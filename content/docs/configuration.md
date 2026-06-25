+++
title = "配置（site.kdl）"
description = "站点与主题配置使用 KDL，字段说明与示例"
weight = 4
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["config", "kdl", "image", "search", "deploy", "check"]
+++

站点与主题配置使用 **[KDL](https://kdl.dev/)**。`anycms init` 生成的最小配置：

```kdl
title "My AnyCMS Site"
base_url "https://example.com"
default_language "en"
output_dir "public"

taxonomies {
    taxonomy name="tags"
}

languages {
    language code="fr"
}

theme "ink"            // 启用主题 overlay（可选）

// 插件级配置覆盖：覆盖各插件 manifest 中的 config {} 默认值（site 胜出）
plugins {
    plugin "reading-time" {
        wpm 250
    }
}
```

## 字段说明

| 字段 | 说明 |
|---|---|
| `title` / `base_url` | 站点标题与基准 URL（用于绝对链接、feeds、sitemap） |
| `default_language` | 默认语言代码 |
| `output_dir` | 构建输出目录（默认 `public`） |
| `theme` | 启用的主题名（对应 `themes/<name>/`） |
| `taxonomies` | 自定义分类法（`tags` / `categories` …） |
| `languages` | 额外支持的语言代码 |
| `params` | 自由参数表，主题默认值会被合并进来，模板中通过 `config.params.<key>` 读取 |
| `plugins` | 各插件的配置覆盖（递归合并，site 覆盖 manifest 默认值） |
| `menu` | 声明式、按语言组织的导航菜单 |
| `image` | 图像处理管线（EXIF 方向矫正、输出格式；见下文） |
| `check` | 链接检查选项（`external_links`，默认关闭） |
| `search` | 搜索索引格式与字段裁剪（json / fuse_json / fuse_javascript / elasticlunr_json） |
| `deploy` | 部署目标声明（见[部署](/docs/deployment/)） |

## 声明式导航菜单

用 `menu {}` 块声明导航，模板中通过 `config.menu` 读取。裸 `item` 节点构成默认语言菜单，`lang "<code>" {}` 子块提供按语言的覆盖：

```kdl
menu {
    item "Home" url="/"
    item "Docs" url="/docs/" weight=10
    item "GitHub" url="https://github.com/anycms/anycms-ssg" weight=90

    lang "fr" {
        item "Accueil" url="/fr/"
        item "Docs" url="/fr/docs/" weight=10
    }
}
```

菜单按 `weight` 升序排序；绝对 URL（`http(s)://`）视为外链。

> **KDL 注释**是 `//`，不是 `#`——`#` 在 KDL 里是布尔字面量前缀，写成注释会导致解析失败。

## 图像处理管线（`image {}`）

控制构建时的图像处理管线（默认 `enabled #false`，需显式开启）：

```kdl
image {
    enabled #true                 // 默认 false
    widths "640,1024,1920"        // 默认 [640, 1024, 1920]
    quality 80                    // 默认 80（JPEG/WebP/AVIF）
    auto_orient #true             // 默认 true — 读 EXIF Orientation(1–8) 在缩放前旋转
    format "auto"                 // 默认 auto；可选 jpeg/png/webp/avif（大小写不敏感）
}
```

- **EXIF 自动方向矫正**（`auto_orient`，默认 `true`）：读 EXIF `Orientation` 标签（1–8），在尺寸计算与变体生成前旋转成正立朝向，避免手机照片侧躺 / 倒置。EXIF 读取失败时回退到不旋转并打印警告，不中断构建。
- **输出格式**（`format`，默认 `auto`）：`auto` 保留源格式；也可统一转码为 `jpeg` / `png` / `webp` / `avif`。
- **AVIF 输出**：选择 `avif` 需启用 cargo 特性 `cargo build --features avif`（默认关闭）。编码器是纯 Rust 的 `ravif`，无需 C 工具链。注意仅支持 AVIF 编码、不支持解码。

## 链接检查（`check {}`）

`anycms check` 命令的链接检查选项。默认关闭外链 HTTP 校验，开启后用 `HEAD`→`GET` 回退校验（8 并发、10s 超时）：

```kdl
check {
    external_links #true          // 默认 false — 启用外链 HTTP 校验
}
```

CLI 标志 `--skip-external-links` 可强制关闭外链检查（即便配置里开了）。详见 [CLI check](/docs/getting-started/)。

## 搜索索引（`search {}`）

控制内置搜索索引（`DefaultSearch` provider）的输出格式与字段裁剪。缺省该块时使用默认值（`json` 格式、含 title + content）。插件可通过 `on_search_index` 整站聚合 hook 接管索引输出。

```kdl
search {
    format "fuse_json"          // 默认 json；可选 fuse_json / fuse_javascript / elasticlunr_json
    include_title       #true   // 默认 true
    include_content     #true   // 默认 true
    include_description #false  // 默认 false
    include_date        #false  // 默认 false
    include_path        #false  // 默认 false
    truncate_content_length 1000  // 可选；正文字符截断长度
}
```

- `json` 输出单一 `search.json`（语言无关）；`fuse_json` / `fuse_javascript` / `elasticlunr_json` 按语言分文件 `search_index.<lang>.json` / `.js`（`fuse_javascript` 包裹为 `window.searchIndex = …`，便于 `<script>` 直接引入）。
- `elasticlunr_json` 需 `cargo build --features elasticlunr`（默认关闭）；未启用时选择该格式返回明确错误而非静默生成坏索引。

## 部署（`deploy {}`）

声明一个或多个部署目标，供 `anycms deploy` 发布。内置四个 provider：`local`（镜像到本地目录，纯文件复制、零依赖）、`git`（GitHub Pages 风格 `git push`）、`ssh-rsync`（`rsync -avz --delete` over SSH），以及 `s3`（原生镜像同步到 S3 兼容存储，需 `--features s3`）。详见[部署](/docs/deployment/)。

```kdl
deploy {
    target "local-mirror" {
        provider  "local"
        path      "/var/www/site"      // 本地目标目录（绝对或相对 CWD）
        delete    #true                // 默认 true，镜像删除多余文件
    }
    target "gh-pages" {
        provider "git"
        repo     "git@github.com:user/user.github.io.git"
        branch   "gh-pages"
    }
    target "prod" {
        provider  "ssh-rsync"
        host      "user@host"
        path      "/var/www/site/"
        delete    #true
    }
}
```
