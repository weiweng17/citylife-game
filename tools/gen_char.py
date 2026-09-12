"""
角色生成器 · 都市浮生 v3
================================================================
对照参考图里的小人重做：

  参考图角色特征（放大原图数出来的）
    · 约 3 头身（头 ≈ 全高的 1/3），不是 2 头身 Q 版
    · 深色蓬松短发 + 两侧鬓角，额头露出一条，脸不被头发盖住
    · 白/浅色衬衫 + 深色长裤 + 深色鞋 → 明暗对比强，暗场景里能"跳"出来
    · 1px 深色描边（像素风关键）
    · 脚下是软椭圆投影，不是硬边黑圈

  画布 32x48（原来 24x32）：
    参考图角色约占屏高 7~8%，360x640 竖屏下 48/640 = 7.5%，对得上。
    原点定在"脚底"（y=46），便于和地图上的门口坐标对齐。

  几何（画布 32 宽，中线 x=15.5）
    头发尖 y0..1 / 头发 y2..7 / 脸 y8..16 / 下巴 y17
    脖子 y18 / 躯干 y19..32 / 腿 y33..42 / 鞋 y43..45 / 影子 y~45.5
    躯干 x10..21 (12)  手臂 x8..9, x22..23  腿 x10..14, x17..21（中缝 2px）
    → 全高 46px，头 16px ⇒ 约 2.9 头身

用法：
    python tools/gen_char.py            # 主角色（容姿+4帧走）+ 6 个 NPC
"""

import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from artlib import (  # noqa: E402
    HAIR, HAIR_HL, HAIR_L, OUTLINE, PANTS, PANTS_D, SHIRT, SHIRT_D, SHOE,
    SKIN, SKIN_D, SKIN_L, SPR, TIE, save,
)

CW, CH = 32, 48
FOOT_Y = 46
CX = 15.5

# 纵向关键线
Y_HAIR_TIP = 0
Y_HAIR = 2
Y_FACE = 8
Y_CHIN = 17
Y_NECK = 18
Y_TORSO = 19
Y_TORSO_END = 32
Y_LEG = 33
Y_SHOE = 43
Y_SHADOW = 45.6


# ---------------------------------------------------------------- 基础绘制
def new():
    img = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


def px(d, x, y, c):
    if c is None:
        return
    if 0 <= x < CW and 0 <= y < CH:
        d.point((x, y), fill=c)


def rect(d, x, y, w, h, c):
    if c is None or w <= 0 or h <= 0:
        return
    d.rectangle([x, y, x + w - 1, y + h - 1], fill=c)


def shade(c, k):
    return (max(0, min(255, int(c[0] * k))),
            max(0, min(255, int(c[1] * k))),
            max(0, min(255, int(c[2] * k))))


def soft_shadow(img, cx, cy, rx, ry, alpha=132):
    """软椭圆投影：中心实、外圈渐隐（参考图角色脚下就是这个）。"""
    w, h = img.size
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.sqrt(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2)
    a = (np.clip(1.0 - d, 0.0, 1.0) ** 1.15) * alpha
    sh = np.zeros((h, w, 4), np.uint8)
    sh[..., 0], sh[..., 1], sh[..., 2] = 8, 9, 14
    sh[..., 3] = a.astype(np.uint8)
    return Image.alpha_composite(img, Image.fromarray(sh, "RGBA"))


# ---------------------------------------------------------------- 小人
DEFAULT = {
    "hair": HAIR, "hair_l": HAIR_L, "hair_hl": HAIR_HL,
    "skin": SKIN, "skin_l": SKIN_L, "skin_d": SKIN_D,
    "top": SHIRT, "top_d": SHIRT_D, "tie": TIE,
    "pants": PANTS, "pants_d": PANTS_D, "shoe": SHOE,
    "hair_len": 0,        # 0 短发 / 1 及肩 / 2 长发 / 3 蓬乱长发
    "beard": 0,           # 0 无 / 1 胡茬 / 2 络腮
    "accessory": "",      # hat/hood/scarf/robe/apron/vest
    "outer": None, "hat": None, "scarf": None,
    "build": 0.0,         # -1 瘦 / 0 普通 / +1 壮
}


def draw_body(d, P, arm=0, legs=(0, 0), dy=0):
    sk, skl, skd = P["skin"], P["skin_l"], P["skin_d"]
    top, topd, tie = P["top"], P["top_d"], P["tie"]
    pt, ptd, sh = P["pants"], P["pants_d"], P["shoe"]
    hc, hl, hh = P["hair"], P["hair_l"], P["hair_hl"]
    wide = int(round(P.get("build", 0.0)))
    tw = 12 + wide
    tx0 = int(CX - tw / 2 + 0.5)

    # ---- 腿 ----
    ldy, rdy = legs
    rect(d, 10, Y_LEG + ldy, 5, 10 - ldy, pt)
    rect(d, 17, Y_LEG + rdy, 5, 10 - rdy, pt)
    rect(d, 10, Y_LEG + ldy, 1, 10 - ldy, shade(pt, 1.45))   # 左腿受光边
    rect(d, 13, Y_LEG + ldy, 2, 10 - ldy, ptd)
    rect(d, 17, Y_LEG + rdy, 2, 10 - rdy, ptd)

    # ---- 鞋（比裤子略亮一点，否则整条腿+鞋会糊成一根黑棒）----
    rect(d, 9, Y_SHOE + ldy, 5, 3, sh)
    rect(d, 18, Y_SHOE + rdy, 5, 3, sh)
    rect(d, 9, Y_SHOE + ldy, 5, 1, shade(sh, 2.3))
    rect(d, 18, Y_SHOE + rdy, 5, 1, shade(sh, 2.3))
    px(d, 9, Y_SHOE + ldy + 1, shade(sh, 1.5))
    px(d, 18, Y_SHOE + rdy + 1, shade(sh, 1.5))

    # ---- 躯干 ----
    ty = Y_TORSO + dy
    rect(d, tx0, ty, tw, 14, top)
    rect(d, tx0, ty, 2, 14, shade(top, 1.07))
    rect(d, tx0 + tw - 2, ty, 2, 14, topd)
    rect(d, tx0, ty + 12, tw, 2, shade(top, 0.84))
    rect(d, tx0 + 4, ty, 5, 2, shade(top, 1.14))          # 领口
    px(d, int(CX), ty + 1, tie)
    rect(d, int(CX) - 1, ty + 2, 2, 8, tie)

    # ---- 手臂 ----
    asw = arm
    rect(d, tx0 - 2, ty + 1 + max(0, asw), 2, 9, shade(top, 0.95))
    px(d, tx0 - 2, ty + 10 + max(0, asw), sk)
    px(d, tx0 - 1, ty + 10 + max(0, asw), sk)
    rect(d, tx0 + tw, ty + 1 + max(0, -asw), 2, 9, shade(top, 0.86))
    px(d, tx0 + tw, ty + 10 + max(0, -asw), skd)
    px(d, tx0 + tw + 1, ty + 10 + max(0, -asw), skd)

    # 外搭
    acc = P.get("accessory", "")
    if acc in ("vest", "robe", "hood", "apron"):
        oc = P.get("outer") or shade(top, 0.6)
        rect(d, tx0, ty, tw, 13, oc)
        rect(d, tx0, ty, 2, 13, shade(oc, 1.14))
        rect(d, tx0 + tw - 2, ty, 2, 13, shade(oc, 0.84))
        rect(d, tx0 + 4, ty, tw - 8, 12, top)
        if acc == "apron":
            rect(d, tx0, ty + 9, tw, 4, oc)
            rect(d, tx0 + 2, ty + 1, tw - 4, 1, shade(oc, 1.2))
        if acc == "robe":
            rect(d, tx0 + 4, ty + 4, tw - 8, 1, shade(oc, 0.68))
            rect(d, tx0 + 4, ty + 8, tw - 8, 1, shade(oc, 0.68))

    # ---- 脖子 ----
    rect(d, 13, Y_NECK, 5, 2, skd)

    # ---- 脸（y7..17 一整块，别单独画"下巴行"——那会被描边夹成双层黑带）----
    rect(d, 10, Y_FACE - 1, 12, 11, sk)
    rect(d, 11, Y_CHIN, 10, 1, sk)
    rect(d, 10, Y_FACE - 1, 2, 9, skl)                  # 左侧受光
    rect(d, 20, Y_FACE + 1, 2, 8, shade(skd, 1.06))     # 右侧暗部（轻一点，
    #                                                      自明暗主要交给运行时光照）
    rect(d, 12, Y_CHIN - 1, 8, 1, skd)                  # 下巴阴影

    # ---- 五官（眼 y10 / 嘴 y13，上方留 3 行额头，别太高也别太低）----
    rect(d, 12, 10, 2, 1, OUTLINE)                      # 眼
    rect(d, 18, 10, 2, 1, OUTLINE)
    px(d, 12, 10, shade(tie, 0.5))
    px(d, 18, 10, shade(tie, 0.5))
    px(d, 15, 13, skd)                                  # 嘴
    px(d, 14, 13, shade(skd, 1.08))
    if P.get("beard", 0) >= 1:
        rect(d, 12, 15, 8, 1, shade(hc, 1.5))
    if P.get("beard", 0) >= 2:
        rect(d, 10, 13, 2, 5, shade(hc, 1.4))
        rect(d, 20, 13, 2, 5, shade(hc, 1.4))
        rect(d, 12, 15, 8, 2, shade(hc, 1.45))

    # ---- 头发：圆盖 + 顶部尖 + 上缘一条受光带 ----
    # 整块纯深色会读成"头盔"或"戴帽子"，必须做出圆角轮廓和明确的高光带。
    rect(d, 9, 4, 14, 2, hc)                            # y4..5 最宽（比脸外扩 1px）
    rect(d, 11, 2, 10, 2, hc)                           # y2..3
    rect(d, 13, 1, 6, 1, hc)                            # y1 收口
    px(d, 12, 1, hc)                                    # 顶部尖（三个）
    px(d, 19, 1, hc)
    rect(d, 14, Y_HAIR_TIP, 2, 1, hc)
    rect(d, 10, 6, 12, 1, hc)                           # y6
    rect(d, 10, 7, 4, 1, hc)                            # y7 两侧刘海锁
    rect(d, 18, 7, 4, 1, hc)
    px(d, 9, 6, hc)
    px(d, 22, 6, hc)
    rect(d, 9, 7, 1, 4, hc)                             # 鬓角
    rect(d, 22, 7, 1, 4, hc)
    # 受光带（左上打光）：从 y2 拉到 y5 的一条斜向亮带
    rect(d, 11, 2, 4, 1, hl)
    rect(d, 10, 4, 3, 2, hl)
    rect(d, 12, 3, 3, 1, hl)
    rect(d, 12, 2, 2, 1, hh)
    px(d, 11, 3, hh)
    rect(d, 11, 4, 2, 1, hh)
    px(d, 20, 3, hl)
    px(d, 21, 5, hl)
    rect(d, 18, 7, 3, 1, shade(hc, 1.45))
    px(d, 9, 9, shade(hc, 1.4))
    px(d, 22, 9, shade(hc, 1.4))

    ln = P.get("hair_len", 0)
    if ln >= 1:
        rect(d, 8, Y_HAIR + 3, 1, 9, hc)
        rect(d, 23, Y_HAIR + 3, 1, 9, hc)
    if ln >= 2:
        rect(d, 7, Y_HAIR + 3, 1, 15, hc)
        rect(d, 24, Y_HAIR + 3, 1, 15, hc)
    if ln >= 3:
        rect(d, 6, Y_HAIR + 4, 1, 19, hc)
        rect(d, 25, Y_HAIR + 4, 1, 19, hc)
        rect(d, 11, Y_HAIR - 4, 2, 3, hc)
        rect(d, 19, Y_HAIR - 3, 2, 3, hc)

    # ---- 配件 ----
    acc = P.get("accessory", "")
    if acc == "hat":
        c = P.get("hat") or (58, 58, 70)
        rect(d, 8, Y_HAIR - 1, 16, 2, c)
        rect(d, 10, Y_HAIR - 5, 12, 4, c)
        rect(d, 12, Y_HAIR - 6, 8, 1, shade(c, 1.25))
        rect(d, 10, Y_HAIR - 1, 12, 1, shade(c, 0.68))
    if acc == "hood":
        c = P.get("outer") or shade(top, 0.6)
        rect(d, 8, Y_HAIR + 2, 16, 2, c)
        rect(d, 7, Y_HAIR + 2, 1, 9, c)
        rect(d, 24, Y_HAIR + 2, 1, 9, c)
    if acc == "scarf":
        c = P.get("scarf") or (150, 66, 58)
        rect(d, 11, Y_NECK, 10, 2, c)
        rect(d, 19, Y_NECK + 2, 3, 7, c)
        px(d, 19, Y_NECK + 9, shade(c, 0.7))


def build(P, arm=0, legs=(0, 0), dy=0, shadow=True, outline=True):
    img, d = new()
    if shadow:
        img = soft_shadow(img, CX, Y_SHADOW, 8.6, 2.7, alpha=138)
        d = ImageDraw.Draw(img)
    draw_body(d, P, arm, legs, dy)
    return _outline(img) if outline else img


def _outline(img, color=OUTLINE, min_a=200):
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


# 4 帧走路：0 并拢 → 1 左腿抬 → 2 并拢 → 3 右腿抬（身体同时 1px 起伏）
WALK = [
    (0, (0, 0), 0),
    (-1, (2, 0), -1),
    (0, (0, 0), 0),
    (1, (0, 2), -1),
]


def make_player():
    idle = build(DEFAULT)
    strip = Image.new("RGBA", (CW * 4, CH), (0, 0, 0, 0))
    for i, (arm, legs, dy) in enumerate(WALK):
        strip.alpha_composite(build(DEFAULT, arm=arm, legs=legs, dy=dy), (i * CW, 0))
    return idle, strip


# ---------------------------------------------------------------- NPC 变体
NPCS = {
    "chenjie": dict(
        hair=(52, 36, 32), hair_l=(76, 54, 46), hair_hl=(104, 78, 66),
        top=(206, 208, 212), top_d=(148, 152, 158), tie=(126, 66, 60),
        pants=(60, 56, 62), pants_d=(42, 40, 46), hair_len=2,
        accessory="apron", outer=(152, 70, 62), scarf=(178, 96, 96),
    ),
    "laozhang": dict(
        hair=(92, 90, 94), hair_l=(116, 114, 118), hair_hl=(146, 144, 148),
        top=(196, 200, 208), top_d=(138, 144, 154), tie=(52, 62, 88),
        pants=(50, 54, 70), pants_d=(36, 40, 52), beard=1, build=1.0,
    ),
    "laozhou": dict(
        hair=(200, 198, 192), hair_l=(224, 222, 216), hair_hl=(242, 240, 236),
        top=(148, 144, 136), top_d=(104, 100, 94), tie=(70, 66, 60),
        pants=(58, 56, 58), pants_d=(42, 40, 42), beard=2,
        accessory="vest", outer=(82, 78, 74), build=1.0,
    ),
    "daoshi": dict(
        hair=(172, 168, 160), hair_l=(196, 192, 184), hair_hl=(218, 214, 206),
        skin=(204, 174, 150), skin_l=(226, 198, 174), skin_d=(158, 128, 108),
        top=(84, 82, 92), top_d=(56, 54, 64), tie=(40, 38, 48),
        pants=(54, 52, 62), pants_d=(38, 36, 44), hair_len=3, beard=2,
        accessory="robe", outer=(46, 46, 58), build=-1.0,
    ),
    "xiaoyu": dict(
        hair=(66, 48, 40), hair_l=(92, 68, 56), hair_hl=(122, 92, 76),
        top=(198, 152, 142), top_d=(146, 108, 100), tie=(122, 78, 74),
        pants=(70, 62, 68), pants_d=(50, 44, 50), hair_len=3,
        accessory="hood", outer=(124, 90, 94), build=-1.0,
    ),
    "azhe": dict(
        hair=(38, 36, 44), hair_l=(62, 60, 72), hair_hl=(94, 92, 104),
        top=(152, 150, 154), top_d=(104, 102, 108), tie=(60, 58, 70),
        pants=(48, 50, 64), pants_d=(34, 36, 48),
        accessory="hat", hat=(66, 68, 80), scarf=(168, 84, 76), build=-1.0,
    ),
}


def main():
    idle, strip = make_player()
    save(idle, "player.png")
    save(strip, "player_walk.png")
    for nid, params in NPCS.items():
        P = dict(DEFAULT)
        P.update(params)
        save(build(P), "npc_%s.png" % nid)
        st = Image.new("RGBA", (CW * 4, CH), (0, 0, 0, 0))
        for i, (arm, legs, dy) in enumerate(WALK):
            st.alpha_composite(build(P, arm=arm, legs=legs, dy=dy), (i * CW, 0))
        save(st, "npcwalk_%s.png" % nid)
    print("角色 OK: player.png %dx%d / player_walk.png %dx%d / NPC %d 个"
          % (CW, CH, CW * 4, CH, len(NPCS)))


if __name__ == "__main__":
    main()
