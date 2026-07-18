-- Spotify UI Library Example

local Library =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/spectronal/Spotify-UI/refs/heads/main/Source.lua"))()

local Window = Library:CreateWindow({
	Title = "Meu Menu",
	Subtitle = "Spotify UI Library",
	Size = Vector2.new(940, 590),
	Scale = 1,
	AutoScale = true,
	Animations = true,
	AnimateOnStart = true,
	Keybind = Enum.KeyCode.RightShift,
	Minimized = false,
	ShowNowPlaying = true,
	ShowSessionTimer = true,
	SessionTimerDuration = 3600, -- Escala visual da barra: 1 hora.
	SessionTimerText = "Tempo aberto",
	-- CloseBehavior = "Destroy", -- O padrão é "Hide", permitindo reabrir pelo keybind.
	-- GameName = "Nome personalizado",
	-- GameCreator = "Criador personalizado",
	-- GameIcon = "rbxassetid://0000000000",
})

local HomeTab = Window:CreateTab({
	Name = "Home",
	Icon = "⌂",
})
local ControlsSection = HomeTab:CreateSection("Controles principais")

ControlsSection:CreateButton({
	Text = "Abrir mini player",
	Description = "Recolhe a janela para o popup compacto.",
	Callback = function()
		Window:SetMinimized(true)
	end,
})

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

ControlsSection:CreateDropdown({
	Text = "Efeitos visuais",
	Options = { "Bloom", "Sombras", "Partículas", "Reflexos" },
	Multi = true,
	Default = { "Bloom", "Sombras" },
	Callback = function(selected)
		print("Efeitos:", table.concat(selected, ", "))
	end,
})

ControlsSection:CreateInput({
	Text = "Nome da playlist",
	Placeholder = "Minha playlist...",
	Callback = function(text, enterPressed)
		print("Texto:", text, "Enter:", enterPressed)
	end,
})

local AboutTab = Window:CreateTab({
	Name = "Sobre",
	Icon = "i",
})
AboutTab:CreateParagraph({
	Title = "Spotify UI Library",
	Content = "A janela se adapta ao ViewportSize. Use os controles de escala na barra inferior, Window:SetScale() ou pressione RightShift para ocultar e reabrir o menu.",
})
AboutTab:CreateLabel({
	Text = "Versão " .. Library.Version,
	Bold = true,
	Color = Library.Theme.AccentHover,
})

-- A tab Settings e o Keybind Picker são criados automaticamente.
-- Ao clicar na tab, o conteúdo abre no painel lateral direito.
local SettingsTab = Window:GetSettingsTab()
SettingsTab:CreateLabel({
	Text = "O atalho só é mantido durante a sessão atual.",
	Color = Library.Theme.Subtext,
})

-- APIs adicionais:
-- Window:SetKeybind(Enum.KeyCode.F4)
-- Window:SetMinimized(true)
-- Window:ToggleMinimized()
-- Window:ResetMiniPlayerPosition()
-- Window:SetSettingsPanelVisible(true)
-- Window:SetGameInfo({ Name = "Novo nome", Creator = "Novo criador" })
-- Window:SetNowPlayingVisible(false)
-- Window:SetSessionTimerVisible(false)
-- Window:ResetSessionTimer()
-- print(Window:GetSessionElapsed())
-- Window:SetScale(1.15)
-- Window:SetSize(1000, 640)
