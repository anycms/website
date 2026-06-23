+++
title = "分发：静态注册中心"
description = "从一个带 index.json 的静态目录分发插件与主题"
weight = 11
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["registry", "distribution", "packages", "publishing"]
+++

插件与主题可从**静态注册中心**分发——一个带 `index.json` 索引的目录，托管在任何静态服务上（GitHub Pages、S3、本地目录）。无需动态服务器、鉴权或数据库。

## 维护者：构建注册中心

```sh
# 把制品放入版本化目录后重建索引
anycms-registry build /path/to/registry-root     # 扫描 + 打包 theme tar.gz + 算 sha256 + 写 index.json
anycms-registry serve /path/to/registry-root --port 1111   # 本地静态服务（用于测试）
```

`anycms-registry` 是一个独立二进制。

## 用户：从注册中心安装

```sh
anycms plugin install shout --registry https://example.com/registry --root ./my-site
anycms theme   install ink   --registry https://example.com/registry --root ./my-site --version 0.1.0
anycms plugin install shout --registry /srv/registry --root ./my-site   # 本地路径也行
```

每个可下载制品在索引中带 `sha256`，下载时校验。

## 安装源自动判别

`install` 的 `SOURCE` 自动判别：

- `http(s)://` / `git@` / `ssh://` 开头 → git 仓库
- 否则 → 本地目录
- 配合 `--registry` → 注册中心包名

## 完整流程

打包 → 发布到注册中心 → 用户安装。详见 [`docs/publishing.md`](https://github.com/anycms/anycms-ssg/blob/master/docs/publishing.md) 与 [`docs/registry.md`](https://github.com/anycms/anycms-ssg/blob/master/docs/registry.md)。
