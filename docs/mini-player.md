# Components

## Button

```lua
Section:CreateButton({
    Text = "Run action",
    Description = "Optional secondary text.",
    Callback = function()
    end,
})
```

## Toggle

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

## Slider

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

## Dropdown

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

## Input

```lua
Section:CreateInput({
    Text = "Name",
    Placeholder = "Type here...",
    Callback = function(text, enterPressed)
    end,
})
```

## Label and paragraph

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

## Keybind Picker

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
