# Native Search Controller

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
