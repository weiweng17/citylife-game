# 《都市浮生》代码结构与模块说明

本文回答三个问题：**仓库里各个文件夹是干什么的、各个模块负责什么、开发按什么顺序推进。**
面向接手人；读完本文再读 `HANDOFF.md` 与最新的 `docs/TODAY_HANDOFF_<日期>.md`。

技术栈：Godot **4.7.2 stable**，GL Compatibility，1280×720，`canvas_items` 拉伸，界面字体 `assets/fonts/GameCN.ttf`。主场景唯一入口是 `scenes/Main.tscn`（见 `project.godot` 的 `run/main_scene`）。

---

## 一、目录结构

### 仓库根目录

| 路径 | 作用 |
| --- | --- |
| `project.godot` | Godot 工程配置：主场景、分辨率、渲染后端、字体 |
| `scenes/Main.tscn` | **唯一入口场景**，把 `Game.gd` 挂起来，其余一切由代码在运行时构建 |
| `scripts/` | 全部 GDScript，分四层（见第二节） |
| `data/` | 纯数据 JSON：事件、职业/结局规则、遭遇、NPC 日程、美术目录 |
| `assets/` | 美术与字体资源 |
| `tools/` | 开发期测试与截图脚本，**不进游戏运行时** |
| `docs/` | 计划、交接、QA、美术说明等文档 |
| `HANDOFF.md` | 项目长期状态与踩坑总账，**接手第一站** |
| `README.md` | 项目简介与文档索引 |
| `export_presets.cfg` | Web 导出预设 |
| `.github/workflows/deploy-web.yml` | 推送到 `main` 时自动导出 Web 并发布 GitHub Pages |
| `web-preview/index.html` | 源码迁入完成前的线上引导页 |

### 三个本地目录：**不要提交，也不要在里面改代码**

`.gitignore` 忽略以下三项，它们是本机产物，换台机器自然重建：

| 路径 | 说明 |
| --- | --- |
| `.godot/` | Godot 导入缓存、着色器缓存，删掉会自动重建 |
| `build/qa/` | 测试截图输出目录（`capture_*.gd` 写到这里） |
| `working-source/` | **早期脚手架的残留副本**（其自带 README 还写着 Godot 4.5 / 像素风 / 抖音小游戏，与当前版本无关）。它没有被 Git 跟踪，**改它不会生效，请忽略它**；确认无用后可自行删除 |

### 一个待清理项

仓库根目录的 `citylife_WEB001_SourceUpload.zip`（约 **10 MB**）是**已被 Git 跟踪**的历史上传包。它会拖大仓库体积，但因为删除属于改动用户文件，**未擅自处理**；确认无用后建议 `git rm --cached` 并加进 `.gitignore`。

---

## 二、模块职责

代码分四层，依赖方向是**上层调用下层，下层不反向依赖**：

```
data/*.json  ──►  scripts/systems/*   ──►  Game.gd（唯一结算中枢）  ──►  scripts/ui/*
                        │                        │
                        └── LocationManager ─────┴──► scripts/world/*
```

### 1. 根层 `scripts/`——中枢与静态数据

| 文件 | 职责 |
| --- | --- |
| `Game.gd`（约 42 KB，最大） | **全局中枢**。装配所有系统、持有玩家数值与背包、时间推进、活动结算、存读档、HUD 刷新。**所有数值结算只在这里发生** |
| `GameState.gd` | 可序列化状态容器（年龄、钱、健康、心情、饱食、精力、技能、旗标…），负责 `to_dict/apply_dict` |
| `Data.gd` | 静态内容：人生阶段 `STAGES`、出身 `ORIGINS`、引导文案 `TUTORIAL`、NPC 名单、暗线线索定义 |
| `Rules.gd` | 职业与结局规则（运行时日志：18 个职业 / 15 个结局） |
| `Events.gd` | 事件加载入口 |
| `ArtCatalog.gd` | 美术目录访问（对应 `data/art_catalog.json`） |
| `Player.gd` | 角色精灵与动画的薄封装 |

### 2. `scripts/systems/`——逻辑系统（无 UI）

| 文件 | 职责 |
| --- | --- |
| `LocationManager.gd`（约 30 KB） | **地点与移动**：九张独立地点场景的加载、玩家位置、脚下坐标与接地、A\* 点击绕行、键盘连续碰撞与滑墙、方向动画映射、前景遮挡与环境染色、互动反馈标签 |
| `LocationNavigation.gd` | 导航算法本体（可走多边形、路径查找、最近合法点） |
| `TimeManager.gd` | 游戏时钟：分钟推进、跨天 `day_changed`、暂停 |
| `WeatherSystem.gd` | 天气与时段 |
| `SaveManager.gd` | 存档文件读写（`user://savegame.json`） |
| `DailyRoutine.gd` | **每日目标**（通勤/工作/吃饭/休息），跨天重置。只跟踪一天之内，**不推进年龄** |
| `HomeActivities.gd` | 出租屋互动点：床/书桌/厨房/房门，距离校验、朝向、活动锁 |
| `OfficeActivities.gd` | 公司工位活动 |
| `StoreActivities.gd` | 便利店货架互动点 |
| `Inventory.gd` | **物品目录与持有数量**。名称/价钱/效果/描述**只定义在这一处**，面板与结算都读它 |
| `NPCScheduleSystem.gd` | NPC 日程推进（对应 `data/npc_schedules.json`）——第 3 阶段的主要落点 |
| `EventSystem.gd` | 事件池与触发（`data/events.json`，运行时加载 69 个事件） |
| `EncounterSystem.gd` | 随机遭遇（`data/encounters.json`，8 个） |
| `StorySystem.gd` | 主线剧情推进 |
| `DarkLocationSystem.gd` | 暗线地点与结局分支 |
| `InteractionSystem.gd` | 场景内可交互物件的统一入口 |

### 3. `scripts/ui/`——只读视图，通过信号向 `Game` 提请求

| 文件 | 职责 |
| --- | --- |
| `HUD.gd` | 顶部状态条：年龄/阶段/时间/天气/钱、健康·心情·饱食·精力四条、今日目标、背包按钮、存读档与退出 |
| `ShopUI.gd` | 一块面板两种用法：`open_buy` 货架 / `open_bag` 背包。买不起的行置灰 |
| `DialogUI.gd` | 对话 |
| `EventUI.gd` | 事件弹窗 |
| `StartUI.gd` | 开局选出身 |
| `EndingUI.gd` | 结局 |

### 4. `scripts/world/`——场景内实体

`WorldManager.gd`（地点内的物件/热点装配）、`NPC.gd`、`POI.gd`、`InteriorScene.gd`、`MoveMarker.gd`（点击落点反馈）、`ActivityProp.gd`（休息/学习/做饭/上班时手里的道具）。

---

## 三、模块边界约定（改代码前务必遵守）

这几条是踩过坑之后定下来的，破坏它们会引入难以定位的问题：

1. **数值结算只在 `Game.gd`。** 活动脚本（`HomeActivities` / `OfficeActivities` / `StoreActivities`）只负责距离校验、朝向、活动锁；UI 只负责显示与转发信号。活动脚本自己不扣钱、不涨属性。
2. **物品目录只写在 `Inventory.gd` 一处。** 否则货架价、背包价、结算价会对不上。
3. **`ui_busy` 闸门由 `Game._process()` 统一写。** `location.input_blocked` 与各活动脚本的 `blocked` 都被它赋值。**测试若提前 `set_process(false)`，闸门会停在旧值**（详见 `docs/QA_2026-09-13.md` 的偶发红灯一节）。
4. **活动层的 `layer.visible` 由各自 `_process` 按当前地点开关。** 切图后必须等它真的可见再 `_activate`，否则会静默返回，表现为"点了没反应"。
5. **动态创建的 UI 若挂在 `CanvasLayer` 上，不要用 `PRESET_FULL_RECT`**，要手动监听 `size_changed` 同步视口尺寸；且必须挂在 `UI` 层，否则会被 HUD 压住。
6. **每日/分钟循环与旧的年度人生事件严格分离。** 做一顿饭不能长一岁。

---

## 四、数据流

- **静态内容**走 `data/*.json` → 对应 System 在启动时载入（控制台会打印载入数量，便于核对）。
- **玩家状态**集中在 `GameState`，`Game` 暴露同名代理属性；UI 只读它。
- **输入**：地面点击/键盘 → `LocationManager` 算路径并移动 → 到达后由活动脚本发 `activity_requested` → `Game` 结算 → 刷新 HUD。
- **时间**：`TimeManager` 推进分钟 → `Game._sync_needs_to_time()` 按**真实流经分钟**扣饱食/精力（不要用 `hour_changed` 信号扣，它在一次 `advance_minutes` 里只发一次）。
- **存档**：`Game.build_save_payload()` / `apply_save_payload()`。读档会重置需求基准，避免把时间跳变当成真实流逝去扣需求。

---

## 五、文档地图（哪份文档说了算）

| 文档 | 权威范围 |
| --- | --- |
| `HANDOFF.md` | **长期状态与踩坑总账**。接手第一站，始终反映工作树真实状态 |
| `docs/ITERATION_PLAN.md` | **开发规划的唯一权威**：五阶段范围、验收标准、任务勾选状态 |
| `docs/TODAY_HANDOFF_<日期>.md` | 当日交接索引：检查点、当天提交、当天踩的坑、下一优先级 |
| `docs/QA_<日期>.md` | 当日逐套测试的实测数字、限制、复测命令 |
| `docs/ARCHITECTURE.md` | 本文：目录与模块职责 |
| `docs/ART_ASSETS.md` | 美术资源清单与接入说明 |
| `docs/DEVELOPMENT_PLAN.md` | **早期路线图，已非权威**。其中"已完成"只表示原型接入，不代表体验验收 |
| `docs/LOCAL_CODEX_HANDOFF.md` | 本地 Codex 工作流的接手说明 |

---

## 六、开发规划与当前进度

五阶段划分、每阶段试玩验收标准、任务勾选，全部以 **`docs/ITERATION_PLAN.md`** 为准。当前概况：

| 阶段 | 状态 |
| --- | --- |
| 1. 出租屋可玩样板 | 碰撞/可达/活动/道具已完成并有自动测试；**四向身体比例与动画接地、专属活动姿态与音效仍缺**（项目内无音频资源） |
| 2. 完整的一天 | **代码已闭环**（家→地铁→公司→便利店→回家→睡到次日），自动测试全绿；**只剩 20–30 分钟完整流程的人工试玩验收** |
| 3. NPC 与成长 | 未开始。仓库已有 `NPCScheduleSystem` 与 `data/npc_schedules.json` 作底子 |
| 4. 扩展地图与内容 | 未开始。每张新图须先过出生点/出入口/热点连通与遮挡检查再开放 |
| 5. 完整首版打磨 | 未开始 |

**下一步就是第 3 阶段**，建议顺序：NPC 实体化与交谈 → 日程与关系反馈 → 工作技能成长 → 首批连续任务。

---

## 七、常见任务"改哪里"速查

| 想做什么 | 改哪里 |
| --- | --- |
| 加一件便利店商品 | `scripts/systems/Inventory.gd` 的目录一处即可（面板与结算自动跟随） |
| 加一个可行走地点 | `LocationManager.NAVIGATION` 加配置 + `scenes/` 加背景 + `Game` 里挂载/解锁 |
| 改活动收益/耗时 | `Game.gd` 里对应的 `_on_*_activity` 结算分支 |
| 加一句生活化文案 | 结算文案在 `Game.gd` 各 `_on_*` 分支；引导在 `Data.gd` 的 `TUTORIAL` |
| 加事件/遭遇/职业结局 | `data/events.json` / `data/encounters.json` / `data/rules.json` |
| 调 NPC 日程 | `data/npc_schedules.json` + `scripts/systems/NPCScheduleSystem.gd` |
| 加一条自动测试 | 在 `tools/` 新建 `extends SceneTree` 的 `verify_*.gd`（**`extends Node` 的脚本不能用 `--script` 跑**） |
| 出截图 | `tools/capture_*.gd`，输出到 `build/qa/` |

跑测试与复测命令清单见 `docs/QA_2026-09-13.md` 末尾。
