# 都市浮生 / CityLife

Godot 4.7.2 城市人生模拟游戏。

当前执行顺序、验收条件与粗估工期见 [分阶段开发计划](docs/ITERATION_PLAN.md)。现阶段以本地版本验收为准，暂不推送/发布。

中断或更换开发者时，首先阅读根目录 [HANDOFF.md](HANDOFF.md)，再看最新的 `docs/TODAY_HANDOFF_<日期>.md`（当日交接索引）与 `docs/QA_<日期>.md`（当日逐套测试实测与限制）。

## 在线开发流程

远程 `main` 收到推送后，GitHub Actions 会自动构建并发布 Web 预览；本地修改不会更新线上版本。

- 引擎：Godot 4.7.2 stable
- 分辨率：1280×720
- Web 导出预设：`Web`
- CI：GitHub Actions → GitHub Pages
- 当前阶段：第 2 阶段「完整的一天」代码已闭环（家→地铁→公司→便利店→回家→睡到次日），只剩人工试玩验收；下一阶段为第 3 阶段「NPC 与成长」

## 目标体验

开局只进入居民区，随着剧情逐步解锁地铁站、公司、公园、便利店、咖啡馆、医院、旧巷、天台等独立地点，而不是把所有地点挤在一张地图里。

## 部署

工作流：`.github/workflows/deploy-web.yml`

仓库中存在 `project.godot` 时，CI 会使用 Godot 4.7.2 自动导出 Web；在源码迁入完成前，会先发布 `web-preview/` 引导页验证线上部署链路。
