# Loading Screen

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
