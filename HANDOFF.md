# 都市浮生开发交接

更新时间：2026-09-13

## 唯一开发源

- 项目：`D:\打工人模拟器\citylife-game-github`
- 引擎：`F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- Godot：4.7.2 stable，GL Compatibility，1280×720
- 当前约束：只使用仓库内用户美术；借鉴开源功能代码但不套用外部美术包；所有开发留在 D 盘。
- 远程同步：**用户已授权把本地 `main` 与 `origin/main` 保持同步**（远程 `https://github.com/weiweng17/citylife-game.git`）。推送 `main` 会触发 GitHub Actions 自动导出 Web 并发布到 Pages，因此推送前必须先确认工作树干净、测试通过。恢复/回退历史仍须先问用户。

## 接手顺序

1. 阅读本文件。
2. 阅读 `docs/ARCHITECTURE.md`（目录与模块职责）、`docs/ITERATION_PLAN.md`（开发规划权威）、最新的 `docs/TODAY_HANDOFF_<日期>.md` 与最新的 `docs/QA_<日期>.md`。
3. 执行 `git status --short` 与 `git log -5 --oneline`，保留所有用户修改。
4. 先运行与当前任务直接相关的测试，再修改代码。
5. 每完成一个 15–30 分钟的小单元：测试、更新本文件、做本地提交；不要等整个阶段完成才记录。

## 产品基调（用户明确要求）

参照国产独立游戏《众生》：普通人的日常质感、有文学性的叙述、需求与情绪的起伏、让人产生共鸣。
原则是**交互质感优先于数值堆砌**——同样的结算，用生活化的句子表达，数值放在括号里保留。
当前游戏是彩色雨夜城市美术，不照搬《众生》的黑白简笔画，只取其"把日常写得有分量"的调子。

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

## 2026-09-13 再后续：阶段 2 每日循环骨架（单元 1）

- 新增 `scripts/systems/DailyRoutine.gd`：每日目标（通勤/工作/吃饭/休息）、完成标记、跨天重置、存档字典。**只跟踪一天之内的进度，不推进年龄、不触发年度结算**，与旧人生系统分离。
- 新增 `scripts/systems/OfficeActivities.gd`：公司工位互动（距离校验、防重复结算、朝向、活动锁）。结算放在 `Game._on_office_activity`：工资+120、健康−6、心情−4、耗时 4 小时，完成后标记 work。站位 `Vector2(700, 470)` 为粗略标定，尚未对照美术校正。
- `Game` 接入：`daily_routine` 与 `office_activities` 初始化、监听 `time_sys.day_changed` 重置每日目标、存档新增 `daily` 字段、抵达公司标记通勤。
- HUD 新增“今日”行显示目标摘要（`refresh_daily`）；因 HUD 加高一行，地点标题整体下移 20px 保持与 HUD 分离，`verify_locations` 的布局断言已复跑通过。
- 阶段 2 第 2 项说明：`_on_location_travel` 原本已有通勤时间消耗（地铁 20 分钟、其他 35 分钟），本次只补齐“抵达公司标记通勤”，未改动既有数值。
- 新增 `tools/verify_daily_routine.gd`：目标状态与存档往返、通勤标记、工位可达、工作结算（只结算一次）、跨午夜重置。
- 五套测试全绿：`verify_daily_routine`、`verify_home_activities`、`verify_home_edges` 6252、`verify_navigation` 6646、`verify_locations`。
- 已知限制：通勤若在跨午夜完成，通勤标记会被当日重置清掉（边缘情况，未处理）。

## 2026-09-13 再后续：交互质感（向《众生》的调子靠）

- 新增 `scripts/world/MoveMarker.gd`：点击地面必须有回应——走得到是金色涟漪扩散，走不到是静止红环加斜杠。**z_index 必须设到 1905**（前景遮挡层最深 650、环境染色 1900），否则会被沙发等前景盖住看不见。
- 家具/工位互动标签加 `_style_button`：暗色胶囊 + 金色细边，悬停时描边转亮。注意**不能用 `flat = true`**，Godot 4 在 flat 下不绘制 normal 状态的 stylebox，底色会整个消失。
- 结算文案改成生活化叙述，数值保留在括号内：如“你把一整天交给了格子间。下班时雨还在下，手机里多了 120 块。身体发沉，话也不想说。（工资+120 健康−6 心情−4，耗时4小时）”。活动中的进度提示也从“上班中… 40%”改成“键盘敲个不停… 40%”。
- 新增 `tools/capture_interaction_polish.gd`：截取可走/不可走两种落点标记的对照图。
- 六套测试全绿：`verify_daily_routine`、`verify_home_activities`、`verify_home_edges`、`verify_navigation`、`verify_locations`，以及真实鼠标键盘的 `verify_home_input`（0 失败）。

## 2026-09-13 再后续：需求系统（饱食 + 精力）

- `GameState` 新增 `fullness`（饱食 70 起）、`energy`（精力 80 起），进 `to_dict/apply_dict`；`Game` 有同名代理属性。
- 消耗按**真实流经的分钟数**计算：`Game._sync_needs_to_time()` 每帧比对 `day*1440+minute_of_day`，每满一小时扣饱食 4、精力 3（不足一小时先攒在 `need_fraction`，避免被舍掉）。
  **不要用 `hour_changed` 信号扣**——`advance_minutes` 无论推进多少分钟都只 emit 一次该信号，按信号扣比例必然错。
- 极端后果：饱食归零每小时掉健康 2，精力归零每小时掉心情 2。
- 补回：做饭饱食 +45 并标记每日 meal，睡觉（rest）精力 +50 并标记每日 sleep。
- 告急独白：低于 25 时用角色口气 toast 一次（“肚子在叫。你想不起来上一顿是什么时候吃的了。”），同一天每种只播一次（`murmur_shown`）。
- HUD 状态行扩成四条：健康/心情/饱食/精力（条宽 120→92），需求条低于 35 转橙、低于 15 转红。
- 新增 `tools/verify_needs.gd`：按真实分钟消耗、吃饭/睡觉补给与每日标记、告急独白每天一次、存档往返。
- 七套测试全绿（needs/daily_routine/home_activities/home_edges/navigation/locations + 真实输入 home_input）。

## 2026-09-13 再后续：便利店购买与背包消耗

本轮提交：`629a64f feat: add daily needs system (fullness and energy)`（上一轮被打断补交）、`1f381aa feat: add convenience store shopping and inventory`。

- 新增 `scripts/systems/Inventory.gd`：物品目录（名称/价钱/耗时/效果/描述/食用文案）+ 数量增减 + 存档往返。**目录只写这一处**，货架面板、背包面板和结算全部读同一份定义，避免价钱对不上。目前六样：桶装泡面 6 元、三角饭团 7 元、袋装面包 5 元、罐装咖啡 8 元、盒装牛奶 6 元、感冒药 18 元。
- 新增 `scripts/systems/StoreActivities.gd`：仿 `OfficeActivities` 的便利店货架互动点，位置 `Vector2(455, 515)`（在碰撞体外侧、与出生点连通，已由 `walk_to` 断言可达），朝向 `(-1, 0)` 面向左侧货架。提示行放在 y=580——底部面板从 y=608 起，放在 600 会被盖住（顺带把 `OfficeActivities` 同样错位的提示行一并下移到 580）。
- 新增 `scripts/ui/ShopUI.gd`：一块面板两种用法，`open_buy` 看货架、`open_bag` 看背包。**必须挂在 `UI` CanvasLayer 里**（放在 `ending_ui` 之后），这样才盖得住 HUD；放在 `LocationManager.root` 里不管 z_index 多高都会被 layer 2 的 HUD 压住。整屏 `ColorRect` 用 `MOUSE_FILTER_STOP` 吃掉点击，面板打开时点不到地面和地点按钮。
- 买不起的行直接把按钮 `disabled`，并单独覆写 `disabled` stylebox（默认主题的 disabled 底色和暗色面板不搭）。
- 结算仍在 `Game`：`_on_shop_buy` 扣钱入包；`_on_shop_use` 施加效果、推进分钟、消耗一件，并把"能顶一顿"的（效果 `fullness >= MEAL_FULLNESS = 20`）记入每日 `meal` 目标——牛奶只补 12，糊弄不过每日目标。
- 面板打开计入 `ui_busy`：锁住走动并暂停时间，免得挑东西的时候饱食一直在掉。
- HUD 第一行加「背包」按钮，带件数（`refresh_bag`）。
- 存档新增 `inventory` 字段；读档/选出身/重开都会先收起面板并重置背包。`apply_save_dict` 会丢掉目录里已不存在的旧物品，不让无效条目带进存档。
- 新增 `tools/verify_store.gd`（10 组断言：解锁与可达、面板列出全部货品、开面板锁走动、买不起无副作用且按钮置灰、购买扣钱入包与 HUD 同步、取用回补并消耗、牛奶不算一顿饭、药品只养身体、背包只列持有物、存档往返与未知物品丢弃）。
- 新增 `tools/capture_store.gd`：截货架标签/货架面板/背包面板到 `build/qa/store_*.png`（排版只能靠眼睛看）。
- 复跑全绿：新增 `verify_store` 10 组，其余各套同轮复跑通过。

### 这一轮踩到的两个坑（都不在逻辑里，在布局里）

- **挂在 `CanvasLayer` 上的 Control 不要指望 `PRESET_FULL_RECT` 自动撑开**：`ShopUI` 根节点是 `CanvasLayer(UI)` 的子节点，用 FULL_RECT 锚点时根节点尺寸是 0，结果是整屏遮罩根本没铺开、面板贴在左上角。改成 `PRESET_TOP_LEFT` + 自己监听 `size_changed` 同步视口尺寸（和 `LocationManager.root` 的 `_sync_web_layout` 同一套做法）才正常。
- **容器的最小尺寸要等布局刷新，刚重建完量到的是旧值**：面板里的列表原本套了 `ScrollContainer` 再按 `list_box.get_combined_minimum_size()` 设高度，结果"先开货架 6 行、再开空背包"时量到的是 6 行的高度，背包面板撑出一大片空白；而且同一个列表，父容器报的高度（342）和单行自己报的（62）还对不上。最后**去掉 `ScrollContainer`，让面板直接按内容撑高**——6 件货品刚好一屏，背包里只有一件时就只有一件的高度。货品目录涨到十几件时再换回固定高度的滚动区。

## 2026-09-13 再后续：回家过夜与次日结算（阶段 2 最后一项）

- 床位（`rest`）现在看时刻分两种结果：**20:00 之后或凌晨 5:00 之前上床＝睡一整夜**，跨过午夜到次日 07:30；**白天上床仍然只是两小时小睡**（原行为不变）。这样一张床不用加第二个按钮，玩家也不会被抢走小睡的选择。
- 提示语跟着变：`Game._rest_detail_text()` 在 `_refresh_ui()` 里每帧写进 `HomeActivities.rest_detail`，夜里显示"睡到明早 7:30 · 跨天结算"，白天显示原来的"2小时 · 健康+12 心情+8 精力+50"。按 E 之前就能看到这一觉会睡多久。
- 结算顺序（`Game._sleep_through_night()`）：**先记下昨天**（`daily_routine.complete("sleep")` + `summary()`）→ 再 `advance_minutes()` 跨天（`day_changed` 会把当日目标清空，所以顺序不能反）→ 再 `_sync_needs_to_time()` 把这一夜该掉的饱食掉掉 → 最后回满精力、健康+12 心情+8。
  于是醒来是**"睡饱了但饿"**（11 小时扣 44 饱食），而不是睡完还累，也不是顶着一身力气却饿着。
- 跨天之后不再补记"休息"：新的一天从空白目标开始。这是刻意的，理由写在代码注释里。
- 附带的规则交互（已在测试里锁住）：饿着肚子、精力见底才上床，这一觉会额外触发"精力归零再掉 2 点心情"——那是需求系统的规则，不是睡眠加成出问题。

### 存档改成 payload 进出，并修掉一个读档丢需求的坑

- `Game._save_game/_load_game` 里内联的 payload 抽成 `build_save_payload()` / `apply_save_payload()`。好处是**"中途存档 → 读回"可以在内存里整份往返验证，不必去碰玩家真正的存档文件**（`user://savegame.json`）——和 `verify_home_input.gd` 不碰玩家存档是同一个顾虑。
- **修的坑**：读档会把时间整体跳到存档那一刻（可能是好几天前）。`_sync_needs_to_time()` 按 `day*1440+minute` 的差值扣需求，不重设基准就会把这一整跳当成"真实流过的时间"扣掉一大截饱食与精力。`apply_save_payload()` 现在会重置 `_last_total_minutes` 与 `need_fraction`。
- 新增 `tools/verify_day_cycle.gd`（4 组：白天只小睡、夜里睡到次日、过午夜后睡同一个早晨、中途存档读回且不扣需求）。存档往返那组逐项断言钱/健康/心情/技能/饱食/精力/天数/时钟/所在地/背包/每日进度/剧情 flag/origin，并检查 payload 的十个字段齐全。
- 新增 `tools/verify_day_flow.gd`（整条链的接线测试，6 组）：家→地铁→公司上班→便利店买泡面→回家做饭→睡到次日，**全程走真实交互**（点家具标签、走地点按钮、按面板按钮），不直接改状态；唯一的取巧是把时钟快进到夜里（白天到晚上要真等 6 分钟现实时间）。第四组 PASS 时钱从 2000 变成 2094，正好对上 +120 工资 −6 泡面 −20 做饭。
- **注意**：活动层（`HomeActivities.layer` 等）是在它自己的 `_process` 里按"当前地点"开关的。切完图要等它真的亮起来再 `_activate`，否则会因为 `layer.visible` 还是 `false` 而**静默返回**——看起来像"点了没反应"。`verify_day_flow.gd` 里的 `_wait_for_layer()` 就是干这个的。
- 注：测试里为了摆场景会直接跳时间，跳完把 `_last_total_minutes` 对齐一次，否则那一跳会被当成真实流逝的时间扣需求（和上面读档是同一个原理）。

## 2026-09-13 再后续：清理两个失效的旧测试

- `tools/verify.gd` 是单张世界地图时代的套件（旧 `Player.moving/set_target`、`Game._detect_near()`、固定坐标 GOAL(600,600)、建筑/树木/POI 计数）。MAP-002 独立地点场景迁移（`c43c30e`）之后旧世界被隐藏、交互改由 `InteractionSystem` 负责，这份套件统计出来全是 0、却在 `_detect_near` 处抛 SCRIPT ERROR，而且因为断言宽松还会照打 `[OK]`——**给的是误导性的绿灯**。已在文件头和阶段 2 入口标明废弃，一旦发现旧接口不在就 `quit(2)` 并指向替代套件。
- `tools/verify_onboard.gd` 断言的是迁移前那份 6 行新手引导文案（"点击地图 / 发光 / 说话 / 家 / 60 岁"），文案早就换成了地点场景版本，于是六条关键词全部落空。更麻烦的是它把失败分支写成 `_init()` 里的 `quit(1)`，**后面的 `quit()` 会把退出码覆盖回 0**——打了 FAIL 却仍然退出 0。已改为断言当前文案（行数、无空行、包含 22 岁 / 独立场景 / 解锁 / 行动 / 旅行），并在末尾按失败数统一决定退出码。
- 另外记录：`verify_art` / `verify_hud` / `verify_interior` / `verify_layout` / `verify_min` 是 `extends Node` 的脚本，**不能用 `--script` 直接跑**（会挂住不返回）；能这样跑的是 `extends SceneTree` 的那些。

## 2026-09-13 再后续：修掉真实输入测试的偶发红灯

阶段 2 收尾做全员回归时，`verify_home_input` 报过一次 `real click did not queue furniture approach`。**同一份代码时而红时而绿**（连跑四次红一次、连跑六次红一次），这种红灯比不测还坏，必须查清。

- **先排除产品问题**：新增 `tools/diag_click.gd`（只读诊断，不做断言），复现那次点击并打印几何与命中结果——命中控件确实是床标签按钮（`STOP`、排在最后即最上层），点击后 `home.pending=rest`、`walk_path=2`。**点击链路本身是好的，问题在测试。**
- **真正原因**：`location.input_blocked` 和 `home_activities.blocked` **只在 `Game._process()` 里按 `ui_busy` 写**（`Game.gd:568-571`）。而测试关掉开场对话后只等了一帧就 `main.set_process(false)`——那一帧里 `_process` 有没有跑、`dialog_ui.is_busy()` 是不是已经变假，是不确定的。闸门一旦停在 `true`，就再也没人把它写回来了：`walk_to()` 开头 `if input_blocked or not active: return false` 直接返回，`_request()` 也早退，于是点击看起来"毫无反应"。
- **修法（只改测试，未动运行时）**：
  - 关掉对话后**显式跑一次 `main._process(0.0)`**，让 Game 自己把闸门算清楚，再冻结 processing；
  - 补一条 `check(not location.input_blocked and not home.blocked, "input gate still blocked after closing intro dialog")`，以后这类问题会直接指名"闸门没放行"，而不是在下面某个断言上伪装成"点击没反应"；
  - `click_at()` 里加 `Input.warp_mouse(position)`：窗口刚获得焦点时引擎会按真实光标位置补发一次移动事件，光标若停在别处，会把刚按下的按钮判成"指针已移出"（这是次要风险，顺手挡掉）。
- **验证**：修前 4 次红 1；修后连跑 18 次（8 + 10）全绿。
- **教训**：凡是"真实输入"测试，只要它依赖的闸门是由 `Game._process` 写出来的，就**不能提前 `set_process(false)` 了事**——要么先手动驱一次 `_process`，要么改成轮询到闸门放行为止。

## 2026-09-13 阶段 2 收尾保存（交接检查点）

- **当前 HEAD：以 `git log -1 --oneline` 为准**（本节记录时是阶段 2 收尾的 `4389231`，其后又补了架构文档与推送脚本）。工作树应保持干净。
- **远程同步**：本地 `main` 需要与 `origin/main` 保持一致，**双击 `tools\push-local.cmd` 即可推送**。自动化环境因 PATH 被替换而推不上去，原因见本文件「推送远程」一节。
- 阶段 2 的六个代码单元全部完成，提交顺序：
  - `629a64f` 需求系统（饱食/精力）
  - `1f381aa` 便利店购买与背包消耗
  - `14c43f4` 文档：记录便利店里程碑提交号
  - `3199133` 回家睡眠触发次日与跨天结算
  - `c7bd310` 过夜截图工具
  - `4389231` 修掉真实输入测试的偶发红灯
- 本次交接新增两份文档：
  - `docs/QA_2026-09-13.md`：第 2 阶段逐套测试的实测数字、限制、本地复测命令清单。
  - `docs/TODAY_HANDOFF_2026-09-13.md`：给接手人的索引——检查点、今天完成项、踩坑、环境命令、下一优先级。
- **接手第一步**：读 `docs/TODAY_HANDOFF_2026-09-13.md`，然后按 `docs/QA_2026-09-13.md` 末尾的命令跑一遍回归。
- **阶段 2 出口尚未达成**：只剩"无调试跳转走完 20–30 分钟完整流程"的人工试玩验收。自动部分由 `tools/verify_day_flow.gd` 覆盖，但游戏内 1 秒＝2 分钟，节奏与观感只能靠人眼判断。

## 2026-09-13 阶段 3 开工：NPC 关系反馈（单元 1）

第 3 阶段第一块代码。目标是把"找得到、聊得上"变成"聊出关系"，同时不破坏任何已有测试。

- 提交：`53a06cb feat: NPC relationship feedback (affinity, daily limit, tiers)`（6 文件）。
- 新增 `scripts/systems/NpcRelations.gd`：每人一条好感值（0–100 封顶），**每天只第一次交谈 +4**；档位 陌生人 0 / 认识 20 / 熟络 45 / 朋友 70，升档回补一点心情并给一句叙述。纯逻辑 `RefCounted`，不挂树、不落盘。
- `scripts/GameState.gd` 增 `relations` / `talk_day`，塞进现有 `game_state` 里，**未新增存档键**，旧档可读、新状态随存档往返。
- `scripts/systems/LocationManager.gd`：热点标签/悬停提示带档位（`小雨（熟络）`），档位变则重建热点；**`_clear_npcs` 改为先 `remove_child` 再 `queue_free`**。
- `scripts/Game.gd`：交谈结果**在 `_on_dialog_finished` 才结算**（中途关掉不算），重复交谈追加"今天已经聊过了"，升档弹提示与叙述。
- 新增 `tools/verify_npc.gd`（8 组）与 `tools/capture_npc.gd`（3 张截图，输出 `build/qa/npc_*.png`）。
- 验证：`verify_npc` 8/8 通过；**12 套全员回归全绿**（navigation `6646/0`、home_edges `6252/0`，其余 `exit=0`）；截图确认 `陌生人 → 熟络` 标签实时变化。
- **踩坑（重要）**：`queue_free()` 只标记不立即离树，节点到帧末才走；`_clear_npcs` 原来只调 `queue_free()`，导致重建后同一帧按名字取到的是待删除的旧节点，标签显示上一档位。凡"同名节点重建"都要 `remove_child` 再 `queue_free`；测试按名字找子节点要跳过 `is_queued_for_deletion()`。已写进 `docs/ARCHITECTURE.md` 模块边界第 7 条。
- 尚未做：工作技能成长、首批连续任务；关系目前只由"每天聊一次"推动，无对话选项/事件加成/门槛解锁；可交谈的仅当前日程表里的 NPC。

## 尚未完成

- 全部行走方向的身体比例与动画接地视觉抽查：碰撞与可达已由 `verify_home_edges.gd` 自动覆盖，姿态观感仍需人工看截图与试玩。
- 角色活动姿态、物品反馈和音效；当前活动主要是移动、进度文字与数值反馈。
- 2026-09-13 已增加最小头顶互动反馈，但尚不是正式姿态/物品/音效系统。
- 房门等"触发即切图"的互动，转身朝向与切图同帧发生，玩家看不到转身；当前朝向只对不切图的家具（床/书桌/厨房）有实际观感。
- NPC 尺寸、脚点、方向动画尚未全面统一。
- NPC 关系（阶段 3 单元 1）目前只由"每天聊一次"推动，**没有对话选项、没有事件加成、没有关系门槛解锁的内容**；`朋友` 档位暂时只是显示与一次心情回补。工作技能成长、首批连续任务尚未开始。
- 出租屋以外的碰撞及遮挡多数仍为矩形近似，不能宣称全地图无视觉穿模。
- 阶段 2 的完整一天闭环已实现：家→地铁→公司工作→便利店购买→回家睡觉跨到次日。**只剩"无调试跳转走完 20–30 分钟完整流程"的人工试玩验收没做**——这一项自动测试替代不了：游戏内 1 秒＝2 分钟，现实里走完一天要 6 分钟，无头脚本只能覆盖切图与结算。
- 过夜目前只有"睡到明早 7:30"一种；还没有"被闹钟叫醒/熬夜加班/失眠"这类分支。
- 便利店购买与背包消耗已完成（见上），但货架站位是粗略标定，尚未逐帧对照便利店美术校正；吃/喝的动作也只有进度文案与数值，没有专属姿态。
- 旧年度人生事件与新的分钟/每日循环仍需正式分离。

## 下一任务

阶段 1 先封闭出租屋可玩样板：逐家具边缘检查、四方向角色融合、互动反馈。阶段 2 的最小闭环进度：

1. [完成] 定义每日目标和流程状态，不依赖调试跳转。
2. [完成] 地铁增加通勤入口与固定分钟消耗。
3. [完成] 公司增加工作活动、工资/健康/心情结算。
4. [完成] 便利店增加购买与背包消耗。
5. [完成] 回家睡眠触发次日，并验证中途存档恢复。
6. [待人工] 无调试跳转走完 20–30 分钟完整流程的试玩验收；通过后阶段 2 出口达成。

阶段 3「NPC 与成长」：

7. [完成] NPC 实体化与交谈：日程热点、点击开聊、带档位的对话标题。
8. [完成] 关系反馈：好感/档位/每日一次/升档叙述/存档往返。
9. [待做] 工作技能成长，让关系与技能影响后续选择。
10. [待做] 首批连续任务：不重复结算、不形成死路。

## 常用命令

```powershell
$godotExe = 'F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --headless --path . --script res://tools/verify_navigation.gd
& $godotExe --headless --path . --script res://tools/verify_home_activities.gd
& $godotExe --headless --path . --script res://tools/verify_store.gd
& $godotExe --headless --path . --script res://tools/verify_day_cycle.gd
& $godotExe --headless --path . --script res://tools/verify_day_flow.gd
& $godotExe --headless --path . --script res://tools/verify_locations.gd
& $godotExe --headless --path . --script res://tools/verify_npc.gd
& $godotExe --path . --rendering-method gl_compatibility --script res://tools/capture_store.gd
& $godotExe --path . --rendering-method gl_compatibility --script res://tools/capture_npc.gd
& $godotExe --path . --rendering-method gl_compatibility --script res://tools/verify_home_input.gd
# 排查"点了没反应"：打印命中控件与盖在该点上的全部控件（只读，不做断言）
& $godotExe --path . --rendering-method gl_compatibility --script res://tools/diag_click.gd
```

### 推送远程（本机有两个坑，实测过）

本机只有 PortableGit，有两个叠加的问题：

1. **`git-remote-https` 在 `mingw64\bin`，而 git 的 exec-path 指向 `mingw64\libexec\git-core`**，所以 http(s) 传输默认找不到 → 报 `git: 'remote-https' is not a git command`。
2. **凭据助手（`git-credential-helper-selector` / `git-credential-manager`）本身是 shell 脚本，需要 `git` 自己在 PATH 上**；`git-credential-wincred` 同样。GitHub 的令牌存在 Windows 凭据管理器里（GCM 建的 `GitHub - https://api.github.com/weiweng17`），GCM 取它时也要能定位 `git.exe`。

**正确做法：在普通 shell 里把 PATH 设对，然后 push。** 直接双击 `tools\push-local.cmd` 即可（脚本自己设 PATH）。

- 只读远程（`ls-remote` / `fetch`）是匿名可用的，仓库是公开的；**推送必须带凭据**。
- **在自动化/沙箱 shell 里推不了**：这类环境会把子进程的 PATH 整个替换掉（实测 `$env:PATH` 改动不会传给子进程），于是助手找不到 `git`、GCM 找不到 `git.exe`，表现是 `git: 'remote-https' is not a git command` 或者干脆静默 `exit 128`。此时至少要用 `--exec-path` 指向 `mingw64\bin` 才能读远程，但推送仍然失败。
- 推送会触发 GitHub Actions 导出 Web 并发布 Pages，所以推之前先确认测试通过、工作树干净。

本地试玩可双击 `tools\play-local.cmd`。截图输出到被 Git 忽略的 `build/qa/`。

## 检查点规则

- `HANDOFF.md` 必须始终反映工作树真实状态。
- 测试通过只能说明其声明范围通过；视觉抽查不得写成“全地图已完成”。
- 本地提交后更新本文件中的当前提交号，并按需 `git push origin main` 保持与远程同步；禁止 force push、reset 或覆盖用户文件。
