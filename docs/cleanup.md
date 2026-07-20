# Window Options

Options passed to `Library:CreateWindow({...})`.

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
