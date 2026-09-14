# Audio / Music Agent Report

## Agent
- Lane: 06-Audio-Music
- Owner key: `audio-music`
- Coordination branch: `orchestrator/multi-agent-bootstrap`

## Current task
- ID: `AUDIO-CONTENT-002`
- Title: First-hour legally usable sound-source pack
- Branch: `agent/audio-content-002-first-hour-sound-pack`
- Status: **NEEDS_REVIEW**
- Priority: HIGH
- Player-visible: YES / directly unblocks audible vertical slice

## Authoritative task state read
Read latest coordination state before work:
- `docs/agents/TASK_BOARD.md`
- `docs/agents/FILE_OWNERSHIP.md`
- `docs/agents/WEB_AGENT_LAUNCHPAD.md`
- this report on the assigned task branch

`AUDIO-AUDIT-001` is already accepted by 00 at exact tip `cb17301c2dd9e4f4502e5279f27024dc84b503b1`; this task did **not** repeat that architecture audit.

## Writable scope used
Task-authorized files only:
- `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md`
- `agent-reports/audio-music.md`

No other repository files were intentionally modified.

## Deliverable summary
Created `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md` as the legal/source manifest for the first-hour audible slice.

### Curated core pack
- **1 home/rain-night music candidate**
  - `Sadness.ogg` — Kistol / OpenGameArt / CC0
- **3 ambience candidates**
  - `Office Ambience.wav` — 170026 / Freesound / CC0
  - `subway_ttc_ambience.wav` — larsn.wav / Freesound / CC0
  - `rain on window.wav` — Northern Rebel / Freesound / CC0; source explicitly says loopable
- **10 high-frequency SFX candidates**
  - UI click — `click.wav`
  - dialogue advance — `Maracas-click.wav`
  - indoor footsteps — `Footsteps Wooden Floor.wav`
  - door — `Door Open.wav`
  - keyboard/work — `keyboard_typing_loop1.wav`
  - study/page — `page_turn.wav`
  - cooking — `cooking.wav`
  - purchase/confirm — `CASHIER-REGISTER-KEYBOARD-BEEP-CALC.wav`
  - task complete — `success.wav`
  - warning/failure — `Negative.wav`
- **1 optional subway arrival layer**
  - `SUBWAY_01.WAV` — Manicciola / Freesound / CC0

All core candidates are source-page-verified as **Creative Commons 0 / CC0**. The manifest records exact source page, creator, upstream filename, format/duration, license, attribution requirement, modification rule, preparation recommendation, loop/fade behavior, priority and intended existing hook.

## Existing-hook mapping recorded
The source manifest maps candidates to the already-accepted audio audit handoff points, including:
- `LocationManager.current_location` for home/office/subway state;
- `TimeManager.period_changed` for later night/day music state;
- `WeatherSystem.weather_changed` for indoor rain strength/state;
- `LocationManager._advance_path()` / `_move_player()` movement state for footsteps;
- `HomeActivities` ids `leave`, `study`, `meal`;
- `OfficeActivities` id `work`;
- `DialogUI._on_next_pressed()`;
- `ShopUI.buy_requested(item_id)` after successful settlement;
- quest completion / reward path for task-complete feedback.

No hook code was modified.

## Rights / provenance result
The pack intentionally uses **CC0-only core candidates** for this first wave. Sources with unclear rights, YouTube-ripped audio, commercial-game audio and non-commercial-only licenses were excluded.

License guidance checked during curation:
- Freesound licensing FAQ states Freesound sounds can use different licenses and describes CC0 as the permissive zero-license case; therefore each selected Freesound item was individually checked for `Creative Commons 0` on its own page.
- OpenGameArt FAQ describes CC0/Public Domain works as usable, modifiable and distributable, including commercial use, without required attribution.
- The manifest instructs the future downloader to re-check the source page at download time and preserve a license/source snapshot because remote metadata can change.

## Creative / content risks retained for review
This is a **candidate source pack**, not automatic final casting:

1. `MUS-01 / Sadness.ogg` is licensing-clean and loop-ready but may be too mournful for the rental apartment. It requires creative listening against the rain-night scene before adoption.
2. Office recordings may contain foreground speech/telephone events; the later edit must choose a section without distracting intelligible dialogue.
3. Subway ambience can reveal a real-city identity through announcements. The later edit should prefer non-intelligible steady station texture; otherwise replace the source.
4. Wooden-floor footsteps fit the rental interior first; office/subway need harder-floor variants in a later expansion.
5. `Negative.wav` is a legal fallback for warning/failure but its processed texture may feel too gamey/sci-fi; reject if it breaks the grounded tone.

## Download / production / integration status
- Audio binaries downloaded into repository: **NO**
- Audio edited/trimmed/converted: **NO**
- Audio imported into Godot: **NO**
- AudioManager / AudioStreamPlayer / buses changed: **NO**
- `project.godot`, `Game.gd`, `LocationManager.gd` changed: **NO**
- Godot playback run: **NOT RUN**
- Web export/browser audio run: **NOT RUN**
- Listening/mix acceptance: **NOT CLAIMED**

This is deliberate: AUDIO-CONTENT-002 authorizes the source/license manifest and report only.

## Recommended integration order for the next authorized audio task
1. UI click + dialog advance.
2. Home rain-window ambience + home music bed.
3. Indoor footsteps + door.
4. Office ambience + keyboard/work action loop.
5. Subway ambience (+ optional arrival layer).
6. Study/page + cooking + purchase.
7. Task-complete + warning/failure feedback.

## Handoff requested from 00-Orchestrator
Review `assets/audio/licenses/CONTENT_WAVE_01_SOURCES.md`. If accepted, the smallest useful next task should explicitly authorize:

- acquisition of only the approved source binaries;
- preservation of provenance/download-date data;
- derivation of game-ready `.ogg` / `.wav` files under exact `assets/audio/**` paths;
- a narrow AudioManager/Bus/integration surface owned or co-assigned by the correct code lane;
- Codex/local Godot + Web playback verification on the exact integration SHA.

Until such authorization exists, this lane should not modify runtime audio configuration or claim any source has been integrated.
