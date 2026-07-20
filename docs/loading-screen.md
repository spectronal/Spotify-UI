# Settings Panel

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
