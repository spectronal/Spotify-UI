-- SpotifyUI Library v1.2.0

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Library = {
	Version = "1.2.0",
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
local NOW_PLAYING_HEIGHT = 86
local SIDEBAR_HEADER_HEIGHT = 88
local SETTINGS_AREA_HEIGHT = 72
local WINDOW_CORNER_RADIUS = 16
local PANEL_CORNER_RADIUS = 12
local CARD_CORNER_RADIUS = 10
local CONTROL_CORNER_RADIUS = 8
local WINDOW_OUTLINE_TRANSPARENCY = 0.18
local WINDOW_SHADOW_TRANSPARENCY = 0.7

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

local function addStroke(parent, color, transparency, thickness)
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color or Theme.Stroke,
		Transparency = transparency == nil and 0.45 or transparency,
		Thickness = thickness or 1,
		LineJoinMode = Enum.LineJoinMode.Round,
		Parent = parent,
	})
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
	local value = config.Default
	local opened = false
	local collapsedHeight = 58
	local row, rowStroke, rowScale = createBaseRow(self, collapsedHeight)
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
		ZIndex = 11,
	})
	addCorner(selector, CONTROL_CORNER_RADIUS)
	local selectorStroke = addStroke(selector, Theme.Stroke, 0.68, 1)

	local selectedLabel = makeTextLabel(selector, {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -42, 1, 0),
		Text = value ~= nil and tostring(value) or (config.Placeholder or "Selecionar"),
		TextColor3 = value ~= nil and Theme.Text or Theme.Subtext,
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
			Transparency = opened and 0.3 or 0.68,
		})
		playTween(rowStroke, FAST_TWEEN_INFO, {
			Color = opened and Theme.AccentSoft or Theme.Stroke,
			Transparency = opened and 0.48 or 0.78,
		})
	end

	local function setValue(newValue, fireCallback)
		value = newValue
		selectedLabel.Text = value ~= nil and tostring(value) or (config.Placeholder or "Selecionar")
		selectedLabel.TextColor3 = value ~= nil and Theme.Text or Theme.Subtext
		if fireCallback ~= false then
			safeCallback(config.Callback, value)
		end
	end

	local function rebuildOptions()
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
				local optionButton = makeTextButton(optionsHolder, {
					Name = "Option",
					Size = UDim2.new(1, -4, 0, 36),
					BackgroundColor3 = Theme.Input,
					Text = tostring(optionValue),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 13,
					LayoutOrder = index,
					ZIndex = 13,
				})
				create("UIPadding", {
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
					Parent = optionButton,
				})
				addCorner(optionButton, CONTROL_CORNER_RADIUS)
				local optionStroke = addStroke(optionButton, Theme.Stroke, 0.82, 1)
				bindInteractiveSurface(optionButton, optionsMaid, optionButton, optionStroke, nil, {
					NormalColor = Theme.Input,
					HoverColor = Theme.InputHover,
					StrokeTransparency = 0.82,
					HoverStrokeTransparency = 0.55,
				})
				optionsMaid:Give(optionButton.MouseButton1Click:Connect(function()
					setValue(optionValue, true)
					setOpened(false)
				end))
			end
		end

		if opened then
			setOpened(true)
		end
	end

	bindInteractiveSurface(selector, maid, selector, selectorStroke, nil, {
		NormalColor = Theme.Input,
		HoverColor = Theme.InputHover,
		StrokeTransparency = 0.68,
		HoverStrokeTransparency = 0.42,
	})
	maid:Give(selector.MouseButton1Click:Connect(function()
		setOpened(not opened)
	end))

	rebuildOptions()

	local api = {}
	function api:SetValue(newValue, fireCallback)
		setValue(newValue, fireCallback)
	end
	function api:GetValue()
		return value
	end
	function api:SetOptions(newOptions, keepValue)
		options = table.clone(newOptions or {})
		if not keepValue then
			setValue(nil, false)
		end
		rebuildOptions()
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

local WindowMethods = {}
WindowMethods.__index = WindowMethods

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
	if config.Name ~= nil and self._gameNameLabel then
		self._gameNameLabel.Text = tostring(config.Name)
	end
	if config.Creator ~= nil and self._gameCreatorLabel then
		self._gameCreatorLabel.Text = tostring(config.Creator)
	end
	if config.Icon ~= nil and self._gameIcon then
		self._gameIcon.Image = tostring(config.Icon)
	end
	return self
end

function WindowMethods:SetNowPlayingVisible(visible)
	self._nowPlayingVisible = visible == true
	self._nowPlaying.Visible = self._nowPlayingVisible
	self:_updateResponsiveScale()
	return self
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

function WindowMethods:_syncWindowLayers()
	if self._destroyed then
		return
	end

	local position = self._main.Position
	local size = self._main.Size

	self._outline.Position = position
	self._outline.Size = UDim2.new(size.X.Scale, size.X.Offset + 2, size.Y.Scale, size.Y.Offset + 2)

	self._shadow.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 10)
	self._shadow.Size = UDim2.new(size.X.Scale, size.X.Offset + 18, size.Y.Scale, size.Y.Offset + 18)
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

function WindowMethods:_setLayerVisibility(visible)
	self._main.Visible = visible
	self._outline.Visible = visible
	self._shadow.Visible = visible
	self._notificationContainer.Visible = visible
end

function WindowMethods:_cancelResponsiveTweens()
	for _, tweenKey in ipairs({
		"_responsiveMainTween",
		"_responsiveOutlineTween",
		"_responsiveShadowTween",
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
	self._scaleLabel.Text = string.format("%d%%", math.floor(self._userScale * 100 + 0.5))
	self:_updateResponsiveScale(true)
	return self
end

function WindowMethods:GetScale()
	return self._userScale
end

function WindowMethods:GetEffectiveScale()
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
	self:_cancelVisibilityTweens()
	self:_cancelResponsiveTweens()

	if not isVisible and self._activeKeybindPicker then
		self._activeKeybindPicker:CancelListening()
	end

	local targetScale = self._effectiveScale or self._uiScale.Scale
	local animationsEnabled = self._animationsEnabled and instant ~= true

	if not animationsEnabled then
		self:_setLayerVisibility(isVisible)
		self._main.GroupTransparency = isVisible and 0 or 1
		self._outline.BackgroundTransparency = isVisible and WINDOW_OUTLINE_TRANSPARENCY or 1
		self._shadow.BackgroundTransparency = isVisible and WINDOW_SHADOW_TRANSPARENCY or 1
		self._uiScale.Scale = targetScale
		self._outlineScale.Scale = targetScale
		self._shadowScale.Scale = targetScale
		return self
	end

	self._visibilityAnimating = true
	self:_setLayerVisibility(true)

	local scaleFrom = targetScale * 0.965
	local scaleTo = targetScale

	if isVisible then
		self._main.GroupTransparency = 1
		self._outline.BackgroundTransparency = 1
		self._shadow.BackgroundTransparency = 1
		self._uiScale.Scale = scaleFrom
		self._outlineScale.Scale = scaleFrom
		self._shadowScale.Scale = scaleFrom
	else
		scaleFrom = self._uiScale.Scale
		scaleTo = targetScale * 0.965
	end

	local groupTween = playTween(self._main, FADE_TWEEN_INFO, {
		GroupTransparency = isVisible and 0 or 1,
	})
	local outlineTween = playTween(self._outline, FADE_TWEEN_INFO, {
		BackgroundTransparency = isVisible and WINDOW_OUTLINE_TRANSPARENCY or 1,
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

	self._visibilityConnection = groupTween.Completed:Connect(function()
		self._visibilityConnection = nil
		self._visibilityAnimating = false
		self._visibilityTweens = {}

		if self._destroyed then
			return
		end

		if not self._visible then
			self:_setLayerVisibility(false)
		else
			self._uiScale.Scale = targetScale
			self._outlineScale.Scale = targetScale
			self._shadowScale.Scale = targetScale
		end
	end)

	return self
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
		else
			self._uiScale.Scale = effectiveScale
			self._outlineScale.Scale = effectiveScale
			self._shadowScale.Scale = effectiveScale
		end
	end
	self._notificationScale.Scale = effectiveScale

	local logicalViewportWidth = viewport.X / math.max(effectiveScale, 0.01)
	local compact = logicalViewportWidth < 820
	local sidebarWidth = compact and 184 or math.clamp(self._baseSize.X * 0.225, 198, 224)
	local nowPlayingHeight = self._nowPlayingVisible and NOW_PLAYING_HEIGHT or 0

	self._sidebar.Size = UDim2.new(0, sidebarWidth, 1, -nowPlayingHeight)
	self._content.Position = UDim2.fromOffset(sidebarWidth, 0)
	self._content.Size = UDim2.new(1, -sidebarWidth, 1, -nowPlayingHeight)
	self._nowPlaying.Position = UDim2.new(0, 0, 1, -nowPlayingHeight)
	self._nowPlaying.Size = UDim2.new(1, 0, 0, nowPlayingHeight)
	self._sidebarDivider.Position = UDim2.fromOffset(sidebarWidth - 1, 0)
	self._sidebarDivider.Size = UDim2.new(0, 1, 1, -nowPlayingHeight)

	local showGameStatus = self._nowPlayingVisible and logicalViewportWidth >= 790
	self._gameStatus.Visible = showGameStatus
	local gameTextRightPadding = showGameStatus and 270 or 108
	self._gameNameLabel.Size = UDim2.new(1, -gameTextRightPadding, 0, 25)
	self._gameCreatorLabel.Size = UDim2.new(1, -gameTextRightPadding, 0, 20)

	self:_syncWindowLayers()
	self:_clampToViewport(viewport, effectiveScale)
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
	local tabStroke = addStroke(tabButton, Theme.Stroke, 1, 1)
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
		ZIndex = 8,
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
			ZIndex = 7,
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
			ZIndex = 7,
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
		ZIndex = 7,
	})

	local page = create("CanvasGroup", {
		Name = "Page_" .. tabName,
		Position = UDim2.fromOffset(0, 8),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 5,
		Parent = self._pageContainer,
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
		ZIndex = 5,
		Parent = page,
	})
	create("UIPadding", {
		PaddingTop = UDim.new(0, 14),
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
		if self._currentTab ~= tab then
			playTween(tabButton, FAST_TWEEN_INFO, { BackgroundColor3 = Theme.Card })
			playTween(tabLabel, FAST_TWEEN_INFO, { TextColor3 = Theme.Text })
			playTween(tabStroke, FAST_TWEEN_INFO, {
				Color = Theme.Stroke,
				Transparency = 0.78,
			})
			playTween(tabScale, FAST_TWEEN_INFO, { Scale = 1.01 })
			setIconColor(Theme.Text)
		end
	end))

	tabMaid:Give(tabButton.MouseLeave:Connect(function()
		if self._currentTab ~= tab then
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
		playTween(tabScale, FAST_TWEEN_INFO, { Scale = self._currentTab == tab and 1 or 1.01 })
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

	for _, tab in ipairs(self._tabs) do
		if not tab._destroyed then
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

	local toast = create("CanvasGroup", {
		Name = "Notification",
		Position = UDim2.fromOffset(24, 0),
		Size = UDim2.fromOffset(310, config.Title and 96 or 78),
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		LayoutOrder = -math.floor(os.clock() * 1000),
		ZIndex = 102,
		Parent = self._notificationContainer,
	})
	toastMaid:Give(toast)
	addCorner(toast, PANEL_CORNER_RADIUS)
	addStroke(toast, Theme.Stroke, 0.38, 1)
	addGradient(toast, Color3.fromRGB(27, 27, 27), Color3.fromRGB(20, 20, 20), 90)

	local accent = create("Frame", {
		Size = UDim2.fromOffset(4, config.Title and 96 or 78),
		BackgroundColor3 = config.Color or Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 103,
		Parent = toast,
	})
	addCorner(accent, 2)

	local y = 12
	if config.Title then
		makeTextLabel(toast, {
			Position = UDim2.fromOffset(16, y),
			Size = UDim2.new(1, -52, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = tostring(config.Title),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 104,
		})
		y = 38
	end

	makeTextLabel(toast, {
		Position = UDim2.fromOffset(16, y),
		Size = UDim2.new(1, -52, 0, config.Title and 38 or 44),
		Text = tostring(config.Content or config.Text or "Notificação"),
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 12,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 104,
	})

	local closeButton = makeTextButton(toast, {
		Position = UDim2.new(1, -36, 0, 8),
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Theme.Subtext,
		TextSize = 13,
		ZIndex = 105,
	})

	local progress = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 4, 1, 0),
		Size = UDim2.new(1, -4, 0, 3),
		BackgroundColor3 = config.Color or Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 104,
		Parent = toast,
	})

	local function dismiss()
		if dismissed then
			return
		end
		dismissed = true

		local tween = playTween(toast, FADE_TWEEN_INFO, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(30, 0),
		})
		toastMaid:Give(tween.Completed:Connect(function()
			self._maid:Forget(rootTaskId)
			toastMaid:Cleanup()
		end))
	end

	toastMaid:Give(closeButton.MouseButton1Click:Connect(dismiss))
	toastMaid:Give(closeButton.MouseEnter:Connect(function()
		closeButton.TextColor3 = Theme.Text
	end))
	toastMaid:Give(closeButton.MouseLeave:Connect(function()
		closeButton.TextColor3 = Theme.Subtext
	end))

	playTween(toast, POP_TWEEN_INFO, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) })
	playTween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 3),
	})
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
		Position = UDim2.new(0.5, 0, 0.5, 10),
		Size = UDim2.fromOffset(baseSize.X + 18, baseSize.Y + 18),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = screenGui,
	})
	addCorner(shadow, WINDOW_CORNER_RADIUS + 7)

	local outline = create("Frame", {
		Name = "WindowOutline",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(baseSize.X + 2, baseSize.Y + 2),
		BackgroundColor3 = Theme.Outline,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = screenGui,
	})
	addCorner(outline, WINDOW_CORNER_RADIUS + 1)

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
		Size = UDim2.new(0, 220, 1, -NOW_PLAYING_HEIGHT),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = main,
	})
	addGradient(sidebar, Color3.fromRGB(24, 24, 24), Color3.fromRGB(18, 18, 18), 90)

	-- A sidebar não recebe UICorner próprio. O recorte vem da janela principal,
	-- evitando quinas internas arredondadas e linhas quebradas junto à barra inferior.

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
		Size = UDim2.new(1, -220, 1, -NOW_PLAYING_HEIGHT),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = main,
	})

	local sidebarDivider = create("Frame", {
		Name = "SidebarDivider",
		Position = UDim2.fromOffset(219, 0),
		Size = UDim2.new(0, 1, 1, -NOW_PLAYING_HEIGHT),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.58,
		BorderSizePixel = 0,
		ZIndex = 19,
		Parent = main,
	})

	local topbar = create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT),
		BackgroundColor3 = Theme.BackgroundAlt,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = content,
	})
	addGradient(topbar, Color3.fromRGB(21, 21, 21), Color3.fromRGB(15, 15, 15), 90)
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
		Size = UDim2.new(1, -220, 1, 0),
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

	local dragHandle = create("Frame", {
		Name = "DragHandle",
		Size = UDim2.new(1, -205, 1, 0),
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
		ZIndex = 7,
	})

	local scalePlus = makeTextButton(topbar, {
		Position = UDim2.new(1, -94, 0.5, -16),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = Theme.Card,
		Text = "+",
		TextSize = 16,
		ZIndex = 7,
	})
	addCorner(scalePlus, 16)
	local scalePlusStroke = addStroke(scalePlus, Theme.Stroke, 0.78, 1)
	local scalePlusScale = create("UIScale", { Scale = 1, Parent = scalePlus })

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
		Position = UDim2.new(0, 0, 1, -NOW_PLAYING_HEIGHT),
		Size = UDim2.new(1, 0, 0, NOW_PLAYING_HEIGHT),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Visible = config.ShowNowPlaying ~= false,
		ZIndex = 20,
		Parent = main,
	})
	addGradient(nowPlaying, Color3.fromRGB(24, 24, 24), Color3.fromRGB(17, 17, 17), 0)

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
		Size = UDim2.new(1, -270, 0, 25),
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
		Size = UDim2.new(1, -270, 0, 20),
		Text = tostring(config.GameCreator or "Criador do jogo"),
		TextColor3 = Theme.Subtext,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 22,
	})

	local gameStatus = makeTextButton(nowPlaying, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -18, 0.5, 0),
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

	local notificationContainer = create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(310, 600),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 100,
		Parent = screenGui,
	})
	local notificationScale = create("UIScale", {
		Scale = 1,
		Parent = notificationContainer,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = notificationContainer,
	})

	local window = setmetatable({
		_maid = maid,
		_cameraMaid = cameraMaid,
		_screenGui = screenGui,
		_shadow = shadow,
		_shadowScale = shadowScale,
		_outline = outline,
		_outlineScale = outlineScale,
		_main = main,
		_uiScale = uiScale,
		_sidebar = sidebar,
		_sidebarDivider = sidebarDivider,
		_content = content,
		_titleLabel = titleLabel,
		_subtitleLabel = subtitleLabel,
		_tabsContainer = tabsContainer,
		_settingsTabsContainer = settingsTabsContainer,
		_currentTabLabel = currentTabLabel,
		_topbarAccent = topbarAccent,
		_pageContainer = pageContainer,
		_scaleLabel = scaleLabel,
		_nowPlaying = nowPlaying,
		_gameIcon = gameIcon,
		_gameNameLabel = gameNameLabel,
		_gameCreatorLabel = gameCreatorLabel,
		_gameStatus = gameStatus,
		_nowPlayingVisible = config.ShowNowPlaying ~= false,
		_notificationContainer = notificationContainer,
		_notificationScale = notificationScale,
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
		_visibilityAnimating = false,
		_visibilityTweens = {},
		_visibilityConnection = nil,
		_effectiveScale = 1,
		_destroyed = false,
	}, WindowMethods)

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
	end)

	bindInteractiveSurface(scaleMinus, maid, scaleMinus, scaleMinusStroke, scaleMinusScale, {
		NormalColor = Theme.Card,
		HoverColor = Theme.CardHover,
		StrokeTransparency = 0.78,
		HoverStrokeTransparency = 0.48,
	})
	bindInteractiveSurface(scalePlus, maid, scalePlus, scalePlusStroke, scalePlusScale, {
		NormalColor = Theme.Card,
		HoverColor = Theme.CardHover,
		StrokeTransparency = 0.78,
		HoverStrokeTransparency = 0.48,
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
	maid:Give(closeButton.MouseEnter:Connect(function()
		playTween(closeButton, FAST_TWEEN_INFO, { TextColor3 = Theme.Text })
	end))
	maid:Give(closeButton.MouseLeave:Connect(function()
		playTween(closeButton, FAST_TWEEN_INFO, { TextColor3 = Theme.Subtext })
	end))

	maid:Give(scaleMinus.MouseButton1Click:Connect(function()
		window:SetScale(window:GetScale() - 0.1)
	end))
	maid:Give(scalePlus.MouseButton1Click:Connect(function()
		window:SetScale(window:GetScale() + 0.1)
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
				if config.GameName == nil and productInfo.Name then
					gameNameLabel.Text = tostring(productInfo.Name)
				end

				if config.GameCreator == nil then
					local creator = productInfo.Creator
					local creatorName
					if type(creator) == "table" then
						creatorName = creator.Name or creator.CreatorName
					elseif type(creator) == "string" then
						creatorName = creator
					end
					if creatorName and creatorName ~= "" then
						gameCreatorLabel.Text = tostring(creatorName)
					else
						gameCreatorLabel.Text = "Criador desconhecido"
					end
				end
			elseif config.GameCreator == nil and not window._destroyed then
				gameCreatorLabel.Text = "Criador desconhecido"
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

	window._scaleLabel.Text = string.format("%d%%", math.floor(window._userScale * 100 + 0.5))
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
