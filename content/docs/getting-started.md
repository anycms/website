+++
title = "快速开始"
description = "三步生成你的第一个 AnyCMS SSG 站点"
weight = 2
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["getting-started", "install", "cli", "quickstart"]
+++

## 前置要求

- **Rust 1.85+**（edition 2024，stable 工具链）
- 编写插件还需添加 wasm 编译目标：`rustup target add wasm32-unknown-unknown`

## 安装

```sh
git clone <repo-url> anycms-ssg
cd anycms-ssg
cargo install --path .        # 安装 `anycms` 二进制到 ~/.cargo/bin
```

> 也可直接用 `cargo run --` 代替已安装的 `anycms`。

## 三步生成你的第一个站点

```sh
anycms init my-site           # 生成站点骨架（site.kdl + content + templates + sass + ts）
cd my-site
anycms build                  # → public/（渲染 Markdown、编译 Sass、转译 TS、压缩 HTML）
anycms serve                  # → http://127.0.0.1:1111 实时热重载
```

编辑 `content/` 下的 Markdown，保存后浏览器自动刷新。

## 使用主题

```sh
anycms init my-site
cd my-site
anycms theme install ../themes/ink      # 安装内置主题到 ./themes/ink
# 在 site.kdl 中设置 theme "ink"，并删除 site 自带的 templates/ 和 sass/ 让主题生效：
rm -rf templates sass
anycms build && anycms serve
```

> **overlay 优先级**：site 的 `templates/*.html` 与 `sass/main.scss` 会**覆盖**主题同名文件。
> 全新 `init` 会同时生成这两者，要让已安装主题接管布局与样式，需先删除它们。详见[主题](/docs/themes/)。

## 安装一个插件

```sh
# 从内置示例构建并安装一个插件
cd examples/plugins/reading-time
anycms plugin build --install ../../sites/demo-ink --release

# 构建站点，插件自动加载
anycms build --root ../../sites/demo-ink
```

## 下一步

- 了解[站点结构](/docs/site-structure/)
- 配置你的 [`site.kdl`](/docs/configuration/)
- 编写你的[第一个插件](/docs/plugins/)
