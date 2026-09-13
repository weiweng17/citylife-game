# 《都市浮生》开发交接报告

写于 2026-09-13 晚。**读者对象：接替开发的 AI（或人类开发者）。**
本文自包含：读完这一篇 + 仓库里的 `HANDOFF.md` / `docs/ARCHITECTURE.md` / `docs/ITERATION_PLAN.md` / `docs/QA_2026-09-13.md`，就可以直接开工。

---

## 1. 项目概况（一段话）

《都市浮生》是一款 Godot 4.5 / GDScript 的 2.5D 生活模拟游戏（1280×720，GL Compatibility），基调参照国产独立游戏《众生》：普通人的日常质感、文学化的结算文案（数值放括号里）、需求与情绪的起伏。玩家扮演 22 岁初到城市的年轻人，在出租屋-地铁站-公司-便利店-公园-咖啡馆-医院-旧巷-天台九张地图里过"以分钟计"的日子：上班攒手艺、谈薪、交朋友、做任务、管理饱食与精力。**当前状态：第 1–3 阶段代码全部完成，第 4 阶段五张新地图场景扩展收官 + 交互层基类重构完成；19 套自动化测试全绿；只欠人工试玩验收与第 4 阶段的事件/经济收尾。**

- 仓库：`D:\打工人模拟器\citylife-game-github`（唯一开发源，所有改动留 D 盘）
- 远程：`https://github.com/weiweng17/citylife-game.git`（推送触发 GitHub Actions 自动导出 Web 并发布 Pages）
- 当前 HEAD：`ed2065d`，工作树干净，**本地 `main` 领先 `origin/main` 38 个提交**——接手第一件事提醒用户双击 `tools\push-local.cmd` 同步（AI 环境推不上去，原因见 §2）。

## 2. 环境要点（AI 接手必读，坑都在这）

- **Godot**：本会话实际使用 `C:\Users\86139\.workbuddy\binaries\godot\Godot_v4.5-stable_win64_console.exe`（项目文档里写的 `F:\Downloads\Godot_v4.7.2...` 在沙箱里未验证过；4.5 跑项目无警告）。接手后先用手头引擎跑一遍回归确认。
- **Bash 工具不可用**，一律用 PowerShell；PowerShell 不回显 stdout，输出要 `Out-File`/`WriteAllLines` 到临时文件再读。
- **git 不在 PATH**，用完整路径 `C:\Users\86139\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe`；提交需 `-c user.name=... -c user.email=...`；**提交信息一律英文**（PowerShell 向 git 传中文 `-m` 会乱码，踩过）。
- **AI 环境推不了远程**：harness 替换子进程 PATH，凭据助手找不到 git。同步 = 提醒用户双击 `tools\push-local.cmd`。
- 无头测试：`& $godot --headless --path . --script res://tools/verify_xxx.gd`，看退出码（0=过）。
- 截图/开窗：`& $godot --path . --rendering-method gl_compatibility --script res://tools/capture_xxx.gd`，输出到 `build/qa/`（被 git 忽略）。
- `extends Node` 的工具脚本不能用 `--script` 跑（会挂住）；能跑的是 `extends SceneTree` 的。
- 用户双击即可试玩：`tools\play-local.cmd`（或桌面 `E:\Desktop\都市浮生-试玩.bat`）。

## 3. 架构速览

详见 `docs/ARCHITECTURE.md`。核心分层：

- **`Game.gd`（唯一协调者）**：所有数值结算都在这里（`_on_home_activity` / `_do_work_shift` / `_do_negotiate` / `_on_cafe_activity` / `_on_hospital_activity` / `_on_alley_activity` / `_on_rooftop_activity`…）。活动脚本自己不扣钱不涨属性——这是模块边界第 1 条，别破坏。
- **活动结算脚手架**：`Game._begin_activity()` / `_end_activity()` 统一"锁输入→进度 10×0.12s→结算→解锁"，所有场景活动都走它，`blocked` 闸门在 `_process` 里按 `ui_busy` 统一写。
- **`SpotActivities.gd`（交互层基类）**：八个 `*Activities.gd`（home/office/store/park/cafe/hospital/alley/rooftop）的公共骨架。子类只答五个钩子：`_define_spots()` / `_location_id()` / `_layer_name()` / `_idle_prompt()` / `_approach_word()`；可选展示钩子 `_label_of` / `_detail_of` / `_spot_available` / `_sync_display`。**`SPOTS` 是基类实例变量**，外部按 `xxx_activities.SPOTS` 只读。**新场景互动 = ~30 行子类 + Game 三处接线**（preload+var、`_ready`、`_process` 闸门 + 两把活动锁 + 结算函数）。
- **系统层（纯逻辑，状态存 `GameState`，随存档走，不加新存档键）**：`DailyRoutine`（每日四目标）、`Inventory`（物品目录唯一出处）、`NpcRelations`（好感 0–100，每天首聊 +4，四档位）、`JobGrowth`（五档手艺定时薪、上班攒熟练度、谈薪门槛确定性判定）、`QuestSystem`（`data/quests.json` 串行主线，无限时无失败态，奖励只发一次）、`NPCScheduleSystem`（`data/npc_schedules.json`）。
- **场景/表现层**：`LocationManager`（九张图、`NAVIGATION` 阻挡、`OCCLUDERS` 前景遮挡、`NPC_LOCATION_POS`）、`LocationNavigation`（A*）、`ActivityProp`（手部道具）、`MoveMarker`（落点反馈，z=1905）、HUD/ShopUI/DialogUI。

### 历代踩坑速查（完整版在 HANDOFF.md，这里是最容易复发的）

1. `queue_free()` 帧末才离树——同名节点重建要 `remove_child` 再 `queue_free`。
2. 交互层 `layer.visible` 在它自己的 `_process` 里按地点开——切图后要等它亮再 `_activate`，否则静默返回（测试里用 `_wait_for_layer()` 轮询）。
3. 冻结 `Game._process` 的测试必须先手动跑一次 `main._process(0.0)` 让闸门落定；`process_frame` 信号在节点 `_process` 之前发出，按钮显隐要等两帧。
4. 测试/截图脚本跳时间后要重置 `main._last_total_minutes`，否则那一跳会被需求系统当成真实流逝时间扣饱食精力。
5. 截图等 `activity_running` 落下再等 4 帧，不要数帧数。
6. 提示行 y=580（底部面板 y=608 起）；按钮别用 `flat=true`；`MoveMarker.z_index=1905`。
7. 无头模式下子类继承新类用**路径式 extends**（`extends "res://..."`），class_name 形式会因全局类缓存未收录而解析失败。
8. 站位标定五步清单：美术原图换算 1280×720 → 查 `NAVIGATION` blocked → 查 `OCCLUDERS` 下缘 → 查按钮布局（站位+(-58,16)，116×30）→ verify 实走断言。**连续四个单元首跑零返工**。

## 4. 已完成内容（按阶段）

| 阶段 | 状态 | 内容 |
| --- | --- | --- |
| 1 出租屋可玩样板 | ✅ 代码完成 | 多边形碰撞、A* 点击绕障、键盘滑墙、贴边实走复核（6252 项 0 失败）、死区封堵、前景遮挡、活动道具反馈、交互质感（落点涟漪/暗色胶囊/文学化文案） |
| 2 完整的一天 | ✅ 代码闭环 | 每日四目标、通勤计时、公司上班、需求系统（饱食/精力按真实分钟消耗+告急独白）、便利店购买与背包、夜里睡整夜跨天结算、存档 payload 化（读档不丢需求） |
| 3 NPC 与成长 | ✅ 代码完成 | NPC 日程热点+交谈、关系四档位（每天首聊 +4）、五档手艺定时薪+上班攒熟练+谈薪（老张降门槛，确定性判定）、三条串行主线任务（先站稳脚→老张的提醒→有人等你回家） |
| 4 扩展地图与内容 | 🔶 场景扩展收官 | 公园（长椅歇脚/池塘看雨）、咖啡馆（点咖啡 15 元/发呆）+阿哲午间日程、医院（看病 50 元/候诊椅）、旧巷（上香 5 元/木门歇脚）、天台（看夜景/吹风）；交互层八份模板收敛为 `SpotActivities` 基类 |
| 5 完整首版打磨 | ⬜ 未开始 | 动画/音效/引导/性能/打包（项目目前**无任何音频资源**） |

主要提交锚点：`4389231`（阶段 2 收尾）→ `53a06cb`/`b764121`/`4709122`（阶段 3 三单元）→ `75052d7`/`5c48872`/`b1fd2bb`/`44c1b77`（阶段 4 场景四连）→ `af2aa88`（SpotActivities 基类）→ `ed2065d`（文档）。

## 5. 测试体系（改动前先跑，改完必须全绿）

**19 套全员回归**（无头，全部 `exit=0` 才算过）：

```powershell
$godotExe = '<你的 Godot 控制台版 exe>'
Set-Location 'D:\打工人模拟器\citylife-game-github'
foreach($t in @('verify_park','verify_cafe','verify_hospital','verify_alley','verify_rooftop','verify_quests','verify_job_growth','verify_npc','verify_needs','verify_daily_routine','verify_store','verify_day_cycle','verify_day_flow','verify_locations','verify_navigation','verify_home_activities','verify_home_edges','verify_onboard','verify_dark')){
  & $godotExe --headless --path . --script "res://tools/$t.gd"; "=> $t exit=$LASTEXITCODE"
}
```

关键数字：navigation `6646 项 0 失败`、home_edges `6252 项 0 失败`。另有 `verify_home_input`（真实鼠标键盘，须开窗跑）与 13 个 capture_* 截图工具（视觉抽查用）。**废弃注意**：`verify.gd` 退出码 2 是刻意的废弃标记；`verify_art/hud/interior/layout/min` 是 `extends Node` 不能用 `--script` 跑。

开发节奏惯例：15–30 分钟一个小单元 → 测试 → 更新 HANDOFF.md/QA 文档/ITERATION_PLAN → 本地提交（英文信息）→ 继续下一单元。**行为改动靠测试锁，重构单独立单元不混功能提交。**

## 6. 已知债务与限制（如实，别当已完成）

- **第 2、3 阶段的人工试玩验收一直欠着**：任务文案顺不顺、节奏观感、HUD 长度，自动测试替代不了。建议接手后尽早推动用户双击试玩。
- 五张新地图与**事件系统、任务链没有交叉**：没有"生病送医院"这类连接；旧巷道士还是夜里的旧台词；公园路人对话也是旧的。
- 经济平衡没验证过：咖啡馆咖啡（15 元+15 精力）vs 便利店罐装（8 元随身）、看病（50 元+25 健康）vs 睡觉（免费+12）、上班攒手艺 vs 回家读书；谈薪门槛 95 只在自动测试里验过。
- `Rules.gd` 年度经济与分钟循环经济**两套并存未打通**（阶段 2 遗留）。
- 姿态/音效缺位：活动是行走动画定格+程序化道具；项目无音频资产。
- 天台"看夜景"站位在屋顶中部（非最前沿栏杆）；各场景站位仍是粗略标定，未逐帧对照美术。
- 根目录 `citylife_WEB001_SourceUpload.zip`（~10MB）被 git 跟踪，待用户批准后清理。

## 7. 下一步规划（建议优先级）

**P0 —— 打通与验收（让"能玩"变成"好玩"）**
1. 推动用户做第 2、3 阶段人工试玩验收；问题清单回来后修。
2. 扩展事件与经济平衡：把医院/咖啡馆/公园接进事件系统（如连续低健康触发"生病"事件引导去医院）；为五张新地图各写 1–2 个事件或遭遇；跑一次"一天 24 小时怎么过最划算"的数值核算。

**P1 —— 内容深化**
3. 任务链第二章（利用新地图：如阿哲线——去咖啡馆找他、天台看夜景触发歌词事件）；公园路人、旧巷道士对话按场景重写。
4. NPC 日程扩容：让更多 NPC 出现在新地图（日程表+`NPC_LOCATION_POS` 各加一条即可）。

**P2 —— 阶段 5 打磨**
5. 活动专属姿态动画；音频资产到位后补音效；引导文案更新（新地图解锁提示）；Web/桌面导出验证；长流程回归。

## 8. 给接手 AI 的三句话

1. **先跑一遍 19 套回归再动代码**；动完再跑一遍，全绿才算完。
2. **改哪都要先读 `HANDOFF.md` 对应小节**——里面的坑都是真实踩出来的，别不信邪。
3. 每个单元：测试 → 文档 → 提交，工作树永远保持干净；推送只提醒用户双击 `tools\push-local.cmd`，自己别硬试。
