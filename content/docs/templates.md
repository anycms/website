+++
title = "模板"
description = "MiniJinja 模板语法、overlay 解析与契约变量"
weight = 6
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["templates", "minijinja", "filters", "functions", "jinja2"]
+++

模板引擎是 **[MiniJinja](https://github.com/mitsuhiko/minijinja)**（Jinja2 语法）。

- `{{ … }}` 输出
- `{% … %}` 控制流
- `{% extends %}` / `{% block %}` 继承

## overlay 解析（三级回退）

模板按 **site → theme → 内置技术模板** 的顺序解析。内置的 sitemap / rss / robots 模板可以被 site 或主题的同名文件覆盖。

## 契约变量

`base.html` 必须用 `| safe` 渲染三个接缝变量——插件注入和 SEO 才有落点：

```html
<head>
  {{ seo_head | safe }}      {# SEO meta/canonical/OG/JSON-LD，由 host 生成 #}
  {{ head_inject | safe }}    {# 插件 on_head_inject 注入的 <head> 标签 #}
</head>
<body>
  {{ body_inject | safe }}    {# 插件 on_body_inject，在 </body> 之前 #}
</body>
```

> ⚠️ MiniJinja 会把生成 URL 中的 `/` 转义成 `&#x2f;`，因此所有生成的链接在 `href` / `src` 中须标记 `| safe`。

## 可用变量

页面模板（`page.html`）上下文：

| 变量 | 说明 |
|---|---|
| `page.title` / `page.content` | 标题与渲染后的 HTML |
| `page.date` / `page.description` | 元数据 |
| `page.url` / `page.lang` | URL 与语言 |
| `page.summary` / `page.toc` | 摘要与目录 |
| `page.translations` | 其它语言翻译（`[{lang, url}]`） |
| `page.older` / `page.newer` | 前后页 |
| `page.taxonomies` | 分类法赋值 |

Section 模板（`section.html`）额外有 `section.title`、`section.content`、`section.pages`、`section.translations`。

全局变量：`config`（站点配置）、`current_lang`、`taxonomy`、`term`。

## 模板全局函数

| 函数 | 说明 |
|---|---|
| `get_page(url)` | 按 URL 查询任意页面，返回 page view 或空 |
| `get_section(url)` | 按 URL 查询任意 section，含 `.pages` 列表 |
| `now(format?)` | 当前 UTC 时间字符串。无参返回 RFC3339；传参用 `time` crate 格式描述语言（非 strftime） |
| `get_url(path, hash=true?)` | 工程相对路径的输出 URL；`hash=true` 追加 `?v=<短哈希>` 做缓存击穿（默认 `false`） |
| `get_hash(path)` | 文件 SHA-256 的前 10 位十六进制（文件不可读返回空串） |
| `trans(key, lang?)` | 从 `config.params.translations` 查翻译，缺失回退到 `key` 本身 |
| `get_taxonomy(kind, lang?)` | 序列化指定分类法（如 `tags`）；未声明返回 `undefined` |
| `get_image_metadata(path)` | 返回 `{ width, height, format }`；文件缺失 / 无法解码返回 `undefined` |

这两个全局函数让模板能在服务端做跨 section 的内容聚合（如文档侧边栏、相关页面），无需客户端脚本。本站的文档侧边栏就是用 `get_section("/docs/")` 自动生成的。

函数示例：

```jinja
{{ now("[year]-[month]-[day]") }}              {# 2026-06-20（time crate 格式语言，非 strftime） #}
<link rel="stylesheet" href="{{ get_url("/static/app.css", hash=true) | safe }}">
{{ trans("greeting") }}                        {# 缺失时回退到 "greeting" 本身 #}
{{ get_image_metadata("/static/cover.png").width }}
```

## 模板过滤器

除插件贡献的 dispatcher 外，host 还注册了一批第一方过滤器（不加载插件也始终可用）：

| 过滤器 | 说明 |
|---|---|
| `base64_encode` / `base64_decode` | 标准 base64（带 padding）编解码；非法输入解码为空串，不会 panic |
| `regex_replace(pattern, replacement)` | 正则替换所有匹配 |
| `markdown` | 将 Markdown 字符串渲染为 HTML（无 summary/TOC）；输出需 `| safe` |

```jinja
{{ content | base64_encode }}
{{ s | regex_replace("\\d+", "N") }}           {# 所有数字替换为 N #}
{{ "**bold**" | markdown | safe }}             {# 渲染为 <strong>bold</strong> #}
```

> 约定：缺失 / 无法解析的输入返回输入本身或 `undefined` / 空串，绝不中断构建。

## 导航菜单

`config.menu` 是一个「语言代码 → 菜单项数组」的映射。渲染当前语言的菜单，缺失时回退到默认语言：

```jinja
{% set ml = current_lang | default(config.default_language) %}
{% set items = config.menu[ml] | default(config.menu[config.default_language]) %}
{% for item in items %}
  <a href="{{ item.url | safe }}">{{ item.label }}</a>
{% endfor %}
```

每个菜单项有 `label`、`url`、`weight` 三个字段。
