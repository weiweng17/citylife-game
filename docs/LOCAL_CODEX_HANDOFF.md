# 本地 Codex 接手说明

## 推荐模式

本地 Codex 负责高频开发，本地 Godot 负责快速运行验证，GitHub 负责版本管理和自动发布。

## 当前线上结构

仓库：`weiweng17/citylife-game`

固定试玩：
https://weiweng17.github.io/citylife-game/

当前线上仍主要通过：

```text
citylife_WEB001_SourceUpload.zip
+ .github/workflows/deploy-web.yml
```

Actions 解压 ZIP 后会应用一组 Web 补丁再导出。

## 已知最新线上修复

- 地点层新游戏/读档后强制重新显示
- Godot 4.7 `get_minute_of_day()` 兼容
- 居民区开场背景切换为街角雨夜
- Web viewport 尺寸同步
- 背景层尺寸同步
- 便利店事件映射从 cafe 修复到 street
- 地点名称使用中文名显示
- 主角缩小、接触阴影、环境色、Y 排序的第一轮整合

## 最重要的下一步

把 ZIP 内源码迁移到仓库根目录，形成标准 Godot 项目：

```text
project.godot
scripts/
scenes/
data/
assets/
docs/
.github/workflows/
```

完成后，删除 workflow 中针对 ZIP 的临时 Python 字符串补丁，直接维护真实源码。

## Godot 版本

当前线上导出版本：Godot 4.7.2 stable。

注意 GDScript：
- 避免对 Variant 结果使用不明确的 `:=`
- 需要时显式写类型，例如：`var minute: int = int(...)`

## 近期优先任务

1. NPC 实体化
2. 主角/NPC 与背景视觉融合
3. 可行走区域
4. 场景遮挡层
5. 居民区/地铁/公司独立地图深化
6. 剧情驱动地点解锁
7. Touch 输入和移动端适配
8. 清理乱码旧资源

## 提交流程

```bash
git add .
git commit -m "feat: ..."
git push origin main
```

main 更新后，GitHub 会自动构建并发布 Web 版本。
