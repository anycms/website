+++
title = "介绍"
description = "AnyCMS SSG 是什么，以及它和 Hugo / Zola 的根本差异"
weight = 1
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["overview", "ssg", "comparison", "fundamentals"]
+++

AnyCMS SSG 是 anycms 生态中的**静态站点生成器**（Static Site Generator），用 Rust 编写。

> 输入：Markdown + KDL 配置 + 主题；输出：可直接部署的静态 HTML 站点。

## 它解决了什么

与 Hugo / Zola 等「常规 SSG」相比，AnyCMS SSG 的根本差异在于：

**WASM 插件扩展机制 + 插件 / 主题市场。**

插件在这里不是附加功能，而是贯穿整个构建管线的主轴——内容发现、Markdown 渲染、模板上下文、SEO、sitemap、feed、资源处理，每一个阶段都可以被插件 hook。

## 技术栈

- **模板引擎**：[MiniJinja](https://github.com/mitsuhiko/minijinja)（Jinja2 的 Rust 实现）
- **Markdown**：[pulldown-cmark](https://github.com/pulldown-cmark/pulldown-cmark)（GFM 扩展）
- **样式**：[grass](https://github.com/kaj/grass)（纯 Rust Sass 编译 + 压缩）
- **HTML 压缩**：[minify-html](https://github.com/wilsonzlin/minify-html)
- **TypeScript**：[oxc](https://github.com/oxc-project/oxc)（纯 Rust 转译 + minify，无外部依赖）
- **代码高亮**：[syntect](https://github.com/trishume/syntect)（Sublime 语法，class-based）
- **配置**：站点 / 主题用 [KDL](https://kdl.dev/)，front matter 兼容 TOML / YAML
- **插件运行时**：[extism](https://extism.org/) wasm 沙箱（host SDK + PDK）
- **开发服务器**：axum + notify + WebSocket 实时热重载

## 适用场景

- 个人博客、技术文档、作品集
- 需要在构建期对内容做**程序化加工**的站点（阅读时长、聚合页、外部数据拉取、SEO 增强……）
- 希望**用代码而非配置**扩展 SSG 能力的开发者

准备好之后，前往[快速开始](/docs/getting-started/)生成你的第一个站点。
