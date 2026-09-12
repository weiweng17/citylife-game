"""
场景生成器 · 都市浮生 v3
================================================================
为什么重写：参考图那两张夜景的"氛围"不是靠配色调出来的，是靠**光照**。

流程（每一步都不能省）
  1. albedo   ：先把材质固有色画出来（地砖、沥青、墙面、玻璃、家具），不带光
  2. bake     ：按点光源列表逐像素算照度  L = ambient + Σ energy/(1+(d/r)^2.2)
  3. out      ：out = albedo × L × AO + glow + emission
                AO  = 墙根/树根/灯座旁的接触阴影（物体的"落地感"全靠它）
                glow= 泛光（模拟 bloom，Web 端 gl_compatibility 没有辉光后处理）
                emission = 亮着的窗户/招牌自身发光（不参与光照乘法）
  4. lightmap ：导出一张降采样的"实体补光图"，运行时给角色/NPC/交互点做 modulate
                → 站在灯下自动被烤暖、走进暗处自动沉下去，和背景同一套光源

前两版失败的原因就是只有第 1 步：平涂出来永远像"色块"。
本版实测：近黑像素占比拉到 ~60%，亮部 <1%，和参考图统计对得上。

坐标（世界 1080×1080，和 scripts/Game.gd / Data.gd 必须保持一致）
  主街（横向）y 700..800，人行道 672..700 / 800..828
  支路（纵向）x 636..736，人行道 608..636 / 736..764
  建筑  公寓 x150 w320 base360 | 医院 x790 w280 base240
        公司 x790 w280 base500 | 便利店 x260 w250 base940 | 老楼 x30 w170 base960
  旧巷口 夹在老楼与便利店之间 x200..260，进深到 y1010

用法： python tools/gen_scene.py
"""

import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from artlib import (  # noqa: E402
    ACCENT, ALLEY_FLOOR, AMBIENT, ASPHALT, ASPHALT_D, ASPHALT_L, CURB, CURB_D,
    GLASS_COOL, GLASS_DARK, GRASS, GRASS_D, GRASS_L, G0, G1, G2, G3, G4, G5,
    LEAF, LEAF_D, LEAF_DD, LEAF_L, Light, N0, N1, N2, N3, N4, N5, NEON,
    OUTLINE, PAINT, PAVER, PAVER_D, PAVER_L, SCN, SOIL, SPR, TRUNK, TRUNK_D,
    W0, W1, W2, W3, W4, W5, WALL_APART, WALL_APART_D, WALL_APART_L, WALL_HOSP,
    WALL_HOSP_D, WALL_HOSP_L, WALL_OFFICE, WALL_OFFICE_D, WALL_OFFICE_L,
    WALL_OLD, WALL_OLD_D, WALL_OLD_L, WALL_STORE, WALL_STORE_D, WALL_STORE_L,
    apply_light, bake_light, blur_mask, circle_mask, ellipse_mask, grid_lines,
    outline_alpha, paste_rgba, rect_mask, rgb, save, text_stamp, tile_noise,
    to_image, value_noise,
)

MAP = 1080
ROAD_H = (700, 800)          # 主街沥青
SW_N = (672, 700)            # 主街北侧人行道
SW_S = (800, 828)            # 主街南侧人行道
ROAD_V = (636, 736)          # 支路沥青
SW_W = (608, 636)
SW_E = (736, 764)

FOOT_D = 28                  # 建筑碰撞进深（薄薄一条，玩家能一直走到墙根）

BUILDINGS = [
    dict(id="home", kind="apartment", name="公寓", x=150, w=320, base=360, fh=230, door=310),
    dict(id="hospital", kind="hospital", name="医院", x=790, w=280, base=240, fh=215, door=930),
    dict(id="office", kind="office", name="公司", x=790, w=280, base=500, fh=250, door=935),
    dict(id="store", kind="store", name="便利店", x=260, w=250, base=940, fh=140, door=385),
    dict(id="old", kind="old", name="老楼", x=30, w=170, base=960, fh=150, door=115),
]

ALLEY = dict(x0=200, x1=260, y0=828, y1=1010)

PARK = dict(x0=40, x1=430, y0=420, y1=660)

TREES = [
    (80, 640), (170, 640), (350, 640), (450, 640), (560, 650),
    (790, 640), (900, 640), (1010, 640),
    (80, 858), (150, 858), (560, 858), (650, 858), (880, 858), (980, 858),
    (110, 470), (190, 450), (350, 480), (390, 620), (120, 620), (60, 560),
]

LAMPS = [
    (120, 672), (330, 672), (540, 672),
    (250, 828), (470, 828), (690, 828), (910, 828),
    (622, 300), (622, 520), (750, 200), (750, 420),
    (240, 505),
]

# 光源表：世界坐标 / 半径 / 强度 / 颜色。暖色只出现在这里，别的地方一律冷压。
# LIGHT_SCALE 把"灯光外溢"压到极小：参考图是"大面积极暗 + 极小暖光"，
# 之前 energy 不缩放、falloff 太软，导致整张图都被照成中灰 —— 完全不像。
LIGHT_SCALE = 0.33
LIGHTS = []
for lx, ly in LAMPS:
    LIGHTS.append(Light(lx, ly - 6, 132, 0.95 * LIGHT_SCALE, (1.00, 0.78, 0.52), glow=0.55))
LIGHTS += [
    Light(310, 348, 150, 1.05 * LIGHT_SCALE, (1.00, 0.80, 0.55), glow=0.60),   # 公寓门口
    Light(930, 228, 145, 1.00 * LIGHT_SCALE, (0.98, 0.84, 0.66), glow=0.55),   # 医院门口
    Light(935, 488, 150, 0.95 * LIGHT_SCALE, (0.92, 0.90, 0.92), glow=0.50),   # 公司大堂
    Light(385, 926, 155, 1.10 * LIGHT_SCALE, (1.00, 0.86, 0.58), glow=0.70),   # 便利店橱窗
    Light(115, 948, 110, 0.75 * LIGHT_SCALE, (1.00, 0.80, 0.55), glow=0.40),   # 老楼门灯
    Light(230, 890, 74, 0.80 * LIGHT_SCALE, (1.00, 0.74, 0.46), glow=0.60),    # 巷子里的灯泡
    Light(520, 664, 105, 0.70 * LIGHT_SCALE, (0.72, 0.86, 1.00), glow=0.45),   # 地铁口冷光
]


# ================================================================ 地面
def build_ground_albedo():
    h = w = MAP
    g = np.zeros((h, w, 3), np.float32)
    g[:] = rgb(PAVER)

    paver_n = tile_noise(w, h, 44, 7)
    g *= (0.88 + 0.26 * paver_n)[..., None]
    seams = grid_lines(w, h, 44, 2)
    g[seams] *= 0.72
    g = np.clip(g, 0, 1)

    # ---- 主街 / 支路：沥青 ----
    road = rect_mask(w, h, 0, ROAD_H[0], w, ROAD_H[1])
    road = np.maximum(road, rect_mask(w, h, ROAD_V[0], 0, ROAD_V[1], h))
    speck = value_noise(w, h, 3, 11, octaves=2)
    asph = rgb(ASPHALT)[None, None, :] * (0.78 + 0.5 * speck)[..., None]
    g = g * (1 - road[..., None]) + asph * road[..., None]
    # 车辙（两条纵向磨损带）
    for cxx in (ROAD_V[0] + 26, ROAD_V[1] - 26):
        wear = rect_mask(w, h, cxx - 12, 0, cxx + 12, h, soft=12) * 0.35
        g *= (1 - wear[..., None] * 0.3)
    for cyy in (ROAD_H[0] + 26, ROAD_H[1] - 26):
        wear = rect_mask(w, h, 0, cyy - 12, w, cyy + 12, soft=12) * 0.35
        g *= (1 - wear[..., None] * 0.3)

    # ---- 人行道 ----
    for band in (SW_N, SW_S):
        m = rect_mask(w, h, 0, band[0], w, band[1])
        tn = tile_noise(w, h, 22, 13)
        pv = rgb(PAVER_L)[None, None, :] * (0.86 + 0.3 * tn)[..., None]
        g = g * (1 - m[..., None]) + pv * m[..., None]
    for band in (SW_W, SW_E):
        m = rect_mask(w, h, band[0], 0, band[1], h)
        tn = tile_noise(w, h, 22, 17)
        pv = rgb(PAVER_L)[None, None, :] * (0.86 + 0.3 * tn)[..., None]
        g = g * (1 - m[..., None]) + pv * m[..., None]

    # ---- 路缘石（带一条高光棱，立体感的关键小细节）----
    curbs = [(0, ROAD_H[0] - 5, w, ROAD_H[0]), (0, ROAD_H[1], w, ROAD_H[1] + 5),
             (ROAD_V[0] - 5, 0, ROAD_V[0], h), (ROAD_V[1], 0, ROAD_V[1] + 5, h)]
    for x0, y0, x1, y1 in curbs:
        m = rect_mask(w, h, x0, y0, x1, y1)
        g = g * (1 - m[..., None]) + rgb(CURB)[None, None, :] * m[..., None]
    for x0, y0, x1, y1 in curbs:
        edge = rect_mask(w, h, x0, y0, x1, y0 + 2) + rect_mask(w, h, x0, y0, x0 + 2, y1)
        g = g * (1 - edge[..., None] * 0.7) + rgb(CURB_D)[None, None, :] * (edge[..., None] * 0.7)

    # ---- 路面标线 ----
    yc = (ROAD_H[0] + ROAD_H[1]) / 2
    dash = np.zeros((h, w), np.float32)
    for x in range(0, w, 74):
        dash[max(0, int(yc) - 2):int(yc) + 2, x:x + 40] = 1.0
    xc = (ROAD_V[0] + ROAD_V[1]) / 2
    for y in range(0, h, 74):
        dash[y:y + 40, max(0, int(xc) - 2):int(xc) + 2] = 1.0
    g = g * (1 - dash[..., None] * 0.8) + rgb(PAINT)[None, None, :] * (dash[..., None] * 0.8)
    # 斑马线（路口四角）
    cross = np.zeros((h, w), np.float32)
    for i in range(6):
        x = ROAD_V[0] - 6 - i * 13
        cross[ROAD_H[0] + 10:ROAD_H[1] - 10, x:x + 8] = 0.85
        x2 = ROAD_V[1] + 6 + i * 13
        cross[ROAD_H[0] + 10:ROAD_H[1] - 10, x2:x2 + 8] = 0.85
    for i in range(6):
        y = ROAD_H[0] - 6 - i * 13
        cross[y:y + 8, ROAD_V[0] + 10:ROAD_V[1] - 10] = 0.85
        y2 = ROAD_H[1] + 6 + i * 13
        cross[y2:y2 + 8, ROAD_V[0] + 10:ROAD_V[1] - 10] = 0.85
    cross *= (0.7 + 0.3 * value_noise(w, h, 8, 23, octaves=2))
    g = g * (1 - cross[..., None] * 0.75) + rgb(PAINT)[None, None, :] * (cross[..., None] * 0.75)

    # ---- 公园：草地 + 土路 + 水塘 ----
    pm = rect_mask(w, h, PARK["x0"], PARK["y0"], PARK["x1"], PARK["y1"], soft=6)
    gn = value_noise(w, h, 9, 31, octaves=4)
    grass = rgb(GRASS)[None, None, :] * (0.72 + 0.62 * gn)[..., None]
    g = g * (1 - pm[..., None]) + grass * pm[..., None]
    path = ellipse_mask(w, h, 235, 545, 150, 66, soft=0.35) * pm
    dirt = rgb(SOIL)[None, None, :] * (0.9 + 0.4 * value_noise(w, h, 7, 37, octaves=3))[..., None]
    g = g * (1 - path[..., None] * 0.9) + dirt * (path[..., None] * 0.9)
    pond = ellipse_mask(w, h, 130, 570, 62, 40, soft=0.25)
    g = g * (1 - pond[..., None] * 0.95) + rgb(N1)[None, None, :] * (pond[..., None] * 0.95)
    rim = ellipse_mask(w, h, 130, 570, 68, 45, soft=0.3) - ellipse_mask(w, h, 130, 570, 62, 40, soft=0.25)
    g = g * (1 - np.clip(rim, 0, 1)[..., None] * 0.8) + rgb(G2)[None, None, :] * (np.clip(rim, 0, 1)[..., None] * 0.8)

    # ---- 旧巷口：深色水泥 ----
    am = rect_mask(w, h, ALLEY["x0"], ALLEY["y0"], ALLEY["x1"], ALLEY["y1"])
    an = value_noise(w, h, 6, 41, octaves=3)
    g = g * (1 - am[..., None]) + rgb(ALLEY_FLOOR)[None, None, :] * (0.8 + 0.4 * an)[..., None] * am[..., None]

    # ---- 树坑 ----
    for tx, ty in TREES:
        if PARK["x0"] < tx < PARK["x1"] and PARK["y0"] < ty < PARK["y1"]:
            continue
        pit = rect_mask(w, h, tx - 17, ty + 12, tx + 17, ty + 34, soft=2)
        g = g * (1 - pit[..., None]) + rgb(SOIL)[None, None, :] * (0.8 + 0.4 * an)[..., None] * pit[..., None]
        grate = grid_lines(w, h, 6, 1)
        g = g * (1 - (pit * grate)[..., None] * 0.5)

    # ---- 井盖 / 雨水箅 / 裂缝 / 油污 ----
    img = to_image(g)
    d = ImageDraw.Draw(img)
    for (mx, my) in [(300, 610), (880, 760), (200, 480), (760, 380)]:
        d.ellipse([mx - 12, my - 12, mx + 12, my + 12], fill=(int(G1[0] * .8), int(G1[1] * .8), int(G1[2] * .8)))
        d.ellipse([mx - 10, my - 10, mx + 10, my + 10], outline=(int(G3[0] * .8), int(G3[1] * .8), int(G3[2] * .8)))
        d.line([mx - 9, my, mx + 9, my], fill=(int(G0[0] * .9), int(G0[1] * .9), int(G0[2] * .9)))
    for (gx, gy) in [(160, ROAD_H[0] - 3), (500, ROAD_H[0] - 3), (860, ROAD_H[0] - 3)]:
        d.rectangle([gx - 9, gy - 5, gx + 9, gy + 1], fill=(int(G0[0] * .7), int(G0[1] * .7), int(G0[2] * .7)))
        for i in range(4):
            d.line([gx - 8 + i * 5, gy - 4, gx - 8 + i * 5, gy], fill=(int(G1[0] * .6), int(G1[1] * .6), int(G1[2] * .6)))
    g = np.asarray(img, np.float32) / 255.0

    stain = value_noise(w, h, 26, 53, octaves=3)
    g *= (0.90 + 0.16 * (stain > 0.55))[..., None]

    return np.clip(g, 0, 1)


def ground_puddle_mask():
    w = h = MAP
    n = value_noise(w, h, 40, 71, octaves=3)
    m = (n > 0.635).astype(np.float32)
    m = blur_mask(m, 3)
    m = np.clip((m - 0.35) * 2.2, 0, 1)
    return m


# ================================================================ 建筑立面
def _steps_and_door(img, d, door_x, wall_d, accent_light=True):
    """底部 0..46px：台阶 + 玻璃门 + 暖光外溢 + 门牌"""
    W, H = img.size
    base = H - 1
    for i, (inset, col) in enumerate([(34, G2), (24, G3), (14, G4)]):
        y0 = base - (i + 1) * 7
        d.rectangle([door_x - inset - 12, y0, door_x + inset + 12, y0 + 7], fill=col)
        d.line([door_x - inset - 12, y0, door_x + inset + 12, y0], fill=(255, 250, 235))
        d.line([door_x - inset - 12, y0 + 7, door_x + inset + 12, y0 + 7], fill=(58, 58, 66))
    # 门洞
    dw, dh = 26, 30
    dx0, dy0 = door_x - dw, base - 7 * 3 - dh
    d.rectangle([dx0, dy0, dx0 + dw * 2, dy0 + dh], fill=(30, 26, 24))
    d.rectangle([dx0 + 1, dy0 + 1, dx0 + dw * 2 - 1, dy0 + dh - 1], fill=W1)
    d.rectangle([dx0 + 2, dy0 + 2, dx0 + dw * 2 - 2, dy0 + dh - 4], fill=W2)
    d.rectangle([dx0 + 3, dy0 + 3, dx0 + dw * 2 - 3, dy0 + dh - 12], fill=W3)
    d.line([door_x, dy0 + 1, door_x, dy0 + dh - 1], fill=(60, 48, 40))
    d.line([dx0 + 3, dy0 + dh - 10, dx0 + dw * 2 - 3, dy0 + dh - 10], fill=(88, 70, 56))
    # 门厅里的一点剪影（人影/柜台）
    d.rectangle([dx0 + 6, dy0 + 8, dx0 + 12, dy0 + dh - 6], fill=(96, 78, 60))
    d.rectangle([dx0 + dw * 2 - 14, dy0 + 12, dx0 + dw * 2 - 8, dy0 + dh - 6], fill=(104, 84, 64))


def _parapet(img, d, wall_l, wall_d, extra_top=0):
    W, H = img.size
    d.rectangle([0, 0, W - 1, 5], fill=wall_d)
    d.line([0, 0, W - 1, 0], fill=wall_l)
    d.line([0, 6, W - 1, 6], fill=(26, 26, 32))
    d.rectangle([0, 7, W - 1, 9], fill=(int(wall_d[0] * .82), int(wall_d[1] * .82), int(wall_d[2] * .82)))


def _window_grid(d, x0, y0, cols, rows, cw, ch, gapx, gapy, lit_set, lit_c, dark_c, frame_c):
    for r in range(rows):
        for c in range(cols):
            x = x0 + c * (cw + gapx)
            y = y0 + r * (ch + gapy)
            d.rectangle([x - 2, y - 2, x + cw + 1, y + ch + 1], fill=frame_c)
            on = (r, c) in lit_set
            if on:
                d.rectangle([x, y, x + cw - 1, y + ch - 1], fill=lit_c[1])
                d.rectangle([x, y, x + cw - 1, y + ch - 4], fill=lit_c[0])
                d.rectangle([x + 1, y + 1, x + cw - 2, y + 2], fill=lit_c[2])
                d.rectangle([x + 2, y + ch - 7, x + cw - 3, y + ch - 5], fill=lit_c[3])
            else:
                d.rectangle([x, y, x + cw - 1, y + ch - 1], fill=dark_c)
                d.rectangle([x, y, x + cw - 1, y + 2], fill=(int(dark_c[0] * 1.5), int(dark_c[1] * 1.6), int(dark_c[2] * 1.8)))
                d.line([x, y + ch // 2, x + cw - 1, y + ch // 2], fill=(int(dark_c[0] * .7), int(dark_c[1] * .7), int(dark_c[2] * .8)))
            d.rectangle([x - 3, y + ch, x + cw + 2, y + ch + 2], fill=(int(frame_c[0] * 1.1), int(frame_c[1] * 1.1), int(frame_c[2] * 1.1)))


def _noise_overlay(img, seed, strength=0.16, cell=18):
    W, H = img.size
    n = value_noise(W, H, cell, seed, octaves=3)
    a = np.asarray(img).astype(np.float32)
    k = (1.0 - strength + strength * 2 * n)[..., None]
    a[..., :3] = np.clip(a[..., :3] * k, 0, 255)
    return Image.fromarray(a.astype(np.uint8), "RGBA")


def _vgrad(d, x0, y0, x1, y1, c_top, c_bot):
    h = y1 - y0
    for i in range(h):
        t = i / max(1, h - 1)
        c = tuple(int(c_top[k] * (1 - t) + c_bot[k] * t) for k in range(3))
        d.line([x0, y0 + i, x1, y0 + i], fill=c)


def facade(spec):
    """返回 (albedo RGBA, emission RGBA)。底部一行 = 建筑墙根（世界 base 线）。"""
    kind = spec["kind"]
    W, H, door = spec["w"], spec["fh"], spec["door"] - spec["x"]
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    em = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    de = ImageDraw.Draw(em)
    rnd = np.random.default_rng(abs(hash(spec["id"])) % 9999)

    # ---------------------------------------------------- 公寓
    if kind == "apartment":
        wall, wl, wd = WALL_APART, WALL_APART_L, WALL_APART_D
        d.rectangle([0, 6, W - 1, H - 1], fill=wall)
        d.rectangle([0, 6, 3, H - 1], fill=wl)
        d.rectangle([W - 4, 6, W - 1, H - 1], fill=wd)
        # 楼层线
        floor_h = 34
        n = (H - 60) // floor_h
        for i in range(n + 1):
            y = H - 46 - i * floor_h
            if y < 12:
                break
            d.line([0, y, W - 1, y], fill=(int(wd[0] * .8), int(wd[1] * .8), int(wd[2] * .8)))
            d.line([0, y + 1, W - 1, y + 1], fill=(int(wl[0] * .92), int(wl[1] * .92), int(wl[2] * .92)))
        # 阳台 + 窗
        for i in range(n):
            y = H - 46 - i * floor_h
            if y - 24 < 12:
                break
            for b in range(4):
                bx = 14 + b * 74
                if bx + 58 > W - 10:
                    break
                on = rnd.random() < 0.34
                d.rectangle([bx, y - 24, bx + 58, y - 4], fill=(int(wall[0] * .8), int(wall[1] * .8), int(wall[2] * .8)))
                d.rectangle([bx + 4, y - 22, bx + 54, y - 6], fill=(28, 30, 42))
                if on:
                    d.rectangle([bx + 5, y - 21, bx + 53, y - 7], fill=W2)
                    d.rectangle([bx + 5, y - 21, bx + 53, y - 15], fill=W3)
                    de.rectangle([bx + 5, y - 21, bx + 53, y - 7], fill=(150, 108, 62))
                    de.rectangle([bx + 7, y - 19, bx + 51, y - 16], fill=(196, 150, 92))
                d.rectangle([bx + 4, y - 12, bx + 54, y - 11], fill=(int(G1[0] * .9), int(G1[1] * .9), int(G1[2] * .9)))
                d.rectangle([bx + 2, y - 12, bx + 56, y - 11], fill=(int(G2[0] * .85), int(G2[1] * .85), int(G2[2] * .85)))
                d.line([bx + 2, y - 4, bx + 56, y - 4], fill=(int(G3[0] * .8), int(G3[1] * .8), int(G3[2] * .8)))
                if rnd.random() < 0.3:      # 空调外机
                    d.rectangle([bx + 44, y - 34, bx + 62, y - 25], fill=(int(G1[0] * .85), int(G1[1] * .85), int(G1[2] * .85)))
                    d.line([bx + 44, y - 30, bx + 62, y - 30], fill=(int(G0[0] * .8), int(G0[1] * .8), int(G0[2] * .8)))
        _parapet(img, d, wl, wd)
        # 屋顶：水箱 + 天线（做剪影，把"3D 建筑"的信息量补上）
        d.rectangle([42, -24, 92, 6], fill=(int(wd[0] * .9), int(wd[1] * .9), int(wd[2] * .9)))
        d.rectangle([42, -24, 92, -20], fill=(int(wl[0] * .85), int(wl[1] * .85), int(wl[2] * .85)))
        for i in range(4):
            d.line([46 + i * 12, -24, 46 + i * 12, 6], fill=(int(wd[0] * .7), int(wd[1] * .7), int(wd[2] * .7)))
        d.line([W - 40, -30, W - 40, 6], fill=(int(G0[0] * .9), int(G0[1] * .9), int(G0[2] * .9)))
        d.line([W - 52, -30, W - 28, -30], fill=(int(G1[0] * .8), int(G1[1] * .8), int(G1[2] * .8)))
        _steps_and_door(img, d, door, wd)
        # 门头灯
        d.rectangle([door - 30, H - 74, door + 30, H - 70], fill=(int(wd[0] * .9), int(wd[1] * .9), int(wd[2] * .9)))
        d.rectangle([door - 26, H - 70, door + 26, H - 66], fill=(int(wd[0] * .8), int(wd[1] * .8), int(wd[2] * .8)))
        d.rectangle([door - 20, H - 69, door + 20, H - 68], fill=W4)
        de.rectangle([door - 20, H - 69, door + 20, H - 68], fill=(220, 180, 120))
        # 门牌
        st = text_stamp("公寓", 13, (238, 232, 216), (24, 22, 28))
        paste_rgba(img, st, door - st.size[0] // 2, H - 92)
        # 门口绿植
        for px_ in (door - 78, door + 60):
            d.rectangle([px_, H - 22, px_ + 16, H - 8], fill=(58, 50, 44))
            d.ellipse([px_ - 4, H - 44, px_ + 20, H - 18], fill=LEAF_D)
            d.ellipse([px_ + 1, H - 41, px_ + 15, H - 24], fill=LEAF)
            d.ellipse([px_ + 3, H - 40, px_ + 11, H - 30], fill=LEAF_L)

    # ---------------------------------------------------- 便利店
    elif kind == "store":
        wall, wl, wd = WALL_STORE, WALL_STORE_L, WALL_STORE_D
        d.rectangle([0, 6, W - 1, H - 1], fill=wall)
        d.rectangle([0, 6, 3, H - 1], fill=wl)
        d.rectangle([W - 4, 6, W - 1, H - 1], fill=wd)
        # 大玻璃橱窗（暖光外溢，画面里最亮的一块）
        gx0, gx1 = 10, W - 10
        gy0, gy1 = H - 96, H - 44
        d.rectangle([gx0 - 3, gy0 - 3, gx1 + 3, gy1 + 3], fill=(int(wd[0] * .85), int(wd[1] * .85), int(wd[2] * .85)))
        _vgrad(d, gx0, gy0, gx1, gy1, W5, W3)
        de.rectangle([gx0, gy0, gx1, gy1], fill=(210, 165, 105))
        de.rectangle([gx0, gy0, gx1, gy0 + 14], fill=(246, 214, 160))
        # 货架剪影
        for i in range(9):
            x = gx0 + 8 + i * 24
            hgt = 10 + (i * 7) % 14
            d.rectangle([x, gy1 - hgt, x + 4, gy1], fill=(126, 96, 66))
            d.rectangle([x, gy1 - hgt, x + 4, gy1 - hgt + 2], fill=(160, 126, 88))
        d.line([gx0, gy0 + 26, gx1, gy0 + 26], fill=(120, 92, 66))
        # 竖框
        for i in range(1, 4):
            mx = gx0 + i * (gx1 - gx0) // 4
            d.line([mx, gy0, mx, gy1], fill=(58, 52, 48))
        # 门
        dw = 26
        dx0 = door - dw
        d.rectangle([dx0, gy1, dx0 + dw * 2, H - 8], fill=(48, 44, 42))
        _vgrad(d, dx0 + 2, gy1 + 2, dx0 + dw * 2 - 2, H - 12, W4, W2)
        de.rectangle([dx0 + 2, gy1 + 2, dx0 + dw * 2 - 2, H - 12], fill=(198, 152, 96))
        d.line([door, gy1, door, H - 10], fill=(96, 76, 58))
        # 招牌
        d.rectangle([0, 6, W - 1, 40], fill=(38, 34, 34))
        d.rectangle([0, 8, W - 1, 36], fill=(52, 44, 42))
        st = text_stamp("便利店", 15, (255, 246, 226), (18, 16, 18))
        paste_rgba(img, st, (W - st.size[0]) // 2, 14)
        de.rectangle([6, 40, W - 7, 42], fill=(90, 70, 40))
        # 红霓虹条
        d.rectangle([6, 44, W - 7, 48], fill=ACCENT)
        de.rectangle([6, 44, W - 7, 48], fill=(150, 52, 40))
        # 雨棚
        d.rectangle([0, 50, W - 1, 56], fill=(70, 60, 56))
        d.line([0, 56, W - 1, 56], fill=(96, 84, 78))
        for i in range(0, W, 18):
            d.line([i, 50, i, 56], fill=(54, 46, 44))
        # 自动贩卖机
        vx = W - 42
        d.rectangle([vx, H - 44, vx + 34, H - 6], fill=(44, 48, 54))
        d.rectangle([vx + 3, H - 41, vx + 31, H - 24], fill=NEON)
        de.rectangle([vx + 3, H - 41, vx + 31, H - 24], fill=(46, 96, 90))
        d.rectangle([vx + 3, H - 22, vx + 20, H - 18], fill=(96, 100, 106))

    # ---------------------------------------------------- 写字楼
    elif kind == "office":
        wall, wl, wd = WALL_OFFICE, WALL_OFFICE_L, WALL_OFFICE_D
        d.rectangle([0, 6, W - 1, H - 1], fill=wall)
        d.rectangle([0, 6, 3, H - 1], fill=wl)
        d.rectangle([W - 4, 6, W - 1, H - 1], fill=wd)
        # 玻璃幕墙网格（加班的人：零星几格亮着）
        cw, ch, gx, gy = 22, 20, 8, 6
        cols = (W - 16) // (cw + gx)
        rows = (H - 60) // (ch + gy)
        lit = set()
        for r in range(rows):
            for c in range(cols):
                if rnd.random() < 0.13:
                    lit.add((r, c))
        _window_grid(d, 8, 16, cols, rows, cw, ch, gx, gy, lit,
                     ((92, 108, 138), (128, 148, 178), (150, 172, 202), (108, 126, 156)),
                     (28, 34, 50), (int(wall[0] * .82), int(wall[1] * .82), int(wall[2] * .82)))
        for (r, c) in sorted(lit):
            x = 8 + c * (cw + gx)
            y = 16 + r * (ch + gy)
            de.rectangle([x, y, x + cw - 1, y + ch - 1], fill=(60, 66, 82))
            de.rectangle([x + 2, y + 2, x + cw - 3, y + ch - 5], fill=(96, 100, 116))
        _parapet(img, d, wl, wd)
        # 大堂
        d.rectangle([0, H - 52, W - 1, H - 1], fill=(int(wall[0] * 1.15), int(wall[1] * 1.15), int(wall[2] * 1.1)))
        _vgrad(d, 4, H - 50, W - 5, H - 12, (46, 52, 66), (28, 32, 44))
        de.rectangle([6, H - 48, W - 7, H - 14], fill=(48, 52, 64))
        for i in range(1, 5):
            x = 4 + i * (W - 8) // 5
            d.line([x, H - 50, x, H - 12], fill=(84, 92, 110))
        d.rectangle([door - 34, H - 40, door + 34, H - 8], fill=(58, 64, 80))
        de.rectangle([door - 32, H - 38, door + 32, H - 12], fill=(104, 106, 118))
        d.rectangle([door - 24, H - 34, door + 24, H - 14], fill=W2)
        de.rectangle([door - 24, H - 34, door + 24, H - 14], fill=(150, 134, 110))
        st = text_stamp("公司", 14, (232, 226, 214), (18, 20, 26))
        paste_rgba(img, st, (W - st.size[0]) // 2, H - 68)

    # ---------------------------------------------------- 医院
    elif kind == "hospital":
        wall, wl, wd = WALL_HOSP, WALL_HOSP_L, WALL_HOSP_D
        d.rectangle([0, 6, W - 1, H - 1], fill=wall)
        d.rectangle([0, 6, 3, H - 1], fill=wl)
        d.rectangle([W - 4, 6, W - 1, H - 1], fill=wd)
        cw, ch, gx, gy = 18, 16, 10, 8
        cols = (W - 20) // (cw + gx)
        rows = (H - 70) // (ch + gy)
        lit = set()
        for r in range(rows):
            for c in range(cols):
                if rnd.random() < 0.42:
                    lit.add((r, c))
        _window_grid(d, 12, 18, cols, rows, cw, ch, gx, gy, lit,
                     ((118, 132, 148), (166, 186, 202), (196, 214, 226), (140, 158, 176)),
                     (30, 38, 52), (int(wall[0] * .86), int(wall[1] * .86), int(wall[2] * .86)))
        for (r, c) in sorted(lit):
            x = 12 + c * (cw + gx)
            y = 18 + r * (ch + gy)
            de.rectangle([x, y, x + cw - 1, y + ch - 1], fill=(74, 80, 92))
        _parapet(img, d, wl, wd)
        # 红十字
        cx_, cy_ = W // 2, 34
        d.rectangle([cx_ - 14, cy_ - 14, cx_ + 14, cy_ + 14], fill=(196, 196, 196))
        d.rectangle([cx_ - 4, cy_ - 11, cx_ + 4, cy_ + 11], fill=(168, 48, 44))
        d.rectangle([cx_ - 11, cy_ - 4, cx_ + 11, cy_ + 4], fill=(168, 48, 44))
        de.rectangle([cx_ - 4, cy_ - 11, cx_ + 4, cy_ + 11], fill=(96, 26, 24))
        de.rectangle([cx_ - 11, cy_ - 4, cx_ + 11, cy_ + 4], fill=(96, 26, 24))
        _steps_and_door(img, d, door, wd)
        d.rectangle([door - 46, H - 76, door + 46, H - 72], fill=(int(wd[0] * .9), int(wd[1] * .9), int(wd[2] * .9)))
        de.rectangle([door - 40, H - 71, door + 40, H - 70], fill=(90, 92, 98))
        st = text_stamp("医院", 14, (238, 240, 240), (22, 24, 28))
        paste_rgba(img, st, door - st.size[0] // 2, H - 94)

    # ---------------------------------------------------- 老楼
    else:
        wall, wl, wd = WALL_OLD, WALL_OLD_L, WALL_OLD_D
        d.rectangle([0, 6, W - 1, H - 1], fill=wall)
        d.rectangle([0, 6, 3, H - 1], fill=wl)
        d.rectangle([W - 4, 6, W - 1, H - 1], fill=wd)
        cw, ch, gx, gy = 16, 15, 12, 10
        cols = (W - 20) // (cw + gx)
        rows = (H - 60) // (ch + gy)
        for r in range(rows):
            for c in range(cols):
                x = 12 + c * (cw + gx)
                y = 16 + r * (ch + gy)
                d.rectangle([x - 2, y - 2, x + cw + 1, y + ch + 1], fill=(int(wall[0] * .8), int(wall[1] * .8), int(wall[2] * .8)))
                broken = rnd.random() < 0.22
                on = (not broken) and rnd.random() < 0.22
                if on:
                    d.rectangle([x, y, x + cw - 1, y + ch - 1], fill=W1)
                    d.rectangle([x, y, x + cw - 1, y + ch - 5], fill=W2)
                    de.rectangle([x, y, x + cw - 1, y + ch - 1], fill=(84, 62, 40))
                else:
                    d.rectangle([x, y, x + cw - 1, y + ch - 1], fill=(24, 26, 34))
                    d.rectangle([x, y, x + cw - 1, y + 2], fill=(40, 46, 60))
                    if broken:
                        d.rectangle([x + 3, y + 4, x + 8, y + 10], fill=(46, 44, 46))
                        d.line([x, y + ch - 2, x + cw - 1, y + 3], fill=(52, 52, 56))
                d.rectangle([x - 3, y + ch, x + cw + 2, y + ch + 2], fill=(int(wd[0] * 1.1), int(wd[1] * 1.1), int(wd[2] * 1.1)))
        _parapet(img, d, wl, wd)
        # 屋顶水箱 + 消防梯
        d.rectangle([16, -20, 54, 6], fill=(int(wd[0] * .95), int(wd[1] * .95), int(wd[2] * .95)))
        d.rectangle([16, -20, 54, -16], fill=(int(wl[0] * .85), int(wl[1] * .85), int(wl[2] * .85)))
        for i in range(3):
            d.line([20 + i * 12, -20, 20 + i * 12, 6], fill=(int(wd[0] * .75), int(wd[1] * .75), int(wd[2] * .75)))
        d.line([W - 22, -34, W - 22, 6], fill=(int(G0[0] * .95), int(G0[1] * .95), int(G0[2] * .95)))
        for i in range(5):
            d.line([W - 26, -34 + i * 8, W - 16, -34 + i * 8], fill=(int(G0[0] * .9), int(G0[1] * .9), int(G0[2] * .9)))
        # 涂鸦
        d.line([30, H - 120, 46, H - 128], fill=(96, 72, 96))
        d.line([46, H - 128, 60, H - 118], fill=(96, 72, 96))
        d.line([30, H - 120, 60, H - 118], fill=(96, 72, 96))
        _steps_and_door(img, d, door, wd)
        d.rectangle([door - 22, H - 70, door - 8, H - 62], fill=(38, 34, 32))
        d.rectangle([door - 20, H - 69, door - 10, H - 63], fill=W3)
        de.rectangle([door - 20, H - 69, door - 10, H - 63], fill=(170, 120, 66))
        st = text_stamp("老楼", 12, (206, 200, 188), (22, 22, 26))
        paste_rgba(img, st, door - st.size[0] // 2, H - 90)
        # 门口杂物
        d.rectangle([W - 60, H - 30, W - 30, H - 8], fill=(48, 44, 42))
        d.rectangle([W - 58, H - 28, W - 32, H - 14], fill=(60, 54, 50))

    img = _noise_overlay(img, abs(hash(spec["id"] + "n")) % 9999, 0.10, 14)
    return img, em


def bake_building(spec, albedo, emission):
    """按全局光源烘这块立面。立面法线朝观察者，所以整体比地面暗一档。"""
    W, H = albedo.size
    x0, y0 = spec["x"], spec["base"] - H
    L, glow = bake_light(W, H, LIGHTS, x0=x0, y0=y0)
    a = np.asarray(albedo, np.float32)[..., :3] / 255.0
    e = np.asarray(emission, np.float32)[..., :3] / 255.0
    alpha = np.asarray(albedo, np.float32)[..., 3:4] / 255.0
    # 立面朝向：竖向渐变（上冷下暖） + 统一压暗
    vg = np.linspace(0.62, 1.0, H)[:, None, None]
    L *= 0.80 * vg
    out = a * L + e * 0.85 + glow * 0.55
    out = np.clip(out, 0, 1)
    rgba = np.concatenate([out * 255.0, alpha * 255.0], axis=2).astype(np.uint8)
    return Image.fromarray(rgba, "RGBA")


# ================================================================ 树 / 灯 / 交互点
def gen_tree():
    W, H = 56, 92
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rng = np.random.default_rng(3)
    # 树干
    d.rectangle([24, 56, 31, 90], fill=TRUNK)
    d.rectangle([24, 56, 25, 90], fill=(90, 78, 68))
    d.rectangle([30, 56, 31, 90], fill=TRUNK_D)
    d.line([22, 74, 24, 66], fill=TRUNK)
    d.line([33, 74, 31, 66], fill=TRUNK_D)
    # 树冠：一簇簇的圆，压暗处理
    blobs = [(28, 34, 20, 17), (13, 42, 12, 11), (43, 42, 12, 11), (20, 22, 12, 10),
             (38, 22, 12, 10), (28, 12, 12, 9), (10, 30, 9, 8), (46, 30, 9, 8)]
    for (cx, cy, rx, ry) in blobs:
        d.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=LEAF_D)
    for (cx, cy, rx, ry) in blobs:
        d.ellipse([cx - rx + 2, cy - ry + 2, cx + rx - 3, cy + ry - 4], fill=LEAF)
    for (cx, cy, rx, ry) in blobs[:4]:
        d.ellipse([cx - rx + 4, cy - ry + 2, cx + rx - 6, cy - ry + 5], fill=LEAF_L)
    a = np.asarray(img).copy()
    # 左上受光、右下压暗
    xg = np.linspace(0.78, 1.16, W)[None, :, None]
    yg = np.linspace(1.12, 0.82, H)[:, None, None]
    rgb_a = a[..., :3].astype(np.float32) * xg * yg
    a[..., :3] = np.clip(rgb_a, 0, 255).astype(np.uint8)
    return Image.fromarray(a, "RGBA")


def gen_lamp():
    W, H = 22, 128
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([10, 30, 12, 126], fill=(42, 44, 52))
    d.rectangle([10, 30, 10, 126], fill=(62, 64, 72))
    d.rectangle([6, 122, 17, 127], fill=(48, 50, 58))
    d.rectangle([6, 122, 17, 123], fill=(70, 72, 80))
    # 灯头
    d.rectangle([4, 18, 18, 30], fill=(38, 40, 48))
    d.rectangle([5, 19, 17, 22], fill=(58, 60, 70))
    d.ellipse([5, 24, 17, 32], fill=(250, 226, 176))
    d.ellipse([7, 26, 15, 31], fill=(255, 246, 220))
    return outline_alpha(img)


def gen_poi():
    W = 30
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    a = np.zeros((W, W, 4), np.float32)
    yy, xx = np.mgrid[0:W, 0:W]
    c = (W - 1) / 2.0
    r = np.sqrt((xx - c) ** 2 + (yy - c) ** 2)
    # 细环 + 中心点，干净（上一版用抖色铺环，放大是噪点星芒）
    ring = np.exp(-((r - 11.0) ** 2) / 4.0) * 0.85
    ring2 = np.exp(-((r - 7.5) ** 2) / 2.0) * 0.35
    core = np.exp(-(r ** 2) / 6.0) * 0.95
    d = np.clip(ring + ring2 + core, 0, 1)
    a[..., 0] = 236
    a[..., 1] = 244
    a[..., 2] = 255
    a[..., 3] = d * 255
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "RGBA")


def gen_rain(w=160, h=256):
    """可无缝平铺的雨丝。运行时用 scrolling offset 让它动起来。"""
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rng = np.random.default_rng(9)
    for _ in range(260):
        x = rng.integers(0, w)
        y = rng.integers(0, h)
        ln = int(rng.integers(7, 20))
        alpha = int(rng.integers(38, 116))
        for i in range(ln):
            xx = int((x + i * 0.22) % w)
            yy = int((y + i) % h)
            d.point((xx, yy), fill=(196, 214, 240, alpha))
    return img


def gen_vignette(w=360, h=640, strength=0.72):
    yy, xx = np.mgrid[0:h, 0:w]
    cx, cy = w / 2.0, h * 0.46
    r = np.sqrt(((xx - cx) / (w * 0.62)) ** 2 + ((yy - cy) / (h * 0.60)) ** 2)
    v = np.clip((r - 0.52) / 0.78, 0, 1) ** 1.5 * strength
    a = np.zeros((h, w, 4), np.uint8)
    a[..., 3] = (v * 255).astype(np.uint8)
    return Image.fromarray(a, "RGBA")


# ================================================================ 主流程
def main():
    import time
    t0 = time.time()
    w = h = MAP

    # ---- 1. 地面 ----
    alb = build_ground_albedo()
    puddle = ground_puddle_mask()
    # AO：建筑根部 + 树根 + 灯座
    ao = np.ones((h, w), np.float32)
    for b in BUILDINGS:
        m = rect_mask(w, h, b["x"] - 8, b["base"] - FOOT_D, b["x"] + b["w"] + 8, b["base"] + 26, soft=16)
        ao *= (1.0 - m * 0.55)
    for tx, ty in TREES:
        m = ellipse_mask(w, h, tx, ty + 24, 26, 14, soft=0.7)
        ao *= (1.0 - m * 0.45)
    for lx, ly in LAMPS:
        m = ellipse_mask(w, h, lx, ly, 10, 6, soft=0.8)
        ao *= (1.0 - m * 0.5)
    # 巷子整体压暗
    ao *= (1.0 - rect_mask(w, h, ALLEY["x0"] - 6, ALLEY["y0"], ALLEY["x1"] + 6, ALLEY["y1"], soft=14) * 0.34)

    L, glow = bake_light(w, h, LIGHTS)
    out = apply_light(alb, L, glow * (1.0 + 1.5 * puddle[..., None]), ao=ao)
    # 湿地面：暗但反光强
    out = out * (1 - puddle[..., None] * 0.34) + glow * puddle[..., None] * 0.9
    ground = to_image(np.clip(out, 0, 1))
    ground.save(os.path.join(SCN, "ground.png"))

    # ---- 2. lightmap（实体补光，4px 一格）----
    step = 4
    lw, lh = w // step, h // step
    _, _ = bake_light(1, 1, [])
    yy, xx = np.mgrid[0:lh, 0:lw].astype(np.float32) * step
    Lm = np.zeros((lh, lw, 3), np.float32)
    Lm[..., 0], Lm[..., 1], Lm[..., 2] = AMBIENT
    for lt in LIGHTS:
        d2 = (xx - lt.x) ** 2 + (yy - lt.y) ** 2
        att = lt.energy / (1.0 + (d2 / (lt.r * lt.r)) ** lt.falloff)
        Lm += lt.color[None, None, :] * att[..., None]
    Lm *= 0.55
    mod = np.clip(Lm * 1.55 + np.array([0.30, 0.32, 0.38], np.float32)[None, None, :], 0.30, 1.30)
    np.save(os.path.join(SCN, "_lightmap.npy"), mod)
    to_image(np.clip(mod / 1.30, 0, 1)).save(os.path.join(SCN, "lightmap.png"))

    # ---- 3. 建筑 ----
    built = []
    for spec in BUILDINGS:
        a, e = facade(spec)
        img = bake_building(spec, a, e)
        img.save(os.path.join(SPR, "building_%s.png" % spec["id"]))
        built.append((spec, img))

    # ---- 4. 树 / 灯 / 交互点 / 雨 / 暗角 ----
    tree = gen_tree()
    tree.save(os.path.join(SPR, "tree.png"))
    gen_lamp().save(os.path.join(SPR, "lamp.png"))
    gen_poi().save(os.path.join(SPR, "poi.png"))
    gen_rain().save(os.path.join(SPR, "rain.png"))
    gen_vignette().save(os.path.join(SPR, "vignette.png"))

    # ---- 5. 预览：整图 + 两个 360x640 视野裁切 ----
    full = ground.copy().convert("RGBA")
    for spec, img in sorted(built, key=lambda t: t[0]["base"]):
        full.alpha_composite(img, (spec["x"], spec["base"] - img.size[1]))
    for tx, ty in sorted(TREES, key=lambda p: p[1]):
        full.alpha_composite(tree, (tx - tree.size[0] // 2, ty - tree.size[1] + 30))
    full.convert("RGB").resize((540, 540), Image.LANCZOS).save(
        os.path.join(os.path.dirname(SPR), "preview_scene.png"))

    pl = Image.open(os.path.join(SPR, "player.png")).convert("RGBA")
    for name, (vx, vy) in {"preview_view.png": (310, 460), "preview_view2.png": (300, 900)}.items():
        view = full.copy()
        view.alpha_composite(pl, (vx - 16, vy - 46))
        box = (max(0, vx - 180), max(0, vy - 360), max(0, vx - 180) + 360, max(0, vy - 360) + 640)
        crop = view.crop(box).convert("RGB")
        crop.save(os.path.join(os.path.dirname(SPR), name))

    # 统计：确认"极暗为主"这个氛围指标
    arr = np.asarray(ground, np.float32)
    dark = float((arr.max(axis=2) < 40).mean() * 100)
    bright = float((arr.min(axis=2) > 170).mean() * 100)
    print("场景 OK  近黑 %.1f%%  亮部 %.2f%%  (参考图: 61~63%% / 0.10%%)" % (dark, bright))
    print("建筑 %d 个 / 树 %d / 灯 %d / 光源 %d   用时 %.1fs"
          % (len(BUILDINGS), len(TREES), len(LAMPS), len(LIGHTS), time.time() - t0))


if __name__ == "__main__":
    main()
