+++
title = "MCP 端点（AI agent 接入）"
description = "anycms admin 内置的 MCP 端点：让 AI agent 直接编写内容、发布、构建、部署"
weight = 20
date = "2026-06-22"
author = "liangdi"
template = "docs.html"
tags = ["cli", "editor", "mcp", "automation", "ai"]
+++

`anycms admin`（内容编辑后台）除了浏览器 SPA,还内置一个 **MCP**（Model Context Protocol）端点,让外部 AI agent **直接**编写内容、发布、构建、部署——无需走 cookie 登录。基于 [`anycms-mcp`](https://github.com/ai-station/anycms-mcp) 0.3（axum 传输,支持 profile 过滤）。

适合自动化场景:让 Claude / 其它 agent 读你的内容库、起草新文章、一键发布上线。

## 端点路径

挂载在 admin 服务的根上（默认 `http://127.0.0.1:3333`）:

| 路径 | 说明 |
|---|---|
| `/mcp` | MCP streamable HTTP 端点（暴露所有工具） |
| `/mcp-profiles` | profile 管理 REST（`/list`、`/info`、`/{id}`、`POST`、`PUT`、`DELETE`）；`/info` 列出当前可用工具 |

## 启用（fail-closed）

MCP 端点能发布 / 部署,权限很大,因此**默认不挂载**。两种方式配置 bearer token,任一非空即启用（`site.kdl` 优先,都为空则 `/mcp` 返回 404）:

```kdl
// site.kdl
mcp {
    token "a-long-random-secret"
}
```

或环境变量兜底:

```sh
ANYCMS_MCP_TOKEN=secret anycms admin --root my-site
```

启动后会看到:

```
▶ MCP on http://127.0.0.1:3333/mcp  (profiles: /mcp-profiles)  — send `Authorization: Bearer <token>`
```

## 鉴权

每个请求带 bearer header:

```
Authorization: Bearer <token>
Accept: application/json, text/event-stream
```

缺失 / 错误 token → **401**；端点未挂载（token 未配）→ **404**。

## 工具

8 个工具,复用 editor 现有业务逻辑（与浏览器 SPA 走同一套代码,HTTP API 不变）:

| 工具 | 作用 |
|---|---|
| `list_content` | 列出全部内容页（source 路径 / URL / 标题 / 草稿标记 / 日期） |
| `get_draft` | 读取草稿（无 DB 行则从磁盘种子,不写库） |
| `upsert_draft` | 新建 / 更新草稿 + 追加版本快照（不落盘 content/） |
| `list_draft_revisions` | 列出某草稿的版本历史 |
| `publish` | 发布:写 `content/*.md` → rebuild → 可选 deploy |
| `build_site` | 触发整站重建 |
| `deploy_site` | 部署 `output_dir/` 到配置的 target |
| `render_preview` | Markdown → HTML（与编辑器实时预览同一渲染器） |

典型流程:`list_content` → `get_draft` → `upsert_draft` → `publish`。

## 试一下

```sh
# 探测:列出全部工具
curl http://127.0.0.1:3333/mcp-profiles/info -H "Authorization: Bearer <token>"
```

完整 MCP 调用走 streamable HTTP 握手（`initialize` → `notifications/initialized` → `tools/call`）,用任意 MCP 客户端（如 [mcp-inspector](https://github.com/modelcontextprotocol/inspector)）指向 `http://127.0.0.1:3333/mcp` 并带上 bearer header 即可。

## 安全说明

- **fail-closed**:token 未配则端点不挂载,绝不暴露无认证的 MCP。
- mutate 工具（`publish` / `build_site` / `deploy_site` / `upsert_draft`）以 `mcp-agent` 系统身份执行（无 session cookie）；启动时幂等插入一行 backing `users`（空密码、永远登不进 HTTP 登录）以满足 `drafts.updated_by` 等 FK 约束。
- token 是明文比较（服务端密钥,非用户密码）,建议用 `openssl rand -hex 32` 生成；生产环境配合 HTTPS / 反代使用。
- profile 过滤:可通过 `/mcp-profiles` REST 创建 profile 限定某 agent 只能用部分工具,请求时带 `X-MCP-Profile: <name>` header 或 `?profile=<name>` 即生效。
