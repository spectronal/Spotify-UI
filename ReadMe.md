<div align="center">

# 🎵 Spotify UI Library

### A modern Roblox UI library written in Luau, styled after Spotify's look.

<img alt="Version" src="https://img.shields.io/badge/version-1.5.0-1DB954?style=for-the-badge">
<img alt="Luau" src="https://img.shields.io/badge/Luau-Roblox-00A2FF?style=for-the-badge&logo=roblox">
<img alt="Client" src="https://img.shields.io/badge/runs%20on-LocalScript-181818?style=for-the-badge">
<img alt="Dependencies" src="https://img.shields.io/badge/dependencies-none-1DB954?style=for-the-badge">

<br><br>

</div>

---

## ✨ About

Spotify UI Library is a Roblox interface library built around a simple API, a consistent look, and code that's easy to maintain. You get a full window with sidebar, tabs, sections, interactive components, notifications, responsive scaling, a configurable keybind, and a bottom bar inspired by Spotify's "Now Playing".

---

# 📜 Update Logs

Changes for every version, newest on top.

## `v1.5.0` — 07/17/2026

### ✨ Added

- Central scale control group on the Now Playing bar, inspired by Spotify's rewind/play/forward buttons.
- Percentage indicator with a white background at the center of the group, staying readable against the dark theme.
- Green hover state on the scale-down and scale-up buttons.
- Each notification now has its own dedicated shadow.

### 🔧 Changed

- The `-`, percentage and `+` controls moved from the topbar down to the bottom bar.
- The topbar now reserves more room for the tab title and only keeps the close button.
- Game name and creator width is now clamped before the central controls to prevent overlap.
- Notifications still stack in the bottom-right corner, but the layout now only manages transparent slots.

### 🐛 Fixed

- Notification border getting clipped by `ClipsDescendants` and the `CanvasGroup`.
- Square corners showing up when the gradient, accent stripe or duration bar reached the edge of the toast.
- Notification `UIStroke` blending visually with the progress bar.
- Opacity tween keeping stale references after a notification was dismissed early.

## `v1.4.0` — 07/17/2026

### 🔧 Changed

- All `UIStroke` instances across the library now use `Thickness = 2`.
- Notifications are now pinned to the bottom-right corner of the screen.
- New notifications stack upward, keeping the newest one closest to the bottom.
- Notification animations now run on a separate slot so `UIListLayout` and `Position` tweens stop fighting each other.
- Tab hover keeps the button size fixed and only animates background, text and stroke, so it no longer leaks outside the `ScrollingFrame`.
- The notification duration bar is now inset inside the card instead of touching the outer edge.

### 🐛 Fixed

- Tab borders getting clipped by the sidebar's `ScrollingFrame` during hover/selection.
- Tab stroke only showing part of the sides at certain scales.
- Notification borders blending visually with the side accent stripe and the duration bar.
- Notification `UIStroke` getting cut off on rounded corners.
- Notification enter/exit tweens getting overridden by `UIListLayout`.

## `v1.3.0` — 07/17/2026

### ✨ Added

- Session timeline on the bottom bar, inspired by Spotify's progress bar.
- `mm:ss` / `h:mm:ss` counter showing how long the window has been open.
- New config options: `ShowSessionTimer`, `SessionTimerDuration`, `SessionTimerText`.
- New APIs: `GetSessionElapsed`, `ResetSessionTimer`, `SetSessionTimerVisible`.
- Hover tween on the timeline plus a knob that follows progress.

### 🔧 Changed

- The Now Playing bar grows its height automatically when the timeline is visible.
- The outer shadow is smaller and softer now.
- The "current experience" indicator repositions itself so it doesn't collide with the timeline.
- Layout goes back to its compact height when the timer is hidden.

### 🐛 Fixed

- Square outer corners caused by opaque children inside a container that has `UICorner`.
- Uneven outer border caused by a larger Frame filled in behind the window.
- Inconsistent stroke thickness during scale animations.
- Sidebar top-left, topbar top-right and Now Playing bottom corners are now drawn separately.
- Stroke, shadow and window now stay in sync while dragging, resizing or changing scale.
- Timer connection now disconnects automatically on `Window:Destroy()`.

## `v1.2.0` — 07/17/2026

### ✨ Added

- Window open/close animation with fade + scale.
- Fade/slide transition when switching tabs.
- Subtle gradients on background, sidebar, topbar, sections, cards and bottom bar.
- Animated hover/click/press states on components.
- Pulse effect on the current experience indicator.
- New `Animations` and `AnimateOnStart` options in `CreateWindow`.

### 🔧 Changed

- Cards and sections got clearer visual hierarchy, spacing and corner radii.
- Toggle now has a spring animation and shadow on the knob.
- Dropdown expands more smoothly with better focus feedback.
- Inputs and Keybind Picker now animate border/background on focus.
- Notifications enter/exit with fade + slide.
- Scrollbars are thinner and moved inward.

### 🐛 Fixed

- Outer stroke getting clipped by `ClipsDescendants`.
- Wrong inner corners on the sidebar next to the Now Playing bar.
- Dividers touching the window's rounded edges.
- Page scrollbar showing up on top of the right border.
- Dropdown `UIStroke` getting cut off while expanding/collapsing.
- Conflict between the responsive scale tween and the open/close tween.
- Slider staying in a hover state after dragging outside the card.

## `v1.1.0` — 07/17/2026

### ✨ Added

- Automatic, separate `Settings` tab at the bottom of the sidebar.
- New `Keybind Picker` component.
- Default `RightShift` keybind to open/close the UI.
- Bottom "Now Playing" bar showing experience info.
- Icons on sidebar tabs.
- Green indicator on the selected tab.
- Destroy methods for components, sections and tabs.
- New APIs: `SetGameInfo`, `SetNowPlayingVisible`, `SetKeybind`, `GetKeybind`.

### 🔧 Changed

- Close button now defaults to `CloseBehavior = "Hide"`.
- Sidebar spacing and hierarchy now sit closer to Spotify's actual look.
- Responsive layout now correctly reserves space for the bottom bar.
- Sidebar width adapts to smaller viewports.

### 🐛 Fixed

- Stale dropdown option connections when rebuilding the list.
- Elements overflowing past or ending up behind the bottom bar.
- Wrong drag behavior when the window was scaled.
- Shadow misaligned with window position/size/scale.
- Notifications and temp tasks sticking around after destroying the UI.
- Dangling references to already-destroyed components, tabs and sections.
- Keybind firing while capturing a key or typing in a `TextBox`.

<details>
<summary><strong>v1.0.0 — First release</strong></summary>

### ✨ Added

- Main window with Spotify theme.
- Sidebar and tab system.
- Sections.
- Button, Toggle, Slider, Dropdown, Input, Label and Paragraph.
- Notifications.
- Manual and automatic scaling.
- Mouse and touch drag support.
- Internal connection cleanup system.

</details>

---

## 📚 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [API Structure](#-api-structure)
- [Window Setup](#-window-setup)
- [Tabs and Sections](#-tabs-and-sections)
- [Components](#-components)
- [Settings and Keybind](#-settings-and-keybind)
- [Now Playing Bar](#-now-playing-bar)
- [Notifications](#-notifications)
- [Responsiveness and Scaling](#-responsiveness-and-scaling)
- [Theme](#-theme)
- [Cleanup and Destruction](#-cleanup-and-destruction)
- [Full Example](#-full-example)
- [Common Issues](#-common-issues)

---

## 🚀 Features

- Dark Spotify-inspired look.
- Outer corners drawn with selective surfaces, so no square edges leak through `UICorner`.
- Real outline via `UIStroke`, independent from the window's clipping. Every stroke uses `Thickness = 2`.
- Subtle gradients, visual elevation, hover/press states.
- Animations for opening, closing and switching tabs.
- Sidebar with icon, label and active-tab indicator.
- Automatic `Settings` tab, kept separate from the main tabs.
- Configurable keybind to open/close the interface.
- Bottom bar showing the experience's icon, name and creator.
- Session timer with a progress bar styled after Spotify's timeline.
- Draggable window (mouse and touch).
- Manual scaling via the center controls on the bottom bar (`-`, percentage, `+`).
- Automatic scaling based on `ViewportSize`.
- Works across different resolutions and aspect ratios.
- Auto-scrolling tabs and pages.
- Sections with automatic height.
- Components expose methods to update themselves at runtime.
- Stacked, temporary notifications in the bottom-right corner with an internal progress bar.
- Cleans up connections, threads, tweens and instances when the UI is destroyed.
- Zero external dependencies.

### Available components

| Component | Description |
|---|---|
| `Window` | Main interface window. |
| `Tab` | Sidebar navigation item. |
| `Section` | Visual grouping for components. |
| `Button` | Runs an action on click. |
| `Toggle` | Switches on/off. |
| `Slider` | Picks a numeric value. |
| `Dropdown` | Picks an option from a list. |
| `Input` | Text input field. |
| `Label` | Plain text display. |
| `Paragraph` | Title + multi-line content. |
| `Keybind Picker` | Captures and changes a key. |
| `Notification` | Shows a temporary toast. |

---

## ⚡ Quick Start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/spectronal/Spotify-UI/refs/heads/main/SpotifyUILibrary.lua"))()

local Window = Library:CreateWindow({
    Title = "My Menu",
    Subtitle = "Spotify UI Library",
})

local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "⌂",
})

local MainSection = HomeTab:CreateSection("Main controls")

MainSection:CreateButton({
    Text = "Click me",
    Description = "Runs a simple action.",
    Callback = function()
        print("Button pressed")
    end,
})

MainSection:CreateToggle({
    Text = "Music enabled",
    Default = true,
    Callback = function(enabled)
        print("Music:", enabled)
    end,
})

MainSection:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 70,
    Suffix = "%",
    Callback = function(value)
        print("Volume:", value)
    end,
})
```

---

## 🧱 API Structure

The main hierarchy looks like this:

```text
Library
└── Window
    ├── Tab
    │   └── Section
    │       └── Components
    ├── Automatic Settings Tab
    ├── Now Playing
    └── Notifications
```

Example:

```lua
local Window = Library:CreateWindow({ Title = "Menu" })
local Tab = Window:CreateTab("Home")
local Section = Tab:CreateSection("Gameplay")
local Toggle = Section:CreateToggle({ Text = "Auto Farm" })
```

You can also create components directly on a tab — the library will just create an internal untitled section for you:

```lua
local AboutTab = Window:CreateTab("About")

AboutTab:CreateLabel({
    Text = "Built with Spotify UI Library",
})
```

---

## 🪟 Window Setup

```lua
local Window = Library:CreateWindow({
    Name = "MyInterface",
    Title = "My Menu",
    Subtitle = "Spotify UI Library",
    Size = Vector2.new(940, 590),
    Scale = 1,
    MinScale = 0.65,
    MaxScale = 1.5,
    AutoScale = true,
    MaxAutoScale = 1.2,
    ViewportMargin = 20,
    Keybind = Enum.KeyCode.RightShift,
    ShowNowPlaying = true,
    ShowSessionTimer = true,
    SessionTimerDuration = 3600,
    SessionTimerText = "Time open",
    CloseBehavior = "Hide",
    Animations = true,
    AnimateOnStart = true,
    DisplayOrder = 50,
    GameName = "My experience",
    GameCreator = "My studio",
    GameIcon = "rbxassetid://123456789",
})
```

### `CreateWindow` options

| Property | Type | Default | Description |
|---|---:|---:|---|
| `Name` | `string` | Auto | `ScreenGui` name. |
| `Title` | `string` | `Spotify UI` | Title shown on the sidebar. |
| `Subtitle` | `string` | `Roblox UI Library` | Subtitle shown below the title. |
| `Parent` | `Instance` | `PlayerGui` | Custom parent for the `ScreenGui`. |
| `Size` | `Vector2` | `Vector2.new(940, 590)` | Base window size. |
| `Scale` | `number` | `1` | Initial manual scale. |
| `MinScale` | `number` | `0.65` | Lowest allowed scale. |
| `MaxScale` | `number` | `1.5` | Highest allowed scale. |
| `AutoScale` | `boolean` | `true` | Auto-adjusts the window to the viewport. |
| `MaxAutoScale` | `number` | `1.2` | Cap for the automatic scale. |
| `ViewportMargin` | `number` | `20` | Margin kept between the window and the screen edge. |
| `Keybind` | `Enum.KeyCode`, `string`, `false` | `RightShift` | Key used to open/close the UI. Pass `false` to disable it. |
| `ShowNowPlaying` | `boolean` | `true` | Shows the bottom bar for the experience. |
| `ShowSessionTimer` | `boolean` | `true` | Shows the timeline with elapsed time since the window was created. |
| `SessionTimerDuration` | `number` | `3600` | Duration in seconds used as the visual scale until the bar hits 100%. The displayed time keeps counting past that. |
| `SessionTimerText` | `string` | `Time open` | Text shown on the right side of the timeline. |
| `CloseBehavior` | `"Hide"` or `"Destroy"` | `"Hide"` | What the close button does. |
| `Animations` | `boolean` | `true` | Turns visual tweens on/off for the window and tabs. |
| `AnimateOnStart` | `boolean` | `true` | Controls the entry animation when the window is created. |
| `DisplayOrder` | `number` | `50` | Display order of the `ScreenGui`. |
| `GameName` | `string` | Auto | Name shown on the bottom bar. |
| `GameCreator` | `string` | Auto | Creator shown on the bottom bar. |
| `GameIcon` | `string` | Auto | Asset or thumbnail used as icon. |

> [!NOTE]
> The size you pass in gets clamped internally so windows can't end up too small or too big. Width is clamped between `720` and `1280`, height between `460` and `820`.

### Window methods

| Method | Returns | Description |
|---|---|---|
| `Window:CreateTab(config)` | `Tab` | Creates a new tab. |
| `Window:SelectTab(tabOrName)` | `boolean` | Selects a tab by object or name. |
| `Window:GetSettingsTab()` | `Tab` | Returns the automatic Settings tab. |
| `Window:SetKeybind(keyCode)` | `Window` | Changes or removes the window's keybind. |
| `Window:GetKeybind()` | `Enum.KeyCode?` | Returns the current keybind. |
| `Window:SetScale(scale)` | `Window` | Changes the manual scale. |
| `Window:GetScale()` | `number` | Returns the manual scale. |
| `Window:GetEffectiveScale()` | `number` | Returns the final scale actually applied after AutoScale. |
| `Window:SetAutoScale(enabled)` | `Window` | Toggles automatic scaling. |
| `Window:SetSize(width, height)` | `Window` | Changes the base window size. Also accepts a `Vector2`. |
| `Window:GetSize()` | `Vector2` | Returns the current base size. |
| `Window:SetTitle(title, subtitle?)` | `Window` | Updates title and, optionally, subtitle. |
| `Window:SetVisible(visible, instant?)` | `Window` | Shows/hides the UI, animated by default. |
| `Window:ToggleVisible()` | `boolean` | Toggles visibility, returns the new state. |
| `Window:SetGameInfo(config)` | `Window` | Updates name, creator and icon on the bottom bar. |
| `Window:SetNowPlayingVisible(visible)` | `Window` | Shows/hides the bottom bar. |
| `Window:SetSessionTimerVisible(visible)` | `Window` | Shows/hides the timeline and recalculates the bottom bar height. |
| `Window:GetSessionElapsed()` | `number` | Returns how many seconds the window has been open. |
| `Window:ResetSessionTimer()` | `Window` | Resets the timer and its visual progress. |
| `Window:Notify(config)` | `Notification?` | Shows a notification. |
| `Window:Destroy()` | — | Destroys the window and cleans up its resources. |

### Window control examples

```lua
Window:SetScale(1.15)
Window:SetSize(1000, 640)
Window:SetTitle("New title", "New subtitle")
Window:SetAutoScale(true)
Window:SetVisible(false)
Window:SetVisible(true)
```

---

## 🧭 Tabs and Sections

### Creating a tab

The simple way:

```lua
local HomeTab = Window:CreateTab("Home")
```

With a text icon:

```lua
local MusicTab = Window:CreateTab({
    Name = "Music",
    Icon = "♫",
})
```

With an image icon:

```lua
local InventoryTab = Window:CreateTab({
    Name = "Inventory",
    Icon = "rbxassetid://123456789",
    IconColor = Library.Theme.Text,
})
```

### Tab options

| Property | Type | Description |
|---|---:|---|
| `Name` | `string` | Tab name. |
| `Icon` | `string` | Symbol, text, or image asset. |
| `IconColor` | `Color3` | Initial icon color. |

The library auto-picks some icons for common names like `Home`, `About`, `Player`, `Music` and `Settings`.

### Tab methods

```lua
Tab:Select()
Tab:Destroy()
Tab:CreateSection("Section name")
```

Every component creation method can also be called directly on a tab:

```lua
Tab:CreateButton({...})
Tab:CreateToggle({...})
Tab:CreateSlider({...})
Tab:CreateDropdown({...})
Tab:CreateInput({...})
Tab:CreateLabel({...})
Tab:CreateParagraph({...})
Tab:CreateKeybindPicker({...})
```

### Creating a section

```lua
local Section = HomeTab:CreateSection("Main controls")
```

For an untitled section:

```lua
local Section = HomeTab:CreateSection(nil)
```

To destroy it:

```lua
Section:Destroy()
```

---

## 🧩 Components

Every component returns a control object. All of them expose:

```lua
Component:SetVisible(true)
Component:IsDestroyed()
Component:Destroy()
```

### Button

```lua
local Button = Section:CreateButton({
    Text = "Run action",
    Description = "Optional button description.",
    Callback = function()
        print("Executed")
    end,
})
```

Methods:

```lua
Button:SetText("New text")
Button:Fire()
Button:SetVisible(false)
Button:Destroy()
```

---

### Toggle

```lua
local Toggle = Section:CreateToggle({
    Text = "Music enabled",
    Description = "Turns the game music on/off.",
    Default = true,
    Callback = function(enabled)
        print(enabled)
    end,
})
```

Methods:

```lua
Toggle:Set(true)
Toggle:Set(false, false) -- changes value without firing the callback
print(Toggle:Get())
```

---

### Slider

```lua
local Slider = Section:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 70,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print(value)
    end,
})
```

Methods:

```lua
Slider:SetValue(50)
Slider:SetValue(80, false) -- changes value without firing the callback
print(Slider:GetValue())
```

---

### Dropdown

```lua
local Dropdown = Section:CreateDropdown({
    Text = "Quality",
    Options = { "Low", "Medium", "High", "Ultra" },
    Default = "High",
    Placeholder = "Select",
    Callback = function(value)
        print(value)
    end,
})
```

Methods:

```lua
Dropdown:SetValue("Ultra")
Dropdown:SetValue("Medium", false)
print(Dropdown:GetValue())

Dropdown:SetOptions({ "Option A", "Option B", "Option C" })
Dropdown:SetOptions({ "New A", "New B" }, true) -- tries to keep the current value
Dropdown:SetOpen(true)
```

The list grows inside the layout itself and shows up to four options before switching to scrolling.

---

### Input

```lua
local Input = Section:CreateInput({
    Text = "Playlist name",
    Placeholder = "My playlist...",
    Default = "",
    ClearTextOnFocus = false,

    Changed = function(text)
        print("While typing:", text)
    end,

    Callback = function(text, enterPressed)
        print("Final:", text, "Enter:", enterPressed)
    end,
})
```

Methods:

```lua
Input:SetText("New text")
Input:SetText("Fires the callback", true)
print(Input:GetText())
Input:Focus()
```

---

### Label

```lua
local Label = Section:CreateLabel({
    Text = "Version " .. Library.Version,
    Bold = true,
    Color = Library.Theme.AccentHover,
    TextSize = 13,
    Alignment = Enum.TextXAlignment.Left,
})
```

Methods:

```lua
Label:SetText("Updated text")
Label:SetColor(Color3.fromRGB(255, 255, 255))
```

---

### Paragraph

```lua
local Paragraph = Section:CreateParagraph({
    Title = "About",
    Content = "Longer content with automatic line wrapping.",
})
```

Methods:

```lua
Paragraph:SetTitle("New title")
Paragraph:SetContent("New content")
```

> [!NOTE]
> `SetTitle` only updates the title if the component was created with a `Title` property in the first place.

---

### Keybind Picker

```lua
local Keybind = Section:CreateKeybindPicker({
    Text = "Menu shortcut",
    Description = "Click and press a key.",
    Default = Enum.KeyCode.RightShift,
    BindToWindow = true,
    Callback = function(keyCode)
        print("New keybind:", keyCode)
    end,
})
```

Methods:

```lua
Keybind:BeginListening()
Keybind:CancelListening()
Keybind:SetKeybind(Enum.KeyCode.F4)
Keybind:SetKeybind(nil) -- removes the keybind
print(Keybind:GetKeybind())
```

Behavior while capturing:

- Text switches to `[ ... ]`.
- The next keyboard key gets captured.
- `Backspace` or `Delete` clears the bind.
- Only one picker can listen at a time inside the window.
- With `BindToWindow = true`, the value updates the UI's main shortcut.
- With `BindToWindow = false`, the component keeps its own independent value.

---

## ⚙️ Settings and Keybind

The `Settings` tab is created automatically at the bottom of the sidebar.

```lua
local SettingsTab = Window:GetSettingsTab()
```

It already contains a `Keybind Picker` wired to the window. The default key is:

```lua
Enum.KeyCode.RightShift
```

That key opens/closes the whole interface:

```lua
Window:SetKeybind(Enum.KeyCode.F4)
```

To remove the shortcut:

```lua
Window:SetKeybind(nil)
```

You can also disable it right when creating the window:

```lua
local Window = Library:CreateWindow({
    Keybind = false,
})
```

The keybind won't fire when:

- Another Keybind Picker is capturing a key.
- The input was consumed by the game.
- The player is typing in a `TextBox`.

### Adding content to Settings

```lua
local SettingsTab = Window:GetSettingsTab()
local ExtraSection = SettingsTab:CreateSection("Preferences")

ExtraSection:CreateToggle({
    Text = "Show notifications",
    Default = true,
})
```

> [!TIP]
> Manually creating a tab named `Settings` just returns the existing automatic tab instead of duplicating it.

---

## 🎮 Now Playing Bar

The fixed bottom bar shows info about the current experience:

- Game icon.
- Experience name.
- Creator name.
- "Current experience" indicator.
- Central scale controls styled like playback buttons (`-`, percentage, `+`).
- Timeline with elapsed time since the window was created.

By default the library tries to auto-fill this info. You can override it on creation:

```lua
local Window = Library:CreateWindow({
    GameName = "My experience",
    GameCreator = "My studio",
    GameIcon = "rbxassetid://123456789",
})
```

Or at runtime:

```lua
Window:SetGameInfo({
    Name = "New name",
    Creator = "New creator",
    Icon = "rbxassetid://123456789",
})
```

To hide/show the bar:

```lua
Window:SetNowPlayingVisible(false)
Window:SetNowPlayingVisible(true)
```

### Session timer

The timeline runs on `RunService.Heartbeat`, with the connection registered in the window's cleanup system. The label shows the actual elapsed time; the green fill uses `SessionTimerDuration` only as a visual scale.

```lua
local Window = Library:CreateWindow({
    ShowSessionTimer = true,
    SessionTimerDuration = 3600,
    SessionTimerText = "Time open",
})

print(Window:GetSessionElapsed())

Window:ResetSessionTimer()
Window:SetSessionTimerVisible(false)
Window:SetSessionTimerVisible(true)
```

Once `SessionTimerDuration` is reached, the bar stays at 100% but the clock keeps counting normally.

When available width is tight, the right-side indicator gets hidden automatically. The scale controls stay centered, and the game name gets truncated before it reaches that area.

---

## 🔔 Notifications

Notifications show up in the **bottom-right corner** of the screen and stack upward. Each toast uses its own rounded surface, with the `UIStroke` outside any clipping, so borders don't get cut off and corners stay round.

### Through the window

```lua
local Notification = Window:Notify({
    Title = "All set",
    Content = "Your settings were saved.",
    Duration = 4,
    Color = Library.Theme.Accent,
})
```

### Through the library

`Library:Notify` sends the notification to the most recently created, still-active window:

```lua
Library:Notify({
    Title = "Heads up",
    Content = "This is a global notification.",
})
```

### Options

| Property | Type | Default | Description |
|---|---:|---:|---|
| `Title` | `string?` | — | Optional title. |
| `Content` | `string` | `Notification` | Main content. |
| `Duration` | `number` | `4` | Time in seconds. Minimum of `0.5`. |
| `Color` | `Color3` | `Theme.Accent` | Color of the indicator and progress bar. |

To dismiss early:

```lua
Notification:Dismiss()
```

---

## 📐 Responsiveness and Scaling

The library calculates the final scale using:

- Base window size.
- Scale chosen by the user.
- Current camera resolution.
- Configured viewport margin.
- Auto-scale cap.

```lua
Window:SetScale(1.2)
Window:SetAutoScale(true)

print(Window:GetScale())
print(Window:GetEffectiveScale())
```

`GetScale()` returns the scale the user asked for. `GetEffectiveScale()` returns the scale actually applied after fitting the viewport.

### Built-in controls

The bottom bar has a central group inspired by Spotify's playback controls:

- `-` button on the left to shrink the scale.
- Percentage indicator highlighted in the center.
- `+` button on the right to grow the scale.

The topbar only keeps the `×` button to hide or destroy the UI, freeing up more room for the tab title.

### Responsive behavior

- The window stays inside the visible screen area.
- The sidebar gets narrower on smaller viewports.
- The bottom bar recalculates the content area.
- Long text truncates where needed.
- Tabs, pages and dropdowns scroll when needed.
- Dragging works with both mouse and touch.

---

## 🎨 Theme

Access the theme through:

```lua
print(Library.Theme.Accent)
```

### Default palette

| Field | Color |
|---|---|
| `Background` | `#0F0F0F` |
| `BackgroundAlt` | `#121212` |
| `Sidebar` | `#161616` |
| `Panel` | `#191919` |
| `Card` | `#1F1F1F` |
| `CardHover` | `#272727` |
| `CardPressed` | `#222222` |
| `Input` | `#242424` |
| `InputHover` | `#2A2A2A` |
| `Accent` | `#1DB954` |
| `AccentHover` | `#1ED760` |
| `AccentSoft` | `#177A3B` |
| `Text` | `#FFFFFF` |
| `Subtext` | `#B3B3B3` |
| `Muted` | `#7E7E7E` |
| `Stroke` | `#434343` |
| `Outline` | `#484848` |
| `Divider` | `#363636` |
| `Selected` | `#262626` |
| `Danger` | `#E84855` |

Example:

```lua
Section:CreateLabel({
    Text = "Status: online",
    Color = Library.Theme.AccentHover,
    Bold = true,
})
```

> [!WARNING]
> `Library.Theme` exposes the live table, but components already created won't update automatically if you change a color afterward.

---

## 🧹 Cleanup and Destruction

The library has an internal cleanup system for connections, threads, instances and temporary objects.

### Destroying a component

```lua
Toggle:Destroy()
```

### Destroying a section

```lua
Section:Destroy()
```

### Destroying a tab

```lua
Tab:Destroy()
```

### Destroying a window

```lua
Window:Destroy()
```

### Destroying every window

```lua
Library:DestroyAll()
```

After a component is destroyed:

```lua
print(Component:IsDestroyed()) -- true
```

> [!CAUTION]
> Don't keep calling methods on tabs or sections after destroying them.

---

## 💻 Full Example

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild("SpotifyUILibrary"))

local Window = Library:CreateWindow({
    Title = "My Menu",
    Subtitle = "Spotify UI Library",
    Size = Vector2.new(940, 590),
    Scale = 1,
    AutoScale = true,
    Keybind = Enum.KeyCode.RightShift,
    ShowNowPlaying = true,
    ShowSessionTimer = true,
    SessionTimerDuration = 3600,
    SessionTimerText = "Time open",
    CloseBehavior = "Hide",
})

local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "⌂",
})

local Controls = HomeTab:CreateSection("Main controls")

Controls:CreateButton({
    Text = "Show notification",
    Description = "Opens a toast in the bottom-right corner.",
    Callback = function()
        Window:Notify({
            Title = "Spotify UI",
            Content = "The button was pressed successfully.",
            Duration = 3,
        })
    end,
})

local MusicToggle = Controls:CreateToggle({
    Text = "Music enabled",
    Description = "Turns the game music on/off.",
    Default = true,
    Callback = function(enabled)
        print("Music:", enabled)
    end,
})

local VolumeSlider = Controls:CreateSlider({
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

local QualityDropdown = Controls:CreateDropdown({
    Text = "Quality",
    Options = { "Low", "Medium", "High", "Ultra" },
    Default = "High",
    Callback = function(value)
        print("Quality:", value)
    end,
})

local PlaylistInput = Controls:CreateInput({
    Text = "Playlist name",
    Placeholder = "My playlist...",
    Callback = function(text, enterPressed)
        print("Playlist:", text, enterPressed)
    end,
})

local AboutTab = Window:CreateTab({
    Name = "About",
    Icon = "i",
})

AboutTab:CreateParagraph({
    Title = "Spotify UI Library",
    Content = "A visual library for Roblox written in Luau.",
})

AboutTab:CreateLabel({
    Text = "Version " .. Library.Version,
    Bold = true,
    Color = Library.Theme.AccentHover,
})

local SettingsTab = Window:GetSettingsTab()
local SettingsInfo = SettingsTab:CreateSection("Info")

SettingsInfo:CreateLabel({
    Text = "The keybind only persists for the current session.",
    Color = Library.Theme.Subtext,
})
```

---

## 🛠️ Common Issues

### `Players.LocalPlayer` is `nil`

The library is running on the server. Move the init code to a `LocalScript`.

### The interface doesn't show up

Check that:

- The ModuleScript is in `ReplicatedStorage`.
- The name you're using in `WaitForChild` is correct.
- The LocalScript is in `StarterPlayerScripts` or `StarterGui`.
- No earlier error interrupted the script.

### The window closes and doesn't come back

If you're using:

```lua
CloseBehavior = "Destroy"
```

the window gets fully removed. Use the default `"Hide"` if you want to reopen it via the keybind.

### The keybind isn't working

Check whether:

- The keybind was removed with `SetKeybind(nil)`.
- The player is typing in a `TextBox`.
- Another Keybind Picker is currently listening.
- The input was consumed by another UI in the game.

### The window looks smaller than the scale I set

With `AutoScale = true`, the library can shrink the scale to keep the window inside the viewport. Compare:

```lua
print(Window:GetScale())
print(Window:GetEffectiveScale())
```

### Game name or creator didn't load

You can set the info manually:

```lua
Window:SetGameInfo({
    Name = "Game name",
    Creator = "Creator name",
    Icon = "rbxassetid://123456789",
})
```

### A component isn't needed anymore

Destroy it to remove the interface and its connections:

```lua
Component:Destroy()
```

---

## 📄 License

No license has been set for this package yet. Add a `LICENSE` file with the terms you want before publishing this library publicly.

---

<div align="center">

Made in **Luau** for **Roblox**, visually inspired by **Spotify**.

`Spotify UI Library v1.5.0`

</div>