+++
title = "图像处理管线"
description = "EXIF 方向矫正、输出格式与 AVIF 编码"
weight = 18
date = "2026-06-21"
author = "liangdi"
template = "docs.html"
tags = ["images", "assets", "avif", "exif", "responsive"]
+++

`site.kdl` 的 `image {}` 块控制图像处理管线（默认 `enabled #false`，需显式开启）：

```kdl
image {
    enabled #true                 // 默认 false
    widths "640,1024,1920"        // 默认 [640, 1024, 1920]
    quality 80                    // 默认 80（JPEG/WebP/AVIF）
    auto_orient #true             // 默认 true — 读 EXIF Orientation 在缩放前旋转
    format "auto"                 // 默认 auto；可选 jpeg/png/webp/avif（大小写不敏感）
}
```

## EXIF 方向自动矫正

手机拍摄的图片常带 EXIF `Orientation` 标签（1–8），像素数据本身是侧躺 / 倒置的，靠这个标签告诉显示器怎么转正。如果不处理，缩略图会显示歪。

`auto_orient`（默认 `true`）在**尺寸计算与变体生成之前**读取该标签，把源图旋转成正立朝向，确保所有变体都是正确的。EXIF 读取失败时回退到不旋转（orientation 1）并打印警告，**不中断构建**。

## 输出格式

`format`（默认 `auto`，大小写不敏感）：

| 值 | 行为 |
|---|---|
| `auto` | 保留源格式 |
| `jpeg` / `png` / `webp` | 统一转码为该格式 |
| `avif` | 转码为 AVIF（需特性，见下） |

## AVIF 编码

选择 `avif` 需启用 cargo 特性（默认关闭，保持默认构建精简）：

```sh
cargo build --features avif
```

- 编码器是纯 Rust 的 `ravif`（经 `image` crate 的 `avif` 特性引入），**无需 C 工具链**，可在任意平台编译。
- 启用后 release 二进制体积约增加 ~1.05 MB。
- **仅支持编码，不支持解码**——AVIF 解码需要 C 工具链的 dav1d，破坏 clean build，故有意排除。这意味着源图不能是 AVIF，但可以把 JPEG/PNG/WebP 源图转码输出为 AVIF。

## 与 responsive-images 插件协作

图像管线负责**生成多分辨率变体文件**（按 `widths` 配置），而官方插件 [responsive-images](./official-plugins/#responsive-images) 负责**改写 HTML**——把变体写进 `<img>` 的 `srcset` / `sizes`，加上 `loading="lazy"` / `decoding`。两者分工：

- 管线：产出文件
- 插件：把文件引用写进标记

插件本身不重新编码图像，只做标记增强。

## 内容哈希缓存

变体生成基于**内容哈希**做缓存——源文件未变时跳过重复编码，大幅加速增量重建（dev serve 下尤其明显）。改图后才重新生成对应变体。

## 关闭管线

不声明 `image {}` 块，或显式 `enabled #false`，则图像原样处理（仅由 responsive-images 插件改写标记，不产出变体）。
