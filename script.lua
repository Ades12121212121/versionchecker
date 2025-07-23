-- Script de teletransporte súper potente para Roblox
-- Versión mejorada con retención verdaderamente efectiva

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local virtualUser = game:GetService("VirtualUser")

-- Variables globales del sistema
local retainedObjects = {}
local retentionActive = false
local autoClickerActive = false
local isAttacking = false
local godModeActive = false
local RETAIN_DISTANCE = 12
local RETENTION_FORCE = 50

-- Nombres de bots comunes
local BOT_NAMES = {
    ["Dummy"] = true,
    ["Linkmon99"] = true,
    ["kay"] = true,
    ["Enemy"] = true,
    ["Training Dummy"] = true,
    ["Target"] = true,
    ["Mob"] = true,
    ["Copperhe4d"] = true,
    ["NETLUKE"] = true,
    ["agmusicgirl"] = true,
    ["djnyiah123"] = true,
    ["Linkmon99"] = true,
    ["Dark_Eccentric"] = true,
    ["Tyne"] = true,
    ["Player1"] = true,
    ["Fein"] = true,
    ["HellaParis"] = true,
    ["Okay"] = true,
    ["arab"] = true,
    ["erza"] = true,
    ["lalito"] = true,
    ["Inmate"] = true,
    ["Officer"] = true,
    ["doge"] = true,
    ["inmate"] = true,
    ["prisoner"] = true,
    ["3utterfly3ffect"] = true,
    ["Alien"] = true,
    ["Weakest Dummy"] = true,
    ["TuberBoss"] = true
}

local function createGui()
    -- Eliminar GUI previa
    local oldGui = playerGui:FindFirstChild("PowerTeleportGui")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PowerTeleportGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Frame principal minimalista
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 220, 0, 270)
    mainFrame.Position = UDim2.new(0, 30, 0, 30)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true

    -- Bordes redondeados
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- Sombra sutil
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.85
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 14)
    shadowCorner.Parent = shadow

    -- Título minimalista
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -30, 0, 32)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "CONTROL"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame

    -- Botón X para cerrar la GUI
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -28, 0, 4)
    closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.BorderSizePixel = 0
    closeButton.Parent = mainFrame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Línea divisoria
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0.9, 0, 0, 1)
    divider.Position = UDim2.new(0.05, 0, 0, 36)
    divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    divider.BorderSizePixel = 0
    divider.Parent = mainFrame

    -- Función para obtener posición enfrente del jugador
    local function getFrontPosition()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart
            return root.Position + (root.CFrame.LookVector * RETAIN_DISTANCE)
        end
        return nil
    end

    -- Sistema de retención súper potente con detección automática de respawn
    local retentionConnection
    local playerConnections = {}
    
    local function updateRetainedObjects()
        if not retentionActive then return end
        
        -- Limpiar objetos que ya no existen
        for target, rootPart in pairs(retainedObjects) do
            if not rootPart or not rootPart.Parent then
                retainedObjects[target] = nil
            end
        end
        
        -- Agregar jugadores que respawnearon
        for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local root = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and not retainedObjects[otherPlayer] then
                    retainedObjects[otherPlayer] = root
                    
                    -- Deshabilitar controles del jugador
                    pcall(function()
                        local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.PlatformStand = true
                        end
                    end)
                end
            end
        end
        
        -- Agregar bots que puedan haber respawneado
        for _, obj in ipairs(workspace:GetChildren()) do
            if (BOT_NAMES[obj.Name] or obj.Name:find("Bot") or obj.Name:find("NPC") or obj.Name:find("Dummy")) and obj:IsA("Model") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
                if root and not retainedObjects[obj] then
                    retainedObjects[obj] = root
                end
            end
        end
    end
    
    local function startPowerfulRetention()
        if retentionConnection then retentionConnection:Disconnect() end
        
        retentionConnection = runService.Heartbeat:Connect(function()
            if not retentionActive then return end
            
            -- Actualizar objetos retenidos cada frame
            updateRetainedObjects()
            
            local frontPos = getFrontPosition()
            if not frontPos then return end
            
            for target, rootPart in pairs(retainedObjects) do
                if rootPart and rootPart.Parent then
                    -- Fuerza de retención múltiple
                    for i = 1, 3 do
                        pcall(function()
                            rootPart.CFrame = CFrame.new(frontPos + Vector3.new(
                                math.random(-2, 2), 
                                math.random(-1, 1), 
                                math.random(-2, 2)
                            ))
                            rootPart.Velocity = Vector3.new(0, 0, 0)
                            rootPart.AngularVelocity = Vector3.new(0, 0, 0)
                            if rootPart:FindFirstChild("BodyVelocity") then
                                rootPart.BodyVelocity:Destroy()
                            end
                            if rootPart:FindFirstChild("BodyPosition") then
                                rootPart.BodyPosition:Destroy()
                            end
                        end)
                    end
                    
                    -- Crear anclaje temporal
                    pcall(function()
                        rootPart.Anchored = true
                        spawn(function()
                            wait(0.01)
                            if rootPart and rootPart.Parent then
                                rootPart.Anchored = false
                            end
                        end)
                    end)
                end
            end
        end)
    end
    
    -- Función para configurar detección de respawn de jugadores
    local function setupPlayerRespawnDetection()
        -- Limpiar conexiones previas
        for _, connection in pairs(playerConnections) do
            connection:Disconnect()
        end
        playerConnections = {}
        
        -- Configurar detección para todos los jugadores
        for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player then
                local connection = otherPlayer.CharacterAdded:Connect(function(character)
                    if retentionActive then
                        -- Esperar a que el character esté completamente cargado
                        wait(0.5)
                        local root = character:WaitForChild("HumanoidRootPart", 5)
                        if root then
                            retainedObjects[otherPlayer] = root
                            
                            -- Deshabilitar controles inmediatamente
                            pcall(function()
                                local humanoid = character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                    humanoid.PlatformStand = true
                                end
                            end)
                        end
                    end
                end)
                playerConnections[otherPlayer] = connection
            end
        end
    end
    
    -- Configurar detección cuando nuevos jugadores se unan
    game.Players.PlayerAdded:Connect(function(newPlayer)
        if retentionActive and newPlayer ~= player then
            local connection = newPlayer.CharacterAdded:Connect(function(character)
                if retentionActive then
                    wait(0.5)
                    local root = character:WaitForChild("HumanoidRootPart", 5)
                    if root then
                        retainedObjects[newPlayer] = root
                        pcall(function()
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                humanoid.PlatformStand = true
                            end
                        end)
                    end
                end
            end)
            playerConnections[newPlayer] = connection
        end
    end)

    -- Función para crear botones elegantes y pequeños
    local function createButton(text, position, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -32, 0, 28)
        btn.Position = position
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.BackgroundTransparency = 0.05
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Text = text
        btn.BorderSizePixel = 0
        btn.Parent = mainFrame
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 7)
        btnCorner.Parent = btn
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Botones compactos y minimalistas
    local retainButton = createButton("RETENER TODOS", UDim2.new(0, 16, 0, 50), function()
        retainedObjects = {}
        
        -- Configurar detección de respawn antes de iniciar retención
        setupPlayerRespawnDetection()
        
        -- Retener jugadores actualmente en el juego
        for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local root = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    retainedObjects[otherPlayer] = root
                    
                    -- Deshabilitar controles del jugador
                    pcall(function()
                        local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.PlatformStand = true
                        end
                    end)
                end
            end
        end
        
        -- Retener bots y NPCs
        for _, obj in ipairs(workspace:GetChildren()) do
            if (BOT_NAMES[obj.Name] or obj.Name:find("Bot") or obj.Name:find("NPC") or obj.Name:find("Dummy")) and obj:IsA("Model") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
                if root then
                    retainedObjects[obj] = root
                end
            end
        end
        
        retentionActive = true
        startPowerfulRetention()
        retainButton.Text = "RETENIENDO..."
        retainButton.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    end)
    local releaseButton = createButton("LIBERAR", UDim2.new(0, 16, 0, 86), function()
        retentionActive = false
        if retentionConnection then
            retentionConnection:Disconnect()
        end
        
        -- Limpiar todas las conexiones de detección de respawn
        for _, connection in pairs(playerConnections) do
            connection:Disconnect()
        end
        playerConnections = {}
        
        -- Restaurar controles de jugadores
        for target, rootPart in pairs(retainedObjects) do
            if target and target:IsA("Player") and target.Character then
                pcall(function()
                    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.PlatformStand = false
                    end
                end)
            end
        end
        
        retainedObjects = {}
        retainButton.Text = "RETENER TODOS"
        retainButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    end)
    local speedButton = createButton("SPEED BOOST", UDim2.new(0, 16, 0, 122), function()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 150
                humanoid.JumpPower = 120
            end
        end
    end)
    local godModeButton = createButton("GOD MODE: OFF", UDim2.new(0, 16, 0, 158), function()
        godModeActive = not godModeActive
        godModeButton.Text = godModeActive and "GOD MODE: ON" or "GOD MODE: OFF"
        godModeButton.BackgroundColor3 = godModeActive and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(180, 50, 255)
        
        if godModeActive then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                end
            end
        end
    end)
    local autoClickerButton = createButton("AUTO CLICK: OFF", UDim2.new(0, 16, 0, 194), function()
        autoClickerActive = not autoClickerActive
        autoClickerButton.Text = autoClickerActive and "AUTO CLICK: ON" or "AUTO CLICK: OFF"
        autoClickerButton.BackgroundColor3 = autoClickerActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 255, 100)
        
        if autoClickerActive then
            startAutoClicker()
        else
            if autoClickerConnection then
                autoClickerConnection:Disconnect()
            end
        end
    end)

    -- Sistema de autoclicker mejorado y funcional
    local autoClickerConnection
    local function startAutoClicker()
        if autoClickerConnection then autoClickerConnection:Disconnect() end
        
        autoClickerConnection = runService.Heartbeat:Connect(function()
            if not autoClickerActive then return end
            
            pcall(function()
                -- Método 1: VirtualUser con posición del mouse
                local mouse = player:GetMouse()
                if mouse then
                    virtualUser:Button1Down(Vector2.new(mouse.X, mouse.Y))
                    wait(0.01)
                    virtualUser:Button1Up(Vector2.new(mouse.X, mouse.Y))
                end
            end)
            
            pcall(function()
                -- Método 2: Simulación directa de click
                local camera = workspace.CurrentCamera
                if camera then
                    virtualUser:CaptureController()
                    virtualUser:ClickButton1(Vector2.new(400, 300))
                end
            end)
            
            pcall(function()
                -- Método 3: Activar herramientas si las hay
                local character = player.Character
                if character then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        tool:Activate()
                    end
                end
            end)
        end)
    end
    
    -- Iniciar autoclicker
    startAutoClicker()

    -- Detección de ataque mejorada con múltiples métodos
    userInputService.InputBegan:Connect(function(input, processed)
        if not processed then
            if input.KeyCode == Enum.KeyCode.F or 
               input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.KeyCode == Enum.KeyCode.E or
               input.KeyCode == Enum.KeyCode.Q then
                isAttacking = true
            end
        end
    end)

    userInputService.InputEnded:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.F or 
           input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.KeyCode == Enum.KeyCode.E or
           input.KeyCode == Enum.KeyCode.Q then
            isAttacking = false
        end
    end)
    
    -- Método alternativo usando mouse directo
    local mouse = player:GetMouse()
    if mouse then
        mouse.Button1Down:Connect(function()
            isAttacking = true
        end)
        mouse.Button1Up:Connect(function()
            isAttacking = false
        end)
    end

    -- Sistema de protección del jugador local
    local function protectLocalPlayer()
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        local lastHealth = humanoid.Health
        
        local healthConnection
        healthConnection = humanoid.HealthChanged:Connect(function(newHealth)
            if godModeActive then
                humanoid.Health = math.huge
                return
            end
            
            if newHealth < lastHealth and not isAttacking then
                humanoid.Health = lastHealth
            end
            lastHealth = humanoid.Health
        end)
        
        -- Protección contra muerte
        humanoid.Died:Connect(function()
            if godModeActive then
                wait(0.1)
                humanoid.Health = math.huge
            end
        end)
    end

    -- Inicializar protección
    if player.Character then
        protectLocalPlayer()
    end
    
    player.CharacterAdded:Connect(function()
        wait(1)
        protectLocalPlayer()
    end)

    -- Indicador de estado minimalista
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 14, 0, 14)
    statusFrame.Position = UDim2.new(1, -22, 0, 38)
    statusFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainFrame
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = statusFrame
    spawn(function()
        while screenGui.Parent do
            if retentionActive then
                statusFrame.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            else
                statusFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end
            wait(0.5)
        end
    end)
end

-- Inicializar
createGui()

-- Recrear GUI al respawnear
player.CharacterAdded:Connect(function()
    wait(2)
    createGui()
end)

print("Sistema de teletransporte súper potente cargado exitosamente")
