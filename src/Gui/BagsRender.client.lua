local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BagsModule = require(ReplicatedStorage.Modules.BagsClient)

local sliderSettings = {
    min = 0.1,
    max = 10
}
local function lerp(start:number, goal:number, alpha:number) : number
	return start + (goal - start) * alpha
end
local function inverseLerp(start:number, goal:number, alpha:number): number
	if start == goal then
		return 0
	end
	return (alpha - start) / (goal - start)
end

RunService.RenderStepped:Connect(function()
    for _, v in BagsModule.CurrentBags do
        v:UpdatePosition()
    end
end)

local IsAdmin = ReplicatedStorage.Remotes.Baggage.IsAdmin:InvokeServer()
if IsAdmin then
    local jUILib = require(ReplicatedStorage.Modules.jUILib)
    local sliderGui = script.Parent.Slider
    sliderGui.Enabled = true
    local label: TextLabel = sliderGui.holder.label
    local function getVal(sliderpos)
        local val = lerp(sliderSettings.min, sliderSettings.max, sliderpos)
        val = math.floor(val*100)/100
        return val
    end
    local function onChanged(sliderpos)
        local val = getVal(sliderpos)
        label.Text = `{val}s`
    end
    local function onEnded(sliderpos)
        local val = getVal(sliderpos)
        label.Text = `{val}s`
        ReplicatedStorage.Remotes.Baggage.SpawnDelay:FireServer(val)
    end
    local Force = jUILib.Slider(sliderGui.holder, sliderGui.holder.button, {sliderGui.holder, sliderGui.holder.button}, onChanged, onEnded)
    Force(inverseLerp(sliderSettings.min, sliderSettings.max, 1))
end