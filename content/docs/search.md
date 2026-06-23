+++
title = "搜索索引"
description = "search 配置：四种索引格式与字段裁剪"
weight = 15
date = "2026-06-21"
author = "liangdi"
template = "docs.html"
tags = ["search", "indexing", "plugins", "fuse"]
+++

`site.kdl` 中的 `search {}` 块控制内置搜索索引（`DefaultSearch` provider）的输出格式与字段裁剪。不声明该块时使用默认值（`json` 格式、含 title + content）。

```kdl
search {
    format "fuse_json"             // 默认 json
    include_title       #true     // 默认 true
    include_content     #true     // 默认 true
    include_description #false    // 默认 false
    include_date        #false    // 默认 false
    include_path        #false    // 默认 false
    truncate_content_length 1000  // 可选；正文中文字符截断长度
}
```

## 四种输出格式

| 格式 | 输出 | 适用 |
|---|---|---|
| `json`（默认） | 单一 `search.json`（语言无关） | 简单全站搜索，前端自定义解析 |
| `fuse_json` | 按语言分文件 `search_index.<lang>.json` | 配合 [Fuse.js](https://www.fusejs.io/) 模糊搜索 |
| `fuse_javascript` | 按语言分 `search_index.<lang>.js`，包裹为 `window.searchIndex = <json>;` | `<script>` 直接引入，无需 fetch |
| `elasticlunr_json` | 按语言分 `search_index.<lang>.json`（Elasticlunr schema） | 配合 [elasticlunr](http://elasticlunr.com/)（需启用特性） |

`format` 大小写不敏感。

## 字段裁剪

`include_*` 开关决定每条索引记录里收录哪些字段。正文默认开启但可能很长，用 `truncate_content_length` 截断（按字符计），避免索引文件膨胀。

## elasticlunr 需要特性

`elasticlunr_json` 依赖 [elasticlunr-rs](https://crates.io/crates/elasticlunr)，默认关闭以保持默认构建精简：

```sh
cargo build --features elasticlunr
```

未启用特性却选了该格式，构建会**返回明确错误**（提示重新编译），而非静默生成错误索引——避免线上搜索坏掉却没人发现。

## 与 search-index 插件协作

内置 `DefaultSearch` 是一个「合理的默认 enhancer」。装上官方插件 [search-index](./official-plugins/#search-index) 后，它会接管逐页增强（清洗正文 HTML、生成智能摘要与语言、设置 boost、附带分类法/日期/类型字段、应用排除规则），返回的 `Some(doc)` 会覆盖默认文档。

插件还可通过 `on_search_index` 整站聚合 hook 接管整份索引的输出——接管后 host 跳过内置输出，把索引文件交由插件生成。
