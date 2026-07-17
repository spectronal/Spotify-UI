-- Spotify UI Library Example

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SpotifyUI/SpotifyUI/main/SpotifyUILibrary.lua"))() :: any

local Window = Library:CreateWindow({
	Title = "Meu Menu",
	Subtitle = "Spotify UI Library",
	Size = Vector2.new(940, 590),
	Scale = 1,
	AutoScale = true,
})

local HomeTab = Window:CreateTab("Home")
local ControlsSection = HomeTab:CreateSection("Controles principais")

ControlsSection:CreateButton({
	Text = "Clique aqui",
	Description = "Executa um callback simples.",
	Callback = function()
		Window:Notify({
			Title = "Tudo certo",
			Content = "O botão foi pressionado.",
			Duration = 3,
		})
	end,
})

ControlsSection:CreateToggle({
	Text = "Música ativada",
	Description = "Liga ou desliga a música do jogo.",
	Default = true,
	Callback = function(enabled)
		print("Música:", enabled)
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
	Text = "Qualidade",
	Options = { "Baixa", "Média", "Alta", "Ultra" },
	Default = "Alta",
	Callback = function(value)
		print("Qualidade:", value)
	end,
})

ControlsSection:CreateInput({
	Text = "Nome da playlist",
	Placeholder = "Minha playlist...",
	Callback = function(text, enterPressed)
		print("Texto:", text, "Enter:", enterPressed)
	end,
})

local AboutTab = Window:CreateTab("Sobre")
AboutTab:CreateParagraph({
	Title = "Spotify UI Library",
	Content = "A janela se adapta automaticamente ao ViewportSize. Use os botões - e + no topo ou Window:SetScale(1.2) para alterar a escala.",
})
AboutTab:CreateLabel({
	Text = "Versão " .. Library.Version,
	Bold = true,
	Color = Library.Theme.AccentHover,
})

-- Também pode ser alterado por código:
-- Window:SetScale(1.15)
-- Window:SetSize(1000, 640)
