+++
title = "开发调试面板"
description = "serve 自带的 DevTools 面板：切换主题、启停插件、可视化 params"
weight = 14
date = "2026-06-21"
author = "liangdi"
template = "docs.html"
tags = ["cli", "development", "debugging", "devtools"]
+++

`anycms serve` 在本地开发服务器上自动注入一个**调试面板**（DevTools），仅在 localhost 下生效，帮助你在写内容时快速切换配置、观察构建状态。

## 打开面板

启动 serve 后，浏览器右下角会出现一个浮动按钮，点击即在 `/__anycms_dev` 打开面板（SPA 路由）。也可以直接访问：

```
http://127.0.0.1:1111/__anycms_dev/
```

## 面板能力

- **切换主题（theme）**：在已安装主题之间快速切换，无需改 `site.kdl` 再重启。
- **启停插件（plugin）**：勾选 / 取消勾选插件，即时看到带或不带某个插件的效果（等价于 `anycms plugin enable/disable`，但无需离开浏览器）。
- **可视化 params**：浏览当前合并后的 `config.params`，确认主题默认值与 site 覆盖值如何叠加。
- **构建状态与路由表**：查看上次构建是否成功，以及当前的路由表（哪些 URL 被生成）。
- **show drafts toggle**：临时显示 / 隐藏草稿页面，对比发布前后的差异。

## 关闭面板

```sh
anycms serve --no-devtools
```

启用后调试路由（`/__anycms_dev/*`）返回 404，页面不再注入浮动按钮——适合做最终演示或录屏。

## 增量重建

serve 的热重载不是「全量重建」——它会根据**变更类型**选择重建范围：

| 变更 | 重建范围 |
|---|---|
| 单个内容页 | 仅重建受影响页面（跳过未变动的页面） |
| 模板 / `site.kdl` / asset / 插件 | 自动全量重建 |

所以改一篇文章能秒级刷新，而改模板或配置会触发整站重建。WebSocket 连接在构建完成后推送刷新指令，浏览器自动重载。

## 安全

DevTools 仅在 localhost 下注入，**不会**出现在 `anycms build` 的产物中——它是开发期工具，不进入 `public/`。
