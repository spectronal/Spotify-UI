<div align="center">

# Spotify UI Library

A polished Roblox UI library written in Luau, inspired by Spotify's desktop and mobile interfaces.

![Version](https://img.shields.io/badge/version-2.1.1-1DB954?style=for-the-badge)
![Language](https://img.shields.io/badge/Luau-Roblox-00A2FF?style=for-the-badge)
![Theme](https://img.shields.io/badge/theme-Spotify-121212?style=for-the-badge)

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
- Rich bottom-right toast notifications with types, actions, hover-paused timers, and persistent mode.
- Animated Spotify-style loading screen with a native loading controller.
- Centralized cleanup for connections, tweens, tasks, and temporary instances.
- Every `UIStroke` uses `Thickness = 2`.

## Quick Start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/spectronal/Spotify-UI/refs/heads/main/Source.lua"))()

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
-- Spotify UI Library Example

local Library =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/spectronal/Spotify-UI/refs/heads/main/Source.lua"))()

local Window = Library:CreateWindow({
    Title = "Spotify UI Example",
    Subtitle = "Modern Roblox interface",
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

    ShowLoading = true,
    LoadingTitle = "Spotify UI",
    LoadingSubtitle = "By @spectronal",
    LoadingText = "Preparing your interface",
    LoadingDuration = 5,
    LoadingIcon = "loader-circle",
})

local Home = Window:CreateTab({
    Name = "Home",
    Icon = "house",
})

local General = Home:CreateSection("General")

General:CreateButton({
    Text = "Show success notification",
    Description = "Displays the redesigned notification toast.",
    Callback = function()
        Window:Notify({
            Type = "Success",
            Title = "Everything is ready",
            Content = "The interface finished loading successfully.",
            Duration = 4.5,
        })
    end,
})

General:CreateButton({
    Text = "Show notification action",
    Description = "Displays a warning with an action button.",
    Callback = function()
        Window:Notify({
            Type = "Warning",
            Title = "Pending changes",
            Content = "Apply the new graphics settings now?",
            ActionText = "Apply",
            ActionCallback = function()
                print("Settings applied")
            end,
        })
    end,
})

General:CreateButton({
    Text = "Show error notification",
    Description = "Displays an error with an action button.",
    Callback = function()
        Window:Notify({
            Type = "Error",
            Title = "Something went wrong",
            Content = "An error occurred while applying the settings.",
            Duration = 4.5,
        })
    end,
})

General:CreateToggle({
    Text = "Music enabled",
    Description = "Enables or disables game music.",
    Default = true,
    Callback = function(enabled)
        print("Music enabled:", enabled)
    end,
})

General:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 70,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print("Volume:", value)
    end,
})

General:CreateDropdown({
    Text = "Visual effects",
    Options = { "Bloom", "Shadows", "Particles", "Reflections" },
    Multi = true,
    Default = { "Bloom", "Shadows" },
    Callback = function(selected)
        print(table.concat(selected, ", "))
    end,
})

local About = Window:CreateTab({
    Name = "About",
    Icon = "info",
})

About:CreateParagraph({
    Title = "Spotify UI Library",
    Content = "A responsive Roblox UI library with Lucide icons, native search, loading animation, notifications, Settings panel, and mini player.",
})

About:CreateLabel({
    Text = "Version " .. Library.Version,
    Bold = true,
    Color = Library.Theme.AccentHover,
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
| `ShowLoading` | `boolean` | `true` | Shows the animated loading screen before revealing the window. |
| `LoadingTitle` | `string` | Window title | Main loading-screen title. |
| `LoadingSubtitle` | `string` | `By @spectronal` | Small creator line below the title. |
| `LoadingText` | `string` | `Preparing interface` | Initial loading status. |
| `LoadingDuration` | `number` | `1.8` | Approximate automatic loading animation duration. |
| `LoadingIcon` | `string` | `loader-circle` | Lucide icon used by the loading animation. |
| `LoadingBackdropTransparency` | `number` | `1` | Full-screen loading backdrop transparency. `1` keeps the game fully visible. |
| `LoadingBackdropColor` | `Color3` | `Color3.fromRGB(8, 8, 8)` | Color used only when the loading backdrop is visible. |
| `LoadingBlockInput` | `boolean` | `true` | Captures input while the loading card is active. |
| `LoadingColor` | `Color3` | Theme accent | Loading-screen accent color. |
| `LoadingStages` | `table` | Built-in stages | Custom `{ Progress, Text }` loading stages. |
| `LoadingCallback` | `function` | `nil` | Runs after the loading screen finishes. |
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

## Loading screen

The loading screen is enabled by default and runs without blocking the rest of your LocalScript. Tabs and components can be created normally while the loading animation is visible. The full-screen holder is transparent by default, so the game remains visible behind the centered card.

```lua
local Window = Library:CreateWindow({
    Title = "My Menu",
    ShowLoading = true,
    LoadingTitle = "Spotify UI",
    LoadingSubtitle = "By @spectronal",
    LoadingText = "Preparing interface",
    LoadingDuration = 1.8,
    LoadingIcon = "loader-circle",
    LoadingBackdropTransparency = 1,
    LoadingBlockInput = true,
    LoadingStages = {
        { Progress = 0.25, Text = "Loading assets" },
        { Progress = 0.6, Text = "Building interface" },
        { Progress = 0.9, Text = "Connecting interactions" },
        { Progress = 1, Text = "Ready" },
    },
})
```

The controller can also be accessed directly:

```lua
local Loading = Window:GetLoadingController()

print(Window:IsLoading())
Window:SetLoadingProgress(0.75, "Almost ready")
Window:FinishLoading()

-- Equivalent direct controller calls:
Loading:SetStatus("Finalizing")
Loading:SetProgress(0.9)
Loading:Finish()
```

Set `ShowLoading = false` to reveal the window immediately. Set `LoadingBackdropTransparency` below `1` only when you intentionally want a dimmed game background.

## Notifications

Notifications support four built-in visual types: `Success`, `Info`, `Warning`, and `Error`.

```lua
Window:Notify({
    Type = "Success",
    Title = "Saved",
    Content = "Your settings were saved successfully.",
    Duration = 4.5,
})
```

Add an action when the player should be able to respond directly from the toast:

```lua
Window:Notify({
    Type = "Warning",
    Title = "Changes not applied",
    Content = "Your graphics settings are still pending.",
    ActionText = "Apply",
    ActionCallback = function(notification)
        print("Settings applied")
    end,
})
```

Persistent notifications remain visible until dismissed:

```lua
local Notification = Window:Notify({
    Type = "Info",
    Title = "Background task",
    Content = "Waiting for a server response...",
    Persistent = true,
})

Notification:SetContent("The server responded.")
Notification:Dismiss()
```

Additional options include `Icon`, `Color`, `SoftColor`, `CloseOnAction`, and `OnDismiss`. Timed notifications pause while hovered. All notifications appear in the bottom-right corner and stack upward.

## Cleanup

```lua
Window:Destroy()
Library:DestroyAll()
```

Destroying a component, tab, section, or window disconnects its registered events and cancels owned tweens and tasks.

## License

MIT License