# Notifications

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
