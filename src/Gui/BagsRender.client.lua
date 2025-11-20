local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BagsModule = require(ReplicatedStorage.Modules.BagsClient)

RunService.RenderStepped:Connect(function()
    for _, v in BagsModule.CurrentBags do
        v:UpdatePosition()
    end
end)