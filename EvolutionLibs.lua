--[[
	EvolutionLibs v2.0 - Librería GUI Profesional para Roblox
	
	Características:
	• Temas dinámicos y personalizables
	• Animaciones fluidas y efectos visuales
	• Sistema de pestañas avanzado
	• Elementos UI modernos y responsivos
	• API simplificada y intuitiva
	• Notificaciones toast elegantes
	• Sidebar colapsable
	• Drag & Drop nativo
	• Efectos de ripple y hover
	• Sistema de iconos integrado
	
	Ejemplo de uso:
	local Evo = loadstring(game:HttpGet("tu-url.lua"))()
	
	local window = Evo:CreateWindow({
		Title = "Evolution Panel",
		Theme = "Futuristic", -- Dark, Light, Futuristic, Custom
		Size = {600, 400},
		MinSize = {400, 300},
		Resizable = true
	})
	
	local tab = window:CreateTab("AutoFarm", "rbxassetid://icon")
	
	tab:CreateLabel("Bienvenido a Evolution!")
	tab:CreateToggle("Auto Money", false, function(state)
		print("AutoMoney:", state)
	end)
	
	Evo:Notify("¡Librería cargada!", "success", 3)
]]

local EvolutionLibs = {
	Version = "2.0.0",
	Windows = {},
	Themes = {},
	Notifications = {},
	Services = {}
}

-- Servicios de Roblox
local Services = {
	Players = game:GetService("Players"),
	TweenService = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService"),
	RunService = game:GetService("RunService"),
	CoreGui = game:GetService("CoreGui"),
	HttpService = game:GetService("HttpService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Utilidades matemáticas y de colores
local Utils = {}

function Utils:Lerp(a, b, t)
	return a + (b - a) * t
end

function Utils:LerpColor(color1, color2, t)
	return Color3.new(
		self:Lerp(color1.R, color2.R, t),
		self:Lerp(color1.G, color2.G, t),
		self:Lerp(color1.B, color2.B, t)
	)
end

function Utils:CreateRipple(button, color)
	color = color or Color3.fromRGB(255, 255, 255)
	
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local ripple = Instance.new("Frame")
			ripple.Name = "Ripple"
			ripple.Size = UDim2.new(0, 0, 0, 0)
			ripple.BackgroundColor3 = color
			ripple.BackgroundTransparency = 0.7
			ripple.BorderSizePixel = 0
			ripple.ZIndex = 100
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = ripple
			
			ripple.Parent = button
			
			local mouse = Services.UserInputService:GetMouseLocation()
			local buttonPos = button.AbsolutePosition
			local buttonSize = button.AbsoluteSize
			
			local relativeX = mouse.X - buttonPos.X
			local relativeY = mouse.Y - buttonPos.Y
			
			ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
			
			local maxSize = math.max(buttonSize.X, buttonSize.Y) * 2
			
			local tween = Services.TweenService:Create(ripple, 
				TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = UDim2.new(0, maxSize, 0, maxSize),
					Position = UDim2.new(0, relativeX - maxSize/2, 0, relativeY - maxSize/2),
					BackgroundTransparency = 1
				}
			)
			
			tween:Play()
			tween.Completed:Connect(function()
				ripple:Destroy()
			end)
		end
	end)
end

function Utils:Animate(object, properties, duration, easingStyle, easingDirection)
	duration = duration or 0.3
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	
	local tween = Services.TweenService:Create(
		object,
		TweenInfo.new(duration, easingStyle, easingDirection),
		properties
	)
	
	tween:Play()
	return tween
end

function Utils:CreateGlow(parent, color, size)
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, size or 20, 1, size or 20)
	glow.Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxasset://textures/ui/Glow.png"
	glow.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
	glow.ImageTransparency = 0.8
	glow.ZIndex = -1
	glow.Parent = parent
	return glow
end

-- Definición de temas
EvolutionLibs.Themes = {
	Dark = {
		Background = Color3.fromRGB(25, 25, 35),
		Surface = Color3.fromRGB(35, 35, 45),
		Primary = Color3.fromRGB(70, 130, 255),
		Secondary = Color3.fromRGB(45, 45, 55),
		Accent = Color3.fromRGB(100, 200, 100),
		Text = Color3.fromRGB(245, 245, 245),
		TextSecondary = Color3.fromRGB(180, 180, 180),
		Border = Color3.fromRGB(60, 60, 70),
		Success = Color3.fromRGB(76, 175, 80),
		Warning = Color3.fromRGB(255, 193, 7),
		Error = Color3.fromRGB(244, 67, 54),
		Hover = Color3.fromRGB(255, 255, 255),
		Disabled = Color3.fromRGB(120, 120, 120)
	},
	
	Light = {
		Background = Color3.fromRGB(250, 250, 250),
		Surface = Color3.fromRGB(255, 255, 255),
		Primary = Color3.fromRGB(33, 150, 243),
		Secondary = Color3.fromRGB(240, 240, 240),
		Accent = Color3.fromRGB(255, 87, 34),
		Text = Color3.fromRGB(33, 33, 33),
		TextSecondary = Color3.fromRGB(117, 117, 117),
		Border = Color3.fromRGB(224, 224, 224),
		Success = Color3.fromRGB(76, 175, 80),
		Warning = Color3.fromRGB(255, 193, 7),
		Error = Color3.fromRGB(244, 67, 54),
		Hover = Color3.fromRGB(0, 0, 0),
		Disabled = Color3.fromRGB(189, 189, 189)
	},
	
	Futuristic = {
		Background = Color3.fromRGB(15, 15, 25),
		Surface = Color3.fromRGB(25, 25, 40),
		Primary = Color3.fromRGB(0, 255, 255),
		Secondary = Color3.fromRGB(35, 35, 50),
		Accent = Color3.fromRGB(255, 0, 128),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 200),
		Border = Color3.fromRGB(0, 255, 255),
		Success = Color3.fromRGB(0, 255, 127),
		Warning = Color3.fromRGB(255, 215, 0),
		Error = Color3.fromRGB(255, 20, 147),
		Hover = Color3.fromRGB(0, 255, 255),
		Disabled = Color3.fromRGB(100, 100, 120),
		Gradient = {
			ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
			})
		}
	}
}

-- Clase Window principal
local Window = {}
Window.__index = Window

function Window.new(config)
	local self = setmetatable({}, Window)
	
	-- Configuración por defecto
	self.Config = {
		Title = config.Title or "Evolution Panel",
		Theme = config.Theme or "Dark",
		Size = config.Size or {600, 400},
		MinSize = config.MinSize or {400, 300},
		Resizable = config.Resizable ~= false,
		Position = config.Position,
		Draggable = config.Draggable ~= false,
		CloseCallback = config.CloseCallback
	}
	
	self.Theme = EvolutionLibs.Themes[self.Config.Theme] or EvolutionLibs.Themes.Dark
	self.Tabs = {}
	self.CurrentTab = nil
	self.SidebarCollapsed = false
	
	self:CreateUI()
	self:SetupEvents()
	
	table.insert(EvolutionLibs.Windows, self)
	
	return self
end

function Window:CreateUI()
	-- ScreenGui principal
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "EvolutionLibs_" .. Services.HttpService:GenerateGUID(false)
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.Parent = PlayerGui
	
	-- Frame principal con sombra
	self.Shadow = Instance.new("Frame")
	self.Shadow.Name = "Shadow"
	self.Shadow.Size = UDim2.new(0, self.Config.Size[1] + 20, 0, self.Config.Size[2] + 20)
	self.Shadow.Position = self.Config.Position or UDim2.new(0.5, -self.Config.Size[1]/2 - 10, 0.5, -self.Config.Size[2]/2 - 10)
	self.Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.Shadow.BackgroundTransparency = 0.7
	self.Shadow.BorderSizePixel = 0
	self.Shadow.ZIndex = 1
	self.Shadow.Parent = self.ScreenGui
	
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 12)
	shadowCorner.Parent = self.Shadow
	
	-- Frame principal
	self.Main = Instance.new("Frame")
	self.Main.Name = "Main"
	self.Main.Size = UDim2.new(0, self.Config.Size[1], 0, self.Config.Size[2])
	self.Main.Position = UDim2.new(0, 10, 0, 10)
	self.Main.BackgroundColor3 = self.Theme.Background
	self.Main.BorderSizePixel = 0
	self.Main.ZIndex = 2
	self.Main.Parent = self.Shadow
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 8)
	mainCorner.Parent = self.Main
	
	-- Barra de título
	self:CreateTitleBar()
	
	-- Sidebar
	self:CreateSidebar()
	
	-- Área de contenido
	self:CreateContentArea()
	
	-- Hacer draggable si está habilitado
	if self.Config.Draggable then
		self:MakeDraggable()
	end
	
	-- Hacer redimensionable si está habilitado
	if self.Config.Resizable then
		self:MakeResizable()
	end
end

function Window:CreateTitleBar()
	self.TitleBar = Instance.new("Frame")
	self.TitleBar.Name = "TitleBar"
	self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
	self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
	self.TitleBar.BackgroundColor3 = self.Theme.Surface
	self.TitleBar.BorderSizePixel = 0
	self.TitleBar.ZIndex = 3
	self.TitleBar.Parent = self.Main
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 8)
	titleCorner.Parent = self.TitleBar
	
	-- Título
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -100, 1, 0)
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = self.Config.Title
	titleLabel.TextColor3 = self.Theme.Text
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 4
	titleLabel.Parent = self.TitleBar
	
	-- Botones de control
	self:CreateControlButtons()
end

function Window:CreateControlButtons()
	local buttonSize = 30
	local spacing = 5
	
	-- Botón cerrar
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, buttonSize, 0, buttonSize)
	closeBtn.Position = UDim2.new(1, -buttonSize - 5, 0.5, -buttonSize/2)
	closeBtn.BackgroundColor3 = self.Theme.Error
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.ZIndex = 4
	closeBtn.Parent = self.TitleBar
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 6)
	closeBtnCorner.Parent = closeBtn
	
	-- Botón minimizar sidebar
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleButton"
	toggleBtn.Size = UDim2.new(0, buttonSize, 0, buttonSize)
	toggleBtn.Position = UDim2.new(1, -buttonSize*2 - spacing - 5, 0.5, -buttonSize/2)
	toggleBtn.BackgroundColor3 = self.Theme.Primary
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = "☰"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 14
	toggleBtn.ZIndex = 4
	toggleBtn.Parent = self.TitleBar
	
	local toggleBtnCorner = Instance.new("UICorner")
	toggleBtnCorner.CornerRadius = UDim.new(0, 6)
	toggleBtnCorner.Parent = toggleBtn
	
	-- Eventos
	closeBtn.MouseButton1Click:Connect(function()
		self:Close()
	end)
	
	toggleBtn.MouseButton1Click:Connect(function()
		self:ToggleSidebar()
	end)
	
	-- Efectos hover
	Utils:CreateRipple(closeBtn, Color3.fromRGB(255, 255, 255))
	Utils:CreateRipple(toggleBtn, Color3.fromRGB(255, 255, 255))
	
	closeBtn.MouseEnter:Connect(function()
		Utils:Animate(closeBtn, {BackgroundColor3 = Utils:LerpColor(self.Theme.Error, Color3.fromRGB(255, 255, 255), 0.1)})
	end)
	
	closeBtn.MouseLeave:Connect(function()
		Utils:Animate(closeBtn, {BackgroundColor3 = self.Theme.Error})
	end)
	
	toggleBtn.MouseEnter:Connect(function()
		Utils:Animate(toggleBtn, {BackgroundColor3 = Utils:LerpColor(self.Theme.Primary, Color3.fromRGB(255, 255, 255), 0.1)})
	end)
	
	toggleBtn.MouseLeave:Connect(function()
		Utils:Animate(toggleBtn, {BackgroundColor3 = self.Theme.Primary})
	end)
end

function Window:CreateSidebar()
	self.Sidebar = Instance.new("Frame")
	self.Sidebar.Name = "Sidebar"
	self.Sidebar.Size = UDim2.new(0, 180, 1, -40)
	self.Sidebar.Position = UDim2.new(0, 0, 0, 40)
	self.Sidebar.BackgroundColor3 = self.Theme.Surface
	self.Sidebar.BorderSizePixel = 0
	self.Sidebar.ZIndex = 3
	self.Sidebar.Parent = self.Main
	
	-- Lista de pestañas
	self.TabList = Instance.new("ScrollingFrame")
	self.TabList.Name = "TabList"
	self.TabList.Size = UDim2.new(1, 0, 1, 0)
	self.TabList.Position = UDim2.new(0, 0, 0, 0)
	self.TabList.BackgroundTransparency = 1
	self.TabList.BorderSizePixel = 0
	self.TabList.ScrollBarThickness = 4
	self.TabList.ScrollBarImageColor3 = self.Theme.Primary
	self.TabList.ZIndex = 4
	self.TabList.Parent = self.Sidebar
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = self.TabList
	
	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 10)
	listPadding.PaddingBottom = UDim.new(0, 10)
	listPadding.PaddingLeft = UDim.new(0, 5)
	listPadding.PaddingRight = UDim.new(0, 5)
	listPadding.Parent = self.TabList
end

function Window:CreateContentArea()
	self.Content = Instance.new("Frame")
	self.Content.Name = "Content"
	self.Content.Size = UDim2.new(1, -180, 1, -40)
	self.Content.Position = UDim2.new(0, 180, 0, 40)
	self.Content.BackgroundColor3 = self.Theme.Background
	self.Content.BorderSizePixel = 0
	self.Content.ZIndex = 3
	self.Content.Parent = self.Main
end

function Window:CreateTab(name, icon)
	local tab = setmetatable({
		Window = self,
		Name = name,
		Icon = icon,
		Elements = {},
		Active = false
	}, {__index = Tab})
	
	tab:CreateUI()
	table.insert(self.Tabs, tab)
	
	-- Seleccionar primera pestaña automáticamente
	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end
	
	return tab
end

function Window:SelectTab(tab)
	-- Desactivar pestaña actual
	if self.CurrentTab then
		self.CurrentTab:SetActive(false)
	end
	
	-- Activar nueva pestaña
	self.CurrentTab = tab
	tab:SetActive(true)
end

function Window:ToggleSidebar()
	self.SidebarCollapsed = not self.SidebarCollapsed
	
	local sidebarSize = self.SidebarCollapsed and 0 or 180
	local contentPos = self.SidebarCollapsed and 0 or 180
	local contentSize = self.SidebarCollapsed and 0 or -180
	
	Utils:Animate(self.Sidebar, {Size = UDim2.new(0, sidebarSize, 1, -40)}, 0.3)
	Utils:Animate(self.Content, {
		Position = UDim2.new(0, contentPos, 0, 40),
		Size = UDim2.new(1, contentSize, 1, -40)
	}, 0.3)
end

function Window:MakeDraggable()
	local dragging = false
	local dragStart, startPos
	
	self.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.Shadow.Position
		end
	end)
	
	Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			self.Shadow.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

function Window:MakeResizable()
	-- Implementar redimensionamiento por las esquinas
	local resizing = false
	local resizeStart, startSize, startPos
	
	local resizeHandle = Instance.new("Frame")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Size = UDim2.new(0, 20, 0, 20)
	resizeHandle.Position = UDim2.new(1, -20, 1, -20)
	resizeHandle.BackgroundColor3 = self.Theme.Primary
	resizeHandle.BackgroundTransparency = 0.7
	resizeHandle.BorderSizePixel = 0
	resizeHandle.ZIndex = 5
	resizeHandle.Parent = self.Main
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = resizeHandle
	
	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = input.Position
			startSize = self.Shadow.Size
		end
	end)
	
	Services.UserInputService.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - resizeStart
			local newWidth = math.max(self.Config.MinSize[1], startSize.X.Offset + delta.X)
			local newHeight = math.max(self.Config.MinSize[2], startSize.Y.Offset + delta.Y)
			
			self.Shadow.Size = UDim2.new(0, newWidth, 0, newHeight)
			self.Main.Size = UDim2.new(0, newWidth - 20, 0, newHeight - 20)
		end
	end)
	
	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)
end

function Window:SetupEvents()
	-- Cleanup al cerrar
	self.ScreenGui.AncestryChanged:Connect(function()
		if not self.ScreenGui.Parent then
			for i, win in ipairs(EvolutionLibs.Windows) do
				if win == self then
					table.remove(EvolutionLibs.Windows, i)
					break
				end
			end
		end
	end)
end

function Window:Close()
	if self.Config.CloseCallback then
		self.Config.CloseCallback()
	end
	
	-- Animación de cierre
	Utils:Animate(self.Shadow, {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1
	}, 0.3)
	
	Utils:Animate(self.Main, {
		BackgroundTransparency = 1
	}, 0.3)
	
	wait(0.3)
	self.ScreenGui:Destroy()
end

function Window:Show()
	self.ScreenGui.Enabled = true
	
	-- Animación de entrada
	local originalSize = self.Shadow.Size
	self.Shadow.Size = UDim2.new(0, 0, 0, 0)
	self.Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	Utils:Animate(self.Shadow, {
		Size = originalSize,
		Position = UDim2.new(0.5, -originalSize.X.Offset/2, 0.5, -originalSize.Y.Offset/2)
	}, 0.4, Enum.EasingStyle.Back)
end

function Window:Hide()
	self.ScreenGui.Enabled = false
end

-- Clase Tab
local Tab = {}
Tab.__index = Tab

function Tab:CreateUI()
	-- Botón en la sidebar
	self.Button = Instance.new("TextButton")
	self.Button.Name = "TabButton_" .. self.Name
	self.Button.Size = UDim2.new(1, -10, 0, 40)
	self.Button.BackgroundColor3 = self.Window.Theme.Secondary
	self.Button.BorderSizePixel = 0
	self.Button.Text = ""
	self.Button.ZIndex = 5
	self.Button.Parent = self.Window.TabList
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = self.Button
	
	-- Icono y texto
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = self.Button
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.Parent = self.Button
	
	if self.Icon then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 20, 0, 20)
		icon.BackgroundTransparency = 1
		icon.Image = self.Icon
		icon.ImageColor3 = self.Window.Theme.TextSecondary
		icon.ZIndex = 6
		icon.Parent = self.Button
	end
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, self.Icon and -28 or 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = self.Name
	label.TextColor3 = self.Window.Theme.TextSecondary
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = self.Button
	
	-- Contenido de la pestaña
	self.Container = Instance.new("ScrollingFrame")
	self.Container.Name = "TabContainer_" .. self.Name
	self.Container.Size = UDim2.new(1, 0, 1, 0)
	self.Container.Position = UDim2.new(0, 0, 0, 0)
	self.Container.BackgroundTransparency = 1
	self.Container.BorderSizePixel = 0
	self.Container.ScrollBarThickness = 6
	self.Container.ScrollBarImageColor3 = self.Window.Theme.Primary
	self.Container.ZIndex = 4
	self.Container.Visible = false
	self.Container.Parent = self.Window.Content
	
	local containerLayout = Instance.new("UIListLayout")
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	containerLayout.Padding = UDim.new(0, 8)
	containerLayout.Parent = self.Container
	
	local containerPadding = Instance.new("UIPadding")
	containerPadding.PaddingTop = UDim.new(0, 15)
	containerPadding.PaddingBottom = UDim.new(0, 15)
	containerPadding.PaddingLeft = UDim.new(0, 20)
	containerPadding.PaddingRight = UDim.new(0, 20)
	containerPadding.Parent = self.Container
	
	-- Eventos
	self.Button.MouseButton1Click:Connect(function()
		self.Window:SelectTab(self)
	end)
	
	-- Efectos
	Utils:CreateRipple(self.Button, self.Window.Theme.Primary)
	
	self.Button.MouseEnter:Connect(function()
		if not self.Active then
			Utils:Animate(self.Button, {BackgroundColor3 = Utils:LerpColor(self.Window.Theme.Secondary, self.Window.Theme.Primary, 0.1)})
		end
	end)
	
	self.Button.MouseLeave:Connect(function()
		if not self.Active then
			Utils:Animate(self.Button, {BackgroundColor3 = self.Window.Theme.Secondary})
		end
	end)
	
	-- Actualizar layout del contenedor
	containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Container.CanvasSize = UDim2.new(0, 0, 0, containerLayout.AbsoluteContentSize.Y)
	end)
end

function Tab:SetActive(active)
	self.Active = active
	
	if active then
		-- Activar pestaña
		Utils:Animate(self.Button, {BackgroundColor3 = self.Window.Theme.Primary})
		if self.Button:FindFirstChild("Icon") then
			Utils:Animate(self.Button.Icon, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
		end
		Utils:Animate(self.Button.Label, {TextColor3 = Color3.fromRGB(255, 255, 255)})
		
		self.Container.Visible = true
		Utils:Animate(self.Container, {BackgroundTransparency = 0}, 0.2)
	else
		-- Desactivar pestaña
		Utils:Animate(self.Button, {BackgroundColor3 = self.Window.Theme.Secondary})
		if self.Button:FindFirstChild("Icon") then
			Utils:Animate(self.Button.Icon, {ImageColor3 = self.Window.Theme.TextSecondary})
		end
		Utils:Animate(self.Button.Label, {TextColor3 = self.Window.Theme.TextSecondary})
		
		Utils:Animate(self.Container, {BackgroundTransparency = 1}, 0.2)
		wait(0.2)
		self.Container.Visible = false
	end
end

-- Métodos para crear elementos UI
function Tab:CreateLabel(text, config)
	config = config or {}
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -40, 0, config.Size or 25)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = config.Color or self.Window.Theme.Text
	label.Font = config.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextSize = config.TextSize or 16
	label.TextXAlignment = Enum.TextXAlignment[config.Alignment or "Left"]
	label.TextWrapped = true
	label.ZIndex = 5
	label.Parent = self.Container
	
	-- Efecto gradiente si está habilitado
	if config.Gradient and self.Window.Theme.Gradient then
		local gradient = Instance.new("UIGradient")
		gradient.Color = self.Window.Theme.Gradient[1]
		gradient.Parent = label
	end
	
	return label
end

function Tab:CreateButton(text, callback, config)
	config = config or {}
	
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(1, -40, 0, config.Height or 35)
	button.BackgroundColor3 = config.Color or self.Window.Theme.Primary
	button.BorderSizePixel = 0
	button.Text = ""
	button.ZIndex = 5
	button.Parent = self.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	
	-- Layout horizontal para icono y texto
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = button
	
	-- Icono opcional
	if config.Icon then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 18, 0, 18)
		icon.BackgroundTransparency = 1
		icon.Image = config.Icon
		icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		icon.ZIndex = 6
		icon.Parent = button
	end
	
	-- Texto del botón
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0, 0, 1, 0)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
	label.ZIndex = 6
	label.Parent = button
	
	-- Eventos
	button.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
	
	-- Efectos
	Utils:CreateRipple(button, Color3.fromRGB(255, 255, 255))
	
	button.MouseEnter:Connect(function()
		Utils:Animate(button, {BackgroundColor3 = Utils:LerpColor(button.BackgroundColor3, Color3.fromRGB(255, 255, 255), 0.1)})
	end)
	
	button.MouseLeave:Connect(function()
		Utils:Animate(button, {BackgroundColor3 = config.Color or self.Window.Theme.Primary})
	end)
	
	return button
end

function Tab:CreateToggle(text, default, callback, config)
	config = config or {}
	
	local container = Instance.new("Frame")
	container.Name = "Toggle"
	container.Size = UDim2.new(1, -40, 0, 40)
	container.BackgroundColor3 = self.Window.Theme.Surface
	container.BorderSizePixel = 0
	container.ZIndex = 5
	container.Parent = self.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = container
	
	-- Texto
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Window.Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = container
	
	-- Switch
	local switch = Instance.new("Frame")
	switch.Name = "Switch"
	switch.Size = UDim2.new(0, 45, 0, 24)
	switch.Position = UDim2.new(1, -60, 0.5, -12)
	switch.BackgroundColor3 = default and self.Window.Theme.Success or self.Window.Theme.Secondary
	switch.BorderSizePixel = 0
	switch.ZIndex = 6
	switch.Parent = container
	
	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(0, 12)
	switchCorner.Parent = switch
	
	-- Círculo del switch
	local circle = Instance.new("Frame")
	circle.Name = "Circle"
	circle.Size = UDim2.new(0, 18, 0, 18)
	circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.BorderSizePixel = 0
	circle.ZIndex = 7
	circle.Parent = switch
	
	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(0, 9)
	circleCorner.Parent = circle
	
	-- Estado
	local toggled = default
	
	-- Botón invisible para capturar clicks
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.ZIndex = 8
	button.Parent = container
	
	-- Función toggle
	local function toggle()
		toggled = not toggled
		
		if toggled then
			Utils:Animate(circle, {Position = UDim2.new(1, -21, 0.5, -9)})
			Utils:Animate(switch, {BackgroundColor3 = self.Window.Theme.Success})
		else
			Utils:Animate(circle, {Position = UDim2.new(0, 3, 0.5, -9)})
			Utils:Animate(switch, {BackgroundColor3 = self.Window.Theme.Secondary})
		end
		
		if callback then callback(toggled) end
	end
	
	button.MouseButton1Click:Connect(toggle)
	
	-- Efectos hover
	button.MouseEnter:Connect(function()
		Utils:Animate(container, {BackgroundColor3 = Utils:LerpColor(self.Window.Theme.Surface, self.Window.Theme.Primary, 0.05)})
	end)
	
	button.MouseLeave:Connect(function()
		Utils:Animate(container, {BackgroundColor3 = self.Window.Theme.Surface})
	end)
	
	return {
		Container = container,
		SetValue = function(value)
			if value ~= toggled then toggle() end
		end,
		GetValue = function() return toggled end
	}
end

function Tab:CreateSlider(text, min, max, default, callback, config)
	config = config or {}
	min, max, default = min or 0, max or 100, default or 0
	
	local container = Instance.new("Frame")
	container.Name = "Slider"
	container.Size = UDim2.new(1, -40, 0, 55)
	container.BackgroundColor3 = self.Window.Theme.Surface
	container.BorderSizePixel = 0
	container.ZIndex = 5
	container.Parent = self.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = container
	
	-- Etiqueta
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -20, 0, 20)
	label.Position = UDim2.new(0, 10, 0, 5)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. default
	label.TextColor3 = self.Window.Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = container
	
	-- Pista del slider
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, -30, 0, 6)
	track.Position = UDim2.new(0, 15, 0, 35)
	track.BackgroundColor3 = self.Window.Theme.Secondary
	track.BorderSizePixel = 0
	track.ZIndex = 6
	track.Parent = container
	
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 3)
	trackCorner.Parent = track
	
	-- Relleno del slider
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = self.Window.Theme.Primary
	fill.BorderSizePixel = 0
	fill.ZIndex = 7
	fill.Parent = track
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 3)
	fillCorner.Parent = fill
	
	-- Thumb del slider
	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 16, 0, 16)
	thumb.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
	thumb.BackgroundColor3 = self.Window.Theme.Primary
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 8
	thumb.Parent = track
	
	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(0, 8)
	thumbCorner.Parent = thumb
	
	-- Estado
	local value = default
	local dragging = false
	
	-- Función para actualizar valor
	local function updateValue(newValue)
		value = math.clamp(math.floor(newValue), min, max)
		local percent = (value - min) / (max - min)
		
		Utils:Animate(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
		Utils:Animate(thumb, {Position = UDim2.new(percent, -8, 0.5, -8)}, 0.1)
		
		label.Text = text .. ": " .. value
		
		if callback then callback(value) end
	end
	
	-- Eventos de arrastre
	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			Utils:Animate(thumb, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(thumb.Position.X.Scale, -10, 0.5, -10)}, 0.1)
		end
	end)
	
	Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			relativeX = math.clamp(relativeX, 0, 1)
			local newValue = min + (max - min) * relativeX
			updateValue(newValue)
		end
	end)
	
	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
			dragging = false
			Utils:Animate(thumb, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(thumb.Position.X.Scale, -8, 0.5, -8)}, 0.1)
		end
	end)
	
	-- Click en la pista
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
			local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			relativeX = math.clamp(relativeX, 0, 1)
			local newValue = min + (max - min) * relativeX
			updateValue(newValue)
		end
	end)
	
	return {
		Container = container,
		SetValue = updateValue,
		GetValue = function() return value end
	}
end

function Tab:CreateDropdown(text, options, default, callback, config)
	config = config or {}
	options = options or {}
	default = default or 1
	
	local container = Instance.new("Frame")
	container.Name = "Dropdown"
	container.Size = UDim2.new(1, -40, 0, 40)
	container.BackgroundColor3 = self.Window.Theme.Surface
	container.BorderSizePixel = 0
	container.ZIndex = 5
	container.Parent = self.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = container
	
	-- Etiqueta
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Window.Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = container
	
	-- Botón dropdown
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(0.4, -15, 0, 28)
	button.Position = UDim2.new(0.6, 0, 0.5, -14)
	button.BackgroundColor3 = self.Window.Theme.Primary
	button.BorderSizePixel = 0
	button.Text = options[default] or "Seleccionar"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 12
	button.ZIndex = 6
	button.Parent = container
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 4)
	buttonCorner.Parent = button
	
	-- Flecha
	local arrow = Instance.new("TextLabel")
	arrow.Name = "Arrow"
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(1, -20, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
	arrow.Font = Enum.Font.Gotham
	arrow.TextSize = 10
	arrow.ZIndex = 7
	arrow.Parent = button
	
	-- Estado
	local selectedIndex = default
	local isOpen = false
	
	-- Lista desplegable
	local dropdown = Instance.new("Frame")
	dropdown.Name = "DropdownList"
	dropdown.Size = UDim2.new(0.4, -15, 0, #options * 25)
	dropdown.Position = UDim2.new(0.6, 0, 1, 5)
	dropdown.BackgroundColor3 = self.Window.Theme.Surface
	dropdown.BorderSizePixel = 1
	dropdown.BorderColor3 = self.Window.Theme.Border
	dropdown.ZIndex = 10
	dropdown.Visible = false
	dropdown.Parent = container
	
	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.CornerRadius = UDim.new(0, 4)
	dropdownCorner.Parent = dropdown
	
	local dropdownLayout = Instance.new("UIListLayout")
	dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropdownLayout.Parent = dropdown
	
	-- Crear opciones
	for i, option in ipairs(options) do
		local optionButton = Instance.new("TextButton")
		optionButton.Name = "Option" .. i
		optionButton.Size = UDim2.new(1, 0, 0, 25)
		optionButton.BackgroundColor3 = i == selectedIndex and self.Window.Theme.Primary or Color3.fromRGB(0, 0, 0, 0)
		optionButton.BorderSizePixel = 0
		optionButton.Text = option
		optionButton.TextColor3 = i == selectedIndex and Color3.fromRGB(255, 255, 255) or self.Window.Theme.Text
		optionButton.Font = Enum.Font.Gotham
		optionButton.TextSize = 12
		optionButton.ZIndex = 11
		optionButton.Parent = dropdown
		
		optionButton.MouseButton1Click:Connect(function()
			selectedIndex = i
			button.Text = option
			
			-- Actualizar colores de todas las opciones
			for j, child in ipairs(dropdown:GetChildren()) do
				if child:IsA("TextButton") then
					if j == selectedIndex then
						child.BackgroundColor3 = self.Window.Theme.Primary
						child.TextColor3 = Color3.fromRGB(255, 255, 255)
					else
						child.BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)
						child.TextColor3 = self.Window.Theme.Text
					end
				end
			end
			
			-- Cerrar dropdown
			isOpen = false
			dropdown.Visible = false
			Utils:Animate(arrow, {Rotation = 0}, 0.2)
			
			if callback then callback(option, i) end
		end)
		
		optionButton.MouseEnter:Connect(function()
			if i ~= selectedIndex then
				Utils:Animate(optionButton, {BackgroundColor3 = Utils:LerpColor(Color3.fromRGB(0, 0, 0, 0), self.Window.Theme.Primary, 0.1)})
			end
		end)
		
		optionButton.MouseLeave:Connect(function()
			if i ~= selectedIndex then
				Utils:Animate(optionButton, {BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)})
			end
		end)
	end
	
	-- Toggle dropdown
	button.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		dropdown.Visible = isOpen
		
		if isOpen then
			Utils:Animate(arrow, {Rotation = 180}, 0.2)
		else
			Utils:Animate(arrow, {Rotation = 0}, 0.2)
		end
	end)
	
	-- Efectos hover
	button.MouseEnter:Connect(function()
		Utils:Animate(button, {BackgroundColor3 = Utils:LerpColor(self.Window.Theme.Primary, Color3.fromRGB(255, 255, 255), 0.1)})
	end)
	
	button.MouseLeave:Connect(function()
		Utils:Animate(button, {BackgroundColor3 = self.Window.Theme.Primary})
	end)
	
	return {
		Container = container,
		SetValue = function(index)
			if options[index] then
				selectedIndex = index
				button.Text = options[index]
				if callback then callback(options[index], index) end
			end
		end,
		GetValue = function() return options[selectedIndex], selectedIndex end
	}
end

function Tab:CreateTextbox(text, placeholder, callback, config)
	config = config or {}
	
	local container = Instance.new("Frame")
	container.Name = "Textbox"
	container.Size = UDim2.new(1, -40, 0, 55)
	container.BackgroundColor3 = self.Window.Theme.Surface
	container.BorderSizePixel = 0
	container.ZIndex = 5
	container.Parent = self.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = container
	
	-- Etiqueta
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -20, 0, 20)
	label.Position = UDim2.new(0, 10, 0, 5)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Window.Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = container
	
	-- Campo de texto
	local textbox = Instance.new("TextBox")
	textbox.Name = "Textbox"
	textbox.Size = UDim2.new(1, -20, 0, 25)
	textbox.Position = UDim2.new(0, 10, 0, 25)
	textbox.BackgroundColor3 = self.Window.Theme.Secondary
	textbox.BorderSizePixel = 1
	textbox.BorderColor3 = self.Window.Theme.Border
	textbox.Text = ""
	textbox.PlaceholderText = placeholder or "Escribir aquí..."
	textbox.TextColor3 = self.Window.Theme.Text
	textbox.PlaceholderColor3 = self.Window.Theme.TextSecondary
	textbox.Font = Enum.Font.Gotham
	textbox.TextSize = 13
	textbox.ClearButtonOnFocus = false
	textbox.ZIndex = 6
	textbox.Parent = container
	
	local textboxCorner = Instance.new("UICorner")
	textboxCorner.CornerRadius = UDim.new(0, 4)
	textboxCorner.Parent = textbox
	
	-- Eventos
	textbox.Focused:Connect(function()
		Utils:Animate(textbox, {BorderColor3 = self.Window.Theme.Primary}, 0.2)
	end)
	
	textbox.FocusLost:Connect(function(enterPressed)
		Utils:Animate(textbox, {BorderColor3 = self.Window.Theme.Border}, 0.2)
		if enterPressed and callback then
			callback(textbox.Text)
		end
	end)
	
	return {
		Container = container,
		SetText = function(newText) textbox.Text = newText end,
		GetText = function() return textbox.Text end,
		Clear = function() textbox.Text = "" end
	}
end

function Tab:CreateColorPicker(text, default, callback, config)
	config = config or {}
	default = default or Color3.fromRGB(255, 255, 255)
	
	local container = Instance.new("Frame")
	container.Name = "ColorPicker"
	container.Size = UDim2.new(1, -40, 0, 40)
	container.BackgroundColor3 = self.Window.Theme.Surface
	container.BorderSizePixel = 0
	container.ZIndex = 5
	container.Parent = self.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = container
	
	-- Etiqueta
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Window.Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = container
	
	-- Muestra de color
	local colorSample = Instance.new("Frame")
	colorSample.Name = "ColorSample"
	colorSample.Size = UDim2.new(0, 50, 0, 25)
	colorSample.Position = UDim2.new(1, -65, 0.5, -12.5)
	colorSample.BackgroundColor3 = default
	colorSample.BorderSizePixel = 1
	colorSample.BorderColor3 = self.Window.Theme.Border
	colorSample.ZIndex = 6
	colorSample.Parent = container
	
	local sampleCorner = Instance.new("UICorner")
	sampleCorner.CornerRadius = UDim.new(0, 4)
	sampleCorner.Parent = colorSample
	
	-- Botón invisible para abrir picker
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.ZIndex = 7
	button.Parent = container
	
	-- Estado
	local currentColor = default

	
	button.MouseButton1Click:Connect(function()
		-- Aquí iría un color picker completo
		-- Por simplicidad, alterna entre algunos colores
		local colors = {
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 0, 255),
			Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(255, 255, 255)
		}
		local idx = 1
		for i, c in ipairs(colors) do
			if currentColor == c then idx = i break end
		end
		idx = idx % #colors + 1
		currentColor = colors[idx]
		colorSample.BackgroundColor3 = currentColor
		if callback then callback(currentColor) end
	end)
	
	return {
		Container = container,
		SetColor = function(c)
			currentColor = c
			colorSample.BackgroundColor3 = c
		end,
		GetColor = function() return currentColor end
	}
end

-- API de ventana principal
function EvolutionLibs.CreateWindow(config)
	return Window.new(config)
end

-- Notificaciones toast (simplificado)
function EvolutionLibs:Notify(text, type, duration)
	duration = duration or 2
	local gui = Instance.new("ScreenGui")
	gui.Name = "EvolutionToast"
	gui.Parent = PlayerGui
	local toast = Instance.new("TextLabel")
	toast.Size = UDim2.new(0, 320, 0, 40)
	toast.Position = UDim2.new(0.5, -160, 0.1, 0)
	toast.BackgroundColor3 = self.Themes.Dark.Primary
	toast.TextColor3 = Color3.fromRGB(255,255,255)
	toast.Text = text
	toast.Font = Enum.Font.GothamBold
	toast.TextSize = 16
	toast.BackgroundTransparency = 0.1
	toast.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = toast
	Utils:Animate(toast, {BackgroundTransparency = 0.1}, 0.2)
	delay(duration, function()
		Utils:Animate(toast, {BackgroundTransparency = 1}, 0.3)
		wait(0.3)
		gui:Destroy()
	end)
end

return EvolutionLibs 
