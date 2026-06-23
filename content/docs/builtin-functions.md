+++
title = "模板内置函数与过滤器"
description = "host 注册的全局函数与过滤器完整参考"
weight = 17
date = "2026-06-21"
author = "liangdi"
template = "docs.html"
tags = ["templates", "functions", "filters", "reference"]
+++

除插件贡献的 dispatcher 外，host 在模板环境上注册了一批第一方全局函数与过滤器（对标 Zola 的 Tera）。**不加载任何插件也始终可用。**

> 约定：缺失 / 无法解析的输入返回输入本身或 `undefined` / 空串，**绝不中断构建**。

## 全局函数

### `now(format?)`

当前 UTC 时间字符串。

- 无参：返回 RFC3339，如 `2026-06-21T13:45:00Z`
- 传参：使用 `time` crate 的**格式描述语言**（不是 strftime），如 `now("[year]-[month]-[day]")`

```jinja
{{ now() }}                          {# 2026-06-21T13:45:00Z #}
{{ now("[year]-[month]-[day]") }}    {# 2026-06-21 #}
```

### `get_url(path, hash=true?)`

工程相对路径（如 `/static/app.css`）的输出 URL。`hash=true` 时追加 `?v=<短哈希>` 做缓存击穿（默认 `false`）。返回的 URL 在 `href` / `src` 中需 `| safe`。

```jinja
<link rel="stylesheet" href="{{ get_url("/static/app.css", hash=true) | safe }}">
```

### `get_hash(path)`

文件 SHA-256 的前 10 位十六进制。文件不可读时返回**空串**（不报错）。

```jinja
{{ get_hash("/static/app.css") }}    {# a1b2c3d4e5 #}
```

### `trans(key, lang?)`

从 `config.params.translations` 查翻译，缺失时**回退到 `key` 本身**（Zola 行为）。`lang` 缺省取 `default_language`。

```jinja
{{ trans("greeting") }}              {# 缺失时输出 "greeting" 本身 #}
{{ trans("greeting", "fr") }}
```

### `get_taxonomy(kind, lang?)`

序列化指定分类法（如 `tags`）。未声明该分类法时返回 `undefined`。`lang` 目前接受但不过滤。

```jinja
{% set tags = get_taxonomy("tags") %}
{% for term in tags.terms %}{{ term.name }} {% endfor %}
```

### `get_image_metadata(path)`

返回 `{ width, height, format }`。文件缺失 / 无法解码时返回 `undefined`。

```jinja
{% set img = get_image_metadata("/static/cover.png") %}
{% if img %}{{ img.width }}x{{ img.height }}{% endif %}
```

### `get_page(url)` / `get_section(url)`

按 URL 查询任意页面 / section，返回 page view 或空。`get_section` 额外含 `.pages` 列表。用于跨 section 聚合（如文档侧边栏、相关页面），无需客户端脚本。

```jinja
{% set docs = get_section("/docs/") %}
{% for p in docs.pages %}<a href="{{ p.url | safe }}">{{ p.title }}</a>{% endfor %}
```

> 本站文档侧边栏就是用 `get_section("/docs/")` 自动生成的。

## 过滤器

### `base64_encode` / `base64_decode`

标准 base64（带 padding）编解码。**非法输入解码为空串，不会 panic。**

```jinja
{{ "hello" | base64_encode }}            {# aGVsbG8= #}
{{ "aGVsbG8=" | base64_decode }}         {# hello #}
{{ "!!!not-base64!!!" | base64_decode }} {# 空串，不报错 #}
```

### `regex_replace(pattern, replacement)`

正则替换**所有**匹配。

```jinja
{{ "abc123def456" | regex_replace("\\d+", "N") }}   {# abcNdefN #}
```

### `markdown`

将 Markdown 字符串渲染为 HTML（无 summary / TOC）。输出是原始 HTML，需链 `| safe` 才不被转义。

```jinja
{{ "**bold** and [link](/x/)" | markdown | safe }}
{# <strong>bold</strong> and <a href="/x/">link</a> #}
```

## `| safe` 约定

MiniJinja 会把生成的 URL 中的 `/` 转义成 `&#x2f;`。因此**所有** `get_url` / `page.url` / `term.permalink` 等 URL 在 `href` / `src` 中必须标 `| safe`，否则浏览器会请求到带转义字符的坏地址。

```jinja
{# 正确 #}
<a href="{{ page.url | safe }}">
<link href="{{ get_url("/static/app.css") | safe }}">

{# 错误 —— 会变成 &#x2f; #}
<a href="{{ page.url }}">
```
