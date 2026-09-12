"""
角色生成器 v4 · 都市浮生
================================================================
按用户给的参考图（总经理办公室里的 Q 版小人）重做：

  参考图人物实测（把角色从图里抠出来量的）
    · 约 2.5 头身（头 ≈ 全高 40%），比 v3 的 3 头身 Q、比 2 头身 chibi 收敛
    · 黑色刺猬头 / 乱发，顶部有 3~4 撮尖刺（最关键特征）
    · 苍白偏暖的脸：RGB ≈ (219,173,147)，小眼睛
    · 白色长袖衫（实测 ≈ (209,191,167) 暖白）
    · 深色长裤
    · 整体干净、细长，1px 深描边

画布 32x48、脚在 y=46（与现有一致，替换零回归）。

用法：
    python tools/gen_char_v4.py
    → assets/sprites/v4_<id>.png（5 个待选）+ assets/preview_v4.png（对比总览）
"""

import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from artlib import OUTLINE, FONT_PATH, save  # noqa: E402

CW, CH = 32, 48
FOOT_Y = 46
CX = 15.5

SKIN = (234, 200, 174)
SKIN_L = (248, 222, 200)
SKIN_D = (192, 152, 128)
EYE = (36, 30, 34)


def new():
    img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


def rect(d, x, y, w, h, c):
    if c is None or w <= 0 or h <= 0:
        return
    d.rectangle([int(x), int(y), int(x + w - 1), int(y + h - 1)], fill=c)


def px(d, x, y, c):
    if c is None:
        return
    if 0 <= x < CW and 0 <= y < CH:
        d.point((int(x), int(y)), fill=c)


def sh(c, k):
    return (max(0, min(255, int(c[0] * k))),
            max(0, min(255, int(c[1] * k))),
            max(0, min(255, int(c[2] * k))))


def soft_shadow(img, cx, cy, rx, ry, alpha=124):
    w, h = img.size
    yy, xx = np.mgrid[0:h, 0:w]
    dd = np.sqrt(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2)
    a = (np.clip(1.0 - dd, 0.0, 1.0) ** 1.1) * alpha
    s = np.zeros((h, w, 4), np.uint8)
    s[..., 0], s[..., 1], s[..., 2] = 8, 9, 14
    s[..., 3] = a.astype(np.uint8)
    return Image.alpha_composite(img, Image.fromarray(s, "RGBA"))


# ---------------------------------------------------------------- 绘制
def draw(d, P):
    hair, hairl, hairhl = P["hair"], P["hair_l"], P["hair_hl"]
    shirt, shirtd = P["shirt"], P["shirt_d"]
    pants, pantsd = P["pants"], P["pants_d"]
    shoe = P["shoe"]
    style = P.get("style", "spiky")

    # ---------- 腿（深色长裤）y35..43 ----------
    rect(d, 11, 35, 4, 9, pants)
    rect(d, 17, 35, 4, 9, pants)
    rect(d, 12, 35, 1, 9, sh(pants, 1.45))   # 受光边
    rect(d, 18, 35, 1, 9, pantsd)
    rect(d, 10, 43, 5, 3, shoe)
    rect(d, 17, 43, 5, 3, shoe)
    rect(d, 10, 43, 5, 1, sh(shoe, 2.0))
    rect(d, 17, 43, 5, 1, sh(shoe, 2.0))

    # ---------- 躯干（白色长袖衫）y20..34 ----------
    rect(d, 10, 20, 12, 15, shirt)
    rect(d, 10, 20, 2, 15, sh(shirt, 1.05))   # 左受光
    rect(d, 20, 20, 2, 15, shirtd)            # 右暗部
    rect(d, 10, 33, 12, 2, sh(shirt, 0.86))   # 下摆
    # 领口（小 V）
    rect(d, 13, 20, 6, 2, sh(shirt, 1.12))
    px(d, 15, 21, shirtd)
    px(d, 16, 21, shirtd)
    rect(d, 13, 22, 6, 1, sh(shirt, 0.82))

    # ---------- 长袖手臂 y21..31 ----------
    rect(d, 8, 21, 2, 10, sh(shirt, 0.96))
    rect(d, 22, 21, 2, 10, sh(shirt, 0.86))
    px(d, 8, 31, SKIN)
    px(d, 9, 31, SKIN)
    px(d, 22, 31, SKIN_D)
    px(d, 23, 31, SKIN_D)

    # ---------- 脖子 y18..19 ----------
    rect(d, 13, 18, 6, 2, SKIN_D)

    # ---------- 脸（苍白偏暖，12px 高：y6..17）----------
    rect(d, 9, 7, 14, 10, SKIN)
    rect(d, 10, 6, 12, 1, SKIN)
    rect(d, 8, 8, 1, 8, SKIN)
    rect(d, 23, 8, 1, 8, SKIN)
    rect(d, 10, 17, 12, 1, SKIN)
    rect(d, 9, 7, 2, 8, SKIN_L)                # 左受光
    rect(d, 21, 8, 2, 8, sh(SKIN_D, 1.05))     # 右暗
    # 小眼睛（2x2）
    rect(d, 11, 11, 2, 2, EYE)
    rect(d, 18, 11, 2, 2, EYE)
    px(d, 11, 11, (150, 150, 160))
    px(d, 18, 11, (150, 150, 160))
    # 小嘴
    px(d, 15, 15, sh(SKIN_D, 1.15))
    px(d, 16, 15, sh(SKIN_D, 1.15))

    # ---------- 头发 ----------
    # 注意：1px 描边会闭合 ≤2px 的缝，所以"尖刺"必须做成轮廓本身收尖（而不是浮在外面的孤立像素）
    if style == "spiky":       # 刺猬头（参考图）：顶部收成尖，两侧鬓角
        rect(d, 8, 3, 16, 3, hair)             # y3..5 最宽
        rect(d, 9, 2, 14, 1, hair)             # y2
        rect(d, 11, 1, 9, 1, hair)             # y1
        px(d, 13, 0, hair); rect(d, 14, 0, 3, 1, hair); px(d, 18, 0, hair)   # y0 尖顶
        rect(d, 7, 5, 2, 6, hair)              # 左鬓
        rect(d, 23, 5, 2, 6, hair)             # 右鬓
        rect(d, 9, 6, 3, 1, hair)              # 刘海
        rect(d, 20, 6, 3, 1, hair)
        px(d, 12, 6, hair); px(d, 19, 6, hair)
    elif style == "messy":     # 蓬乱：顶部更宽更不规则
        rect(d, 8, 2, 16, 4, hair)
        rect(d, 9, 1, 14, 1, hair)
        px(d, 10, 0, hair); rect(d, 13, 0, 2, 1, hair); px(d, 18, 0, hair); px(d, 21, 0, hair)
        rect(d, 7, 4, 2, 6, hair)
        rect(d, 23, 4, 2, 6, hair)
        rect(d, 9, 6, 4, 1, hair); rect(d, 19, 6, 4, 1, hair)
        px(d, 14, 6, hair)
    else:                       # short 顺短发：圆润
        rect(d, 8, 2, 16, 4, hair)
        rect(d, 9, 1, 14, 1, hair)
        rect(d, 11, 0, 10, 1, hair)
        rect(d, 7, 5, 2, 6, hair)
        rect(d, 23, 5, 2, 6, hair)
        rect(d, 9, 6, 3, 1, hair); rect(d, 20, 6, 3, 1, hair)

    # 发高光（左上）
    rect(d, 10, 2, 4, 1, hairhl)
    rect(d, 9, 3, 2, 2, hairl)
    px(d, 10, 3, hairhl)
    if style != "short":
        px(d, 20, 3, hairl)


def outline_alpha(img, color=OUTLINE, min_a=200):
    a = np.asarray(img.getchannel("A"), np.uint8)
    core = a >= min_a
    ring = np.zeros_like(core)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dx == 0 and dy == 0:
                continue
            ring |= np.roll(np.roll(core, dy, 0), dx, 1)
    ring &= ~core
    arr = np.asarray(img).copy()
    for i in range(3):
        arr[..., i] = np.where(ring, color[i], arr[..., i])
    arr[..., 3] = np.where(ring | core, 255, 0)
    return Image.fromarray(arr, "RGBA")


def build(P):
    img, d = new()
    img = soft_shadow(img, CX, FOOT_Y - 0.5, 8.4, 2.3, alpha=120)
    d = ImageDraw.Draw(img)
    draw(d, P)
    return outline_alpha(img)


# ---------------------------------------------------------------- 待选形象
VARIANTS = {
    "1_参考还原": dict(
        hair=(30, 28, 34), hair_l=(52, 50, 58), hair_hl=(88, 86, 96),
        shirt=(236, 232, 224), shirt_d=(184, 180, 172),
        pants=(46, 48, 62), pants_d=(32, 34, 46), shoe=(28, 28, 36),
        style="spiky",
    ),
    "2_刺猬棕发": dict(
        hair=(92, 62, 44), hair_l=(122, 86, 60), hair_hl=(156, 116, 84),
        shirt=(210, 224, 232), shirt_d=(156, 174, 186),
        pants=(56, 58, 74), pants_d=(38, 40, 54), shoe=(34, 34, 44),
        style="spiky",
    ),
    "3_金发衬衫": dict(
        hair=(226, 188, 104), hair_l=(244, 212, 136), hair_hl=(255, 234, 176),
        shirt=(228, 226, 222), shirt_d=(176, 174, 170),
        pants=(58, 60, 76), pants_d=(40, 42, 56), shoe=(34, 34, 44),
        style="messy",
    ),
    "4_深蓝短发": dict(
        hair=(44, 56, 92), hair_l=(68, 84, 126), hair_hl=(104, 122, 166),
        shirt=(216, 220, 228), shirt_d=(162, 168, 180),
        pants=(48, 50, 64), pants_d=(34, 36, 48), shoe=(30, 30, 40),
        style="short",
    ),
    "5_红发卫衣": dict(
        hair=(168, 74, 58), hair_l=(196, 98, 76), hair_hl=(224, 130, 104),
        shirt=(180, 132, 118), shirt_d=(132, 94, 84),
        pants=(54, 56, 70), pants_d=(38, 40, 52), shoe=(32, 32, 42),
        style="messy",
    ),
}


def make_sheet():
    scale = 5
    cols, rows = 3, 2
    cell_w, cell_h = CW * scale + 12, CH * scale + 26
    W, H = cols * cell_w + 20, rows * cell_h + 30
    sheet = Image.new("RGBA", (W, H), (16, 18, 28, 255))
    d = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype(FONT_PATH, 15)
    except Exception:
        font = ImageFont.load_default()
    items = list(VARIANTS.items())
    for idx, (name, P) in enumerate(items):
        big = build(P).resize((CW * scale, CH * scale), Image.NEAREST)
        r, c = divmod(idx, cols)
        x = 10 + c * cell_w + 6
        y = 10 + r * cell_h + 14
        sheet.alpha_composite(big, (x, y))
        label = name.split("_", 1)[1]
        tw = d.textlength(label, font=font)
        d.text((x + CW * scale // 2 - tw / 2, y + CH * scale + 2), label,
               fill=(230, 232, 240), font=font)
    return sheet


def main():
    for name, P in VARIANTS.items():
        save(build(P), "v4_%s.png" % name)
    save(make_sheet(), "preview_v4.png")
    print("角色 v4 OK: %d 个待选 -> v4_<id>.png；总览 -> preview_v4.png" % len(VARIANTS))


if __name__ == "__main__":
    main()
