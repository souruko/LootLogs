# Icons

Every icon in this folder is derived from [Phosphor Icons](https://phosphoricons.com)
([phosphor-icons/core](https://github.com/phosphor-icons/core)), which is MIT licensed:

> MIT License
>
> Copyright (c) 2023 Phosphor Icons
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software
> and associated documentation files (the "Software"), to deal in the Software without
> restriction, including without limitation the rights to use, copy, modify, merge, publish,
> distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
> Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or
> substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
> BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
> DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## What is what

| File | Phosphor icon | Weight | Size | Colour | Used by |
| --- | --- | --- | --- | --- | --- |
| `settings.tga` | `gear` | regular | 16×16 | white | title bar settings button |
| `cross.tga` | `x` | regular | 16×16 | white | title bar close button |
| `arrow_down.tga` | `caret-down` | regular | 12×12 | white | expanded group in the sidebar |
| `arrow_right.tga` | `caret-right` | regular | 12×12 | white | collapsed group in the sidebar |
| `collaps.tga` | `caret-up` | regular | 16×16 | white | collapse-all button |
| `search.tga` | `magnifying-glass` | regular | 16×16 | white | sidebar search field |
| `star_on.tga` | `star` | fill | 12×12 | white | pinned tier band |
| `star_off.tga` | `star` | regular | 12×12 | white | unpinned tier band |
| `star_fill.tga` | `star` | fill | 16×16 | white | Pinned tab |
| `star_pin.tga` | `star` | fill | 10×10 | white | pinned marker on a sidebar row |
| `check.tga` | `check` | bold | 10×10 | white | tick in the "done" status chip |
| `carryover.tga` | `arrows-clockwise` | bold | 10×10 | white | carry-over marker on a tier |
| `badge_dot.tga` | `circle` | fill | 20×20 | `#B4141E` | quicklaunch unread counter |

**Regular weight**, the same as Gibberish3's `RESOURCES/` icons — the two plugins share a window
language. It also happens to be the crisp choice: at 16px a Phosphor regular stroke is exactly 1px
and lands on the pixel grid, where bold lands on 1.5px and blurs.

`lootlogs_icon.tga` is **not** from Phosphor and is not built by the script — the quicklaunch
button keeps its original hand-drawn artwork.

**Sizes are not free.** Turbine clips a `.tga` to the control instead of scaling it, unless the
control sets `SetStretchMode`. Every file above is exactly the size of the control that draws it —
16px is `PanelWindow`'s `BTN_ICON` and the sidebar disclosure arrows. `lootlogs_icon.tga` is
the exception: `UI/QuickLaunch.lua` sets a stretch mode so the button can be resized in settings.

**Glyphs are white on transparent.** The UI tints them by drawing with `BlendMode.Overlay` over a
themed ground, so the colour must not be baked in. `lootlogs_icon.tga` is the exception — it is a
floating button with nothing behind it, so it carries its own ground, 1px frame and gold glyph.

## Format

The LOTRO client wants uncompressed 32-bit TGA. All files here are image type 2, 32 bpp,
descriptor `0x28` (8 alpha bits, top-left origin), BGRA, top row first.

## Rebuilding

    python3 docs/icons/build_icons.py

Downloads the SVGs, rasterises them and writes the TGA headers by hand. Needs `rsvg-convert`
(librsvg), Pillow and network access. Change the sizes, weights or icon names in that script
rather than editing the TGAs.
