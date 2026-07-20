<div align="center">

# Spotify UI Library

A polished Roblox UI library written in Luau, inspired by Spotify's desktop and mobile interfaces.

![Version](https://img.shields.io/badge/version-2.1.1-1DB954?style=for-the-badge)
![Language](https://img.shields.io/badge/Luau-Roblox-00A2FF?style=for-the-badge)
![Theme](https://img.shields.io/badge/theme-Spotify-121212?style=for-the-badge)

**[Read the full documentation →](https://spectronal.github.io/Spotify-UI/)**

</div>

## Update logs

### v2.1.1

#### Changed

- The loading screen no longer adds a full-screen black background by default.
- Loading now uses a transparent full-screen input layer and fades only the centered loading card.
- The example script now follows the project `Source.lua` loader and the current showcase structure.

#### Added

- `LoadingBackdropTransparency` to optionally restore a dimmed loading backdrop. The default is `1` (fully transparent).
- `LoadingBackdropColor` for customizing the optional loading backdrop color.
- `LoadingBlockInput` for controlling whether the transparent loading layer captures input while loading.

#### Fixed

- The loading fade no longer changes the transparency of the entire screen-sized container.
- The loading card now owns its own `CanvasGroup`, preventing the game view from fading with the UI card.

<details>
<summary><strong>v2.1.0</strong></summary>

#### Added

- Spotify-inspired loading screen with animated progress, rotating Lucide icon, status stages, custom title, and `By @spectronal` subtitle.
- First-class `LoadingController` with progress, status, running-state, and finish APIs.
- Notification types: `Success`, `Info`, `Warning`, and `Error`.
- Optional notification action button, persistent notifications, dismiss reasons, and mutable title/content APIs.

#### Changed

- Notifications were fully redesigned with a status icon badge, type label, richer depth, inset outline, hover feedback, and a smoother slide/pop transition.
- Notification timers now pause while hovered, making longer messages and actions easier to use.
- Toast width adapts to narrow viewports while preserving the bottom-right stack.
- The main window is revealed only after the loading screen completes, preventing partially rendered interface states.

#### Fixed

- Loading blocks the global keybind until the interface is ready.
- Loading-owned tweens, render connections, and temporary instances are cleaned with the window lifecycle.
- Notification timeout connections are disconnected as soon as a toast is dismissed.

</details>

<details>
<summary><strong>v2.0.1</strong></summary>

#### Fixed

- Replaced the generic icon-provider guessing logic with the documented lucide-roblox API.
- Named icons now resolve through `Lucide.GetAsset(iconName, iconSize)`.
- `Url`, `ImageRectSize`, and `ImageRectOffset` are applied exactly as returned by lucide-roblox.
- Added per-icon and per-size asset caching.
- Invalid icon identifiers safely use fallback glyphs.

#### Added

- `Library:SetLucideLibrary` and `Library:GetLucideLibrary`.
- `Library:GetLucideAsset` for direct access to the normalized Lucide asset metadata.
- `Library.LucideDocumentation`.
- `Lucide` as the preferred `CreateWindow` injection option.

#### Compatibility

- `SetIconProvider`, `GetIconProvider`, and the `IconProvider` window option remain available as aliases.

</details>

<details>
<summary><strong>v2.0.0</strong></summary>

#### Added

- Native Lucide provider adapter using the requested `Lucide.luau` source.
- Lucide icons for tabs, search, dropdowns, buttons, window controls, Settings, notifications, and the mini player.
- `Library:SetIconProvider`, `Library:GetIconProvider`, and `Library:ReloadLucide`.
- First-class `SearchController` with owned state, searchable-entry registry, and cleanup.
- `MiniDarkOverlay` now has a 16 px `UICorner`.

#### Changed

- Entire ModuleScript and example script are now written in English.
- Unknown tab icons now use Lucide's `circle` icon instead of generated text initials.
- Search focus, clear, visibility, query, result rendering, resizing, and component metadata registration are routed through the search controller.
- Search no longer scans UI descendants during queries; components register searchable metadata natively at creation time.
- Bottom scale controls are explicitly made visible after being reparented.

#### Compatibility

- Existing public component APIs remain compatible.
- Direct Roblox image URLs and asset IDs remain supported as tab icons.
- Fallback glyphs keep the UI usable when the remote Lucide provider cannot load.

</details>

<details>
<summary><strong>v1.9.0</strong></summary>

- Added the Spotify-style global search bar.
- Redesigned the Settings panel.

</details>

<details>
<summary><strong>v1.8.0</strong></summary>

- Fixed synchronized minimize transitions.
- Reduced and refined the mini player.

</details>

<details>
<summary><strong>v1.7.0</strong></summary>

- Added draggable mini player positioning.
- Added multi-select dropdowns.

</details>

## License

MIT License
