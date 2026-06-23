+++
title = "站点结构"
description = "一个 anycms 站点的标准目录布局"
weight = 3
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["structure", "filesystem", "overlay", "project"]
+++

一个 `anycms` 站点的标准目录布局：

```text
my-site/
├── site.kdl              # 站点配置（KDL）
├── content/              # Markdown 内容
│   ├── _index.md         # 首页内容
│   ├── _index.fr.md      # 首页法语翻译
│   └── blog/
│       ├── _index.md     # blog section 列表页
│       └── hello-world.md
├── templates/            # MiniJinja 模板（覆盖主题同名模板）
│   ├── base.html
│   ├── index.html
│   └── page.html
├── sass/                 # Sass 源（编译为 public/main.css）
│   └── main.scss
├── ts/                   # TypeScript 源（转译为 public/main.js）
│   └── main.ts
├── static/               # 原样拷贝到 public/
├── themes/               # 已安装主题（overlay 来源）
│   └── ink/
├── plugins/              # 已安装插件（<name>.wasm + <name>.kdl）
│   └── reading-time.{wasm,kdl}
└── public/               # 构建输出（生成物，勿提交）
```

## 关键目录

| 目录 / 文件 | 作用 |
|---|---|
| `site.kdl` | 站点配置，唯一必需的入口文件（至少要有 `title`） |
| `content/` | 所有 Markdown 内容，目录结构映射为 URL |
| `templates/` | MiniJinja 模板，overlay 优先级最高 |
| `sass/` | `main.scss` 会被编译为 `public/main.css` |
| `ts/` | TypeScript 会被转译 + minify 为 `public/*.js` |
| `static/` | 原样拷贝到输出目录 |
| `themes/` | 通过 `theme install` 安装的主题 |
| `plugins/` | 通过 `plugin install` 安装的插件 |
| `public/` | 构建产物，应当加入 `.gitignore` |

## overlay 三级回退

模板与静态资源按 **site → theme → 内置** 的顺序回退：

1. **site** 的 `templates/*.html`、`sass/main.scss`、`static/**` 优先级最高；
2. 其次是已启用的**主题**；
3. 最后是 host 的**内置技术模板**（sitemap / rss / robots，可被覆盖）。

> 本官方网站就是完全自包含的站点：它自带 `templates/` 与 `sass/`，不依赖任何主题——这同样是一种合法的用法。

## 最小化站点

一个最小可构建的站点只需要：

```text
my-site/
├── site.kdl        # title "Hello"
└── content/
    └── _index.md   # # Hello world
```

其余目录都是可选的。
