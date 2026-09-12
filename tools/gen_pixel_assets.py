"""
像素素材生成器 · 氛围像素风 v2
================================================================
配色直接取自参考图（一张冷调夜晚像素画）的真实像素统计，不是"我觉得"：

  冷调蓝阶   #1e2334 → #7997b3   （低饱和、低对比，主导画面，占比最大）
  中性月光   #464252 → #d5d6cc
  暖光琥珀   #765438 → #ecd0ac   （低饱和！参考图的暖色其实很"灰"，只做稀疏点缀）

设计原则
  1. 低饱和 + 低对比：整体统一在冷蓝调里，暖色只出现在光源处
  2. 每个材质 ≥4 阶调（高光/亮/基/暗/深暗）+ 抖色(dither)过渡，去掉"纯色块"感
  3. 描边用深藏蓝 #161824（不用纯黑），更像夜色
  4. 画布尺寸与 v1 完全一致：
       玩家 24x32 / tile 32x32 / 建筑 64x64 / 树 32x40 / POI 24x24
     → 只升级观感，不动碰撞体与布局，零回归风险

额外产出
  light_warm.png   暖色径向渐变，给 PointLight2D 做"窗口暖光池"
  vignette.png     暗角，压住四角、聚焦中心（参考图很重要的氛围手段）
  preview_sprites.png / preview_scene.png   自检预览图

用法： python tools/gen_pixel_assets.py
"""

import math
import os

from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "sprites")
os.makedirs(OUT, exist_ok=True)

# ================================================================ 调色板
# ---- 冷调蓝阶（夜色 / 阴影 / 冷墙面）----
N0 = (26, 31, 46)
N1 = (36, 52, 74)
N2 = (46, 68, 93)
N3 = (54, 79, 105)
N4 = (62, 89, 116)
N5 = (75, 104, 134)
N6 = (99, 118, 139)
N7 = (121, 151, 179)

# ---- 中性（水泥 / 月光 / 路面）----
G0 = (70, 66, 82)
G1 = (100, 103, 117)
G2 = (155, 154, 161)
G3 = (186, 186, 180)
G4 = (213, 214, 204)

# ---- 暖光琥珀（低饱和，参考图实测 #cca789 区间）----
W0 = (118, 84, 56)
W1 = (168, 128, 90)
W2 = (204, 167, 137)
W3 = (236, 208, 172)

ACCENT = (168, 72, 60)      # 招牌 / 海报红
OUTLINE = (22, 24, 36)      # 深藏蓝描边

# ---- 地面：黄昏草地（压暗，让建筑暖光跳出来）----
GRASS = (68, 92, 88)
GRASS_L = (90, 116, 108)
GRASS_D = (50, 72, 72)

# ---- 路面：冷调水泥 ----
ROAD = (92, 100, 116)
ROAD_L = (114, 122, 138)
ROAD_D = (72, 80, 96)
LINE = (208, 208, 198)

# ---- 角色 ----
SKIN = (214, 178, 150)
SKIN_L = (238, 208, 178)
SKIN_D = (172, 136, 114)
EYE = (46, 40, 46)
HAIR = (30, 30, 40)
HAIR_L = (62, 60, 74)
HAIR_HL = (104, 100, 116)
COAT = (70, 84, 110)        # 藏青偏灰：既像参考图的西装，又能被 modulate 染色
COAT_L = (98, 114, 146)
COAT_D = (50, 60, 82)
COAT_DD = (36, 44, 62)
SHIRT_IN = (150, 156, 168)
PANTS = (54, 62, 84)
PANTS_D = (40, 46, 64)
SHOE = (28, 28, 38)

# ---- 树 ----
TRUNK = (78, 66, 58)
TRUNK_D = (58, 48, 44)
LEAF = (66, 92, 88)         # 黄昏冷绿
LEAF_L = (88, 118, 108)
LEAF_D = (50, 72, 72)
LEAF_DD = (38, 58, 60)

# ---- 建筑用色（三种立面）----
HOME_WALL = (96, 106, 124)
HOME_WALL_L = (118, 128, 146)
HOME_WALL_D = (74, 84, 102)
HOME_EAVE = (86, 74, 78)
HOME_EAVE_L = (112, 96, 96)

STORE_WALL = (78, 92, 114)
STORE_WALL_L = (100, 116, 138)
STORE_WALL_D = (58, 72, 92)

OFFICE_WALL = (72, 82, 104)
OFFICE_WALL_L = (94, 104, 126)
OFFICE_WALL_D = (54, 64, 84)
OFFICE_EAVE = (48, 56, 74)
OFFICE_EAVE_L = (74, 84, 104)

WIN_DARK = (34, 46, 66)
WIN_GLASS = (96, 118, 142)
WIN_LIT = W2
WIN_LIT_HL = W3
WIN_LIT_D = W1
WIN_COOL = (150, 168, 190)


# ================================================================ 基础工具
def new(w, h):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


def px(d, x, y, c):
    if c is None:
        return
    d.point((x, y), fill=c)


def rect(d, x, y, w, h, c):
    if c is None or w <= 0 or h <= 0:
        return
    d.rectangle([x, y, x + w - 1, y + h - 1], fill=c)


def ellipse_px(d, cx, cy, rx, ry, c):
    """像素风椭圆：逐行铺小矩形，保持硬边像素感"""
    if c is None:
        return
    for y in range(-ry, ry + 1):
        t = y / ry if ry else 0.0
        half = int(rx * max(0.0, 1.0 - t * t) ** 0.5)
        rect(d, cx - half, cy + y, half * 2 + 1, 1, c)


# 4x4 Bayer 有序抖动矩阵：用"按比例打点"实现像素风渐变
_BAYER = (
    (0, 8, 2, 10),
    (12, 4, 14, 6),
    (3, 11, 1, 9),
    (15, 7, 13, 5),
)


def dither(d, x, y, w, h, c, ratio, phase=0):
    """在矩形内按 ratio(0~1) 的比例抖动铺色，得到细腻的两色过渡"""
    if c is None or ratio <= 0:
        return
    thr = ratio * 16.0
    for yy in range(h):
        row = _BAYER[(yy + phase) % 4]
        for xx in range(w):
            if row[(xx + phase) % 4] < thr:
                px(d, x + xx, y + yy, c)


def vgrad(d, x, y, w, h, c_top, c_bot):
    """垂直方向两色渐变（上半 c_top 实心 + 向下逐渐抖出 c_bot）"""
    rect(d, x, y, w, h, c_top)
    for i in range(h):
        r = i / max(1, h - 1)
        dither(d, x, y + i, w, 1, c_bot, r ** 1.35)


def outline_inner(img, color=OUTLINE, min_alpha=200):
    """给不透明区域做 1px 内描边：外圈实心像素染成描边色。
    不用纯黑，也不改变画布尺寸。半透明的影子不参与描边。"""
    w, h = img.size
    pm = img.load()
    solid = [[pm[x, y][3] >= min_alpha for x in range(w)] for y in range(h)]
    for y in range(h):
        for x in range(w):
            if not solid[y][x]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if nx < 0 or ny < 0 or nx >= w or ny >= h or not solid[ny][nx]:
                    pm[x, y] = color
                    break
    return img


# ================================================================ 玩家 24x32
def gen_player():
    """正面小人，约 3.5 头身。光源约定：左上打光、右下为暗部。
    比例刻意收窄：头宽 10 < 肩宽 12，两腿之间留缝，避免"方块人"。"""
    img, d = new(24, 32)

    # ---- 影子（贴地）----
    ellipse_px(d, 12, 30, 7, 2, (0, 0, 0, 55))
    ellipse_px(d, 12, 30, 4, 1, (0, 0, 0, 70))

    # ---- 腿（中间留 2px 缝，视觉上分开两条腿）----
    rect(d, 8, 22, 3, 6, PANTS)
    rect(d, 13, 22, 3, 6, PANTS)
    rect(d, 8, 22, 1, 6, (70, 80, 104))     # 左腿受光边
    rect(d, 15, 22, 1, 6, PANTS_D)          # 右腿暗边
    rect(d, 11, 22, 2, 5, PANTS_D)          # 裆部暗区
    # 鞋
    rect(d, 7, 27, 4, 3, SHOE)
    rect(d, 13, 27, 4, 3, SHOE)
    rect(d, 7, 27, 4, 1, (54, 56, 72))
    rect(d, 13, 27, 4, 1, (54, 56, 72))

    # ---- 躯干（肩 12 → 腰 10，做出收腰）----
    rect(d, 6, 12, 12, 8, COAT)             # 胸腹
    rect(d, 7, 20, 10, 3, COAT)             # 收腰
    rect(d, 6, 12, 12, 2, COAT_L)           # 肩线受光
    rect(d, 6, 12, 2, 11, COAT_L)           # 左侧受光
    rect(d, 16, 12, 2, 11, COAT_D)          # 右侧暗部
    rect(d, 7, 21, 10, 2, COAT_D)           # 下摆
    # 削掉肩角，避免"方肩"
    px(d, 6, 12, COAT_L)
    px(d, 17, 12, COAT_D)
    dither(d, 9, 14, 6, 6, COAT_DD, 0.20)
    # 领口：小 V 字衬衫领（别用大灰块，会像围脖）
    px(d, 10, 12, SHIRT_IN)
    px(d, 13, 12, SHIRT_IN)
    px(d, 11, 13, SHIRT_IN)
    px(d, 12, 13, SHIRT_IN)
    # 门襟
    rect(d, 10, 14, 1, 7, COAT_D)
    rect(d, 13, 14, 1, 7, COAT_D)
    # 手臂（2px，比躯干窄一圈）
    rect(d, 4, 14, 2, 7, COAT_D)
    rect(d, 18, 14, 2, 7, COAT_D)
    rect(d, 4, 14, 2, 2, COAT)
    rect(d, 18, 14, 2, 2, COAT)
    px(d, 5, 21, SKIN_D)                    # 手
    px(d, 18, 21, SKIN_D)

    # ---- 脖子 ----
    rect(d, 10, 10, 4, 3, SKIN_D)
    rect(d, 10, 10, 4, 1, N2)               # 下颌投影

    # ---- 头：y3..11（10x9px）。小尺寸下必须做减法：
    #      1) 受光只放上半脸，绝不能压到眼睛那一行
    #      2) 眼睛下移到 y8、上方留 2 行额头，才不会和刘海糊成"墨镜"
    #      3) 眼色用深棕灰 EYE，不用纯黑 OUTLINE ----
    rect(d, 8, 4, 8, 7, SKIN)               # 面部主体 x8..15
    rect(d, 7, 5, 10, 5, SKIN)              # 两侧鼓出 x7..16
    rect(d, 9, 11, 6, 1, SKIN_D)            # 下巴阴影
    rect(d, 7, 5, 2, 2, SKIN_L)             # 左侧受光（仅上半脸）
    rect(d, 10, 4, 4, 1, SKIN_L)            # 额头高光
    # 注：不要在颊部抖色——10px 宽的脸会把抖点读成"小胡子"

    # ---- 五官 ----
    rect(d, 9, 8, 2, 1, EYE)                # 左眼
    rect(d, 13, 8, 2, 1, EYE)               # 右眼
    px(d, 12, 10, SKIN_D)                   # 嘴

    # ---- 头发：盖住 y2..5，鬓角止于 y7（不压眼行），形成脸部取景框 ----
    rect(d, 8, 3, 8, 2, HAIR)               # 主发 y3..4
    rect(d, 7, 4, 10, 2, HAIR)              # y4..5 全宽
    rect(d, 8, 2, 8, 1, HAIR)               # 发顶
    rect(d, 7, 6, 1, 2, HAIR)               # 左鬓 y6..7
    rect(d, 16, 6, 1, 2, HAIR)              # 右鬓 y6..7
    rect(d, 9, 3, 4, 1, HAIR_L)             # 发丝高光
    px(d, 9, 3, HAIR_HL)
    px(d, 10, 3, HAIR_HL)

    return outline_inner(img)


# ================================================================ 地面 tile 32x32
def gen_grass():
    img, d = new(32, 32)
    rect(d, 0, 0, 32, 32, GRASS)
    # 大块明暗斑（低对比，避免"脏"）
    dither(d, 0, 0, 32, 32, GRASS_L, 0.18)
    dither(d, 8, 10, 20, 22, GRASS_D, 0.20, phase=2)
    # 草簇
    seed = 7
    for i in range(34):
        seed = (seed * 9301 + 49297) % 233280
        x = seed % 32
        seed = (seed * 9301 + 49297) % 233280
        y = seed % 32
        c = GRASS_L if i % 3 else GRASS_D
        rect(d, x, y, 1, 2, c)
        if i % 5 == 0:
            px(d, x + 1, y + 1, c)
    return img


def gen_road():
    img, d = new(32, 32)
    rect(d, 0, 0, 32, 32, ROAD)
    dither(d, 0, 0, 32, 32, ROAD_L, 0.16)
    dither(d, 6, 6, 24, 24, ROAD_D, 0.18, phase=3)
    # 沥青颗粒
    seed = 13
    for i in range(26):
        seed = (seed * 9301 + 49297) % 233280
        x = seed % 32
        seed = (seed * 9301 + 49297) % 233280
        y = seed % 32
        px(d, x, y, ROAD_D if i % 2 else ROAD_L)
    # 裂缝
    rect(d, 5, 0, 1, 9, ROAD_D)
    rect(d, 22, 18, 1, 12, ROAD_D)
    return img


def gen_road_line():
    img, d = new(32, 32)
    rect(d, 0, 0, 32, 32, ROAD)
    dither(d, 0, 0, 32, 32, ROAD_L, 0.16)
    # 斑马线式的虚线（冷白、略脏）
    for y0 in (4, 18):
        rect(d, 13, y0, 6, 9, LINE)
        rect(d, 13, y0, 6, 1, G3)
        rect(d, 13, y0 + 8, 6, 1, G2)
        dither(d, 13, y0, 6, 9, ROAD_D, 0.12)
    return img


# ================================================================ 建筑 64x64
def _facade(img, d, wall, wall_l, wall_d, eave, eave_l):
    """画立面底：檐口 + 墙体 + 体积感"""
    rect(d, 0, 0, 64, 7, eave)              # 檐口
    rect(d, 0, 0, 64, 2, eave_l)            # 檐口受光
    rect(d, 0, 7, 64, 1, N0)                # 檐下投影
    rect(d, 1, 8, 62, 55, wall)
    rect(d, 1, 8, 62, 3, wall_l)            # 墙体顶部受光
    rect(d, 1, 8, 3, 55, wall_l)            # 左侧受光
    rect(d, 57, 10, 6, 53, wall_d)          # 右侧暗面
    dither(d, 5, 12, 52, 46, wall_d, 0.16, phase=1)
    rect(d, 1, 60, 62, 3, wall_d)           # 地脚暗带
    rect(d, 1, 59, 62, 1, N0)


def _window(d, x, y, w, h, on, c_hl, c_main, c_dark, dark):
    """一扇窗：外框 + 玻璃。on=True 表示室内亮灯（暖光/冷光由 c_* 决定）"""
    rect(d, x, y, w, h, N0)                         # 窗框
    rect(d, x + 1, y + 1, w - 2, h - 2, dark)       # 玻璃底
    if on:
        rect(d, x + 1, y + 1, w - 2, h - 2, c_dark)
        rect(d, x + 1, y + 1, w - 2, h - 3, c_main)
        rect(d, x + 1, y + 1, w - 4, 1, c_hl)       # 上缘高光
        px(d, x + 1, y + 1, c_hl)
        dither(d, x + 1, y + h - 4, w - 2, 2, c_dark, 0.4)
    else:
        rect(d, x + 1, y + 1, w - 2, 1, (48, 62, 86))
        dither(d, x + 1, y + 1, w - 2, h - 2, (26, 34, 50), 0.35, phase=2)


def gen_building_home():
    """居民楼：暖色石膏外墙 + 零星亮灯窗（最贴近参考图的建筑）"""
    img, d = new(64, 64)
    _facade(img, d, HOME_WALL, HOME_WALL_L, HOME_WALL_D, HOME_EAVE, HOME_EAVE_L)
    lit = {(0, 1), (2, 0), (1, 2)}          # 哪几扇窗亮着（保持稀疏，才像深夜）
    for r in range(3):
        for c in range(3):
            x = 6 + c * 19
            y = 12 + r * 15
            _window(d, x, y, 14, 11, (r, c) in lit, WIN_LIT_HL, WIN_LIT, WIN_LIT_D, WIN_DARK)
    # 楼道门
    rect(d, 26, 50, 12, 13, N0)
    rect(d, 27, 51, 10, 11, (60, 52, 58))
    rect(d, 27, 51, 10, 2, (84, 72, 74))
    px(d, 35, 56, W1)                        # 门把手反光
    # 单元牌
    rect(d, 6, 50, 12, 5, (52, 56, 70))
    rect(d, 7, 51, 10, 3, (78, 84, 100))
    return outline_inner(img)


def gen_building_store():
    """便利店：大面积落地橱窗 + 招牌（画面里唯一的高饱和暖色块）"""
    img, d = new(64, 64)
    _facade(img, d, STORE_WALL, STORE_WALL_L, STORE_WALL_D, (66, 70, 88), (92, 96, 116))
    # 招牌
    rect(d, 4, 9, 56, 12, N0)
    rect(d, 5, 10, 54, 10, ACCENT)
    rect(d, 5, 10, 54, 2, (206, 108, 92))
    dither(d, 5, 12, 54, 8, (120, 44, 38), 0.28, phase=1)
    # 招牌上的字（用亮块示意，不用真字体）
    for i, x in enumerate((10, 22, 34, 46)):
        rect(d, x, 13, 8, 5, W3 if i % 2 == 0 else G4)
        rect(d, x + 3, 13, 2, 5, ACCENT)
    # 落地橱窗（亮着，透露店内暖光）
    _window(d, 6, 30, 22, 20, True, W3, W2, W1, WIN_DARK)
    _window(d, 36, 30, 22, 20, True, W3, W2, W1, WIN_DARK)
    # 橱窗内的货架剪影
    for x in (8, 14, 20, 38, 44, 50):
        rect(d, x, 40, 3, 9, (120, 92, 66))
        rect(d, x, 36, 3, 3, (86, 66, 52))
    # 门
    rect(d, 27, 50, 10, 13, N0)
    rect(d, 28, 51, 8, 11, WIN_LIT_D)
    rect(d, 28, 51, 8, 9, W1)
    return outline_inner(img)


def gen_building_office():
    """写字楼：冷灰网格窗，只有少数几层还亮着（加班感）"""
    img, d = new(64, 64)
    _facade(img, d, OFFICE_WALL, OFFICE_WALL_L, OFFICE_WALL_D, OFFICE_EAVE, OFFICE_EAVE_L)
    lit = {(0, 1), (1, 2), (2, 0), (1, 0)}
    for r in range(4):
        for c in range(4):
            x = 5 + c * 14
            y = 11 + r * 12
            is_lit = (r, c) in lit
            if is_lit:
                _window(d, x, y, 11, 8, True, (196, 212, 228), WIN_COOL, (118, 140, 164), WIN_DARK)
            else:
                _window(d, x, y, 11, 8, False, WIN_LIT_HL, WIN_LIT, WIN_LIT_D, WIN_DARK)
    # 大堂
    rect(d, 20, 50, 24, 13, N0)
    rect(d, 21, 51, 22, 10, (44, 54, 74))
    rect(d, 21, 51, 22, 8, (72, 88, 112))
    rect(d, 30, 53, 4, 9, (96, 116, 142))
    return outline_inner(img)


# ================================================================ 树 32x40
def gen_tree():
    img, d = new(32, 40)
    ellipse_px(d, 16, 37, 10, 3, (0, 0, 0, 50))
    # 树干（受光在左）
    rect(d, 14, 24, 4, 12, TRUNK)
    rect(d, 14, 24, 1, 12, (96, 84, 72))
    rect(d, 17, 24, 1, 12, TRUNK_D)
    # 树冠：多层像素圆，左上受光、右下深暗
    ellipse_px(d, 16, 20, 13, 8, LEAF)
    ellipse_px(d, 16, 13, 12, 9, LEAF)
    ellipse_px(d, 16, 17, 14, 9, LEAF)
    # 暗部（右下）
    ellipse_px(d, 20, 24, 7, 4, LEAF_D)
    ellipse_px(d, 21, 20, 6, 5, LEAF_D)
    dither(d, 12, 8, 12, 10, LEAF_DD, 0.22, phase=2)
    dither(d, 20, 18, 10, 10, LEAF_D, 0.4, phase=1)
    # 亮部（左上）
    ellipse_px(d, 11, 10, 6, 4, LEAF_L)
    ellipse_px(d, 9, 12, 4, 5, LEAF_L)
    dither(d, 6, 6, 9, 8, LEAF_L, 0.45, phase=3)
    px(d, 8, 8, (110, 140, 126))
    px(d, 10, 7, (110, 140, 126))
    # 叶片缺口（打破"圆球感"）
    for x, y in ((4, 16), (5, 17), (26, 15), (27, 16), (25, 22), (14, 4), (18, 4)):
        if 0 <= x < 32 and 0 <= y < 40:
            d.point((x, y), fill=(0, 0, 0, 0))
    return outline_inner(img)


# ================================================================ 交互点 24x24
def gen_poi():
    """可交互点：干净的同心环 + 外发光 + 暖核。
    （上一版用抖色铺环，放大后是噪点星芒，很脏——这里改成逐像素径向计算。）"""
    img = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
    pm = img.load()
    c = 11.5
    for y in range(24):
        for x in range(24):
            dd = math.hypot(x - c, y - c)
            if dd > 11.5:
                continue
            if dd > 8.0:                                   # 外发光（柔和衰减）
                a = int(58 * (1.0 - (dd - 8.0) / 3.5) ** 1.7)
                if a > 0:
                    pm[x, y] = (172, 202, 228, a)
            elif dd > 6.2:                                 # 亮环
                pm[x, y] = (206, 226, 244, 205)
            elif dd > 4.6:                                 # 环内侧暗槽（拉开层次）
                pm[x, y] = (40, 62, 88, 240)
            elif dd > 2.6:                                 # 内盘
                pm[x, y] = (62, 92, 124, 245)
            elif dd > 1.3:                                 # 暖核边缘
                pm[x, y] = (232, 200, 158, 250)
            else:                                          # 暖核
                pm[x, y] = (255, 246, 226, 255)
    return img


# ================================================================ 光照贴图
def gen_light_warm(size=128, power=2.4):
    """PointLight2D 用的暖色径向渐变（alpha 做衰减，RGB 恒定）"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pm = img.load()
    c = (size - 1) / 2.0
    for y in range(size):
        for x in range(size):
            dd = math.hypot(x - c, y - c) / (size / 2.0)
            if dd >= 1.0:
                continue
            a = (1.0 - dd) ** power
            pm[x, y] = (255, 226, 186, int(255 * a))
    return img


def gen_vignette(w=360, h=640, strength=0.66, inner=0.40):
    """暗角：中心透明、四角压暗，并带一点冷蓝，模拟参考图的聚焦感"""
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    pm = img.load()
    cx, cy = w / 2.0, h / 2.0
    maxd = math.hypot(cx, cy)
    for y in range(h):
        for x in range(w):
            dd = math.hypot(x - cx, y - cy) / maxd
            t = (dd - inner) / (1.0 - inner)
            if t <= 0:
                continue
            a = int(255 * strength * (t ** 1.5))
            if a:
                pm[x, y] = (10, 14, 30, min(255, a))
    return img


# ================================================================ 预览
def _open(name):
    return Image.open(os.path.join(OUT, name)).convert("RGBA")


def gen_preview_sprites():
    """精灵总览图（4x 放大 + 深色底，便于肉眼验收）"""
    names = [
        ("player.png", 24, 32), ("poi.png", 24, 24), ("tree.png", 32, 40),
        ("grass.png", 32, 32), ("road.png", 32, 32), ("road_line.png", 32, 32),
        ("building_home.png", 64, 64), ("building_store.png", 64, 64),
        ("building_office.png", 64, 64),
    ]
    scale = 3
    pad = 10
    cols = 3
    rows = (len(names) + cols - 1) // cols
    cell_w = max(n[1] for n in names) * scale + pad * 2
    cell_h = max(n[2] for n in names) * scale + pad * 2
    W = cols * cell_w
    H = rows * cell_h
    sheet = Image.new("RGBA", (W, H), (18, 21, 32, 255))
    d = ImageDraw.Draw(sheet)
    for i, (name, w, h) in enumerate(names):
        cx = (i % cols) * cell_w
        cy = (i // cols) * cell_h
        d.rectangle([cx, cy, cx + cell_w - 1, cy + cell_h - 1], outline=(44, 52, 72))
        sp = _open(name).resize((w * scale, h * scale), Image.NEAREST)
        sheet.alpha_composite(sp, (cx + (cell_w - w * scale) // 2, cy + (cell_h - h * scale) // 2))
    return sheet


def gen_preview_scene():
    """地图合成预览：按真实尺寸拼一块场景（360x640，与游戏视口一致）"""
    W, H = 360, 640
    img = Image.new("RGBA", (W, H), (14, 18, 30, 255))
    grass = _open("grass.png")

    for y in range(0, H, 32):
        for x in range(0, W, 32):
            img.alpha_composite(grass, (x, y))

    road = _open("road.png")
    for y in (470, 502):
        for x in range(0, W, 32):
            img.alpha_composite(road, (x, y))
    for x in (198, 230):
        for y in range(0, H, 32):
            img.alpha_composite(road, (x, y))

    def paste(name, x, y):
        img.alpha_composite(_open(name), (int(x), int(y)))

    # 建筑（底边对齐、按 y 排序）
    paste("building_home.png", 40, 150)
    paste("building_store.png", 244, 250)
    paste("building_office.png", 96, 372)
    # 树
    for tx, ty in ((10, 250), (140, 210), (300, 170), (18, 560), (128, 520), (296, 470)):
        paste("tree.png", tx, ty)
    # NPC（用一个暖色 modulate 变体，模拟游戏里 NPC_TINT 的效果）
    r, g, b, a = _open("player.png").split()
    npc = Image.merge("RGBA", (r, g.point(lambda v: int(v * 0.82)), b.point(lambda v: int(v * 0.66)), a))
    img.alpha_composite(npc, (118, 312))
    # 玩家 / 交互点
    paste("player.png", 176, 330)
    paste("poi.png", 292, 282)
    paste("poi.png", 188, 528)

    # 暖光池（加法混合，模拟 PointLight2D 的 BLEND_MODE_ADD）
    light = gen_light_warm()
    for lx, ly, sc, en in ((72, 190, 2.4, 0.42), (276, 292, 2.6, 0.46), (128, 410, 2.0, 0.26)):
        ls = light.resize((int(128 * sc), int(128 * sc)), Image.BILINEAR)
        ls = _scale_alpha(ls, en)
        img = _add_blend(img, ls, int(lx - ls.size[0] / 2), int(ly - ls.size[1] / 2))

    # 简易 HUD
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, W, 44], fill=(26, 32, 48, 236))
    d.rectangle([0, 44, W, 45], fill=(70, 84, 110, 255))
    d.rectangle([10, 10, 26, 26], fill=(66, 84, 112, 255))
    d.rectangle([34, 11, 132, 19], fill=(196, 206, 224, 255))
    d.rectangle([34, 25, 96, 30], fill=(120, 134, 160, 255))
    d.rectangle([236, 10, 350, 18], fill=(204, 167, 137, 255))
    d.rectangle([236, 24, 316, 29], fill=(120, 134, 160, 255))
    d.rectangle([10, 580, 220, 588], fill=(150, 160, 180, 200))
    d.rectangle([10, 596, 300, 604], fill=(110, 122, 146, 200))

    # 暗角
    img.alpha_composite(gen_vignette(W, H))
    return img


def _scale_alpha(im, k):
    r, g, b, a = im.split()
    a = a.point(lambda v: int(v * k))
    return Image.merge("RGBA", (r, g, b, a))


def _add_blend(base, add, x, y):
    """加法混合（模拟 2D 光照的 ADD 模式）：result = base + add.rgb * add.alpha"""
    base = base.copy()
    bw, bh = base.size
    aw, ah = add.size
    x0, y0 = max(0, x), max(0, y)
    x1, y1 = min(bw, x + aw), min(bh, y + ah)
    if x1 <= x0 or y1 <= y0:
        return base
    region = base.crop((x0, y0, x1, y1)).convert("RGB")
    sub = add.crop((x0 - x, y0 - y, x1 - x, y1 - y))
    sr, sg, sb, sa = sub.split()
    rgb = region.load()
    ar, ag, ab = sr.load(), sg.load(), sb.load()
    aa = sa.load()
    for yy in range(region.size[1]):
        for xx in range(region.size[0]):
            k = aa[xx, yy] / 255.0
            if k <= 0:
                continue
            c0 = rgb[xx, yy]
            rgb[xx, yy] = (
                min(255, int(c0[0] + ar[xx, yy] * k)),
                min(255, int(c0[1] + ag[xx, yy] * k)),
                min(255, int(c0[2] + ab[xx, yy] * k)),
            )
    base.paste(region.convert("RGBA"), (x0, y0))
    return base


# ================================================================ main
def main():
    assets = {
        "player.png": gen_player(),
        "grass.png": gen_grass(),
        "road.png": gen_road(),
        "road_line.png": gen_road_line(),
        "building_home.png": gen_building_home(),
        "building_store.png": gen_building_store(),
        "building_office.png": gen_building_office(),
        "tree.png": gen_tree(),
        "poi.png": gen_poi(),
        "light_warm.png": gen_light_warm(),
        "vignette.png": gen_vignette(),
    }
    print("生成像素素材（氛围像素风 v2）")
    for name, im in assets.items():
        im.save(os.path.join(OUT, name), "PNG")
        print(f"  {name:24s} {im.size[0]}x{im.size[1]}")

    gen_preview_sprites().save(os.path.join(OUT, "..", "preview_sprites.png"), "PNG")
    gen_preview_scene().save(os.path.join(OUT, "..", "preview_scene.png"), "PNG")
    print(f"  预览图                    preview_sprites.png / preview_scene.png")
    print(f"\n共 {len(assets)} 个素材 → {os.path.normpath(OUT)}")

    # 调色板合规自检：除 ACCENT 外不应出现高饱和色
    bad = 0
    for name, im in assets.items():
        if name in ("light_warm.png", "vignette.png"):
            continue
        for r, g, b, a in im.getdata():
            if a < 8:
                continue
            mx, mn = max(r, g, b), min(r, g, b)
            sat = (mx - mn) / mx if mx else 0
            if sat > 0.42 and (r, g, b) != ACCENT:
                bad += 1
    print(f"调色板合规：高饱和像素 {bad} 个（含 ACCENT 招牌为设计意图）")
    print("ART_GEN_OK")


if __name__ == "__main__":
    main()
