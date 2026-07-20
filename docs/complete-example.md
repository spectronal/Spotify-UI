# Tabs & Sections

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
