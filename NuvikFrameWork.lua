--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║          NUVIK FRAMEWORK V2.0 - EXECUTOR EDITION          ║
    ║              Compatible con todos los executors           ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local NuvikFramework = {}

-- ========================================
-- COMPATIBILIDAD CON EXECUTORS
-- ========================================
local function getService(serviceName)
    return game:GetService(serviceName)
end

local Players = getService("Players")
local Workspace = game.Workspace or workspace
local Lighting = getService("Lighting")
local RunService = getService("RunService")

-- ========================================
-- LOGGER SIMPLE
-- ========================================
local Logger = {}
function Logger.new()
    local self = {}
    self.logs = {}
    
    function self:info(msg)
        print("[INFO] " .. msg)
        table.insert(self.logs, {type = "INFO", msg = msg, time = tick()})
    end
    
    function self:warn(msg)
        warn("[WARN] " .. msg)
        table.insert(self.logs, {type = "WARN", msg = msg, time = tick()})
    end
    
    function self:error(msg)
        warn("[ERROR] " .. msg)
        table.insert(self.logs, {type = "ERROR", msg = msg, time = tick()})
    end
    
    function self:get_logs()
        return self.logs
    end
    
    return self
end

-- ========================================
-- MÓDULO: PLAYER MANAGER
-- ========================================
local PlayerManager = {}
function PlayerManager.new()
    local self = {}
    
    function self:get_all_players()
        local players = Players:GetPlayers()
        local result = {}
        
        for i, player in ipairs(players) do
            result[player.Name] = {
                Name = player.Name,
                DisplayName = player.DisplayName,
                UserId = player.UserId,
                Team = player.Team and player.Team.Name or "No Team",
                Character = player.Character and "Loaded" or "Not Loaded"
            }
        end
        
        return result
    end
    
    function self:find_player(name)
        name = string.lower(tostring(name))
        
        for i, player in ipairs(Players:GetPlayers()) do
            if string.find(string.lower(player.Name), name) or 
               string.find(string.lower(player.DisplayName), name) then
                return player
            end
        end
        
        return nil
    end
    
    function self:get_player_info(player)
        if not player then return nil end
        
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        return {
            Name = player.Name,
            DisplayName = player.DisplayName,
            Health = hum and hum.Health or 0,
            MaxHealth = hum and hum.MaxHealth or 100,
            Position = root and tostring(root.Position) or "N/A",
            WalkSpeed = hum and hum.WalkSpeed or 16,
            JumpPower = hum and hum.JumpPower or 50
        }
    end
    
    function self:teleport_to(player, position)
        if not player or not player.Character then return false end
        
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        
        root.CFrame = CFrame.new(position)
        return true
    end
    
    function self:modify_humanoid(player, property, value)
        if not player or not player.Character then return false end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        
        pcall(function()
            hum[property] = value
        end)
        return true
    end
    
    function self:get_distance_between(player1, player2)
        if not player1 or not player1.Character then return nil end
        if not player2 or not player2.Character then return nil end
        
        local root1 = player1.Character:FindFirstChild("HumanoidRootPart")
        local root2 = player2.Character:FindFirstChild("HumanoidRootPart")
        
        if not root1 or not root2 then return nil end
        
        return (root1.Position - root2.Position).Magnitude
    end
    
    return self
end

-- ========================================
-- MÓDULO: ENVIRONMENT MANAGER
-- ========================================
local EnvironmentManager = {}
function EnvironmentManager.new()
    local self = {}
    
    function self:get_lighting_info()
        return {
            ClockTime = Lighting.ClockTime,
            Brightness = Lighting.Brightness,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            TimeOfDay = Lighting.TimeOfDay
        }
    end
    
    function self:set_time(time_value)
        if type(time_value) == "number" then
            Lighting.ClockTime = time_value
        else
            Lighting.TimeOfDay = tostring(time_value)
        end
    end
    
    function self:set_fog(start_distance, end_distance)
        Lighting.FogStart = start_distance or 0
        Lighting.FogEnd = end_distance or 100000
    end
    
    function self:set_brightness(value)
        Lighting.Brightness = value or 1
    end
    
    function self:get_workspace_info()
        local parts = 0
        local models = 0
        
        for i, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                parts = parts + 1
            elseif obj:IsA("Model") then
                models = models + 1
            end
        end
        
        return {
            Name = Workspace.Name,
            Gravity = Workspace.Gravity,
            Parts = parts,
            Models = models,
            StreamingEnabled = Workspace.StreamingEnabled
        }
    end
    
    function self:find_parts(name_pattern, max_results)
        max_results = max_results or 50
        local results = {}
        local count = 0
        
        for i, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if string.find(string.lower(obj.Name), string.lower(name_pattern)) then
                    table.insert(results, {
                        Name = obj.Name,
                        Position = tostring(obj.Position),
                        Size = tostring(obj.Size),
                        Material = tostring(obj.Material),
                        Path = obj:GetFullName()
                    })
                    
                    count = count + 1
                    if count >= max_results then
                        break
                    end
                end
            end
        end
        
        return results
    end
    
    function self:set_gravity(value)
        Workspace.Gravity = value or 196.2
    end
    
    return self
end

-- ========================================
-- MÓDULO: ESP & VISUALS
-- ========================================
local VisualsManager = {}
function VisualsManager.new()
    local self = {}
    self.esp_enabled = false
    self.esp_objects = {}
    
    function self:create_esp(player)
        if not player or not player.Character then return end
        
        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Crear BillboardGui
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_" .. player.Name
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = root
        
        -- Crear texto
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = player.Name
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeTransparency = 0.5
        text.TextScaled = true
        text.Font = Enum.Font.SourceSansBold
        text.Parent = billboard
        
        self.esp_objects[player.Name] = billboard
    end
    
    function self:remove_esp(player)
        if self.esp_objects[player.Name] then
            self.esp_objects[player.Name]:Destroy()
            self.esp_objects[player.Name] = nil
        end
    end
    
    function self:enable_esp_all()
        for i, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                self:create_esp(player)
            end
        end
        self.esp_enabled = true
    end
    
    function self:disable_esp_all()
        for name, obj in pairs(self.esp_objects) do
            obj:Destroy()
        end
        self.esp_objects = {}
        self.esp_enabled = false
    end
    
    function self:highlight_part(part, color)
        if not part or not part:IsA("BasePart") then return end
        
        local highlight = Instance.new("SelectionBox")
        highlight.Adornee = part
        highlight.Color3 = color or Color3.fromRGB(255, 0, 0)
        highlight.LineThickness = 0.05
        highlight.Parent = part
        
        return highlight
    end
    
    return self
end

-- ========================================
-- MÓDULO: UTILITIES
-- ========================================
local Utilities = {}
function Utilities.new()
    local self = {}
    
    function self:format_time(seconds)
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d:%02d", hours, mins, secs)
    end
    
    function self:format_number(num)
        local formatted = tostring(num)
        local k
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formatted
    end
    
    function self:random_string(length)
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        local result = ""
        for i = 1, length do
            local rand = math.random(1, #chars)
            result = result .. string.sub(chars, rand, rand)
        end
        return result
    end
    
    function self:distance(pos1, pos2)
        return (pos1 - pos2).Magnitude
    end
    
    function self:vector_to_string(vec)
        return string.format("(%.1f, %.1f, %.1f)", vec.X, vec.Y, vec.Z)
    end
    
    function self:color_to_rgb(color)
        return {
            R = math.floor(color.R * 255),
            G = math.floor(color.G * 255),
            B = math.floor(color.B * 255)
        }
    end
    
    function self:copy_table(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                copy[k] = self:copy_table(v)
            else
                copy[k] = v
            end
        end
        return copy
    end
    
    function self:table_to_string(tbl, indent)
        indent = indent or 0
        local result = "{\n"
        local spacing = string.rep("  ", indent)
        
        for k, v in pairs(tbl) do
            local key = type(k) == "string" and '"' .. k .. '"' or tostring(k)
            local value
            
            if type(v) == "table" then
                value = self:table_to_string(v, indent + 1)
            elseif type(v) == "string" then
                value = '"' .. v .. '"'
            else
                value = tostring(v)
            end
            
            result = result .. spacing .. "  [" .. key .. "] = " .. value .. ",\n"
        end
        
        return result .. spacing .. "}"
    end
    
    return self
end

-- ========================================
-- MÓDULO: GAME UTILITIES
-- ========================================
local GameUtils = {}
function GameUtils.new()
    local self = {}
    
    function self:get_local_player()
        return Players.LocalPlayer
    end
    
    function self:get_character()
        local player = Players.LocalPlayer
        return player and player.Character
    end
    
    function self:get_humanoid()
        local char = self:get_character()
        return char and char:FindFirstChildOfClass("Humanoid")
    end
    
    function self:get_root_part()
        local char = self:get_character()
        return char and char:FindFirstChild("HumanoidRootPart")
    end
    
    function self:is_alive()
        local hum = self:get_humanoid()
        return hum and hum.Health > 0
    end
    
    function self:noclip(enabled)
        local char = self:get_character()
        if not char then return end
        
        for i, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
    
    function self:god_mode(enabled)
        local hum = self:get_humanoid()
        if not hum then return end
        
        if enabled then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        else
            hum.MaxHealth = 100
            hum.Health = 100
        end
    end
    
    function self:infinite_jump(enabled)
        if enabled then
            game:GetService("UserInputService").JumpRequest:Connect(function()
                local hum = self:get_humanoid()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
    
    return self
end

-- ========================================
-- CORE FRAMEWORK
-- ========================================
function NuvikFramework.new()
    local self = {}
    
    -- Inicializar logger
    self.logger = Logger.new()
    
    -- Inicializar módulos
    self.modules = {
        Player = PlayerManager.new(),
        Environment = EnvironmentManager.new(),
        Visuals = VisualsManager.new(),
        Utility = Utilities.new(),
        Game = GameUtils.new()
    }
    
    -- Info del framework
    self.info = {
        version = "2.0-EXECUTOR",
        build = "2024",
        start_time = tick()
    }
    
    -- Función para obtener módulos
    function self:get(module_name)
        return self.modules[module_name]
    end
    
    -- Listar módulos
    function self:list_modules()
        local list = {}
        for name, _ in pairs(self.modules) do
            table.insert(list, name)
        end
        return list
    end
    
    -- Estadísticas
    function self:get_stats()
        return {
            version = self.info.version,
            uptime = tick() - self.info.start_time,
            uptime_formatted = self.modules.Utility:format_time(tick() - self.info.start_time),
            modules = self:list_modules(),
            memory = collectgarbage("count")
        }
    end
    
    self.logger:info("Nuvik Framework initialized!")
    
    return self
end

-- ========================================
-- INICIALIZACIÓN Y DEMO
-- ========================================
print("\n" .. string.rep("=", 60))
print("    🚀 NUVIK FRAMEWORK V2.0 - EXECUTOR EDITION")
print(string.rep("=", 60))

-- Crear framework
local framework = NuvikFramework.new()

-- Mostrar info
print("\n📋 Framework Info:")
local stats = framework:get_stats()
print("  • Version:", stats.version)
print("  • Modules:", table.concat(stats.modules, ", "))
print("  • Memory:", string.format("%.2f KB", stats.memory))

-- Demo: Players
print("\n👥 PLAYER DEMO:")
local player_mgr = framework:get("Player")
local players = player_mgr:get_all_players()

for name, data in pairs(players) do
    print(string.format("  • %s | Team: %s | Status: %s", 
        data.Name, data.Team, data.Character))
end

-- Demo: Environment
print("\n🌍 ENVIRONMENT DEMO:")
local env = framework:get("Environment")
local lighting = env:get_lighting_info()
print(string.format("  • Time: %s | Brightness: %.1f", 
    lighting.TimeOfDay, lighting.Brightness))

local ws_info = env:get_workspace_info()
print(string.format("  • Parts: %d | Models: %d | Gravity: %.1f", 
    ws_info.Parts, ws_info.Models, ws_info.Gravity))

-- Demo: Utilities
print("\n🛠️ UTILITIES DEMO:")
local util = framework:get("Utility")
print("  • Random String:", util:random_string(10))
print("  • Formatted Time:", util:format_time(tick()))

-- Demo: Game Utils
print("\n🎮 GAME UTILS DEMO:")
local game_utils = framework:get("Game")
local local_player = game_utils:get_local_player()
if local_player then
    print("  • Local Player:", local_player.Name)
    print("  • Is Alive:", tostring(game_utils:is_alive()))
end

print("\n" .. string.rep("=", 60))
print("    ✅ Framework ready! Use '_G.Nuvik' to access")
print(string.rep("=", 60) .. "\n")

-- Guardar en global para fácil acceso
_G.Nuvik = framework

print([[
EJEMPLOS DE USO:

-- Obtener jugadores
local players = _G.Nuvik:get("Player"):get_all_players()

-- Cambiar hora del día
_G.Nuvik:get("Environment"):set_time(12)

-- Activar ESP
_G.Nuvik:get("Visuals"):enable_esp_all()

-- Modificar velocidad
local player = game.Players.LocalPlayer
_G.Nuvik:get("Player"):modify_humanoid(player, "WalkSpeed", 100)

-- NoClip
_G.Nuvik:get("Game"):noclip(true)

-- God Mode
_G.Nuvik:get("Game"):god_mode(true)
]])

return NuvikFramework
