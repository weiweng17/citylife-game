# ChatGPT 接管开发记录（2026-09-13）

## 基线

- 仓库：`weiweng17/citylife-game`
- 开发分支：`chatgpt-dev`
- 分支基线：`4206185f495421a4b117ebecfb64561e87accccd`
- `main` 暂不承载后续开发修改；新开发先在 `chatgpt-dev` 验证。

## 当前技术决策

出租屋“床 -> 睡觉”已经证明：在已烘焙半写实背景上继续用独立角色 Sprite + 大量前景被子/offset 强行合成，视觉收益过低。

因此复杂交互采用两层表现：

1. 地图层仍负责走动、寻路、锚点与交互触发；
2. 复杂动作采用全屏动漫式 `InteractionCutin` 演出；
3. 时间、体力、金钱、存档、任务等业务结算仍由原有 `Game.gd` 负责，不迁移到 Cut-in。

## 第一版实现

新增：`scripts/ui/InteractionCutin.gd`

并在 `project.godot` 注册为 Autoload：

```ini
[autoload]
InteractionCutin="*res://scripts/ui/InteractionCutin.gd"
```

当前只接入 `home:bed`，它读取已有 `Game.activity_running`、`LocationSys.current_location` 与 `LocationSys.interaction_anchor.interactionType`，因此无需修改现有活动结算逻辑。

正式完整 Cut-in 资源约定路径：

`res://assets/cutins/home_sleep_v1.webp`

如果资源尚未放入项目，系统自动退回到“现有出租屋背景 + 旧睡姿”原型，因此不会因为缺图而阻断项目启动。

## 当前验收目标

本轮只验收出租屋床铺：

`点击床 -> 自动走近 -> 活动开始 -> Cut-in 淡入 -> 原有休息结算 -> Cut-in 淡出 -> 返回地图`

暂不扩展书桌、厨房、办公室、便利店、地铁等复杂交互，直到床铺 Cut-in 的运行节奏和 UI 风格通过。

## 后续资源规划

完整 Cut-in 统一使用 1280x720 / 16:9：

- `home_sleep_v1.webp`
- `home_study_v1.webp`
- `home_cook_v1.webp`
- `home_phone_v1.webp`
- `office_work_v1.webp`
- `store_shop_v1.webp`
- `subway_ride_v1.webp`
- `restaurant_eat_v1.webp`

后续接入时优先扩展 `InteractionCutin.PRESENTATIONS`，而不是在各场景复制一套 UI 逻辑。
