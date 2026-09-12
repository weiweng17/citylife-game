"""
美术公共库 · 都市浮生 v3
================================================================
这一版的核心改变：不再"画一张平的图"，而是按真实光照模型出图。

参考图（两张夜景像素）的实测统计：
    近黑像素（max 通道 < 40）占 61% ~ 63%
    亮部（min 通道 > 170）只占 0.1%
也就是说它的"氛围"= 大面积极暗 + 极小面积暖光。之前那版整体太亮、
太均匀，所以怎么调都"不像"。

因此这里的流程是：
    1. 先画 albedo（材质固有色，不带光）
    2. 再按点光源列表逐像素计算照度  L = ambient + Σ energy/(1+(d/r)^2.2)
    3. out = albedo * L + glow（glow 模拟泛光）
    4. 再叠 AO（物体根部/墙根的接触阴影）
做了这四步，画面才会出现"光落在物体上"的立体感 —— 这是手绘平涂给不了的。

实体（角色/NPC/可交互点）不烘焙，改为运行时采样 lightmap.png 做 modulate，
这样站在灯下就自然被烤暖、走进暗处就沉下去，和背景光照是同一套光源。
"""

import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPR = os.path.join(ROOT, "assets", "sprites")
SCN = os.path.join(ROOT, "assets", "scene")
FONT_PATH = os.path.join(ROOT, "assets", "fonts", "GameCN.ttf")
os.makedirs(SPR, exist_ok=True)
os.makedirs(SCN, exist_ok=True)

# ================================================================ 调色板
# 全部按参考图实测区间重定：低饱和、低对比、冷底暖点。

# 冷底（夜色 / 阴影 / 玻璃）
N0 = (16, 18, 26)
N1 = (24, 29, 42)
N2 = (33, 41, 58)
N3 = (42, 53, 74)
N4 = (54, 68, 92)
N5 = (72, 90, 118)

# 中性（水泥 / 月光 / 石材）
G0 = (58, 58, 66)
G1 = (82, 83, 92)
G2 = (108, 109, 118)
G3 = (140, 140, 146)
G4 = (176, 175, 176)
G5 = (208, 206, 202)

# 暖光（低饱和琥珀，参考图实测 #cca789 一档才是主色）
W0 = (86, 60, 40)
W1 = (128, 92, 62)
W2 = (170, 128, 92)
W3 = (206, 168, 128)
W4 = (236, 208, 172)
W5 = (252, 236, 208)

ACCENT = (172, 66, 54)       # 招牌红（画面唯一高饱和块）
NEON = (96, 208, 190)        # 便利店霓虹青
OUTLINE = (18, 19, 28)       # 深藏蓝描边，不用纯黑（纯黑会把像素割裂）

# 角色
SKIN = (224, 188, 162)
SKIN_L = (246, 216, 190)
SKIN_D = (176, 138, 116)
HAIR = (28, 28, 40)
HAIR_L = (54, 54, 70)
HAIR_HL = (96, 96, 114)
SHIRT = (228, 229, 232)
SHIRT_D = (168, 174, 186)
TIE = (40, 44, 62)
PANTS = (44, 50, 72)
PANTS_D = (32, 36, 54)
SHOE = (24, 24, 32)

# 树
TRUNK = (70, 60, 52)
TRUNK_D = (48, 40, 36)
LEAF = (44, 62, 60)
LEAF_L = (62, 86, 80)
LEAF_D = (30, 44, 44)
LEAF_DD = (20, 30, 32)

# 地面
ASPHALT = (58, 60, 66)
ASPHALT_L = (70, 72, 78)
ASPHALT_D = (42, 43, 49)
PAVER = (96, 96, 100)
PAVER_L = (114, 114, 118)
PAVER_D = (74, 74, 78)
GRASS = (52, 66, 56)
GRASS_L = (66, 84, 68)
GRASS_D = (36, 48, 42)
SOIL = (52, 44, 38)
ALLEY_FLOOR = (60, 60, 64)
CURB = (120, 120, 122)
CURB_D = (70, 70, 74)
PAINT = (176, 174, 160)      # 路面标线

# 墙面（各建筑）
WALL_APART = (104, 96, 88)
WALL_APART_L = (128, 118, 108)
WALL_APART_D = (76, 70, 66)
WALL_HOSP = (132, 134, 134)
WALL_HOSP_L = (156, 158, 158)
WALL_HOSP_D = (98, 100, 102)
WALL_OFFICE = (62, 70, 86)
WALL_OFFICE_L = (82, 92, 110)
WALL_OFFICE_D = (44, 50, 64)
WALL_STORE = (92, 84, 76)
WALL_STORE_L = (114, 104, 94)
WALL_STORE_D = (66, 60, 56)
WALL_OLD = (86, 82, 78)
WALL_OLD_L = (106, 100, 94)
WALL_OLD_D = (60, 56, 54)

GLASS_DARK = (26, 32, 46)
GLASS_COOL = (58, 74, 96)

# ================================================================ 光照参数
AMBIENT = (0.065, 0.080, 0.115)      # 冷调环境光（很低，氛围全靠它压暗）
MOON_TINT = (0.55, 0.62, 0.85)       # 月光方向补色


# ================================================================ 数值工具
def value_noise(w, h, cell, seed, octaves=3, persistence=0.5):
    """分形值噪声，0..1。用于墙面污渍、地面磨损、草丛。"""
    rng = np.random.default_rng(seed)
    total = np.zeros((h, w), np.float32)
    norm = 0.0
    amp = 1.0
    c = float(cell)
    for _ in range(octaves):
        gw = max(2, int(w / c) + 2)
        gh = max(2, int(h / c) + 2)
        g = (rng.random((gh, gw)) * 255).astype(np.uint8)
        up = Image.fromarray(g).resize((w, h), Image.BICUBIC)
        total += np.asarray(up, np.float32) / 255.0 * amp
        norm += amp
        amp *= persistence
        c = max(2.0, c / 2.0)
    return total / norm


def tile_noise(w, h, tile, seed):
    """每块砖一个随机值（NEAREST 放大），做出"每块略有差别"的效果。"""
    rng = np.random.default_rng(seed)
    gw = int(w / tile) + 2
    gh = int(h / tile) + 2
    g = (rng.random((gh, gw)) * 255).astype(np.uint8)
    up = Image.fromarray(g).resize((gw * tile, gh * tile), Image.NEAREST)
    return np.asarray(up.crop((0, 0, w, h)), np.float32) / 255.0


def grid_lines(w, h, tile, thick=2):
    """网格线掩码（砖缝），返回 bool 数组。"""
    xs = (np.arange(w) % tile) < thick
    ys = (np.arange(h) % tile) < thick
    m = np.zeros((h, w), bool)
    m |= xs[None, :]
    m |= ys[:, None]
    return m


def rgb(c):
    return np.array([c[0], c[1], c[2]], np.float32) / 255.0


def shift_color(c, k):
    return (max(0, min(255, int(c[0] * k))),
            max(0, min(255, int(c[1] * k))),
            max(0, min(255, int(c[2] * k))))


def blur_mask(mask, radius):
    if radius <= 0:
        return mask
    im = Image.fromarray((np.clip(mask, 0, 1) * 255).astype(np.uint8))
    im = im.filter(ImageFilter.GaussianBlur(radius))
    return np.asarray(im, np.float32) / 255.0


def circle_mask(w, h, cx, cy, r, soft=0.0):
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
    if soft <= 0:
        return (d <= r).astype(np.float32)
    return np.clip((r - d) / max(1e-6, soft), 0.0, 1.0).astype(np.float32)


def ellipse_mask(w, h, cx, cy, rx, ry, soft=0.0):
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.sqrt(((xx - cx) / max(1e-6, rx)) ** 2 + ((yy - cy) / max(1e-6, ry)) ** 2)
    if soft <= 0:
        return (d <= 1.0).astype(np.float32)
    return np.clip((1.0 - d) / max(1e-6, soft), 0.0, 1.0).astype(np.float32)


def rect_mask(w, h, x0, y0, x1, y1, soft=0.0):
    m = np.zeros((h, w), np.float32)
    x0i, y0i = int(max(0, math.floor(x0))), int(max(0, math.floor(y0)))
    x1i, y1i = int(min(w, math.ceil(x1))), int(min(h, math.ceil(y1)))
    if x1i <= x0i or y1i <= y0i:
        return m
    m[y0i:y1i, x0i:x1i] = 1.0
    if soft > 0:
        m = blur_mask(m, soft)
    return m


def over(dst, src_rgb, mask):
    """把纯色按 mask 叠到 dst（float RGB, 0..1）。"""
    m = mask[..., None]
    return dst * (1.0 - m) + src_rgb[None, None, :] * m


# ================================================================ 光照
class Light:
    """点光源。x/y 世界坐标，r 光池半径，energy 强度，color 0..1 三通道。"""

    __slots__ = ("x", "y", "r", "energy", "color", "falloff", "glow")

    def __init__(self, x, y, r, energy, color, falloff=2.2, glow=0.0):
        self.x = float(x)
        self.y = float(y)
        self.r = float(r)
        self.energy = float(energy)
        self.color = np.array(color, np.float32)
        self.falloff = float(falloff)
        self.glow = float(glow)


def bake_light(w, h, lights, ambient=AMBIENT, x0=0, y0=0):
    """
    逐像素照度。返回 (L, glow)，L 为 3 通道 0..N。
    x0/y0 是子图原点在世界坐标中的偏移，便于只烘一块区域。
    """
    yy, xx = np.mgrid[y0:y0 + h, x0:x0 + w].astype(np.float32)
    L = np.zeros((h, w, 3), np.float32)
    L[..., 0] = ambient[0]
    L[..., 1] = ambient[1]
    L[..., 2] = ambient[2]
    glow = np.zeros((h, w, 3), np.float32)
    for lt in lights:
        d2 = (xx - lt.x) ** 2 + (yy - lt.y) ** 2
        att = lt.energy / (1.0 + (d2 / (lt.r * lt.r)) ** lt.falloff)
        L += lt.color[None, None, :] * att[..., None]
        if lt.glow > 0:
            g = lt.glow * np.exp(-d2 / max(1.0, (lt.r * 0.42) ** 2))
            glow += lt.color[None, None, :] * g[..., None]
    return L, glow


def apply_light(albedo, L, glow, ao=None):
    """out = albedo * L * ao + glow"""
    out = albedo * L
    if ao is not None:
        out *= ao[..., None]
    out = out + glow
    return np.clip(out, 0.0, 1.0)


def to_image(arr):
    return Image.fromarray((np.clip(arr, 0, 1) * 255.0 + 0.5).astype(np.uint8), "RGB")


# ================================================================ 文字（招牌）
_FONT_CACHE = {}


def _font(size):
    if size not in _FONT_CACHE:
        try:
            _FONT_CACHE[size] = ImageFont.truetype(FONT_PATH, size)
        except Exception:
            _FONT_CACHE[size] = ImageFont.load_default()
    return _FONT_CACHE[size]


def text_stamp(text, size, color, outline=OUTLINE, threshold=110, spacing=1):
    """
    生成一枚"像素感"文字贴图：TrueType 渲染后做二值化，去掉抗锯齿灰边，
    再补一圈描边。中文在 10~14px 直接渲染会糊，二值化后才像像素字。
    """
    f = _font(size)
    sp = spacing
    if sp > 0:
        try:
            f = ImageFont.truetype(FONT_PATH, size)
        except Exception:
            pass
    pad = 2
    tmp = Image.new("L", (size * (len(text) + 2) * 2, size * 4), 0)
    d = ImageDraw.Draw(tmp)
    try:
        d.text((pad, pad), text, font=f, fill=255, spacing=sp)
    except Exception:
        d.text((pad, pad), text, font=f, fill=255)
    bbox = tmp.getbbox()
    if bbox is None:
        return Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    tmp = tmp.crop((bbox[0] - 1, bbox[1] - 1, bbox[2] + 1, bbox[3] + 1))
    a = np.asarray(tmp, np.uint8)
    hard = (a >= threshold).astype(np.uint8) * 255
    w, h = tmp.size
    out = np.zeros((h + 2, w + 2, 4), np.uint8)
    core = np.zeros((h + 2, w + 2), bool)
    core[1:1 + h, 1:1 + w] = hard > 0
    ol = np.zeros((h + 2, w + 2), bool)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dx == 0 and dy == 0:
                continue
            ol |= np.roll(np.roll(core, dy, 0), dx, 1)
    ol &= ~core
    out[..., 0] = np.where(core, color[0], np.where(ol, outline[0], 0))
    out[..., 1] = np.where(core, color[1], np.where(ol, outline[1], 0))
    out[..., 2] = np.where(core, color[2], np.where(ol, outline[2], 0))
    out[..., 3] = np.where(core | ol, 255, 0).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


def paste_rgba(dst_img, stamp, x, y, alpha=255):
    if stamp.size[0] <= 1:
        return
    if alpha >= 255:
        dst_img.alpha_composite(stamp, (int(x), int(y)))
        return
    s = stamp.copy()
    a = s.getchannel("A").point(lambda v: int(v * alpha / 255))
    s.putalpha(a)
    dst_img.alpha_composite(s, (int(x), int(y)))


# ================================================================ 素材读写
def save(img, name, folder=None):
    p = os.path.join(folder or SPR, name)
    img.save(p)
    return p


def load_rgba(path):
    return Image.open(path).convert("RGBA")


def outline_alpha(img, color=OUTLINE, min_alpha=200):
    """给不透明区域补 1px 外描边（像素风的关键：把形状从背景里拎出来）。"""
    a = np.asarray(img.getchannel("A"), np.uint8)
    core = a >= min_alpha
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
    arr[..., 3] = np.where(ring, 255, arr[..., 3])
    return Image.fromarray(arr, "RGBA")
