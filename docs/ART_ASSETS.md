# 《都市浮生》美术资源清单

更新日期：2026-09-12

## 场景背景

当前已生成并用于/准备接入的主要场景图：

- 雨夜玻璃大厦入口.png
- 雨夜加班的静谧办公室.png
- 雨夜里的温馨杂居公寓.png
- 雨夜街角的温暖灯火.png
- 雨夜公园凉亭与棋桌.png
- 雨夜地铁站的静谧候车时光.png
- 雨夜高楼会议室.png
- 雨夜摩登行政办公室.png
- 雨夜温暖便利店.png
- 雨夜暖光咖啡馆一隅.png
- 夜行地铁里的静谧通勤者.png
- 雨夜温馨诊室全景.png
- 雨夜灯影下的静谧病房.png
- 雨后霓虹 rooftop 城市夜景.png
- 雨夜霓虹巷院与暖灯倒影.png

Godot 当前主要资源映射：

```text
assets/backgrounds/dialogue/city/street_corner_rain_night.webp
assets/backgrounds/dialogue/transport/subway_platform_rain_night.webp
assets/backgrounds/dialogue/company/company_entrance_rain_night.webp
assets/backgrounds/dialogue/life/park_pavilion_rain_night.webp
assets/backgrounds/dialogue/life/convenience_store_rain_night.webp
assets/backgrounds/dialogue/life/cafe_rain_night.webp
assets/backgrounds/dialogue/hospital/clinic_room_rain_night.webp
assets/backgrounds/dialogue/city/rooftop_rain_night.webp
assets/backgrounds/dialogue/city/old_alley_rain_night.webp
```

## 角色美术

主要角色资源：

- 动漫风格十人角色阵容立绘.png
- 三阶段男主角表情与动作图鉴.png
- 五人日常角色立绘合集.png
- 都市浮生_多角色成长图鉴.png
- 六位都市生活角色立绘合集.png
- 雨城六人角色精灵图.png
- 透明背景办公男角色精灵图表.png
- 疲惫上班族角色立绘表.png

## 游戏内精灵

当前 Godot 已有/使用：

```text
assets/characters/sprites/gameplay/protagonist_walk_4x4.png
assets/characters/sprites/prototype/protagonist_walk_candidate.png
assets/characters/sprites/prototype/xiaoyu_walk_candidate.png
assets/characters/sprites/prototype/chenjie_walk_candidate.png
assets/sprites/npcwalk_xiaoyu.png
assets/sprites/npcwalk_chenjie.png
assets/sprites/npcwalk_laozhang.png
assets/sprites/npcwalk_laozhou.png
assets/sprites/npcwalk_daoshi.png
assets/sprites/npcwalk_azhe.png
```

## 当前视觉问题

1. 主角与半写实背景比例不统一。
2. 人物边缘过干净，缺乏环境色。
3. 无脚底接触阴影时会产生“贴纸感”。
4. NPC 当前仍有文字按钮式表现。
5. 场景遮挡层尚未建立。
6. 部分旧资源文件名乱码，CI 导入会报 Unicode 警告。

## 近期美术整合方向

- 人物整体缩小约 20–30%
- 添加椭圆软阴影
- 雨夜冷色环境调制
- 暖光区域局部加暖
- Y 排序实现前后关系
- 花坛、栏杆、路灯等建立前景遮挡层
- NPC 使用真实角色精灵而不是按钮
- 统一主角与 NPC 的切图标准

## 美术包保存建议

代码与文档适合直接放 GitHub。

原始大尺寸 PNG、PSD、生成过程图建议：

1. 保留一份完整 ZIP 归档；
2. 游戏真正使用的压缩 WebP/PNG 放入 `assets/`；
3. 超大 PSD/源图不要频繁直接提交普通 Git 历史，优先使用 Git LFS 或单独 Release/云盘备份；
4. 每张正式资源使用英文/ASCII 文件名，中文标题记录在本清单，避免跨平台编码问题。
