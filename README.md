# qlpreview.yazi

Preview Office documents (`.pptx`, `.docx`, `.xlsx`, `.ppt`, `.doc`, `.xls`, `.odp`, `.odt`, `.ods`) in [Yazi](https://github.com/sxyazi/yazi) using the **native macOS Quick Look engine** (`qlmanage`).

Zero dependencies beyond what ships with macOS. No LibreOffice, no `pdftoppm` — just `qlmanage`.

## Why this over office.yazi?

|                    | qlpreview.yazi                | office.yazi                   |
|--------------------|-------------------------------|-------------------------------|
| Rendering engine   | macOS Quick Look (built-in)   | LibreOffice                   |
| Dependencies       | **None** (macOS only)         | LibreOffice + pdftoppm        |
| Speed              | Fast (native thumbnails)      | Slower (full PDF conversion)  |
| Blocking           | **No** — 15s timeout per file | Yes (sync `libreoffice` call) |
| Page navigation    | First page only               | Full PDF conversion           |

If you need pixel-perfect renders of every slide, keep `office.yazi`. If you want **fast, native thumbnails that don't block your workflow**, use `qlpreview`.

## Installation

```sh
ya pkg add Fun10165/qlpreview
```

> [!IMPORTANT]
> Requires **Yazi ≥ 26.5.6** (uses `ya.preview_widget`, not the deprecated `ya.preview_widgets`).

## Setup

Add to `~/.config/yazi/yazi.toml`:

```toml
[plugin]
prepend_preloaders = [
    { url = "*.pptx", run = "qlpreview" },
    { url = "*.ppt",  run = "qlpreview" },
    { url = "*.odp",  run = "qlpreview" },
    { url = "*.docx", run = "qlpreview" },
    { url = "*.doc",  run = "qlpreview" },
    { url = "*.odt",  run = "qlpreview" },
    { url = "*.xlsx", run = "qlpreview" },
    { url = "*.xls",  run = "qlpreview" },
    { url = "*.ods",  run = "qlpreview" },
]

prepend_previewers = [
    { url = "*.pptx", run = "qlpreview" },
    { url = "*.ppt",  run = "qlpreview" },
    { url = "*.odp",  run = "qlpreview" },
    { url = "*.docx", run = "qlpreview" },
    { url = "*.doc",  run = "qlpreview" },
    { url = "*.odt",  run = "qlpreview" },
    { url = "*.xlsx", run = "qlpreview" },
    { url = "*.xls",  run = "qlpreview" },
    { url = "*.ods",  run = "qlpreview" },
]
```

## How it works

```
hover file  →  yazi calls preload() in background
                 ├─ qlmanage -t -s 4096 → thumbnail PNG
                 ├─ Copy to yazi cache
                 └─ 15s timeout if qlmanage hangs

ready?  →  yazi calls peek() → ya.image_show() → preview shown
```

- **Non-blocking**: `peek()` never calls `preload()`. Browsing stays smooth.
- **Timeout**: If Quick Look can't handle a file (or hangs), it's killed after 15 seconds. No stuck preview pane.
- **Per-file isolation**: Each preload runs in its own temp directory. Parallel hovers never collide.

## License

MIT
