-- Auto-Farm Money Script with Rayfield UI
-- Rayfield UI Setup
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Delivery Job Auto-Farm",
    Icon = "truck",
    LoadingTitle = "Loading Delivery Job Auto-Farm",
    LoadingSubtitle = "by User",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AutoFarmConfigs",
        FileName = "DeliveryJobAutoFarm"
    }
})

local DeliveryJobTab = Window:CreateTab("Delivery Job", "dollar-sign")

local AutoFarmSection = DeliveryJobTab:CreateSection("Auto-Farm Money")

local AutoFarmEnabled = false
local AutoFarmConnection

local function startAutoFarm()
    if AutoFarmConnection then AutoFarmConnection:Disconnect() end
    AutoFarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not AutoFarmEnabled then
            if AutoFarmConnection then AutoFarmConnection:Disconnect() end
            return
        end

        Rayfield:Notify({
            Title = "Auto-Farm Status",
            Content = "Auto-Farm is ongoing...",
            Duration = 4,
            Image = "repeat"
        })

        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local pickupBox = workspace:FindFirstChild("DeliveryJob") and workspace.DeliveryJob:FindFirstChild("BoxPickingJob") and workspace.DeliveryJob.BoxPickingJob:FindFirstChild("PickupBox")
        local jobLocation = workspace:FindFirstChild("DeliveryJob") and workspace.DeliveryJob:FindFirstChild("BoxPickingJob") and workspace.DeliveryJob.BoxPickingJob:FindFirstChild("Job")

        if pickupBox and pickupBox:FindFirstChild("PickupPrompt") then
            root.CFrame = pickupBox.CFrame
            task.wait(0.5)
            pcall(function()
                fireproximityprompt(pickupBox.PickupPrompt)
            end)
            task.wait(pickupBox.PickupPrompt.HoldDuration + 0.5)
        end

        if jobLocation and jobLocation:FindFirstChild("Part") and jobLocation.Part:FindFirstChild("ProximityPrompt") then
            root.CFrame = jobLocation.Part.CFrame
            task.wait(0.5)
            pcall(function()
                fireproximityprompt(jobLocation.Part.ProximityPrompt)
            end)
            task.wait(jobLocation.Part.ProximityPrompt.HoldDuration + 0.5)
        end
    end)
end

DeliveryJobTab:CreateToggle({
    Name = "Auto-Farm Money",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(value)
        AutoFarmEnabled = value
        if AutoFarmEnabled then
            startAutoFarm()
        end
    end
})

Rayfield:LoadConfiguration()
