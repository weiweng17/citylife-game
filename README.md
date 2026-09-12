# 都市浮生 / CityLife

Godot 4.7.2 城市人生模拟游戏。

## 在线开发流程

`main` 每次提交后，GitHub Actions 会自动构建并发布 Web 预览。

- 引擎：Godot 4.7.2 stable
- 分辨率：1280×720
- Web 导出预设：`Web`
- CI：GitHub Actions → GitHub Pages
- 当前阶段：迁入 MAP-002（独立地点场景 + 地点内移动）

## 目标体验

开局只进入居民区，随着剧情逐步解锁地铁站、公司、公园、便利店、咖啡馆、医院、旧巷、天台等独立地点，而不是把所有地点挤在一张地图里。

## 部署

工作流：`.github/workflows/deploy-web.yml`

仓库中存在 `project.godot` 时，CI 会使用 Godot 4.7.2 自动导出 Web；在源码迁入完成前，会先发布 `web-preview/` 引导页验证线上部署链路。
