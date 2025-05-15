-- Auto-Farm Money Script with Rayfield UI
-- Rayfield UI Setup
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Delivery Job Auto-Farm",
    Icon = "truck",
    LoadingTitle = "Delivery Job Auto Farm 1.2.3",
    LoadingSubtitle = "by Lomi",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "AutoFarmConfigs",
        FileName = "DeliveryJobAutoFarm"
    }
})

local DeliveryJobTab = Window:CreateTab("Delivery Job", "dollar-sign")

local AutoFarmSection = DeliveryJobTab:CreateSection("Auto-Farm Money")

local AutoFarmEnabled = false
local AutoFarmConnection
local AutoFarmKeybind = "F"
local selectedJob = ""

local function cementJob()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pickupBox = workspace:FindFirstChild("DeliveryJob") and workspace.DeliveryJob:FindFirstChild("BoxPickingJob") and workspace.DeliveryJob.BoxPickingJob:FindFirstChild("PickupBox")
    local jobLocation = workspace:FindFirstChild("DeliveryJob") and workspace.DeliveryJob:FindFirstChild("BoxPickingJob") and workspace.DeliveryJob.BoxPickingJob:FindFirstChild("Job")

    while AutoFarmEnabled do
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
    end
end

local function jntJob()
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local packageGiver = workspace:FindFirstChild("PackageGiver")
    local locations = workspace:FindFirstChild("Locations")

    while AutoFarmEnabled do
        -- Pickup Package
        if packageGiver and packageGiver:FindFirstChild("ProximityPrompt") then
            root.CFrame = packageGiver.CFrame
            task.wait(0.5)
            pcall(function()
                fireproximityprompt(packageGiver.ProximityPrompt)
            end)
            task.wait(packageGiver.ProximityPrompt.HoldDuration + 0.5)
        end

        -- Iterate through all locations
        if locations then
            for _, location in pairs(locations:GetChildren()) do
                if location and location:FindFirstChild("ProximityPrompt") then
                    root.CFrame = location.CFrame
                    task.wait(0.5)
                    pcall(function()
                        fireproximityprompt(location.ProximityPrompt)
                    end)
                    task.wait(location.ProximityPrompt.HoldDuration + 0.5)
                end
            end
        end
    end
end

    local packageGiver = workspace:FindFirstChild("PackageGiver")
    local locations = workspace:FindFirstChild("Locations")

    while AutoFarmEnabled do
        if packageGiver and packageGiver:FindFirstChild("ProximityPrompt") then
            root.CFrame = packageGiver.CFrame
            task.wait(0.5)
            pcall(function()
                fireproximityprompt(packageGiver.ProximityPrompt)
            end)
            task.wait(packageGiver.ProximityPrompt.HoldDuration + 0.5)
        end

        if locations then
            local location = locations:GetChildren()[math.random(1, #locations:GetChildren())]
            if location and location:FindFirstChild("ProximityPrompt") then
                root.CFrame = location.CFrame
                task.wait(0.5)
                pcall(function()
                    fireproximityprompt(location.ProximityPrompt)
                end)
                task.wait(location.ProximityPrompt.HoldDuration + 0.5)
            end
        end
    end
end

local function startAutoFarm()
    if not AutoFarmConnection then
        Rayfield:Notify({
            Title = "Auto-Farm Status",
            Content = "Auto-Farm started",
            Duration = 4,
            Image = "repeat"
        })
        AutoFarmEnabled = true
        if selectedJob == "Cement Job" then
            AutoFarmConnection = task.spawn(cementJob)
        elseif selectedJob == "JNT Job" then
            AutoFarmConnection = task.spawn(jntJob)
        end
    end
end

local function stopAutoFarm()
    AutoFarmEnabled = false
    if AutoFarmConnection then
        Rayfield:Notify({
            Title = "Auto-Farm Status",
            Content = "Auto-Farm stopped",
            Duration = 4,
            Image = "repeat"
        })
        AutoFarmConnection = nil
    end
end

DeliveryJobTab:CreateDropdown({
    Name = "Select Job",
    Options = {"Cement Job", "JNT Job"},
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "JobDropdown",
    Callback = function(selected)
        selectedJob = selected[1] or ""
    end
})

DeliveryJobTab:CreateToggle({
    Name = "Auto-Farm Money",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(value)
        if value then
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end
})

DeliveryJobTab:CreateKeybind({
    Name = "Auto-Farm Keybind",
    CurrentKeybind = AutoFarmKeybind,
    HoldToInteract = false,
    Flag = "AutoFarmKeybind",
    Callback = function()
        AutoFarmEnabled = not AutoFarmEnabled
        if AutoFarmEnabled then
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end
})

-- Items Tab
local ItemsTab = Window:CreateTab("Items", "shopping-cart")
local BuySection = ItemsTab:CreateSection("Buy Items")

local itemsList = {}
for _, item in pairs(game:GetService("ReplicatedStorage").Weapons:GetChildren()) do
    table.insert(itemsList, item.Name)
end

local selectedItem = ""

local ItemDropdown = ItemsTab:CreateDropdown({
    Name = "Items List",
    Options = itemsList,
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "ItemDropdown",
    Callback = function(selected)
        selectedItem = selected[1] or ""
    end
})

ItemsTab:CreateButton({
    Name = "Buy Item",
    Callback = function()
        if selectedItem ~= "" then
            game:GetService("ReplicatedStorage").PurchaseEvent:FireServer(selectedItem)
            Rayfield:Notify({
                Title = "Purchase",
                Content = "Purchased " .. selectedItem,
                Duration = 4,
                Image = "check"
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Please select an item to purchase.",
                Duration = 4,
                Image = "x"
            })
        end
    end
})

-- Misc Tab
local MiscTab = Window:CreateTab("Misc", "settings")

local MiscSection = MiscTab:CreateSection("Scripts")

MiscTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

MiscTab:CreateButton({
    Name = "Cobalt Spy",
    Callback = function()
        loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()
    end
})

MiscTab:CreateButton({
    Name = "Bypass Adonis",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/iMvnRVBg"))()
    end
})

Rayfield:LoadConfiguration()
