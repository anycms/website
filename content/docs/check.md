+++
title = "链接检查器"
description = "anycms check 校验内部链接、锚点与可选外链，CI 友好"
weight = 13
date = "2026-06-21"
author = "liangdi"
template = "docs.html"
tags = ["cli", "check", "validation", "links"]
+++

`anycms check` 在不写出任何输出的前提下校验内容与链接，**错误返回非零退出码、警告不会**——非常适合挂进 CI 流水线。

```sh
anycms check [--root ROOT] [--skip-external-links]
```

## 校验范围

按以下顺序逐项校验：

### 内部链接

识别两种写法：

- 标准 Markdown 链接：`[文本](./path.md)` / `[文本](/blog/hello/)`
- 裸 HTML 链接：`<a href="/blog/hello/">`

链接形式都支持：

- 相对链接：`./foo.md`、`../bar.md`、`baz.md`
- 根相对链接：`/blog/hello/`

全部解析到构建出的 URL 索引。悬空链接（指向不存在的页面）报为错误。

不在检查范围的 scheme：`mailto:`、`tel:`、`ftp:`、`data:` 等非 `http(s)` 协议被跳过；**围栏代码块**中的链接也被忽略。

### 锚点 `#fragment`

链接中带 `#fragment` 时，该 fragment 必须指向目标页**真实存在的标题 id**。标题 id 由渲染器 slugify + 去重生成，与渲染端一致——你写 `[用法](/docs/#usage)`，就要求目标页确实有 `## 用法` 这个标题。

### 外链（可选，默认关）

仅当 `site.kdl` 中显式开启时才校验外部 `http(s)` 链接：

```kdl
check {
    external_links #true      // 默认 #false
}
```

开启后用 `reqwest` 做 `HEAD` → `GET` 回退校验，`2xx` / `3xx` 视为可达，有界并发（8）与 10s 超时。

CLI 标志 `--skip-external-links` 可以**强制关闭**外链检查——即便配置里开了也跳过，用于离线或受限网络环境下的快速校验：

```sh
anycms check --skip-external-links
```

## 与内部链接语法配合

`@/` 内容互链语法（见 [内容模型 · 内容互链](./content/#内容互链)）解析后同样进入 URL 索引，若指向的源文件不存在，`check` 会报告悬空链。

## 典型 CI 用法

```sh
anycms build && anycms check && anycms deploy
```

`check` 失败（非零退出）会中断流水线，保证带坏链的站点不会被发布。
