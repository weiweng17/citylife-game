# 都市浮生 / CityLife

Godot 4.7.2 城市人生模拟游戏。

## 先从这三份文档开始

| 文档 | 看它能了解什么 |
| --- | --- |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | **各文件夹与各模块的职责**、模块边界约定、常见改动"改哪里"速查 |
| [docs/ITERATION_PLAN.md](docs/ITERATION_PLAN.md) | **开发规划的唯一权威**：五阶段范围、每阶段验收标准、当前进度 |
| [HANDOFF.md](HANDOFF.md) | 长期状态与踩坑总账，接手第一站 |

中断或更换开发者时，先读 `HANDOFF.md`，再看最新的 `docs/TODAY_HANDOFF_<日期>.md`（当日交接索引）与 `docs/QA_<日期>.md`（当日逐套测试实测与限制）。

## 目录速览

| 路径 | 作用 |
| --- | --- |
| `scenes/Main.tscn` | 唯一入口场景，其余一切由代码在运行时构建 |
| `scripts/` | 全部 GDScript，分根层 / `systems/` / `ui/` / `world/` 四层；**`Game.gd` 是唯一数值结算中枢** |
| `data/` | 事件、职业与结局规则、遭遇、NPC 日程、美术目录等 JSON |
| `assets/` | 美术与字体 |
| `tools/` | 开发期测试与截图脚本，不进游戏运行时 |
| `docs/` | 架构、计划、交接、QA、美术等文档 |

`.godot/`、`build/`、`working-source/` 是被 Git 忽略的本地目录：前者是导入缓存，中者是测试截图输出，后者是**早期脚手架残留副本（改它不生效，可直接忽略或删除）**。完整说明见 `docs/ARCHITECTURE.md`。

## 在线开发流程

本地 `main` 与远程 `origin/main` 保持同步：推送 `main` 后，GitHub Actions 会自动构建并发布 Web 预览；未推送的本地修改不会更新线上版本。

同步操作：**双击 `tools\push-local.cmd`**（该脚本会自己配好 portable Git 的 PATH 再 push；自动化环境里 PATH 会被替换，推不上去，原因见 `HANDOFF.md`）。

- 引擎：Godot 4.7.2 stable
- 分辨率：1280×720
- Web 导出预设：`Web`
- CI：GitHub Actions → GitHub Pages
- 当前阶段：第 3 阶段「NPC 与成长」进行中——NPC 日程热点、交谈、关系反馈（好感/档位/每日一次）已完成；工作技能成长与首批连续任务待做。第 2 阶段只剩人工试玩验收

## 目标体验

开局只进入居民区，随着剧情逐步解锁地铁站、公司、公园、便利店、咖啡馆、医院、旧巷、天台等独立地点，而不是把所有地点挤在一张地图里。

## 部署

工作流：`.github/workflows/deploy-web.yml`

仓库中存在 `project.godot` 时，CI 会使用 Godot 4.7.2 自动导出 Web；在源码迁入完成前，会先发布 `web-preview/` 引导页验证线上部署链路。
