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
