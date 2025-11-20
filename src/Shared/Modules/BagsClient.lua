local module = {}
local Bags = {}
Bags.__index = Bags

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes: Folder = ReplicatedStorage.Remotes.Baggage
local Assets: Folder = ReplicatedStorage:FindFirstChild("Assets")
assert(Assets, "Missing a bag template in ReplicatedStorage/Assets/Baggage/Bag!")

local Baggage: Folder = Assets:FindFirstChild("Baggage")
assert(Baggage, "Missing a bag template in ReplicatedStorage/Assets/Baggage/Bag!")

local BagTemplate: Model = Baggage:FindFirstChild("Bag")
assert(BagTemplate, "Missing a bag template in ReplicatedStorage/Assets/Baggage/Bag!")

-- ahh asserts

local Conveyor: Model = workspace.Conveyor

local StartPart: Part = workspace:WaitForChild("Start")
local EndPart: Part = workspace:WaitForChild("End")
local EmitStart: ParticleEmitter = StartPart:WaitForChild("emitter")
local EmitEnd: ParticleEmitter = EndPart:WaitForChild("emitter")

local Settings = {
    EmitCount = 30,
}
module.Settings = Settings

local CurrentBags = {}
module.CurrentBags = CurrentBags

export type Bag = {
    ID: string,
    Speed: number,
    SpawnTime: number,
    Color: Color3,
    Material: Enum.Material,
    Rotation: number,
    Model: Model?
}

function module.new(self:Bag, DisableEmit:boolean?)
    local model = BagTemplate:Clone()
    model.Parent = workspace:WaitForChild("Bags")
    local primary = model.PrimaryPart
    primary.Color = self.Color
    primary.Material = self.Material
    self.Model = model
    setmetatable(self, Bags)
    CurrentBags[self.ID] = self
    if not DisableEmit then
        EmitStart:Emit(Settings.EmitCount)
    end

    return self
end

function Bags.UpdatePosition(self:Bag)
    local ConveyorLength = Conveyor.PrimaryPart.Size.Z
    local BagLifetime = workspace:GetServerTimeNow() - self.SpawnTime
    local TravelDistance = BagLifetime * self.Speed
    if ConveyorLength <= TravelDistance then
        self:Destroy()
        return
    end  
    local ConveyorPivot = Conveyor.PrimaryPart:GetPivot()
    local StartPivot = ConveyorPivot - ConveyorPivot.LookVector * (ConveyorLength / 2)
    -- could just put pivot on the start but it'll make great pain for whoever sets this conveyor up
    self.Model:PivotTo((StartPivot + ConveyorPivot.LookVector * TravelDistance) * CFrame.Angles(0, self.Rotation, 0))
end

function Bags.Destroy(self:Bag)
    self.Model:Destroy()
    EmitEnd:Emit(Settings.EmitCount)
    CurrentBags[self.ID] = nil
end

Remotes.BagSpawn.OnClientEvent:Connect(function(bag:Bag)
    for ID, _ in CurrentBags do
        if ID == bag.ID then return end
    end
    module.new(bag)
end)

for _, bag in Remotes.GetBags:InvokeServer() do
    for ID, _ in CurrentBags do
        if ID == bag.ID then break end
    end
    module.new(bag, true)

end
-- t

return module