#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
生成游戏用中文字体（子集化），输出 assets/fonts/GameCN.ttf

为什么需要：Godot 默认字体不含中日韩字形。桌面端靠系统字体回退能显示，
Web 导出包里没有系统字体 → 中文全部变「豆腐块」。
所以在 project.godot 里设置 gui/theme/custom_font 指向本脚本产出的字体。

覆盖范围 = 源码里出现的所有字符 ∪ GB2312 全字表 ∪ 常用标点符号区 ∪ ASCII
（GB2312 覆盖日常中文；以后新增文案基本不会再缺字）

用法：
    python tools/gen_font.py
改完文案/数据后重跑一次即可。

依赖：fonttools
"""
import os
import sys

from fontTools.ttLib import TTFont
from fontTools.subset import Subsetter, Options
from fontTools.varLib.instancer import instantiateVariableFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

# 待扫描的文本来源（源码 + 数据 + 配置）
SRC = [
    "scripts/Data.gd", "scripts/Game.gd", "scripts/Events.gd",
    "scripts/Rules.gd", "scripts/Player.gd",
    "data/events.json", "data/rules.json", "project.godot",
]
# 候选系统字体（按优先级）
FONT_CANDIDATES = [
    "C:/Windows/Fonts/NotoSansSC-VF.ttf",
    "C:/Windows/Fonts/NotoSansSC-Regular.otf",
    "C:/Windows/Fonts/msyh.ttc",
    "C:/Windows/Fonts/simhei.ttf",
]
OUT = os.path.join(ROOT, "assets", "fonts", "GameCN.ttf")


def collect_chars() -> set:
    chars = set()
    for rel in SRC:
        p = os.path.join(ROOT, rel)
        if not os.path.exists(p):
            print("  skip (missing):", rel)
            continue
        for ch in open(p, encoding="utf-8").read():
            if ch.strip():
                chars.add(ch)
    # GB2312 全字表（6763 汉字 + 符号）
    for b1 in range(0xA1, 0xFA):
        for b2 in range(0xA1, 0xFF):
            try:
                chars.add(bytes([b1, b2]).decode("gb2312"))
            except Exception:
                pass
    # 常用标点 / 符号区
    ranges = [
        (0x2000, 0x206F),  # General Punctuation
        (0x2190, 0x21FF),  # Arrows
        (0x2460, 0x24FF),  # Enclosed Alphanumerics
        (0x25A0, 0x25FF),  # Geometric Shapes
        (0x2600, 0x26FF),  # Misc Symbols
        (0x3000, 0x303F),  # CJK Symbols and Punctuation
        (0xFF00, 0xFFEF),  # Halfwidth and Fullwidth Forms
    ]
    for a, b in ranges:
        for cp in range(a, b + 1):
            try:
                chars.add(chr(cp))
            except Exception:
                pass
    # ASCII（含空格！0x20 必须要有，否则界面里所有空格会渲染成豆腐块）
    for i in range(0x20, 0x7F):
        chars.add(chr(i))
    chars.add("\u00a0")  # 不换行空格
    return chars


def pick_font() -> str:
    for f in FONT_CANDIDATES:
        if os.path.exists(f):
            return f
    sys.exit("找不到可用的中文字体，请安装 Noto Sans SC 或思源黑体")


def main() -> None:
    chars = collect_chars()
    unicodes = sorted(ord(c) for c in chars)
    print("字符数:", len(unicodes))

    src = pick_font()
    print("源字体:", src)
    f = TTFont(src)
    try:
        instantiateVariableFont(f, {"wght": 400}, inplace=True)
        print("  → 可变字重实例化为 wght=400")
    except Exception:
        pass

    opt = Options()
    opt.glyph_names = False
    opt.drop_tables += ["MVAR", "HVAR", "STAT", "GDEF"]
    ss = Subsetter(options=opt)
    ss.populate(unicodes=unicodes)
    ss.subset(f)

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    f.save(OUT)
    size = os.path.getsize(OUT)
    print("已生成:", OUT, "%.2f MB" % (size / 1024 / 1024), "字形数:", f["maxp"].numGlyphs)

    # 校验关键字（含空格！空格缺失会让界面里所有空格变成豆腐块）
    cm = f.getBestCmap()
    must_have = " 都市浮生第岁碎片清醒疯狂觉醒考研海归旧巷口天台霓虹·｜"
    missing = [c for c in must_have if ord(c) not in cm]
    if missing:
        sys.exit("缺字: " + repr("".join(missing)))
    print("校验通过：关键字齐全（含空格）")


if __name__ == "__main__":
    main()
