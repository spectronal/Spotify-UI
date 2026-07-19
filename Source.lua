-- Spotify Library UI v1.9.0

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Library = {
	Version = "1.9.0",
	_windows = {},
	_windowCounter = 0,
}

local Theme = {
	Background = Color3.fromRGB(15, 15, 15),
	BackgroundAlt = Color3.fromRGB(18, 18, 18),
	Sidebar = Color3.fromRGB(22, 22, 22),
	Panel = Color3.fromRGB(25, 25, 25),
	PanelAlt = Color3.fromRGB(21, 21, 21),
	Card = Color3.fromRGB(31, 31, 31),
	CardHover = Color3.fromRGB(39, 39, 39),
	CardPressed = Color3.fromRGB(34, 34, 34),
	Input = Color3.fromRGB(36, 36, 36),
	InputHover = Color3.fromRGB(42, 42, 42),
	Accent = Color3.fromRGB(29, 185, 84),
	AccentHover = Color3.fromRGB(30, 215, 96),
	AccentSoft = Color3.fromRGB(23, 122, 59),
	Text = Color3.fromRGB(255, 255, 255),
	Subtext = Color3.fromRGB(179, 179, 179),
	Muted = Color3.fromRGB(126, 126, 126),
	Stroke = Color3.fromRGB(67, 67, 67),
	Outline = Color3.fromRGB(72, 72, 72),
	Divider = Color3.fromRGB(54, 54, 54),
	Selected = Color3.fromRGB(38, 38, 38),
	Track = Color3.fromRGB(78, 78, 78),
	Shadow = Color3.fromRGB(0, 0, 0),
	Danger = Color3.fromRGB(232, 72, 85),
}

local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FAST_TWEEN_INFO = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local POP_TWEEN_INFO = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local FADE_TWEEN_INFO = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local TOPBAR_HEIGHT = 66
local NOW_PLAYING_HEIGHT = 108
local NOW_PLAYING_COMPACT_HEIGHT = 86
local SIDEBAR_HEADER_HEIGHT = 88
local SETTINGS_AREA_HEIGHT = 72
local WINDOW_CORNER_RADIUS = 16
local PANEL_CORNER_RADIUS = 12
local CARD_CORNER_RADIUS = 10
local CONTROL_CORNER_RADIUS = 8
local WINDOW_OUTLINE_TRANSPARENCY = 0.48
local WINDOW_SHADOW_TRANSPARENCY = 0.78
local MINI_PLAYER_SIZE = Vector2.new(300, 156)
local MINI_PLAYER_MARGIN = 16
local SETTINGS_PANEL_MIN_WIDTH = 318
local SETTINGS_PANEL_MAX_WIDTH = 382
local SEARCH_BAR_HEIGHT = 38
local SEARCH_RESULTS_MAX_HEIGHT = 250
local DEFAULT_SEARCH_RESULTS = 6

local DEFAULT_TAB_ICONS = {
	home = "⌂",
	inicio = "⌂",
	["início"] = "⌂",
	main = "⌂",
	sobre = "i",
	about = "i",
	player = "▶",
	music = "♫",
	musica = "♫",
	settings = "⚙",
	configuracoes = "⚙",
	["configurações"] = "⚙",
}

-- Maid simples para impedir vazamento de conexões, threads e objetos temporários.
local Maid = {}
Maid.__index = Maid

local function cleanupTask(taskItem)
	if taskItem == nil then
		return
	end

	local itemType = typeof(taskItem)
	if itemType == "RBXScriptConnection" then
		if taskItem.Connected then
			taskItem:Disconnect()
		end
	elseif itemType == "Tween" then
		taskItem:Cancel()
	elseif itemType == "Instance" then
		taskItem:Destroy()
	elseif type(taskItem) == "function" then
		taskItem()
	elseif type(taskItem) == "thread" then
		pcall(task.cancel, taskItem)
	elseif type(taskItem) == "table" then
		if type(taskItem.Destroy) == "function" then
			taskItem:Destroy()
		elseif type(taskItem.Cleanup) == "function" then
			taskItem:Cleanup()
		end
	end
end

function Maid.new()
	return setmetatable({
		_tasks = {},
		_nextId = 0,
		_cleaned = false,
	}, Maid)
end

function Maid:Give(taskItem)
	if self._cleaned then
		cleanupTask(taskItem)
		return nil
	end

	self._nextId += 1
	self._tasks[self._nextId] = taskItem
	return self._nextId
end

function Maid:Forget(taskId)
	if taskId ~= nil then
		self._tasks[taskId] = nil
	end
end

function Maid:Remove(taskId)
	if taskId == nil then
		return
	end

	local taskItem = self._tasks[taskId]
	self._tasks[taskId] = nil
	cleanupTask(taskItem)
end

function Maid:Cleanup()
	if self._cleaned then
		return
	end
	self._cleaned = true

	local tasks = self._tasks
	self._tasks = {}

	for _, taskItem in pairs(tasks) do
		local ok, err = pcall(cleanupTask, taskItem)
		if not ok then
			warn("[SpotifyUI] Erro durante cleanup:", err)
		end
	end
end

local function create(className, properties)
	local instance = Instance.new(className)
	local parent = properties.Parent

	for property, value in pairs(properties) do
		if property ~= "Parent" then
			instance[property] = value
		end
	end

	if parent ~= nil then
		instance.Parent = parent
	end

	return instance
end

local function addCorner(parent, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
		Parent = parent,
	})
end

local function addStroke(parent, color, transparency, _thickness)
	-- Todos os contornos da biblioteca usam 2 px para manter consistência visual.
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color or Theme.Stroke,
		Transparency = transparency == nil and 0.45 or transparency,
		Thickness = 2,
		LineJoinMode = Enum.LineJoinMode.Round,
		Parent = parent,
	})
end

local function addInsetStroke(parent, radius, color, transparency, inset, zIndex)
	local borderInset = math.max(math.floor(tonumber(inset) or 1), 1)
	local borderFrame = create("Frame", {
		Name = "InsetBorder",
		Position = UDim2.fromOffset(borderInset, borderInset),
		Size = UDim2.new(1, -borderInset * 2, 1, -borderInset * 2),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = zIndex or (parent.ZIndex + 1),
		Parent = parent,
	})
	addCorner(borderFrame, math.max((radius or 8) - borderInset, 1))
	return addStroke(borderFrame, color, transparency, 2), borderFrame
end

local function addGradient(parent, startColor, endColor, rotation)
	return create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, startColor),
			ColorSequenceKeypoint.new(1, endColor),
		}),
		Rotation = rotation or 90,
		Parent = parent,
	})
end

local function playTween(instance, tweenInfo, properties)
	local tween = TweenService:Create(instance, tweenInfo or TWEEN_INFO, properties)
	tween:Play()
	return tween
end

local function replaceTween(owner, key, tween)
	local previous = owner[key]
	if previous then
		previous:Cancel()
	end
	owner[key] = tween
	return tween
end

local function safeCallback(callback, ...)
	if type(callback) ~= "function" then
		return
	end

	local arguments = table.pack(...)
	task.spawn(function()
		local ok, err = xpcall(function()
			callback(table.unpack(arguments, 1, arguments.n))
		end, debug.traceback)

		if not ok then
			warn("[SpotifyUI] Erro no callback:\n" .. tostring(err))
		end
	end)
end

local function normalizeConfig(config, textKey)
	if type(config) == "string" then
		return { [textKey or "Text"] = config }
	end
	return config or {}
end

local function formatElapsedTime(seconds)
	local totalSeconds = math.max(0, math.floor(tonumber(seconds) or 0))
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local secs = totalSeconds % 60

	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, minutes, secs)
	end
	return string.format("%d:%02d", minutes, secs)
end

local function normalizeKeyCode(value)
	if value == nil or value == false or value == Enum.KeyCode.Unknown then
		return nil
	end

	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value
	end

	if type(value) == "string" then
		local ok, keyCode = pcall(function()
			return Enum.KeyCode[value]
		end)
		if ok then
			return keyCode
		end
	end

	return nil
end

local function getKeyCodeDisplayName(keyCode)
	if keyCode == nil or keyCode == Enum.KeyCode.Unknown then
		return "Nenhuma tecla"
	end

	local ok, displayName = pcall(function()
		return UserInputService:GetStringForKeyCode(keyCode)
	end)

	if ok and type(displayName) == "string" and displayName ~= "" then
		return displayName
	end

	return keyCode.Name
end

local function normalizeTabConfig(nameOrConfig, iconOverride)
	local config
	if type(nameOrConfig) == "table" then
		config = table.clone(nameOrConfig)
	else
		config = {
			Name = tostring(nameOrConfig or "Tab"),
			Icon = iconOverride,
		}
	end

	config.Name = tostring(config.Name or config.Text or "Tab")
	if config.Icon == nil then
		local normalizedName = string.lower(config.Name)
		config.Icon = DEFAULT_TAB_ICONS[normalizedName] or string.upper(string.sub(config.Name, 1, 1))
	end

	return config
end

local function isImageIcon(icon)
	if type(icon) ~= "string" then
		return false
	end

	return string.match(icon, "^rbxasset") ~= nil
		or string.match(icon, "^rbxthumb") ~= nil
		or string.match(icon, "^https?://") ~= nil
end

local function attachComponentLifecycle(api, maid, root, beforeDestroy)
	local destroyed = false
	maid:Give(root)

	function api:IsDestroyed()
		return destroyed
	end

	function api:Destroy()
		if destroyed then
			return
		end
		destroyed = true

		if type(beforeDestroy) == "function" then
			local ok, err = pcall(beforeDestroy)
			if not ok then
				warn("[SpotifyUI] Erro ao destruir componente:", err)
			end
		end

		maid:Cleanup()
	end

	return api
end

local function bindHover(button, maid, normalColor, hoverColor)
	maid:Give(button.MouseEnter:Connect(function()
		playTween(button, FAST_TWEEN_INFO, { BackgroundColor3 = hoverColor })
	end))

	maid:Give(button.MouseLeave:Connect(function()
		playTween(button, FAST_TWEEN_INFO, { BackgroundColor3 = normalColor })
	end))
end

local function bindInteractiveSurface(hitbox, maid, surface, stroke, scale, options)
	options = options or {}
	local normalColor = options.NormalColor or Theme.Card
	local hoverColor = options.HoverColor or Theme.CardHover
	local pressedColor = options.PressedColor or Theme.CardPressed
	local normalStrokeColor = options.StrokeColor or Theme.Stroke
	local hoverStrokeColor = options.HoverStrokeColor or Theme.AccentSoft
	local normalStrokeTransparency = options.StrokeTransparency == nil and 0.78 or options.StrokeTransparency
	local hoverStrokeTransparency = options.HoverStrokeTransparency == nil and 0.42 or options.HoverStrokeTransparency
	local hovered = false
	local pressed = false

	local function render()
		local targetColor = pressed and pressedColor or (hovered and hoverColor or normalColor)
		playTween(surface, FAST_TWEEN_INFO, { BackgroundColor3 = targetColor })

		if stroke then
			playTween(stroke, FAST_TWEEN_INFO, {
				Color = hovered and hoverStrokeColor or normalStrokeColor,
				Transparency = hovered and hoverStrokeTransparency or normalStrokeTransparency,
			})
		end

		if scale then
			playTween(scale, FAST_TWEEN_INFO, {
				Scale = pressed and 0.992 or 1,
			})
		end
	end

	maid:Give(hitbox.MouseEnter:Connect(function()
		hovered = true
		render()
	end))

	maid:Give(hitbox.MouseLeave:Connect(function()
		hovered = false
		pressed = false
		render()
	end))

	maid:Give(hitbox.MouseButton1Down:Connect(function()
		pressed = true
		render()
	end))

	maid:Give(hitbox.MouseButton1Up:Connect(function()
		pressed = false
		render()
	end))

	return function()
		hovered = false
		pressed = false
		render()
	end
end

local function makeTextLabel(parent, properties)
	properties = properties or {}
	properties.Parent = parent
	properties.BackgroundTransparency = properties.BackgroundTransparency == nil and 1
		or properties.BackgroundTransparency
	properties.BorderSizePixel = 0
	properties.Font = properties.Font or Enum.Font.Gotham
	properties.TextColor3 = properties.TextColor3 or Theme.Text
	properties.TextSize = properties.TextSize or 14
	return create("TextLabel", properties)
end

local function makeTextButton(parent, properties)
	properties = properties or {}
	properties.Parent = parent
	properties.AutoButtonColor = false
	properties.BorderSizePixel = 0
	properties.Font = properties.Font or Enum.Font.GothamMedium
	properties.TextColor3 = properties.TextColor3 or Theme.Text
	properties.TextSize = properties.TextSize or 14
	return create("TextButton", properties)
end

local function formatNumber(value, increment)
	local decimals = 0
	local incrementText = tostring(increment)
	local decimalPart = incrementText:match("%.(%d+)")
	if decimalPart then
		decimals = math.min(#decimalPart, 4)
	end
	return string.format("%." .. decimals .. "f", value)
end

local function getPlayerGui(parentOverride)
	if parentOverride then
		return parentOverride
	end

	local localPlayer = Players.LocalPlayer
	assert(localPlayer, "[SpotifyUI] A biblioteca deve ser criada em um LocalScript.")
	return localPlayer:WaitForChild("PlayerGui")
end

local function createComponentMaid(window, owner)
	local componentMaid = Maid.new()
	local windowTaskId = window._maid:Give(componentMaid)
	componentMaid:Give(function()
		window._maid:Forget(windowTaskId)
	end)

	if owner then
		owner._componentMaids = owner._componentMaids or {}
		owner._componentMaids[componentMaid] = true
		componentMaid:Give(function()
			if owner._componentMaids then
				owner._componentMaids[componentMaid] = nil
			end
		end)
	end

	return componentMaid
end

local function createBaseRow(section, height)
	local row = create("Frame", {
		Name = "Component",
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = section._content,
	})
	addCorner(row, CARD_CORNER_RADIUS)
	local stroke = addStroke(row, Theme.Stroke, 0.78, 1)
	local scale = create("UIScale", {
		Scale = 1,
		Parent = row,
	})
	addGradient(row, Color3.fromRGB(33, 33, 33), Color3.fromRGB(28, 28, 28), 90)
	return row, stroke, scale
end

local SectionMethods = {}
SectionMethods.__index = SectionMethods

function SectionMethods:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	local componentMaids = {}
	for componentMaid in pairs(self._componentMaids or {}) do
		table.insert(componentMaids, componentMaid)
	end
	for _, componentMaid in ipairs(componentMaids) do
		componentMaid:Cleanup()
	end

	if self._frame then
		self._frame:Destroy()
	end

	if self._tab then
		for index, section in ipairs(self._tab._sections) do
			if section == self then
				table.remove(self._tab._sections, index)
				break
			end
		end
		if self._tab._defaultSection == self then
			self._tab._defaultSection = nil
		end
	end
end

function SectionMethods:CreateButton(config)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A section ou janela já foi destruída.")
	config = normalizeConfig(config, "Text")
	local maid = createComponentMaid(self._window, self)
	local row, stroke, rowScale = createBaseRow(self, config.Description and 66 or 52)

	local button = makeTextButton(row, {
		Name = "Button",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 9,
	})

	local title = makeTextLabel(button, {
		Name = "Title",
		Position = UDim2.fromOffset(16, config.Description and 10 or 0),
		Size = config.Description and UDim2.new(1, -60, 0, 22) or UDim2.new(1, -60, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Button",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		ZIndex = 10,
	})

	if config.Description then
		makeTextLabel(button, {
			Position = UDim2.fromOffset(16, 33),
			Size = UDim2.new(1, -60, 0, 18),
			Text = tostring(config.Description),
			TextColor3 = Theme.Subtext,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 10,
		})
	end

	local arrow = makeTextLabel(button, {
		Position = UDim2.new(1, -43, 0.5, -11),
		Size = UDim2.fromOffset(22, 22),
		Font = Enum.Font.GothamBold,
		Text = "›",
		TextColor3 = Theme.Subtext,
		TextSize = 20,
		ZIndex = 10,
	})

	bindInteractiveSurface(button, maid, row, stroke, rowScale)

	maid:Give(button.MouseEnter:Connect(function()
		playTween(arrow, FAST_TWEEN_INFO, {
			Position = UDim2.new(1, -38, 0.5, -11),
			TextColor3 = Theme.Text,
		})
	end))
	maid:Give(button.MouseLeave:Connect(function()
		playTween(arrow, FAST_TWEEN_INFO, {
			Position = UDim2.new(1, -43, 0.5, -11),
			TextColor3 = Theme.Subtext,
		})
	end))

	maid:Give(button.MouseButton1Click:Connect(function()
		local flash = create("Frame", {
			Name = "ClickFlash",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.86,
			BorderSizePixel = 0,
			ZIndex = 9,
			Parent = row,
		})
		addCorner(flash, CARD_CORNER_RADIUS)
		local flashTween = playTween(flash, TWEEN_INFO, {
			BackgroundTransparency = 1,
		})
		local completedTaskId
		completedTaskId = maid:Give(flashTween.Completed:Connect(function()
			maid:Remove(completedTaskId)
			if flash.Parent then
				flash:Destroy()
			end
		end))
		safeCallback(config.Callback)
	end))

	local api = {}
	function api:SetText(text)
		title.Text = tostring(text)
	end
	function api:Fire()
		safeCallback(config.Callback)
	end
	function api:SetVisible(visible)
		row.Visible = visible == true
	end
	return attachComponentLifecycle(api, maid, row)
end

function SectionMethods:CreateToggle(config)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A section ou janela já foi destruída.")
	config = normalizeConfig(config, "Text")
	local maid = createComponentMaid(self._window, self)
	local row, stroke, rowScale = createBaseRow(self, config.Description and 66 or 54)
	local value = config.Default == true

	local button = makeTextButton(row, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 9,
	})

	makeTextLabel(row, {
		Position = UDim2.fromOffset(16, config.Description and 9 or 0),
		Size = config.Description and UDim2.new(1, -96, 0, 22) or UDim2.new(1, -96, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Toggle",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		ZIndex = 10,
	})

	if config.Description then
		makeTextLabel(row, {
			Position = UDim2.fromOffset(16, 32),
			Size = UDim2.new(1, -96, 0, 18),
			Text = tostring(config.Description),
			TextColor3 = Theme.Subtext,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 10,
		})
	end

	local track = create("Frame", {
		Position = UDim2.new(1, -64, 0.5, -14),
		Size = UDim2.fromOffset(48, 28),
		BackgroundColor3 = value and Theme.Accent or Theme.Track,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = row,
	})
	addCorner(track, 14)
	local trackStroke = addStroke(track, value and Theme.AccentHover or Theme.Stroke, 0.72, 1)

	local knobShadow = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = value and UDim2.new(1, -14, 0.5, 1) or UDim2.new(0, 14, 0.5, 1),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = track,
	})
	addCorner(knobShadow, 11)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = value and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
		ZIndex = 11,
		Parent = track,
	})
	addCorner(knob, 10)

	local function render(animated)
		local info = animated and POP_TWEEN_INFO or TweenInfo.new(0)
		local position = value and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 14, 0.5, 0)
		local shadowPosition = value and UDim2.new(1, -14, 0.5, 1) or UDim2.new(0, 14, 0.5, 1)
		playTween(track, animated and TWEEN_INFO or TweenInfo.new(0), {
			BackgroundColor3 = value and Theme.Accent or Theme.Track,
		})
		playTween(trackStroke, animated and TWEEN_INFO or TweenInfo.new(0), {
			Color = value and Theme.AccentHover or Theme.Stroke,
			Transparency = value and 0.58 or 0.76,
		})
		playTween(knob, info, {
			Position = position,
			Size = animated and UDim2.fromOffset(21, 21) or UDim2.fromOffset(20, 20),
		})
		playTween(knobShadow, info, {
			Position = shadowPosition,
		})
		if animated then
			local resetTaskId
			resetTaskId = maid:Give(task.delay(0.16, function()
				maid:Forget(resetTaskId)
				if knob.Parent then
					playTween(knob, FAST_TWEEN_INFO, { Size = UDim2.fromOffset(20, 20) })
				end
			end))
		end
	end

	local function setValue(newValue, fireCallback)
		newValue = newValue == true
		if value == newValue then
			return
		end
		value = newValue
		render(true)
		if fireCallback ~= false then
			safeCallback(config.Callback, value)
		end
	end

	bindInteractiveSurface(button, maid, row, stroke, rowScale)
	maid:Give(button.MouseButton1Click:Connect(function()
		setValue(not value, true)
	end))

	local api = {}
	function api:Set(newValue, fireCallback)
		setValue(newValue, fireCallback)
	end
	function api:Get()
		return value
	end
	function api:SetVisible(visible)
		row.Visible = visible == true
	end
	return attachComponentLifecycle(api, maid, row)
end

function SectionMethods:CreateSlider(config)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A section ou janela já foi destruída.")
	config = normalizeConfig(config, "Text")
	local maid = createComponentMaid(self._window, self)
	local row, stroke, rowScale = createBaseRow(self, 78)

	local minimum = tonumber(config.Min) or 0
	local maximum = tonumber(config.Max) or 100
	if maximum < minimum then
		minimum, maximum = maximum, minimum
	end
	if maximum == minimum then
		maximum = minimum + 1
	end

	local increment = math.abs(tonumber(config.Increment) or 1)
	if increment == 0 then
		increment = 1
	end

	local value = math.clamp(tonumber(config.Default) or minimum, minimum, maximum)
	local dragging = false
	local dragInput = nil
	local rowHovered = false

	makeTextLabel(row, {
		Position = UDim2.fromOffset(16, 8),
		Size = UDim2.new(1, -90, 0, 22),
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Slider",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		ZIndex = 10,
	})

	local valueLabel = makeTextLabel(row, {
		Position = UDim2.new(1, -78, 0, 8),
		Size = UDim2.fromOffset(62, 22),
		Font = Enum.Font.GothamBold,
		Text = formatNumber(value, increment),
		TextColor3 = Theme.AccentHover,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 13,
		ZIndex = 10,
	})

	local track = create("Frame", {
		Position = UDim2.new(0, 16, 1, -29),
		Size = UDim2.new(1, -32, 0, 6),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 10,
		Parent = row,
	})
	addCorner(track, 3)

	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 11,
		Parent = track,
	})
	addCorner(fill, 3)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
		ZIndex = 12,
		Parent = track,
	})
	addCorner(knob, 8)
	addStroke(knob, Theme.Shadow, 0.7, 1)

	local function roundToIncrement(rawValue)
		local steps = math.floor(((rawValue - minimum) / increment) + 0.5)
		return math.clamp(minimum + steps * increment, minimum, maximum)
	end

	local function render(animated)
		local alpha = (value - minimum) / (maximum - minimum)
		local info = animated and FAST_TWEEN_INFO or TweenInfo.new(0)
		playTween(fill, info, { Size = UDim2.fromScale(alpha, 1) })
		playTween(knob, info, { Position = UDim2.fromScale(alpha, 0.5) })
		valueLabel.Text = formatNumber(value, increment) .. (config.Suffix or "")
	end

	local function setValue(newValue, fireCallback, animated)
		newValue = roundToIncrement(tonumber(newValue) or minimum)
		if newValue == value then
			return
		end
		value = newValue
		render(animated ~= false)
		if fireCallback ~= false then
			safeCallback(config.Callback, value)
		end
	end

	local function updateFromX(screenX)
		if track.AbsoluteSize.X <= 0 then
			return
		end
		local alpha = math.clamp((screenX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		setValue(minimum + (maximum - minimum) * alpha, true, false)
	end

	maid:Give(track.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragInput = input
			updateFromX(input.Position.X)
			playTween(knob, FAST_TWEEN_INFO, { Size = UDim2.fromOffset(20, 20) })
		end
	end))

	maid:Give(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		local isMouseMovement = input.UserInputType == Enum.UserInputType.MouseMovement
		local isTrackedTouch = dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput

		if isMouseMovement or isTrackedTouch then
			updateFromX(input.Position.X)
		end
	end))

	maid:Give(UserInputService.InputEnded:Connect(function(input)
		local endedMouse = input.UserInputType == Enum.UserInputType.MouseButton1
		local endedTouch = dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput

		if dragging and (endedMouse or endedTouch) then
			dragging = false
			dragInput = nil
			playTween(knob, FAST_TWEEN_INFO, { Size = UDim2.fromOffset(16, 16) })
			if not rowHovered then
				playTween(row, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Card })
				playTween(stroke, FAST_TWEEN_INFO, {
					Color = Theme.Stroke,
					Transparency = 0.78,
				})
			end
		end
	end))

	maid:Give(row.MouseEnter:Connect(function()
		rowHovered = true
		playTween(row, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.CardHover })
		playTween(stroke, FAST_TWEEN_INFO, {
			Color = Theme.AccentSoft,
			Transparency = 0.46,
		})
	end))
	maid:Give(row.MouseLeave:Connect(function()
		rowHovered = false
		if not dragging then
			playTween(row, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Card })
			playTween(stroke, FAST_TWEEN_INFO, {
				Color = Theme.Stroke,
				Transparency = 0.78,
			})
		end
	end))

	render(false)

	local api = {}
	function api:SetValue(newValue, fireCallback)
		setValue(newValue, fireCallback, true)
	end
	function api:GetValue()
		return value
	end
	function api:SetVisible(visible)
		row.Visible = visible == true
	end
	return attachComponentLifecycle(api, maid, row, function()
		dragging = false
		dragInput = nil
	end)
end

function SectionMethods:CreateDropdown(config)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A section ou janela já foi destruída.")
	config = normalizeConfig(config, "Text")
	local maid = createComponentMaid(self._window, self)
	local optionsMaid = Maid.new()
	local optionsMaidTaskId = maid:Give(optionsMaid)

	local options = table.clone(config.Options or {})
	local multi = config.Multi == true
	local value = multi and nil or config.Default
	local selectedValues = {}
	local opened = false
	local collapsedHeight = 58

	local function optionExists(candidate)
		for _, option in ipairs(options) do
			if option == candidate then
				return true
			end
		end
		return false
	end

	local function assignMultiValues(newValue)
		table.clear(selectedValues)
		if type(newValue) == "table" then
			for _, item in ipairs(newValue) do
				if optionExists(item) then
					selectedValues[item] = true
				end
			end
		elseif newValue ~= nil and optionExists(newValue) then
			selectedValues[newValue] = true
		end
	end

	local function getMultiValues()
		local result = {}
		for _, option in ipairs(options) do
			if selectedValues[option] then
				table.insert(result, option)
			end
		end
		return result
	end

	if multi then
		assignMultiValues(config.Default)
	end

	local row, rowStroke = createBaseRow(self, collapsedHeight)
	row.ClipsDescendants = false

	makeTextLabel(row, {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(0.45, -16, 0, collapsedHeight),
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Dropdown",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		ZIndex = 10,
	})

	local selector = makeTextButton(row, {
		Position = UDim2.new(0.45, 0, 0, 10),
		Size = UDim2.new(0.55, -16, 0, 38),
		BackgroundColor3 = Theme.Input,
		Text = "",
		ClipsDescendants = false,
		ZIndex = 11,
	})
	addCorner(selector, CONTROL_CORNER_RADIUS)
	local selectorStroke = addInsetStroke(selector, CONTROL_CORNER_RADIUS, Theme.Stroke, 0.68, 2, 14)

	local selectedLabel = makeTextLabel(selector, {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -42, 1, 0),
		Text = "",
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 12,
	})

	local arrow = makeTextLabel(selector, {
		Position = UDim2.new(1, -32, 0, 0),
		Size = UDim2.fromOffset(24, 38),
		Font = Enum.Font.GothamBold,
		Text = "⌄",
		TextColor3 = Theme.Subtext,
		TextSize = 13,
		ZIndex = 12,
	})

	local optionsHolder = create("ScrollingFrame", {
		Name = "Options",
		Position = UDim2.fromOffset(12, collapsedHeight),
		Size = UDim2.new(1, -24, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = Theme.Subtext,
		ScrollBarImageTransparency = 0.45,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		ZIndex = 12,
		Parent = row,
	})

	local optionsLayout = create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = optionsHolder,
	})

	local function updateSelectedLabel()
		if multi then
			local selected = getMultiValues()
			if #selected == 0 then
				selectedLabel.Text = config.Placeholder or "Selecionar"
				selectedLabel.TextColor3 = Theme.Subtext
			else
				local labels = {}
				for _, item in ipairs(selected) do
					table.insert(labels, tostring(item))
				end
				selectedLabel.Text = table.concat(labels, ", ")
				selectedLabel.TextColor3 = Theme.Text
			end
		else
			selectedLabel.Text = value ~= nil and tostring(value) or (config.Placeholder or "Selecionar")
			selectedLabel.TextColor3 = value ~= nil and Theme.Text or Theme.Subtext
		end
	end

	local function getExpandedHeight()
		local visibleOptions = math.clamp(#options, 1, 4)
		return collapsedHeight + 10 + visibleOptions * 36 + math.max(visibleOptions - 1, 0) * 6
	end

	local function setOpened(newOpened)
		opened = newOpened == true
		optionsHolder.Visible = opened
		local targetHeight = opened and getExpandedHeight() or collapsedHeight
		local holderHeight = opened and (targetHeight - collapsedHeight - 10) or 0

		playTween(row, POP_TWEEN_INFO, { Size = UDim2.new(1, 0, 0, targetHeight) })
		playTween(optionsHolder, TWEEN_INFO, { Size = UDim2.new(1, -24, 0, holderHeight) })
		playTween(arrow, TWEEN_INFO, {
			Rotation = opened and 180 or 0,
			TextColor3 = opened and Theme.Text or Theme.Subtext,
		})
		playTween(selectorStroke, FAST_TWEEN_INFO, {
			Color = opened and Theme.Accent or Theme.Stroke,
			Transparency = opened and 0.24 or 0.68,
		})
		playTween(rowStroke, FAST_TWEEN_INFO, {
			Color = opened and Theme.AccentSoft or Theme.Stroke,
			Transparency = opened and 0.48 or 0.78,
		})
	end

	local function setValue(newValue, fireCallback)
		if multi then
			assignMultiValues(newValue)
			updateSelectedLabel()
			if fireCallback ~= false then
				safeCallback(config.Callback, table.clone(getMultiValues()))
			end
		else
			value = newValue
			updateSelectedLabel()
			if fireCallback ~= false then
				safeCallback(config.Callback, value)
			end
		end
	end

	local rebuildOptions
	rebuildOptions = function()
		maid:Forget(optionsMaidTaskId)
		optionsMaid:Cleanup()
		optionsMaid = Maid.new()
		optionsMaidTaskId = maid:Give(optionsMaid)

		for _, child in ipairs(optionsHolder:GetChildren()) do
			if child ~= optionsLayout then
				child:Destroy()
			end
		end

		if #options == 0 then
			makeTextLabel(optionsHolder, {
				Name = "Empty",
				Size = UDim2.new(1, 0, 0, 36),
				Text = "Nenhuma opção",
				TextColor3 = Theme.Subtext,
				TextSize = 12,
				LayoutOrder = 1,
				ZIndex = 13,
			})
		else
			for index, option in ipairs(options) do
				local optionValue = option
				local selected = value == optionValue
				if multi then
					selected = selectedValues[optionValue] == true
				end
				local optionButton = makeTextButton(optionsHolder, {
					Name = "Option",
					Size = UDim2.new(1, -6, 0, 36),
					BackgroundColor3 = selected and Theme.Selected or Theme.Input,
					Text = "",
					LayoutOrder = index,
					ClipsDescendants = false,
					ZIndex = 13,
				})
				addCorner(optionButton, CONTROL_CORNER_RADIUS)
				makeTextLabel(optionButton, {
					Name = "OptionText",
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, selected and -46 or -24, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = tostring(optionValue),
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 13,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 16,
				})
				local optionStroke = addInsetStroke(
					optionButton,
					CONTROL_CORNER_RADIUS,
					selected and Theme.Accent or Theme.Stroke,
					selected and 0.18 or 0.82,
					2,
					15
				)

				if selected then
					makeTextLabel(optionButton, {
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -11, 0.5, 0),
						Size = UDim2.fromOffset(18, 18),
						Font = Enum.Font.GothamBold,
						Text = "✓",
						TextColor3 = Theme.AccentHover,
						TextSize = 13,
						ZIndex = 16,
					})
				end

				bindInteractiveSurface(optionButton, optionsMaid, optionButton, optionStroke, nil, {
					NormalColor = selected and Theme.Selected or Theme.Input,
					HoverColor = Theme.InputHover,
					StrokeColor = selected and Theme.Accent or Theme.Stroke,
					HoverStrokeColor = Theme.AccentHover,
					StrokeTransparency = selected and 0.18 or 0.82,
					HoverStrokeTransparency = selected and 0.08 or 0.44,
				})

				optionsMaid:Give(optionButton.MouseButton1Click:Connect(function()
					if multi then
						if selectedValues[optionValue] then
							selectedValues[optionValue] = nil
						else
							selectedValues[optionValue] = true
						end
						updateSelectedLabel()
						safeCallback(config.Callback, table.clone(getMultiValues()))
						rebuildOptions()
					else
						setValue(optionValue, true)
						setOpened(false)
						rebuildOptions()
					end
				end))
			end
		end

		if opened then
			setOpened(true)
		end
	end

	maid:Give(selector.MouseEnter:Connect(function()
		playTween(selector, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.InputHover })
		playTween(selectorStroke, FAST_TWEEN_INFO, {
			Color = opened and Theme.Accent or Theme.AccentSoft,
			Transparency = opened and 0.18 or 0.38,
		})
	end))
	maid:Give(selector.MouseLeave:Connect(function()
		playTween(selector, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Input })
		playTween(selectorStroke, FAST_TWEEN_INFO, {
			Color = opened and Theme.Accent or Theme.Stroke,
			Transparency = opened and 0.24 or 0.68,
		})
	end))
	maid:Give(selector.MouseButton1Click:Connect(function()
		setOpened(not opened)
	end))

	updateSelectedLabel()
	rebuildOptions()

	local api = {}
	function api:SetValue(newValue, fireCallback)
		setValue(newValue, fireCallback)
		rebuildOptions()
	end
	function api:GetValue()
		if multi then
			return table.clone(getMultiValues())
		end
		return value
	end
	function api:SetOptions(newOptions, keepValue)
		options = table.clone(newOptions or {})
		if not keepValue then
			setValue(nil, false)
		elseif multi then
			for selectedValue in pairs(selectedValues) do
				if not optionExists(selectedValue) then
					selectedValues[selectedValue] = nil
				end
			end
			updateSelectedLabel()
		elseif value ~= nil and not optionExists(value) then
			setValue(nil, false)
		end
		rebuildOptions()
	end
	function api:Select(optionValue, fireCallback)
		if not multi or not optionExists(optionValue) then
			return
		end
		selectedValues[optionValue] = true
		updateSelectedLabel()
		rebuildOptions()
		if fireCallback ~= false then
			safeCallback(config.Callback, table.clone(getMultiValues()))
		end
	end
	function api:Deselect(optionValue, fireCallback)
		if not multi then
			return
		end
		selectedValues[optionValue] = nil
		updateSelectedLabel()
		rebuildOptions()
		if fireCallback ~= false then
			safeCallback(config.Callback, table.clone(getMultiValues()))
		end
	end
	function api:Clear(fireCallback)
		if multi then
			table.clear(selectedValues)
			updateSelectedLabel()
			rebuildOptions()
			if fireCallback ~= false then
				safeCallback(config.Callback, {})
			end
		else
			setValue(nil, fireCallback)
			rebuildOptions()
		end
	end
	function api:IsMulti()
		return multi
	end
	function api:SetOpen(isOpen)
		setOpened(isOpen)
	end
	function api:SetVisible(visible)
		row.Visible = visible == true
	end
	return attachComponentLifecycle(api, maid, row)
end

function SectionMethods:CreateInput(config)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A section ou janela já foi destruída.")
	config = normalizeConfig(config, "Text")
	local maid = createComponentMaid(self._window, self)
	local row, rowStroke, rowScale = createBaseRow(self, 68)
	local focused = false

	makeTextLabel(row, {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(0.38, -16, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Input",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		ZIndex = 10,
	})

	local textBox = create("TextBox", {
		Position = UDim2.new(0.38, 0, 0, 12),
		Size = UDim2.new(0.62, -16, 0, 42),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		ClearTextOnFocus = config.ClearTextOnFocus == true,
		Font = Enum.Font.Gotham,
		PlaceholderColor3 = Theme.Subtext,
		PlaceholderText = config.Placeholder or "Digite aqui...",
		Text = tostring(config.Default or ""),
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
		Parent = row,
	})
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = textBox,
	})
	addCorner(textBox, CONTROL_CORNER_RADIUS)
	local inputStroke = addStroke(textBox, Theme.Stroke, 0.68, 1)

	maid:Give(textBox.MouseEnter:Connect(function()
		if not focused then
			playTween(textBox, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.InputHover })
			playTween(inputStroke, FAST_TWEEN_INFO, { Transparency = 0.48 })
		end
	end))
	maid:Give(textBox.MouseLeave:Connect(function()
		if not focused then
			playTween(textBox, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Input })
			playTween(inputStroke, FAST_TWEEN_INFO, { Transparency = 0.68 })
		end
	end))

	maid:Give(textBox.Focused:Connect(function()
		focused = true
		playTween(textBox, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.InputHover })
		playTween(inputStroke, FAST_TWEEN_INFO, {
			Color = Theme.Accent,
			Transparency = 0.2,
		})
		playTween(rowStroke, FAST_TWEEN_INFO, {
			Color = Theme.AccentSoft,
			Transparency = 0.5,
		})
	end))

	maid:Give(textBox.FocusLost:Connect(function(enterPressed)
		focused = false
		playTween(textBox, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Input })
		playTween(inputStroke, FAST_TWEEN_INFO, {
			Color = Theme.Stroke,
			Transparency = 0.68,
		})
		playTween(rowStroke, FAST_TWEEN_INFO, {
			Color = Theme.Stroke,
			Transparency = 0.78,
		})
		safeCallback(config.Callback, textBox.Text, enterPressed)
	end))

	if type(config.Changed) == "function" then
		maid:Give(textBox:GetPropertyChangedSignal("Text"):Connect(function()
			safeCallback(config.Changed, textBox.Text)
		end))
	end

	local api = {}
	function api:SetText(text, fireCallback)
		textBox.Text = tostring(text or "")
		if fireCallback then
			safeCallback(config.Callback, textBox.Text, false)
		end
	end
	function api:GetText()
		return textBox.Text
	end
	function api:Focus()
		textBox:CaptureFocus()
	end
	function api:SetVisible(visible)
		row.Visible = visible == true
	end
	return attachComponentLifecycle(api, maid, row)
end

function SectionMethods:CreateLabel(config)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A section ou janela já foi destruída.")
	config = normalizeConfig(config, "Text")
	local maid = createComponentMaid(self._window, self)
	local row = create("Frame", {
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = self._content,
	})
	addCorner(row, CARD_CORNER_RADIUS)
	addStroke(row, Theme.Stroke, 0.72, 1)
	create("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = row,
	})

	local label = makeTextLabel(row, {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = config.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		Text = config.Text or "Label",
		TextColor3 = config.Color or Theme.Subtext,
		TextXAlignment = config.Alignment or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = config.TextSize or 13,
		TextWrapped = true,
		ZIndex = 10,
	})

	local api = {}
	function api:SetText(text)
		label.Text = tostring(text)
	end
	function api:SetColor(color)
		label.TextColor3 = color
	end
	function api:SetVisible(visible)
		row.Visible = visible == true
	end
	return attachComponentLifecycle(api, maid, row)
end

function SectionMethods:CreateParagraph(config)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A section ou janela já foi destruída.")
	config = normalizeConfig(config, "Content")
	local maid = createComponentMaid(self._window, self)
	local row = create("Frame", {
		Name = "Paragraph",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = self._content,
	})
	addCorner(row, CARD_CORNER_RADIUS)
	addStroke(row, Theme.Stroke, 0.72, 1)
	create("UIPadding", {
		PaddingTop = UDim.new(0, 13),
		PaddingBottom = UDim.new(0, 13),
		PaddingLeft = UDim.new(0, 15),
		PaddingRight = UDim.new(0, 15),
		Parent = row,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = row,
	})

	local title = nil
	if config.Title then
		title = makeTextLabel(row, {
			Size = UDim2.new(1, 0, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = tostring(config.Title),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 14,
			LayoutOrder = 1,
			ZIndex = 10,
		})
	end

	local content = makeTextLabel(row, {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Enum.Font.Gotham,
		Text = tostring(config.Content or config.Text or ""),
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 13,
		TextWrapped = true,
		LayoutOrder = 2,
		ZIndex = 10,
	})

	local api = {}
	function api:SetTitle(text)
		if title then
			title.Text = tostring(text)
		end
	end
	function api:SetContent(text)
		content.Text = tostring(text)
	end
	function api:SetVisible(visible)
		row.Visible = visible == true
	end
	return attachComponentLifecycle(api, maid, row)
end

function SectionMethods:CreateKeybindPicker(config)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A section ou janela já foi destruída.")
	config = normalizeConfig(config, "Text")
	local window = self._window
	local maid = createComponentMaid(window, self)
	local rowHeight = config.Description and 72 or 58
	local row, rowStroke, rowScale = createBaseRow(self, rowHeight)
	local listening = false
	local bindToWindow = config.BindToWindow ~= false
	local value

	if config.Default ~= nil then
		value = normalizeKeyCode(config.Default)
	elseif bindToWindow then
		value = window:GetKeybind()
	else
		value = nil
	end

	makeTextLabel(row, {
		Position = UDim2.fromOffset(16, config.Description and 9 or 0),
		Size = config.Description and UDim2.new(0.56, -16, 0, 22) or UDim2.new(0.56, -16, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Atalho do menu",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 10,
	})

	if config.Description then
		makeTextLabel(row, {
			Position = UDim2.fromOffset(16, 32),
			Size = UDim2.new(0.56, -16, 0, 28),
			Text = tostring(config.Description),
			TextColor3 = Theme.Subtext,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 11,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 10,
		})
	end

	local pickerButton = makeTextButton(row, {
		Position = UDim2.new(0.56, 0, 0.5, -19),
		Size = UDim2.new(0.44, -16, 0, 38),
		BackgroundColor3 = Theme.Input,
		Text = "",
		TextSize = 13,
		ZIndex = 11,
	})
	addCorner(pickerButton, CONTROL_CORNER_RADIUS)
	local pickerStroke = addStroke(pickerButton, Theme.Stroke, 0.68, 1)

	local pickerLabel = makeTextLabel(pickerButton, {
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 12,
	})

	local api = {}

	local function render()
		if listening then
			pickerLabel.Text = "[ ... ]"
			playTween(pickerLabel, FAST_TWEEN_INFO, { TextColor3 = Theme.AccentHover })
			playTween(pickerStroke, FAST_TWEEN_INFO, {
				Color = Theme.Accent,
				Transparency = 0.18,
			})
			playTween(rowStroke, FAST_TWEEN_INFO, {
				Color = Theme.AccentSoft,
				Transparency = 0.42,
			})
		else
			pickerLabel.Text = "[ " .. getKeyCodeDisplayName(value) .. " ]"
			playTween(pickerLabel, FAST_TWEEN_INFO, {
				TextColor3 = value and Theme.Text or Theme.Subtext,
			})
			playTween(pickerStroke, FAST_TWEEN_INFO, {
				Color = Theme.Stroke,
				Transparency = 0.68,
			})
			playTween(rowStroke, FAST_TWEEN_INFO, {
				Color = Theme.Stroke,
				Transparency = 0.78,
			})
		end
	end

	local function stopListening()
		if not listening then
			return
		end
		listening = false
		if window._activeKeybindPicker == api then
			window._activeKeybindPicker = nil
		end
		render()
	end

	local function setValue(newValue, fireCallback)
		newValue = normalizeKeyCode(newValue)
		value = newValue

		if bindToWindow then
			window:SetKeybind(newValue)
		else
			render()
		end

		if fireCallback ~= false then
			safeCallback(config.Callback, value)
		end
	end

	function api:BeginListening()
		if window._activeKeybindPicker and window._activeKeybindPicker ~= api then
			window._activeKeybindPicker:CancelListening()
		end
		listening = true
		window._activeKeybindPicker = api
		render()
	end

	function api:CancelListening()
		stopListening()
	end

	function api:SetKeybind(newValue, fireCallback)
		stopListening()
		setValue(newValue, fireCallback)
	end

	function api:GetKeybind()
		return value
	end

	function api:SetVisible(visible)
		row.Visible = visible == true
	end

	bindInteractiveSurface(pickerButton, maid, pickerButton, pickerStroke, nil, {
		NormalColor = Theme.Input,
		HoverColor = Theme.InputHover,
		StrokeTransparency = 0.68,
		HoverStrokeTransparency = 0.42,
	})
	maid:Give(pickerButton.MouseButton1Click:Connect(function()
		if listening then
			stopListening()
		else
			api:BeginListening()
		end
	end))

	maid:Give(UserInputService.InputBegan:Connect(function(input)
		if not listening or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == Enum.KeyCode.Unknown then
			return
		end

		window._capturedKeybindInput = input
		local capturedInput = input
		local clearCaptureTaskId
		clearCaptureTaskId = maid:Give(task.defer(function()
			maid:Forget(clearCaptureTaskId)
			if window._capturedKeybindInput == capturedInput then
				window._capturedKeybindInput = nil
			end
		end))

		local capturedKey = input.KeyCode
		if capturedKey == Enum.KeyCode.Backspace or capturedKey == Enum.KeyCode.Delete then
			capturedKey = nil
		end

		stopListening()
		setValue(capturedKey, true)
	end))

	local listenerToken = {}
	window._keybindListeners[listenerToken] = function(newKeybind)
		if bindToWindow then
			value = newKeybind
			render()
		end
	end

	maid:Give(function()
		window._keybindListeners[listenerToken] = nil
		if window._activeKeybindPicker == api then
			window._activeKeybindPicker = nil
		end
		if window._settingsKeybindPicker == api then
			window._settingsKeybindPicker = nil
		end
	end)

	if bindToWindow and config.Default ~= nil then
		window:SetKeybind(value)
	else
		render()
	end

	return attachComponentLifecycle(api, maid, row, stopListening)
end

local TabMethods = {}
TabMethods.__index = TabMethods

function TabMethods:Select()
	self._window:SelectTab(self)
end

function TabMethods:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	local sections = table.clone(self._sections)
	for _, section in ipairs(sections) do
		section:Destroy()
	end

	local window = self._window
	for index, tab in ipairs(window._tabs) do
		if tab == self then
			table.remove(window._tabs, index)
			break
		end
	end

	local wasCurrent = window._currentTab == self
	if wasCurrent then
		window._currentTab = nil
	end

	if window._settingsTab == self then
		window._settingsTab = nil
		window._settingsKeybindPicker = nil
	end

	self._maid:Cleanup()

	if wasCurrent then
		for _, candidate in ipairs(window._tabs) do
			if not candidate._destroyed and not candidate._isSettings then
				window:SelectTab(candidate)
				return
			end
		end
		for _, candidate in ipairs(window._tabs) do
			if not candidate._destroyed then
				window:SelectTab(candidate)
				return
			end
		end
		window._currentTabLabel.Text = ""
	end
end

function TabMethods:CreateSection(name)
	assert(not self._destroyed and not self._window._destroyed, "[SpotifyUI] A tab ou janela já foi destruída.")
	local sectionFrame = create("Frame", {
		Name = "Section",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 6,
		Parent = self._scroll,
	})
	addCorner(sectionFrame, PANEL_CORNER_RADIUS)
	addStroke(sectionFrame, Theme.Stroke, 0.8, 1)
	addGradient(sectionFrame, Color3.fromRGB(27, 27, 27), Color3.fromRGB(22, 22, 22), 90)

	local padding = create("UIPadding", {
		PaddingTop = UDim.new(0, 13),
		PaddingBottom = UDim.new(0, 13),
		PaddingLeft = UDim.new(0, 13),
		PaddingRight = UDim.new(0, 13),
		Parent = sectionFrame,
	})

	local layout = create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sectionFrame,
	})

	if name and tostring(name) ~= "" then
		makeTextLabel(sectionFrame, {
			Name = "SectionTitle",
			Size = UDim2.new(1, 0, 0, 25),
			Font = Enum.Font.GothamBold,
			Text = tostring(name),
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			LayoutOrder = 0,
			ZIndex = 8,
		})
	end

	local section = setmetatable({
		_window = self._window,
		_name = name and tostring(name) or "",
		_tab = self,
		_frame = sectionFrame,
		_content = sectionFrame,
		_padding = padding,
		_layout = layout,
		_componentMaids = {},
		_destroyed = false,
	}, SectionMethods)

	table.insert(self._sections, section)
	return section
end

function TabMethods:_getDefaultSection()
	if not self._defaultSection then
		self._defaultSection = self:CreateSection(nil)
	end
	return self._defaultSection
end

for _, methodName in ipairs({
	"CreateButton",
	"CreateToggle",
	"CreateSlider",
	"CreateDropdown",
	"CreateInput",
	"CreateLabel",
	"CreateParagraph",
	"CreateKeybindPicker",
}) do
	TabMethods[methodName] = function(self, config)
		return self:_getDefaultSection()[methodName](self:_getDefaultSection(), config)
	end
end

local function normalizeSearchText(value)
	local text = string.lower(tostring(value or ""))
	local replacements = {
		["á"] = "a",
		["à"] = "a",
		["â"] = "a",
		["ã"] = "a",
		["ä"] = "a",
		["é"] = "e",
		["è"] = "e",
		["ê"] = "e",
		["ë"] = "e",
		["í"] = "i",
		["ì"] = "i",
		["î"] = "i",
		["ï"] = "i",
		["ó"] = "o",
		["ò"] = "o",
		["ô"] = "o",
		["õ"] = "o",
		["ö"] = "o",
		["ú"] = "u",
		["ù"] = "u",
		["û"] = "u",
		["ü"] = "u",
		["ç"] = "c",
	}
	for accented, plain in pairs(replacements) do
		text = string.gsub(text, accented, plain)
	end
	text = string.gsub(text, "[%c%p]", " ")
	text = string.gsub(text, "%s+", " ")
	return string.gsub(text, "^%s*(.-)%s*$", "%1")
end

local function collectSearchTexts(root)
	local texts = {}
	local seen = {}
	local ignored = {
		["×"] = true,
		["−"] = true,
		["+"] = true,
		["⌄"] = true,
		["›"] = true,
		["✓"] = true,
		["↗"] = true,
	}

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			local text = tostring(descendant.Text or "")
			local normalized = normalizeSearchText(text)
			if normalized ~= "" and not ignored[text] and not seen[normalized] then
				seen[normalized] = true
				table.insert(texts, text)
			end
		end
	end

	return texts
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods

function WindowMethods:_clearSearchResults()
	if self._searchResultsMaid then
		self._searchResultsMaid:Cleanup()
	end
	self._searchResultsMaid = Maid.new()

	if self._searchResultsList then
		for _, child in ipairs(self._searchResultsList:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
	end

	self._searchResultCache = {}
	if self._searchResults then
		self._searchResults.Visible = false
		self._searchResults.Size = UDim2.new(0, self._searchBarWidth or 320, 0, 0)
	end
end

function WindowMethods:_collectSearchResults(query)
	local normalizedQuery = normalizeSearchText(query)
	if normalizedQuery == "" then
		return {}
	end

	local queryTokens = {}
	for token in string.gmatch(normalizedQuery, "%S+") do
		table.insert(queryTokens, token)
	end

	local results = {}
	for _, tab in ipairs(self._tabs) do
		if not tab._destroyed then
			for _, section in ipairs(tab._sections) do
				if not section._destroyed then
					for _, root in ipairs(section._content:GetChildren()) do
						if
							root:IsA("GuiObject")
							and root ~= section._frame:FindFirstChild("SectionTitle")
							and root.Name ~= "SectionTitle"
						then
							local texts = collectSearchTexts(root)
							if #texts > 0 then
								local sectionName = section._name or ""
								local haystack = normalizeSearchText(
									table.concat(texts, " ") .. " " .. tab._name .. " " .. sectionName
								)
								local matches = true
								for _, token in ipairs(queryTokens) do
									if not string.find(haystack, token, 1, true) then
										matches = false
										break
									end
								end

								if matches then
									local title = texts[1]
									local normalizedTitle = normalizeSearchText(title)
									local score = 20
									if normalizedTitle == normalizedQuery then
										score = 120
									elseif string.sub(normalizedTitle, 1, #normalizedQuery) == normalizedQuery then
										score = 90
									elseif string.find(normalizedTitle, normalizedQuery, 1, true) then
										score = 70
									elseif string.find(normalizeSearchText(tab._name), normalizedQuery, 1, true) then
										score = 50
									elseif
										sectionName ~= ""
										and string.find(normalizeSearchText(sectionName), normalizedQuery, 1, true)
									then
										score = 42
									end

									table.insert(results, {
										Title = title,
										Description = texts[2],
										Tab = tab,
										Section = section,
										Root = root,
										Score = score,
									})
								end
							end
						end
					end
				end
			end
		end
	end

	table.sort(results, function(a, b)
		if a.Score == b.Score then
			return tostring(a.Title) < tostring(b.Title)
		end
		return a.Score > b.Score
	end)

	return results
end

function WindowMethods:_activateSearchResult(result)
	if self._destroyed or not result or not result.Tab or result.Tab._destroyed then
		return
	end

	if self._searchBox then
		self._searchBox:ReleaseFocus()
	end
	self:_clearSearchResults()

	if result.Tab._isSettings then
		self:SetSettingsPanelVisible(true)
	else
		self:SelectTab(result.Tab)
	end

	task.defer(function()
		if self._destroyed or not result.Root or not result.Root.Parent then
			return
		end
		local scroll = result.Tab._scroll
		if scroll and scroll.Parent then
			local offset = result.Root.AbsolutePosition.Y - scroll.AbsolutePosition.Y + scroll.CanvasPosition.Y - 14
			scroll.CanvasPosition = Vector2.new(0, math.max(offset, 0))
		end

		if result.Root:IsA("Frame") then
			local originalColor = result.Root.BackgroundColor3
			playTween(result.Root, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.CardHover })
			local resetTaskId
			resetTaskId = self._maid:Give(task.delay(0.32, function()
				self._maid:Forget(resetTaskId)
				if not self._destroyed and result.Root.Parent then
					playTween(result.Root, TWEEN_INFO, { BackgroundColor3 = originalColor })
				end
			end))
		end
	end)
end

function WindowMethods:_renderSearchResults(query)
	if self._destroyed or not self._searchEnabled then
		return
	end

	self:_clearSearchResults()
	local normalizedQuery = normalizeSearchText(query)
	self._searchClearButton.Visible = normalizedQuery ~= ""
	if normalizedQuery == "" then
		return
	end

	local results = self:_collectSearchResults(normalizedQuery)
	self._searchResultCache = results
	local maximum = math.max(tonumber(self._maxSearchResults) or DEFAULT_SEARCH_RESULTS, 1)
	local visibleCount = math.min(#results, maximum)
	local rowHeight = 52
	local panelHeight = math.min(visibleCount * rowHeight + 14, SEARCH_RESULTS_MAX_HEIGHT)

	if visibleCount == 0 then
		local empty = makeTextLabel(self._searchResultsList, {
			Name = "EmptySearch",
			Size = UDim2.new(1, -8, 0, 48),
			Font = Enum.Font.GothamMedium,
			Text = "Nenhum resultado para “" .. tostring(query) .. "”",
			TextColor3 = Theme.Subtext,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 47,
		})
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			Parent = empty,
		})
		visibleCount = 1
		panelHeight = 62
	else
		for index = 1, visibleCount do
			local result = results[index]
			local selectedResult = result
			local row = makeTextButton(self._searchResultsList, {
				Name = "SearchResult",
				Size = UDim2.new(1, -8, 0, 46),
				BackgroundColor3 = Theme.PanelAlt,
				Text = "",
				LayoutOrder = index,
				ZIndex = 47,
			})
			addCorner(row, CONTROL_CORNER_RADIUS)
			local rowStroke = addInsetStroke(row, CONTROL_CORNER_RADIUS, Theme.Stroke, 0.82, 2, 49)

			makeTextLabel(row, {
				Position = UDim2.fromOffset(12, 5),
				Size = UDim2.new(1, -40, 0, 19),
				Font = Enum.Font.GothamMedium,
				Text = tostring(result.Title),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 50,
			})
			local pathText = result.Tab._name
			if result.Section._name and result.Section._name ~= "" then
				pathText ..= "  •  " .. result.Section._name
			end
			makeTextLabel(row, {
				Position = UDim2.fromOffset(12, 24),
				Size = UDim2.new(1, -40, 0, 16),
				Text = pathText,
				TextColor3 = Theme.Subtext,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 10,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 50,
			})
			makeTextLabel(row, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.fromOffset(16, 20),
				Font = Enum.Font.GothamBold,
				Text = "›",
				TextColor3 = Theme.Subtext,
				TextSize = 17,
				ZIndex = 50,
			})

			bindInteractiveSurface(row, self._searchResultsMaid, row, rowStroke, nil, {
				NormalColor = Theme.PanelAlt,
				HoverColor = Theme.CardHover,
				StrokeTransparency = 0.82,
				HoverStrokeTransparency = 0.34,
			})
			self._searchResultsMaid:Give(row.MouseButton1Click:Connect(function()
				self:_activateSearchResult(selectedResult)
			end))
		end
	end

	self._searchResults.Visible = true
	self._searchResults.Size = UDim2.new(0, self._searchBarWidth or 320, 0, panelHeight)
end

function WindowMethods:SetSearchQuery(query)
	if self._destroyed or not self._searchBox then
		return self
	end
	self._searchBox.Text = tostring(query or "")
	self:_renderSearchResults(self._searchBox.Text)
	return self
end

function WindowMethods:GetSearchQuery()
	return self._searchBox and self._searchBox.Text or ""
end

function WindowMethods:FocusSearch()
	if not self._destroyed and self._searchEnabled and self._searchBox then
		self._searchBox:CaptureFocus()
	end
	return self
end

function WindowMethods:SetSearchVisible(visible)
	self._searchEnabled = visible == true
	if self._searchContainer then
		self._searchContainer.Visible = self._searchEnabled
	end
	if not self._searchEnabled then
		self:_clearSearchResults()
	end
	return self
end

function WindowMethods:SetKeybind(keyCode)
	local normalized = normalizeKeyCode(keyCode)
	if keyCode ~= nil and keyCode ~= false and keyCode ~= Enum.KeyCode.Unknown and normalized == nil then
		warn("[SpotifyUI] Keybind inválido:", keyCode)
		return self
	end

	self._keybind = normalized
	for _, listener in pairs(self._keybindListeners) do
		local ok, err = pcall(listener, normalized)
		if not ok then
			warn("[SpotifyUI] Erro ao atualizar Keybind Picker:", err)
		end
	end

	return self
end

function WindowMethods:GetKeybind()
	return self._keybind
end

function WindowMethods:GetSettingsTab()
	return self._settingsTab
end

function WindowMethods:SetGameInfo(config)
	config = config or {}
	if config.Name ~= nil then
		local value = tostring(config.Name)
		for _, label in ipairs({ self._gameNameLabel, self._miniGameNameLabel, self._settingsGameNameLabel }) do
			if label then
				label.Text = value
			end
		end
	end
	if config.Creator ~= nil then
		local value = tostring(config.Creator)
		for _, label in ipairs({ self._gameCreatorLabel, self._miniGameCreatorLabel, self._settingsGameCreatorLabel }) do
			if label then
				label.Text = value
			end
		end
	end
	if config.Icon ~= nil then
		local value = tostring(config.Icon)
		for _, image in ipairs({ self._gameIcon, self._miniGameIcon, self._settingsGameIcon }) do
			if image then
				image.Image = value
			end
		end
	end
	return self
end

function WindowMethods:SetNowPlayingVisible(visible)
	self._nowPlayingVisible = visible == true
	self._nowPlaying.Visible = self._nowPlayingVisible
	self:_updateResponsiveScale()
	return self
end

function WindowMethods:GetSessionElapsed()
	return math.max(0, os.clock() - (self._sessionStartedAt or os.clock()))
end

function WindowMethods:ResetSessionTimer()
	self._sessionStartedAt = os.clock()
	self._sessionLastDisplayedSecond = -1
	self:_updateSessionTimer(0)
	return self
end

function WindowMethods:SetSessionTimerVisible(visible)
	self._sessionTimerVisible = visible == true
	if self._sessionTimerContainer then
		self._sessionTimerContainer.Visible = self._sessionTimerVisible
	end
	for _, item in ipairs({ self._miniSessionTrack, self._miniSessionElapsedLabel, self._miniSessionTotalLabel }) do
		if item then
			item.Visible = self._sessionTimerVisible
		end
	end
	self:_updateResponsiveScale()
	return self
end

function WindowMethods:_updateSessionTimer(elapsed)
	if self._destroyed or not self._sessionTimerFill then
		return
	end

	local currentElapsed = math.max(0, tonumber(elapsed) or self:GetSessionElapsed())
	local duration = self._sessionTimerDuration
	local progress = duration and math.clamp(currentElapsed / duration, 0, 1) or 0

	self._sessionTimerFill.Size = UDim2.new(progress, 0, 1, 0)
	self._sessionTimerKnob.Position = UDim2.new(progress, 0, 0.5, 0)
	self._sessionTimerKnob.Visible = progress > 0.002

	if self._miniSessionFill then
		self._miniSessionFill.Size = UDim2.new(progress, 0, 1, 0)
	end
	if self._miniSessionKnob then
		self._miniSessionKnob.Position = UDim2.new(progress, 0, 0.5, 0)
		self._miniSessionKnob.Visible = progress > 0.002
	end

	local displayedSecond = math.floor(currentElapsed)
	if displayedSecond ~= self._sessionLastDisplayedSecond then
		self._sessionLastDisplayedSecond = displayedSecond
		local formatted = formatElapsedTime(displayedSecond)
		self._sessionElapsedLabel.Text = formatted
		if self._miniSessionElapsedLabel then
			self._miniSessionElapsedLabel.Text = formatted
		end
	end
end

function WindowMethods:_clampToViewport(viewport, effectiveScale)
	local scaledSize = self._baseSize * effectiveScale
	local halfSize = scaledSize / 2
	local position = self._main.Position
	local center = Vector2.new(
		viewport.X * position.X.Scale + position.X.Offset,
		viewport.Y * position.Y.Scale + position.Y.Offset
	)

	local minimumX = math.min(halfSize.X + 6, viewport.X / 2)
	local maximumX = math.max(viewport.X - halfSize.X - 6, viewport.X / 2)
	local minimumY = math.min(halfSize.Y + 6, viewport.Y / 2)
	local maximumY = math.max(viewport.Y - halfSize.Y - 6, viewport.Y / 2)

	center = Vector2.new(math.clamp(center.X, minimumX, maximumX), math.clamp(center.Y, minimumY, maximumY))

	self._main.Position = UDim2.fromScale(center.X / math.max(viewport.X, 1), center.Y / math.max(viewport.Y, 1))
end

function WindowMethods:_clampMiniPlayer(viewport)
	if self._destroyed or not self._miniPlayer then
		return
	end

	local currentViewport = viewport
	if not currentViewport then
		local camera = Workspace.CurrentCamera
		currentViewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	end

	if not self._miniWasDragged then
		self._miniPlayer.AnchorPoint = Vector2.new(1, 1)
		self._miniPlayer.Position = UDim2.new(1, -MINI_PLAYER_MARGIN, 1, -MINI_PLAYER_MARGIN)
		return
	end

	local scale = self._miniEffectiveScale or 1
	local renderedSize = MINI_PLAYER_SIZE * scale
	local position = self._miniPlayer.Position
	local anchor = Vector2.new(
		currentViewport.X * position.X.Scale + position.X.Offset,
		currentViewport.Y * position.Y.Scale + position.Y.Offset
	)

	anchor = Vector2.new(
		math.clamp(anchor.X, renderedSize.X + 6, math.max(renderedSize.X + 6, currentViewport.X - 6)),
		math.clamp(anchor.Y, renderedSize.Y + 6, math.max(renderedSize.Y + 6, currentViewport.Y - 6))
	)

	self._miniPlayer.AnchorPoint = Vector2.new(1, 1)
	self._miniPlayer.Position = UDim2.fromOffset(anchor.X, anchor.Y)
end

function WindowMethods:ResetMiniPlayerPosition()
	self._miniWasDragged = false
	self:_clampMiniPlayer()
	return self
end

function WindowMethods:_syncWindowLayers()
	if self._destroyed then
		return
	end

	local position = self._main.Position
	local size = self._main.Size

	self._outline.Position = position
	self._outline.Size = size

	self._shadow.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 6)
	self._shadow.Size = UDim2.new(size.X.Scale, size.X.Offset + 12, size.Y.Scale, size.Y.Offset + 12)
end

function WindowMethods:_cancelVisibilityTweens()
	if self._visibilityConnection then
		self._visibilityConnection:Disconnect()
		self._visibilityConnection = nil
	end

	for _, tween in pairs(self._visibilityTweens or {}) do
		tween:Cancel()
	end
	self._visibilityTweens = {}
	self._visibilityAnimating = false
end

function WindowMethods:_updateNotificationInset()
	if not self._notificationPadding then
		return
	end
	local bottomInset = 18
	if self._visible and self._minimized then
		bottomInset = math.floor(MINI_PLAYER_MARGIN + MINI_PLAYER_SIZE.Y * (self._miniEffectiveScale or 1) + 12)
	end
	self._notificationPadding.PaddingBottom = UDim.new(0, bottomInset)
end

function WindowMethods:_setLayerVisibility(visible)
	local showMain = visible and not self._minimized
	local showMini = visible and self._minimized

	self._main.Visible = showMain
	self._outline.Visible = showMain
	self._shadow.Visible = showMain
	if self._miniPlayer then
		self._miniPlayer.Visible = showMini
	end
	self._notificationContainer.Visible = visible
	self:_updateNotificationInset()
end

function WindowMethods:_cancelResponsiveTweens()
	for _, tweenKey in ipairs({
		"_responsiveMainTween",
		"_responsiveOutlineTween",
		"_responsiveShadowTween",
		"_responsiveMiniTween",
	}) do
		local tween = self[tweenKey]
		if tween then
			tween:Cancel()
			self[tweenKey] = nil
		end
	end
end

function WindowMethods:SetScale(scale)
	self._userScale = math.clamp(tonumber(scale) or 1, self._minScale, self._maxScale)
	local text = string.format("%d%%", math.floor(self._userScale * 100 + 0.5))
	self._scaleLabel.Text = text
	if self._miniScaleLabel then
		self._miniScaleLabel.Text = text
	end
	self:_updateResponsiveScale(true)
	return self
end

function WindowMethods:GetScale()
	return self._userScale
end

function WindowMethods:GetEffectiveScale()
	if self._minimized and self._miniEffectiveScale then
		return self._miniEffectiveScale
	end
	return self._effectiveScale or self._uiScale.Scale
end

function WindowMethods:SetAutoScale(enabled)
	self._autoScale = enabled == true
	self:_updateResponsiveScale(true)
	return self
end

function WindowMethods:SetSize(width, height)
	local newSize
	if typeof(width) == "Vector2" then
		newSize = width
	else
		newSize = Vector2.new(tonumber(width) or self._baseSize.X, tonumber(height) or self._baseSize.Y)
	end

	self._baseSize = Vector2.new(math.clamp(newSize.X, 720, 1280), math.clamp(newSize.Y, 460, 820))
	self._main.Size = UDim2.fromOffset(self._baseSize.X, self._baseSize.Y)
	self:_syncWindowLayers()
	self:_updateResponsiveScale(true)
	return self
end

function WindowMethods:GetSize()
	return self._baseSize
end

function WindowMethods:SetTitle(title, subtitle)
	self._titleLabel.Text = tostring(title or "Spotify UI")
	if subtitle ~= nil then
		self._subtitleLabel.Text = tostring(subtitle)
	end
	return self
end

function WindowMethods:SetVisible(visible, instant)
	if self._destroyed then
		return self
	end

	local isVisible = visible == true
	if self._visible == isVisible and not self._visibilityAnimating then
		return self
	end
	self._visible = isVisible
	if not isVisible then
		self:_clearSearchResults()
		if self._searchBox then
			self._searchBox:ReleaseFocus()
		end
	end
	self:_cancelVisibilityTweens()
	self:_cancelResponsiveTweens()
	self:_cancelModeTransition()

	if not isVisible and self._activeKeybindPicker then
		self._activeKeybindPicker:CancelListening()
	end

	local animationsEnabled = self._animationsEnabled and instant ~= true
	local mainTargetScale = self._effectiveScale or self._uiScale.Scale
	local miniTargetScale = self._miniEffectiveScale or self._miniScale.Scale

	if not animationsEnabled then
		self:_setLayerVisibility(isVisible)
		self._main.GroupTransparency = isVisible and not self._minimized and 0 or 1
		self._outlineStroke.Transparency = isVisible and not self._minimized and WINDOW_OUTLINE_TRANSPARENCY or 1
		self._shadow.BackgroundTransparency = isVisible and not self._minimized and WINDOW_SHADOW_TRANSPARENCY or 1
		self._miniPlayer.GroupTransparency = isVisible and self._minimized and 0 or 1
		self._uiScale.Scale = mainTargetScale
		self._outlineScale.Scale = mainTargetScale
		self._shadowScale.Scale = mainTargetScale
		self._miniScale.Scale = miniTargetScale
		return self
	end

	self._visibilityAnimating = true
	self:_setLayerVisibility(true)

	if self._minimized then
		self._main.Visible = false
		self._outline.Visible = false
		self._shadow.Visible = false
		self._miniPlayer.Visible = true

		local target = isVisible and miniTargetScale or miniTargetScale * 0.955
		if isVisible then
			self._miniPlayer.GroupTransparency = 1
			self._miniScale.Scale = miniTargetScale * 0.955
		end

		local groupTween = playTween(self._miniPlayer, FADE_TWEEN_INFO, {
			GroupTransparency = isVisible and 0 or 1,
		})
		local scaleTween = playTween(self._miniScale, POP_TWEEN_INFO, { Scale = target })
		self._visibilityTweens = { groupTween, scaleTween }
		local visibilityConnection
		visibilityConnection = groupTween.Completed:Connect(function()
			if visibilityConnection then
				visibilityConnection:Disconnect()
			end
			if self._visibilityConnection == visibilityConnection then
				self._visibilityConnection = nil
			end
			self._visibilityAnimating = false
			self._visibilityTweens = {}
			if self._destroyed then
				return
			end
			if not self._visible then
				self:_setLayerVisibility(false)
			else
				self._miniScale.Scale = miniTargetScale
			end
		end)
		self._visibilityConnection = visibilityConnection
		return self
	end

	local scaleTo = isVisible and mainTargetScale or mainTargetScale * 0.965
	if isVisible then
		self._main.GroupTransparency = 1
		self._outlineStroke.Transparency = 1
		self._shadow.BackgroundTransparency = 1
		self._uiScale.Scale = mainTargetScale * 0.965
		self._outlineScale.Scale = mainTargetScale * 0.965
		self._shadowScale.Scale = mainTargetScale * 0.965
	end

	local groupTween = playTween(self._main, FADE_TWEEN_INFO, {
		GroupTransparency = isVisible and 0 or 1,
	})
	local outlineTween = playTween(self._outlineStroke, FADE_TWEEN_INFO, {
		Transparency = isVisible and WINDOW_OUTLINE_TRANSPARENCY or 1,
	})
	local shadowTween = playTween(self._shadow, FADE_TWEEN_INFO, {
		BackgroundTransparency = isVisible and WINDOW_SHADOW_TRANSPARENCY or 1,
	})
	local mainScaleTween = playTween(self._uiScale, POP_TWEEN_INFO, { Scale = scaleTo })
	local outlineScaleTween = playTween(self._outlineScale, POP_TWEEN_INFO, { Scale = scaleTo })
	local shadowScaleTween = playTween(self._shadowScale, POP_TWEEN_INFO, { Scale = scaleTo })

	self._visibilityTweens = {
		groupTween,
		outlineTween,
		shadowTween,
		mainScaleTween,
		outlineScaleTween,
		shadowScaleTween,
	}

	local visibilityConnection
	visibilityConnection = groupTween.Completed:Connect(function()
		if visibilityConnection then
			visibilityConnection:Disconnect()
		end
		if self._visibilityConnection == visibilityConnection then
			self._visibilityConnection = nil
		end
		self._visibilityAnimating = false
		self._visibilityTweens = {}

		if self._destroyed then
			return
		end

		if not self._visible then
			self:_setLayerVisibility(false)
		else
			self._uiScale.Scale = mainTargetScale
			self._outlineScale.Scale = mainTargetScale
			self._shadowScale.Scale = mainTargetScale
		end
	end)
	self._visibilityConnection = visibilityConnection

	return self
end

function WindowMethods:_cancelModeTransition()
	self._modeTransitionId = (self._modeTransitionId or 0) + 1
	if self._modeMaid then
		self._modeMaid:Cleanup()
	end
	self._modeMaid = Maid.new()
end

function WindowMethods:IsMinimized()
	return self._minimized == true
end

function WindowMethods:SetMinimized(minimized, instant)
	if self._destroyed then
		return self
	end

	local targetMinimized = minimized == true
	if targetMinimized then
		self:_clearSearchResults()
		if self._searchBox then
			self._searchBox:ReleaseFocus()
		end
	end
	if self._minimized == targetMinimized then
		return self
	end

	if targetMinimized and self._settingsPanelOpen then
		self:SetSettingsPanelVisible(false, true)
	end

	self:_cancelVisibilityTweens()
	self:_cancelModeTransition()
	local transitionId = self._modeTransitionId
	self._minimized = targetMinimized
	self:_updateResponsiveScale(false)

	if not self._visible then
		self:_setLayerVisibility(false)
		return self
	end

	local animate = self._animationsEnabled and instant ~= true
	local mainScale = self._effectiveScale or self._uiScale.Scale
	local miniScale = self._miniEffectiveScale or self._miniScale.Scale

	local function transitionIsCurrent()
		return not self._destroyed and self._minimized == targetMinimized and self._modeTransitionId == transitionId
	end

	local function finish()
		if not transitionIsCurrent() then
			return
		end

		self._main.Visible = not targetMinimized
		self._outline.Visible = not targetMinimized
		self._shadow.Visible = not targetMinimized
		self._miniPlayer.Visible = targetMinimized

		self._main.GroupTransparency = targetMinimized and 1 or 0
		self._outlineStroke.Transparency = targetMinimized and 1 or WINDOW_OUTLINE_TRANSPARENCY
		self._shadow.BackgroundTransparency = targetMinimized and 1 or WINDOW_SHADOW_TRANSPARENCY
		self._miniPlayer.GroupTransparency = targetMinimized and 0 or 1

		self._uiScale.Scale = mainScale
		self._outlineScale.Scale = mainScale
		self._shadowScale.Scale = mainScale
		self._miniScale.Scale = miniScale

		if targetMinimized then
			self:_clampMiniPlayer()
		end
		self:_updateNotificationInset()
	end

	if targetMinimized then
		-- Esconde todas as camadas da janela no mesmo frame. Nenhum filho fica
		-- visível sozinho enquanto o mini player aparece.
		self._main.Visible = false
		self._outline.Visible = false
		self._shadow.Visible = false
		self._main.GroupTransparency = 1
		self._outlineStroke.Transparency = 1
		self._shadow.BackgroundTransparency = 1

		self:_clampMiniPlayer()
		self._miniPlayer.Visible = true
		self._miniPlayer.GroupTransparency = animate and 1 or 0
		self._miniScale.Scale = animate and (miniScale * 0.9) or miniScale

		if not animate then
			finish()
			return self
		end

		local fadeTween = playTween(self._miniPlayer, FAST_TWEEN_INFO, {
			GroupTransparency = 0,
		})
		local scaleTween = playTween(self._miniScale, POP_TWEEN_INFO, {
			Scale = miniScale,
		})
		self._modeMaid:Give(fadeTween)
		self._modeMaid:Give(scaleTween)

		local connection
		connection = scaleTween.Completed:Connect(function()
			if connection then
				connection:Disconnect()
			end
			finish()
		end)
		self._modeMaid:Give(connection)
	else
		-- O popup sai inteiro e a janela volta inteira no mesmo frame. A única
		-- animação restante é um pequeno pop de escala, sem fade desencontrado.
		self._miniPlayer.Visible = false
		self._miniPlayer.GroupTransparency = 1

		self._main.Visible = true
		self._outline.Visible = true
		self._shadow.Visible = true
		self._main.GroupTransparency = 0
		self._outlineStroke.Transparency = WINDOW_OUTLINE_TRANSPARENCY
		self._shadow.BackgroundTransparency = WINDOW_SHADOW_TRANSPARENCY

		local startScale = animate and (mainScale * 0.97) or mainScale
		self._uiScale.Scale = startScale
		self._outlineScale.Scale = startScale
		self._shadowScale.Scale = startScale

		if not animate then
			finish()
			return self
		end

		local mainTween = playTween(self._uiScale, POP_TWEEN_INFO, { Scale = mainScale })
		local outlineTween = playTween(self._outlineScale, POP_TWEEN_INFO, { Scale = mainScale })
		local shadowTween = playTween(self._shadowScale, POP_TWEEN_INFO, { Scale = mainScale })
		self._modeMaid:Give(mainTween)
		self._modeMaid:Give(outlineTween)
		self._modeMaid:Give(shadowTween)

		local connection
		connection = mainTween.Completed:Connect(function()
			if connection then
				connection:Disconnect()
			end
			finish()
		end)
		self._modeMaid:Give(connection)
	end

	return self
end

function WindowMethods:ToggleMinimized()
	self:SetMinimized(not self._minimized)
	return self._minimized
end

function WindowMethods:_setSettingsTabVisual(open)
	local tab = self._settingsTab
	if not tab or tab._destroyed then
		return
	end
	playTween(tab._button, FAST_TWEEN_INFO, {
		BackgroundColor3 = open and Theme.Selected or Theme.Sidebar,
	})
	playTween(tab._label, FAST_TWEEN_INFO, {
		TextColor3 = open and Theme.Text or Theme.Subtext,
	})
	playTween(tab._indicator, FAST_TWEEN_INFO, {
		BackgroundTransparency = open and 0 or 1,
		Size = open and UDim2.fromOffset(3, 24) or UDim2.fromOffset(3, 14),
		Position = open and UDim2.fromOffset(0, 9) or UDim2.fromOffset(0, 14),
	})
	playTween(tab._stroke, FAST_TWEEN_INFO, {
		Color = open and Theme.AccentSoft or Theme.Stroke,
		Transparency = open and 0.72 or 1,
	})
	if tab._iconIsImage then
		playTween(tab._icon, FAST_TWEEN_INFO, { ImageColor3 = open and Theme.Text or tab._iconColor })
	else
		playTween(tab._icon, FAST_TWEEN_INFO, { TextColor3 = open and Theme.Text or tab._iconColor })
	end
end

function WindowMethods:IsSettingsPanelVisible()
	return self._settingsPanelOpen == true
end

function WindowMethods:SetSettingsPanelVisible(visible, instant)
	if self._destroyed or not self._settingsPanel then
		return self
	end

	local open = visible == true
	if open then
		self:_clearSearchResults()
		if self._searchBox then
			self._searchBox:ReleaseFocus()
		end
	end
	if open and self._minimized then
		self:SetMinimized(false, true)
	end
	if self._settingsPanelOpen == open and self._settingsPanel.Visible == open then
		return self
	end

	self._settingsPanelOpen = open
	self:_setSettingsTabVisual(open)

	if self._settingsPanelConnection then
		self._settingsPanelConnection:Disconnect()
		self._settingsPanelConnection = nil
	end
	for _, key in ipairs({ "_settingsPanelTween", "_settingsBackdropTween" }) do
		if self[key] then
			self[key]:Cancel()
			self[key] = nil
		end
	end

	local panelWidth = self._settingsPanelWidth or SETTINGS_PANEL_MAX_WIDTH
	local shownPosition = UDim2.new(1, -(panelWidth + 8), 0, 8)
	local hiddenPosition = UDim2.new(1, 8, 0, 8)
	local animate = self._animationsEnabled and instant ~= true and self._visible

	if not animate then
		self._settingsBackdrop.Visible = open
		self._settingsBackdrop.BackgroundTransparency = 1
		self._settingsPanel.Visible = open
		self._settingsPanel.Position = open and shownPosition or hiddenPosition
		return self
	end

	self._settingsBackdrop.Visible = true
	self._settingsPanel.Visible = true
	if open then
		self._settingsPanel.Position = hiddenPosition
	end

	self._settingsBackdropTween = playTween(self._settingsBackdrop, FAST_TWEEN_INFO, {
		BackgroundTransparency = 1,
	})
	self._settingsPanelTween = playTween(self._settingsPanel, TWEEN_INFO, {
		Position = open and shownPosition or hiddenPosition,
	})

	local activeTween = self._settingsPanelTween
	local completionConnection
	completionConnection = activeTween.Completed:Connect(function(playbackState)
		if completionConnection then
			completionConnection:Disconnect()
		end
		if self._settingsPanelConnection == completionConnection then
			self._settingsPanelConnection = nil
			self._settingsPanelTween = nil
			self._settingsBackdropTween = nil
		end
		if self._destroyed or playbackState == Enum.PlaybackState.Cancelled then
			return
		end
		if not self._settingsPanelOpen then
			self._settingsBackdrop.Visible = false
			self._settingsPanel.Visible = false
		end
	end)
	self._settingsPanelConnection = completionConnection
	return self
end

function WindowMethods:ToggleSettingsPanel()
	self:SetSettingsPanelVisible(not self._settingsPanelOpen)
	return self._settingsPanelOpen
end

function WindowMethods:ToggleVisible()
	local isVisible = not self._visible
	self:SetVisible(isVisible)
	return isVisible
end

function WindowMethods:_updateResponsiveScale(animated)
	if self._destroyed then
		return
	end

	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local margin = self._viewportMargin
	local fitX = math.max((viewport.X - margin * 2) / self._baseSize.X, 0.25)
	local fitY = math.max((viewport.Y - margin * 2) / self._baseSize.Y, 0.25)
	local fitScale = math.min(fitX, fitY, self._maxAutoScale)
	local effectiveScale = self._autoScale and math.min(self._userScale, fitScale) or self._userScale
	effectiveScale = math.clamp(effectiveScale, 0.25, self._maxScale)
	self._effectiveScale = effectiveScale

	local miniFitX = math.max((viewport.X - MINI_PLAYER_MARGIN * 2) / MINI_PLAYER_SIZE.X, 0.25)
	local miniFitY = math.max((viewport.Y - MINI_PLAYER_MARGIN * 2) / MINI_PLAYER_SIZE.Y, 0.25)
	local miniFitScale = math.min(miniFitX, miniFitY, self._maxAutoScale)
	local miniEffectiveScale = self._autoScale and math.min(self._userScale, miniFitScale) or self._userScale
	miniEffectiveScale = math.clamp(miniEffectiveScale, 0.25, self._maxScale)
	self._miniEffectiveScale = miniEffectiveScale

	if not self._visibilityAnimating then
		if animated and self._animationsEnabled and self._visible then
			replaceTween(
				self,
				"_responsiveMainTween",
				playTween(self._uiScale, TWEEN_INFO, {
					Scale = effectiveScale,
				})
			)
			replaceTween(
				self,
				"_responsiveOutlineTween",
				playTween(self._outlineScale, TWEEN_INFO, {
					Scale = effectiveScale,
				})
			)
			replaceTween(
				self,
				"_responsiveShadowTween",
				playTween(self._shadowScale, TWEEN_INFO, {
					Scale = effectiveScale,
				})
			)
			replaceTween(
				self,
				"_responsiveMiniTween",
				playTween(self._miniScale, TWEEN_INFO, {
					Scale = miniEffectiveScale,
				})
			)
		else
			self._uiScale.Scale = effectiveScale
			self._outlineScale.Scale = effectiveScale
			self._shadowScale.Scale = effectiveScale
			self._miniScale.Scale = miniEffectiveScale
		end
	end
	self._notificationScale.Scale = 1

	local logicalViewportWidth = viewport.X / math.max(effectiveScale, 0.01)
	local compact = logicalViewportWidth < 820
	local sidebarWidth = compact and 184 or math.clamp(self._baseSize.X * 0.225, 198, 224)
	local nowPlayingHeight = 0
	if self._nowPlayingVisible then
		nowPlayingHeight = self._sessionTimerVisible and NOW_PLAYING_HEIGHT or NOW_PLAYING_COMPACT_HEIGHT
	end

	self._sidebar.Size = UDim2.new(0, sidebarWidth, 1, -nowPlayingHeight)
	self._content.Position = UDim2.fromOffset(sidebarWidth, 0)
	self._content.Size = UDim2.new(1, -sidebarWidth, 1, -nowPlayingHeight)
	self._nowPlaying.Position = UDim2.new(0, 0, 1, -nowPlayingHeight)
	self._nowPlaying.Size = UDim2.new(1, 0, 0, nowPlayingHeight)
	self._sidebarDivider.Position = UDim2.fromOffset(sidebarWidth - 1, 0)
	self._sidebarDivider.Size = UDim2.new(0, 1, 1, -nowPlayingHeight)
	self._sidebarBottomPatch.Visible = self._nowPlayingVisible

	if self._sessionTimerVisible then
		self._gameStatus.AnchorPoint = Vector2.new(1, 0)
		self._gameStatus.Position = UDim2.new(1, -18, 0, 18)
	else
		self._gameStatus.AnchorPoint = Vector2.new(1, 0.5)
		self._gameStatus.Position = UDim2.new(1, -18, 0.5, 0)
	end

	local windowLogicalWidth = self._baseSize.X
	local showGameStatus = self._nowPlayingVisible and windowLogicalWidth >= 860
	self._gameStatus.Visible = showGameStatus
	self._scaleControls.Visible = self._nowPlayingVisible
	local gameTextWidth = math.max(math.floor(windowLogicalWidth * 0.5 - 190), 118)
	self._gameNameLabel.Size = UDim2.fromOffset(gameTextWidth, 25)
	self._gameCreatorLabel.Size = UDim2.fromOffset(gameTextWidth, 20)

	local contentLogicalWidth = math.max(self._baseSize.X - sidebarWidth, 240)
	local panelWidth = math.clamp(
		contentLogicalWidth * (compact and 0.72 or 0.46),
		math.min(SETTINGS_PANEL_MIN_WIDTH, contentLogicalWidth - 16),
		math.min(SETTINGS_PANEL_MAX_WIDTH, contentLogicalWidth - 16)
	)
	self._settingsPanelWidth = panelWidth
	self._settingsViewport.Position = UDim2.fromOffset(0, 0)
	self._settingsViewport.Size = UDim2.fromScale(1, 1)
	self._settingsBackdrop.Size = UDim2.fromScale(1, 1)
	self._settingsPanel.Size = UDim2.new(0, panelWidth, 1, -16)
	self._settingsPanel.Position = self._settingsPanelOpen and UDim2.new(1, -(panelWidth + 8), 0, 8)
		or UDim2.new(1, 8, 0, 8)

	local showTopbarTitle = contentLogicalWidth >= 650
	self._currentTabLabel.Visible = showTopbarTitle
	self._topbarAccent.Visible = showTopbarTitle
	local searchWidth = math.clamp(contentLogicalWidth - 180, 160, 360)
	local searchOffset = showTopbarTitle and 12 or -12
	self._searchBarWidth = searchWidth
	self._searchContainer.Position = UDim2.new(0.5, searchOffset, 0.5, 0)
	self._searchContainer.Size = UDim2.fromOffset(searchWidth, SEARCH_BAR_HEIGHT)
	self._searchResults.Position = UDim2.new(0.5, searchOffset, 0, TOPBAR_HEIGHT - 2)
	if self._searchResults.Visible then
		self._searchResults.Size = UDim2.new(0, searchWidth, 0, self._searchResults.Size.Y.Offset)
	else
		self._searchResults.Size = UDim2.new(0, searchWidth, 0, 0)
	end

	self:_syncWindowLayers()
	self:_clampToViewport(viewport, effectiveScale)
	self:_clampMiniPlayer(viewport)
	self:_updateNotificationInset()
end

function WindowMethods:_bindCurrentCamera()
	self._cameraMaid:Cleanup()
	self._cameraMaid = Maid.new()

	local camera = Workspace.CurrentCamera
	if camera then
		self._cameraMaid:Give(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			self:_updateResponsiveScale()
		end))
	end

	self:_updateResponsiveScale()
end

function WindowMethods:CreateTab(nameOrConfig, iconOverride)
	assert(not self._destroyed, "[SpotifyUI] A janela já foi destruída.")
	local tabConfig = normalizeTabConfig(nameOrConfig, iconOverride)
	local tabName = tabConfig.Name
	local isSettings = tabConfig.IsSettings == true

	if
		not tabConfig._Internal
		and string.lower(tabName) == "settings"
		and self._settingsTab
		and not self._settingsTab._destroyed
	then
		return self._settingsTab
	end

	local tabMaid = createComponentMaid(self)
	local buttonParent = isSettings and self._settingsTabsContainer or self._tabsContainer
	local tabButton = makeTextButton(buttonParent, {
		Name = "TabButton_" .. tabName,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Sidebar,
		Text = "",
		LayoutOrder = isSettings and 1 or (#self._tabs + 1),
		ZIndex = 6,
	})
	addCorner(tabButton, CONTROL_CORNER_RADIUS)
	-- O contorno fica 2 px para dentro. Assim o UIStroke de 2 px não é
	-- cortado pelo container da sidebar nem pelo tween de escala do botão.
	local tabStroke, tabBorder = addInsetStroke(tabButton, CONTROL_CORNER_RADIUS, Theme.Stroke, 1, 2, 7)
	local tabScale = create("UIScale", {
		Scale = 1,
		Parent = tabButton,
	})

	local indicator = create("Frame", {
		Position = UDim2.fromOffset(0, 9),
		Size = UDim2.fromOffset(3, 24),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = tabButton,
	})
	addCorner(indicator, 2)

	local tabIcon
	local iconIsImage = isImageIcon(tabConfig.Icon)
	if iconIsImage then
		tabIcon = create("ImageLabel", {
			Name = "Icon",
			Position = UDim2.fromOffset(14, 11),
			Size = UDim2.fromOffset(20, 20),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = tostring(tabConfig.Icon),
			ImageColor3 = tabConfig.IconColor or Theme.Subtext,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 8,
			Parent = tabButton,
		})
	else
		tabIcon = makeTextLabel(tabButton, {
			Name = "Icon",
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.fromOffset(24, 42),
			Font = Enum.Font.GothamBold,
			Text = tostring(tabConfig.Icon or "•"),
			TextColor3 = tabConfig.IconColor or Theme.Subtext,
			TextSize = 17,
			ZIndex = 8,
		})
	end

	local tabLabel = makeTextLabel(tabButton, {
		Position = UDim2.fromOffset(44, 0),
		Size = UDim2.new(1, -56, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = tabName,
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 8,
	})

	local pageParent = isSettings and self._settingsPageContainer or self._pageContainer
	local page = create("CanvasGroup", {
		Name = "Page_" .. tabName,
		Position = isSettings and UDim2.fromOffset(0, 0) or UDim2.fromOffset(0, 8),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		GroupTransparency = isSettings and 0 or 1,
		Visible = isSettings,
		ZIndex = isSettings and 64 or 5,
		Parent = pageParent,
	})

	local scroll = create("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, -8, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = Theme.Subtext,
		ScrollBarImageTransparency = 0.58,
		ScrollBarThickness = 3,
		ZIndex = isSettings and 64 or 5,
		Parent = page,
	})
	create("UIPadding", {
		PaddingTop = UDim.new(0, isSettings and 8 or 14),
		PaddingBottom = UDim.new(0, 18),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 10),
		Parent = scroll,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroll,
	})

	local tab = setmetatable({
		_window = self,
		_name = tabName,
		_button = tabButton,
		_indicator = indicator,
		_icon = tabIcon,
		_iconIsImage = iconIsImage,
		_iconColor = tabConfig.IconColor or Theme.Subtext,
		_label = tabLabel,
		_stroke = tabStroke,
		_border = tabBorder,
		_scale = tabScale,
		_page = page,
		_scroll = scroll,
		_sections = {},
		_maid = tabMaid,
		_isSettings = isSettings,
		_destroyed = false,
	}, TabMethods)

	tabMaid:Give(tabButton)
	tabMaid:Give(page)

	local function setIconColor(color)
		if tab._iconIsImage then
			tab._icon.ImageColor3 = color
		else
			tab._icon.TextColor3 = color
		end
	end

	tabMaid:Give(tabButton.MouseEnter:Connect(function()
		if self._currentTab ~= tab and not (isSettings and self._settingsPanelOpen) then
			playTween(tabButton, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Card })
			playTween(tabLabel, FAST_TWEEN_INFO, { TextColor3 = Theme.Text })
			playTween(tabStroke, FAST_TWEEN_INFO, {
				Color = Theme.Stroke,
				Transparency = 0.78,
			})
			playTween(tabScale, FAST_TWEEN_INFO, { Scale = 1 })
			setIconColor(Theme.Text)
		end
	end))

	tabMaid:Give(tabButton.MouseLeave:Connect(function()
		if self._currentTab ~= tab and not (isSettings and self._settingsPanelOpen) then
			playTween(tabButton, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Sidebar })
			playTween(tabLabel, FAST_TWEEN_INFO, { TextColor3 = Theme.Subtext })
			playTween(tabStroke, FAST_TWEEN_INFO, { Transparency = 1 })
			playTween(tabScale, FAST_TWEEN_INFO, { Scale = 1 })
			setIconColor(tabConfig.IconColor or Theme.Subtext)
		end
	end))

	tabMaid:Give(tabButton.MouseButton1Down:Connect(function()
		playTween(tabScale, FAST_TWEEN_INFO, { Scale = 0.985 })
	end))
	tabMaid:Give(tabButton.MouseButton1Up:Connect(function()
		playTween(tabScale, FAST_TWEEN_INFO, { Scale = 1 })
	end))
	tabMaid:Give(tabButton.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end))

	table.insert(self._tabs, tab)
	if isSettings then
		self._settingsTab = tab
	elseif not self._currentTab then
		self:SelectTab(tab)
	end
	return tab
end

function WindowMethods:SelectTab(tabOrName)
	local target = nil
	if type(tabOrName) == "string" then
		for _, tab in ipairs(self._tabs) do
			if tab._name == tabOrName then
				target = tab
				break
			end
		end
	else
		target = tabOrName
	end

	if not target or target._window ~= self or target._destroyed then
		return false
	end

	if target._isSettings then
		self:SetSettingsPanelVisible(true)
		return true
	end

	if self._settingsPanelOpen then
		self:SetSettingsPanelVisible(false)
	end

	for _, tab in ipairs(self._tabs) do
		if not tab._destroyed and not tab._isSettings then
			local selected = tab == target
			tab._page.Visible = selected

			if selected then
				tab._page.GroupTransparency = self._animationsEnabled and 1 or 0
				tab._page.Position = self._animationsEnabled and UDim2.fromOffset(0, 9) or UDim2.fromOffset(0, 0)
				if self._animationsEnabled then
					playTween(tab._page, FADE_TWEEN_INFO, {
						GroupTransparency = 0,
						Position = UDim2.fromOffset(0, 0),
					})
				end
			end

			playTween(tab._button, FAST_TWEEN_INFO, {
				BackgroundColor3 = selected and Theme.Selected or Theme.Sidebar,
			})
			playTween(tab._label, FAST_TWEEN_INFO, {
				TextColor3 = selected and Theme.Text or Theme.Subtext,
			})
			playTween(tab._indicator, FAST_TWEEN_INFO, {
				BackgroundTransparency = selected and 0 or 1,
				Size = selected and UDim2.fromOffset(3, 24) or UDim2.fromOffset(3, 14),
				Position = selected and UDim2.fromOffset(0, 9) or UDim2.fromOffset(0, 14),
			})
			playTween(tab._stroke, FAST_TWEEN_INFO, {
				Color = selected and Theme.AccentSoft or Theme.Stroke,
				Transparency = selected and 0.72 or 1,
			})
			playTween(tab._scale, FAST_TWEEN_INFO, { Scale = 1 })

			if tab._iconIsImage then
				playTween(tab._icon, FAST_TWEEN_INFO, {
					ImageColor3 = selected and Theme.Text or tab._iconColor,
				})
			else
				playTween(tab._icon, FAST_TWEEN_INFO, {
					TextColor3 = selected and Theme.Text or tab._iconColor,
				})
			end
		end
	end

	self._currentTab = target
	self._currentTabLabel.Text = target._name
	self._topbarAccent.Size = UDim2.fromOffset(12, 2)
	self._topbarAccent.BackgroundTransparency = 0.72
	playTween(self._topbarAccent, POP_TWEEN_INFO, {
		Size = UDim2.fromOffset(34, 2),
		BackgroundTransparency = 0.16,
	})
	return true
end

function WindowMethods:_createSettingsTab()
	if self._settingsTab and not self._settingsTab._destroyed then
		return self._settingsTab
	end

	local settingsTab = self:CreateTab({
		Name = "Settings",
		Icon = "⚙",
		IsSettings = true,
		_Internal = true,
	})

	local shortcutsSection = settingsTab:CreateSection("Interface")
	self._settingsKeybindPicker = shortcutsSection:CreateKeybindPicker({
		Text = "Abrir / fechar menu",
		Description = "Clique e pressione uma tecla. Backspace ou Delete remove o atalho.",
		BindToWindow = true,
	})

	return settingsTab
end

function WindowMethods:Notify(config)
	config = normalizeConfig(config, "Content")
	if self._destroyed then
		return nil
	end

	local toastMaid = Maid.new()
	local rootTaskId = self._maid:Give(toastMaid)
	local dismissed = false
	local duration = math.max(tonumber(config.Duration) or 4, 0.5)
	local toastHeight = config.Title and 96 or 78

	self._notificationCounter += 1

	-- O layout move apenas o slot. A notificação anima dentro dele, então o
	-- UIListLayout nunca disputa a propriedade Position com os tweens.
	local slot = create("Frame", {
		Name = "NotificationSlot",
		Size = UDim2.fromOffset(326, toastHeight + 8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		LayoutOrder = self._notificationCounter,
		ZIndex = 201,
		Parent = self._notificationContainer,
	})
	toastMaid:Give(slot)

	-- CanvasGroup transparente apenas para animação de posição e opacidade.
	-- A superfície visual fica separada, impedindo que ClipsDescendants corte
	-- o UIStroke ou transforme os cantos arredondados em cantos quadrados.
	local toast = create("CanvasGroup", {
		Name = "Notification",
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		GroupTransparency = 1,
		ZIndex = 202,
		Parent = slot,
	})

	local shadow = create("Frame", {
		Name = "Shadow",
		Position = UDim2.fromOffset(3, 6),
		Size = UDim2.new(1, -6, 1, -8),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.52,
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = toast,
	})
	addCorner(shadow, PANEL_CORNER_RADIUS + 1)

	local surface = create("Frame", {
		Name = "Surface",
		Position = UDim2.fromOffset(3, 2),
		Size = UDim2.new(1, -6, 1, -8),
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 203,
		Parent = toast,
	})
	addCorner(surface, PANEL_CORNER_RADIUS)
	addGradient(surface, Color3.fromRGB(27, 27, 27), Color3.fromRGB(18, 18, 18), 90)
	addStroke(surface, Theme.Stroke, 0.18, 2)

	local accent = create("Frame", {
		Position = UDim2.fromOffset(10, 12),
		Size = UDim2.new(0, 3, 1, -24),
		BackgroundColor3 = config.Color or Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 204,
		Parent = surface,
	})
	addCorner(accent, 2)

	local y = 12
	if config.Title then
		makeTextLabel(surface, {
			Position = UDim2.fromOffset(24, y),
			Size = UDim2.new(1, -62, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = tostring(config.Title),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 205,
		})
		y = 38
	end

	makeTextLabel(surface, {
		Position = UDim2.fromOffset(24, y),
		Size = UDim2.new(1, -62, 0, config.Title and 38 or 44),
		Text = tostring(config.Content or config.Text or "Notificação"),
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 12,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 205,
	})

	local closeButton = makeTextButton(surface, {
		Position = UDim2.new(1, -36, 0, 8),
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Theme.Subtext,
		TextSize = 13,
		ZIndex = 207,
	})

	local progressTrack = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -9),
		Size = UDim2.new(1, -24, 0, 2),
		BackgroundColor3 = Theme.Track,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 205,
		Parent = surface,
	})
	addCorner(progressTrack, 1)

	local progress = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = config.Color or Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 206,
		Parent = progressTrack,
	})
	addCorner(progress, 1)

	local function dismiss()
		if dismissed then
			return
		end
		dismissed = true

		local tween = playTween(toast, FADE_TWEEN_INFO, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(30, 0),
		})
		toastMaid:Give(tween)
		toastMaid:Give(tween.Completed:Connect(function()
			self._maid:Forget(rootTaskId)
			toastMaid:Cleanup()
		end))
	end

	toastMaid:Give(closeButton.MouseButton1Click:Connect(dismiss))
	toastMaid:Give(closeButton.MouseEnter:Connect(function()
		playTween(closeButton, FAST_TWEEN_INFO, { TextColor3 = Theme.Text })
	end))
	toastMaid:Give(closeButton.MouseLeave:Connect(function()
		playTween(closeButton, FAST_TWEEN_INFO, { TextColor3 = Theme.Subtext })
	end))

	toastMaid:Give(playTween(toast, POP_TWEEN_INFO, {
		GroupTransparency = 0,
		Position = UDim2.fromOffset(0, 0),
	}))
	toastMaid:Give(playTween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 1, 0),
	}))
	toastMaid:Give(task.delay(duration, dismiss))

	return {
		Dismiss = dismiss,
	}
end

function WindowMethods:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	self._cameraMaid:Cleanup()
	if self._modeMaid then
		self._modeMaid:Cleanup()
	end
	if self._settingsPanelConnection then
		self._settingsPanelConnection:Disconnect()
		self._settingsPanelConnection = nil
	end
	self._maid:Cleanup()

	if self._screenGui then
		self._screenGui:Destroy()
	end

	Library._windows[self] = nil
	if Library._lastWindow == self then
		Library._lastWindow = nil
		for remainingWindow in pairs(Library._windows) do
			Library._lastWindow = remainingWindow
			break
		end
	end
end

function Library:CreateWindow(config)
	config = config or {}
	self._windowCounter += 1

	local parent = getPlayerGui(config.Parent)
	local maid = Maid.new()
	local cameraMaid = Maid.new()
	local minScale = tonumber(config.MinScale) or 0.65
	local maxScale = tonumber(config.MaxScale) or 1.5
	if maxScale < minScale then
		minScale, maxScale = maxScale, minScale
	end
	minScale = math.max(minScale, 0.25)
	maxScale = math.max(maxScale, minScale)

	local baseSize = config.Size or Vector2.new(940, 590)
	if typeof(baseSize) ~= "Vector2" then
		baseSize = Vector2.new(940, 590)
	end
	baseSize = Vector2.new(math.clamp(baseSize.X, 720, 1280), math.clamp(baseSize.Y, 460, 820))
	local sessionTimerVisible = config.ShowSessionTimer ~= false
	local sessionTimerDuration
	if config.SessionTimerDuration == false then
		sessionTimerDuration = nil
	else
		sessionTimerDuration = math.max(tonumber(config.SessionTimerDuration) or 3600, 1)
	end
	local initialNowPlayingHeight = 0
	if config.ShowNowPlaying ~= false then
		initialNowPlayingHeight = sessionTimerVisible and NOW_PLAYING_HEIGHT or NOW_PLAYING_COMPACT_HEIGHT
	end

	local initialKeybind
	if config.Keybind == nil then
		initialKeybind = Enum.KeyCode.RightShift
	else
		initialKeybind = normalizeKeyCode(config.Keybind)
		if config.Keybind ~= false and config.Keybind ~= Enum.KeyCode.Unknown and initialKeybind == nil then
			warn("[SpotifyUI] Keybind inicial inválido; usando RightShift.")
			initialKeybind = Enum.KeyCode.RightShift
		end
	end

	local screenGui = create("ScreenGui", {
		Name = config.Name or ("SpotifyUI_%d"):format(self._windowCounter),
		IgnoreGuiInset = false,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = config.DisplayOrder or 50,
		Parent = parent,
	})

	local shadow = create("Frame", {
		Name = "WindowShadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 6),
		Size = UDim2.fromOffset(baseSize.X + 12, baseSize.Y + 12),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = screenGui,
	})
	addCorner(shadow, WINDOW_CORNER_RADIUS + 5)

	-- O contorno fica em uma camada própria, exatamente do tamanho da janela.
	-- Isso evita a moldura preenchida e espessuras irregulares.
	local outline = create("Frame", {
		Name = "WindowOutline",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(baseSize.X, baseSize.Y),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 90,
		Parent = screenGui,
	})
	addCorner(outline, WINDOW_CORNER_RADIUS)
	local outlineStroke = addStroke(outline, Theme.Outline, 1, 1)

	local main = create("CanvasGroup", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(baseSize.X, baseSize.Y),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		GroupTransparency = 1,
		ZIndex = 3,
		Parent = screenGui,
	})
	addCorner(main, WINDOW_CORNER_RADIUS)
	addGradient(main, Color3.fromRGB(18, 18, 18), Color3.fromRGB(12, 12, 12), 90)

	local uiScale = create("UIScale", {
		Scale = 1,
		Parent = main,
	})
	local outlineScale = create("UIScale", {
		Scale = 1,
		Parent = outline,
	})
	local shadowScale = create("UIScale", {
		Scale = 1,
		Parent = shadow,
	})

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 220, 1, -initialNowPlayingHeight),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = main,
	})

	-- ClipsDescendants usa um recorte retangular. As superfícies abaixo pintam
	-- somente os cantos externos corretos, sem depender de clipping arredondado.
	local sidebarSurface = create("Frame", {
		Name = "Surface",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = sidebar,
	})
	addCorner(sidebarSurface, WINDOW_CORNER_RADIUS)
	create("Frame", {
		Name = "SquareRight",
		Position = UDim2.new(1, -WINDOW_CORNER_RADIUS, 0, 0),
		Size = UDim2.new(0, WINDOW_CORNER_RADIUS, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = sidebarSurface,
	})
	local sidebarBottomPatch = create("Frame", {
		Name = "SquareBottom",
		Position = UDim2.new(0, 0, 1, -WINDOW_CORNER_RADIUS),
		Size = UDim2.new(1, 0, 0, WINDOW_CORNER_RADIUS),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Visible = config.ShowNowPlaying ~= false,
		ZIndex = 3,
		Parent = sidebarSurface,
	})

	local titleLabel = makeTextLabel(sidebar, {
		Position = UDim2.fromOffset(18, 17),
		Size = UDim2.new(1, -36, 0, 27),
		Font = Enum.Font.GothamBold,
		Text = tostring(config.Title or "Spotify UI"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 20,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 5,
	})

	local subtitleLabel = makeTextLabel(sidebar, {
		Position = UDim2.fromOffset(18, 46),
		Size = UDim2.new(1, -36, 0, 18),
		Text = tostring(config.Subtitle or "Roblox UI Library"),
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 5,
	})

	local tabsContainer = create("ScrollingFrame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(12, SIDEBAR_HEADER_HEIGHT),
		Size = UDim2.new(1, -24, 1, -(SIDEBAR_HEADER_HEIGHT + SETTINGS_AREA_HEIGHT)),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = Theme.Subtext,
		ScrollBarImageTransparency = 0.68,
		ScrollBarThickness = 2,
		ZIndex = 5,
		Parent = sidebar,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabsContainer,
	})

	create("Frame", {
		Name = "SettingsDivider",
		Position = UDim2.new(0, 16, 1, -64),
		Size = UDim2.new(1, -32, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.48,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = sidebar,
	})

	local settingsTabsContainer = create("Frame", {
		Name = "SettingsTab",
		Position = UDim2.new(0, 12, 1, -54),
		Size = UDim2.new(1, -24, 0, 42),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = sidebar,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = settingsTabsContainer,
	})

	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(220, 0),
		Size = UDim2.new(1, -220, 1, -initialNowPlayingHeight),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = main,
	})

	local sidebarDivider = create("Frame", {
		Name = "SidebarDivider",
		Position = UDim2.fromOffset(219, 0),
		Size = UDim2.new(0, 1, 1, -initialNowPlayingHeight),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.58,
		BorderSizePixel = 0,
		ZIndex = 19,
		Parent = main,
	})

	local topbar = create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = content,
	})
	local topbarSurface = create("Frame", {
		Name = "Surface",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.BackgroundAlt,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = topbar,
	})
	addCorner(topbarSurface, WINDOW_CORNER_RADIUS)
	create("Frame", {
		Name = "SquareLeft",
		Size = UDim2.new(0, WINDOW_CORNER_RADIUS, 1, 0),
		BackgroundColor3 = Theme.BackgroundAlt,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = topbarSurface,
	})
	create("Frame", {
		Name = "SquareBottom",
		Position = UDim2.new(0, 0, 1, -WINDOW_CORNER_RADIUS),
		Size = UDim2.new(1, 0, 0, WINDOW_CORNER_RADIUS),
		BackgroundColor3 = Theme.BackgroundAlt,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = topbarSurface,
	})
	create("Frame", {
		Name = "BottomDivider",
		Position = UDim2.new(0, 14, 1, -1),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = topbar,
	})

	local currentTabLabel = makeTextLabel(topbar, {
		Position = UDim2.fromOffset(18, -3),
		Size = UDim2.fromOffset(156, TOPBAR_HEIGHT),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 19,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 5,
	})

	local topbarAccent = create("Frame", {
		Position = UDim2.fromOffset(18, TOPBAR_HEIGHT - 13),
		Size = UDim2.fromOffset(34, 2),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.16,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = topbar,
	})
	addCorner(topbarAccent, 1)

	local initialSearchWidth = math.clamp(baseSize.X * 0.34, 250, 360)
	local searchContainer = create("Frame", {
		Name = "SearchBar",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, -18, 0.5, 0),
		Size = UDim2.fromOffset(initialSearchWidth, SEARCH_BAR_HEIGHT),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = config.ShowSearch ~= false,
		ZIndex = 10,
		Parent = topbar,
	})
	addCorner(searchContainer, SEARCH_BAR_HEIGHT / 2)
	local searchStroke = addInsetStroke(searchContainer, SEARCH_BAR_HEIGHT / 2, Theme.Stroke, 0.62, 2, 11)
	addGradient(searchContainer, Color3.fromRGB(40, 40, 40), Color3.fromRGB(31, 31, 31), 90)

	local searchIcon = makeTextLabel(searchContainer, {
		Position = UDim2.fromOffset(13, 0),
		Size = UDim2.fromOffset(24, SEARCH_BAR_HEIGHT),
		Font = Enum.Font.GothamBold,
		Text = "⌕",
		TextColor3 = Theme.Subtext,
		TextSize = 18,
		ZIndex = 12,
	})

	local searchBox = create("TextBox", {
		Name = "SearchInput",
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -78, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		PlaceholderColor3 = Theme.Subtext,
		PlaceholderText = tostring(config.SearchPlaceholder or "O que você quer encontrar?"),
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 12,
		Parent = searchContainer,
	})

	local searchClearButton = makeTextButton(searchContainer, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -9, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Theme.Subtext,
		TextSize = 13,
		Visible = false,
		ZIndex = 13,
	})

	local searchResults = create("Frame", {
		Name = "SearchResults",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, -18, 0, TOPBAR_HEIGHT - 2),
		Size = UDim2.fromOffset(initialSearchWidth, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 45,
		Parent = content,
	})
	addCorner(searchResults, PANEL_CORNER_RADIUS)
	addInsetStroke(searchResults, PANEL_CORNER_RADIUS, Theme.Outline, 0.32, 2, 48)
	addGradient(searchResults, Color3.fromRGB(27, 27, 27), Color3.fromRGB(18, 18, 18), 90)

	local searchResultsList = create("ScrollingFrame", {
		Name = "Results",
		Position = UDim2.fromOffset(7, 7),
		Size = UDim2.new(1, -14, 1, -14),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = Theme.Subtext,
		ScrollBarImageTransparency = 0.55,
		ScrollBarThickness = 2,
		ZIndex = 46,
		Parent = searchResults,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = searchResultsList,
	})

	local dragHandle = create("Frame", {
		Name = "DragHandle",
		Size = UDim2.new(1, -104, 1, 0),
		BackgroundTransparency = 1,
		Active = true,
		ZIndex = 6,
		Parent = topbar,
	})

	local scaleMinus = makeTextButton(topbar, {
		Position = UDim2.new(1, -190, 0.5, -16),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = Theme.Card,
		Text = "−",
		TextSize = 17,
		Visible = false,
		ZIndex = 7,
	})
	addCorner(scaleMinus, 16)
	local scaleMinusStroke = addStroke(scaleMinus, Theme.Stroke, 0.78, 1)
	local scaleMinusScale = create("UIScale", { Scale = 1, Parent = scaleMinus })

	local scaleLabel = makeTextLabel(topbar, {
		Position = UDim2.new(1, -154, 0.5, -16),
		Size = UDim2.fromOffset(56, 32),
		Font = Enum.Font.GothamBold,
		Text = "100%",
		TextColor3 = Theme.Subtext,
		TextSize = 11,
		Visible = false,
		ZIndex = 7,
	})

	local scalePlus = makeTextButton(topbar, {
		Position = UDim2.new(1, -94, 0.5, -16),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = Theme.Card,
		Text = "+",
		TextSize = 16,
		Visible = false,
		ZIndex = 7,
	})
	addCorner(scalePlus, 16)
	local scalePlusStroke = addStroke(scalePlus, Theme.Stroke, 0.78, 1)
	local scalePlusScale = create("UIScale", { Scale = 1, Parent = scalePlus })

	local minimizeButton = makeTextButton(topbar, {
		Position = UDim2.new(1, -90, 0.5, -16),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = Theme.Card,
		Text = "−",
		TextColor3 = Theme.Subtext,
		TextSize = 16,
		ZIndex = 7,
	})
	addCorner(minimizeButton, 16)
	local minimizeStroke = addStroke(minimizeButton, Theme.Stroke, 0.78, 2)
	local minimizeScale = create("UIScale", { Scale = 1, Parent = minimizeButton })

	local closeButton = makeTextButton(topbar, {
		Position = UDim2.new(1, -50, 0.5, -16),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = Theme.Card,
		Text = "×",
		TextColor3 = Theme.Subtext,
		TextSize = 13,
		ZIndex = 7,
	})
	addCorner(closeButton, 16)
	local closeStroke = addStroke(closeButton, Theme.Stroke, 0.78, 1)
	local closeScale = create("UIScale", { Scale = 1, Parent = closeButton })

	local pageContainer = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(0, TOPBAR_HEIGHT),
		Size = UDim2.new(1, -4, 1, -TOPBAR_HEIGHT),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 4,
		Parent = content,
	})

	local nowPlaying = create("Frame", {
		Name = "NowPlaying",
		Position = UDim2.new(0, 0, 1, -initialNowPlayingHeight),
		Size = UDim2.new(1, 0, 0, initialNowPlayingHeight),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = config.ShowNowPlaying ~= false,
		ZIndex = 20,
		Parent = main,
	})
	local nowPlayingSurface = create("Frame", {
		Name = "Surface",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 20,
		Parent = nowPlaying,
	})
	addCorner(nowPlayingSurface, WINDOW_CORNER_RADIUS)
	create("Frame", {
		Name = "SquareTop",
		Size = UDim2.new(1, 0, 0, WINDOW_CORNER_RADIUS),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 20,
		Parent = nowPlayingSurface,
	})

	create("Frame", {
		Name = "TopDivider",
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.42,
		BorderSizePixel = 0,
		ZIndex = 21,
		Parent = nowPlaying,
	})

	-- Os controles de escala saem da topbar e ocupam a área central da barra
	-- inferior, seguindo a hierarquia visual dos controles de reprodução do
	-- Spotify: diminuir à esquerda, valor atual no centro e aumentar à direita.
	local scaleControls = create("Frame", {
		Name = "ScaleControls",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromOffset(178, 42),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 23,
		Parent = nowPlaying,
	})

	scaleMinus.Parent = scaleControls
	scaleMinus.Position = UDim2.fromOffset(4, 4)
	scaleMinus.Size = UDim2.fromOffset(34, 34)
	scaleMinus.BackgroundColor3 = Theme.PanelAlt
	scaleMinus.TextColor3 = Theme.Subtext
	scaleMinus.ZIndex = 24

	scaleLabel.Parent = scaleControls
	scaleLabel.Position = UDim2.fromOffset(54, 4)
	scaleLabel.Size = UDim2.fromOffset(70, 34)
	scaleLabel.BackgroundColor3 = Theme.Text
	scaleLabel.BackgroundTransparency = 0
	scaleLabel.TextColor3 = Theme.Background
	scaleLabel.TextSize = 11
	scaleLabel.ZIndex = 24
	addCorner(scaleLabel, 17)
	addStroke(scaleLabel, Theme.Stroke, 0.7, 2)

	scalePlus.Parent = scaleControls
	scalePlus.Position = UDim2.fromOffset(140, 4)
	scalePlus.Size = UDim2.fromOffset(34, 34)
	scalePlus.BackgroundColor3 = Theme.PanelAlt
	scalePlus.TextColor3 = Theme.Subtext
	scalePlus.ZIndex = 24

	local gameIconHolder = create("Frame", {
		Name = "GameIconHolder",
		Position = UDim2.fromOffset(14, 11),
		Size = UDim2.fromOffset(60, 60),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 21,
		Parent = nowPlaying,
	})
	addCorner(gameIconHolder, CARD_CORNER_RADIUS)
	addStroke(gameIconHolder, Theme.Stroke, 0.62, 1)
	local gameIconScale = create("UIScale", { Scale = 1, Parent = gameIconHolder })

	makeTextLabel(gameIconHolder, {
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		Text = "◇",
		TextColor3 = Theme.Subtext,
		TextSize = 22,
		ZIndex = 21,
	})

	local defaultIcon = ""
	if game.GameId > 0 then
		defaultIcon = string.format("rbxthumb://type=GameIcon&id=%d&w=150&h=150", game.GameId)
	end

	local gameIcon = create("ImageLabel", {
		Name = "GameIcon",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = tostring(config.GameIcon or defaultIcon),
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 22,
		Parent = gameIconHolder,
	})

	local gameNameLabel = makeTextLabel(nowPlaying, {
		Name = "GameName",
		Position = UDim2.fromOffset(88, 15),
		Size = UDim2.new(0.5, -190, 0, 25),
		Font = Enum.Font.GothamBold,
		Text = tostring(config.GameName or game.Name or "Experiência Roblox"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 22,
	})

	local gameCreatorLabel = makeTextLabel(nowPlaying, {
		Name = "GameCreator",
		Position = UDim2.fromOffset(88, 42),
		Size = UDim2.new(0.5, -190, 0, 20),
		Text = tostring(config.GameCreator or "Criador do jogo"),
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 22,
	})

	local gameStatus = makeTextButton(nowPlaying, {
		AnchorPoint = sessionTimerVisible and Vector2.new(1, 0) or Vector2.new(1, 0.5),
		Position = sessionTimerVisible and UDim2.new(1, -18, 0, 18) or UDim2.new(1, -18, 0.5, 0),
		Size = UDim2.fromOffset(142, 34),
		BackgroundColor3 = Theme.Card,
		Text = "",
		ZIndex = 21,
	})
	addCorner(gameStatus, 17)
	local gameStatusStroke = addStroke(gameStatus, Theme.Stroke, 0.8, 1)
	local gameStatusScale = create("UIScale", { Scale = 1, Parent = gameStatus })

	local statusPulse = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(17, 17),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.AccentHover,
		BackgroundTransparency = 0.62,
		BorderSizePixel = 0,
		ZIndex = 21,
		Parent = gameStatus,
	})
	addCorner(statusPulse, 9)

	local pulseTween =
		playTween(statusPulse, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false), {
			Size = UDim2.fromOffset(18, 18),
			BackgroundTransparency = 1,
		})
	maid:Give(pulseTween)

	local statusDot = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(17, 17),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.AccentHover,
		BorderSizePixel = 0,
		ZIndex = 22,
		Parent = gameStatus,
	})
	addCorner(statusDot, 4)

	makeTextLabel(gameStatus, {
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.new(1, -38, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = "Experiência atual",
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 22,
	})

	local sessionTimerContainer = create("Frame", {
		Name = "SessionTimer",
		Position = UDim2.fromOffset(88, 68),
		Size = UDim2.new(1, -106, 0, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = sessionTimerVisible,
		ZIndex = 22,
		Parent = nowPlaying,
	})

	local sessionTimerTrack = create("Frame", {
		Name = "Track",
		Position = UDim2.fromOffset(0, 3),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = Theme.Track,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		Active = true,
		ZIndex = 22,
		Parent = sessionTimerContainer,
	})
	addCorner(sessionTimerTrack, 3)

	local sessionTimerFill = create("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 23,
		Parent = sessionTimerTrack,
	})
	addCorner(sessionTimerFill, 3)
	addGradient(sessionTimerFill, Theme.Accent, Theme.AccentHover, 0)

	local sessionTimerKnob = create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(9, 9),
		BackgroundColor3 = Theme.Text,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 24,
		Parent = sessionTimerTrack,
	})
	addCorner(sessionTimerKnob, 5)
	addStroke(sessionTimerKnob, Theme.Shadow, 0.66, 1)

	local sessionElapsedLabel = makeTextLabel(sessionTimerContainer, {
		Name = "Elapsed",
		Position = UDim2.fromOffset(0, 11),
		Size = UDim2.fromOffset(94, 17),
		Font = Enum.Font.GothamMedium,
		Text = "0:00",
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 10,
		ZIndex = 23,
	})

	makeTextLabel(sessionTimerContainer, {
		Name = "Caption",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 11),
		Size = UDim2.fromOffset(150, 17),
		Font = Enum.Font.GothamMedium,
		Text = tostring(config.SessionTimerText or "Tempo aberto"),
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 23,
	})

	maid:Give(sessionTimerTrack.MouseEnter:Connect(function()
		playTween(sessionTimerTrack, FAST_TWEEN_INFO, {
			Position = UDim2.fromOffset(0, 2),
			Size = UDim2.new(1, 0, 0, 6),
			BackgroundTransparency = 0.04,
		})
		playTween(sessionTimerKnob, FAST_TWEEN_INFO, {
			Size = UDim2.fromOffset(11, 11),
			BackgroundTransparency = 0,
		})
	end))
	maid:Give(sessionTimerTrack.MouseLeave:Connect(function()
		playTween(sessionTimerTrack, FAST_TWEEN_INFO, {
			Position = UDim2.fromOffset(0, 3),
			Size = UDim2.new(1, 0, 0, 4),
			BackgroundTransparency = 0.18,
		})
		playTween(sessionTimerKnob, FAST_TWEEN_INFO, {
			Size = UDim2.fromOffset(9, 9),
			BackgroundTransparency = 0.08,
		})
	end))

	bindInteractiveSurface(gameStatus, maid, gameStatus, gameStatusStroke, gameStatusScale, {
		NormalColor = Theme.Card,
		HoverColor = Theme.CardHover,
		StrokeTransparency = 0.8,
		HoverStrokeTransparency = 0.5,
	})
	maid:Give(gameIconHolder.MouseEnter:Connect(function()
		playTween(gameIconScale, FAST_TWEEN_INFO, { Scale = 1.035 })
	end))
	maid:Give(gameIconHolder.MouseLeave:Connect(function()
		playTween(gameIconScale, FAST_TWEEN_INFO, { Scale = 1 })
	end))

	-- Painel lateral inspirado no painel "Now Playing" do Spotify desktop.
	-- Ele vive dentro da área de conteúdo, entra pela direita e não atravessa a janela.
	local settingsViewport = create("Frame", {
		Name = "SettingsViewport",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 51,
		Parent = content,
	})

	local settingsBackdrop = makeTextButton(settingsViewport, {
		Name = "SettingsBackdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 1,
		Text = "",
		Visible = false,
		ZIndex = 52,
	})

	local initialSettingsWidth =
		math.clamp((baseSize.X - 220) * 0.46, SETTINGS_PANEL_MIN_WIDTH, SETTINGS_PANEL_MAX_WIDTH)
	local settingsPanel = create("Frame", {
		Name = "SettingsPanel",
		Position = UDim2.new(1, 8, 0, 8),
		Size = UDim2.new(0, initialSettingsWidth, 1, -16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		Visible = false,
		ZIndex = 60,
		Parent = settingsViewport,
	})

	local settingsShadow = create("Frame", {
		Name = "Shadow",
		Position = UDim2.fromOffset(-5, 5),
		Size = UDim2.new(1, 5, 1, -2),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.46,
		BorderSizePixel = 0,
		ZIndex = 59,
		Parent = settingsPanel,
	})
	addCorner(settingsShadow, PANEL_CORNER_RADIUS + 3)

	local settingsSurface = create("Frame", {
		Name = "Surface",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.BackgroundAlt,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		ZIndex = 60,
		Parent = settingsPanel,
	})
	addCorner(settingsSurface, PANEL_CORNER_RADIUS + 2)
	addGradient(settingsSurface, Color3.fromRGB(24, 24, 24), Color3.fromRGB(13, 13, 13), 90)

	local settingsBorder = create("Frame", {
		Name = "Border",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 78,
		Parent = settingsSurface,
	})
	addCorner(settingsBorder, PANEL_CORNER_RADIUS)
	addStroke(settingsBorder, Theme.Outline, 0.26, 2)

	local settingsHeader = create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 62,
		Parent = settingsSurface,
	})

	makeTextLabel(settingsHeader, {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -62, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "Settings",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 64,
	})

	local settingsCloseButton = makeTextButton(settingsHeader, {
		Position = UDim2.new(1, -44, 0.5, -15),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Card,
		Text = "×",
		TextColor3 = Theme.Subtext,
		TextSize = 13,
		ZIndex = 65,
	})
	addCorner(settingsCloseButton, 15)
	local settingsCloseStroke = addStroke(settingsCloseButton, Theme.Stroke, 0.72, 2)
	local settingsCloseScale = create("UIScale", { Scale = 1, Parent = settingsCloseButton })

	create("Frame", {
		Position = UDim2.new(0, 12, 1, -1),
		Size = UDim2.new(1, -24, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.52,
		BorderSizePixel = 0,
		ZIndex = 64,
		Parent = settingsHeader,
	})

	local settingsHero = create("Frame", {
		Name = "GameHero",
		Position = UDim2.fromOffset(12, 66),
		Size = UDim2.new(1, -24, 0, 174),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 62,
		Parent = settingsSurface,
	})
	addCorner(settingsHero, PANEL_CORNER_RADIUS)
	addInsetStroke(settingsHero, PANEL_CORNER_RADIUS, Theme.Stroke, 0.62, 2, 67)

	local settingsGameIcon = create("ImageLabel", {
		Name = "GameImage",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = tostring(config.GameIcon or defaultIcon),
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 63,
		Parent = settingsHero,
	})

	local settingsHeroOverlay = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.32,
		BorderSizePixel = 0,
		ZIndex = 64,
		Parent = settingsHero,
	})
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 22)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.72),
			NumberSequenceKeypoint.new(0.48, 0.54),
			NumberSequenceKeypoint.new(1, 0.04),
		}),
		Rotation = 90,
		Parent = settingsHeroOverlay,
	})

	makeTextLabel(settingsHero, {
		Position = UDim2.fromOffset(13, 11),
		Size = UDim2.new(1, -26, 0, 17),
		Font = Enum.Font.GothamMedium,
		Text = "●  Experiência atual",
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 9,
		ZIndex = 66,
	})

	local settingsGameNameLabel = makeTextLabel(settingsHero, {
		Position = UDim2.new(0, 14, 1, -55),
		Size = UDim2.new(1, -28, 0, 24),
		Font = Enum.Font.GothamBold,
		Text = tostring(config.GameName or game.Name or "Experiência Roblox"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 66,
	})
	local settingsGameCreatorLabel = makeTextLabel(settingsHero, {
		Position = UDim2.new(0, 14, 1, -31),
		Size = UDim2.new(1, -28, 0, 18),
		Font = Enum.Font.GothamMedium,
		Text = tostring(config.GameCreator or "Criador do jogo"),
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 66,
	})

	makeTextLabel(settingsSurface, {
		Position = UDim2.fromOffset(14, 250),
		Size = UDim2.new(1, -28, 0, 24),
		Font = Enum.Font.GothamBold,
		Text = "Configurações",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		ZIndex = 64,
	})

	local settingsPageContainer = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(0, 278),
		Size = UDim2.new(1, 0, 1, -286),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 63,
		Parent = settingsSurface,
	})

	-- Mini player compacto, ancorado no canto inferior direito e arrastável.
	-- A escala é compartilhada com a janela principal.
	local miniPlayer = create("CanvasGroup", {
		Name = "MiniPlayer",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -MINI_PLAYER_MARGIN, 1, -MINI_PLAYER_MARGIN),
		Size = UDim2.fromOffset(MINI_PLAYER_SIZE.X, MINI_PLAYER_SIZE.Y),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 120,
		Parent = screenGui,
	})
	local miniScale = create("UIScale", { Scale = 1, Parent = miniPlayer })

	local miniShadow = create("Frame", {
		Position = UDim2.fromOffset(3, 5),
		Size = UDim2.new(1, -6, 1, -2),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.48,
		BorderSizePixel = 0,
		ZIndex = 120,
		Parent = miniPlayer,
	})
	addCorner(miniShadow, 18)

	local miniSurface = create("ImageLabel", {
		Name = "Surface",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Image = tostring(config.GameIcon or defaultIcon),
		ImageTransparency = 0.03,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 121,
		Parent = miniPlayer,
	})
	addCorner(miniSurface, 16)

	local miniDarkOverlay = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		ZIndex = 122,
		Parent = miniSurface,
	})

	addCorner(miniDarkOverlay, 16)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 3, 3)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.18),
			NumberSequenceKeypoint.new(0.55, 0.34),
			NumberSequenceKeypoint.new(1, 0.04),
		}),
		Rotation = 90,
		Parent = miniDarkOverlay,
	})
	local miniBorder = create("Frame", {
		Name = "Border",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 140,
		Parent = miniSurface,
	})
	addCorner(miniBorder, 14)
	addStroke(miniBorder, Theme.Outline, 0.16, 2)

	local miniDragHandle = create("Frame", {
		Name = "DragHandle",
		Size = UDim2.new(1, 0, 0, 98),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 124,
		Parent = miniSurface,
	})

	local miniGameIcon = miniSurface
	makeTextLabel(miniSurface, {
		Position = UDim2.fromOffset(14, 9),
		Size = UDim2.new(1, -58, 0, 14),
		Font = Enum.Font.GothamMedium,
		Text = "●  Experiência em execução",
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 9,
		ZIndex = 125,
	})

	local expandButton = makeTextButton(miniSurface, {
		Position = UDim2.new(1, -38, 0, 8),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 0.16,
		Text = "↗",
		TextColor3 = Theme.Text,
		TextSize = 13,
		ZIndex = 128,
	})
	addCorner(expandButton, 13)
	local expandStroke = addStroke(expandButton, Theme.Text, 0.68, 2)
	local expandScale = create("UIScale", { Scale = 1, Parent = expandButton })

	local miniGameNameLabel = makeTextLabel(miniSurface, {
		Position = UDim2.fromOffset(14, 34),
		Size = UDim2.new(1, -62, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = tostring(config.GameName or game.Name or "Experiência Roblox"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 125,
	})
	local miniGameCreatorLabel = makeTextLabel(miniSurface, {
		Position = UDim2.fromOffset(14, 55),
		Size = UDim2.new(1, -28, 0, 15),
		Font = Enum.Font.GothamMedium,
		Text = tostring(config.GameCreator or "Criador do jogo"),
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 125,
	})

	local miniSessionTrack = create("Frame", {
		Position = UDim2.fromOffset(14, 82),
		Size = UDim2.new(1, -28, 0, 4),
		BackgroundColor3 = Color3.fromRGB(190, 190, 190),
		BackgroundTransparency = 0.34,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 125,
		Parent = miniSurface,
	})
	addCorner(miniSessionTrack, 2)
	local miniSessionFill = create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Text,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ZIndex = 126,
		Parent = miniSessionTrack,
	})
	addCorner(miniSessionFill, 2)
	local miniSessionKnob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(11, 11),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 127,
		Parent = miniSessionTrack,
	})
	addCorner(miniSessionKnob, 6)
	addStroke(miniSessionKnob, Theme.Shadow, 0.5, 2)

	local miniSessionElapsedLabel = makeTextLabel(miniSurface, {
		Position = UDim2.fromOffset(14, 89),
		Size = UDim2.fromOffset(92, 16),
		Font = Enum.Font.GothamMedium,
		Text = "0:00",
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 8,
		ZIndex = 125,
	})
	local miniSessionTotalLabel = makeTextLabel(miniSurface, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 89),
		Size = UDim2.fromOffset(100, 16),
		Font = Enum.Font.GothamMedium,
		Text = sessionTimerDuration and formatElapsedTime(sessionTimerDuration) or "Sem limite",
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 8,
		ZIndex = 125,
	})

	local miniControls = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 111),
		Size = UDim2.fromOffset(150, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 125,
		Parent = miniSurface,
	})
	local miniScaleMinus = makeTextButton(miniControls, {
		Position = UDim2.fromOffset(3, 5),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 0.14,
		Text = "−",
		TextColor3 = Theme.Text,
		TextSize = 17,
		ZIndex = 127,
	})
	addCorner(miniScaleMinus, 15)
	local miniScaleMinusStroke = addStroke(miniScaleMinus, Theme.Text, 0.74, 2)
	local miniScaleMinusScale = create("UIScale", { Scale = 1, Parent = miniScaleMinus })

	local miniScaleLabel = makeTextLabel(miniControls, {
		Position = UDim2.fromOffset(54, 0),
		Size = UDim2.fromOffset(42, 40),
		BackgroundColor3 = Theme.Text,
		BackgroundTransparency = 0,
		Font = Enum.Font.GothamBold,
		Text = "100%",
		TextColor3 = Theme.Background,
		TextSize = 10,
		ZIndex = 127,
	})
	addCorner(miniScaleLabel, 20)
	addStroke(miniScaleLabel, Theme.Text, 0.18, 2)

	local miniScalePlus = makeTextButton(miniControls, {
		Position = UDim2.fromOffset(117, 5),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Color3.fromRGB(22, 22, 22),
		BackgroundTransparency = 0.14,
		Text = "+",
		TextColor3 = Theme.Text,
		TextSize = 16,
		ZIndex = 127,
	})
	addCorner(miniScalePlus, 15)
	local miniScalePlusStroke = addStroke(miniScalePlus, Theme.Text, 0.74, 2)
	local miniScalePlusScale = create("UIScale", { Scale = 1, Parent = miniScalePlus })

	-- Container ocupa toda a tela; o layout ancora os toasts no canto inferior
	-- direito e empilha novas notificações para cima.
	local notificationContainer = create("Frame", {
		Name = "Notifications",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 200,
		Parent = screenGui,
	})
	local notificationPadding = create("UIPadding", {
		PaddingTop = UDim.new(0, 18),
		PaddingBottom = UDim.new(0, 18),
		PaddingLeft = UDim.new(0, 18),
		PaddingRight = UDim.new(0, 18),
		Parent = notificationContainer,
	})
	local notificationScale = create("UIScale", {
		Scale = 1,
		Parent = notificationContainer,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Parent = notificationContainer,
	})

	local window = setmetatable({
		_maid = maid,
		_cameraMaid = cameraMaid,
		_modeMaid = Maid.new(),
		_modeTransitionId = 0,
		_screenGui = screenGui,
		_shadow = shadow,
		_shadowScale = shadowScale,
		_outline = outline,
		_outlineStroke = outlineStroke,
		_outlineScale = outlineScale,
		_main = main,
		_uiScale = uiScale,
		_sidebar = sidebar,
		_sidebarBottomPatch = sidebarBottomPatch,
		_sidebarDivider = sidebarDivider,
		_content = content,
		_titleLabel = titleLabel,
		_subtitleLabel = subtitleLabel,
		_tabsContainer = tabsContainer,
		_settingsTabsContainer = settingsTabsContainer,
		_currentTabLabel = currentTabLabel,
		_topbarAccent = topbarAccent,
		_searchContainer = searchContainer,
		_searchStroke = searchStroke,
		_searchIcon = searchIcon,
		_searchBox = searchBox,
		_searchClearButton = searchClearButton,
		_searchResults = searchResults,
		_searchResultsList = searchResultsList,
		_searchResultsMaid = Maid.new(),
		_searchEnabled = config.ShowSearch ~= false,
		_searchBarWidth = initialSearchWidth,
		_maxSearchResults = math.max(tonumber(config.MaxSearchResults) or DEFAULT_SEARCH_RESULTS, 1),
		_pageContainer = pageContainer,
		_settingsPageContainer = settingsPageContainer,
		_settingsViewport = settingsViewport,
		_settingsBackdrop = settingsBackdrop,
		_settingsPanel = settingsPanel,
		_settingsPanelOpen = false,
		_settingsPanelWidth = initialSettingsWidth,
		_settingsGameIcon = settingsGameIcon,
		_settingsGameNameLabel = settingsGameNameLabel,
		_settingsGameCreatorLabel = settingsGameCreatorLabel,
		_scaleLabel = scaleLabel,
		_scaleControls = scaleControls,
		_nowPlaying = nowPlaying,
		_gameIcon = gameIcon,
		_gameNameLabel = gameNameLabel,
		_gameCreatorLabel = gameCreatorLabel,
		_gameStatus = gameStatus,
		_sessionTimerContainer = sessionTimerContainer,
		_sessionTimerFill = sessionTimerFill,
		_sessionTimerKnob = sessionTimerKnob,
		_sessionElapsedLabel = sessionElapsedLabel,
		_miniPlayer = miniPlayer,
		_miniScale = miniScale,
		_miniGameIcon = miniGameIcon,
		_miniGameNameLabel = miniGameNameLabel,
		_miniGameCreatorLabel = miniGameCreatorLabel,
		_miniSessionTrack = miniSessionTrack,
		_miniSessionFill = miniSessionFill,
		_miniSessionKnob = miniSessionKnob,
		_miniSessionElapsedLabel = miniSessionElapsedLabel,
		_miniSessionTotalLabel = miniSessionTotalLabel,
		_miniScaleLabel = miniScaleLabel,
		_miniWasDragged = false,
		_sessionStartedAt = os.clock(),
		_sessionTimerDuration = sessionTimerDuration,
		_sessionTimerVisible = sessionTimerVisible,
		_sessionLastDisplayedSecond = -1,
		_nowPlayingVisible = config.ShowNowPlaying ~= false,
		_notificationContainer = notificationContainer,
		_notificationPadding = notificationPadding,
		_notificationScale = notificationScale,
		_notificationCounter = 0,
		_tabs = {},
		_currentTab = nil,
		_settingsTab = nil,
		_keybind = initialKeybind,
		_keybindListeners = {},
		_activeKeybindPicker = nil,
		_capturedKeybindInput = nil,
		_baseSize = baseSize,
		_userScale = math.clamp(tonumber(config.Scale) or 1, minScale, maxScale),
		_minScale = minScale,
		_maxScale = maxScale,
		_autoScale = config.AutoScale ~= false,
		_maxAutoScale = math.max(tonumber(config.MaxAutoScale) or 1.2, 0.25),
		_viewportMargin = tonumber(config.ViewportMargin) or 20,
		_closeBehavior = config.CloseBehavior == "Destroy" and "Destroy" or "Hide",
		_animationsEnabled = config.Animations ~= false,
		_visible = false,
		_minimized = config.Minimized == true,
		_visibilityAnimating = false,
		_visibilityTweens = {},
		_visibilityConnection = nil,
		_effectiveScale = 1,
		_miniEffectiveScale = 1,
		_destroyed = false,
	}, WindowMethods)

	local function elevateSettingsDescendant(descendant)
		if descendant == settingsShadow then
			return
		end
		if descendant:IsA("GuiObject") and descendant.ZIndex < 60 then
			descendant.ZIndex += 60
		end
	end
	for _, descendant in ipairs(settingsPanel:GetDescendants()) do
		elevateSettingsDescendant(descendant)
	end
	maid:Give(settingsPanel.DescendantAdded:Connect(elevateSettingsDescendant))

	-- Mantém contorno e sombra sincronizados sem depender de UIStroke no frame recortado.
	maid:Give(main:GetPropertyChangedSignal("Position"):Connect(function()
		window:_syncWindowLayers()
	end))
	maid:Give(main:GetPropertyChangedSignal("Size"):Connect(function()
		window:_syncWindowLayers()
	end))
	maid:Give(function()
		window:_cancelVisibilityTweens()
		window:_cancelResponsiveTweens()
		if window._modeMaid then
			window._modeMaid:Cleanup()
		end
		if window._searchResultsMaid then
			window._searchResultsMaid:Cleanup()
		end
		if window._settingsPanelConnection then
			window._settingsPanelConnection:Disconnect()
			window._settingsPanelConnection = nil
		end
		for _, key in ipairs({ "_settingsPanelTween", "_settingsBackdropTween" }) do
			if window[key] then
				window[key]:Cancel()
				window[key] = nil
			end
		end
	end)

	maid:Give(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		window:_renderSearchResults(searchBox.Text)
	end))
	maid:Give(searchBox.Focused:Connect(function()
		playTween(searchContainer, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.InputHover })
		playTween(searchStroke, FAST_TWEEN_INFO, {
			Color = Theme.Text,
			Transparency = 0.22,
		})
		playTween(searchIcon, FAST_TWEEN_INFO, { TextColor3 = Theme.Text })
		window:_renderSearchResults(searchBox.Text)
	end))
	maid:Give(searchBox.FocusLost:Connect(function(enterPressed)
		playTween(searchContainer, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Input })
		playTween(searchStroke, FAST_TWEEN_INFO, {
			Color = Theme.Stroke,
			Transparency = 0.62,
		})
		playTween(searchIcon, FAST_TWEEN_INFO, { TextColor3 = Theme.Subtext })
		if enterPressed and window._searchResultCache and window._searchResultCache[1] then
			window:_activateSearchResult(window._searchResultCache[1])
		end
	end))
	maid:Give(searchClearButton.MouseButton1Click:Connect(function()
		searchBox.Text = ""
		searchBox:CaptureFocus()
	end))
	maid:Give(searchClearButton.MouseEnter:Connect(function()
		playTween(searchClearButton, FAST_TWEEN_INFO, { TextColor3 = Theme.Text })
	end))
	maid:Give(searchClearButton.MouseLeave:Connect(function()
		playTween(searchClearButton, FAST_TWEEN_INFO, { TextColor3 = Theme.Subtext })
	end))

	window:_updateSessionTimer(0)
	maid:Give(RunService.Heartbeat:Connect(function()
		if not window._destroyed and window._sessionTimerVisible then
			window:_updateSessionTimer(window:GetSessionElapsed())
		end
	end))

	bindInteractiveSurface(scaleMinus, maid, scaleMinus, scaleMinusStroke, scaleMinusScale, {
		NormalColor = Theme.PanelAlt,
		HoverColor = Theme.CardHover,
		StrokeTransparency = 0.78,
		HoverStrokeTransparency = 0.48,
	})
	bindInteractiveSurface(scalePlus, maid, scalePlus, scalePlusStroke, scalePlusScale, {
		NormalColor = Theme.PanelAlt,
		HoverColor = Theme.CardHover,
		StrokeTransparency = 0.78,
		HoverStrokeTransparency = 0.48,
	})
	bindInteractiveSurface(miniScaleMinus, maid, miniScaleMinus, miniScaleMinusStroke, miniScaleMinusScale, {
		NormalColor = Color3.fromRGB(22, 22, 22),
		HoverColor = Color3.fromRGB(38, 38, 38),
		StrokeColor = Theme.Text,
		HoverStrokeColor = Theme.AccentHover,
		StrokeTransparency = 0.74,
		HoverStrokeTransparency = 0.24,
	})
	bindInteractiveSurface(miniScalePlus, maid, miniScalePlus, miniScalePlusStroke, miniScalePlusScale, {
		NormalColor = Color3.fromRGB(22, 22, 22),
		HoverColor = Color3.fromRGB(38, 38, 38),
		StrokeColor = Theme.Text,
		HoverStrokeColor = Theme.AccentHover,
		StrokeTransparency = 0.74,
		HoverStrokeTransparency = 0.24,
	})
	bindInteractiveSurface(minimizeButton, maid, minimizeButton, minimizeStroke, minimizeScale, {
		NormalColor = Theme.Card,
		HoverColor = Theme.CardHover,
		StrokeTransparency = 0.78,
		HoverStrokeTransparency = 0.38,
	})
	bindInteractiveSurface(expandButton, maid, expandButton, expandStroke, expandScale, {
		NormalColor = Color3.fromRGB(22, 22, 22),
		HoverColor = Color3.fromRGB(38, 38, 38),
		StrokeColor = Theme.Text,
		HoverStrokeColor = Theme.AccentHover,
		StrokeTransparency = 0.68,
		HoverStrokeTransparency = 0.18,
	})
	bindInteractiveSurface(settingsCloseButton, maid, settingsCloseButton, settingsCloseStroke, settingsCloseScale, {
		NormalColor = Theme.Card,
		HoverColor = Theme.Danger,
		PressedColor = Theme.Danger,
		StrokeTransparency = 0.72,
		HoverStrokeTransparency = 0.2,
		HoverStrokeColor = Theme.Danger,
	})
	bindInteractiveSurface(closeButton, maid, closeButton, closeStroke, closeScale, {
		NormalColor = Theme.Card,
		HoverColor = Theme.Danger,
		PressedColor = Theme.Danger,
		StrokeColor = Theme.Stroke,
		HoverStrokeColor = Theme.Danger,
		StrokeTransparency = 0.78,
		HoverStrokeTransparency = 0.28,
	})

	for _, item in ipairs({
		{ scaleMinus, Theme.Subtext },
		{ scalePlus, Theme.Subtext },
		{ miniScaleMinus, Theme.Text },
		{ miniScalePlus, Theme.Text },
		{ minimizeButton, Theme.Subtext },
		{ expandButton, Theme.Text },
	}) do
		local button = item[1]
		local normalColor = item[2]
		maid:Give(button.MouseEnter:Connect(function()
			playTween(button, FAST_TWEEN_INFO, { TextColor3 = Theme.AccentHover })
		end))
		maid:Give(button.MouseLeave:Connect(function()
			playTween(button, FAST_TWEEN_INFO, { TextColor3 = normalColor })
		end))
	end
	maid:Give(closeButton.MouseEnter:Connect(function()
		playTween(closeButton, FAST_TWEEN_INFO, { TextColor3 = Theme.Text })
	end))
	maid:Give(closeButton.MouseLeave:Connect(function()
		playTween(closeButton, FAST_TWEEN_INFO, { TextColor3 = Theme.Subtext })
	end))

	local function changeScale(delta)
		window:SetScale(window:GetScale() + delta)
	end

	maid:Give(scaleMinus.MouseButton1Click:Connect(function()
		changeScale(-0.1)
	end))
	maid:Give(scalePlus.MouseButton1Click:Connect(function()
		changeScale(0.1)
	end))
	maid:Give(miniScaleMinus.MouseButton1Click:Connect(function()
		changeScale(-0.1)
	end))
	maid:Give(miniScalePlus.MouseButton1Click:Connect(function()
		changeScale(0.1)
	end))
	maid:Give(minimizeButton.MouseButton1Click:Connect(function()
		window:SetMinimized(true)
	end))
	maid:Give(expandButton.MouseButton1Click:Connect(function()
		window:SetMinimized(false)
	end))
	maid:Give(settingsCloseButton.MouseButton1Click:Connect(function()
		window:SetSettingsPanelVisible(false)
	end))
	maid:Give(settingsBackdrop.MouseButton1Click:Connect(function()
		window:SetSettingsPanelVisible(false)
	end))
	maid:Give(closeButton.MouseButton1Click:Connect(function()
		if window._closeBehavior == "Destroy" then
			window:Destroy()
		else
			window:SetVisible(false)
		end
	end))

	local dragging = false
	local dragInput = nil
	local dragStart = Vector2.new()
	local startCenter = Vector2.new()

	maid:Give(dragHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragInput = input
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startCenter = main.AbsolutePosition + main.AbsoluteSize / 2
		end
	end))

	maid:Give(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		local isMouseMovement = input.UserInputType == Enum.UserInputType.MouseMovement
		local isTrackedTouch = dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput
		if not isMouseMovement and not isTrackedTouch then
			return
		end

		local camera = Workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
		local currentPosition = Vector2.new(input.Position.X, input.Position.Y)
		local desiredCenter = startCenter + (currentPosition - dragStart)

		main.Position =
			UDim2.fromScale(desiredCenter.X / math.max(viewport.X, 1), desiredCenter.Y / math.max(viewport.Y, 1))
		window:_clampToViewport(viewport, window:GetEffectiveScale())
	end))

	maid:Give(UserInputService.InputEnded:Connect(function(input)
		local endedMouse = input.UserInputType == Enum.UserInputType.MouseButton1
		local endedTouch = dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput
		if dragging and (endedMouse or endedTouch) then
			dragging = false
			dragInput = nil
		end
	end))

	local miniDragging = false
	local miniDragInput = nil
	local miniDragStart = Vector2.new()
	local miniStartAnchor = Vector2.new()

	maid:Give(miniDragHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			miniDragging = true
			miniDragInput = input
			miniDragStart = Vector2.new(input.Position.X, input.Position.Y)
			local camera = Workspace.CurrentCamera
			local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
			local position = miniPlayer.Position
			miniStartAnchor = Vector2.new(
				viewport.X * position.X.Scale + position.X.Offset,
				viewport.Y * position.Y.Scale + position.Y.Offset
			)
		end
	end))

	maid:Give(UserInputService.InputChanged:Connect(function(input)
		if not miniDragging then
			return
		end

		local isMouseMovement = input.UserInputType == Enum.UserInputType.MouseMovement
		local isTrackedTouch = miniDragInput
			and miniDragInput.UserInputType == Enum.UserInputType.Touch
			and input == miniDragInput
		if not isMouseMovement and not isTrackedTouch then
			return
		end

		local camera = Workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
		local currentPosition = Vector2.new(input.Position.X, input.Position.Y)
		local desiredAnchor = miniStartAnchor + (currentPosition - miniDragStart)
		local renderedSize = MINI_PLAYER_SIZE * (window._miniEffectiveScale or 1)

		desiredAnchor = Vector2.new(
			math.clamp(desiredAnchor.X, renderedSize.X + 6, math.max(renderedSize.X + 6, viewport.X - 6)),
			math.clamp(desiredAnchor.Y, renderedSize.Y + 6, math.max(renderedSize.Y + 6, viewport.Y - 6))
		)

		window._miniWasDragged = true
		miniPlayer.AnchorPoint = Vector2.new(1, 1)
		miniPlayer.Position = UDim2.fromOffset(desiredAnchor.X, desiredAnchor.Y)
	end))

	maid:Give(UserInputService.InputEnded:Connect(function(input)
		local endedMouse = input.UserInputType == Enum.UserInputType.MouseButton1
		local endedTouch = miniDragInput
			and miniDragInput.UserInputType == Enum.UserInputType.Touch
			and input == miniDragInput
		if miniDragging and (endedMouse or endedTouch) then
			miniDragging = false
			miniDragInput = nil
		end
	end))

	maid:Give(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if window._capturedKeybindInput == input then
			window._capturedKeybindInput = nil
			return
		end

		if
			window._activeKeybindPicker ~= nil
			or gameProcessedEvent
			or UserInputService:GetFocusedTextBox() ~= nil
			or input.UserInputType ~= Enum.UserInputType.Keyboard
			or window._keybind == nil
		then
			return
		end

		if input.KeyCode == window._keybind then
			window:ToggleVisible()
		end
	end))

	maid:Give(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		window:_bindCurrentCamera()
	end))

	if config.GameCreator == nil or config.GameName == nil then
		local infoTaskId
		infoTaskId = maid:Give(task.spawn(function()
			local ok, productInfo = pcall(function()
				return MarketplaceService:GetProductInfoAsync(game.PlaceId, Enum.InfoType.Asset)
			end)

			if ok and type(productInfo) == "table" and not window._destroyed then
				local update = {}
				if config.GameName == nil and productInfo.Name then
					update.Name = tostring(productInfo.Name)
				end

				if config.GameCreator == nil then
					local creator = productInfo.Creator
					local creatorName
					if type(creator) == "table" then
						creatorName = creator.Name or creator.CreatorName
					elseif type(creator) == "string" then
						creatorName = creator
					end
					update.Creator = creatorName and creatorName ~= "" and tostring(creatorName)
						or "Criador desconhecido"
				end
				window:SetGameInfo(update)
			elseif config.GameCreator == nil and not window._destroyed then
				window:SetGameInfo({ Creator = "Criador desconhecido" })
			end

			maid:Forget(infoTaskId)
		end))
	end

	window:_createSettingsTab()
	local initialSelectionTaskId
	initialSelectionTaskId = maid:Give(task.defer(function()
		maid:Forget(initialSelectionTaskId)
		if not window._destroyed and not window._currentTab and window._settingsTab then
			window:SelectTab(window._settingsTab)
		end
	end))

	local initialScaleText = string.format("%d%%", math.floor(window._userScale * 100 + 0.5))
	window._scaleLabel.Text = initialScaleText
	window._miniScaleLabel.Text = initialScaleText
	window:_syncWindowLayers()
	window:_bindCurrentCamera()
	window:SetVisible(true, config.AnimateOnStart == false)

	self._windows[window] = true
	self._lastWindow = window
	return window
end

function Library:Notify(config)
	assert(
		self._lastWindow and not self._lastWindow._destroyed,
		"[SpotifyUI] Crie uma janela antes de enviar notificações."
	)
	return self._lastWindow:Notify(config)
end

function Library:DestroyAll()
	local windows = {}
	for window in pairs(self._windows) do
		table.insert(windows, window)
	end
	for _, window in ipairs(windows) do
		window:Destroy()
	end
end

Library.Theme = Theme

return Library
