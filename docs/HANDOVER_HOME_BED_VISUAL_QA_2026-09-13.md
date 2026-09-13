# 出租屋床铺视觉 QA：交接说明（2026-09-13）

## 当前范围与结论

本轮只处理出租屋（`home`）的“床 → 睡觉”视觉链路；没有继续扩展书桌、厨房、房门或其他地图。业务逻辑（时间、体力、存档、活动结算）没有改动。

默认运行方案仍是 **legacy 床组**：

- 睡姿：`res://assets/characters/sprites/interactions/protagonist_sleep_side_v6.png`
- 被子：`res://assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png`

候选资源、背景提取 v2、局部背景提取 v3 均已保留在仓库内，但开关默认均为 `false`，不能视为视觉验收通过。

用户的视觉判断是：大面积整床前景被子是错误方向，不能继续用缩放、旋转或偏移硬修；横向睡姿方向本身比“整床覆盖”更接近正确方向。当前未解决的最大问题仍是**睡姿素材下缘/腿部与原床局部遮挡之间的边缘融合**，而不是交互逻辑或坐标空间。

## Git 基线

- 基础程序层 checkpoint：`41cb5a7 feat: first pass character environment interaction integration`
- 本次提交在该 checkpoint 之后，包含床铺视觉 QA 资源、开关、提取工具与本文件。
- 当前分支：`main`；远端：`origin`（GitHub `weiweng17/citylife-game`）。

## 运行环境

- 可用：Godot `4.7.2`（`F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`）。
- 不可用：本机 Godot `4.5` 会立即出现 Windows memory-read 崩溃弹窗；不要用它做验收。
- 4.7.2 可完成 headless 验证和画面截图。截图脚本在 OpenGL 退出阶段偶有 signal 11，但在此之前 PNG 已成功写出；应把它当作环境/退出问题继续观察，而不是把截图脚本通过等同于视觉通过。

## 架构与坐标约定

### 交互链路

`HomeActivities.gd` 定义床锚点 → `LocationManager.gd` 让站立角色走到床边并锁定活动 → `HomeInteractionVisual.gd` 渲染睡姿、局部遮挡和程序 Zzz → 活动结束后恢复床边的自由移动。

- `position` / `approach_position`：角色**脚底中心**的可行走 LocationView 坐标。
- `sleep_position`：睡姿视觉中心，处于同一 LocationView 坐标空间，不能与父节点 local 坐标混用。
- `sleep_head_position`：程序 Zzz 的世界位置，不绑定到床中央。

当前床锚点在 `scripts/systems/HomeActivities.gd`：

```gdscript
"position": Vector2(430, 330),
"sleep_position": Vector2(255, 412),
"sleep_head_position": Vector2(156, 369)
```

### 正式背景标定

- 原始背景：`res://assets/backgrounds/dialogue/home/rental_apartment_rain_night.webp`
- 原始分辨率：`1672 × 941`
- 画面床范围（原图估计）：`x=0..510, y=330..650`
- 枕头中心（原图估计）：`(185, 430)`
- 1280×720 LocationView 中的睡姿头部目标约：`(142, 329)`
- v2 提取区域：原图 `(100, 390, 470, 280)`，它过大，形成“第二张床”。
- v3 提取区域：原图 `(300, 480, 190, 90)`，只针对腰/腿局部；其目标是压住身体局部，绝不是新床或新枕头。

## 文件清单

### 程序与工具

- `scripts/world/HomeInteractionVisual.gd`
  - 默认 legacy 床组；候选/v2/v3 三套仅用于 A/B。
  - 没有最终画面 Debug Polygon；被子均以透明纹理 Sprite2D 渲染。
  - `set_candidate_bed_group`、`set_background_blanket_v2`、`set_background_blanket_v3` 是测试开关。
- `scripts/systems/HomeActivities.gd`：床交互锚点、睡姿/头部坐标语义。
- `scripts/systems/LocationManager.gd`：睡眠显示/恢复、脚底中心、接触阴影、暖光、Y/depth 遮挡衔接。
- `tools/capture_activity_props.gd`：可通过参数输出 A/B 截图。
- `tools/inspect_home_background.gd`：背景尺寸和床区域检查，输出 QA 裁图。
- `tools/extract_home_bed_blanket_v2.gd`：过大范围的历史提取方案，仅作对照。
- `tools/extract_home_bed_blanket_v3.gd`：局部遮挡提取方案，仅作对照。
- `tools/verify_home_presentation.gd`、`tools/verify_home_activities.gd`：程序回归验证，不能代替视觉验收。

### 视觉资源

可作为当前默认回退：

- `assets/characters/sprites/interactions/protagonist_sleep_side_v6.png`
- `assets/backgrounds/interactions/home_bed_blanket_foreground_v1.png`

保留但默认关闭：

- `assets/characters/sprites/interactions/protagonist_sleep_side_candidate_v1.png`
- `assets/characters/sprites/interactions/protagonist_sleep_enter_candidate_v1.png`
- `assets/characters/sprites/interactions/protagonist_wake_up_candidate_v1.png`
- `assets/backgrounds/interactions/home_bed_blanket_foreground_candidate_v1.png`
- `assets/backgrounds/interactions/home_bed_blanket_foreground_v2.png`
- `assets/backgrounds/interactions/home_bed_blanket_foreground_v3.png`

`*_candidate_v1` 来自新美术包，和正式出租屋背景在画风、像素密度与透视上不一致；尤其 candidate 被子含完整床面/枕头感并可能自带睡眠符号，不能直接启用。

## 已验证与截图

以 Godot 4.7.2 headless 完成的程序回归：

- `res://tools/verify_home_presentation.gd`：通过。
- `res://tools/verify_home_activities.gd`：通过。
- `res://tools/verify_home_edges.gd`：`6252 checks, 0 failures`。

实际图形运行使用 `capture_activity_props.gd`，本地截图目录（被 Git 忽略）：

- `build/qa/home_prop_rest_legacy.png`
- `build/qa/home_prop_rest_candidate.png`
- `build/qa/home_prop_rest_background_v2.png`
- `build/qa/home_prop_rest_background_v3.png`

截图开关：

```powershell
# legacy 默认
...Godot_v4.7.2-stable_win64_console.exe --path <repo> -s res://tools/capture_activity_props.gd
# 资源包候选
... -s res://tools/capture_activity_props.gd -- --candidate-bed-group
# 背景提取 v2 / v3
... -s res://tools/capture_activity_props.gd -- --background-blanket-v2
... -s res://tools/capture_activity_props.gd -- --background-blanket-v3
```

## 给下一位开发者的执行边界

1. 先真实查看 legacy、v2、v3 截图，再改动；不要将脚本绿灯当作视觉通过。
2. 不要重新启用 candidate 整床被子，也不要用大面积半透明贴图覆盖床。
3. 不要同时更换睡姿和被子。下一步应先决定/修复睡姿下缘 alpha 与腿部轮廓，再用原背景同纹理、极小范围的局部遮挡验证。
4. 不要通过大量 `position` / `scale` / `rotation` 魔法数字去修素材结构问题；维持脚底中心坐标体系。
5. Zzz 必须只有程序这一套，且从 `sleep_head_position` 附近出现；禁止含有自带 Zzz 的正式素材。
6. 继续限于出租屋床铺，直到视觉通过；不要迁移到其他家具或地图。
7. 若局部遮挡仍无法与烘焙背景无缝融合，应明确提出需要美术提供的资源：从正式背景原床拆出的透明“腰腿前景被子边缘”，不含整床、枕头、人物、Zzz 或背景。

## 当前完成度

- 程序闭环（走到床边 → 睡姿/局部前景/Zzz → 时间结算 → 起床回床边）：已存在并回归通过。
- 默认回退方案：已可用。
- 候选素材 A/B 与背景局部提取实验：已保留且可切换。
- 床铺视觉验收：**未通过，状态为 MIXED**。
- 下一步优先级：**素材清理/正式背景拆层**，而非继续改业务程序或其他地图。
