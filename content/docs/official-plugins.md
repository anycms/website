+++
title = "官方插件指南"
description = "五个 Tier-1 官方插件的作用、hook 与典型场景"
weight = 16
date = "2026-06-21"
author = "liangdi"
template = "docs.html"
tags = ["plugins", "seo", "sitemap", "feed", "search"]
+++

`plugins/` 下提供 5 个开箱即用的官方插件（crate 名 `anycms-plugin-*`，author `AnyCMS`），覆盖最常见的「增强」场景。它们只增强 host 已有的内置 provider，不替换渲染管线——卸载后站点仍能正常构建，只是少了那部分增强。

每个插件的 `config {}` 默认值都能在 `site.kdl` 的 `plugins {}` 块中覆盖。

## seo-suite

- **作用**：配置驱动的 SEO 增强。
- **hook**：`on_seo`
- **能力**：OpenGraph / Twitter card / canonical / description 回退 / 去重 JSON-LD（WebSite、Organization、BreadcrumbList、Article）。
- **典型场景**：想让分享到社交平台的链接带预览卡片、被搜索引擎正确收录。
- **配置要点**：在 `site.kdl` 声明站点级 OG/Twitter 默认值，页面 front matter 可逐页覆盖。

## sitemap-robots

- **作用**：增强 `sitemap.xml` 并生成伴随的 `robots.txt`。
- **hook**：`on_sitemap`
- **能力**：按 URL 深度设 `changefreq` / `priority`、可选过滤 draft / noindex 页面、`lastmod` 回填。
- **典型场景**：想给爬虫更精确的更新频率与优先级提示，同时自动产出 `robots.txt`。

## search-index

- **作用**：增强逐页搜索文档。
- **hook**：`on_search_document`
- **能力**：清洗正文 HTML、生成智能摘要与语言、设置 `boost`、附带分类法/日期/类型字段、应用排除规则。
- **典型场景**：配合 [搜索索引](./search/) 的 `fuse_*` / `elasticlunr_json` 格式，让前端搜索结果更准（标题 boost 高、正文截断干净）。
- **配置要点**：`default_boost` 调整默认权重；`exclude_patterns` 按 URL 前缀排除某些页面进索引。装上它即**取代** host 的内置默认 enhancer。

## feed-suite

- **作用**：增强每条 RSS / Atom feed 条目。
- **hook**：`on_feed_entry`
- **能力**：补全摘要、正文、作者、分类、URL。
- **典型场景**：feed 条目缺作者或摘要时，按 `page.author` → `page.extra.author` → 配置的 `default_author` 回退填齐。
- **配置要点**：`default_author` 设站点默认作者。

## responsive-images

- **作用**：为 `<img>` 添加响应式属性。
- **hook**：`on_markdown_html`
- **能力**：按命名约定生成 `srcset` / `sizes` / `loading="lazy"` / `decoding`，**仅改写 HTML 标记，不重新编码图像**。
- **典型场景**：想让文章里的图片按视口自适应、懒加载。
- **与图像管线的关系**：本插件只改 HTML 标记；真正的多分辨率变体生成由 [图像处理管线](./image-processing/) 负责。两者协同：管线产出变体文件，插件把它们写进 `srcset`。

## 统一覆盖方式

```kdl
plugins {
    plugin "search-index" {
        default_boost 2.0
        exclude_patterns {
            pattern "/draft/"
            pattern "/private/"
        }
    }
    plugin "feed-suite" {
        default_author "AnyCMS Team"
    }
}
```
