local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

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
while task.wait(Settings.SpawnDelay) do
    BagModule.new()
end