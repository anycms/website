# AnyCMS SSG 官方网站

> <https://anycms.org> —— 用 AnyCMS SSG **自己**生成的官方网站（吃自己的狗粮）。

本目录是一个自包含的 anycms 站点：自带 `templates/` + `sass/`，不依赖任何主题。
内容来自仓库根的 `README.md` 与 `docs/`，设计走清爽浅色（Stripe / Tailwind 风）。

## 目录结构

```text
site.kdl              # 站点配置 + 导航菜单 + 发布目标
content/              # Markdown 内容
├── _index.md         # 首页（由 index.html 落地页渲染）
├── docs/             # 文档（12 篇，带侧边栏）
├── plugins/          # 插件展示
└── themes/           # 主题展示
templates/            # MiniJinja 模板（base / index / docs / section / page / taxonomy*）
sass/                 # _tokens.scss + main.scss
static/               # 原样拷贝：highlight.css + CNAME + .nojekyll
```

## 前置

需要仓库根编译出的 `anycms` 二进制：

```sh
# 在仓库根
cargo build --release          # → target/release/anycms
```

## 常用命令

```sh
# 本地开发（实时热重载，http://127.0.0.1:1111）
anycms serve --root sites/website

# 内容编辑后台（浏览器里编辑 / 预览 / 发布，http://127.0.0.1:3333/__anycms_admin/）
anycms admin --root sites/website --create-admin admin:s3cret

# 仅构建到 public/
anycms build --root sites/website

# 发布到 anycms.org（构建 + 镜像 + force-push 到 gh-pages）
anycms deploy gh-pages --root sites/website --build
```

## 发布约定（anycms.org）

- 站点发布到 `git@github.com:anycms/website.git` 的 **`gh-pages`** 分支，
  经 GitHub Pages 以自定义域 **`anycms.org`** 提供。
- 自定义域与禁用 Jekyll 的配置放在 **`static/CNAME`**（`anycms.org`）
  与 **`static/.nojekyll`**——构建时随 `static/` 拷入 `public/`，再由
  `anycms deploy` 一并推送。**改域名就改这两个文件。**
- 目标声明在 `site.kdl` 的 `deploy {}` 块（`provider "git"`）。
- `anycms deploy` 用 `git push --force`，只推 `gh-pages`，**不会动 `master`**。
- `master` 分支保留的是旧 Rspress 站点源码；旧线上版本已备份为远端 tag
  `site-pre-ssg`，可回滚。
- 站点沿用旧站的 Google Analytics（`G-Y3YQ0W814W`，写在 `base.html`）。

## 设计

- 清爽浅色、平面、靠 1px 发丝边框与排版建立结构；**无渐变字 / 光晕 / 玻璃 / 网格背景 / emoji**。
- 单一克制强调色（默认 `#2563eb`），可在 `site.kdl` 的 `params { accent "…" }` 调整。
- 支持 **light / dark 手动切换**：切换逻辑在 `ts/main.ts`（oxc 转译为 `/main.js`），
  `<head>` 里一段内联脚本按 **localStorage → 系统偏好 → 浅色** 的优先级在首屏前
  设定 `data-theme`，避免闪烁；切换按钮在页头右侧（sun/moon 图标）。`site.kdl` 的
  `params.dark` 留 `auto`，完全交给 JS。
- 代码块即便在浅色下也用深色（GitHub 风）。

## 写内容的几个约定（踩过的坑）

- **首页**由 `templates/index.html` 落地页渲染，`content/_index.md` 只提供标题元数据。
- **非根 section 的 `_index.md`** 默认走 `index.html`（会渲染成首页落地），
  所以 `/docs/`、`/plugins/`、`/themes/` 的 `_index.md` 必须显式写
  `template = "section.html"`。
- **文档页**用 `template = "docs.html"`（带侧边栏），并用 `weight` 控制顺序
  （侧边栏通过 `get_section("/docs/")` 自动同步）。
- 导航来自 `site.kdl` 的 `menu {}` 块；模板里对 taxonomy 上下文的 config 标量
  做了 `{"value":…}` 解包兜底（见 `base.html` 注释）。
- 所有生成 URL 在 `href`/`src` 里都要 `| safe`（MiniJinja 会把 `/` 转义成 `&#x2f;`）。
