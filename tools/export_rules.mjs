/**
 * 把 Canvas 版的「规则层」导出成 Godot 可读的 JSON
 *
 * 包括：职业表（薪资/属性衰减）、生活成本、晋升路径、结局判定、平衡常量。
 * 这些数值在 Canvas 版已经用 600 局模拟调过平衡，直接搬过来，别重新拍脑袋。
 *
 * 用法： node tools/export_rules.mjs
 */

import { JOBS, LIVING_COST, LIVING_COST_OWN, MORTGAGE_YEAR, ENDINGS } from '../../citylife/src/data.js';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const OUT_DIR = path.join(ROOT, 'data');

// 晋升路径：与 citylife/src/game.js 里的 PROMOTE_PATH 保持一致
const PROMOTE_PATH = {
  intern: 'operator',
  operator: 'manager',
  coder: 'manager',
  pm: 'manager',
  designer: 'manager',
  sales: 'manager',
  teacher: 'manager',
  civil: 'manager',
  rider: 'operator',
  freelance: 'manager',
  manager: 'director',
};

// 平衡常量：与 citylife/src/game.js 保持一致
const CONST = {
  start_age: 22,
  end_age: 60,
  bankrupt_limit: -600000,
  // 消费升级：收入越高、年纪越大，花销水涨船高
  lifestyle_base: 0.25,
  lifestyle_age_step: 0.007,
  lifestyle_age_from: 30,
  // 收入系数
  income_base: 0.85,
  income_skill_div: 280,
  income_network_div: 550,
  // 自然恢复（随年龄递减）
  recover_base: 3.2,
  recover_age_step: 0.05,
  mood_recover: 1.4,
  // 晋升 / 再就业 / 创业结算
  promote_skill: 68,
  promote_network: 50,
  promote_chance: 0.12,
  rehire_min_years: 2,
  rehire_base: 0.35,
  rehire_step: 0.12,
  ipo_skill: 66,
  ipo_network: 58,
  ipo_chance: 0.07,
  ipo_bonus: 500000,
};

function num(s) {
  return Number(s);
}

function parseCond(fn) {
  if (typeof fn !== 'function') return null;
  const src = fn.toString();
  const c = {};
  let m;
  if ((m = src.match(/s\.money\s*>=\s*(-?\d+)/))) c.money_min = num(m[1]);
  if ((m = src.match(/s\.money\s*<=\s*(-?\d+)/))) c.money_max = num(m[1]);
  if ((m = src.match(/s\.money\s*<\s*(-?\d+)/))) c.money_max = num(m[1]) - 1;
  if ((m = src.match(/s\.money\s*>\s*(-?\d+)/))) c.money_min = num(m[1]) + 1;
  if ((m = src.match(/s\.health\s*>=\s*(-?\d+)/))) c.health_min = num(m[1]);
  if ((m = src.match(/s\.health\s*<=\s*(-?\d+)/))) c.health_max = num(m[1]);
  if ((m = src.match(/s\.health\s*<\s*(-?\d+)/))) c.health_max = num(m[1]) - 1;
  if ((m = src.match(/s\.mood\s*>=\s*(-?\d+)/))) c.mood_min = num(m[1]);
  if ((m = src.match(/s\.mood\s*<\s*(-?\d+)/))) c.mood_max = num(m[1]) - 1;
  if ((m = src.match(/s\.skill\s*>=\s*(-?\d+)/))) c.skill_min = num(m[1]);
  if ((m = src.match(/s\.network\s*>=\s*(-?\d+)/))) c.network_min = num(m[1]);
  if ((m = src.match(/s\.network\s*<\s*(-?\d+)/))) c.network_max = num(m[1]) - 1;
  if ((m = src.match(/s\.age\s*>=\s*(-?\d+)/))) c.age_min = num(m[1]);
  if ((m = src.match(/s\.job\s*===?\s*'(\w+)'/))) c.job = m[1];
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

const out = {
  const: CONST,
  jobs: JOBS,
  living_cost: LIVING_COST,
  living_cost_own: LIVING_COST_OWN,
  mortgage_year: MORTGAGE_YEAR,
  promote_path: PROMOTE_PATH,
  endings: ENDINGS.map((e) => ({
    id: e.id,
    name: e.name,
    desc: e.desc || '',
    cond: parseCond(e.cond),
  })),
};

fs.mkdirSync(OUT_DIR, { recursive: true });
const outFile = path.join(OUT_DIR, 'rules.json');
fs.writeFileSync(outFile, JSON.stringify(out, null, 1), 'utf8');

const parsedEndings = out.endings.filter((e) => e.cond).length;
console.log(`已导出规则 → ${path.relative(ROOT, outFile)}`);
console.log(`  职业 ${Object.keys(JOBS).length} 个`);
console.log(`  结局 ${out.endings.length} 个（条件解析成功 ${parsedEndings}）`);
console.log(`  生活成本：租房 ${LIVING_COST} / 有房 ${LIVING_COST_OWN} / 房贷 ${MORTGAGE_YEAR}`);
