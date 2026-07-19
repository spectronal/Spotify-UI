<div align="center">

# Spotify UI Library

A polished Roblox UI library written in Luau, inspired by Spotify's desktop and mobile interfaces.

![Version](https://img.shields.io/badge/version-2.0.1-1DB954?style=for-the-badge)
![Language](https://img.shields.io/badge/Luau-Roblox-00A2FF?style=for-the-badge)
![Theme](https://img.shields.io/badge/theme-Spotify-121212?style=for-the-badge)

</div>

## Update logs

### v2.0.1

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

## Features

- Single ModuleScript with no required Roblox packages.
- Direct lucide-roblox integration through its documented `GetAsset` API, with automatic loading and fallback glyphs.
- Responsive window scaling based on `CurrentCamera.ViewportSize`.
- Sidebar tabs, sections, buttons, toggles, sliders, dropdowns, inputs, labels, paragraphs, and keybind pickers.
- Single-select and multi-select dropdowns.
- Native search controller and metadata registry integrated into the window lifecycle.
- Right-side Settings panel inspired by Spotify's Now Playing panel.
- Draggable mini player in the bottom-right corner.
- Experience information and session timeline.
- Bottom-right toast notifications.
- Centralized cleanup for connections, tweens, tasks, and temporary instances.
- Every `UIStroke` uses `Thickness = 2`.

## Quick Start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/spectronal/Spotify-UI/refs/heads/main/SpotifyUILibrary.lua"))()

local Window = Library:CreateWindow({
    Title = "My Menu",
    Keybind = Enum.KeyCode.RightShift,
})
```

## Lucide icons

Icons are powered by [Lucide](https://lucide.dev/). Grab any icon name straight from the site and pass it to `Icon`:

```lua
local Window = Library:CreateWindow({
    Title = "My Menu",
})

local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "house",
})

local SettingsTab = Window:CreateTab({
    Name = "Preferences",
    Icon = "settings",
})
```

## Complete example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/spectronal/Spotify-UI/refs/heads/main/SpotifyUILibrary.lua"))()

local Window = Library:CreateWindow({
    Title = "My Menu",
    Subtitle = "Spotify UI Library",
    Size = Vector2.new(940, 590),
    Scale = 1,
    AutoScale = true,
    Animations = true,
    Keybind = Enum.KeyCode.RightShift,
    ShowSearch = true,
    SearchPlaceholder = "What do you want to find?",
    ShowNowPlaying = true,
    ShowSessionTimer = true,
    SessionTimerDuration = 3600,
})

local Home = Window:CreateTab({
    Name = "Home",
    Icon = "house",
})

local General = Home:CreateSection("General")

General:CreateButton({
    Text = "Notify me",
    Description = "Displays a toast notification.",
    Callback = function()
        Window:Notify({
            Title = "Done",
            Content = "The action completed successfully.",
        })
    end,
})

General:CreateToggle({
    Text = "Enabled",
    Default = true,
    Callback = function(enabled)
        print(enabled)
    end,
})

General:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 70,
    Suffix = "%",
})

General:CreateDropdown({
    Text = "Effects",
    Options = { "Bloom", "Shadows", "Particles" },
    Multi = true,
    Default = { "Bloom", "Shadows" },
})
```

## Window options

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `Spotify UI` | Window title. |
| `Subtitle` | `string` | `Roblox UI Library` | Sidebar subtitle. |
| `Size` | `Vector2` | `Vector2.new(940, 590)` | Base window size. |
| `Scale` | `number` | `1` | User scale. |
| `MinScale` | `number` | `0.65` | Minimum scale. |
| `MaxScale` | `number` | `1.5` | Maximum scale. |
| `AutoScale` | `boolean` | `true` | Fits the interface to the viewport. |
| `Animations` | `boolean` | `true` | Enables tweens. |
| `Keybind` | `Enum.KeyCode` | `RightShift` | Shows or hides the UI. |
| `ShowSearch` | `boolean` | `true` | Shows the top search bar. |
| `SearchPlaceholder` | `string` | `What do you want to find?` | Search placeholder. |
| `MaxSearchResults` | `number` | `6` | Maximum visible results. |
| `ShowNowPlaying` | `boolean` | `true` | Shows the bottom experience bar. |
| `ShowSessionTimer` | `boolean` | `true` | Shows the session timeline. |
| `SessionTimerDuration` | `number/false` | `3600` | Visual timeline duration. Use `false` for no limit. |
| `Minimized` | `boolean` | `false` | Starts in mini-player mode. |
| `LoadLucide` | `boolean` | `true` | Automatically loads Lucide. |
| `LucideUrl` | `string` | `Library.LucideUrl` | Custom Lucide source URL. |
| `Lucide` | `table` | `nil` | Table returned by the lucide-roblox loadstring. |
| `IconProvider` | `table` | `nil` | Deprecated compatibility alias for `Lucide`. |

## Tabs and sections

```lua
local Tab = Window:CreateTab({
    Name = "Player",
    Icon = "music-2",
})

local Section = Tab:CreateSection("Playback")
```

A string is still accepted:

```lua
local Tab = Window:CreateTab("Home")
```

## Components

### Button

```lua
Section:CreateButton({
    Text = "Run action",
    Description = "Optional secondary text.",
    Callback = function()
    end,
})
```

### Toggle

```lua
local Toggle = Section:CreateToggle({
    Text = "Enabled",
    Default = false,
    Callback = function(value)
    end,
})

Toggle:SetValue(true)
print(Toggle:GetValue())
```

### Slider

```lua
local Slider = Section:CreateSlider({
    Text = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Suffix = "%",
})

Slider:SetValue(75)
```

### Dropdown

```lua
local Dropdown = Section:CreateDropdown({
    Text = "Quality",
    Options = { "Low", "Medium", "High" },
    Default = "High",
})
```

Multi-select:

```lua
local Dropdown = Section:CreateDropdown({
    Text = "Effects",
    Options = { "Bloom", "Shadows", "Particles" },
    Multi = true,
    Default = { "Bloom", "Shadows" },
    Callback = function(selected)
        print(table.concat(selected, ", "))
    end,
})

Dropdown:Select("Particles")
Dropdown:Deselect("Bloom")
Dropdown:Clear()
```

### Input

```lua
Section:CreateInput({
    Text = "Name",
    Placeholder = "Type here...",
    Callback = function(text, enterPressed)
    end,
})
```

### Label and paragraph

```lua
Section:CreateLabel({
    Text = "Version " .. Library.Version,
    Bold = true,
})

Section:CreateParagraph({
    Title = "Information",
    Content = "Longer explanatory content.",
})
```

### Keybind Picker

```lua
Section:CreateKeybindPicker({
    Text = "Open inventory",
    Default = Enum.KeyCode.I,
    Callback = function(keyCode)
    end,
    Pressed = function()
    end,
})
```

## Native search controller

Search is initialized as a first-class controller owned by the window. It owns its query, visibility, focus state, result lifecycle, searchable entry registry, and all related connections. Components register their metadata when they are created, so search does not scrape or manipulate descendant UI text at query time.

```lua
local Search = Window:GetSearchController()

Window:SetSearchQuery("volume")
print(Window:GetSearchQuery())
Window:FocusSearch()
Window:SetSearchVisible(false)

-- The controller is also available directly.
Search:SetQuery("effects")
```

Search results include tabs, sections, component titles, descriptions, current values, dropdown options, input values, and Settings content. Selecting a result opens the correct location and highlights it.

Every component accepts optional custom search keywords:

```lua
Section:CreateToggle({
    Text = "Performance mode",
    SearchKeywords = { "fps", "optimization", "graphics" },
})
```

## Settings panel

```lua
Window:SetSettingsPanelVisible(true)
Window:SetSettingsPanelVisible(false)
Window:ToggleSettingsPanel()

local SettingsTab = Window:GetSettingsTab()
SettingsTab:CreateToggle({
    Text = "Extra option",
})
```

Settings components automatically render inside the right-side panel.

## Mini player

```lua
Window:SetMinimized(true)
Window:SetMinimized(false)
Window:ToggleMinimized()
Window:ResetMiniPlayerPosition()
```

The mini player shares the main window scale, supports mouse and touch dragging, and remains clamped to the viewport.

## Session timeline

```lua
print(Window:GetSessionElapsed())
Window:ResetSessionTimer()
Window:SetSessionTimerVisible(false)
```

## Notifications

```lua
Window:Notify({
    Title = "Saved",
    Content = "Your settings were saved.",
    Duration = 4,
    Color = Library.Theme.Accent,
})
```

Notifications appear in the bottom-right corner and stack upward.

## Cleanup

```lua
Window:Destroy()
Library:DestroyAll()
```

Destroying a component, tab, section, or window disconnects its registered events and cancels owned tweens and tasks.

## License

MIT License