"""
Q 版大头萌系角色生成器 · 都市浮生
================================================================
按用户要求把角色重绘成「Q 版大头萌系」：
    · 2 头身（头 ≈ 全高 1/2），大头 + 小身子 + 短手短腿
    · 大眼睛（带高光）+ 小嘴 + 腮红
    · 亮色衣服（暗色夜城里能"跳"出来）+ 1px 深描边（像素风）

画布仍是 32x48、脚在 y=46（和现有玩家一致，替换零碰撞/布局回归）。

用法：
    python tools/gen_char_chibi.py
    → assets/sprites/chibi_<id>.png（6 个待选）+ assets/preview_chibi.png（对比总览）
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

# 通用肤色（Q 版偏白嫩）
SKIN = (240, 210, 186)
SKIN_L = (252, 230, 208)
SKIN_D = (196, 158, 134)
BLUSH = (246, 168, 168)
EYE = (30, 28, 40)          # 深近黑虹膜
EYE_HL = (255, 255, 255)    # 高光

OUTLINE = OUTLINE


def new():
    img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


def px(d, x, y, c):
    if c is None:
        return
    if 0 <= x < CW and 0 <= y < CH:
        d.point((int(x), int(y)), fill=c)


def rect(d, x, y, w, h, c):
    if c is None or w <= 0 or h <= 0:
        return
    d.rectangle([int(x), int(y), int(x + w - 1), int(y + h - 1)], fill=c)


def shade(c, k):
    return (max(0, min(255, int(c[0] * k))),
            max(0, min(255, int(c[1] * k))),
            max(0, min(255, int(c[2] * k))))


def soft_shadow(img, cx, cy, rx, ry, alpha=120):
    w, h = img.size
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.sqrt(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2)
    a = (np.clip(1.0 - d, 0.0, 1.0) ** 1.1) * alpha
    sh = np.zeros((h, w, 4), np.uint8)
    sh[..., 0], sh[..., 1], sh[..., 2] = 8, 9, 14
    sh[..., 3] = a.astype(np.uint8)
    return Image.alpha_composite(img, Image.fromarray(sh, "RGBA"))


# ---------------------------------------------------------------- 大头小人
def draw_chibi(d, P):
    hair, hair_l, hair_hl = P["hair"], P["hair_l"], P["hair_hl"]
    top, top_d = P["top"], P["top_d"]
    pants, pants_d = P["pants"], P["pants_d"]
    shoe = P["shoe"]
    blush = P.get("blush", True)
    hair_style = P.get("hair_style", "bob")   # bob 圆盖 / messy 蓬乱 / long 长发

    # ---- 脸（大圆脸：x7..24 宽 18，y6..21 高 16）----
    rect(d, 7, 8, 18, 12, SKIN)               # 主体
    rect(d, 8, 6, 16, 2, SKIN)                # 顶部收圆
    rect(d, 6, 9, 2, 9, SKIN)                 # 左侧外扩
    rect(d, 24, 9, 2, 9, SKIN)                # 右侧外扩
    rect(d, 8, 20, 16, 1, SKIN)               # 下巴
    rect(d, 7, 8, 2, 8, SKIN_L)               # 左侧受光
    rect(d, 23, 9, 2, 7, shade(SKIN_D, 1.04))  # 右侧暗部
    rect(d, 8, 20, 16, 1, SKIN_D)             # 下巴阴影

    # ---- 大眼睛（4x3，带高光）----
    rect(d, 10, 12, 4, 3, EYE)                # 左眼
    rect(d, 18, 12, 4, 3, EYE)                # 右眼
    px(d, 10, 12, EYE_HL)                     # 左上高光
    px(d, 11, 12, EYE_HL)
    px(d, 18, 12, EYE_HL)
    px(d, 19, 12, EYE_HL)
    px(d, 11, 14, shade(EYE, 1.6))            # 眼底反光
    px(d, 19, 14, shade(EYE, 1.6))

    # ---- 嘴（小笑）+ 腮红 ----
    rect(d, 15, 18, 2, 1, shade(SKIN_D, 1.25))
    px(d, 14, 18, shade(SKIN_D, 1.1))
    if blush:
        px(d, 9, 15, BLUSH)
        px(d, 22, 15, BLUSH)
        px(d, 9, 16, shade(BLUSH, 0.92))
        px(d, 22, 16, shade(BLUSH, 0.92))

    # ---- 头发（盖在头顶 + 两侧，视风格）----
    if hair_style == "long":
        rect(d, 5, 2, 22, 5, hair)             # 顶
        rect(d, 5, 7, 3, 15, hair)             # 左侧长发
        rect(d, 24, 7, 3, 15, hair)            # 右侧长发
        rect(d, 6, 2, 20, 3, hair)
    elif hair_style == "messy":
        rect(d, 6, 1, 20, 6, hair)
        rect(d, 5, 3, 22, 3, hair)
        px(d, 6, 0, hair); px(d, 12, 0, hair); px(d, 20, 0, hair)  # 翘毛
        px(d, 25, 5, hair); px(d, 7, 6, hair)
        rect(d, 5, 6, 2, 6, hair)              # 鬓角
        rect(d, 25, 6, 2, 6, hair)
    else:  # bob 圆盖
        rect(d, 5, 1, 22, 3, hair)
        rect(d, 4, 4, 24, 4, hair)
        rect(d, 5, 8, 2, 3, hair)              # 两侧
        rect(d, 25, 8, 2, 3, hair)
        rect(d, 6, 4, 20, 2, hair)
        px(d, 7, 2, hair); px(d, 24, 2, hair)

    # 发高光（左上打光）
    rect(d, 7, 2, 6, 1, hair_hl)
    rect(d, 6, 4, 3, 2, hair_l)
    rect(d, 8, 3, 4, 1, hair_hl)
    px(d, 7, 4, hair_hl)
    if hair_style == "bob":
        rect(d, 12, 4, 8, 1, hair_hl)

    # ---- 脖子 ----
    rect(d, 13, 22, 6, 2, SKIN_D)

    # ---- 身体（小身子）----
    acc = P.get("accessory", "")
    if acc == "suit":
        rect(d, 10, 24, 12, 10, top)           # 西装
        rect(d, 10, 24, 2, 10, shade(top, 1.06))
        rect(d, 20, 24, 2, 10, top_d)
        rect(d, 14, 24, 4, 7, P.get("inner", (250, 250, 250)))  # 衬衫
        rect(d, 15, 24, 2, 6, P.get("tie", (150, 60, 60)))       # 领带
        px(d, 16, 30, P.get("tie", (150, 60, 60)))
    else:
        rect(d, 10, 24, 12, 10, top)
        rect(d, 10, 24, 2, 10, shade(top, 1.06))
        rect(d, 20, 24, 2, 10, top_d)
        rect(d, 12, 24, 8, 2, shade(top, 1.14))  # 领口
        rect(d, 12, 24, 8, 1, P.get("collar", shade(top, 0.9)))

    if acc == "hood":
        rect(d, 10, 24, 12, 4, shade(top, 0.82))   # 帽子披肩
        rect(d, 10, 24, 12, 1, shade(top, 1.1))

    # ---- 短手臂 ----
    rect(d, 8, 25, 2, 6, shade(top, 0.95))
    rect(d, 22, 25, 2, 6, shade(top, 0.82))
    px(d, 8, 31, SKIN)
    px(d, 9, 31, SKIN)
    px(d, 22, 31, SKIN_D)
    px(d, 23, 31, SKIN_D)

    # ---- 短腿 + 鞋 ----
    rect(d, 11, 34, 4, 9, pants)
    rect(d, 17, 34, 4, 9, pants)
    rect(d, 12, 34, 1, 9, shade(pants, 1.4))
    rect(d, 18, 34, 1, 9, pants_d)
    rect(d, 10, 43, 6, 2, shoe)               # 左鞋
    rect(d, 16, 43, 6, 2, shoe)               # 右鞋
    rect(d, 10, 43, 6, 1, shade(shoe, 2.0))
    rect(d, 16, 43, 6, 1, shade(shoe, 2.0))
    px(d, 11, 44, shade(shoe, 1.5))
    px(d, 17, 44, shade(shoe, 1.5))


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
    arr[..., 0] = np.where(ring, color[0], arr[..., 0])
    arr[..., 1] = np.where(ring, color[1], arr[..., 1])
    arr[..., 2] = np.where(ring, color[2], arr[..., 2])
    arr[..., 3] = np.where(ring | core, 255, 0)
    return Image.fromarray(arr, "RGBA")


def build(P):
    img, d = new()
    img = soft_shadow(img, CX, FOOT_Y - 0.5, 8.6, 2.4, alpha=118)
    d = ImageDraw.Draw(img)
    draw_chibi(d, P)
    return outline_alpha(img)


# ---------------------------------------------------------------- 6 个待选形象
VARIANTS = {
    "1_黑发白衫": dict(
        hair=(42, 40, 54), hair_l=(66, 64, 82), hair_hl=(104, 100, 122),
        top=(236, 238, 240), top_d=(176, 182, 192), collar=(150, 160, 176),
        pants=(58, 64, 86), pants_d=(42, 46, 64), shoe=(34, 34, 44),
        hair_style="bob",
    ),
    "2_棕发连帽": dict(
        hair=(96, 66, 46), hair_l=(126, 90, 62), hair_hl=(160, 122, 88),
        top=(96, 190, 176), top_d=(64, 140, 128), collar=(84, 168, 156),
        pants=(54, 58, 74), pants_d=(38, 42, 56), shoe=(40, 40, 50),
        hair_style="messy", accessory="hood",
    ),
    "3_金发T恤": dict(
        hair=(232, 192, 96), hair_l=(248, 214, 128), hair_hl=(255, 238, 176),
        top=(226, 100, 92), top_d=(170, 68, 60), collar=(196, 82, 72),
        pants=(70, 74, 92), pants_d=(52, 56, 70), shoe=(44, 44, 56),
        hair_style="messy",
    ),
    "4_黑发西装": dict(
        hair=(34, 34, 46), hair_l=(56, 56, 72), hair_hl=(92, 92, 110),
        top=(54, 58, 78), top_d=(38, 42, 58), inner=(244, 244, 246),
        tie=(150, 66, 60),
        pants=(46, 50, 66), pants_d=(32, 36, 48), shoe=(26, 26, 34),
        hair_style="bob", accessory="suit",
    ),
    "5_紫发卫衣": dict(
        hair=(132, 92, 178), hair_l=(160, 118, 202), hair_hl=(190, 152, 224),
        top=(164, 128, 196), top_d=(120, 90, 150), collar=(146, 112, 176),
        pants=(66, 66, 84), pants_d=(48, 48, 62), shoe=(44, 44, 56),
        hair_style="bob", blush=True,
    ),
    "6_红发夹克": dict(
        hair=(188, 82, 66), hair_l=(214, 106, 84), hair_hl=(236, 140, 112),
        top=(120, 96, 80), top_d=(84, 66, 54), collar=(104, 82, 68),
        pants=(56, 58, 70), pants_d=(40, 42, 52), shoe=(36, 36, 46),
        hair_style="messy",
    ),
}


def make_sheet():
    """6 个形象排成 2 行 3 列，每个放大 5 倍，下方写编号标签。"""
    scale = 5
    cols, rows = 3, 2
    cell_w, cell_h = CW * scale + 12, CH * scale + 26
    W, H = cols * cell_w + 20, rows * cell_h + 30
    sheet = Image.new("RGBA", (W, H), (16, 18, 28, 255))
    d = ImageDraw.Draw(sheet)
    try:
        label_font = ImageFont.truetype(FONT_PATH, 15)
    except Exception:
        label_font = ImageFont.load_default()

    items = list(VARIANTS.items())
    for idx, (name, P) in enumerate(items):
        sprite = build(P)
        big = sprite.resize((CW * scale, CH * scale), Image.NEAREST)
        r, c = divmod(idx, cols)
        x = 10 + c * cell_w + 6
        y = 10 + r * cell_h + 14
        sheet.alpha_composite(big, (x, y))
        # 标签（去掉序号前缀，只留名称），用中文字体渲染
        label = name.split("_", 1)[1]
        tw = d.textlength(label, font=label_font)
        d.text((x + CW * scale // 2 - tw / 2, y + CH * scale + 2), label,
               fill=(230, 232, 240), font=label_font)
    return sheet


def main():
    for name, P in VARIANTS.items():
        save(build(P), "chibi_%s.png" % name)
    save(make_sheet(), "preview_chibi.png")
    print("Q 版角色 OK: 6 个待选形象 -> chibi_<id>.png；总览 -> preview_chibi.png")


if __name__ == "__main__":
    main()
