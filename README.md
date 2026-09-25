# adi2_demo

A kitchen-sink program for [Adi2](https://github.com/ovenpasta/adi2), a GUI
toolkit for Ada 2022 on SDL3. One window, ten pages, each covering one area
of the toolkit: every widget in its XML grammar, a widget defined outside
it, CSS with live reload, themes, widget properties, SVG, Lottie, GIF, HTML,
a CPU-drawn texture, dialogs, native file dialogs, settings persistence and
gettext-style translation.

## Build and run

Needs SDL3, SDL3_ttf, SDL3_image, Python 3 and Alire (see `manage.sh`).
Alire fetches GNAT and gprbuild.

```sh
alr build                  # regenerates src/generated/, then compiles
./bin/adi2_demo            # options below
alr test                   # unit and property tests of the pure packages
```

| Option | Effect |
|--------|--------|
| `--lang en\|fr\|de` | Language for this run; otherwise the saved preference |
| `--fps N` | Frame-rate limit for this run; otherwise the saved preference (60, 30 or 20 on the System page) |
| `--page NAME` | Open on a page, e.g. `--page canvas` |
| `--stats` | Print, once a second, frames drawn and average layout, draw and present time |

`alr build` runs `tools/generate.sh` first, as a pre-build action. It turns
`css/`, `ui/`, `i18n/` and `assets/` into Ada under `src/generated/`, and
copies the third-party assets listed in `NOTICE.md` out of the pinned adi2
crate. adi2 is not in the Alire index, so `alire.toml` pins a commit.

Shortcuts: Ctrl+PgUp and Ctrl+PgDn change page, Ctrl+T switches theme, F11
toggles full screen.

## Pages

| Page | Shows | Ada |
|------|-------|-----|
| Overview | Resident memory, frame time, live widget count; six Lottie animations with shared speed control | `demo-pages-overview.adb` |
| Buttons | Button variants, icon buttons from an SVG sprite, toggle buttons, switches, a disabled container whose children inherit `:disabled`, an option group | `demo-pages-buttons.adb` |
| Inputs | Text and password inputs, clipboard, float and integer sliders paired with value inputs, plural forms, combo boxes, the multi-line editor, a custom widget | `demo-pages-inputs.adb` |
| Lists | A list box whose rows are built in Ada from `Demo.Elements` and rebuilt per keystroke; selection modes; rows coloured by a `category` widget property | `demo-pages-lists.adb` |
| Layout | Flex wrap and `justify-content`, grid spans, absolute positioning, overflow scrolling | XML and CSS only |
| Styling | Transition easings, gradients, borders, shadows, outlines, a `severity` property selected by `.alert[severity="critical"]`, a style composed in Ada | `demo-pages-styling.adb` |
| Media | `object-fit` on SVG, raster crop by URL query, tinted sprites, an icon from SVG path data, GIF playback | `demo-pages-media.adb` |
| Document | The HTML view: lists, inline SVG, images and stylesheets through callbacks, link handling, zoom | `demo-pages-document.adb` |
| Canvas | Conway's Game of Life stepped by a pure function and uploaded with `Texture_View.Set_Pixels` | `demo-pages-canvas.adb`, `demo-life.adb` |
| System | Alert, confirm and custom-content dialogs, a dialog declared in XML, a context menu, native file dialogs, OS folders, persisted preferences, UI and text scale, frame-rate limit, momentum scrolling, debug overlays | `demo-pages-system.adb` |

## How it fits together

- **Layouts.** `ui/shell.xml` declares the window; each page is a separate
  file included with `<component>`. `xml_to_ada.py` compiles each file to a
  package with a generic `Instance`. `src/demo-ui.ads` instantiates the
  shell at library level, so the page packages can name its widgets and
  assign its callbacks with `'Access`.
- **Page packages.** Each `Demo.Pages.*` package has `Wire`, which sets
  callbacks before `Demo.UI.Build`, and `Start`, which runs after it.
  `src/adi2_demo.adb` calls them in that order.
- **Custom widget.** `Demo.Meter` derives from `Box_Widget`, registers
  through `Adi.Widget.Extension`, and draws three CSS parts.
  `ui/widgets_extra.xml` adds it to the XML grammar as `<meter>`.
- **Styles and themes.** `css/app.css` names colours only through `var()`;
  `css/palette_dark.css` and `css/palette_light.css` define them. A theme
  is a palette installed ahead of `app.css`. `Demo.Theme` installs it into
  every generated package's style source and into its own source, which
  styles widgets built in Ada. The sheets are read from `css/` when it sits
  beside `bin/`, so saving an edit restyles the running window. Otherwise
  the copies in the asset bundle are used.
- **Popups.** Combo dropdowns and context menus copy their style when they
  are built, so no live sheet reaches them. `css/overlays.css` is compiled
  once per palette, and `Demo.Theme` hands each tracked popup the matching
  set on every theme change.
- **Assets.** Images, SVG, HTML, CSS and the regular font are compiled into
  the binary (`Demo_Bundle`, `Bundle_Mode`). Lottie files and the bold and
  italic font faces stay in `share/adi2_demo/`, because adi2 opens those by
  path only.
- **Frame rate.** adi2's loop wakes at a fixed rate whether or not
  anything changed. `Demo.Pacing` owns the application object and runs it
  at the limit while the window draws, then drops to 10 fps after a second
  without drawing (`Demo.Frame_Policy`). The program's own periodic
  readouts are marked so they do not count as activity.
- **Animation widgets.** `Demo.Lottie_View` and `Demo.Gif_View` derive
  from adi2's Lottie and animated-image widgets and override `On_Tick` so
  that a new frame marks the widget for redrawing only. See "Things found
  while building this".
- **Pure core.** `Demo.Life`, `Demo.Elements`, `Demo.Text`,
  `Demo.Colours`, `Demo.Proc_Stats` and `Demo.Frame_Policy` have no GUI
  dependency.
  `src/demo_tests.adb` tests them, including property tests: Life commutes
  with translation on the torus, and every element matches its own name,
  symbol and number.

## Inspecting it while it runs

adi2 has a development-only bridge for screenshots, the widget tree,
resolved CSS and simulated input. Dependencies build in their release
profile, which links a stub, so build adi2 in development first:

```sh
alr build --profiles=adi2=development
./bin/adi2_demo &
python3 alire/cache/pins/adi2_*/tools/adi_mcp_server.py --cli screenshot
python3 alire/cache/pins/adi2_*/tools/adi_mcp_server.py --cli perf_stats
```

`SDL_VIDEO_DRIVER=offscreen SDL_RENDER_DRIVER=software` runs it without a
visible window. Screenshots came back blank with the offscreen driver's
default renderer; the software renderer gives complete ones.

## Measurements

Taken on Linux (Arch) with SDL's offscreen driver and software renderer,
adi2 at commit `5caa4e8`. A GPU renderer changes the drawing figures.

| | |
|---|---|
| Stripped binary | 16.2 MiB, of which 638 KiB are bundled assets |
| Resident memory, all pages built | ~135–150 MiB RSS, of which ~66 MiB is private; the rest is shared libraries (SDL loads Mesa's `libgallium` and `libLLVM` even for the software renderer) |
| Texture cache | ~10 MiB, mostly rasterised text |
| Widgets | 698 in the tree with all ten pages built |
| CPU on a static page | 4.2% at a fixed 60 fps; 2.3% with the idle drop to 10 fps |
| Layout per Lottie frame | 10.3 ms with adi2's widget; 0.24 ms with `Demo.Lottie_View` |
| CPU with Lottie playing | 100% at 60 fps, 74% at 20 fps: SDL's software renderer spends ~22 ms presenting each frame, which a GPU renderer does not |

## Things found while building this

- **Animation frames relay out the window.** `Adi.Widget.RLottie`,
  `Adi.Widget.Animated_Image` and `Adi.Widget.Texture_View.Set_Pixels`
  call `Mark_Dirty` for each new frame. That marks layout dirty and bumps
  the content version of every ancestor, so the next frame re-measures the
  text of the whole visible page: 97% of the frame's layout work for
  something that never changes size. `Mark_Render_Dirty` is enough, since
  the widget's draw items are rebuilt without a layout. The demo's
  `Lottie_View` and `Gif_View` do that. `Set_Pixels` cannot be overridden,
  so the Canvas page still lays out once per generation. The demo also
  pauses animations while their page is hidden.
- **No idle wait.** The loop sleeps to the next frame rather than waiting
  for an event, so an idle window costs its frame rate in wake-ups.
- **Release builds do not log.** `Adi.Log` writes nothing, errors
  included, unless adi2 is built in its development profile. `--stats`
  writes to standard output for that reason.
- **Scrollbars overlay content.** A scroll container draws its bar inside
  its content box without reserving a gutter, so `app.css` styles it as a
  translucent overlay.
- **SIGTERM is a close request.** SDL turns SIGTERM into a quit event, which
  goes through `Connect_Close_Request`. With "Ask before quitting" on, the
  program answers SIGTERM with the quit dialog and keeps running.
- **Selectors are flat.** There are no descendant or child combinators:
  each widget that looks different carries its own class.
- **Generated code warns.** `css_to_ada.py` and `xml_to_ada.py` output
  compiles with unused-`with` warnings under Alire's default `-gnatwa`.
