# 《都市浮生》2026-09-12 开发交接索引

## 当前开发模式
推荐后续使用：本地 Codex + 本地 Godot 4.7.2 快速开发，本地验证后 push 到 `main`，GitHub Actions 自动导出 Web 并发布到 GitHub Pages。

固定试玩地址：
https://weiweng17.github.io/citylife-game/

## 今天已经完成的系统
- GameState 状态集中化
- HUD / DialogUI / EventUI 拆分
- EventSystem / StorySystem 拆分
- WorldManager / InteractionSystem
- TimeManager
- NPCScheduleSystem
- DarkLocationSystem
- EncounterSystem
- SaveManager
- WeatherSystem
- LocationManager 独立地点系统
- Web 自动构建与 GitHub Pages 发布

## 今天关键 Bug 修复
- `house` 与 `hasHouse` 状态键不一致
- 地点事件错误回退到全部事件
- Web 导出目录错误
- Godot 4.7 `minute_of_day` API 使用错误
- Variant 类型推导问题
- LocationManager 新游戏后仍隐藏导致灰屏
- Web CanvasLayer / Control viewport 尺寸导致场景不显示
- 便利店事件错误映射到 cafe，修正为 street

## 当前地图结构
居民区 → 地铁 → 公司 → 公园 / 便利店 → 咖啡馆 / 医院 → 老巷 / 天台等特殊地点。

后续应把“到达即解锁”升级成“剧情节点 / 关键行为解锁”。

## 当前视觉方向
场景：雨夜现代中国城市、半写实、电影感、非赛博朋克。

角色：动画化 2D，但需要通过缩放、脚底接触阴影、环境色、Y 深度、遮挡关系融入背景。

## 下一开发优先级
1. NPC 实体化：角色精灵 + 名字标签 + 点击互动
2. 场景 walk polygon / 可行走区域
3. 前景遮挡层
4. 地点交互热点
5. 触摸/移动端适配
6. 线上运行时调试信息
7. 剧情式地点解锁

## 美术资源
今天完整美术归档包含：
- 15 张核心场景背景
- 主角与 NPC 立绘/精灵图
- 行走动画候选图
- 城市地图图
- Godot 已接入 WebP / gameplay sprite 版本
- 美术资源清单与接入说明

大体积美术原图不建议直接塞进普通 Git 历史。推荐：代码/文档/游戏运行资源进 GitHub；高清原稿、PSD、批量生成图放独立美术资源包或 Git LFS / Release。

## 本地 Codex 注意事项
- Godot 版本：4.7.2 stable
- 对 Variant 返回值优先显式类型，不要滥用 `:=`
- 时间读取使用 `time_source.get_minute_of_day()`
- `LocationManager` 激活使用 `set_active(true)`
- Web 动态 UI 节点必须同步 viewport 尺寸
- 便利店事件池对应 `street`
