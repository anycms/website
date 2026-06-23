+++
title = "资源管线"
description = "Sass 编译、TypeScript 转译、HTML 压缩与静态资源拷贝"
weight = 7
date = "2026-06-01"
author = "liangdi"
template = "docs.html"
tags = ["assets", "sass", "typescript", "images", "avif", "exif"]
+++

构建时，AnyCMS SSG 自动处理以下资源：

| 输入 | 处理 | 输出 |
|---|---|---|
| `sass/main.scss` | grass 编译 + 压缩 | `public/main.css` |
| `ts/main.ts` / `*.tsx` | oxc 转译 + minify（不做类型检查 / bundle） | `public/*.js` |
| 文章内 `<img>` | 响应式增强（官方插件 [responsive-images](#响应式图像)：srcset/sizes/lazy/decoding，仅改写 HTML） | 增强后的 `public/**/*.html` |
| 图像资源 | 图像处理管线（EXIF 方向 + 输出格式，见下文） | 转码 / 矫正后的图像 |
| HTML 输出 | minify-html 压缩 | 压缩后的 `public/**/*.html` |
| `static/**` | 原样拷贝 | `public/**` |

## Sass

`sass/main.scss` 是入口。主题的 `sass/` 会被加入 Sass include path，因此可以直接 `@use` 主题的 partial。Sass 输出经过压缩。

```scss
@use "tokens";

body {
  background: var(--bg);
  color: var(--fg);
}
```

主题的 `static/` 与 site 的 `static/` 做 overlay 合并（site 胜出）。

## TypeScript / TSX

`ts/` 下的 `.ts` / `.tsx` 由 **oxc** 转译为 JS 并 minify。特点：

- 纯 Rust 实现，无外部依赖、无 Node.js
- **仅转译，不做 bundle，也不做类型检查**
- 适合写少量交互脚本，而非完整前端应用

## HTML 压缩

所有渲染出的 HTML 都会经过 minify-html 压缩（去注释、折叠空白、缩短布尔属性等）。

## 图像处理管线

`site.kdl` 中的 `image {}` 块控制图像处理管线（默认 `enabled #false`，需显式开启）。它处理两件事：EXIF 方向自动矫正、输出格式转换。

```kdl
image {
    enabled #true                 // 默认 false
    widths "640,1024,1920"        // 默认 [640, 1024, 1920]
    quality 80                    // 默认 80（JPEG/WebP/AVIF）
    auto_orient #true             // 默认 true — 读 EXIF Orientation(1–8) 在缩放前旋转
    format "auto"                 // 默认 auto；可选 jpeg/png/webp/avif（大小写不敏感）
}
```

- **EXIF 自动方向矫正**（`auto_orient`，默认 `true`）：读 EXIF `Orientation` 标签（1–8），在尺寸计算与变体生成前旋转成正立朝向，避免手机照片侧躺 / 倒置。EXIF 读取失败时回退到不旋转（orientation 1）并打印警告，不中断构建。
- **输出格式**（`format`，默认 `auto`）：`auto` 保留源格式；也可统一转码为 `jpeg` / `png` / `webp` / `avif`。
- **AVIF 输出**：选择 `avif` 需启用 cargo 特性 `cargo build --features avif`（默认关闭，保持默认构建精简）。编码器为纯 Rust 的 `ravif`（经 `image` crate 的 `avif` 特性引入），无需 C 工具链，可在任意平台编译。**注意：仅支持 AVIF 编码，不支持 AVIF 解码**（解码需 C 工具链的 dav1d，故有意排除）。启用后 release 二进制体积约增加 ~1.05 MB。

## 响应式图像

官方插件 **responsive-images**（见[插件](/docs/plugins/)）按命名约定为文章内的 `<img>` 添加 `srcset` / `sizes` / `loading="lazy"` / `decoding="async"`。它只改写 HTML 标记、不重新编码图像，与上面的图像处理管线互补。

## 设计参数

主题通过 `params` 声明可调设计令牌，site 在 `params {}` 中覆盖，模板内联注入的 `:root` CSS 变量会覆盖主题默认值。本站就是用这种方式让 `--accent` / `--accent-2` 可在 `site.kdl` 里调整：

```kdl
params {
    accent "#4f46e5"
    accent_secondary "#7c3aed"
}
```
