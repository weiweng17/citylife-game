# 《都市浮生》V1.0 Day 2–7 留存循环实施映射

> Task: `DIRECTOR-CONTENT-003`
> Branch: `agent/director-content-003-day2-7-retention`
> Baseline: accepted `DIRECTOR-CONTENT-002` exact tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`
> 作用：把已经验收的 Day-1 首 30 分钟脊柱延长到第一周，让玩家愿意醒来继续过日子，同时不重新堆出一面“人生目标墙”。
> 本文只定义玩家体验、显示优先级、现有内容的首周资格和最小实现交接；不修改生产代码、数据、UI、美术或音频。

---

# 0. 导演结论

Day 1 回答的是：

> **“我能不能把第一天过下来？”**

Day 2–7 必须回答：

> **“这座城市有没有开始出现一点属于我的规律？”**

第一周不能把 `做饭 → 通勤 → 工作 → 买东西 → 睡觉` 复制六遍，也不能重新把 22–60 岁阶段、暗线碎片、q1–q3、九张地图和所有 NPC 同时推回 HUD。

第一周只保留一个周尺度动机：

> **本周：把“新来的”过成“能留下的人”。**

它通过三个已有状态锚点被玩家感知，而不是新增 WeeklySystem：

1. **工作锚点**：Day 2 起真的重复过一次普通工作，知道这不是一次性剧情按钮；
2. **熟人锚点**：任一普通生活 NPC 达到现有 `认识` 档（relation >= 20）；
3. **去处锚点**：onboarding 后真正去过 `park` 或 `cafe`，拥有一个“不是因为上班才去”的地方。

三个锚点都从现有 `quests / relations / visited / day` 等状态派生，不新增 save schema。它们是周总结依据，不是三个并列硬任务。Day 7 少一个锚点不会失败、不会扣属性、不会锁剧情。

第一周的循环应该是：

> **重复一件熟悉的事 → 加一个小变化 → 人或地点开始回应玩家 → 再回来。**

---

# 1. 已接受输入与硬依赖

## 1.1 Day 1 不重开讨论

沿用 `DIRECTOR-CONTENT-002` 最终脊柱：

`home 做饭 → subway → office 先找老张 → 第一班普通工作 → 可选 overtime → store / 可选陈姐 → home 第一晚 → onboarding_complete → Day 2`

老张在工作前出现的时间校正继续有效，不在 003 反复改动。

## 1.2 已接受谋生活动

`GAME-CONTENT-012` 已被 00 接受：

- office overtime：普通班后可见、每天一次、120 分钟、健康 −4、心情 −8、收入为当前普通班工资约 60%；
- cafe side gig：每天一次、90 分钟、+55 money、健康 −2、心情 −4；
- 两者复用现有 `GameState.flags`，不新增存档 schema。

003 只决定玩家什么时候理解它们，不改结算值。

## 1.3 Pack A 内容已接受，但 runtime 仍被 blocker 挡住

`NPC-CONTENT-012` 的 20 个 `e_cw01_*` 已作为内容资产接受。

但是当前普通 `EventSystem` 事件关闭仍会进入 `_year_pass()`。因此：

> **在 `GAME-CONTENT-014` 提供并验证 ordinary-city-event 的非年度结算路径之前，第一周 Pack A runtime eligibility 仍然是 0。**

本文后面的 Pack A 清单只是 blocker 解除后的首周策划资格，不代表现在可运行。

## 1.4 不新增系统

第一周不新增：

- WeekSystem / 周常币 / 连续登录奖励；
- 新 save schema；
- 新货币；
- 固定房租/月租；
- 周失败态；
- 新职业树；
- 新地图；
- Xiaoyu roommate / romance / housing 新 canon；
- spouse / child 语义；
- 超自然强制主线。

---

# 2. HUD：从 Day-1 单 L1 过渡到“本周 + 当前”

Day 1 onboarding 继续保持一个强 `现在：...`。

第一次成功整夜睡眠写入 `onboarding_complete` 后，Day 2 切成两层：

## L1 — 当前行动：强、只允许一条

例：

> **现在：今天自己去公司，把第二天过顺。**

或：

- `现在：先吃点东西。`
- `现在：身体已经在提醒你了，去仁心医院看一下。`
- `现在：下班后去公园坐一会儿。`
- `现在：去雨巷咖啡馆看看，那里有临时活。`
- `现在：回家练一小时，把手上的活练熟一点。`

任何时刻只能有一个 `现在`。

## L2 — 本周目标：弱常驻

> **本周：把“新来的”过成“能留下的人”。**

可用三个小状态做解释：

> `工作 ✓ / 熟人 · / 去处 ·`

它们只是已有状态的可视化，不是新任务表。

## L3 — 今日 DailyRoutine：弱回顾

保留通勤 / 工作 / 吃饭 / 休息，但缩成 `今日 x/4`、小图标或弱勾选。它回答“今天做过什么”，不回答“现在必须干什么”。

## L4 — 资源与后台成长

钱、健康、心情、饱食、精力、时间、天气、技能/档位继续展示。

Day 2–7 不恢复为主 HUD 的内容：

- 22–60 岁 `立足 / 成家 / 立业 / 归途`；
- 暗线碎片与追查状态；
- 10 万 / 50 万 / 200 万等长期数字；
- 朋友 70、老张 45 等“刷条终点”。

---

# 3. q1 / q2 / q3：不能推翻已接受的 Day-1 合同

这一节是 003 的关键自审修正。

## q1 — Day 2 起正常恢复，但降为后台进度

002 / `GAME-CONTENT-013` 的合同是：**onboarding 期间** suppress q1–q3 foreground/evaluate/notify/reward noise；第一晚 `onboarding_complete` 后退出 onboarding。

003 不应把 q1 再压到 Day 7。

因此：

- Day 2 起 q1 按现有 QuestSystem 正常推进；
- q1 不占据 `本周 + 当前` 两个主位置；
- 当 q1 当前步骤恰好和今天最合理的行动一致时，可以复用其方向，例如 skill 不足时推荐 study；
- 不把“q1 必须在 Day 7 前完成”当周失败条件。

### q1 copy 风险

q1 closing 现写：

> `你把这个月过成了一句勉强能看的话：还行。`

高技能/高现金出身可能在 Day 2–7 就完成，因此这句会穿帮。003 不改数据，但应交给 03 做**只改文案、不改条件/奖励/步骤**的后续修正。

## q2 — 可以自然出现，但不是首周硬目标

q2 的第一步 relation 20 很适合作为“有人认得我”的首周反馈；但谈薪成功还依赖：

- skill >= 55 才有资格；
- skill + network >= 95；
- 老张 relation >=45 才有 10 点帮腔减免。

所以：

- q1 很快完成的玩家可以看到 q2 作为“下一阶段存在”；
- Day 2–7 不要求谈薪成功；
- q2 不覆盖 `现在`，除非玩家自身已经满足条件并主动选择谈薪。

## q3 — 第一周不前台化

q3 明确写 Xiaoyu “室友 / 有人等你回家”。相关 housing/relationship canon 仍属于 deferred decision。

因此：

- 003 不把 q3 作为周目标、回家理由或 Day-7 总结；
- 若极端高属性路径在首周就穿过 q2，后续 Gameplay 应保证 q3 不自动取代 Week-1 `本周/现在` 主目标，也不追加新的 Xiaoyu canonical interpretation；
- 不删除 q3，不在本任务改 q3 数据。

---

# 4. “当前行动”推荐优先级

第一周是确定的导演节拍，但不是铁路。玩家可忽略推荐；系统下一次只重新给一个最有意义的行动。

## P0 — 生存状态优先

复用现有阈值和地图功能，不新增失败机制：

1. fullness <= 25 → `现在：先吃点东西。`
2. energy <= 25 → `现在：回家休息一下。`
3. health <= 55 → `现在：身体已经在提醒你了，去仁心医院看一下。`

医院只有健康真的产生理由时才被主动提示。

## P1 — 当天核心

- 还没完成普通工作且当天主题需要工作 → 普通 work；
- 当前 q1 有明显可执行步骤且不与 P0 冲突 → 可复用 q1 方向；
- Day 2–7 的导演主题只提供一条轻建议。

## P2 — 自由选择

工作完成后允许：

- 回家做饭 / 休息 / study；
- store 补给 / 陈姐；
- park 免费恢复；
- cafe 咖啡 / idle / side gig；
- office overtime；
- 找一个今天还没认真聊过的人。

不要求一天把所有系统打卡。

---

# 5. Day 2–7 默认导演节拍

这些是默认 authored beat，不是倒计时或失败 gate。前置没满足时顺延，不制造无效目标。

## Day 2 — “今天没人牵着我了”

### 早晨

> **现在：今天自己去公司，把第二天过顺。**

玩家自己走完 home → subway → office → ordinary work，不再逐站教学。

这一天证明：Day 1 教会的循环已经能独立完成。

### 下班后

> **现在：下班后的时间，选一件对明天有帮助的事。**

选择可以是：

- overtime：多赚一点，继续消耗健康/心情；
- store / 陈姐：补给；
- home：做饭、休息；
- park：免费恢复。

### park 第一次获得明确理由

不是“office 到过所以按钮亮了”，而是：

> `今天不想立刻回家，可以去中央公园坐一会儿。不花钱，也能把人缓回来一点。`

现有 bench / pond 已足够成立。

**Day 2 不把老周做 gate。**普通班结束后的时间很可能落在他 11:30–15:00 空窗，storm 也会隐藏他。公园价值必须在没有 NPC 时仍成立。

### q1

从 Day 2 起正常后台推进。Day 1 onboarding 的 work/meal 不倒灌成首日连跳；Day 2 的行动开始形成 post-onboarding q1 进度。

---

## Day 3 — “城市里不只公司能换钱”

如果玩家已经访问 park，现有 `VISIT_UNLOCKS` 会自然解锁 cafe。

### 当前行动（前置满足时）

> **现在：去雨巷咖啡馆看看。那里有短一点的活，也有不工作的座位。**

### cafe side gig 的最终位置

**运行资格不新增 Day 3 gate。**沿用已接受 Day-1/GamePlay 方向：

- `onboarding_complete == true`；
- cafe 已通过现有地图链可达；
- 玩家进入 cafe 后，side gig 可以作为次级互动被发现。

因此主动探索的玩家 Day 2 就可能先发现它；Day 3 只是第一次**导演主动 spotlight**。

不要新增 `day >= 3`、`park visited` 之外的永久资格状态；`park visited` 已经由现有地图链自然决定 cafe 是否可达。

### 玩家能比较的三种“卖时间”方式

- ordinary work：主要收入 + 技能成长 + 健康/心情成本；
- overtime：普通班后的追加收入，2 小时，成本更重；
- cafe side gig：90 分钟、固定较低收入、较轻成本。

核心认知：

> **赚钱不是一个按钮，而是时间被谁拿走。**

阿哲 12:00–14:00 可能自然出现在 cafe，是奖励，不是 gate。

---

## Day 4 — “城市里开始有人不是路人”

### 当前行动

> **现在：今天再去见一个你愿意认识的人。**

优先由玩家自己的路线选择：

- 老张：工作锚点；
- 陈姐：生活锚点；
- 老周：工作之外的价值对照；
- 阿哲：另一种生活方式的环境人物。

小雨不承担首周导演 gate。

### 为什么关系系统本身已经够用

现有规则：

- 每天同一 NPC 第一次完成对话 +4；
- 当天重复不涨；
- 20 = `认识`；
- milestone 已有“他记住了你的脸”。

如果 Day 1 起自然回访同一个人，Day 5 左右即可达到 `认识`。不需要新增关系系统，也不应该把 UI 写成“16/20，再点一次”。

---

## Day 5 — “重复工作有没有让我变得不一样”

### 当前行动

> **现在：看看这几天的工作有没有真的让你变熟。**

Day 5 第一次把已存在的 JobGrowth 逻辑解释成长期成长：

- 普通班不仅给钱，也攒熟练；
- skill 提升会进入更高岗位档位和工资；
- home study 用 1 小时直接换技能，但不赚钱、还掉心情；
- 休息保护状态，但不增长技能。

如果 q1 正卡 `skill >=55`，当日工作后可以自然推荐：

> **现在：回家练一小时，把手上的活练熟一点。**

不要求所有出身 Day 7 前都到 55。

---

## Day 6 — “给自己一段不属于公司的时间”

### 当前行动

> **现在：今天留一段不属于公司的时间。去哪，由你。**

Day 6 不新增地图和系统。

合法选择包括：

- park 恢复；
- cafe 休息 / side gig；
- home study / 做饭 / 休息；
- store 补给 / 陈姐；
- 仍然去工作 / overtime。

这里要证明“不工作一段时间”不是失败。

若 Pack A blocker 尚未解除，这一天仍然能靠现有地点活动成立。

---

## Day 7 — “这一周有没有变成你的生活”

### 当前行动

> **现在：把今天过完。晚上看看这一周留下了什么。**

Day 7 不发周失败，也不发新货币。

### 三锚点周总结

从现有状态派生：

**工作**
- Day 2+ 有正常工作记录 / q1 工作步已完成 → 有；

**熟人**
- 任一普通生活 NPC relation >=20 → 有；

**去处**
- onboarding 后 visited park 或 cafe → 有。

### 总结文案

**3/3**

> 一周过去了。你有了一份会重复的工作，一个开始认得你的人，还有一个下班后不是“回家倒下”的去处。城市没有变小，但你终于有了自己的路线。

**2/3**

> 这一周还谈不上站稳，但至少有两件事不再陌生。剩下那一件，下周再补。

**0–1/3**

> 第一周过完了。你还在被日子推着走，但你已经知道最缺的是哪一块。下周不用什么都解决，先解决一个。

### 第二周钩子

如果 q1 已完成或接近完成：

> **下周：光会干活还不够。你开始想知道，自己的时间到底值多少钱。**

这为 q2 / 谈薪线铺路，但不要求 Day 7 已谈成薪。

---

# 6. 地图第一周职责

| 地图 | Day 2–7 为什么去 | Spotlight | 首周角色 |
| --- | --- | --- | --- |
| home | 做饭、睡觉、study，把成长落回生活 | 每天自然返回；Day 5 study | 生活底盘 |
| subway | 通勤；偶遇阿哲 | 不单独做周目标 | 路线 |
| office | 普通工作、overtime、老张 | Day 2 起持续 | 收入/职业锚点 |
| store | 食物/背包、陈姐 | 需求驱动 | 生活补给锚点 |
| park | 免费恢复、工作外第一去处 | Day 2 后 | 第一张主动生活地图 |
| cafe | 咖啡/发呆/side gig、偶遇阿哲 | Day 3（可提前发现） | 第二种卖时间/恢复方式 |
| hospital | 健康出现理由时挂号恢复 | health <=55 | 风险修复点 |
| alley | 当前仍受线索+夜间条件控制 | 不 spotlight | 不属于首周日常线 |
| rooftop | 当前仍受 age>=40 / dark 条件控制 | 不 spotlight | 不属于首周日常线 |

### 不为内容库存破坏地图逻辑

现有 story unlock 明确：

- rooftop：age >=40 或 `dark_pursued`；
- alley：6 clues / `dark_alley_revealed` 且夜间。

第一周不为了“Pack A 各有 4 条事件”提前开放这两张图。

---

# 7. NPC：为什么值得第二次寻找

## 老张 — 工作锚点

Day 1：知道“工作上的事可以问他”。

Day 2–7：

- 他和真实 office 路线重叠；
- q2 已把他定义为后续职业人物；
- JobGrowth 已让 relation 45 的老张未来降低谈薪门槛；
- 首周至少能自然看到从陌生到认识的变化。

不要显示“每天 +4，刷到45”。

## 陈姐 — 生活锚点

- store 本来就因食物/背包反复需要；
- 07:00–23:00 稳定出现；
- young dialogue 和吃饭、身体、刚来到城市直接相关。

她代表“我下班以后也有一个会认出我的人”。

## 老周 — 工作之外的人

park 有恢复理由之后再让他变得重要。

- 06:00–11:30、15:00–19:30 在 park；
- storm 隐藏。

所以他只能是自然奖励，不能成为固定 Day-2 时间 gate。

## 阿哲 — 另一种活法

早晚在 subway，中午 12:00–14:00 在 cafe。首周不派硬任务，他的作用是告诉玩家“不是所有人都按同一种模板活”。

## Xiaoyu

按现有 schedule 可以存在、可以主动聊天，但 003 不把她写成周目标、回家奖励或必回访人物，不追加 roommate / romance / housing canon。

## 疯道士

不进入 Day 2–7 retention loop。暗线不是第一周主要续玩理由。

---

# 8. Pack A：首周候选，但当前仍全部 BLOCKED

## 8.1 当前状态

在 `GAME-CONTENT-014` 被接受并 QA 证明 ordinary city event 关闭不会长一岁以前：

> **20/20 Pack A 在 Day 2–7 runtime 继续 suppress。**

## 8.2 blocker 解除后的“安全默认”候选

### A — 可作为首周默认候选

**`e_cw01_cafe_charger`**

- age 22；
- 不要求物理在场的既有 schedule NPC；
- 小雨只是中性消息引用；
- 规模小，适合第一次 cafe 事件；
- 可写 `cw01_lent_cafe_charger` 给未来连续性。

**`e_cw01_cafe_gossip`**

- age 22；
- generic coworker；
- 工作几天后才有重量；
- network / skill / mood 有清楚取舍。

这两条是 014 解除后最安全的 Week-1 ordinary pool 起点。

### B — 好内容，但需要现有上下文被路由层证明后再开

**`e_cw01_park_free_class` / `e_cw01_park_lost_wallet`**

两条文案都把老周写在现场。现有普通 EventSystem schema 没有 NPC schedule 条件，所以只有当后续 ordinary-city 路由能复用现有 `NPCScheduleSystem` 确认“老周此刻真的在 park 且天气未隐藏”时才适合启用。否则保持 suppress，不让文案里的老周和场景里的老周互相打架。

**`e_cw01_park_rain_aunties`**

需要 `cw01_joined_park_class`。它很适合作为“世界记得上次选择”的后续，但应发生在后续日而不是同一天连刷。若 014 没有安全跨日 pacing，先 defer。

**`e_cw01_cafe_unpaid_trial`**

需要 `cw01_lent_cafe_charger`。同样适合后续日，但不能在 charger 刚结束后同一天连续倾倒。没有跨日 gate 就 defer。

### C — 第一周继续 suppress

- `e_cw01_park_recruiter_call`：age min 23，默认首周仍 22；
- `e_cw01_cafe_interview_prep`：把老张物理放在 cafe，但现有 schedule 没有 cafe slot，而且刚入职首周就模拟下一份面试会提前拉向跳槽；
- `e_cw01_hospital_kiosk`：把陈姐物理放在 hospital，而她 07:00–23:00 schedule 固定在 store；
- `e_cw01_hospital_report`：age min 25；
- `e_cw01_hospital_late_queue`：依赖 kiosk，且文案明确凌晨一点，现有普通 event 数据没有 hour gate；
- `e_cw01_hospital_medicine`：陈姐只是消息引用没有 schedule 冲突，但事件前提是假定已有处方；当前 clinic 活动没有持久化“已问诊/有处方”资格，首周不随机触发；
- 4 个 alley Pack A：地图首周不该破锁；
- 4 个 rooftop Pack A：地图首周不该破锁。

### 内容密度

014 解除后也不要求每天硬塞事件。首周重点是“地点有用途、人物可回访”。如果没有一个小而安全的每日 cap/显式入口，就宁可只开放 A 类少数候选，不另造大导演系统。

---

# 9. 系统如何互相驱动

## 工作 → 钱 / 技能 → 下班取舍

普通班给钱并推动技能，同时掉健康/心情；结果自然逼玩家考虑：恢复、补给、加班、短工、学习。

## 钱 → 时间强度

ordinary work / overtime / side gig 三种卖时间方式收益和状态成本不同，没有万能最优按钮。

## 关系 → 地点回访

- 老张绑定 office；
- 陈姐绑定 store；
- 老周绑定 park；
- 阿哲穿过 subway / cafe。

玩家因为生活路线见到人，而不是为了刷关系跑全城。

## 健康 / 心情 → 地图理由

- home = 做饭 / 睡觉；
- park = 免费缓一口气；
- cafe = 花钱恢复或短工；
- hospital = health warning 后的明确修复点。

## 技能 → 明天为什么还工作

重复工作会积累熟练；study 用不挣钱的一小时换更直接技能增长。Day 5 把这件事说清楚，工作才不是纯现金按钮。

## Pack A → 世界记忆（未来）

blocker 解除后优先做“上次发生过，所以这次不同”的链，而不是一次开放 20 个随机问答。

---

# 10. 每 5–10 分钟应该看到什么变化

第一周不要求固定每 5 分钟发奖励，但每一小段至少应有一种可感知反馈：

- 工资/健康/心情发生取舍；
- skill / work_exp 向下一档推进；
- 某 NPC 从陌生逐渐到认识；
- 新地点被解释出用途；
- 玩家主动选择“多赚一点 / 留点时间给自己”；
- Pack A 未来通过 remembered-choice 承认以前的选择；
- Day 7 把散落状态重新讲成“这一周变了什么”。

不能连续两三天只看到 `钱 +X / 健康 −Y` 而没有人物、地图或成长语义变化。

---

# 11. 给 00 的最小后续任务拆分

本 07 分支不实施以下生产改动。

## 01 Gameplay — `WEEK1-GAME-001`

### 前置

- `GAME-CONTENT-013` Day-1 onboarding gate 先接受；
- Pack A runtime 另依赖 `GAME-CONTENT-014`。

### 最小职责

1. 不新增 WeekSystem/save schema；从现有 day、quest progress、relations、visited、needs 派生：
   - week goal 三锚点状态；
   - 一个 `current_action`；
2. Day 2 起正常恢复 q1 evaluate/notify/reward；Day-1 onboarding 动作不倒灌；
3. q1/q2 只做后台进度，不覆盖 `本周/现在`；
4. 若首周极端路径激活 q3，不让 q3 自动成为 Week-1 主 HUD / 新 canonical route；
5. side gig 资格沿用 accepted 行为：onboarding 完成后，只要 cafe 现有地图链可达就可发现；Day 3 只是首次主动提示，**不加 day>=3 新 gate**；
6. health <=55 时允许 hospital current-action override；
7. Day 7 生成三锚点总结数据，不设失败；
8. `GAME-CONTENT-014` 前 Pack A 继续全 suppress；014 后按第 8 节 A/B/C 资格路由；
9. 不改 livelihood 数值、NPC schedule、alley/rooftop story unlock；
10. 保持 terminal/death ordering。

未来 verifier 建议：`tools/verify_day2_7_retention.gd`，需要后续明确授权。

## 02 Scene/UI — `WEEK1-UI-001`

1. onboarding 完成后 HUD 切为：
   - 弱：`本周：把“新来的”过成“能留下的人”。`
   - 强：`现在：...`
2. 三锚点只做小状态，不变成三条并列任务；
3. DailyRoutine 降为 `今日 x/4` / 小图标；
4. q1 任务名/进度允许弱显示，但不能和 `现在` 同权；
5. stage/dark/长期目标继续退出首周主 HUD；
6. 地图只做“为什么去”的 highlight/hint，不改 `VISIT_UNLOCKS` / story unlock；
7. Day 7 使用轻量总结，不新建大型周结算页；
8. 1280×720 / 960×540 两行目标与地点标题不冲突。

## 03 NPC/Content — `WEEK1-CONTENT-001`

在 `NPC-CONTENT-015` 首日 recognition micro-pass 之后做，避免同区域并发冲突。

最小职责：

1. q1 closing 的“这个月”改成“这几天 / 第一阵子”语义；**只改 copy，不改 step/condition/reward**；
2. q2 relation 文案不要把 `好感 20` 直接当玩家刷条目标，改成“让老张真正记住你”一类生活表达；
3. 老张/陈姐各补或调整一条 young repeat-contact copy，说明“为什么第二次还值得找”；
4. 老周/阿哲只做可选生活对照，不派首周硬任务；
5. q3 不扩写、不重解释 Xiaoyu；
6. 不重写已接受 20 个 Pack A；如未来要修 schedule/premise 冲突，单独窄任务处理。

---

# 12. QA / Codex 验证合同（003 未运行）

003 无 `tools/**` 写权限，只定义未来 exact-SHA 验证包。

至少验证：

1. first-night `onboarding_complete` 后 HUD 从 Day-1 L1 进入 `本周 + 现在`；
2. 三锚点只由已有状态派生，save/load 后一致，无新 save key；
3. Day 2 q1 恢复，但 Day-1 onboarding work/meal 不造成 q1 首日连跳；
4. q1/q2 后台进度不会覆盖 Week-1 主 HUD；q3 不自动变成首周主目标；
5. 同一 NPC 当天第二次聊天不涨关系；多日自然回访可以到 relation 20 / `认识`；
6. Day 2 park 提示是建议，不是 gate；没有老周也能用 park；
7. cafe 只通过现有 `park -> cafe` 解锁；side gig onboarding 后一旦 cafe 可达即可发现，Day 3 只做 highlight；
8. ordinary work / overtime / side gig 保持 GAME-CONTENT-012 accepted 数值和每天一次规则；
9. health <=55 时推荐 hospital，健康正常时 hospital 不成为强制旅游目标；
10. alley / rooftop 不因 Week-1 内容提前破锁；
11. `GAME-CONTENT-014` 未接受时 Pack A 20/20 继续 suppress；
12. 014 接受后 A 类候选关闭不会长一岁，legacy annual 年度路径仍保持；
13. B 类 park 事件只有现有 schedule/weather 能证明老周在场时才能进入 pool；
14. remembered follow-up 不在同日连续倾倒；
15. Day 7 三种锚点组合都只产生总结，不产生失败/终局；
16. 1280×720 / 960×540 HUD 可读；
17. Web/browser/render证据全部绑定同一个 frozen SHA。

本任务实际执行：

- Godot 4.7.2：**NOT RUN**；
- Web export/browser：**NOT RUN**；
- rendered UI：**NOT RUN**；
- animation/audio playback：**NOT RUN**。

不宣称任何 runtime/render/build/browser PASS。

---

# 13. 明确不要做

- 不新增 WeeklySystem、签到、周经验、周货币；
- 不把 DailyRoutine 四项变成每天必须全打勾；
- 不再次 suppress q1 到 Day 7，推翻已接受 onboarding 释放点；
- 不要求 Day 7 必须完成 q1；
- 不要求 Day 7 必须谈成薪；
- 不把 NPC 数值写成永久刷取目标；
- 不为 Pack A 打开 alley / rooftop；
- 不在 `GAME-CONTENT-014` 前启用普通 Pack A；
- 不让 hospital 变成旅游点；
- 不决定 Xiaoyu roommate / romance / housing canon；
- 不新增固定房租；
- 不新增 spouse/child；
- 不把暗线变成第一周强制钩子；
- 不用更多随机事件替代人物回访、地图用途和钱/时间/健康取舍。

---

# 14. 003 完成标准

如果 Day 2–7 最终实现正确，玩家在 Day 7 应该能自然说出：

> 我知道怎么挣钱，也知道多挣一点要拿什么换。
>
> 我开始认得这座城里一两个人，他们也开始认得我。
>
> 我有至少一个地方，不是因为“按钮亮了”才去。
>
> 这一周没让我变成人生赢家，但我开始有自己的路线。

下一周再问：

> **“我现在这样活着，值多少钱？我还要不要继续这么活？”**

而不是重新问玩家“要不要看 60 岁结局”。
