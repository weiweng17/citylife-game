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
| `NPCScheduleSystem.gd` | NPC 日程推进（对应 `data/npc_schedules.json`）——决定某时某地有谁在 |
| `NpcRelations.gd` | **NPC 关系**：每人一条好感值（0–100），**每天只有第一次交谈**加 4 分；档位 陌生人/认识/熟络/朋友，升档给一次心情回补与一句叙述。纯逻辑，不碰 UI，不落盘（状态存在 `GameState.relations` / `talk_day`，随存档走） |
| `JobGrowth.gd` | **工作技能成长**：五个手艺档（学徒/上手/熟练/骨干/独当一面）决定时薪；上班攒熟练度，攒够涨一点技能；「谈薪」要熟练档，成败看技能+人脉，老张熟络会降门槛。**全静态、无状态**，数字都从调用方传进来，不碰 UI、不落盘（状态存在 `GameState.work_exp` / `raise_steps` / `raise_day`） |
| `QuestSystem.gd` | **主线任务**（内容在 `data/quests.json`）：一次一条、串行推进，`next` 接链。**无限时、无失败态、条件全是单调量**，所以不会形成死路。`validate()` 在加载时体检内容（步骤类型写错＝不报错的死路）。进度存 `GameState.quests`，`done` 标记保证奖励只发一次。计数由 `Game` 在结算点喂（只对当前激活任务生效） |
| `EventSystem.gd` | 事件池与触发（`data/events.json`，运行时加载 69 个事件） |
| `EncounterSystem.gd` | 随机遭遇（`data/encounters.json`，8 个） |
| `StorySystem.gd` | 主线剧情推进 |
| `DarkLocationSystem.gd` | 暗线地点与结局分支 |
| `InteractionSystem.gd` | 场景内可交互物件的统一入口 |

### 3. `scripts/ui/`——只读视图，通过信号向 `Game` 提请求

| 文件 | 职责 |
| --- | --- |
| `HUD.gd` | 顶部状态条：年龄/阶段/时间/天气/钱、健康·心情·饱食·精力四条、技能与手艺档位、今日目标、背包按钮、存读档与退出 |
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
7. **同名节点重建要 `remove_child` 再 `queue_free`。** `queue_free()` 只是**标记**，节点要到帧末才真的离开树；若只 `queue_free()`，同一帧内 `get_node("同名")` 仍会拿到那个待删除的旧节点（`LocationManager._clear_npcs` 就踩过：NPC 热点重建后悬停标签还显示旧档位）。测试里若按名字找子节点，也应跳过 `is_queued_for_deletion()` 的。
8. **NPC 关系只在 `Game._on_dialog_finished` 结算。** 关系系统（`NpcRelations.gd`）是纯函数式的 `RefCounted`，不挂树、不落盘；谁加好感、加多少、什么时候算"新的一天"都由 `Game` 决定，避免对话中途退出也照加。
9. **"够不够格"的判定在 `Game`，交互层只管显不显示。** 谈薪要熟练档，`OfficeActivities` 只把不够格的那个按钮藏起来——判定与结算都在 `Game._do_negotiate()`。`Game` 把展示需要的数字（时薪、档位名、能不能谈、今天谈过没）通过 `sync_context()` 每帧喂给交互层，交互层**不自己去读 `GameState`**。
10. **交互层的展示值由 `Game._refresh_ui()` 推，所以测试冻结 `Game._process` 之后必须手动推一次**（`main._refresh_ui()`），且按钮的显隐是在交互层自己的 `_process` 里刷的——`process_frame` 信号在节点处理**之前**发出，只 `await process_frame` 一帧会断言在"刚改完、还没刷"的空档上，要等两帧。
11. **任务进度只读不改，奖励只在 `Game` 发。** `QuestSystem.evaluate()` 会自己推进进度并返回事件列表，但钱/心情的发放归 `Game._apply_quest_reward()`。计数走 `notify()`，**只对当前激活的任务生效**（q1 期间买的东西不替 q3 记账，是刻意的）——以后若要做多任务并行，这条必须重审。
12. **HUD 不加行。** 高度被地点标题的偏移量盯死；任务接在目标那一行后面（`目标：… ｜ 任务：…`）。提示（toast）也一样：任务提示用 `append=true` 接在结算提示下面，别顶掉玩家刚看到的数字。

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
| 3. NPC 与成长 | **代码完成，待人工验收**。已完成：NPC 实体化与交谈、日程热点、关系反馈、工作技能成长（分档时薪/攒熟练度/谈薪）、首批连续任务（3 条串行主线）。 |
| 4. 扩展地图与内容 | 未开始。每张新图须先过出生点/出入口/热点连通与遮挡检查再开放 |
| 5. 完整首版打磨 | 未开始 |

**第 3 阶段代码已全部落地**，剩人工试玩验收；之后进第 4 阶段（扩展地图与内容）。

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
| 改 NPC 好感档位/每日上限/升档文案 | `scripts/systems/NpcRelations.gd`（`DAILY_GAIN` / `TIERS` / `MILESTONES`）；"新的一天"判定与结算时机在 `Game.gd` 的 `_on_dialog_finished` |
| 改时薪/手艺档位/上班涨技能的快慢 | `scripts/systems/JobGrowth.gd`（`TIERS` / `WORK_EXP_PER_SHIFT` / `exp_needed()`） |
| 改谈薪的门槛或条件 | `scripts/systems/JobGrowth.gd`（`NEGOTIATE_SKILL` / `NEGOTIATE_SCORE` / `FRIEND_RELATION`）；文案与结算在 `Game.gd` 的 `_do_negotiate` |
| 加工位上的新互动点 | `scripts/systems/OfficeActivities.gd` 的 `SPOTS`（`requires_skill` 可做成技能门槛，按钮会自己藏起来） |
| 加/改主线任务 | `data/quests.json`（`QuestSystem.STEP_TYPES` 之外的类型会被 `validate()` 拦下）；计数型步骤记得在 `Game.gd` 的结算点补 `quest_sys.notify()` |
| 加一条自动测试 | 在 `tools/` 新建 `extends SceneTree` 的 `verify_*.gd`（**`extends Node` 的脚本不能用 `--script` 跑**） |
| 出截图 | `tools/capture_*.gd`，输出到 `build/qa/` |

跑测试与复测命令清单见 `docs/QA_2026-09-13.md` 末尾。
