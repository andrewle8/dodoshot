# Lucida

A free, open-source macOS menu bar app that captures your screen and turns it into text for AI terminals.

## Why

CleanShot X costs $30. ShareX is Windows-only. Neither of them can take a screenshot, OCR it, and paste the text straight into your terminal. Lucida does that. It started as a fork of DodoShot's screenshot tool and got rebuilt around one idea: get what's on your screen into an AI conversation as fast as possible.

## Install

### Build from source

```bash
git clone https://github.com/andrewle8/lucida.git
cd lucida/DodoShot
open DodoShot.xcodeproj
```

Build and run with Cmd+R. Requires Xcode 15+ and macOS 14.0 (Sonoma) or later.

On first launch, Lucida will ask for Screen Recording and Accessibility permissions. Both are required -- Screen Recording for captures, Accessibility for global hotkeys.

## Hotkeys

All shortcuts are customizable in Settings.

| Shortcut | Action |
|----------|--------|
| Cmd+Shift+4 | Area capture |
| Cmd+Shift+5 | Window capture |
| Cmd+Shift+3 | Fullscreen capture |
| Cmd+Shift+7 | OCR capture -- extract text and paste into terminal |
| Cmd+Shift+E | Error capture -- clean up error text and paste |
| Cmd+Shift+F | Capture area, save to /tmp, paste file path |
| Cmd+Shift+\` | Code capture -- wrap in markdown code block and paste |
| Cmd+Shift+6 | Capture and paste image into terminal |
| Cmd+Shift+2 | Scrolling capture (select area, auto-scroll and stitch) |
| Cmd+Shift+L | Re-capture last area |
| Cmd+Shift+W | Active window capture |
| Cmd+Shift+C | Color picker |
| Cmd+Shift+R | Pixel ruler |
| Cmd+Shift+T | Timed capture |

## Features

### OCR and AI integration

- Smart OCR that auto-detects code, tables, lists, and errors, then formats as markdown
- Auto-paste OCR text directly into the active terminal (Claude Code, iTerm2, any terminal)
- On-device text recognition via Apple Vision framework -- no API key, no network
- Optional cloud AI descriptions via Anthropic or OpenAI API
- Apple Foundation Models support for local AI on macOS 26 (no API key needed)

### Screen capture

- Area, window, fullscreen, and scrolling capture modes
- Quick overlay after capture with copy/save/annotate/pin actions
- Floating always-on-top windows with adjustable opacity and click-through
- Capture history with grid and list views
- Desktop icon hiding during capture

### Annotation editor

- Arrows, rectangles, ellipses, lines, text, callouts, freehand drawing
- Blur and pixelate for redacting sensitive content
- Step counters (1,2,3 / A,B,C / I,II,III) for tutorials
- Layer management and color picker
- Save as `.lucida` project files (JSON with embedded PNG + annotations)

### Measurement tools

- Pixel ruler for measuring on-screen elements
- Color picker with hex code copy

### Privacy

- No telemetry, no analytics
- No network requests unless you configure an API key for cloud AI
- Everything stays on your machine

## Tech

- Swift / SwiftUI + AppKit
- Apple Vision framework for OCR (on-device)
- Apple Foundation Models for local AI (macOS 26+)
- `CGWindowListCreateImage` for screen capture
- `CGEvent` tap for global hotkeys
- Targets macOS 14.0+ (Sonoma)

## License

MIT. See [LICENSE](LICENSE) for details.
