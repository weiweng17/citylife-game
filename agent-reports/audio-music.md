# Audio / Music Agent Report

## Agent
- Lane: 06-Audio-Music
- Owner key: `audio-music`
- Coordination branch audited: `orchestrator/multi-agent-bootstrap`
- Task branch: `agent/audio-audit-001-sound-system`

## Current task
- ID: AUDIO-AUDIT-001
- Status: **NEEDS_REVIEW**
- Priority: HIGH
- Task type: report-only audit / planning

## Control / scope note
- The coordination board currently records development execution as paused by the user. This report is planning-only and was produced from the user's direct 06-Audio-Music audit instruction; it does **not** resume production work.
- Writable scope for this task is `agent-reports/audio-music.md` only.
- No production audio, scripts, `project.godot`, `main`, or coordination files were modified.
- No music/SFX/ambience was generated or downloaded in this task.
- No sound has been played in Godot or a browser, therefore this report makes **no playback, mix, runtime, render, or Web PASS claim**.

---

# 《都市浮生声音设计与资产需求表 v1》

- 审计日期：2026-09-14
- 审计目标：建立《都市浮生》“雨夜城市普通人生活模拟”的完整声音体系规划，覆盖音乐、环境声、动作/UI SFX、来源合规、循环/淡入淡出和 Godot 接入点。
- 审计输入：`HANDOFF.md`、`docs/ARCHITECTURE.md`、`docs/ITERATION_PLAN.md`、`docs/agents/MASTER_PLAN.md`、`docs/agents/TASK_BOARD.md`、`docs/agents/FILE_OWNERSHIP.md`，以及 `assets/**`、`scenes/**`、`scripts/world/**`、`scripts/systems/*Activities.gd`、`scripts/ui/**`、工程配置与核心系统。

---

## 1. 音频生产审计

### 1.1 仓库现状

| 审计项 | 结论 | 证据 / 备注 |
| --- | --- | --- |
| BGM 文件 | **未发现** | 协调分支完整树未发现 `.ogg` / `.wav` / `.mp3` / `.flac`；`HANDOFF.md` 与 `ITERATION_PLAN.md` 也明确记录项目当前无音频资源。 |
| 环境声文件 | **未发现** | 同上。 |
| UI 音效 | **未发现** | `HUD.gd`、`DialogUI.gd`、`EventUI.gd`、`ShopUI.gd`、`StartUI.gd`、`EndingUI.gd` 只有按钮 / signal / UI 生命周期，没有音频播放。 |
| 行走声音 | **未发现** | 当前地点移动集中在 `LocationManager._advance_path()` / `_move_player()`；无步频累计、脚步素材或播放逻辑。 |
| 场景音效 | **未发现** | 九个地点均有视觉/交互配置，但没有声音 profile。 |
| NPC / 交互音效 | **未发现** | `SpotActivities.gd` 有统一 `activity_requested(id)`，NPC / 对话 / 关系有明确回调，但没有 SFX。 |
| `AudioStreamPlayer` / `AudioStreamPlayer2D` | **未发现** | `Main.tscn`、检查过的场景和代码搜索均未发现。 |
| `AudioServer` | **未发现** | 仓库代码搜索无结果。 |
| Godot Audio Bus | **未发现项目级配置** | `project.godot` 无音频相关配置；仓库树未发现 `default_bus_layout.tres`。 |
| 音量设置 | **未发现** | 没有 Master / Music / Ambience / SFX / UI 音量选项或持久化设置。 |
| 淡入淡出 | **未发现** | 没有 music/ambience crossfade、duck、Tween 音量过渡。 |
| 场景切歌 | **未发现** | `LocationManager.current_location` / `travel_requested` 已存在，但没有 Audio Director / Music state。 |
| 昼夜声音切换 | **可接入，未实现** | `TimeManager.period_changed(period)` 已提供 `dawn/day/dusk/night` 信号。 |
| 天气声音切换 | **可接入，未实现** | `WeatherSystem.weather_changed(weather_id, weather_name)` 已提供 `clear/cloudy/rain/storm/fog` 信号。 |

**审计判断：当前不是“缺几首歌”，而是音频资产、播放器、Bus、音量设置、声音状态机、fade/crossfade 与接入规范几乎全部为空白。**

同时，现有游戏逻辑已经提供了很好的声音触发源，因此无需为音频重做玩法架构。

### 1.2 可直接利用的声音 Hook

- **地点**：`LocationManager.current_location`；地点 ID 为 `home / subway / office / park / store / cafe / hospital / rooftop / alley`。`travel_requested(location_id)` 在成功旅行后发出。
- **时间**：`TimeManager.period_changed(period)`；`dawn / day / dusk / night`。
- **天气**：`WeatherSystem.weather_changed(...)`；`clear / cloudy / rain / storm / fog`，开局默认 rain。
- **移动**：`LocationManager._advance_path()` / `_move_player()`；适合未来做“实际行走距离累计 → step event”，而不是按帧播放。
- **通用互动**：`SpotActivities.activity_requested(id)`；所有八套活动脚本走同一骨架。
- **出租屋**：`rest / study / meal / leave`。
- **公司**：`work / negotiate`。
- **便利店**：`shop`。
- **公园**：`bench / pond`。
- **咖啡馆**：`coffee / idle`，现有文案甚至已经明确“雨声混着磨豆声”。
- **医院**：`clinic / bench`。
- **旧巷**：`shrine / door`，现有文案强调“巷子里的雨声更近”。
- **天台**：`ledge / bench`，现有文案强调“风比楼下凉”。
- **对话**：`DialogUI._on_next_pressed()` / `Game._on_dialog_finished()`。
- **购物/背包**：`ShopUI.buy_requested(item_id)` / `use_requested(item_id)` / `closed`；真正的成功/失败结算仍在 Game，因此成功音应以后者为准。
- **任务**：Game 已有 quest completion 分支与奖励结算点。
- **关系**：`Game._on_dialog_finished()` 后才结算关系，适合“关系升温” stinger，且不会给中途关闭对话误播奖励音。
- **事件**：`EventUI.show_event()` / option / continue 有清晰生命周期。
- **结局**：`Game._show_ending()` → `EndingUI.show_ending()`。

---

## 2. 声音总方向

### 2.1 核心声音身份

《都市浮生》应听起来像：**一个人在潮湿城市里生活，不是英雄在拯救世界。**

关键词：雨、近距离生活声、狭小室内、远处交通、荧光灯、空调、键盘、塑料包装、门铃、地铁刹车、夜风、冰箱低鸣，以及偶尔出现但不过度煽情的旋律。

音乐/声音原则：

1. **日常感高于史诗感**：避免大片鼓组、宏大管弦、过量 riser。
2. **空间声优先于一直放音乐**：允许 BGM 很薄，甚至让环境声独占 10–30 秒呼吸区。
3. **同一人生主题反复变形**：出租屋、低谷、关系、阶段转折、结局尽量共享短旋律动机，靠配器/和声变化表现人生状态。
4. **雨不是白噪音墙**：室内/室外、窗外/近处、轻雨/暴雨必须有空间差异，长循环必须避免明显 loop 点。
5. **反馈克制但明确**：购买、任务完成、警告、失败要听得出来，但不做手游式高频“叮叮叮”。
6. **不模仿具体商业游戏音乐**：只借鉴“日常叙事/即时反馈”的功能，不复制旋律、编配或现成曲目。

### 2.2 建议声音调色板

- 音乐：felt piano、低动态电钢、很轻的木吉他泛音、温和 synth pad、低频城市 drone、brush percussion、muted bass、少量 tape texture。
- 雨夜：长期雨声高频要克制；室内雨用“窗玻璃后”的过滤版本。
- 公司/便利店/医院：让机器声成为“生活节奏”，但不盖过 UI 与关键反馈。
- 旧巷/天台：少用传统恐怖音效，用距离、风、空隙、窄/宽空间和低频模糊感塑造陌生感。

---

## 3. Godot 音频架构建议（正式制作任务下发后再实施）

> `FILE_OWNERSHIP.md` 当前没有 06-Audio-Music 的默认代码所有权；`project.godot`、`Game.gd`、`LocationManager.gd` 还是高冲突文件。本节仅是 handoff 方案，本任务没有修改它们。

### 3.1 建议资产目录

```text
assets/audio/
  music/
  ambience/
  sfx/
    ui/
    movement/
    actions/
    world/
  licenses/
    AUDIO_SOURCES.md
    snapshots/
```

建议命名：

```text
bgm_home_rain_night_v01.ogg
bgm_office_v01.ogg
amb_rain_window_light_loop_v01.ogg
amb_city_distant_night_loop_v01.ogg
sfx_footstep_wet_01.wav
sfx_ui_click_01.wav
sfx_purchase_confirm_01.wav
```

### 3.2 建议运行时节点

后续可新增 `scripts/systems/AudioManager.gd`（最终命名由 00 决定）：

- `MusicA` / `MusicB`：两个 `AudioStreamPlayer` 做无缝 A/B crossfade。
- `AmbienceA` / `AmbienceB`：地点环境底噪 crossfade。
- `WeatherLayer`：雨/暴雨独立层，天气变化不重启整个地点 ambience。
- `ActionLoop`：工作键盘、做饭等持续动作循环。
- `SFXPool`：短 SFX 多声部播放，避免快速连续反馈互相截断。
- `UILayer`：UI click / dialog advance / warning 等不受世界坐标影响的声音。
- 局部近景声如门、咖啡机、NPC 若后续空间化确有收益，再用 `AudioStreamPlayer2D`；首版固定镜头不必把所有声音都 2D 空间化。

### 3.3 建议 Bus

```text
Master
├─ Music
├─ Ambience
├─ SFX
└─ UI
```

设置项建议：Master / Music / Ambience / SFX / UI 五路 0–100 + mute。建议使用独立 settings 配置持久化，不要把“玩家声音偏好”混入人生存档语义。

### 3.4 状态优先级

高 → 低：

1. Ending
2. 人生阶段转折 / 重大剧情
3. 低谷 / 失败音乐状态
4. Event 临时 underscore
5. 地点 + 时段 BGM
6. 关系升温 / 任务完成 stinger（**叠加，不替换场景 BGM**）

环境声独立存在；重大剧情默认 duck，不应把整座城市无理由静音。

### 3.5 初始混音原则（不是验收数值）

- Music 比关键 SFX 低约 4–8 dB 作为首轮起点。
- Ambience 再比 Music 低约 3–6 dB；雨声长期播放时尤其控制高频疲劳。
- UI / 警告 / 任务完成清晰但不尖锐。
- Master 留 headroom，避免 Music + Rain + Action SFX 同时叠加削波。
- 最终必须以本地与 Web 真实试玩调，不以波形/数值替代人工听感。

Godot 文档列出的常用导入格式包括 WAV、Ogg Vorbis、MP3。首版建议：长循环 BGM / Ambience 用 Ogg Vorbis；短促、高频触发 SFX 优先 WAV。

---

# 4. BGM 资产需求表（16 层）

> “已有素材”均按本次仓库审计填写；没有实际文件就一律写“否”。

| 名称 | 使用场景 | 类型 | 情绪 | 长度建议 | 循环 | 建议 BPM | 进入 / 退出规则 | 淡入淡出 | 优先级 | 已有素材 | 制作 / 来源方案 | Godot 接入位置 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BGM-01《窗外还在下》 | 出租屋 / 雨夜 | BGM | 疲惫、安稳、孤独但不绝望 | 120–180s | 是 | 62–72 | `home` + `night/dusk`；重大事件可 duck；离家或进入白天版退出 | 入 2.5s / 出 2.0s，A/B crossfade | **P0** | 否 | **新制作优先**；共享人生主题动机 | location + `period_changed` → AudioManager |
| BGM-02《七点半的房间》 | 白天出租屋 | BGM | 清醒、普通、略有希望 | 120–180s | 是 | 76–88 | `home` + `day/dawn`；与雨夜版同主题平滑切换 | 2–3s crossfade | **P0** | 否 | 新制作优先 | 同上 |
| BGM-03《下一站是今天》 | 上班通勤 / 地铁 | BGM | 人流、重复、轻微推进感 | 90–150s | 是 | 88–100 | 进入 `subway`；离站退出 | 1.5s / 1.5s | **P0** | 否 | 新制作；机械节拍/车轮纹理可自制 | location=`subway` |
| BGM-04《格子间四小时》 | 公司 | BGM | 克制、机械、时间被切块 | 120–180s | 是 | 82–94 | `office` 常驻；work 时可加节奏 stem，不重启整曲 | 场景 2s；stem 0.8s | **P0** | 否 | 新制作优先 | office location + `work` activity |
| BGM-05《凌晨也亮着灯》 | 便利店 | BGM | 荧光灯下的小安全感、轻快但空 | 90–150s | 是 | 96–108 | `store`；打开货架面板继续，UI 打开时可 duck 1–2dB | 1.5s / 1.5s | **P0** | 否 | 新制作；可用明确商用授权 loop 做候选，但核心身份仍建议原创 | location=`store` |
| BGM-06《一杯坐很久》 | 咖啡馆 | BGM | 温暖、松弛、与雨隔着玻璃 | 120–180s | 是 | 72–84 | `cafe`；coffee/idle 不重启 | 2s / 2s | P1 | 否 | 新制作；轻电钢/刷鼓，不直接使用现成 jazz standard | location=`cafe` |
| BGM-07《雨里的长椅》 | 公园 | BGM | 慢、透气、稍凉 | 120–180s | 是 | 64–76 | `park`；天气主要改变 ambience | 2.5s / 2s | P1 | 否 | 新制作 | location=`park` + weather context |
| BGM-08《叫到的不是你》 | 医院 | BGM | 不安、等待、克制的人情味 | 100–160s | 是 | 58–70 | `hospital`；看病结算时可短暂 duck | 2.5s / 2.5s | P1 | 否 | 新制作；避免廉价恐怖心跳 | location=`hospital` |
| BGM-09《巷子里的灯》 | 旧巷 | BGM | 陌生、潮湿、似真似幻 | 100–160s | 是 | 54–66 | `alley`；夜晚完整，未来若白天开放则弱化/替换 | 3s / 2.5s | P1 | 否 | 新制作；低频 drone + 稀疏音符 | location=`alley` + period |
| BGM-10《城市在下面》 | 天台 | BGM | 空、远、短暂自由 | 120–180s | 是 | 60–72 | `rooftop`；看夜景/吹风不换歌，只加环境层 | 3s / 2.5s | P1 | 否 | 新制作；人生主题最开阔版本 | location=`rooftop` |
| BGM-11《日子里的一件事》 | 普通人生事件 | BGM | 生活转折、轻叙事、不抢文字 | 60–100s | 可 | 68–82 | 只对需要 underscore 的 event 进入；不是每个弹窗都换歌 | 入 0.8–1.2s / 出 1.5s，底层 BGM duck 4–6dB | P2 | 否 | 新制作一套通用 event underscore | `EventUI.show_event()` 前按 event 分类 |
| BGM-12《今天有点撑不住》 | 低谷 / 失败 | BGM | 空洞、疲惫、压抑但不灾难化 | 60–100s | 可 | 48–60 | 明确失败/低谷剧情；普通小扣数值不滥用 | 0.6s 入 / 2s 出 | P1 | 否 | 新制作；主主题降速/缺音版本 | major fail / negative event state |
| BGM-13《话比昨天多了一点》 | 关系升温 | BGM / Stinger | 温暖、笨拙、微小确认感 | 8–20s | 否 | 76–90 | **关系档位真正提升时**叠加；普通聊天不播 | 0.2s 入 / 自然尾音 | P1 | 否 | 新制作短主题 | `_on_dialog_finished()` 后 relation result / tier change |
| BGM-14《这件事做完了》 | 任务完成 | BGM / Stinger | 完成、松一口气、非“爆奖” | 3–6s | 否 | 90–105 或自由 | quest completion 叠加，不切场景 BGM | 0.05–0.15s 入 / 自然尾音 | **P0** | 否 | **程序化原型 + 后续新制作** | Game quest `kind == "quest"` 完成分支 |
| BGM-15《又过了一段》 | 人生阶段转折 | BGM / Cue | 回望、时间流逝、得失混合 | 30–60s | 否 | 60–72 | 年龄/阶段真正变化时；与 task stinger 做优先级仲裁 | 0.5s 入 / 2.5s 出 | P2 | 否 | 新制作；同一主题年龄化编配 | 年度/阶段推进结算处（正式任务再锁精确 hook） |
| BGM-16《这就是这一生》 | 结局 | BGM | 接受、遗憾、回望；可按 ending 做明暗版本 | 120–180s 或 intro+loop | 是 | 56–72 | `_show_ending()` 最高优先；停止 action loop；场景 BGM 淡下后进入；重开退出 | 游戏声 1.5s 下潜，Ending 2.5s 入；restart 1.5s 出 | **P0** | 否 | 新制作优先；2–3 和声版本共享主旋律 | `_show_ending()` / `EndingUI.show_ending()` |

---

# 5. 环境声 / 空间层需求表

| 名称 | 使用场景 | 类型 | 情绪 / 空间 | 长度建议 | 循环 | BPM | 进入 / 退出规则 | 淡入淡出 | 优先级 | 已有素材 | 制作 / 来源方案 | Godot 接入位置 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AMB-01 轻雨（室外） | 公园、旧巷、天台、地铁入口等 | Ambience | 湿、近、包围 | 45–90s | 是 | N/A | weather=`rain` + outdoor；进室内换窗雨 | 2–4s | **P0** | 否 | 合法授权素材优先或实录；需无缝 loop | `WeatherSystem.weather_changed` + location profile |
| AMB-02 暴雨（室外） | 全部室外 | Ambience | 压迫、风更强、低频更厚 | 45–90s | 是 | N/A | weather=`storm`；与轻雨 crossfade，不满音量双叠 | 3–5s | P1 | 否 | 合法授权素材 / 实录 | WeatherLayer |
| AMB-03 窗外雨（室内过滤） | 家、公司、店、咖啡馆、医院 | Ambience | 隔着玻璃、更远 | 45–90s | 是 | N/A | rain/storm + indoor；按室内 profile 调 EQ/room | 2–4s | **P0** | 否 | 合法雨素材二次设计（low-pass / room / drip layer） | WeatherLayer + indoor profile |
| AMB-04 城市远景 | 家、天台、街角、公园 | Ambience | 远车流、极偶发鸣笛 | 60–120s | 是 | N/A | 城市底层；night 降密度 | 2–3s | **P0** | 否 | 合法授权 / 自录；随机 one-shot 可程序化 | location + period |
| AMB-05 夜间城市 | 家雨夜、天台、旧巷 | Ambience | 稀疏车流、远空调机、水声 | 60–120s | 是 | N/A | period=`night`；与白天 city bed crossfade | 3s | P1 | 否 | 合法授权 / 自录 | `period_changed` |
| AMB-06 地铁站台 | 地铁 | Ambience | 风洞、人群、模糊广播、机械 | 45–90s | 是 | N/A | location=`subway` | 1.5–2s | **P0** | 否 | 合法授权；广播建议自制模糊语义，不使用可识别真实站点/个人录音 | subway profile |
| AMB-07 公司空调 | 公司 | Ambience | 恒定低频、荧光空间 | 60–120s | 是 | N/A | office 常驻低音量 | 2s | P1 | 否 | **程序化/素材均可**；filtered noise + hum | office profile |
| AMB-08 公司远处键盘 | 公司 | Ambience | 别人的工作声、稀疏随机 | 30–60s 或 one-shot pool | 是/随机 | N/A | office；玩家 work 时另开近景键盘 | 1s | P1 | 否 | 合法授权；多变体避免机械重复 | office profile / Randomizer |
| AMB-09 便利店门铃 | 便利店入口 | SFX（环境） | 清脆、熟悉、小安全感 | 0.6–1.5s | 否 | N/A | **成功进入 store 一次** | 0.02s / 自然尾音 | **P0** | 否 | 程序化合成或 CC0 / 明确商用素材 | `travel_requested("store")` 后 |
| AMB-10 咖啡机 / 磨豆机 | 咖啡馆 | Ambience / SFX | 温暖、机械、蒸汽 | 3–12s one-shot | 随机 | N/A | cafe 背景随机；点 coffee 时必有近景动作 | 0.1s / 0.3s | P1 | 否 | 合法授权；建议多变体 | cafe profile + `coffee` activity |
| AMB-11 医院环境 | 医院 | Ambience | HVAC、远走廊、推车/提示声，克制 | 60–120s | 是 | N/A | location=`hospital` | 2s | P1 | 否 | 合法授权 + 自制提示音；避免真实患者隐私录音 | hospital profile |
| AMB-12 公园虫鸣 / 风 | 公园 | Ambience | 风、树叶、雨后自然 | 60–120s | 是 | N/A | park；night 虫鸣提高，storm 降/停虫鸣 | 3s | P1 | 否 | 合法授权 / 自录；按天气/时段程序化混层 | park + weather + period |
| AMB-13 天台风 | 天台 | Ambience | 开阔、持续空气、偶发阵风 | 60–120s | 是 | N/A | rooftop 常驻，storm 加强 | 2–4s | P1 | 否 | 合法授权 / 自录 | rooftop + weather |
| AMB-14 旧巷近雨 / 滴水 | 旧巷 | Ambience | 檐滴、水沟、狭窄反射 | 45–90s | 是 | N/A | alley；叠在天气雨层下方 | 2s | P1 | 否 | 合法授权 + 二次设计 | alley profile |
| AMB-15 室内家电 | 出租屋 | Ambience | 冰箱、偶发压缩机、电气低鸣 | 30–90s / random | 是/随机 | N/A | home；night 更明显 | 2s | **P0** | 否 | **程序化 + 合法素材均可**；Inventory 文案已写“冰箱嗡嗡声” | home + period |

---

# 6. 动作 / UI / 交互 SFX 需求表

| 名称 | 使用场景 | 类型 | 情绪 / 功能 | 长度建议 | 循环 | BPM | 进入 / 退出规则 | 淡入淡出 | 优先级 | 已有素材 | 制作 / 来源方案 | Godot 接入位置 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SFX-01 脚步 | 全部可行走场景 | SFX | 接地、空间感 | 0.15–0.45s × 6–10 variants | 否 | N/A | **按实际移动距离累计**触发，停止即停，不能按帧响 | 5–20ms 防 click | **P0** | 否 | 合法授权 / 自录；首版 wet/concrete/indoor 三组 | `LocationManager` move path；更推荐未来 emit `step` 事件给 AudioManager |
| SFX-02 开门 / 关门 | 出租屋 / 场景出入口 | SFX | 生活动作确认 | 0.4–1.2s | 否 | N/A | 成功 leave/travel 时；失败/blocked 不播 | 0.01s / 自然尾音 | **P0** | 否 | 合法授权 / 自录 | home `leave` success + transition |
| SFX-03 UI 点击 | 全部按钮 | SFX | 轻、统一、不抢戏 | 0.04–0.15s | 否 | N/A | 有效 pressed 时；disabled 不播确认音 | 0–5ms | **P0** | 否 | **程序化可解决**（filtered tick / tiny wood tap） | UI sound router：HUD/Dialog/Event/Shop/Start/Ending/Spot button |
| SFX-04 UI 返回 / 关闭 | 商店、背包、弹窗 | SFX | 收起、退出 | 0.08–0.25s | 否 | N/A | close/escape 成功时 | 极短 | P1 | 否 | 程序化可解决 | `ShopUI.closed` 等 |
| SFX-05 购买确认 | 便利店买下 | SFX | 明确、非“爆金币” | 0.25–0.7s | 否 | N/A | **扣款 + 入包成功后**；余额不足不播成功音 | 0.01s / 0.1s | **P0** | 否 | 程序化 + 纸袋/扫码素材 | Game shop-buy 成功结算 |
| SFX-06 金钱增加 | 工资、奖励、收入 | SFX | 有获得感但克制 | 0.35–0.9s | 否 | N/A | 真正 delta>0 且值得反馈；避免小变动全响 | 0.01s / 0.2s | P1 | 否 | 程序化（软 coin / wood chime） | wage / quest reward / major event result |
| SFX-07 金钱减少 | 购买、看病、咖啡、上香 | SFX | 确认支出，不惩罚 | 0.2–0.6s | 否 | N/A | 真正 delta<0 且成功消费；与 purchase 音避免重复轰炸 | 极短 | P1 | 否 | 程序化 | Game 各消费成功分支 |
| SFX-08 吃饭 | 做饭 / 背包食物 | SFX | 近距离生活感 | 0.8–2.5s | 否 | N/A | meal/food 真结算时；可随机包装/餐具层 | 0.02s / 0.1s | **P0** | 否 | 合法授权 / 自录 | home `meal` + item use food category |
| SFX-09 喝水 / 饮料 | 牛奶、咖啡、吃药配水 | SFX | 短、近 | 0.6–1.8s | 否 | N/A | drink item 成功使用 | 0.02s / 0.1s | P1 | 否 | 合法授权 / 自录 | item use：`canned_coffee` / `milk` / medicine subtype |
| SFX-10 做饭循环 | 出租屋厨房 | SFX | 锅铲、油、水 | 4–12s | 可 | N/A | meal `_begin_activity` 后；`_end_activity` 前停止；失败检查前不播 | 0.15s / 0.3s | **P0** | 否 | 合法授权 + 多层设计 | home `meal` activity lifecycle |
| SFX-11 睡觉进入 | 床 | SFX | 被褥、床垫、安静落下 | 0.8–2s | 否 | N/A | rest/sleep 成功开始；不使用夸张鼾声 | 0.1s / 0.2s | P1 | 否 | 合法授权 / 自录 | home `rest` start |
| SFX-12 起床 | 小睡 / 过夜结束 | SFX | 布料、床板、轻呼吸 | 0.6–1.5s | 否 | N/A | rest/sleep 完成、控制恢复 | 0.05s / 0.1s | P1 | 否 | 合法授权 / 自录 | sleep completion |
| SFX-13 键盘工作循环 | 公司上班 | SFX | 机械、重复、近距离 | 6–15s | 是 | N/A | `work` activity 期间；结束/中断必须停 | 0.15s / 0.25s | **P0** | 否 | 合法授权；2–3 loop variants / Randomizer | `_do_work_shift` activity lifecycle |
| SFX-14 翻书学习 | 出租屋学习 | SFX | 纸张、笔划、安静 | 2–6s + random page | 可/随机 | N/A | `study` 期间；结束停止 | 0.1s / 0.2s | **P0** | 否 | 合法授权 / 自录 | home `study` lifecycle |
| SFX-15 手机消息 | 特定任务/关系/消息事件 | SFX | 现代、克制、不像报警 | 0.25–0.8s | 否 | N/A | 只有“手机消息”语义才播；普通 toast 不全绑 | 极短 | P1 | 否 | **程序化原创两音提示** | 特定 message hook；不要绑定全局 `_show_toast` |
| SFX-16 对话推进 | DialogUI | SFX | 纸感 / 轻 tap，辅助阅读节奏 | 0.03–0.12s | 否 | N/A | 每次有效推进一行；最终结束可轻微不同 | 0–5ms | **P0** | 否 | 程序化可解决 | `DialogUI._on_next_pressed()` / dialog variant |
| SFX-17 任务完成 | 主线任务 | SFX | 温和确认、非抽卡 | 1.5–4s | 否 | 90–105 或自由 | quest completion 只播一次；可与 BGM-14 合并 | 自然尾音 | **P0** | 否 | **新制作 / 程序化原型** | quest completion branch |
| SFX-18 警告 | 饱食/精力告急、真正错误 | SFX | 低刺激但能注意 | 0.25–0.8s | 否 | N/A | 首次告急/真正错误；不能每帧/每 toast 响 | 0.01s / 0.1s | **P0** | 否 | 程序化低频双脉冲 | needs murmur / invalid action concrete branch |
| SFX-19 失败 | 谈薪失败、重要负面结果 | SFX | 短促落空，不羞辱玩家 | 0.6–1.8s | 否 | N/A | 真实 failure 后；小损失不滥用 | 0.02s / 0.3s | P1 | 否 | 新制作 / 程序化 | negotiate fail / major event fail |
| SFX-20 保存成功 | HUD 保存 | SFX | 安定、确认 | 0.15–0.5s | 否 | N/A | **保存真正成功后**，不能按钮一按就假确认 | 极短 | P2 | 否 | 程序化 | save success return point |
| SFX-21 读取完成 | HUD 读取 | SFX | 重新落地 | 0.2–0.7s | 否 | N/A | apply save 成功后；随后重新 sync location/time/weather | 0.05s / 0.2s | P2 | 否 | 程序化 | load success + AudioManager resync |
| SFX-22 地铁进站 / 刹车 | 地铁 | SFX（环境） | 机械、空间移动 | 5–12s | 随机 one-shot | N/A | subway 随机，间隔 30–90s，避免持续吵 | 0.2s / 0.4s | P1 | 否 | 合法授权 | subway ambience scheduler |
| SFX-23 咖啡放杯 / 蒸汽 | 咖啡馆点咖啡 | SFX | 温暖、近距离 | 1–4s | 否 | N/A | coffee 成功后 | 0.05s / 尾音 | P1 | 否 | 合法授权 / 自录 | cafe `coffee` success |
| SFX-24 医院叫号提示 | 医院 | SFX（环境） | 冷静、制度化 | 0.5–1.5s | 随机 one-shot | N/A | 环境随机；不要使用带患者姓名/隐私的真实录音 | 极短 | P2 | 否 | **程序化原创提示音** + 无语义 broadcast texture | hospital scheduler |
| SFX-25 上香 / 火柴 | 旧巷神龛 | SFX | 小仪式感，不超自然化 | 1–3s | 否 | N/A | shrine 消费成功后 | 0.05s / 0.2s | P2 | 否 | 合法授权 / 自录 | alley `shrine` success |

---

## 7. 地点声音 Profile 草案

| 地点 | 主 BGM | 核心 Ambience | 近景 / 随机声 | 声音身份 |
| --- | --- | --- | --- | --- |
| home 夜 | BGM-01 | 窗雨 + 室内家电 + 远城 | 冰箱压缩机、楼道门、偶发车辆 | **项目主声音名片**：安全但孤单 |
| home 日 | BGM-02 | 室内家电 + 白天城市；下雨则窗雨 | 水管/楼上轻响可后加 | 同主题更清醒 |
| subway | BGM-03 | 站台底噪 | 列车进站、刹车、模糊广播 | 通勤重复感 |
| office | BGM-04 | 空调 + 远键盘 | 玩家工作近键盘、远打印机 | “时间被工作切块” |
| store | BGM-05 | 冰柜/空调低鸣 | 门铃、扫码/袋子 | 24h 亮灯的小安全区 |
| cafe | BGM-06 | 窗雨 + room tone | 磨豆、蒸汽、放杯 | 现有文案“雨声混着磨豆声”应真正听见 |
| park | BGM-07 | 风/树叶/雨/虫鸣 | 水面滴雨、远城 | 城市里唯一能慢一点的空间 |
| hospital | BGM-08 | HVAC / 远走廊 | 叫号、推车 | 冷、具体、克制 |
| alley | BGM-09 | 近雨/檐滴 + 夜城 | 火柴、木门、远脚步 | “雨更近”、空间更窄 |
| rooftop | BGM-10 | 风 + 远城 + 雨 | 阵风、极低频率远列车/警笛 | 城市突然变远 |

---

## 8. 自适应进入 / 退出规则

### 8.1 地点

- 同一地点不同时间尽量是同主题 A/B 版本或 stem，避免像换电台。
- 不同地点：Music 1.5–3.0s crossfade；Ambience 1.0–2.5s crossfade。
- 目的地 travel 成功后才进入完整目的地声音；失败/disabled travel 不切音乐。

### 8.2 时间

- `home` 明确有 day / rain-night 两层音乐。
- 其他地点首版可同一 BGM + 环境密度/滤波变化，避免资产量爆炸。
- `period_changed` 作为触发源；AudioManager 需要去抖，防一次 `advance_minutes()` 跨多个边界导致连续切换。

### 8.3 天气

- 天气主要改变 Ambience，不强制换 BGM。
- `rain → storm` crossfade，同一时刻不要两套完整雨声满音量叠加。
- `clear/cloudy/fog` 必须真的淡掉雨层；声音应尊重状态，不能因为美术多数是雨夜就永久播放雨声。

### 8.4 Event / Dialogue

- 普通对话：保留地点 BGM + ambience；BGM duck 1–3dB 即可。
- 普通 event：没有专用音乐时，不为“有声音”而硬切；可只 duck + UI cue。
- 重大 event：cue 入场，地点 BGM duck 约 6dB；结束恢复原播放位置/音量，尽量不从头重启。

### 8.5 Activity

- `_begin_activity` 后启动 action loop；`_end_activity` 前后停止。
- **余额不足、技能不足、blocked、条件不满足时不能先播“成功动作声”。**
- 工作 / 做饭 / 学习是首批最值得加持续动作声的活动：能把“站着等进度 + 数值结算”变成真实生活动作。

---

## 9. 授权与素材来源策略

本任务只做来源调研，**没有下载任何外部素材**。

### 9.1 可进入候选池

1. **项目原创 / 自录 / 自行合成**：优先级最高；尤其 UI、warning、task complete、relationship stinger、核心人生主题音乐。
2. **CC0**：优先检索 Kenney Audio，以及 Freesound 上明确标记 CC0 的单个声音。
3. **明确允许商业游戏同步使用的 royalty-free 库**：例如 Sonniss #GameAudioGDC；使用时必须保存“下载当天适用的许可版本”。
4. **Pixabay Content License** 可作为候选：官方许可摘要允许免费使用、修改且通常无需署名，但禁止 standalone 再分发素材本身；仍应给每个实际文件保存 provenance。
5. **CC-BY**：只有当素材不可替代且 credits/attribution 管线已建立时再用；首版默认优先 CC0 / 无需署名的明确商业许可。

### 9.2 当前调研到的许可结论（2026-09-14）

- **Kenney**：官方 Support 说明其 asset pages 上的 game assets 为 CC0，可商用，署名非必需。
- **Freesound**：官方 FAQ 说明声音可能是 CC0 / CC-BY / CC-BY-NC；必须逐条看 license。商业首版建议只选 CC0，除非已建立 attribution。
- **Pixabay**：官方 Content License 摘要允许免费使用、通常无需署名、可修改；禁止把素材 standalone 分发。
- **Sonniss #GameAudioGDC**：当前 bundle license v2.0（2026-08-27 起）允许 royalty-free 地在个人/商业项目中使用和修改、无需署名，并可同步到 games / interactive projects；禁止把 sound effects 本身作为 library/pack 再分发。**哪一版 license 生效取决于下载当天，因此必须保存当日许可快照。**

### 9.3 默认禁止 / 排除

- YouTube 抓取音频。
- 商业游戏原声、影视原声、流媒体歌曲。
- “免费下载”但没有明确 license 页的网盘/论坛资源。
- Freesound CC-BY-NC（商业项目默认排除）。
- 来源页消失、作者/许可无法确认且无历史快照的素材。
- 将采购/下载的素材包原始文件作为独立音效库重新分发。

### 9.4 每个外部素材必须记录的 provenance

未来 `assets/audio/licenses/AUDIO_SOURCES.md` 至少记录：

- 项目内文件名
- 原始文件名
- 作者 / 发布者
- 来源站点 + 具体素材页面
- License 名称 + 版本
- 下载日期
- 是否要求署名
- 是否修改（裁剪 / EQ / layering / pitch 等）
- 许可页面快照 / 文本副本路径

**没有 provenance 记录的外部声音，不进入正式集成候选。**

---

## 10. 制作优先级

### P0 — 先让“完整一天”真的有声音

覆盖现有家 → 地铁 → 公司 → 便利店 → 家闭环：

- 音频 runtime 骨架 + Bus + 最小音量设置
- BGM-01 / 02 / 03 / 04 / 05
- 轻雨 / 窗雨 / 城市远景 / 地铁 / 公司空调 / 家电
- 脚步 / UI click / 对话推进 / 门 / 购买 / 吃饭 / 做饭 / 键盘工作 / 翻书 / warning / task complete
- 场景 crossfade
- Web 首次用户手势后的音频解锁策略（不能依赖页面加载即自动播放）

### P1 — 九地点完整空间感

- 公园 / 咖啡馆 / 医院 / 旧巷 / 天台 BGM
- 对应 ambience 与场景 one-shot
- 关系升温 / failure cue
- rain/storm/weather layering
- 脚步至少 indoor / concrete / wet outdoor 三类

### P2 — 人生叙事层

- normal life-event underscore
- life-stage turn cue
- ending 多和声版本
- 更细 NPC / 空间随机声
- 动态 stems / 更精细 duck/mix

---

## 11. 建议 00-Orchestrator 后续拆分

### AUDIO-RUNTIME-001 — 音频骨架（需要明确代码授权）

建议 writable scope：

- `scripts/systems/AudioManager.gd`（新文件）
- `assets/audio/**`
- `default_bus_layout.tres`（新文件）
- 最小接线：`scripts/Game.gd`
- 如果需要直接从移动层拿 step，则明确授权 `scripts/systems/LocationManager.gd`；**更推荐 Gameplay 提供 movement/step signal，06 只消费信号**，降低高冲突文件并发。
- 音量设置 UI 如需新增，由 Scene/UI owner 与 06 协作或由 00 明确边界。

### AUDIO-ASSET-001 — P0 SFX / Ambience 合法素材包

建议 writable：`assets/audio/**` + 本 report。

首包：

- 3 类 footsteps × ≥6 variants
- rain outdoor / rain window / city night / subway / office hum / home appliance
- UI click / dialog / door / purchase / eat / cook / keyboard / page / warning
- `AUDIO_SOURCES.md` + license snapshots

### AUDIO-MUSIC-001 — P0 五首地点音乐 + task stinger

- Home rain night
- Home day
- Commute
- Office
- Convenience store
- Quest complete stinger

每首记录：最终 loop、BPM、调性/和声备注、loop 点；入库格式首选 `.ogg`，制作母版另行保存但不要误提交无必要的大文件。

---

## 12. 未来 Godot 验收标准

自动检查只能证明“接线正确”，**不能证明“好听”**。

### 12.1 自动 / 结构验收

未来 `tools/verify_audio.gd` 至少检查：

- manifest 中资源路径存在且可 load。
- Master / Music / Ambience / SFX / UI Bus 存在。
- location 变化后只保留预期的主 BGM / crossfade，不无限叠播放器。
- weather rain/storm/clear 正确开关雨层。
- home day/night 能随 period 切换。
- disabled / 余额不足 / 条件拒绝不误播成功 SFX。
- action loop 在 activity 结束后真正停止。
- load / restart 后按当前 location/time/weather 重新同步，不继续旧场景音乐。
- mute / volume 持久化恢复。

### 12.2 人工听感验收

至少真实走一次：

`出租屋（日） → 地铁 → 公司上班 → 便利店购买/吃东西 → 雨夜回家 → 做饭/学习/睡觉 → 次日醒来`

人工确认：

- 雨声长听不刺耳、不疲劳。
- BGM 不盖关键 UI / SFX。
- footsteps 与移动速度匹配，没有机关枪式重复。
- 切场景无爆音、双播、突然断尾。
- work/cook/study 不再只有“站着等数值”的声音空白。
- dialog advance 在 20–30 分钟流程里不烦。
- task complete / failure 有辨识度但不手游化。
- Web 首次交互后能正常出声；失焦/回焦不叠播。
- mute / volume 设置真实有效。

只有真实播放和人工试听完成，才能把对应声音标为“已验收”。

---

## 13. 本任务完成状态

### 已完成

- [x] 读取指定 6 份核心文档。
- [x] 审计音频资产类型与仓库音频文件存在性。
- [x] 审计 AudioStreamPlayer / AudioServer / Bus / volume / fade / scene-music infrastructure。
- [x] 审计九地点、八套 activities、移动、time、weather、UI、shop、dialog、quest、relations、event、ending 的可用 audio hook。
- [x] 形成 16 层 BGM 规划。
- [x] 形成 ambience / world-space 规划。
- [x] 形成动作 / UI / interaction SFX 规划。
- [x] 明确 loop / fade / entry / exit / priority / availability / sourcing / Godot integration。
- [x] 调研候选合法授权来源规则与 provenance 要求。
- [x] 提出 P0/P1/P2 制作顺序与后续可拆任务。

### 明确未完成 / 未声称完成

- [ ] 任何音乐实际制作。
- [ ] 任何 SFX / Ambience 实际下载或制作。
- [ ] 任何音频实际导入 Godot。
- [ ] 任何 Audio Bus / AudioManager 实际接入。
- [ ] 任何声音实际播放。
- [ ] 任何混音 / 听感 / Web 验收。

## Handoff to 00-Orchestrator

**建议下一步：先 review 本报告。若方向接受，再分配 `AUDIO-RUNTIME-001 + AUDIO-ASSET-001`，先完成“完整一天”声音闭环；音乐制作可并行拆为 `AUDIO-MUSIC-001`。在 00 正式授权 production writable scope 前，06-Audio-Music 停在规划阶段。**
