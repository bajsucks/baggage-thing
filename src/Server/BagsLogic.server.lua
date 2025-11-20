local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Settings = {
    SpawnDelay = 1,
    SliderOwner = nil
}

local BagModule = require(ServerScriptService.Modules.BagsServer)

Players.PlayerAdded:Connect(function(Player)
    if not Settings.SliderOwner then
        Settings.SliderOwner = Player
    end
end)
local function IsAdmin(Player)
    return Settings.SliderOwner == Player
end
ReplicatedStorage.Remotes.Baggage.IsAdmin.OnServerInvoke = function(Player)
    return IsAdmin(Player)
end
ReplicatedStorage.Remotes.Baggage.SpawnDelay.OnServerEvent:Connect(function(Player, value)
    if IsAdmin(Player) and value >= 0.01 then
        Settings.SpawnDelay = value
    end
end)
local totaldt = 0
RunService.Heartbeat:Connect(function(dt)
    totaldt += dt
    if totaldt >= Settings.SpawnDelay then
        BagModule.new()
        totaldt = 0
    end
end)