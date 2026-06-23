+++
title = "主题"
description = "主题是可分发的 bundle，含 manifest、模板与可选静态资源"
weight = 8
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["themes", "design", "overlay", "ui"]
+++

主题是可分发的 bundle：`theme.kdl` manifest + `templates/`（必需）+ 可选 `static/` / `sass/`。三个官方主题随仓库发布：

| 主题 | 定位 | 设计 | 展示能力 |
|---|---|---|---|
| [`ink`](/themes/) | 极简博客（**参考默认主题**） | 衬线、单栏、纸墨感 | 全套模板、feeds、sitemap、高亮、params 主题化 |
| [`manual`](/themes/) | 文档 / 手册 | 无衬线、顶部搜索、页内 TOC | section 导航、客户端 TOC、search.json |
| [`folio`](/themes/) | 作品集 / 视觉 | 粗体展示字、响应式画廊网格 | landing、项目卡片、`columns` 参数 |

## theme.kdl

```kdl
theme {
  name "ink"
  version "0.1.0"
  engine-version "0.1"        // 必需：必须与 host engine 的 major.minor 匹配
  author "AnyCMS"
  description "Minimal blog theme"
  params {
    accent default="#333"
    dark default="auto" enum="auto,on,off"
  }
}
```

## engine-version 校验

安装时与构建时都会检查：主题声明的 `engine-version` 必须与 host engine 共享 `major.minor`，否则拒绝。这保证主题与 host 的模板契约兼容。

## params 合并

主题在 `params {}` 中声明默认值，site 的 `params {}` 覆盖之，模板中读 `config.params.<key>`。

## 主题管理命令

```sh
anycms theme install <SOURCE> [--root ROOT] [--force] [--registry BASE] [--version VER]
anycms theme list   [--root ROOT]
anycms theme uninstall <NAME> [--root ROOT]
anycms theme package <DIR> [--output FILE] [--force]     # 打包为 <name>-<version>.zip
```

详见 [`docs/themes.md`](https://github.com/anycms/anycms-ssg/blob/master/docs/themes.md)。
