# CONTENT-WAVE-01 — First-hour legally usable sound-source pack

Status: **SOURCE REVIEW PACK — NOT DOWNLOADED / NOT INTEGRATED / NOT PLAYBACK-VERIFIED**  
Owner: `06-Audio-Music`  
Task: `AUDIO-CONTENT-002`  
Prepared: 2026-09-14

This file is the legal/source manifest for the first audible vertical slice of **《都市浮生》**. It intentionally contains source references and integration recommendations only. The current task does not authorize audio binaries, `project.godot`, shared audio buses, `Game.gd`, `LocationManager.gd`, or playback integration.

## Rights policy for this pack

All **core** candidates below are marked **CC0 / Public Domain dedication** on their source pages. For this wave that means:

- commercial game distribution is allowed;
- copying, trimming, looping, EQ, gain changes, format conversion and other modifications are allowed;
- attribution is not legally required by CC0, although voluntary credits are recommended as project hygiene;
- do not imply creator endorsement and do not claim authorship of the original recording/composition;
- retain this manifest and capture a local copy/screenshot of each source page at the time of actual download, because website metadata can change later.

Reference guidance checked during curation:

- Freesound licensing FAQ: https://freesound.org/help/faq/
- OpenGameArt FAQ: https://opengameart.org/content/faq
- CC0 1.0 legal/deed entry: https://creativecommons.org/publicdomain/zero/1.0/

**Rejected by policy for this pack:** YouTube-ripped audio, commercial-game audio, unclear/no-license downloads, CC-BY-NC, and sources whose page does not clearly permit game distribution.

## Core source set

| ID | Coverage / intended use | Exact source page | Creator | Upstream download filename | Source format / duration | License | Attribution | Modification | Recommended preparation | Loop / fade | Existing hook / handoff point | Priority | Downloaded? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MUS-01 | Home / rain-night musical bed | https://opengameart.org/content/sadness | Kistol | `Sadness.ogg` | OGG, seamless-loop submission; source page lists 440.6 KB | CC0 | Not required; optional `Music by Kistol` | Allowed | Keep source OGG; audition against rain first. If too mournful, reject rather than over-EQ. Target quiet bed around -22 to -18 LUFS integrated; remove any start transient only if needed. | Seamless loop as authored; 2.5–3.0 s enter / 2.0 s exit crossfade | `LocationManager.current_location == "home"`; later gate by `TimeManager.period_changed("night")`; duck under dialogue/event UI | P0 | **No** |
| AMB-01 | Office room tone / keyboard / distant work | https://freesound.org/people/170026/sounds/407735/ | 170026 | `Office Ambience.wav` | WAV, 2:05.128, 48 kHz/24-bit stereo | CC0 | Not required; optional creator credit | Allowed | Select a 25–45 s steady section with no standout voice/phone event; high-pass rumble lightly; normalize conservatively; render game-ready OGG later. | Build 1.0–1.5 s crossfade loop; 0.8 s in/out | `current_location == "office"`; ambience bus only, separate from `OfficeActivities.work` keyboard SFX | P0 | **No** |
| AMB-02 | Subway station base ambience | https://freesound.org/people/larsn.wav/sounds/707070/ | larsn.wav | `subway_ttc_ambience.wav` | WAV, 2:29.652, 48 kHz/16-bit mono | CC0 | Not required; optional creator credit | Allowed | Choose 35–60 s section without intelligible foreground announcement if possible; tame low-mid rumble; later convert to OGG. | Build 1.5 s crossfade loop; 0.6 s in / 0.8 s out | `current_location == "subway"`; stop/crossfade on travel | P0 | **No** |
| AMB-03 | Indoor rain hitting rental-apartment window | https://freesound.org/people/Northern%20Rebel/sounds/54964/ | Northern Rebel | `rain on window.wav` | WAV, 0:13.066, 48 kHz/24-bit stereo; source explicitly says loopable | CC0 | Not required; optional creator credit | Allowed | Remove DC/very-low rumble only if audible; keep stereo texture; make a second softer gain variant for light rain if useful. | Loop; 1.0 s in/out; weather-strength gain automation later | `home` + `WeatherSystem.weather_changed("rain"/"storm")`; may remain low under home BGM | P0 | **No** |
| SFX-01 | General UI click: HUD / menus / inventory / choices | https://freesound.org/people/saha213131/sounds/666620/ | saha213131 | `click.wav` | WAV, 0:00.179, 44.1 kHz/16-bit stereo | CC0 | Not required | Allowed | Trim leading/trailing silence if any; mono fold-down optional; keep very short and quiet to avoid fatigue. | One-shot; no fade beyond 5–10 ms de-click | Generic `Button.pressed`; later central UI SFX route rather than per-button duplicated players | P0 | **No** |
| SFX-02 | Dialogue advance / continue | https://freesound.org/people/hollandm/sounds/692824/ | hollandm | `Maracas-click.wav` | WAV, 0:00.500, 44.1 kHz/16-bit stereo | CC0 | Not required | Allowed | Shorten to the clean wood click if needed; lower gain 4–8 dB below primary UI click so repeated dialogue remains comfortable. | One-shot; 5–10 ms de-click | `DialogUI._on_next_pressed()`; also suitable for event `continue_requested` at lower gain | P0 | **No** |
| SFX-03 | Indoor footsteps | https://freesound.org/people/spenceomatic/sounds/119766/ | spenceomatic | `Footsteps Wooden Floor.wav` | WAV, 0:26.282, 48 kHz/24-bit stereo | CC0 | Not required | Allowed | Slice 4–6 distinct single steps; remove long tails; create quiet variations rather than replaying the same sample. Do not loop the full recording. | One-shots triggered by distance/step cadence; 10–20 ms fade tails | `LocationManager._advance_path()` / `_move_player()` movement state; cadence should be distance-based, not frame-based | P0 | **No** |
| SFX-04 | Apartment/interior door open | https://freesound.org/people/DeVern/sounds/381305/ | DeVern | `Door Open.wav` | WAV, 0:02.319, 44.1 kHz/24-bit stereo | CC0 | Not required | Allowed | Use first clean open/creak portion; trim tail to ~0.8–1.5 s if it feels too theatrical. | One-shot; short natural tail | Home activity `leave`; later travel transition may add separate whoosh/room-tone crossfade, not reuse this as every map change | P0 | **No** |
| SFX-05 | Keyboard/work loop at office workstation | https://freesound.org/people/peoplearehappy/sounds/841238/ | peoplearehappy | `keyboard_typing_loop1.wav` | WAV, 0:02.653, 22.05 kHz/16-bit stereo; source describes it as a loop | CC0 | Not required | Allowed | Keep as short work texture; EQ excessive clack if fatiguing; optional 2–3 alternate offsets after download. | Loop only while work action is active; 80–150 ms in/out | `OfficeActivities` activity id `work`; start after `_begin_activity`, stop before/at `_end_activity` | P0 | **No** |
| SFX-06 | Study / page turn | https://freesound.org/people/pixelator/sounds/1180/ | pixelator | `page_turn.wav` | WAV, 0:00.789, 44.1 kHz/16-bit mono | CC0 | Not required | Allowed | Keep nearly dry; optional -2 to -4 dB gain. For long study action, play sparsely rather than every progress tick. | One-shot; natural tail | `HomeActivities` activity id `study`; trigger once on enter and optionally one randomized repeat during long loop later | P0 | **No** |
| SFX-07 | Cooking / pots + faint frying | https://freesound.org/people/A.karu742/sounds/623412/ | A.karu742 | `cooking.wav` | WAV, 0:30.096, 48 kHz/24-bit stereo | CC0 | Not required | Allowed | Select a 6–12 s section with moderate pan/pot activity; build a gentle loop; reduce sharp utensil transients if they compete with UI/dialogue. | 0.3 s in/out; loop during meal action | `HomeActivities` activity id `meal`; start in `_begin_activity`, stop in `_end_activity` | P0 | **No** |
| SFX-08 | Purchase / checkout confirmation | https://freesound.org/people/newagesoup/sounds/348240/ | newagesoup | `CASHIER-REGISTER-KEYBOARD-BEEP-CALC.wav` | WAV, 0:03.165, 48 kHz/24-bit stereo | CC0 | Not required | Allowed | Extract one short register key/beep phrase (~0.25–0.7 s), not the whole sequence; soften high frequency if harsh. | One-shot | `ShopUI.buy_requested(item_id)` after successful `Game` settlement only; do not play on unaffordable/failed purchase | P0 | **No** |
| SFX-09 | Task completion / positive confirmation | https://freesound.org/people/sophieciruela/sounds/634450/ | sophieciruela | `success.wav` | WAV, 0:02.049, 44.1 kHz/24-bit stereo | CC0 | Not required | Allowed | Trim silence; retain ~0.8–1.5 s positive motif if full 2 s is too long; keep non-arcade in mix by lowering brightness/gain if needed. | One-shot; 20–50 ms tail fade if trimmed | Quest event kind `quest` / `_apply_quest_reward()` completion path; not for every step update | P0 | **No** |
| SFX-10 | Warning / invalid / failed action | https://freesound.org/people/iwanPlays/sounds/626085/ | iwanPlays | `Negative.wav` | WAV, 0:00.472, 48 kHz/16-bit mono | CC0 | Not required | Allowed | Audition carefully: source uses a processed mouth/cyborg texture. If too stylized, reject. Keep very low gain and reserve for meaningful failure/warning, not routine hover. | One-shot | Failed purchase / insufficient funds / blocked action / serious warning route; later central feedback API, not every toast | P1 | **No** |

## Subway arrival alternate (optional, still CC0)

The core subway bed above is a steady station ambience. If the later integration task wants a distinct train-arrival layer rather than baking arrival into the loop, this source is legally compatible and technically separate:

| ID | Use | Exact source page | Creator | Upstream filename | Format / duration | License | Preparation | Hook | Downloaded? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ALT-01 | Train arrival stinger over AMB-02 | https://freesound.org/people/Manicciola/sounds/121791/ | Manicciola | `SUBWAY_01.WAV` | WAV, 0:37.969, 44.1 kHz/16-bit stereo | CC0 | Extract 4–10 s approach/brake segment; high-pass sub rumble only if necessary; do not loop | Entering `subway`, or occasional sparse arrival event later | **No** |

## Recommended first integration order

1. `SFX-01` UI click + `SFX-02` dialog advance — immediate feedback with the smallest runtime surface.
2. `AMB-03` indoor rain + `MUS-01` home musical bed — establishes the project's core rain-night identity.
3. `SFX-03` footsteps + `SFX-04` door — makes movement/travel feel embodied.
4. `AMB-01` office + `SFX-05` keyboard/work — turns the first work shift from silent number settlement into a place/action.
5. `AMB-02` subway (+ optional `ALT-01`) — makes commute a transition rather than a static screen.
6. `SFX-06` study + `SFX-07` cooking + `SFX-08` purchase — fills the first-hour daily loop.
7. `SFX-09` task complete + `SFX-10` warning — closes the feedback loop after core ambience/action coverage exists.

## Proposed game-ready filenames after actual download/edit

These are **future derived filenames**, not claims that files exist now:

```text
assets/audio/music/home_rain_night_01.ogg
assets/audio/ambience/home_rain_window_loop.ogg
assets/audio/ambience/office_workday_loop.ogg
assets/audio/ambience/subway_station_loop.ogg
assets/audio/ambience/subway_arrival_01.ogg          # optional ALT-01
assets/audio/sfx/ui_click_01.wav
assets/audio/sfx/dialog_advance_01.wav
assets/audio/sfx/footstep_indoor_01.wav ... _06.wav
assets/audio/sfx/door_open_01.wav
assets/audio/sfx/work_keyboard_loop.ogg
assets/audio/sfx/study_page_01.wav
assets/audio/sfx/cooking_loop.ogg
assets/audio/sfx/purchase_confirm_01.wav
assets/audio/sfx/task_complete_01.wav
assets/audio/sfx/warning_01.wav
```

## Download-time provenance checklist

For every source actually acquired in the later asset-download/integration task:

1. Re-open the exact source page and confirm it still says **Creative Commons 0 / CC0**.
2. Record download date and the exact downloaded upstream filename.
3. Save a license/source snapshot or text record beside this manifest.
4. Preserve an untouched `source/` copy outside runtime imports if repository policy permits; derive trimmed/converted runtime versions from it.
5. Record every edit: trim timestamps, loop crossfade, gain/EQ, channel conversion and output format.
6. Audition for embedded speech, copyrighted music playing in the environment, clipping, obvious privacy issues or unwanted identifiable announcements before acceptance.
7. Only after actual Godot + Web playback should a sound be marked integrated/accepted.

## Important content risks to verify during audition

- **Office ambience:** reject or choose a different section if foreground speech is intelligible or distracting.
- **Subway ambience:** avoid clearly intelligible station announcements in the loop if they pull the fictional city toward Toronto or another real city; the source is a candidate because CC0 permits editing, not because every recorded detail automatically fits the fiction.
- **Footsteps:** wooden-floor steps suit the rental interior; office/subway may need harder-floor variants later.
- **MUS-01:** `Sadness.ogg` is technically/licensing-clean but may be emotionally too heavy. It must pass creative audition against the rental-apartment rain scene before final adoption.
- **SFX-10:** the processed texture may feel too gamey/sci-fi; it is a legal fallback, not an automatic final choice.

## Acceptance boundary of AUDIO-CONTENT-002

This task establishes a **legally traceable, prioritized candidate source pack**. It does **not** establish that any audio file has been downloaded, edited, imported, mixed, loop-tested, played in Godot, played in Web export, or approved by listening. Those are later task(s) with explicit binary/integration/runtime authorization.
