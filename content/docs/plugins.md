+++
title = "插件系统"
description = "WASM 插件、两层扩展点、权限化 host 函数与贡献机制"
weight = 9
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["plugins", "wasm", "extism", "hooks", "contribute"]
+++

插件是 WebAssembly 模块，构建时由 host 加载并按 **priority 顺序**（数字越小越先执行）调度。当前 API 契约版本为 **v0.2**。

## 两层扩展点

- **Layer 1 — 10 个通用管线 hook**：`on_build_start` / `on_build_end` / `on_config` / `on_content_discover` / `on_page_parse` / `on_markdown` / `on_markdown_html` / `on_template_context` / `on_template_output` / `on_asset`。
- **Layer 2 — 8 个业务域 hook，覆盖 5 个域**：
  - SEO：`on_seo`
  - Sitemap：`on_sitemap`
  - Search：`on_search_document`（逐页增强）、`on_search_index`（整站聚合）
  - Feed：`on_feed_entry`（逐条增强）、`on_feed`（整站聚合）
  - Inject：`on_head_inject` · `on_body_inject`
- **贡献（contribute）**：插件向模板引擎注册 `filter`（含多参 `filter_args`）/ `global_function` / `shortcode`。

## 写一个插件

```rust
use anycms_ssg_plugin_sdk::{plugin_fn, FnResult, TemplateContext};

/// 注入 reading_time 模板变量
#[plugin_fn]
pub fn on_template_context(mut ctx: TemplateContext) -> FnResult<TemplateContext> {
    let words = ctx.page.content.split_whitespace().count();
    let minutes = (words as f64 / 200.0).ceil() as u64;
    ctx.vars.insert("reading_time".to_string(), minutes.into());
    Ok(ctx)
}
```

`Cargo.toml`：

```toml
[lib]
crate-type = ["cdylib"]                      # 产出 .wasm

[dependencies]
anycms-ssg-plugin-sdk = "0.1"                # 唯一需要引入的包
extism-pdk = "1"                             # #[plugin_fn] 宏的直接依赖
```

构建目标必须是 **`wasm32-unknown-unknown`**（不是 `wasm32-wasip2`）。

## manifest（`<name>.kdl`）

```kdl
plugin {
  name "reading-time"
  version "0.1.0"
  api-version "0.2"                 // 当前 API 契约版本，必须为 "0.2"
  author "Liangdi"

  hooks {
    on-template-context priority=100
  }

  contributes {                     // 可选：向模板引擎贡献 filter/function/shortcode
    filter "shout"
  }

  permissions {                     // 权限声明，host 每次调用强制校验
    net "https://api.example.com/**"
    fs-read "./data/**"
    fs-write "./generated/**"
  }

  config {                          // 默认值，可被 site.kdl 覆盖
    wpm 200
  }
}
```

## Host Functions（权限化）

| Host 函数 | 所需权限 | 说明 |
|---|---|---|
| `host::get_config()` | 无 | 当前 SiteConfig 视图 |
| `host::get_plugin_config()` | 无 | 本插件合并后的配置 |
| `host::get_page(url)` | 无 | 内容库中的页面（Option） |
| `host::get_taxonomy(name)` | 无 | 指定分类法的 term 列表 |
| `host::now()` | 无 | 当前 unix 时间戳 |
| `host::get_state` / `set_state` | 无 | 插件私有跨 hook 键值状态 |
| `host::log(level, msg)` | 无 | 日志 |
| `host::http_get(url)` | `net` | HTTP GET（host 精确匹配 + path 前缀） |
| `host::http_post(url, body)` | `net` | HTTP POST |
| `host::read_file(path)` | `fs-read` | 读站点根下文件（拒绝 `..` 穿越） |
| `host::write_output(path, bytes)` | `fs-write` | 写输出目录 |

未声明权限的插件只能观察 / 转换 host 交给它的数据，无法触达文件系统或网络。host 用 `extism::Plugin::new` 加载插件且不传递 Manifest / `allowed_paths`，**WASI 文件系统访问完全禁用**，所有 FS / 网络访问都收敛到受权限保护的 host function。

## Strict 模式

设置环境变量 `ANYCMS_PLUGIN_STRICT=1`（任何非空非 `"0"` 值）后，任何插件的 hook 调度错误会**中止整个构建**（而非默认的 log + 跳过）。适用于 CI / 严格场景。

## 示例插件

[`examples/plugins/`](https://github.com/anycms/anycms-ssg/tree/master/examples/plugins) 下有 **14 个端到端可运行**的示例：

| 示例 | Hook / 贡献 | 演示 |
|---|---|---|
| `reading-time` | `on_template_context` | 注入 `reading_time` 模板变量 |
| `site-title` | `on_template_context` + host fn | 配置往返（config → wasm → 模板） |
| `uppercasify` | `on_markdown` | 渲染前改写原始 Markdown 源 |
| `virtual-page` | `on_content_discover` | 合成虚拟页面 |
| `state-demo` | `on_content_discover` + `on_template_context` | 插件私有跨 hook 状态 |
| `taxonomy-demo` | `on_template_context` | 分类法数据访问 |
| `now-demo` | `on_template_context` | `host::now()` 时间戳 |
| `body-inject` | `on_body_inject` | Inject 域：`</body>` 前注入 |
| `head-assets` | `on_head_inject` | Inject 域：`<head>` 资源注入 |
| `http-post-demo` | `on_build_start` + `on_template_context` | `host::http_post` 网络访问 |
| `config-demo` | `on_template_context` | manifest 配置被 site.kdl 覆盖 |
| `shout` | contribute `filter` | 贡献 MiniJinja filter（`{{ x | shout }}`） |
| `multi-filter` | contribute `filter`（`filter_args`） | 多参 filter（`{{ s | repeat(n) }}`） |
| `badge` | contribute `shortcode` | 插件声明内联 shortcode（`{{< badge >}}`） |

## 官方插件（Tier 1）

[`plugins/`](https://github.com/anycms/anycms-ssg/tree/master/plugins) 下提供 5 个开箱即用的官方插件（crate 名 `anycms-plugin-*`），只增强 host 内置 provider，不替换渲染管线：

| 插件 | Hook | 作用 |
|---|---|---|
| `seo-suite` | `on_seo` | OpenGraph / Twitter card / canonical / description 回退 / 去重 JSON-LD |
| `sitemap-robots` | `on_sitemap` | 按 URL 深度设 changefreq/priority、可选 draft/noindex 过滤、生成伴随 `robots.txt` |
| `search-index` | `on_search_document` | 清洗正文 HTML、生成智能摘要与语言、设置 boost、附带分类法/日期字段 |
| `feed-suite` | `on_feed_entry` | 增强每条 feed 条目（摘要、正文、作者、分类、URL） |
| `responsive-images` | `on_markdown_html` | 按命名约定为 `<img>` 加 srcset/sizes/lazy（仅改写 HTML 标记） |

每个插件的 `config {}` 默认值都可在 `site.kdl` 的 `plugins {}` 块中覆盖。完整开发指南见 [`docs/plugins.md`](https://github.com/anycms/anycms-ssg/blob/master/docs/plugins.md)。
