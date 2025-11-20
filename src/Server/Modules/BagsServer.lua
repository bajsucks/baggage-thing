local module = {}
local Bags = {}
Bags.__index = Bags
local CurrentBags = {}
module.CurrentBags = CurrentBags

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
assert(Remotes, "Missing a remote folder (ReplicatedStorage/Remotes/Baggage)!")

Remotes = Remotes:FindFirstChild("Baggage")
assert(Remotes, "Missing a remote folder (ReplicatedStorage/Remotes/Baggage)!")

-- those asserts look bad but idfk how else to force the place to have those folders

local Settings = {
    Speed = 5
}

local function GetRandomColor()
    return Color3.fromHSV(math.random(), math.random(70, 100)/100, 1)
end

local function GetRandomMaterial()
    local Materials = Enum.Material:GetEnumItems()
    return Materials[math.random(#Materials)]
end

local IdCounter = 0
function module.new()
    local Color = GetRandomColor()
    local Material = GetRandomMaterial()
    IdCounter += 1
    local ID = tostring(IdCounter)
    local bag = {
        ID = ID,
        Speed = Settings.Speed,
        SpawnTime = workspace:GetServerTimeNow(),
        Color = Color,
        Material = Material,
        Rotation = math.random(0, 60)
    }
    CurrentBags[ID] = bag
    Remotes.BagSpawn:FireAllClients(bag)
    return bag
end

function Bags.Destroy(self:Bag)
    CurrentBags[self.ID] = nil
end

Remotes.GetBags.OnServerInvoke = function()
    return CurrentBags
end

export type Bag = typeof(module.new())


return module