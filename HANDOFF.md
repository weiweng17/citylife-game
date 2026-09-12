# 都市浮生开发交接

更新时间：2026-09-13

## 唯一开发源

- 项目：`D:\打工人模拟器\citylife-game-github`
- 引擎：`F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- Godot：4.7.2 stable，GL Compatibility，1280×720
- 当前约束：只使用仓库内用户美术；借鉴开源功能代码但不套用外部美术包；所有开发留在 D 盘；未经用户允许不得推送远程。

## 接手顺序

1. 阅读本文件。
2. 阅读 `docs/ITERATION_PLAN.md` 和最新的 `docs/QA_*.md`。
3. 执行 `git status --short` 与 `git log -5 --oneline`，保留所有用户修改。
4. 先运行与当前任务直接相关的测试，再修改代码。
5. 每完成一个 15–30 分钟的小单元：测试、更新本文件、做本地提交；不要等整个阶段完成才记录。

## 当前稳定检查点内容

- 地点移动：脚底坐标、A* 点击绕障、键盘连续碰撞与滑墙，不可达目标不会跨墙。
- 出租屋：床、茶几、沙发、书桌/椅子、厨房/柜体使用多边形碰撞；四个家具互动点均可达。
- 家具活动：休息、学习、做饭、出门；支持点击标签自动走近及近距离按 E。
- 状态安全：活动不会重复结算；活动期间禁止旅行、事件、NPC、存读档和重开；结束后恢复输入。
- UI：地点按钮仅在状态变化时重建，避免按钮在点击时被每帧销毁；HUD 与地点标题已分离。
- 视觉：出租屋使用脚底阴影、环境染色和部分前景遮挡；床边及书桌指定站位截图已检查。

## 已验证

- `tools/verify_navigation.gd`：九张地图配置、每图 350 次低帧率位移、全部出租屋互动路径、键盘松开、不可达墙、多边形斜边。
- `tools/verify_home_activities.gd`：距离限制、防重复结算、时间与属性、出门切图；已含互动反馈显示/清理与床/书桌/厨房/房门四个朝向断言，以及活动道具显示/匹配/清理断言。
- `tools/verify_home_input.gd`：渲染窗口真实鼠标/键盘输入；该测试不能用 `--headless`。
- `tools/verify_locations.gd`：HUD、地点标题、居民区行动入口及原地图回归。
- 详细证据与限制见 `docs/QA_2026-09-12.md`。

## 2026-09-13 本地保存内容

- 保存提交：`2b1de0a feat: save home interaction feedback handoff`。
- 补跑提交：`58d8d1e test: assert door facing before travel resets pose`（仅改 `tools/verify_home_activities.gd`）。此后只改本文件提交号的提交不再逐条列出，最新号以 `git log -1 --oneline` 为准。
- 已改动：
  - `scripts/systems/HomeActivities.gd`：为出租屋床、书桌、厨房、房门互动点增加 `facing`，触发互动前让角色面向家具/出口。
  - `scripts/systems/LocationManager.gd`：增加方向到动画的统一映射、静止朝向接口、玩家头顶活动反馈标签；反馈标签挂在根层并跟随脚底坐标，避免随角色缩放变小。
  - `scripts/Game.gd`：休息/学习/做饭期间显示头顶活动反馈，结算后清理反馈。
  - `tools/verify_home_activities.gd`：增加互动反馈显示/清理断言，以及床/书桌/厨房/房门的朝向断言。
- 已验证：
  - 修改后已通过 `tools/verify_navigation.gd`：Navigation checks: 6630; failures: 0。
  - 修改后已通过一次 `tools/verify_home_activities.gd`，覆盖反馈显示/清理，但当时尚未加入朝向断言。
- 补跑结果（加入朝向断言后，2026-09-13 后续）：
  - 首次失败：`Door facing must point toward exit` 断言读到 `walk_down`。
  - 原因：`_activate("leave")` 先 `face_direction(Vector2(1, 0))` 转向右，`Game._on_home_activity` 随即切图，`_refresh()` 把动画复位成落地朝向 `walk_down`；断言测到的是落地朝向，不是房门朝向。
  - 处理：只改测试观测点，未改运行时行为。先用 `main.game_started = false` 拦住 `_on_home_activity` 的切图分支验证房门朝向，再放开验证切图；测试内已写注释说明。
  - 现状：四个断言全通过（rest/study/meal 朝向与一次结算、房门朝向、出门切到 subway）。同轮复跑 `verify_navigation.gd`（6630 项 0 失败）与 `verify_locations.gd`（九图全通过）均通过。
  - 已知限制：房门朝向在玩家侧几乎不可见——转身与切图在同一帧，切图后角色按落地朝向 `walk_down` 显示。等阶段 2 做“走到门口再出门”或跨场景保留朝向时再解决。

## 2026-09-13 后续：边缘实走复核与死区封堵

- 新增 `tools/verify_home_edges.gd`：沿出租屋全部碰撞轮廓外缘每约 26px 取贴边站位，逐点验证站得住、从出生点可走到、路径不穿家具，再沿轮廓真走一整圈；同时输出前景遮挡覆盖诊断。当前 6252 项 0 失败。
- 新增 `tools/capture_home_navmap.gd` 与 `tools/NavMapOverlay.gd`：渲染导航调试图到 `build/qa/home_navmap.png`（红=碰撞体、绿点=可走网格、黄点=站得住却走不到的死区、蓝点=互动站位）。
- 发现并修复三块死区（角色站得住、点击却走不到）：床头上方墙根、床尾木架整片、沙发左侧窄缝；对照美术截图确认均为床头/实体家具/窄缝，已在 `LocationManager.NAVIGATION` home 配置追加两个贴边封堵多边形，而非打通。
- 封堵后复跑全部通过：`verify_home_edges` 6252 项 0 失败、`verify_navigation` 6646 项 0 失败、`verify_home_activities` 全过、`verify_locations` 九图全过。
- 遮挡诊断结论：目前无前景遮挡的三件家具（椅子、右侧厨房柜、床头柜）都贴墙，角色走不到其后方，暂不需要补前景遮挡。

## 2026-09-13 再后续：活动道具反馈

- 新增 `scripts/world/ActivityProp.gd`：休息/学习/做饭时在角色手部显示程序化绘制的枕头/书/锅（深色衬底 + 金边，1.35 倍缩放），随角色脚底坐标移动；项目无音频资源，音效仍缺位。
- `LocationManager.set_activity_feedback` 增加第三个参数 `activity_id`，`Game._on_home_activity` 传入活动 id；道具位置在 `_update_player_grounding` 中同步，z 在角色之上。
- `tools/verify_home_activities.gd` 新增三条断言：活动中道具可见且种类匹配、活动结束后清理。
- 新增 `tools/capture_activity_props.gd`：截取三个活动进行中的画面到 `build/qa/home_prop_*.png`。注意脚本必须等 `activity_running` 复位再触发下一个活动，否则活动锁会拒掉后续激活，截到上一次的反馈。
- 复跑全绿：`verify_home_activities`（含道具断言）、`verify_home_edges` 6252 项、`verify_navigation` 6646 项、`verify_locations` 九图。
- 尚未做：专属活动姿态动画（现仍是行走动画定格）、音效（无音频资产）。

## 尚未完成

- 全部行走方向的身体比例与动画接地视觉抽查：碰撞与可达已由 `verify_home_edges.gd` 自动覆盖，姿态观感仍需人工看截图与试玩。
- 角色活动姿态、物品反馈和音效；当前活动主要是移动、进度文字与数值反馈。
- 2026-09-13 已增加最小头顶互动反馈，但尚不是正式姿态/物品/音效系统。
- 房门等"触发即切图"的互动，转身朝向与切图同帧发生，玩家看不到转身；当前朝向只对不切图的家具（床/书桌/厨房）有实际观感。
- NPC 尺寸、脚点、方向动画尚未全面统一。
- 出租屋以外的碰撞及遮挡多数仍为矩形近似，不能宣称全地图无视觉穿模。
- 阶段 2 的完整一天流程尚未实现：家→地铁→公司工作→便利店购买→回家休息→次日结算。
- 旧年度人生事件与新的分钟/每日循环仍需正式分离。

## 下一任务

阶段 1 先封闭出租屋可玩样板：逐家具边缘检查、四方向角色融合、互动反馈。随后进入阶段 2 的最小闭环：

1. 定义每日目标和流程状态，不依赖调试跳转。
2. 地铁增加通勤入口与固定分钟消耗。
3. 公司增加工作活动、工资/健康/心情结算。
4. 便利店增加购买与背包消耗。
5. 回家睡眠触发次日，并验证中途存档恢复。

## 常用命令

```powershell
$godotExe = 'F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --headless --path . --script res://tools/verify_navigation.gd
& $godotExe --headless --path . --script res://tools/verify_home_activities.gd
& $godotExe --headless --path . --script res://tools/verify_locations.gd
& $godotExe --path . --rendering-method gl_compatibility --script res://tools/verify_home_input.gd
```

本地试玩可双击 `tools\play-local.cmd`。截图输出到被 Git 忽略的 `build/qa/`。

## 检查点规则

- `HANDOFF.md` 必须始终反映工作树真实状态。
- 测试通过只能说明其声明范围通过；视觉抽查不得写成“全地图已完成”。
- 本地提交后更新本文件中的当前提交号；禁止自动 push、force push、reset 或覆盖用户文件。
