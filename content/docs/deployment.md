+++
title = "部署"
description = "anycms deploy 一等命令：local / git / ssh-rsync / s3 发布到任意静态托管"
weight = 12
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["deploy", "local", "git", "ssh-rsync", "s3", "ci", "github-pages"]
+++

`anycms deploy` 把 `output_dir`（默认 `public/`）发布到配置好的目标。它是 anycms 的**一等命令而非插件**——因此可以 shell 出系统的 `git` 与 `rsync`，或直接链接 AWS SDK 走 S3（沙箱插件无法做到）。内置四个 provider：

- **`local`**：把 `output_dir` 的内容镜像复制到一个本地目录。纯 `std::fs`，不 shell out、不联网——零依赖基线。适合本地 web docroot、挂载卷，或某个 sidecar 进程监听的暂存目录。
- **`git`**：GitHub Pages 风格的 `git push`，推送到指定仓库的分支。
- **`ssh-rsync`**：`rsync -avz --delete` over SSH，增量同步到远程目录。
- **`s3`**：原生镜像同步到任意 S3 兼容存储（MinIO / Cloudflare R2 / Backblaze B2 / 阿里 OSS / AWS S3），无需安装 `aws` CLI。需启用 cargo 特性 `--features s3`（默认关闭，保持构建精简）。

## 配置（`deploy {}`）

在 `site.kdl` 中声明一个或多个目标：

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
        delete    #true              // 默认对齐 rsync --delete
        port      22                 // 可选，默认 22
        exclude   "drafts/**"        // 可选，一条或多条 --exclude 模式
    }
    target "cdn" {
        provider  "s3"               // 需 cargo build --features s3
        endpoint  "https://s3.minio.local:9000"
        bucket    "my-site"
        region    "auto"             // 可选，默认 us-east-1
        prefix    "blog/"            // 可选，桶内子前缀
        delete    #true              // 默认 true，镜像删除远端多余对象
        // 凭据省略 → 走 AWS_* env / ~/.aws/credentials；或显式 key_id + secret_key
    }
}
```

## provider 细节

### `local`

零依赖本地镜像：把 `output_dir` 的内容复制到目标 `path`。相对路径按运行 `anycms deploy` 时的工作目录解析（与 `cp`/`rsync` 对相对目标的行为一致）。

| 参数       | 必填 | 默认  | 含义                                            |
|-----------|------|------|------------------------------------------------|
| `provider`| 是   | —    | 必须为 `"local"`                                |
| `path`    | 是   | —    | 目标目录（绝对路径或相对当前工作目录）              |
| `delete`  | 否   | `true` | 镜像：删除 `path` 中源里已不存在的文件（等同 `rsync --delete`）|

`delete #true`（默认）下目标成为源的精确镜像；`delete #false` 则是叠加复制，保留 `path` 里已有的额外文件。清除步骤只清空目录内容，**不会删除顶层 `path` 本身**（它可能是挂载点）。

安全护栏：该 provider 拒绝部署到 `output_dir` 自身或任何与之重叠的路径，避免清空步骤删掉源、或复制步骤递归。该检查在 dry-run 下也生效。

> `--dry-run` 打印复制计划（目标、镜像还是叠加、文件数），不触碰文件系统。

### `git`

把 `output_dir` 的内容推送到远端分支。典型用途：GitHub Pages。

| 参数       | 必填 | 默认       | 含义                                  |
|-----------|------|-----------|---------------------------------------|
| `provider`| 是   | —         | 必须为 `"git"`                         |
| `repo`    | 是   | —         | 推送目标 URL（`git@...`、`https://...`）|
| `branch`  | 否   | `"gh-pages"` | 推送到的分支                          |

工作方式：anycms 在 `<site>/.anycms/deploy/<target>/` 维护一个**持久工作仓库**，跨多次部署复用历史（无需每次重新 clone）。每次部署把 `output_dir/` 镜像进该工作仓库（保留 `.git/`）、以 `anycms deploy` 身份提交，再执行 `git push --force origin <branch>:<branch>`。若产物与上次部署逐字节相同，提交步骤是 no-op，命令报告 `nothing to deploy`。

> **警告**：`git push --force` 会改写目标分支历史。务必把 `branch` 指向专用部署分支（默认 `gh-pages`），**不要**指向 `main`/`master`——provider 会在你这么做时打印警告。鉴权走你正常的 git credential helper / SSH agent，无交互式密码提示。

### `ssh-rsync`

`rsync -avz --delete` 把输出目录同步到远端 `host:path`（over SSH）。

| 参数       | 必填 | 默认  | 含义                                       |
|-----------|------|------|--------------------------------------------|
| `provider`| 是   | —    | 必须为 `"ssh-rsync"`                        |
| `host`    | 是   | —    | `user@server`                               |
| `path`    | 是   | —    | 远端绝对路径                                 |
| `delete`  | 否   | `true` | 传 `--delete`（镜像语义）                    |
| `port`    | 否   | `22` | ssh `-p`                                     |
| `exclude` | 否   | —    | 一条或多条 `--exclude` 模式（字符串或数组）       |

`output_dir` 的末尾斜杠会自动补上——rsync 同步的是 `public/` 的**内容**，而非 `public` 目录本身。

rsync 的 stdout+stderr 被**捕获**（不再实时流式输出），并在部署完成后于独立面板中展示，因此绝不会与 anycms 自身的状态输出交错。代价是：由于流被捕获而非继承，**首次 SSH host-key 确认提示不再实时显示**——请预先接受 host key（或使用基于密钥的鉴权），以便非交互式 rsync 一次成功。`git` provider 的子进程输出同理被捕获到同一面板。

> `--dry-run` 打印组装好的 rsync 命令但不执行——建议在第一次 `--delete` 部署前先跑一次。

### `s3`

把 `output_dir` 镜像到 S3 兼容 bucket（MinIO / Cloudflare R2 / Backblaze B2 / 阿里 OSS / AWS S3）。与 `git`/`ssh-rsync` 不同，它是**原生**的——直接链接 `aws-sdk-s3`，不 shell out，因此无需安装 `aws` CLI。受 `s3` cargo 特性门控（默认关闭，保持构建精简）：

```sh
cargo build --features s3        # 或：cargo install --path . --force --features s3
```

| 参数         | 必填 | 默认         | 含义                                                  |
|-------------|------|-------------|-------------------------------------------------------|
| `provider`  | 是   | —           | 必须为 `"s3"`                                          |
| `bucket`    | 是   | —           | S3 bucket 名                                           |
| `endpoint`  | 否*  | 服务默认     | 自定义 endpoint URL（非 AWS 时实际必填）                   |
| `region`    | 否   | `us-east-1` | AWS region                                             |
| `prefix`    | 否   | bucket 根    | 桶内子前缀                                              |
| `key_id`    | 否   | —           | 显式 access key（`key_id`+`secret_key` 要么都给，要么都不给）|
| `secret_key`| 否   | —           | 显式 secret key（同上）                                   |
| `delete`    | 否   | `true`      | 删除本地输出中已不存在的远端对象（镜像语义）                  |

**凭据**：省略 `key_id`/`secret_key` 时，provider 回落到 aws-sdk 默认凭据链——`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` 环境变量、`~/.aws/credentials` profile、IMDS 或 Web Identity。这是 CI / 已配置好凭据的服务器的推荐做法，把密钥挡在 `site.kdl` 之外。

provider 上传 `output_dir` 下每个文件（保留相对路径、按扩展名推断 `Content-Type`），并在 `delete #true` 下删除 prefix 下本地已不存在的远端对象——与 `rsync --delete` 相同的镜像语义。它是原生 SDK 调用，无子进程，因此不会产生面板输出。

> `--dry-run` 会列出**将**上传/删除的对象（仍需联网 list 现有对象），但不执行任何上传/删除。

## CLI

```sh
anycms build
anycms deploy gh-pages            # 发布指定目标
anycms deploy --build             # 先 build 再发布
anycms deploy --dry-run           # 仅打印将执行的命令，不产生副作用
anycms deploy --root ./site       # 指定 site.kdl 所在目录（默认 .）
```

- `[TARGET]` 指向 `deploy {}` 中声明的某个 target 名称；不传时：恰好一个目标则自动选中、零个报错、多个则报错并列出可选项。
- `--build` 在发布前自动跑一次 `anycms build`。
- `--dry-run` 打印底层 `git` / `rsync` 命令（`s3` 则列出将上传/将删除的对象，需联网 list），便于在 CI 调试，不执行真实推送。
- 退出码：成功 `0`，任何失败非零（stderr 给出清晰错误）。

## base_url

部署前确认 `site.kdl` 的 `base_url` 指向最终域名——它影响绝对链接、feeds 与 sitemap 中的 URL。

> 部署到子路径（如 `https://user.github.io/repo/`）时，需要相应调整 `base_url` 与资源路径策略。

## 其他托管平台

`anycms deploy` 覆盖最常见的 `git push`、`rsync`、本地镜像与 S3 场景；其余平台仍可用通用方式部署：

| 平台 | 做法 |
|---|---|
| Netlify / Vercel | 构建命令 `anycms build`，发布目录 `public` |
| Cloudflare Pages | 同上，构建命令指向 `anycms build` |
| S3 + CloudFront | 用内置 `s3` provider（见上方，需 `--features s3`）；或手动 `aws s3 sync public/ s3://<bucket> --delete` |
| 本地 / 挂载卷 | 用内置 `local` provider 镜像到目标目录 |

## CI 建议

在 CI 中运行质量门后再部署：

```sh
cargo fmt --all -- --check
cargo clippy --workspace --all-targets -- -D warnings
cargo build --workspace --all-targets
anycms build              # 站点构建本身也应零错误退出
anycms deploy --build     # CI 里建议用 --build 确保产物新鲜
```

设置 `ANYCMS_PLUGIN_STRICT=1` 可让任何插件 hook 错误中止构建，避免静默发布坏页面。`git`/`ssh-rsync` 部署需在 CI 环境里预先配置好凭据与（SSH 场景下）已接受的 host key——`anycms deploy` 不做交互式输入。
