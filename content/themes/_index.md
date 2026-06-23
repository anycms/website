+++
title = "主题"
description = "三个官方主题：ink / manual / folio"
weight = 30
date = "2026-06-01"
template = "section.html"
+++

三个官方主题随仓库发布，分别面向博客、文档与作品集。它们既是开箱即用的设计，也是主题契约的参考实现。

<div class="cards" style="margin-top:2rem;">

  <article class="card">
    <div class="card-head">
      <span class="card-icon">ink</span>
      <div><h3>ink</h3><span class="card-tag">参考默认主题</span></div>
    </div>
    <p>极简博客主题。衬线字体、单栏布局、纸墨质感。包含全套模板、feeds、sitemap、代码高亮与 params 主题化。是学习主题契约的起点。</p>
    <div class="chips"><span class="chip">blog</span><span class="chip">typography</span><span class="chip">dark mode</span></div>
  </article>

  <article class="card">
    <div class="card-head">
      <span class="card-icon">man</span>
      <div><h3>manual</h3><span class="card-tag">文档 / 手册</span></div>
    </div>
    <p>面向文档站点。无衬线字体、顶部搜索栏、页内目录（TOC）、section 导航，并生成 search.json 供客户端搜索。</p>
    <div class="chips"><span class="chip">docs</span><span class="chip">TOC</span><span class="chip">search</span></div>
  </article>

  <article class="card">
    <div class="card-head">
      <span class="card-icon">fol</span>
      <div><h3>folio</h3><span class="card-tag">作品集 / 视觉</span></div>
    </div>
    <p>面向作品集与视觉展示。粗体展示字、响应式画廊网格、项目卡片，支持 <code>columns</code> 参数调整布局。</p>
    <div class="chips"><span class="chip">portfolio</span><span class="chip">gallery</span><span class="chip">landing</span></div>
  </article>

</div>

## 安装主题

```sh
anycms theme install ../themes/ink --root ./my-site
```

然后在 `site.kdl` 中启用，并删除 site 自带的 `templates/` 与 `sass/` 让主题接管（见[快速开始](/docs/getting-started/#使用主题)）：

```kdl
theme "ink"
```

## 主题契约速览

每个主题是一个 bundle：`theme.kdl` manifest（含 `engine-version`、`params` 声明）+ 必需的 `templates/` + 可选 `static/` / `sass/`。详见[主题文档](/docs/themes/)。

> 本官方网站**不使用任何主题**——它自带 `templates/` 与 `sass/`，完全自包含。这也是一种合法的用法：当你想要完全定制的设计时，直接在 site 内写模板即可。
