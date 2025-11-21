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

local Conveyor: Model = ReplicatedStorage.Assets.Baggage.Conveyor:Clone()
Conveyor.PrimaryPart = Conveyor.Belt
local End: Part = ReplicatedStorage.Assets.Baggage.End:Clone()
local Start: Part = ReplicatedStorage.Assets.Baggage.Start:Clone()
local Bag = ReplicatedStorage.Assets.Baggage.Bag
Bag.PrimaryPart = Bag.body
local Bagsf = Instance.new("Folder")
Bagsf.Name = "Bags"
Bagsf.Parent = workspace
Conveyor.Parent = workspace
End.Parent = workspace
Start.Parent = workspace
RunService.Heartbeat:Connect(function(dt)
    totaldt += dt
    if totaldt >= Settings.SpawnDelay then
        BagModule.new()
        totaldt = 0
    end
    local t = workspace:GetServerTimeNow()
    for _, self in BagModule.CurrentBags do 
        local ConveyorLength = Conveyor.PrimaryPart.Size.Z
        local BagLifetime = t - self.SpawnTime
        local DeathTime = self.SpawnTime + self.Speed / ConveyorLength
        if BagLifetime >= DeathTime then
            self:Destroy()
        end
    end
end)

ReplicatedStorage.Remotes.Baggage.BagClick.OnServerEvent:Connect(function(_, ID)
    print(ID)
end)
