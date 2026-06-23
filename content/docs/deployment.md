+++
title = "部署"
description = "anycms deploy 一等命令：git / ssh-rsync / s3 发布到任意静态托管"
weight = 12
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["deploy", "git", "ssh-rsync", "s3", "ci", "github-pages"]
+++

`anycms deploy` 把 `output_dir`（默认 `public/`）发布到配置好的目标。它是 anycms 的**一等命令而非插件**——因此可以 shell 出系统的 `git` 与 `rsync`，或直接链接 AWS SDK 走 S3（沙箱插件无法做到）。内置三个 provider：

- **`git`**：GitHub Pages 风格的 `git push`，推送到指定仓库的分支。
- **`ssh-rsync`**：`rsync -avz --delete` over SSH，增量同步到远程目录。
- **`s3`**：原生镜像同步到任意 S3 兼容存储（MinIO / Cloudflare R2 / Backblaze B2 / 阿里 OSS / AWS S3），无需安装 `aws` CLI。需启用 cargo 特性 `--features s3`（默认关闭，保持构建精简）。

## 配置（`deploy {}`）

在 `site.kdl` 中声明一个或多个目标：

```kdl
deploy {
    target "gh-pages" {
        provider "git"
        repo     "git@github.com:user/user.github.io.git"
        branch   "gh-pages"
    }
    target "prod" {
        provider  "ssh-rsync"
        dest      "user@host:/var/www/site/"
        delete    #true              // 默认对齐 rsync --delete
    }
    target "cdn" {
        provider  "s3"               // 需 cargo build --features s3
        endpoint  "https://s3.minio.local:9000"
        bucket    "my-site"
        prefix    "blog/"            // 可选，桶内子前缀
        delete    #true              // 默认 true，镜像删除远端多余对象
        // 凭据省略 → 走 AWS_* env / ~/.aws/credentials；或显式 key_id + secret_key
    }
}
```

## CLI

```sh
anycms build
anycms deploy gh-pages            # 发布指定目标
anycms deploy --build             # 先 build 再发布
anycms deploy --dry-run           # 仅打印将执行的命令，不产生副作用
```

- `[TARGET]` 指向 `deploy {}` 中声明的某个 target 名称；不传时取默认目标。
- `--build` 在发布前自动跑一次 `anycms build`。
- `--dry-run` 打印底层 `git` / `rsync` 命令（`s3` 则列出将上传/将删除的对象，需联网 list），便于在 CI 调试，不执行真实推送。

## base_url

部署前确认 `site.kdl` 的 `base_url` 指向最终域名——它影响绝对链接、feeds 与 sitemap 中的 URL。

> 部署到子路径（如 `https://user.github.io/repo/`）时，需要相应调整 `base_url` 与资源路径策略。

## 其他托管平台

`anycms deploy` 覆盖最常见的 `git push` 与 `rsync` 场景；其余平台仍可用通用方式部署：

| 平台 | 做法 |
|---|---|
| Netlify / Vercel | 构建命令 `anycms build`，发布目录 `public` |
| Cloudflare Pages | 同上，构建命令指向 `anycms build` |
| S3 + CloudFront | 用内置 `s3` provider（见上方，需 `--features s3`）；或手动 `aws s3 sync public/ s3://<bucket> --delete` |

## CI 建议

在 CI 中运行质量门后再部署：

```sh
cargo fmt --all -- --check
cargo clippy --workspace --all-targets -- -D warnings
cargo build --workspace --all-targets
anycms build              # 站点构建本身也应零错误退出
anycms deploy --build     # CI 里建议用 --build 确保产物新鲜
```

设置 `ANYCMS_PLUGIN_STRICT=1` 可让任何插件 hook 错误中止构建，避免静默发布坏页面。
