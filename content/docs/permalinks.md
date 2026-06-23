+++
title = "URL 规则与重定向"
description = "permalink 模板、内容互链与 aliases 重定向"
weight = 19
date = "2026-06-21"
author = "liangdi"
template = "docs.html"
tags = ["content", "permalinks", "urls", "internal-links"]
+++

## 默认 URL 规则

未配置 permalink 时，URL 由「目录 + slug」构成：

- `content/blog/hello-world.md` → `/blog/hello-world/`
- `content/blog/_index.md` → `/blog/`

`slug` 默认取文件名（去扩展名），可在 front matter 覆盖：`slug = "hello"`。

## 自定义 permalink

`site.kdl` 的 `permalink {}` 块为页面 / section 定义 URL 模板，支持占位符变量：

```kdl
permalink {
    page "/:year/:slug/"
    section "/:section/"
}
```

| 变量 | 含义 |
|---|---|
| `:year` | front matter `date` 的年份 |
| `:month` | 月份（两位） |
| `:day` | 日（两位） |
| `:slug` | 页面 slug |
| `:section` | 所在 section 名 |

典型用法：博客用 `/:year/:month/:slug/` 归档式 URL，文档用 `/:section/:slug/`。

> 改 permalink 后，老链接会失效——配合下面的 `aliases` 做重定向。

## 内容互链 `@/`

Markdown 中用 `@/` 前缀做**内容互链**，以工程内容根为基准指向目标页面，解析后输出目标页的**最终 URL**（含 permalink 规则应用结果）：

```markdown
详见 [部署文档](@/docs/deployment.md)。
```

`@/docs/deployment.md` 解析为该内容文件对应的站点 URL（如 `/docs/deployment/`）。好处：

- 写的是源文件路径，可读、IDE 能跳转
- 重命名文件或调整 permalink 时，链接自动跟随，无需手改路径
- 目标页不存在时，[链接检查器](./check/) 会报告悬空链

## 重定向 `aliases`

页面迁移或改 URL 后，老链接可能已被外链 / 收藏。front matter 的 `aliases` 声明重定向别名 URL：

```toml
+++
title = "Hello World"
aliases = ["/old/blog/hello/", "/legacy/hello.html"]
+++
```

系统已支持 `aliases`——构建时为每个别名生成跳转（让访问老 URL 的用户 / 爬虫到达新页面）。

## 与排序字段的关系

`weight`、`date` 同时影响 URL（`:year` / `:month` / `:day` 来自 `date`）和 section 内排序（weight 升序、date 降序）。详见 [内容模型](./content/)。
