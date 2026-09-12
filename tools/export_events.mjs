/**
 * 把 Canvas 版（citylife/src/data.js）的 65 个事件导出成 Godot 可读的 JSON
 *
 * 关键处理：事件里的 cond 是 JS 函数，无法序列化。
 * 这里用正则把常见条件抽成「可判定的数据描述」：
 *   s.money >= 600000   → { "money_min": 600000 }
 *   s.health < 55       → { "health_max": 54 }
 *   s.flags.married     → { "flags": ["married"] }
 *   !s.flags.noChild    → { "flags_not": ["noChild"] }
 *   s.job === 'founder' → { "job": "founder" }
 *
 * 解析不了的复杂条件直接记为 null（宽松处理，宁可多触发也别触发不了——
 * Canvas 版就踩过「cond 太严导致后期无事件可触发」的坑）。
 *
 * 用法： node tools/export_events.mjs
 */

import { EVENTS } from '../../citylife/src/data.js';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const OUT_DIR = path.join(ROOT, 'data');

function num(s) {
  return Number(s);
}

function parseCond(fn) {
  if (typeof fn !== 'function') return null;
  const src = fn.toString();
  const c = {};

  let m;
  // money
  if ((m = src.match(/s\.money\s*>=\s*(-?\d+)/))) c.money_min = num(m[1]);
  if ((m = src.match(/s\.money\s*<=\s*(-?\d+)/))) c.money_max = num(m[1]);
  if ((m = src.match(/s\.money\s*<\s*(-?\d+)/))) c.money_max = num(m[1]) - 1;
  if ((m = src.match(/s\.money\s*>\s*(-?\d+)/))) c.money_min = num(m[1]) + 1;
  // health
  if ((m = src.match(/s\.health\s*>=\s*(-?\d+)/))) c.health_min = num(m[1]);
  if ((m = src.match(/s\.health\s*<=\s*(-?\d+)/))) c.health_max = num(m[1]);
  if ((m = src.match(/s\.health\s*<\s*(-?\d+)/))) c.health_max = num(m[1]) - 1;
  // mood
  if ((m = src.match(/s\.mood\s*>=\s*(-?\d+)/))) c.mood_min = num(m[1]);
  if ((m = src.match(/s\.mood\s*<\s*(-?\d+)/))) c.mood_max = num(m[1]) - 1;
  // skill / network
  if ((m = src.match(/s\.skill\s*>=\s*(-?\d+)/))) c.skill_min = num(m[1]);
  if ((m = src.match(/s\.network\s*>=\s*(-?\d+)/))) c.network_min = num(m[1]);
  if ((m = src.match(/s\.age\s*>=\s*(-?\d+)/))) c.age_min = num(m[1]);
  // job
  if ((m = src.match(/s\.job\s*===?\s*'(\w+)'/))) c.job = m[1];
  // flags（区分正负）
  const pos = [];
  const neg = [];
  for (const fm of src.matchAll(/(!)?\s*s\.flags\.(\w+)/g)) {
    if (fm[1] === '!') neg.push(fm[2]);
    else pos.push(fm[2]);
  }
  if (pos.length) c.flags = pos;
  if (neg.length) c.flags_not = neg;

  return Object.keys(c).length ? c : null;
}

const out = EVENTS.map((e) => ({
  id: e.id,
  scene: e.scene,
  speaker: e.speaker || '',
  title: e.title || '',
  text: e.text || '',
  age: e.age || null,
  weight: e.weight || 1,
  cond: parseCond(e.cond),
  options: (e.options || []).map((o) => ({
    text: o.text,
    cond: parseCond(o.cond),
    effects: o.effects || {},
    flags: o.flags || null,
    job: o.job || null,
    result: o.result || '',
  })),
}));

fs.mkdirSync(OUT_DIR, { recursive: true });
const outFile = path.join(OUT_DIR, 'events.json');
fs.writeFileSync(outFile, JSON.stringify(out, null, 1), 'utf8');

// 统计
const withCond = out.filter((e) => e.cond).length;
const optWithCond = out.reduce((n, e) => n + e.options.filter((o) => o.cond).length, 0);
const scenes = {};
out.forEach((e) => { scenes[e.scene] = (scenes[e.scene] || 0) + 1; });

console.log(`已导出 ${out.length} 个事件 → ${path.relative(ROOT, outFile)}`);
console.log(`事件级条件解析成功：${withCond}/${out.length}（其余宽松处理）`);
console.log(`选项级条件解析成功：${optWithCond}`);
console.log('场景分布：', Object.entries(scenes).map(([k, v]) => `${k}:${v}`).join('  '));
