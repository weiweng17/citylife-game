# 《都市浮生》V1.0 Day 2–7 留存循环实施映射

> Task: `DIRECTOR-CONTENT-003`
> Branch: `agent/director-content-003-day2-7-retention`
> Baseline: accepted `DIRECTOR-CONTENT-002` exact tip `cebc2c868a52fcd719bbe3b5d6bd39917a17b82f`
> 作用：把已经确定的 Day 1 主线延伸成第一周可重复、会变化、但不重新变成“系统墙”的留存循环。
> 本文只定义体验、触发优先级、内容资格和后续任务边界；不修改生产代码、数据、UI、美术或音频。

---

# 0. 本轮导演结论

Day 1 回答的是：

> **“我能不能把第一天过下来？”**

Day 2–7 要回答的是：

> **“明天为什么还值得再过一天？”**

第一周不能只是把 Day 1 的 `做饭 → 通勤 → 工作 → 买东西 → 睡觉` 连续复制六次。

第一周的留存来自三件现有系统已经能表达的变化：

1. **工作在变熟**：普通班会继续推进技能/熟练度，工资档位和谈薪资格未来有真实后果；
2. **人开始记住我**：NPC 每天首次有效交谈 +4，好感到 20 会从“陌生人”变成“认识”；
3. **下班后的时间开始有代价**：回家恢复、去公园喘气、加班、便利店补给、咖啡馆临时帮工不能同时做完。

因此 Day 2–7 的设计不是再加一条长任务链，而是让玩家每天在同一个城市里看到一个新的问题：

- Day 2：昨天有人带着我走，今天我能不能自己过？
- Day 3：下班后的时间，是再卖一次，还是留给自己？
- Day 4：我为什么会想再去找某个人？
- Day 5：重复上班到底有没有让我变得不一样？
- Day 6：如果今天不围着公司转，我还会去哪里？
- Day 7：这一周到底留下了什么？

这六天必须形成**确定的体验节拍 + 非强制的玩家选择**。

---

# 1. 当前已接受输入与硬依赖

## 1.1 Day 1 主线已定

沿用 `DIRECTOR-CONTENT-002` 最终顺序：

`home 做饭 → subway → office 先找老张 → 普通工作 → 可选 overtime → store / 可选陈姐 → home 第一晚 → onboarding_complete`

本任务不重开 Day 1 方向讨论。

## 1.2 已接受的谋生活动

`GAME-CONTENT-012` 已在仓库层面接受：

- office overtime：普通班后才出现、每天一次、120 分钟、当前普通班工资的 60%、健康 −4、心情 −8；
- cafe side gig：每天一次、90 分钟、+55 money、健康 −2、心情 −4。

Day 2–7 只决定它们什么时候被玩家理解、如何进入选择层级；不改这些数值。

## 1.3 City Event Pack A 已接受，但仍有运行时 blocker

`NPC-CONTENT-012` 的 20 个 `e_cw01_*` 事件已经内容验收。

但是：

> **在 `GAME-CONTENT-014` 提供“不推进年龄/年份”的 ordinary-city-event 完成路径以前，Pack A 在运行时仍必须保持 suppressed。**

本文件会列出 Day 2–7 候选事件，但这只是**未来 eligibility 设计**，不是“现在已经可触发”。

同时：

- legacy annual events 继续保持在第一周前台之外；
- encounter / dark-line 不在第一周承担留存；
- 不通过 `_year_pass()` 来制造“内容很多”的假推进。

## 1.4 不新增系统

Day 2–7 不新增：

- WeekSystem；
- 新 save schema；
- 新货币；
- 固定房租结算；
- 周失败态；
- 周奖励树；
- 新职业树；
- 恋爱 / 婚育 / 室友 canon；
- 新地图。

所有提示和总结应尽量从现有 `day / flags / relations / visited / DailyRoutine / skill / work_exp / money / health / mood` 推导。

---

# 2. 第一周唯一周级动机

第一周只保留一个周级问题：

> **本周目标：把“新来的”过成“能留下的人”。**

这不是三条硬任务，也没有 Day 7 前必须完成的判定。

玩家应逐渐从三个方向感到自己“开始留下来”：

- 工作不再完全陌生；
- 至少有一个人开始记住自己；
- 自己知道累了、缺钱、饿了以后该去哪里解决。

关系系统提供第一周最容易被看见的里程碑：每天同一 NPC 只有第一次有效交谈 +4，20 即进入既有“认识”档。Day 1 已见老张后，如果玩家之后隔天继续回访，最早 Day 5 左右就能自然看到一次“他记住了你的脸”的世界反馈；但这只是周目标的**可见证明之一**，不是七天内强制刷到 20 的失败条件。

### 为什么不直接用 q1

当前 `q1_stand_firm` 不适合当第一周前台：

- `skill >= 55` 对四出身差异很大；
- `money >= 3000` 有的出身开局即满足，有的出身需要很久；
- q1 closing 写的是“这个月”，如果 Day 2–7 完成会产生明显语义错位；
- q1 串行步骤会把“第一周自己决定怎么过”重新变成固定清单。

所以 Day 2–7：

> **q1–q3 不作为前台周目标，也不允许其 evaluate / notify / reward / closing 在第一周抢走节奏。**

推荐 Gameplay 至少到 Day 7 结束前继续保持其首周 suppression。尤其是高技能/高资金出身，否则可能 Day 2 很快穿过 q1 多个阈值并弹出“这个月”收尾。

本文件不决定 Day 8 后如何重写 q1–q3；那应由后续 quest pacing/content task 单独处理，不能把“第一周结束”误解为“旧任务原样重新打开”。

---

# 3. HUD：从 Day 1 单 L1 转成“两行留存结构”

Day 1 的 onboarding 只有一个强 L1 `现在：...`。

Day 2 醒来后，不再继续用教程级大字牵手。

## 3.1 Day 2–7 固定两行

### A. 本周目标 — 小、稳定、不频繁变化

> **本周：把“新来的”过成“能留下的人”。**

它只提供方向，不列 10 万、60 岁、六碎片和未来家庭目标。

### B. 当前行动 — 比周目标更醒目，但不是“失败倒计时”

格式：

> **当前：{今天最值得考虑的一件事}**

它每天可以换一次主题，地点内根据上下文短暂变化，但不能重新堆成四个并列任务。

## 3.2 其他信息层级

### 三级：今日 DailyRoutine

保留：

`通勤 / 工作 / 吃饭 / 休息`

但它只是“今天发生了什么”的状态回顾，不再用“第一个未完成项”支配玩家。

### 四级：资源

保持现有：

- 钱；
- 健康；
- 心情；
- 饱食；
- 精力；
- 时间 / 天气；
- 技能 / 岗位档位。

### 第一周继续隐藏 / 降级

- `立足 / 成家 / 立业 / 归途` 的 22–60 岁阶段大目标；
- 暗线碎片计数与追查状态；
- q1–q3 前台步骤与奖励提示；
- 10 万 / 50 万 / 200 万长期数字；
- 朋友 70 等关系终点；
- 老张帮腔的精确 45 门槛；
- 退休 / 最终人生结局。

第一周必须先让玩家关心“明天”，再让他关心“38 年以后”。

---

# 4. Day 2–7 每日导演节拍

这些是**体验锚点，不是失败条件**。

玩家可以绕开某个可选地点，也不会卡住下一天。

---

## Day 2 — “今天没人牵着我了”

### 周目标

> 本周：把“新来的”过成“能留下的人”。

### 早晨当前行动

> **当前：今天自己去公司，把第二天过顺。**

Day 2 是第一天教程撤掉后的回归测试。

玩家应该自己完成：

`home → subway → office → ordinary work`

不再逐站弹教学。

### 为什么 Day 2 仍建议完成一次普通工作

第一周必须先证明：

> “我已经学会这个循环了，不需要 Day 1 一样每一步被指挥。”

完成第二次普通班后，当前行动改成：

> **当前：下班后的时间，选一件对明天有帮助的事。**

这时玩家第一次被正式释放到多选层：

- 直接回家 / 做饭 / 休息；
- 去便利店补给 / 找陈姐；
- 可选 overtime；
- 去公园免费恢复；
- 如果已经自然到达 cafe，则看见 cafe 的普通活动与 side gig。

### Day 2 第一次给公园一个理由

公园不是“office visit 后自动亮了所以去看看”。

第一次被提及时应该写成：

> 今天不想立刻回家，可以去公园坐一会儿。**不花钱，也能把人缓回来一点。**

现有 park `bench / pond` 已足以承担这个功能。

老周可以按现有日程出现，但**不要求 Day 2 必须见到老周**：他 11:30–15:00 有空窗，storm 也会隐藏，不能把他做成硬 gate。

### Day 2 留存反馈

一天结束时玩家应有一个明确认知：

> “昨天我只是被教会，今天我已经能自己过一遍。”

---

## Day 3 — “时间可以卖给不止一个地方”

### 当前行动

> **当前：今天别照抄昨天。下班后，决定是多赚一点、恢复一点，还是见个人。**

Day 3 不强制普通工作以外的新系统，只把已经存在的选择摆到同一价值框架里。

### cafe side gig 的最终导演位置

#### 运行资格

沿用已派发的 Day-1 Gameplay 合同，不制造冲突：

- `onboarding_complete == true`；
- Day 2+；
- cafe 本身已经正常可达。

因此一个主动探索、Day 2 就进入 cafe 的玩家，可以在 cafe 场景里提前发现临时帮工；不需要等到 Day 3 才“解锁”。

#### 展示原则

**不要在 Day 2 起床时全局广播“咖啡馆可打工”。**

第一次可见只应发生在 cafe 内部，作为次级行动：

> 临时帮工 · 90 分钟 · +55 · 健康−2 · 心情−4 · 今日一次

这样它是“我在城市里发现了另一种挣钱法”，不是又一条强制教程。

#### 第一次主动 spotlight

Day 3 才第一次用泛化文案提示：

> 城市里不只公司能换钱。看到临时活时，你可以接，也可以把时间留给自己。

不要强制玩家为了任务去 cafe，也不要在 cafe 尚不可达时显示一个无效目的地。

### 玩家此时应该能比较的三种卖时间方式

- ordinary work：主收入 + 技能成长 + 明显健康/心情成本；
- overtime：普通班后的额外钱，继续消耗健康/心情；
- cafe side gig：更低收入、更短时长、不同强度的成本。

这三个选项必须共同证明：

> **“赚钱”不是一个按钮，而是时间被谁拿走。**

Day 3 不要求玩家实际做 side gig；“知道它存在”已经完成这个设计目的。

---

## Day 4 — “城市里开始有人不是路人”

### 当前行动

> **当前：今天找一个你愿意再见的人。**

这不是 NPC 收集任务。

玩家可以自然选择：

- 公司里的老张；
- 便利店陈姐；
- 公园老周；
- 通勤遇到的阿哲。

小雨不承担本周导演 gate，避免继续加深未决 roommate / romance / housing canon。

### 关系系统如何自然制造第一周里程碑

现有关系规则：

- 每天第一次有效交谈 +4；
- 同一天重复聊天不增加；
- 20 = “认识”。

如果玩家 Day 1 见过老张，并 Day 2–5 大致每天聊一次，最早 Day 5 左右会自然跨到“认识”。

这已经是一个很好的周中留存点，不需要新关系系统。

### UI 不要把它做成刷数值

第一周不显示：

> 老张 16 / 20，再点一次升级。

优先显示世界反馈：

> （他记住了你的脸。）

玩家应该感到“这个人开始认得我”，而不是“经验条升级”。

---

## Day 5 — “重复工作必须证明自己不是原地踏步”

### 当前行动

> **当前：看看这几天的工作有没有真的让你变熟。**

Day 5 的重点不是再开一个地图，而是把已经存在的 JobGrowth 反馈抬到前台一次。

玩家应看到：

- 当前技能值；
- 当前岗位档位（学徒 / 上手 / 熟练等）；
- 距离下一次技能提升的熟练度进展，或至少一句“离下一档还有多远”的可读反馈；
- “熟练”以后才有资格谈薪这一事实可以第一次被轻描淡写地提到，但不要展示完整公式。

### home study 在这里第一次有明确战略理由

Day 1 不需要教学 study。

Day 5 开始，home study 不再只是“按钮 +3 skill”，而是：

> 今天少卖一点时间，把一个小时拿来让自己更值钱。

这给玩家一个新的工作成长路径：

- 上班：挣钱 + 慢慢长熟练；
- 学习：花时间、不赚钱、技能增长更直接；
- 休息：不增长技能，但保护状态。

不需要新增任何系统。

---

## Day 6 — “给自己留一段不属于公司的时间”

### 当前行动

> **当前：今天留一段不属于公司的时间。去哪，由你。**

Day 6 是第一周最自由的一天。

导演目的：

- 玩家知道不完成普通工作也不会触发“周失败”；
- 让 home / park / cafe / store 变成生活地点，而不仅是上班间隙的功能按钮；
- 如果 Pack A 运行 blocker 已经被解决，这是最适合让普通城市事件显露连续性的时段。

玩家可以：

- 公园恢复；
- 咖啡馆坐一会儿；
- 接一次 side gig；
- 在家学习 / 做饭 / 休息；
- 去便利店补给 / 找陈姐；
- 仍然选择去公司上班。

所有选择都合法。

---

## Day 7 — “这一周留下了什么”

### 当前行动

> **当前：把今天过完。晚上看看这一周留下了什么。**

Day 7 不加 boss fight，也不加大奖励。

第一次周总结应该只做一件事：

> **把现有状态重新讲成人生变化。**

### 周总结使用现有状态即可

至少展示：

- 当前 money；
- 当前 health / mood；
- 当前 skill + 岗位档位；
- 关系最高或最有意义的一个已见 NPC 的关系标签；
- 已经有明确用途的地点（home / office / store / park / cafe 里实际 visited 的部分）。

不需要为了总结新增“周积分”。

### 建议收尾文案框架

> 一周过去了。
>
> 你还是会累，也还没真正站稳。
>
> 但地铁哪边下车、工位在哪、饿了去哪、累了去哪，已经不用别人再告诉你。
>
> 而且这座城市里，开始有人会认出你。

动态一句根据现有状态补充：

- 如果某 NPC 已到 acquaintance：`至少有一个人已经会主动跟你打招呼。`
- 否则：`你还没有真正认识谁，但已经知道下一次想去找谁。`

### Day 8 钩子

> **下一周：不只是留下，还要让这份工作开始更值钱。**

这里可以为未来谈薪/技能/关系线做准备，但本任务不直接开启旧 q2，也不把谈薪公式塞进周总结。

---

# 5. 第一周地点目的表

| 地点 | Day 2–7 的第一周目的 | 第一次主动 spotlight | 是否第一周核心 |
| --- | --- | --- | --- |
| home | 做饭、睡觉、学习、状态恢复 | Day 5 把 study 变成成长选择 | 是 |
| subway | 日常通勤、让阿哲作为城市背景重复出现 | Day 2 自主通勤 | 是 |
| office | 普通收入、技能成长、老张、可选 overtime | 每个工作日按玩家选择 | 是 |
| store | 食物/背包补给、陈姐生活锚点 | Day 2–4 需求驱动 | 是 |
| park | 免费恢复、让“下班不等于继续赚钱”成立、老周 | Day 2 工作后 | 是，作为第一恢复地图 |
| cafe | 休息、见人、side gig、未来 Pack A 社交事件 | 玩家自然到达后；Day 3 可第一次轻提示 | 次核心 |
| hospital | 真正的健康问题出现时才是答案 | health 进入 HUD warning 区（<=55）或以后有明确内容理由 | 条件型 |
| alley | 当前没有第一周普通生活必需理由 | 不主动 spotlight | 否 |
| rooftop | 当前偏中后期/重大情绪节点 | 不主动 spotlight | 否 |

## 医院规则

现有 HUD 在 health <=55 已进入 warning 色。

第一周可以直接复用这个玩家已经看得到的阈值：

> **健康进入黄色区以后，医院才应该作为“可能有用”的地点被提醒。**

不要因为 store technical visit unlock 就把医院当旅游地图主动展示。

## alley / rooftop 规则

Pack A 虽然已经各有 4 个事件，但这不构成“第一周必须开放地图”的理由。

第一周不要为了消费内容库存而破坏地图目的。

---

# 6. NPC：第一次“再去找他”的理由

## 6.1 老张 — 工作连续性

Day 1：

> 他知道这份工作怎么活下去。

Day 2–7 的重复理由：

1. 他每天都在玩家真正会去的 office；
2. 每天第一次交谈才有关系增长，天然阻止刷点；
3. 关系未来会真实影响谈薪；
4. “认识”里程碑最快能在第一周中段发生。

### 第一周玩家记忆句

> **“我不是为了 +4 去找他，是因为他比任务栏更懂这份工作。”**

03 后续文案应该让至少一条 young dialogue 是可执行的职业生活建议，而不是只有价值观金句。

---

## 6.2 陈姐 — 生活连续性

Day 1：

> 她知道附近怎么生活。

Day 2–7 的重复理由：

- 便利店本来就会因为吃饭/背包产生重复需求；
- 她 07:00–23:00 长时间稳定出现；
- 她适合承接“晚归、吃饭、身体别硬撑”的普通生活反馈。

第一周不需要强迫陈姐关系达到 20。

她的价值是：

> **“我去买东西时，有个人会逐渐认出我。”**

---

## 6.3 老周 — 工作之外的价值判断

第一次有意义出现：park 已经因为恢复需求被 spotlight 以后。

不要为了见老周要求玩家在他的 schedule 等待。

他的第一周功能：

> **提醒玩家‘慢一点’也是一个合法选择。**

他非常适合承接 `e_cw01_park_free_class`，但该事件在 GAME-CONTENT-014 前仍不可运行。

---

## 6.4 阿哲 — 城市里的另一种活法

Day 1 他只是 subway ambient NPC。

Day 2–7 可以慢慢变成：

> **“不是每个人都在公司里卖时间。”**

他不需要第一周关系任务。

现有 schedule 让他早晚出现在 subway、午间出现在 cafe，已经足以形成“这个人也有自己的日常路线”的感觉。

---

## 6.5 小雨

第一周不把她绑定到周目标、回家必触发或关系 milestone。

理由不是她不重要，而是当前 roommate / close friend / romance possibility / housing canon 尚未由 00/用户最终确定。

现有角色可以继续存在；本轮不再向任何方向追加 canon。

---

## 6.6 疯道士

第一周不 spotlight。

暗线仍是第二层内容，不参与 V1.0 第一周留存主循环。

---

# 7. Pack A：Day 2–7 候选资格表

再次强调：

> **下面所有 Pack A 事件在 `GAME-CONTENT-014` 被接受前，runtime eligibility = false。**

本节只是为 blocker 解除后的第一周 ordinary-city pool 排顺序。

## 7.1 第一优先：早周“种子事件”

### `e_cw01_park_free_class`

推荐最早：Day 2。

原因：

- park 已经有“免费恢复”的生活理由；
- 老周自然出现；
- 健康 / 心情 / 人脉之间有小取舍；
- 会写 `cw01_joined_park_class`，后续可产生真正的“昨天影响今天”。

### `e_cw01_park_lost_wallet`

推荐最早：Day 2–3。

原因：

- 不要求前置 flag；
- 选择非常容易理解；
- 金钱、心情、人脉之间有真实冲突；
- 不牵涉家庭/恋爱/职业大转折。

### `e_cw01_cafe_charger`

推荐最早：Day 3。

原因：

- cafe 在第一周已经有休息/side-gig 的普通生活理由；
- 冲突很轻，不抢主线；
- 会写 `cw01_lent_cafe_charger`，为后续回应事件埋种子；
- 小雨只是一句中性消息，不扩大 housing / romance canon。

### `e_cw01_cafe_gossip`

推荐最早：Day 4。

原因：

- 玩家已经在公司过了几天后，“同事消息”才有重量；
- 网络 / 技能 / 情绪有清晰取舍；
- 不要求玩家换工作或马上谈薪。

---

## 7.2 第二优先：晚周“回应事件”

### `e_cw01_park_rain_aunties`

推荐：Day 5–7，仅当 `cw01_joined_park_class == true`。

这是第一周最值得保留的连续性例子之一：

> 上次见过的人这次认出了你。

这比再加一个新 NPC 更有留存价值。

### `e_cw01_cafe_unpaid_trial`

推荐：Day 5–7，仅当 `cw01_lent_cafe_charger == true`。

作用：

- 昨天的小善意产生后续；
- “免费试稿”是普通打工人能理解的边界问题；
- 继续让 cafe 成为人和工作混在一起的地点，而不只是 +mood 房间。

---

## 7.3 条件型：玩家已经因健康进入 hospital

### `e_cw01_hospital_medicine`

只有玩家已经因为健康/问诊理由来到 hospital 时，才适合进入第一周 pool。

它很好地把：

`钱 ↔ 健康 ↔ 心情`

放在一个具体选择里。

### `e_cw01_hospital_kiosk`

同样只在 hospital 已有生活理由时使用。

它可以让陈姐从“便利店的人”出现在另一个现实场景里，但不能反过来为了触发这条事件强迫玩家去医院。

---

## 7.4 第一周暂不优先

### `e_cw01_park_recruiter_call`

事件 age 最低为 23；正常第一周玩家仍是 22 岁，所以它本来就不是 Day 2–7 主候选。

### `e_cw01_cafe_interview_prep`

内容本身质量可用，但第一周玩家刚稳定第一份工作，立即“模拟面试”会过早把注意力拉向跳槽/外部求职。

建议第二周以后，或等技能/谈薪线开始时再 spotlight。

### `e_cw01_hospital_report`

事件 age 最低为 25；默认 22 岁首周不属于候选。

### alley 全组

第一周没有足够强的普通生活地图理由，且 landlord repair 还带住房语义风险。

不因为有 4 条内容就提前开旧巷。

### rooftop 全组

当前 rooftop 更适合中后期/重大情绪节点。

第一周不为消费内容而开放。

---

# 8. Pack A 解锁后的 ordinary-city pool 规则

`GAME-CONTENT-014` 被接受以后，第一周也不能直接把 `events.json` 的所有 22 岁事件重新放回池里。

推荐第一周 ordinary-city path 使用：

- 只允许明确归入 ordinary pool 的 `e_cw01_*`；
- Day 2–7 优先使用本文件列出的 allowlist；
- legacy annual events 继续走原有年度路径，不进入 minute-scale pool；
- ordinary event 关闭后**绝不能 `_year_pass()`**；
- used/event flags 继续走现有 save 字典，不新增 schema；
- 不让 dark encounter 与普通事件在同一次地点行动里连续抢屏。

### 第一周内容密度

不建议每天都强塞随机事件。

第一周 Pack A 的理想作用是：

> **在 2–3 个普通日子里，让城市突然回应一次玩家。**

而不是：

> 每次点“在这里行动”都弹一张选择题。

如果 Gameplay 需要一个简单默认：

- 每个 in-game day 最多主动 spotlight 一个 ordinary city event；
- 其余时间让地点原生活动正常工作。

如果实现这个 cap 会扩大 GAME-CONTENT-014 范围，则宁可暂时只做“显式事件入口/低频触发”，不要再造复杂随机导演系统。

---

# 9. Day 2–7 留存循环：系统之间怎么互相驱动

## 工作 → 技能 / 钱 → 下班选择

普通班给钱、技能进展，同时掉健康/心情。

结果不是“再点工作”，而是迫使玩家考虑：

- 去公园免费恢复；
- 回家休息；
- 花钱补给；
- 继续 overtime；
- 换成 cafe side gig；
- 学习让未来工作更值钱。

## 关系 → 地点回访

玩家不是为了“全城刷 +4”，而是因为：

- 老张在 office；
- 陈姐在 store；
- 老周在 park；
- 阿哲贯穿 subway / cafe。

人物功能和地点功能绑在一起，回访才有生活感。

## 健康 / 心情 → 地图理由

低状态不是只把条变色。

第一周至少要做到：

- park = 免费缓一口气；
- home = 休息 / 做饭；
- hospital = health warning 后才主动被提醒。

## 技能 → “明天为什么还上班”

玩家要知道普通班不是纯现金按钮。

Day 5 前后至少一次把“离下一档更近了”讲出来。

## Pack A → “昨天的选择今天有人记得”

优先使用 `park_free_class → park_rain_aunties`、`cafe_charger → cafe_unpaid_trial` 两条连续性链。

这是第一周比“再加 20 条随机事件”更重要的留存价值。

---

# 10. 第一周不允许出现的体验回退

Day 2–7 实施以后，仍然禁止：

- Day 2 一醒来重新展示 22–60 岁目标墙；
- q1 closing 在 Day 2–7 说“这个月已经过完”；
- q1–q3 reward/toast 在第一周抢过 week/current-action 层级；
- Pack A ordinary event 关闭后年龄 +1；
- 因为 office 技术解锁了 park/store，就立刻把所有后续地图同时亮成主目标；
- 因为 cafe side gig 存在，就做成“每日必打卡”；
- 因为老张关系有数值，就要求玩家每天重复刷对话；
- 因为 hospital 有内容，就逼健康正常玩家去逛医院；
- 因为 alley/rooftop 有 Pack A，就提前破坏地图叙事顺序；
- 第一周强制小雨成为室友/恋爱/回家奖励；
- 暗线在第一周变成主要续玩钩子；
- 额外增加一套周任务货币/周经验/签到奖励。

---

# 11. 精确后续任务拆分（供 00 审核后派发）

以下只是一组**最小 handoff 合同**。本 07 分支没有实现这些生产改动。

---

## 01 Gameplay — `WEEK1-GAME-001`（建议）

### 依赖

- `GAME-CONTENT-013` 先接受 Day-1 onboarding gate；
- Pack A 的任何运行时启用必须再依赖 `GAME-CONTENT-014`。

### 目标

在不新增 WeekSystem/save schema 的前提下，把 `onboarding_complete` 后的 Day 2–7 切到 first-week mode。

### 最小职责

1. `onboarding_complete` 后不再使用 Day-1 强 L1 状态机；
2. 暴露一个简单的 Day 2–7 `week_goal + current_action` 文本状态给 UI；
3. Day 2 生成“自己完成一次日常”的当前行动；
4. Day 3–6 根据本文 day beat 只给一条轻提示，不把它们做成失败 gate；
5. Day 7 / 首次跨到 Day 8 时生成一次周总结数据；
6. q1–q3 在 Day 2–7 继续不 evaluate/notify/reward/closing 抢屏；
7. legacy annual / encounter / dark 不进入 first-week foreground；
8. side gig 保持 `onboarding_complete + Day2+ + cafe reachable` 的既定资格，不改 GAME-CONTENT-012 数值；
9. side gig Day 3 只是第一次主动 spotlight，不是新的解锁门槛；
10. 不要求玩家完成 overtime / side gig / 特定 NPC 关系才跨天；
11. 不新增 save schema；所有判定尽量用现有 day/flags/relations/visited/daily/skill/health/mood。

### 与 GAME-CONTENT-014 的边界

`WEEK1-GAME-001` 不自己重写 EventSystem 年度语义。

在 `GAME-CONTENT-014` 接受之前：

> Pack A first-week eligibility 必须仍为 0。

在 `GAME-CONTENT-014` 之后，才按本文件第 7–8 节 first-week allowlist 进入 minute-scale pool。

### 建议 verifier 合同

后续由 01/04 明确归属：

`tools/verify_week1_retention.gd`

至少断言：

1. Day 1 → Day 2 后 onboarding L1 释放；
2. Day 2–7 每次只有一条 current action；
3. week goal 文案稳定，不被 stage/q1/dark 覆盖；
4. q1–q3 不在第一周结算月级 closing/reward；
5. 同一 NPC 同日第二次聊天不涨关系；
6. Day 1 + Day 2–5 各一次老张聊天可以自然到 20；
7. side gig Day 1 不可见，Day 2+ cafe 内可见且每天一次；
8. Day 3 的 side-gig 提示只是提示，不阻塞其它路线；
9. park/home/store/office 不依赖 Pack A 也能组成完整 Day 2–7 fallback；
10. GAME-CONTENT-014 未接受时 Pack A 仍不触发；
11. 014 接受后 first-week ordinary event 不触发 `_year_pass()`；
12. Day 7 → Day 8 周总结只展示状态，不发重复奖励；
13. save/load 不让 week/current-action 状态倒退到 onboarding。

**本 07 任务没有运行 Godot，也没有创建 verifier。**

---

## 02 Scene/UI — `WEEK1-UI-001`（建议）

### 目标

把 HUD 从“教程命令”平滑过渡到“周方向 + 当下选择”。

### 最小职责

1. Day 2 起显示两行：
   - `本周：把“新来的”过成“能留下的人”。`
   - `当前：...`
2. current action 视觉权重大于 week goal，但明显弱于 Day-1 onboarding 大目标；
3. DailyRoutine 继续降级为回顾状态；
4. stage / dark / q1–q3 第一周不重新挤回同一行；
5. 地点导航可以用轻量高亮/说明体现“为什么去”，但不要一次展开全部地图；
6. hospital 只在健康 warning / 明确内容理由时得到提示；
7. cafe side gig 只在 cafe 内作为次级 action，不做 Day 2 全局 banner；
8. Day 7 周总结复用现有 DialogUI/toast/已有容器优先，不为了总结新增大型 UI 系统。

### 验收

需要后续 QA 在同一 frozen SHA 上验证：

- 1280×720；
- 960×540；
- week/current/daily/resources 不重叠；
- 长中文文案不挤掉地点标题；
- Day 1 → Day 2 层级变化肉眼可辨。

本 07 web task 不声称 rendered PASS。

---

## 03 NPC/Content — `WEEK1-CONTENT-001`（建议）

### 依赖

先完成/接受 `NPC-CONTENT-015` 的 Day-1 老张/陈姐 recognition micro-pass，避免同一 `Data.gd` 区域并行冲突。

### 目标

只补足“为什么第二次还想找这个人”的 young-dialogue 语义，不新增关系系统。

### 最小内容职责

- 老张：至少一条能给 Day 2–7 玩家具体职业生活建议，而不是只讲大道理；
- 陈姐：至少一条围绕吃饭 / 晚归 / 身体别硬撑的生活反馈；
- 老周：至少一条明确认可“今天不工作也可以喘口气”的价值；
- 阿哲：至少一条表达“城市里还有另一种活法”，但不把卖唱浪漫化成无成本逃离工作；
- 不展示 20 / 45 / 70 等关系门槛数字；
- 不决定小雨 roommate / romance / housing canon；
- 不新增暗线第一周强制对白。

### Pack A 内容边界

本任务不需要重写已接受的 20 个 Pack A 事件。

只需在 report 里确认 first-week 推荐顺序：

- early seeds: `park_free_class`, `park_lost_wallet`, `cafe_charger`, `cafe_gossip`；
- late acknowledgements: `park_rain_aunties`, `cafe_unpaid_trial`；
- hospital conditional: `hospital_medicine`, `hospital_kiosk`；
- alley/rooftop deferred。

运行资格仍由 Gameplay/014 负责。

---

# 12. QA / Codex 验收包（仅定义，未运行）

未来必须在一个 frozen integration SHA 上实际运行。

## 12.1 fallback 周循环（Pack A 仍关闭）

从 Day 2 开始连续过到 Day 8：

- 至少完成 Day 2 一次 ordinary work；
- 至少一次选择 park/home 做恢复；
- 至少一次进入 store；
- cafe 如果自然可达，确认 side gig；
- 和同一个 NPC 同一天聊两次，第二次不涨关系；
- 至少让一个 NPC 连续几天增长关系并观察 20 档里程碑；
- 至少一次选择“不工作/不加班”仍能正常跨天；
- Day 7 进入 Day 8 后出现一次周总结；
- 全程没有 legacy annual `_year_pass()`、q1 月级 closing/reward、暗线强制 takeover。

## 12.2 Pack A 解锁后追加

仅在 `GAME-CONTENT-014` exact tip 已进入 candidate 后：

- 从 park 触发一个 first-week seed；
- 从 cafe 触发一个 first-week seed；
- seed 写 flag 后，后续 acknowledgement 可以成为候选；
- ordinary event close 不推进年龄/年份；
- legacy annual event 仍保持原有独立路径；
- hospital 事件只在 hospital 已有健康理由时测试 first-week exposure；
- alley/rooftop 不因为 Pack A 自动提前开放。

## 12.3 Runtime / rendered / browser

本任务未运行：

- Godot 4.7.2：**NOT RUN**；
- Web export：**NOT RUN**；
- browser console/network：**NOT RUN**；
- 1280×720 / 960×540 rendered UI：**NOT RUN**；
- audio / animation playback：**NOT RUN**。

任何后续 PASS 必须绑定同一个 frozen SHA。

---

# 13. 第一周完成标准

Day 7 结束时，不要求玩家完成一个大型任务树。

只要求体验上能回答：

### 我为什么继续上班？

> 因为它不只给钱，也在让我更熟、更值钱。

### 我为什么不每天都加班？

> 因为时间、健康和心情真的会被拿走。

### 我为什么会回到同一个地方？

> 因为公园、便利店、咖啡馆、家分别解决不同生活问题，不只是不同背景。

### 我为什么会再去找一个 NPC？

> 因为他/她在我的生活里有具体作用，而且开始记住我。

### 我为什么想进入第二周？

> 因为第一周只是学会留下；下一周开始，我想让自己的工作和生活变得更像自己的选择。

---

# 14. 00 审核时只需确认的决定

1. 接受第一周唯一周级动机：`把“新来的”过成“能留下的人”`；
2. 接受 Day 2–7 使用 `本周目标 + 当前行动` 两行，而不是恢复人生目标墙；
3. 接受 cafe side gig **Day 2+ cafe 内可发现、Day 3 才第一次主动轻提示**，并且永远不做周必做项；
4. 接受第一周 Pack A 优先序，但在 `GAME-CONTENT-014` 前 runtime eligibility 仍为 0；
5. 接受 park Day 2、cafe Day 2+、hospital 状态驱动、alley/rooftop 第一周不主动开放的地图顺序；
6. 接受 q1–q3 至少到 Day 7 结束前继续退出前台并保持结算抑制，由后续 quest pacing task 决定何时/如何恢复。

如果这些被接受，00 可以直接按第 11 节拆给 01/02/03，不需要再做一轮产品方向讨论。
