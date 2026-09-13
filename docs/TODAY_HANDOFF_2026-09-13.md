# 《都市浮生》2026-09-13 开发交接索引

## 当前检查点

- 项目：`D:\打工人模拟器\citylife-game-github`
- 当前 HEAD：`53a06cb feat: NPC relationship feedback (affinity, daily limit, tiers)`（本日最后一条是阶段 3 单元 1）
- 工作树：干净（`git status --porcelain` 无输出）
- **本地领先远程若干提交，需要用户双击 `tools\push-local.cmd` 上传**（自动化环境 PATH 被替换，助手无法 push，原因见 `HANDOFF.md`「推送远程」一节）。禁止 force push / reset。
- 详细证据见 `docs/QA_2026-09-13.md`（含第 2 阶段与第 3 阶段单元 1 两部分）；长期项目状态见根目录 `HANDOFF.md`；阶段计划见 `docs/ITERATION_PLAN.md`；目录与模块职责见 `docs/ARCHITECTURE.md`。

## 今天完成的系统（第 2 阶段「完整的一天」）

闭环已打通：家 → 地铁 → 公司 → 便利店 → 回家 → 睡到次日。

| 提交 | 内容 |
| --- | --- |
| `629a64f` | 需求系统（饱食 / 精力，按真实流经分钟消耗） |
| `1f381aa` | 便利店购买与背包消耗 |
| `14c43f4` | 文档：记录便利店里程碑提交号 |
| `3199133` | 回家睡眠触发次日 + 跨天结算 |
| `c7bd310` | 过夜截图工具 |
| `4389231` | 修掉真实输入测试的偶发红灯 |

- 每日目标 `DailyRoutine`：通勤/工作/吃饭/休息四项，跨午夜自动重置，**不推进年龄**，与旧年度人生系统分离。
- 公司工位：工资 +120、健康 −6、心情 −4、耗时 4 小时。
- 便利店：六样货品（桶装泡面 6 元 / 三角饭团 7 / 袋装面包 5 / 罐装咖啡 8 / 盒装牛奶 6 / 感冒药 18），买不起置灰；买到的进背包，HUD 背包按钮带件数，随处可取用。
- 过夜：20:00 后或 5:00 前上床＝睡整夜（跨到次日 07:30）；白天上床仍是两小时小睡。醒来精力回满、健康 +12 心情 +8，并因整夜时间流过而变饿。
- 存档：抽成 `Game.build_save_payload()` / `apply_save_payload()`，读档会重置需求基准，避免把时间跳变当成真实流逝扣需求。

## 今天另起的一段（第 3 阶段：NPC 与成长 · 单元 1）

| 提交 | 内容 |
| --- | --- |
| `53a06cb` | NPC 关系反馈（好感 / 每日一次 / 档位 / 升档叙述 / 存档） |

- 新增 `scripts/systems/NpcRelations.gd`：好感 0–100，每天只第一次交谈 +4；档位 陌生人/认识/熟络/朋友，升档回补心情并给一句叙述。
- `GameState` 增 `relations` / `talk_day`，**未新增存档键**，旧档可读。
- 热点标签与悬停提示带档位（`小雨（熟络）`）；交谈结果在**对话读完**才结算。
- 新增 `tools/verify_npc.gd`（8 组，全通过）与 `tools/capture_npc.gd`（截图到 `build/qa/npc_*.png`）。
- **12 套全员回归全绿**（navigation 6646/0、home_edges 6252/0，其余 `exit=0`）。
- 本段踩的坑（已写进 `ARCHITECTURE.md` 模块边界第 7 条）：**`queue_free()` 只标记不立即离树**，只调它会让同一帧的同名旧节点被重新取到（标签显示旧档位）；同名节点重建要 `remove_child` 再 `queue_free`。
- 未做：工作技能成长、首批连续任务；关系无对话选项/事件加成/门槛解锁。

## 今天的关键修复与踩坑（接手请务必看）

- **真实输入测试偶发红灯（已修）**：`input_blocked` / `home_activities.blocked` **只在 `Game._process()` 里按 `ui_busy` 写**。测试若在 `Game._process` 算出闸门之前就 `set_process(false)`，闸门会永久停在 `true`，`walk_to()` 直接 `return false`，表现成"点了没反应"。修法是先手动驱一次 `_process` 再冻结。**凡依赖该闸门的真实输入测试都适用这条。**
- **活动层可见性会静默失败**：`HomeActivities/OfficeActivities/StoreActivities.layer.visible` 是在各自 `_process` 里按当前地点设的。切完图**必须等它真的亮起来再 `_activate`**，否则因 `layer.visible == false` 直接返回，无任何报错。`verify_day_flow.gd` 的 `_wait_for_layer()` 就是干这个。
- **CanvasLayer 上的 Control 不能指望 `PRESET_FULL_RECT`**：根节点尺寸会是 0，遮罩铺不开、面板贴左上角。要用 `PRESET_TOP_LEFT` + 监听 `size_changed` 手动同步视口。另：这种面板必须挂在 `UI` CanvasLayer 里，放 `LocationManager.root` 里 z_index 再高也会被 layer 2 的 HUD 压住。
- **容器最小尺寸要等布局刷新**：重建列表后立刻量 `get_combined_minimum_size()` 会拿到上一次的值。现在的做法是**不套 ScrollContainer，面板按内容撑高**；货品涨到十几件时再换固定高度滚动区。
- **`extends Node` 的工具脚本不能用 `--script` 跑**（会挂住不返回）：`verify_art / verify_hud / verify_interior / verify_layout / verify_min`。能这样跑的是 `extends SceneTree` 的。
- **`tools/verify.gd` 是刻意废弃的**：退出码 2 并指向替代套件，不是失败，别去"修"它。
- 两条 Godot 4 绘制坑：`Button` 设 `flat = true` 时**不绘制 normal 状态的 stylebox**（自定义深色底会整个消失）；`MoveMarker.z_index` 必须 ≥ 1905，否则被前景遮挡层和环境染色盖住。

## 环境与命令要点

- 引擎：`F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`（无头跑测试用 console 版）。
- 逻辑/导航测试：`--headless --path . --script res://tools/xxx.gd`。
- 真实输入与截图：`--path . --rendering-method gl_compatibility --script res://tools/xxx.gd`（**必须开窗**，无头无法命中 GUI，脚本会拒绝）。
- 完整复测命令清单见 `docs/QA_2026-09-13.md` 末尾。
- 试玩：双击 `tools\play-local.cmd`，或桌面的 `E:\Desktop\都市浮生-试玩.bat` / `都市浮生-编辑器.bat`。
- 截图输出到 `build/qa/`（已忽略入库）。
- 本机若用 Bash 工具会失败（PATH 为空），改用 PowerShell；且 PowerShell 工具**不回显 stdout**，需 `Out-File` 到文件再读。git 不在 PATH，用 `C:\Users\86139\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe`，提交时需 `-c user.name=... -c user.email=...`。

## 下一开发优先级（第 3 阶段：NPC 与成长）

1. ~~NPC 实体化与交谈~~：已完成——找得到、聊得上、有回应；日程热点 + 带档位的对话标题。
2. ~~NPC 日程与关系反馈~~：已完成——好感/档位/每日一次/升档叙述/存档往返。
3. **工作技能成长**（下一步）：让关系与技能影响后续选择。
4. 首批连续任务：不重复结算、不形成死路。
5. 之后才是第 4 阶段扩展地图（公园、咖啡馆、医院、旧巷等要逐场景标定碰撞与遮挡）。

**在第 3 阶段推进的同时，第 2 阶段还剩一项人工验收**：无调试跳转走完 20–30 分钟完整流程，判断节奏与观感是否成立。自动测试覆盖了切图与结算，但替代不了这一项。

## 产品基调（不要跑偏）

参照国产独立游戏《众生》：普通人的日常质感、有文学性的叙述、需求与情绪的起伏。原则是**交互质感优先于数值堆砌**——同样的结算用生活化的句子表达，数值放在括号里保留。当前是彩色雨夜城市美术，不照搬《众生》的黑白简笔画，只取"把日常写得有分量"的调子。
