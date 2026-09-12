#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
字体自检：确认「界面上可能出现的每一个字符」都在 assets/fonts/GameCN.ttf 里。

特别注意：会检查**空格**等空白字符。
之前踩过的坑：ASCII 范围写成 range(0x21, 0x7F) 漏掉了 0x20(空格)，
导致界面里所有空格渲染成豆腐块。

用法：
    python tools/verify_font.py     # 全部存在 → 退出码 0；否则打印缺字并退出码 1
"""
import os
import sys

from fontTools.ttLib import TTFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

SRC = [
    "scripts/Data.gd", "scripts/Game.gd", "scripts/Events.gd",
    "scripts/Rules.gd", "scripts/Player.gd",
    "data/events.json", "data/rules.json", "project.godot",
]
FONT = os.path.join(ROOT, "assets", "fonts", "GameCN.ttf")

# 控制字符不会被渲染，无需字体覆盖
SKIP = {"\n", "\r", "\t", "\x0b", "\x0c"}


def main() -> int:
    if not os.path.exists(FONT):
        print("字体不存在:", FONT)
        return 1
    cmap = TTFont(FONT).getBestCmap()

    needed = set()
    for rel in SRC:
        p = os.path.join(ROOT, rel)
        if not os.path.exists(p):
            continue
        for ch in open(p, encoding="utf-8").read():
            if ch in SKIP:
                continue
            needed.add(ch)

    missing = sorted(c for c in needed if ord(c) not in cmap)
    print("需要覆盖的字符数:", len(needed))

    # 显式强调几个最容易漏的
    for name, c in [("空格", " "), ("不换行空格", "\u00a0"), ("全角空格", "\u3000")]:
        ok = ord(c) in cmap
        print("  %s (U+%04X): %s" % (name, ord(c), "有" if ok else "缺失!!"))

    if missing:
        print("缺失字符 (%d 个):" % len(missing))
        print("  " + "".join(repr(c) + " " for c in missing))
        print("FONT_CHECK_FAIL")
        return 1

    print("FONT_CHECK_OK —— 界面所需字符全部覆盖")
    return 0


if __name__ == "__main__":
    sys.exit(main())
