"""
室内场景生成器 · 都市浮生
================================================================
按用户要求：进入「公司」等地点后，地图切换到对应的室内场景。

这一版先生成「公司办公室」样板（office_inside.png），做法：
    1. 画 albedo（房间固有材质：地毯地板 + 后墙 + 窗 + 工位/显示器/椅子 + 门）
    2. 用暖色室内光烘焙（天花板灯 + 窗外的冷月光），室内比街道亮、偏暖
    3. 叠 AO（家具根部/墙根接触阴影）
    → 视觉上和街道是同一条烘焙管线，但氛围是「室内被点亮」的对比。

画布 1080x1080，与街道地图同尺寸（相机 limit 复用，无需改相机）。

用法：
    python tools/gen_interior.py [office|store|home|hospital]
    → assets/scene/<id>_inside.png
"""

import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from artlib import (  # noqa: E402
    bake_light, apply_light, to_image, value_noise, tile_noise, rect_mask,
    circle_mask, ellipse_mask, Light, rgb, shift_color,
)

W = H = 1080

# 室内调色（比街道暖、亮；但整体仍克制，不刺眼）
CARPET = (46, 52, 58)        # 地毯地板（深灰蓝）
CARPET_L = (58, 66, 72)
CARPET_D = (36, 40, 46)
WALL = (92, 88, 82)          # 后墙（暖灰）
WALL_D = (66, 62, 58)
WINDOW_GLASS = (18, 24, 38)  # 夜窗玻璃
WINDOW_LIT = (176, 156, 108)  # 亮窗（隔壁还亮着）
DESK = (150, 142, 128)       # 桌面（浅木/米白）
DESK_D = (108, 100, 90)
MONITOR = (22, 26, 34)
MONITOR_GLOW = (120, 170, 190)
CHAIR = (52, 52, 60)
DOOR = (40, 40, 48)
PLANT = (52, 82, 60)


def build_office():
    # ---- albedo（RGB 0..1）----
    A = np.zeros((H, W, 3), np.float32)
    floor_c = rgb(CARPET)
    A[..., :] = floor_c[None, None, :]

    # 地板：大方格 + 磨损噪声
    tn = tile_noise(W, H, 90, seed=11)
    A = A * (1.0 - 0.06 * (tn - 0.5))[..., None] * 2.0
    A = np.clip(A, 0, 1)
    vn = value_noise(W, H, 220, seed=7, octaves=3)
    A = A * (0.92 + 0.10 * vn)[..., None]

    # 后墙（顶部 0..250，含踢脚）
    wall_c = rgb(WALL)
    wm = rect_mask(W, H, 0, 0, W, 250)
    A = A * (1 - wm[..., None]) + wall_c[None, None, :] * wm[..., None]
    # 墙的竖向明暗（顶部略暗）
    yy = (np.arange(H) / H).astype(np.float32)
    A = A * (0.94 + 0.10 * (yy[:, None] if False else yy)[:, None] * 0.5)  # 轻微
    # 踢脚线
    kb = rect_mask(W, H, 0, 236, W, 250)
    A = A * (1 - kb[..., None]) + rgb(WALL_D)[None, None, :] * kb[..., None]

    # ---- 窗（后墙上开 4 扇，夜玻璃 + 个别亮窗）----
    win_y0, win_y1 = 70, 190
    win_w, win_h = 150, 120
    for i in range(4):
        cx = 110 + i * 250
        x0, x1 = cx - win_w // 2, cx + win_w // 2
        wm = rect_mask(W, H, x0, win_y0, x1, win_y1)
        lit = (i % 3 == 1)   # 1/3 的窗亮着
        glass = rgb(WINDOW_LIT) if lit else rgb(WINDOW_GLASS)
        A = A * (1 - wm[..., None]) + glass[None, None, :] * wm[..., None]
        # 窗框
        fr = rect_mask(W, H, x0, win_y0, x1, win_y0 + 8)
        A = A * (1 - fr[..., None]) + rgb(WALL_D)[None, None, :] * fr[..., None]
        fr = rect_mask(W, H, x0, win_y1 - 8, x1, win_y1)
        A = A * (1 - fr[..., None]) + rgb(WALL_D)[None, None, :] * fr[..., None]

    # ---- 工位（3 行 x 2 列，桌面 + 显示器 + 椅子）----
    for row in range(3):
        for col in range(2):
            dx = 230 + col * 400
            dy = 330 + row * 230
            # 桌面
            dm = rect_mask(W, H, dx, dy, dx + 200, dy + 90)
            A = A * (1 - dm[..., None]) + rgb(DESK)[None, None, :] * dm[..., None]
            dm2 = rect_mask(W, H, dx, dy + 70, dx + 200, dy + 90)
            A = A * (1 - dm2[..., None]) + rgb(DESK_D)[None, None, :] * dm2[..., None]
            # 显示器（桌后沿一个小方块，发光屏）
            mon = rect_mask(W, H, dx + 70, dy - 26, dx + 150, dy + 4)
            A = A * (1 - mon[..., None]) + rgb(MONITOR)[None, None, :] * mon[..., None]
            scr = rect_mask(W, H, dx + 76, dy - 20, dx + 144, dy + 2)
            A = A * (1 - scr[..., None]) + rgb(MONITOR_GLOW)[None, None, :] * scr[..., None]
            # 椅子
            ch = ellipse_mask(W, H, dx + 90, dy + 118, 34, 20)
            A = A * (1 - ch[..., None]) + rgb(CHAIR)[None, None, :] * ch[..., None]
            # 桌面文件堆（小块）
            for j in range(2):
                pa = rect_mask(W, H, dx + 16 + j * 40, dy + 12, dx + 40 + j * 40, dy + 28)
                A = A * (1 - pa[..., None]) + rgb((120, 118, 112))[None, None, :] * pa[..., None]

    # ---- 门（底部中央，深色门框 = 出口）----
    door = rect_mask(W, H, W // 2 - 80, H - 40, W // 2 + 80, H)
    A = A * (1 - door[..., None]) + rgb(DOOR)[None, None, :] * door[..., None]
    dfr = rect_mask(W, H, W // 2 - 80, H - 46, W // 2 + 80, H - 40)
    A = A * (1 - dfr[..., None]) + rgb(WALL_D)[None, None, :] * dfr[..., None]

    # ---- 盆栽点缀 ----
    for px, py in [(150, 300), (930, 300), (150, 780), (930, 780)]:
        pm = ellipse_mask(W, H, px, py, 26, 30)
        A = A * (1 - pm[..., None]) + rgb(PLANT)[None, None, :] * pm[..., None]

    # ---- 烘焙光照：室内暖色 + 窗外冷月光 ----
    lights = []
    # 天花板灯（工位上方）
    for row in range(3):
        for col in range(2):
            lx = 320 + col * 400
            ly = 360 + row * 230
            lights.append(Light(lx, ly, 190, 0.55, (1.00, 0.86, 0.66), falloff=2.0, glow=0.30))
    # 窗外的冷月光（从后墙透进来，压在窗下方）
    for i in range(4):
        cx = 110 + i * 250
        lights.append(Light(cx, 260, 240, 0.20, (0.55, 0.62, 0.85), falloff=2.0, glow=0.0))
    ambient = (0.16, 0.15, 0.15)
    L, glow = bake_light(W, H, lights, ambient=ambient)
    out = apply_light(A, L, glow)

    # ---- AO（家具/墙根接触阴影）----
    ao = np.ones((H, W), np.float32)
    # 后墙根
    ao *= 1.0 - 0.35 * rect_mask(W, H, 0, 220, W, 250, soft=10)
    # 家具根
    for row in range(3):
        for col in range(2):
            dx = 230 + col * 400
            dy = 330 + row * 230
            ao *= 1.0 - 0.25 * rect_mask(W, H, dx - 6, dy + 78, dx + 206, dy + 96, soft=10)
    ao *= 1.0 - 0.20 * rect_mask(W, H, 0, H - 50, W, H, soft=12)
    out *= ao[..., None]
    out = np.clip(out, 0, 1)

    return to_image(out)


BUILDERS = {
    "office": build_office,
}


def main():
    pid = sys.argv[1] if len(sys.argv) > 1 else "office"
    builder = BUILDERS.get(pid)
    if builder is None:
        print("未知地点：%s（可选 office）" % pid)
        sys.exit(1)
    img = builder()
    out_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                            "assets", "scene", "%s_inside.png" % pid)
    img.save(out_path)
    print("室内场景 OK: %s (%dx%d)" % (out_path, img.size[0], img.size[1]))


if __name__ == "__main__":
    main()
