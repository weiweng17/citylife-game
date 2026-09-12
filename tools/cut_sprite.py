"""
AI 出图 → 游戏素材：抠底 + 稳健裁剪 + 按目标高度缩放
================================================================
ImageGen 的 background:"transparent" 不会生效，出图都带底色，必须后处理。
本脚本处理三种常见的坑：
  1. 纯色/渐变亮底        → 从四边 floodfill 即可
  2. 亮底但最外圈有深色边框 → 四边种子只吃到边框，需从"内侧亮区"补种子
  3. 抠完后残留贴边杂点    → 清掉最外圈 N px；裁剪按"行列统计"忽略零星杂点

同时会量出**头身比**（头占全身百分比），用于校验 Q 版大头是否达标。

用法：
    # 批量：把目录下所有 png 按顺序命名
    python tools/cut_sprite.py --dir assets/concept3 \
        --names chenjie,laozhang,laozhou,daoshi,xiaoyu,azhe \
        --out assets/sprites --prefix npc_ --height 72

    # 单张
    python tools/cut_sprite.py --file assets/concept2/cut/3_休闲连帽.png \
        --out assets/sprites --name player_v5 --height 80
"""

import argparse
import glob
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def remove_bg(im, thresh_edge=90, thresh_inner=60, bright=150, ring=26):
    """连通域抠底。返回 RGBA 图。"""
    rgba = im.convert("RGBA")
    W, H = rgba.size
    lum0 = np.asarray(rgba)[..., :3].mean(2)
    out = rgba.copy()

    # 1) 四边直接填充
    for s in range(0, H, 24):
        ImageDraw.floodfill(out, (0, s), (0, 0, 0, 0), thresh=thresh_edge)
        ImageDraw.floodfill(out, (W - 1, s), (0, 0, 0, 0), thresh=thresh_edge)
    for s in range(0, W, 24):
        ImageDraw.floodfill(out, (s, 0), (0, 0, 0, 0), thresh=thresh_edge)
        ImageDraw.floodfill(out, (s, H - 1), (0, 0, 0, 0), thresh=thresh_edge)

    # 2) 内侧亮区补种子（对付"亮底+深色外框"）
    for inset in (45, 70, 110):
        if inset >= min(W, H) // 2:
            continue
        for y in range(inset, H - inset, 18):
            for x in (inset, W - 1 - inset):
                if lum0[y, x] > bright:
                    ImageDraw.floodfill(out, (x, y), (0, 0, 0, 0), thresh=thresh_inner)
        for x in range(inset, W - inset, 18):
            for y in (inset, H - 1 - inset):
                if lum0[y, x] > bright:
                    ImageDraw.floodfill(out, (x, y), (0, 0, 0, 0), thresh=thresh_inner)

    al = np.asarray(out)[..., 3].copy()
    m = al > 30
    if not m.any():
        return out
    ys, xs = np.where(m)
    # 3) 残留贴边（疑似外框）→ 清最外圈
    if xs.min() < 30 or ys.min() < 30 or xs.max() > W - 30 or ys.max() > H - 30:
        al[:ring, :] = 0
        al[-ring:, :] = 0
        al[:, :ring] = 0
        al[:, -ring:] = 0
    a2 = np.asarray(out).copy()
    a2[..., 3] = al
    return Image.fromarray(a2, "RGBA")


def robust_crop(im, min_ratio=0.01):
    """按'行列统计'裁剪，忽略零星杂点。"""
    a = np.asarray(im)
    m = a[..., 3] > 30
    H, W = m.shape
    cols = np.where(m.sum(0) > H * min_ratio)[0]
    rows = np.where(m.sum(1) > W * min_ratio)[0]
    if len(cols) == 0 or len(rows) == 0:
        return im
    return im.crop((int(cols.min()), int(rows.min()), int(cols.max()) + 1, int(rows.max()) + 1))


def head_ratio(im):
    """用'逐行宽度'找脖子（上半部最窄处），估算头占全身百分比与头身数。"""
    a = np.asarray(im)
    m = a[..., 3] > 30
    ch, cw = m.shape
    if ch == 0:
        return None, None
    w = [int(m[y].sum()) for y in range(ch)]
    lo, hi = int(ch * 0.10), int(ch * 0.55)
    if hi <= lo:
        return None, None
    neck = min(range(lo, hi), key=lambda y: w[y])
    pct = 100.0 * neck / ch
    return pct, ch / max(1, neck)


def process(path, target_h, out_dir, name, quiet=False):
    raw = Image.open(path)
    cut = robust_crop(remove_bg(raw))
    pct, heads = head_ratio(cut)
    if target_h and target_h > 0:
        tw = max(1, round(target_h * cut.size[0] / cut.size[1]))
        out = cut.resize((tw, target_h), Image.LANCZOS)
    else:
        out = cut
    os.makedirs(out_dir, exist_ok=True)
    p = os.path.join(out_dir, name + ".png")
    out.save(p)
    if not quiet:
        hr = ("头占%.0f%% (%.1f头身)" % (pct, heads)) if pct else "头身比未知"
        print("  %-22s %dx%d  %s" % (name, out.size[0], out.size[1], hr))
    return p


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", help="输入目录（按文件名排序）")
    ap.add_argument("--file", help="单张输入")
    ap.add_argument("--names", default="", help="逗号分隔的输出名，与 --dir 内文件一一对应")
    ap.add_argument("--name", default="sprite", help="单张输出名")
    ap.add_argument("--prefix", default="", help="输出名前缀")
    ap.add_argument("--out", required=True, help="输出目录")
    ap.add_argument("--height", type=int, default=0, help="目标高度（0=不缩放）")
    a = ap.parse_args()

    if a.dir:
        files = sorted(glob.glob(os.path.join(a.dir, "*.png")))
        names = [n for n in a.names.split(",") if n] if a.names else \
            [os.path.splitext(os.path.basename(f))[0] for f in files]
        for f, n in zip(files, names):
            process(f, a.height, a.out, a.prefix + n)
        print("共处理 %d 个 -> %s" % (len(files), a.out))
    elif a.file:
        process(a.file, a.height, a.out, a.name)
    else:
        ap.error("需要 --dir 或 --file")


if __name__ == "__main__":
    main()
