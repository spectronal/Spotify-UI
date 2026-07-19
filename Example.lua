-- Spotify UI Library Example

local Library =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/spectronal/Spotify-UI/refs/heads/main/Source.lua"))()

local Window = Library:CreateWindow({
	Title = "My Menu",
	Subtitle = "Spotify UI Library",
	Size = Vector2.new(940, 590),
	Scale = 1,
	AutoScale = true,
	Animations = true,
	AnimateOnStart = true,
	Keybind = Enum.KeyCode.RightShift,
	Minimized = false,

	-- lucide-roblox is loaded automatically from Library.LucideUrl.
	-- Set LoadLucide = false to use built-in fallback glyphs.
	LoadLucide = true,

	ShowSearch = true,
	SearchPlaceholder = "What do you want to find?",
	MaxSearchResults = 6,
	ShowNowPlaying = true,
	ShowSessionTimer = true,
	SessionTimerDuration = 3600,
	SessionTimerText = "Time open",
	-- CloseBehavior = "Destroy", -- Default: "Hide".
	-- GameName = "Custom experience name",
	-- GameCreator = "Custom creator",
	-- GameIcon = "rbxassetid://0000000000",
})

local HomeTab = Window:CreateTab({
	Name = "Home",
	Icon = "house",
})

local ControlsSection = HomeTab:CreateSection("Main controls")

ControlsSection:CreateButton({
	Text = "Open mini player",
	Description = "Collapses the window into the compact player.",
	Callback = function()
		Window:SetMinimized(true)
	end,
})

ControlsSection:CreateButton({
	Text = "Click here",
	Description = "Runs a simple callback.",
	Callback = function()
		Window:Notify({
			Title = "All set",
			Content = "The button was pressed.",
			Duration = 3,
		})
	end,
})

ControlsSection:CreateToggle({
	Text = "Music enabled",
	Description = "Enables or disables the game's music.",
	Default = true,
	Callback = function(enabled)
		print("Music:", enabled)
	end,
})

ControlsSection:CreateSlider({
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

ControlsSection:CreateDropdown({
	Text = "Quality",
	Options = { "Low", "Medium", "High", "Ultra" },
	Default = "High",
	Callback = function(value)
		print("Quality:", value)
	end,
})

ControlsSection:CreateDropdown({
	Text = "Visual effects",
	Options = { "Bloom", "Shadows", "Particles", "Reflections" },
	Multi = true,
	Default = { "Bloom", "Shadows" },
	Callback = function(selected)
		print("Effects:", table.concat(selected, ", "))
	end,
})

ControlsSection:CreateInput({
	Text = "Playlist name",
	Placeholder = "My playlist...",
	Callback = function(text, enterPressed)
		print("Text:", text, "Enter:", enterPressed)
	end,
})

local AboutTab = Window:CreateTab({
	Name = "About",
	Icon = "info",
})

AboutTab:CreateParagraph({
	Title = "Spotify UI Library",
	Content = "The window adapts to ViewportSize. Use the bottom scale controls, Window:SetScale(), or RightShift to hide and reopen the menu.",
})

AboutTab:CreateLabel({
	Text = "Version " .. Library.Version,
	Bold = true,
	Color = Library.Theme.AccentHover,
})

-- Settings and its keybind picker are created automatically.
local SettingsTab = Window:GetSettingsTab()
SettingsTab:CreateLabel({
	Text = "The shortcut is kept only for the current session.",
	Color = Library.Theme.Subtext,
})

-- Additional APIs:
-- Window:FocusSearch()
-- Window:SetSearchQuery("volume")
-- Window:SetSearchVisible(false)
-- Window:SetKeybind(Enum.KeyCode.F4)
-- Window:SetMinimized(true)
-- Window:ToggleMinimized()
-- Window:ResetMiniPlayerPosition()
-- Window:SetSettingsPanelVisible(true)
-- Window:SetGameInfo({ Name = "New name", Creator = "New creator" })
-- Window:SetNowPlayingVisible(false)
-- Window:SetSessionTimerVisible(false)
-- Window:ResetSessionTimer()
-- print(Window:GetSessionElapsed())
-- Window:SetScale(1.15)
-- Window:SetSize(1000, 640)
