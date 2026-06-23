+++
title = "插件"
description = "官方插件与示例插件目录"
weight = 20
date = "2026-06-01"
template = "section.html"
+++

AnyCMS SSG 的能力边界由插件定义。下面是随仓库发布的**官方插件**（Tier 1），每个都演示了一类 Layer-2 业务域的增强。

<div class="cards" style="margin-top:2rem;">

  <article class="card">
    <div class="card-head">
      <span class="card-icon">SS</span>
      <div><h3>seo-suite</h3><span class="card-tag">on_seo</span></div>
    </div>
    <p>配置驱动的 SEO 增强：OpenGraph 图片 / site_name、Twitter card、canonical URL、description 回退，以及去重的 JSON-LD（WebSite、Organization、BreadcrumbList、Article）。</p>
    <div class="chips"><span class="chip">OG</span><span class="chip">Twitter</span><span class="chip">JSON-LD</span></div>
  </article>

  <article class="card">
    <div class="card-head">
      <span class="card-icon">SR</span>
      <div><h3>sitemap-robots</h3><span class="card-tag">on_sitemap</span></div>
    </div>
    <p>按 URL 深度设置 changefreq / priority 默认值，可选过滤 draft / noindex，丰富 lastmod，并生成配套的 robots.txt。</p>
    <div class="chips"><span class="chip">sitemap.xml</span><span class="chip">robots.txt</span></div>
  </article>

  <article class="card">
    <div class="card-head">
      <span class="card-icon">SI</span>
      <div><h3>search-index</h3><span class="card-tag">on_search_document</span></div>
    </div>
    <p>清洗正文 HTML、推导智能摘要与语言、设置 boost、附加分类法 / 日期 / 类型 / 阅读时长字段，并应用排除规则。host 内置的 search provider 聚合出 search.json。</p>
    <div class="chips"><span class="chip">search.json</span><span class="chip">excerpt</span></div>
  </article>

  <article class="card">
    <div class="card-head">
      <span class="card-icon">FS</span>
      <div><h3>feed-suite</h3><span class="card-tag">on_feed_entry</span></div>
    </div>
    <p>订阅源条目增强器：为每个 feed entry 补全 summary、content、author、categories、url。host 内置的 feed provider 负责真正的 RSS / Atom / JSON Feed 渲染。</p>
    <div class="chips"><span class="chip">RSS</span><span class="chip">Atom</span><span class="chip">JSON Feed</span></div>
  </article>

  <article class="card">
    <div class="card-head">
      <span class="card-icon">RI</span>
      <div><h3>responsive-images</h3><span class="card-tag">on_markdown_html</span></div>
    </div>
    <p>按命名约定为 <code>&lt;img&gt;</code> 补充 loading / decoding / srcset / sizes 属性。纯 HTML 标记增强，不做图像重编码。</p>
    <div class="chips"><span class="chip">srcset</span><span class="chip">lazy</span></div>
  </article>

</div>

## 示例插件

仓库的 [`examples/plugins/`](https://github.com/anycms/anycms-ssg/tree/master/examples/plugins) 下还有十多个端到端可运行的最小示例，覆盖**每一个** Layer-1 hook 与 host 函数——它们是学习插件开发的最佳起点：

<div class="chips" style="margin-top:0.5rem;">
  <span class="chip">reading-time</span>
  <span class="chip">site-title</span>
  <span class="chip">uppercasify</span>
  <span class="chip">virtual-page</span>
  <span class="chip">body-inject</span>
  <span class="chip">head-assets</span>
  <span class="chip">shout (contribute)</span>
  <span class="chip">config-demo</span>
  <span class="chip">state-demo</span>
  <span class="chip">now-demo</span>
  <span class="chip">http-post-demo</span>
  <span class="chip">taxonomy-demo</span>
  <span class="chip">multi-filter</span>
  <span class="chip">badge</span>
</div>

## 自己写一个

插件开发只需要一个 crate、一个 manifest，编译到 `wasm32-unknown-unknown`。详见[插件系统文档](/docs/plugins/)。

```sh
anycms plugin new my-plugin --dest ./my-plugin
cd my-plugin
anycms plugin build --install ../my-site --release
```
