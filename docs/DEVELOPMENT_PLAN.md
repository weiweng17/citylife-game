# 《都市浮生》开发规划

更新日期：2026-09-12

## 项目目标

《都市浮生》是一款 2D 都市人生模拟游戏，核心方向为：都市生活、时间推进、NPC 日程、随机事件、主线/暗线剧情、地点解锁、存档与多结局。

目标平台：Web、抖音小游戏、微信小游戏。

当前美术方向：半写实、细节丰富的现代中国城市雨夜背景 + 紧凑 Q 版/动漫化角色。避免像素风与赛博朋克。

## 当前已完成

- GameState 状态集中管理
- HUD 拆分
- DialogUI / EventUI 拆分
- EventSystem 独立
- StorySystem 独立
- NPC / POI / Interior 场景化
- WorldManager / InteractionSystem / StartUI / EndingUI
- 15 张场景背景接入
- TimeManager 时间系统
- NPC 日程系统
- 暗线旧巷系统
- EncounterSystem 遭遇系统
- SaveManager 存档系统
- WeatherSystem 天气系统
- 1280×720 Web UI
- 多地点独立场景切换
- 地点内移动原型
- Web 自动构建与 GitHub Pages 在线试玩
- 灰屏/地点层不可见问题已修复

## 当前开发重点

### P0：角色与场景融合

1. 主角比例重新标定
2. 脚底接触阴影
3. 雨夜环境光/冷色调融合
4. Y 坐标排序
5. NPC 从文字按钮升级为角色实体
6. 名字标签跟随角色
7. 场景遮挡关系

### P1：独立地图真正可玩

地图原则：地点不是挤在一张总地图，而是剧情逐步解锁的独立场景。

首批：
- 居民区
- 地铁站
- 公司

后续：
- 公园
- 便利店
- 咖啡馆
- 医院
- 天台
- 旧巷

每个地点需要：
- 独立背景
- 可行走区域
- 出入口
- 交互热点
- NPC 出现规则
- 场景专属事件池

### P2：地图交互

- 可行走区域约束
- 墙体/玻璃/护栏碰撞
- 住宅入口
- 便利店入口
- 地铁出入口
- 公司入口
- 点击热点触发交互
- 场景切换淡入淡出

### P3：NPC 系统升级

核心 NPC：小雨、陈姐、老张、老周、疯道士、阿哲、老板/主管、恋人/妻子、孩子。

升级内容：
- NPC 独立 sprite
- 日程驱动位置
- 点击对话
- 关系值
- 剧情状态
- 特殊事件
- 夜间/天气差异

### P4：剧情解锁规则

当前需要从“到达地点自动解锁下一地点”调整为“完成剧情/行动后解锁”。

建议流程：
居民区 → 地铁 → 公司 → 公园/便利店 → 咖啡馆/医院 → 暗线地点。

### P5：移动端适配

- Touch 输入
- 手机屏幕缩放
- UI 安全区
- Web 触控验证
- 抖音/微信适配准备

## 已知问题

- 部分旧 PNG 文件名存在编码损坏，Godot CI 会提示 Unicode/import error。
- CI 每次从 ZIP 解压并重新导入，构建较慢。
- 当前仓库仍以 `citylife_WEB001_SourceUpload.zip` 为主，不利于高频源码修改。
- 当前 NPC 仍未完全角色实体化。
- 场景尚未建立真正碰撞/遮挡层。

## 推荐工程结构

后续应迁移为标准仓库：

```text
project.godot
scripts/
scenes/
data/
assets/
docs/
.github/workflows/
```

不再依赖 CI 解压 ZIP 后通过字符串替换打补丁。

## 开发工作流

推荐：本地 Codex + 本地 Godot 高速开发，GitHub 作为单一源码仓库，main 分支自动发布 Web。

流程：

```text
本地 Codex 修改
→ 本地 Godot 快速验证
→ git commit
→ git push main
→ GitHub Actions 导出 Web
→ GitHub Pages 更新
→ 邮件通知
```

固定试玩地址：
https://weiweng17.github.io/citylife-game/
