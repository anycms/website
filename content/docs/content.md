+++
title = "内容模型"
description = "Page、Section、front matter、分类法、摘要与代码高亮"
weight = 5
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["content", "markdown", "frontmatter", "permalinks", "internal-links"]
+++

## Page 与 Section

- **Page**：单个 Markdown 文件，对应一个 URL。
- **Section**：一个目录，`_index.md` 是该 section 的列表页。

## Front matter

正文开头的元数据，支持 `+++ … +++`（TOML）或 `--- … ---`（YAML）两种格式：

```markdown
+++
title = "Hello World"
date = 2025-06-01
author = "liangdi"
draft = false
slug = "hello"
template = "page.html"
tags = ["rust", "ssg"]
+++

正文内容，支持 `<!-- more -->` 分割摘要。

<!-- more -->

摘要之后的内容。
```

## 排序

Section 中的页面按 **`weight` 升序**排序；`weight` 相同或缺失时按 **`date` 降序**。文档类内容建议显式设置 `weight` 控制顺序。

## 常用 front matter 字段

| 字段 | 作用 |
|---|---|
| `title` | 页面标题（必需） |
| `date` | 发布日期，影响排序与 feeds |
| `description` | 描述 / 摘要，用于 SEO 与列表页 |
| `cover` | 封面图路径（见下方「封面图」） |
| `draft` | `true` 的页面在 `build` 时被排除 |
| `slug` | 自定义 URL slug |
| `weight` | 排序权重（整数，升序） |
| `template` | 覆盖默认模板（如 `template = "docs.html"`） |
| `taxonomies` | 分类法赋值（如 `tags = ["rust"]`） |
| `aliases` | 重定向别名 URL 数组（如 `["/old/path/"]`），构建时生成跳转 |
| `expiry_date` | 过期日期字符串（如 `"2026-12-31"`），过期页在构建时被剔除 |

### 定时发布与过期

- **定时（scheduled）**：`date` 为**未来日期**的页面不会发布——构建时被剔除，直到日期到达。
- **过期**：设置 `expiry_date` 到一个已过去的日期，该页同样在构建时被剔除。

二者与 `draft` 一样作用于构建过滤，适合用于预告发布与限时内容下线，无需改动正文。

```toml
# 定时发布：日期到达后自动出现
date = 2099-01-01
author = "liangdi"

# 过期下线：日期过后自动消失
expiry_date = "2026-12-31"

# 重定向别名：旧 URL 跳转到本页
aliases = ["/old/blog/hello/", "/legacy/hello.html"]
```

## 封面图

`cover` 字段给页面指定一张封面图，列表卡片与单页都会用到。支持三种路径写法：

| 写法 | 示例 | 行为 |
|---|---|---|
| **绝对 / static** | `cover = "/covers/x.png"` | 指向 `static/` 下的文件（`static/covers/x.png`），原样输出 |
| **bundle 相对** | `cover = "assets/x.png"` | 相对页面**自身目录**解析（Hugo 式），无需手动拷贝到 `static/` |
| **远程** | `cover = "https://…"` | 透传，不做处理 |

```toml
title = "我的文章"
cover = "assets/cover.png"   # 与本文同目录的图片
```

本地封面（前两种）会走图像处理管线，生成多宽度响应式变体（输出到 `/_img/`），模板里以 `page.cover`（单页）和 `p.cover`（列表项）的形式拿到 `{ url, srcset }`。远程封面只给 `url`，无 `srcset`。

> 需在 `site.kdl` 开启 `image { enabled #true }` 才会生成变体；关闭时本地封面按 static 路径原样引用，不做处理。

官方主题 `ink` / `folio` / `manual` 都已内置封面渲染（列表缩略图 + 单页 hero）。

## 摘要与目录

- **摘要**：用 `<!-- more -->` 分割，前半段作为 `page.summary`。
- **目录（TOC）**：由标题自动生成，通过 `page.toc` 暴露给模板。

## 分类法页

由 `taxonomies` 配置自动生成。例如声明 `taxonomy name="tags"` 后，带 `tags = ["rust"]` 的页面会出现在 `/tags/rust/`。

## 代码高亮

用围栏代码块并声明语言，输出 class-based span，配合 `static/highlight.css` 着色：

````markdown
```rust
fn main() {
    println!("Hello, AnyCMS!");
}
```
````

## 内容互链

Markdown 中的相对链接会被解析为站点内链接，无需手写完整路径。另外支持 `@/` 前缀的**内容互链语法**——以工程内容根为基准指向目标页面，解析后输出目标页的最终 URL：

```markdown
详见 [部署文档](@/docs/deployment.md)。
```

`@/docs/deployment.md` 会被解析为该内容文件对应的站点 URL（如 `/docs/deployment/`），重命名或调整 permalink 时链接自动跟随，无需手改路径。

## 永久链接（permalinks）

在 `site.kdl` 中用 `permalink {}` 块自定义页面 / section 的 URL 模板，支持 `:year` / `:month` / `:day` / `:slug` 等占位符：

```kdl
permalink {
    page "/:year/:slug/"
    section "/:section/"
}
```

未声明 permalink 时沿用默认 URL 规则（目录 + slug）。
