Version = "2.6"
Title = "Lomi AO "
Startup = tick()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Bin = LocalPlayer:WaitForChild("bin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("RS"):WaitForChild("Remotes")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LoadArea
local LoadNPC = nil

local IslandOffsets = {
    ["Mount Othrys"] = Vector3.new(0, 28063, -10),
    ["Harvest Island"] = Vector3.new(-234, -112, 99),
    ["Ravenna"] = Vector3.new(0, -500, 0)
}

local Islands = {}
for i,v in pairs(workspace.Map:GetChildren()) do
    if v:FindFirstChild("Center") and not v.Name:find("Shipwreck") then
        table.insert(Islands, v.Name)
    end
end

local var = {
    dmgValue = false,
    dmgMulti = 1,
    godmode = false,
    NPCBlock = false,
    FastBoatRepair = false,
    RepairMulti = 1,
    NoTracking = false,
    OneTapStructure = false,
    ToggleLightning = false,
    DrinkBottleSilent = false,
    AutoWash = false,
}

local Toggles = {
    InstantProximityPrompt = {Value = false},
    AutoEat = {Value = false}
}

local remotes = {
    "DealAttackDamage",
    "DealStrengthDamage",
    "DealWeaponDamage",
    "DealMagicDamage",
    "DealDamageBoat",
    "DealDamageBoat3",
    "DealDamageBoat2",
    "DealDamageBoat1"
}

for index, connection in next, getconnections(Remotes:WaitForChild("Misc").OnTeleport.OnClientEvent) do
    local env = connection.Function and getfenv(connection.Function)
    if env and tostring(rawget(env, "script")) == "Unloading" then
        LoadArea = debug.getupvalue(connection.Function, 2)
        break
    end
end

pcall(function()
for index, connection in next, getconnections(Remotes:WaitForChild("Misc").OnTeleport.OnClientEvent) do
    if connection.Function and tostring(rawget(getfenv(connection.Function), "script")) == "SetupNPCs" then
        Debug("Found and set LoadNPC function.")
        LoadNPC = hookfunction(debug.getupvalue(connection.Function, 6), function(...)
            if not checkcaller() then
                return
            end LoadNPC(...)
        end)
    end
end
end)

local Settings = {
    DebuggingEnabled = true
}

Debug = function(...)
    if Settings.DebuggingEnabled then
        print(...)
    end
end

local function FindChildByIndexSequence(Parent, IndexSequence)
    local CurrentChild = Parent
    for _, Index in ipairs(IndexSequence) do
        CurrentChild = CurrentChild:FindFirstChild(tostring(Index))
        if not CurrentChild then
            return nil
        end
    end
    return CurrentChild
end

local TP = function(Position)
    if typeof(Position) == "Instance" then
        Position = Position.CFrame
    end
    if typeof(Position) == "Vector3" then
        Position = CFrame.new(Position)
    end
    if typeof(Position) == "CFrame" then
        LocalPlayer.Character:PivotTo(Position)
    else
        warn("[!] Invalid Argument Passed to TP()")
    end
end

local FindFirstChildByNameContaining = function(parent, searchStr)
    for _, child in pairs(parent:GetChildren()) do
        if string.find(child.Name, searchStr) then
            return child
        end
    end
    return nil
end

local GetCurrentStoryMarker = function()
    return FindFirstChildByNameContaining(Camera, "StoryMarker")
end

local GetCurrentQuestMarker = function()
    return FindFirstChildByNameContaining(Camera, "QuestMarker")
end

local function GetShip()
    return workspace.Boats:FindFirstChild(LocalPlayer.Name .. "Boat") or false
end

local function SetWindShake(bool)
    local WindShake = game:GetService("Players").LocalPlayer.PlayerScripts.WindShake
    WindShake.Disabled = not bool
end

local AutoEatCoroutine

local Window = Rayfield:CreateWindow({
    Name = Title .. " | " .. Version,
    Icon = "sword",
    LoadingTitle = "Loading " .. Title .. " Hub...",
    LoadingSubtitle = "by Lomi",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "ArcaneOdysseyHub",
        FileName = "Config"
    },
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = Title .. " | " .. Version,
       Subtitle = "Key System",
       Note = "Key is at discord.gg/lomihub", -- Use this to tell the user how to get a key
       FileName = "LomiHubKey", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"lomihub-AsxQvkslP581d"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
})

-- Create the tabs
local MainTab = Window:CreateTab("Main", "sword")
local ExploitsTab = Window:CreateTab("Exploits", "bolt")
local DarkSeaTab = Window:CreateTab("Dark Sea", "moon")
local TeleportsTab = Window:CreateTab("Teleports", "map")
local MiscTab = Window:CreateTab("Misc", "settings")

-- Main Tab Sections and Controls
MainTab:CreateSection("Combat")
MainTab:CreateToggle({ 
    Name = "Godmode", 
    CurrentValue = false, 
    Flag = "NoWeaponDamage", 
    Callback = function(Value) 
        var.godmode = Value 
    end 
})

MainTab:CreateToggle({ 
    Name = "Damage Multiplier", 
    CurrentValue = false, 
    Flag = "DamageMultiplier", 
    Callback = function(Value) 
        var.dmgValue = Value 
        if Value then 
            Rayfield:Notify({ 
                Title = "Damage Multiplier", 
                Content = "This multiplies damage against players, use it wisely. (5 is recommended)", 
                Duration = 4, 
                Image = "repeat" 
            }) 
        end 
    end 
})

MainTab:CreateSlider({ 
    Name = "Damage Multiplier Amount", 
    Range = {1, 250}, 
    Increment = 1, 
    Suffix = "x", 
    CurrentValue = 1, 
    Flag = "DamageMultiplierAmount", 
    Callback = function(Value) 
        var.dmgMulti = Value 
    end 
})

MainTab:CreateButton({ 
    Name = "Hide Name/Level from other players", 
    Callback = function() 
        local Overhead = FindChildByIndexSequence(LocalPlayer.Character, {"Head","Overhead"}) 
        if Overhead then 
            local OverheadClone = Overhead:Clone() 
            Overhead.Name = "NotOverhead" 
            OverheadClone.Parent = Overhead.Parent 
            Overhead:ClearAllChildren() 
        end 
    end 
})

MainTab:CreateToggle({ 
    Name = "No NPC Aggro", 
    CurrentValue = false, 
    Flag = "NPCBlock", 
    Callback = function(Value) 
        var.NPCBlock = Value 
    end 
})

-- Teleports Tab
TeleportsTab:CreateSection("Teleports")
TeleportsTab:CreateButton({ 
    Name = "Teleport to current story quest", 
    Callback = function() 
        local StoryMarker = GetCurrentStoryMarker() 
        if StoryMarker then 
            LoadArea(StoryMarker.Position, false) 
            TP(StoryMarker) 
        else 
            Rayfield:Notify({ 
                Title = "Teleport", 
                Content = "Story quest marker not found!", 
                Duration = 4, 
                Image = "repeat" 
            }) 
        end 
    end 
})

TeleportsTab:CreateButton({ 
    Name = "Teleport to current quest", 
    Callback = function() 
        local QuestMarker = GetCurrentQuestMarker() 
        if QuestMarker then 
            LoadArea(QuestMarker.Position, false) 
            TP(QuestMarker) 
        else 
            Rayfield:Notify({ 
                Title = "Teleport", 
                Content = "Quest marker not found!", 
                Duration = 4, 
                Image = "repeat" 
            }) 
        end 
    end 
})

TeleportsTab:CreateButton({ 
    Name = "Teleport to ship", 
    Callback = function() 
        local ship = GetShip() 
        if ship and ship.PrimaryPart then 
            TP(ship.PrimaryPart.Position + Vector3.new(0,20,0)) 
        else 
            Rayfield:Notify({ 
                Title = "Teleport", 
                Content = "Ship not found!", 
                Duration = 4, 
                Image = "repeat" 
            }) 
        end 
    end 
})

TeleportsTab:CreateSection("Island Teleports")
local SelectedIsland = nil

TeleportsTab:CreateDropdown({
    Name = "Teleport to Island",
    Options = Islands,
    CurrentOption = nil,
    Flag = "IslandsDropdown",
    Callback = function(Value)
        if type(Value) == "table" then
            SelectedIsland = Value[1]
        else
            SelectedIsland = Value
        end
        
        if not SelectedIsland then return end
        
        local Island = workspace.Map:FindFirstChild(SelectedIsland)
        if Island then
            local Center = Island:FindFirstChild("Center")
            if Center then
                LoadArea(Center.Position, false)
                
                -- Get the base position
                local BasePos = Center.Position
                
                -- Apply special offsets for specific islands
                if SelectedIsland == "Mount Othrys" then
                    BasePos = BasePos + Vector3.new(0, 28063, -10)
                elseif SelectedIsland == "Harvest Island" then
                    BasePos = BasePos + Vector3.new(-234, -112, 99)
                elseif SelectedIsland == "Ravenna" then
                    BasePos = BasePos + Vector3.new(0, -500, 0)
                else
                    BasePos = BasePos + Vector3.new(0, 1000, 0)
                end
                
                -- Teleport to the calculated position
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(BasePos)
                task.wait()
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
                
                task.delay(15, function()
                    LocalPlayer.Character.HumanoidRootPart.Anchored = false
                end)
            end
        end
    end
})
TeleportsTab:CreateSection("Others")
TeleportsTab:CreateToggle({
    Name = "Ctrl+Click Teleport",
    CurrentValue = _G.WRDClickTeleport or false,
    Flag = "CtrlClickTP",
    Callback = function(Value)
        _G.WRDClickTeleport = Value
        if Value then
            Rayfield:Notify({
                Title = "Ctrl+Click Teleport",
                Content = "Ctrl+Click Teleport enabled.",
                Duration = 4,
                Image = "repeat"
            })
            if not _G.WRDClickTPConnection then
                local player = game:GetService("Players").LocalPlayer
                local UserInputService = game:GetService("UserInputService")
                local mouse = player:GetMouse()
                _G.WRDClickTPConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if _G.WRDClickTeleport and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            player.Character:MoveTo(Vector3.new(mouse.Hit.x, mouse.Hit.y, mouse.Hit.z))
                        end
                    end
                end)
            end
        else
            Rayfield:Notify({
                Title = "Ctrl+Click Teleport",
                Content = "Ctrl+Click Teleport disabled.",
                Duration = 4,
                Image = "repeat"
            })
            if _G.WRDClickTPConnection then
                _G.WRDClickTPConnection:Disconnect()
                _G.WRDClickTPConnection = nil
            end
        end
    end
})

-- Exploits Tab
ExploitsTab:CreateSection("Player Exploits")
local toolNames = {"Red apple", "Banana", "Grapes", "Orange", "Green apple"}

ExploitsTab:CreateToggle({ 
    Name = "Auto Eat", 
    CurrentValue = false, 
    Flag = "AutoEat", 
    Callback = function(Value) 
        Toggles.AutoEat.Value = Value 
        if Value then 
            AutoEatCoroutine = coroutine.create(function() 
                while wait(2) do 
                    local HV = tonumber(LocalPlayer.PlayerGui.MainGui.UI.HUD.Anchor.HungerBar.Back.Amount.Text)
                    if HV < 80 then
                        for _, name in ipairs(toolNames) do
                            local tool = LocalPlayer.Backpack:FindFirstChild(name)
                            if tool then
                                Remotes:WaitForChild("Misc"):WaitForChild("ToolAction"):FireServer(tool)
                                task.wait(0.5)
                            end
                        end
                    end
                end 
            end) 
            coroutine.resume(AutoEatCoroutine) 
        else 
            if AutoEatCoroutine then 
                coroutine.close(AutoEatCoroutine) 
            end 
        end 
    end 
})

ExploitsTab:CreateToggle({ 
    Name = "Infinite Stamina", 
    CurrentValue = false, 
    Flag = "InfiniteStamina", 
    Callback = function(Value) 
        if Value then 
            Remotes:WaitForChild("Combat"):WaitForChild("StaminaCost"):FireServer(-1000,"Dodge") 
        else 
            Remotes:WaitForChild("Combat"):WaitForChild("StaminaCost"):FireServer(Bin.Stamina.Value/Bin.MaxStamina.Value,"Dodge") 
        end 
    end 
})

ExploitsTab:CreateToggle({ 
    Name = "One Hit Structures", 
    CurrentValue = false, 
    Flag = "OneTapStructure", 
    Callback = function(Value) 
        var.OneTapStructure = Value 
    end 
})

ExploitsTab:CreateToggle({ 
    Name = "Jesus", 
    CurrentValue = false, 
    Flag = "Jesus", 
    Callback = function(Value) 
        if Value then 
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() 
            local hrp = char:WaitForChild("HumanoidRootPart") 
            local newPart = Instance.new("Part") 
            newPart.Name = "JesusToggle" 
            newPart.Anchored = true 
            newPart.CanCollide = true 
            newPart.Transparency = 1 
            newPart.Size = Vector3.new(50, 1, 50) 
            newPart.Parent = workspace 
            task.spawn(function() 
                while Value do 
                    if hrp.Position.Y >= 405 then 
                        newPart.CanCollide = false 
                    else 
                        newPart.CanCollide = true 
                    end 
                    newPart.Position = Vector3.new(hrp.Position.X, 400, hrp.Position.Z) 
                    task.wait() 
                end 
            end) 
        else 
            pcall(function() 
                local thePart = workspace:FindFirstChild("JesusToggle") 
                if thePart then 
                    thePart:Destroy() 
                end 
            end) 
        end 
    end 
})

ExploitsTab:CreateToggle({ 
    Name = "No Location Tracking", 
    CurrentValue = false, 
    Flag = "NoTracking", 
    Callback = function(Value) 
        var.NoTracking = Value 
    end 
})

ExploitsTab:CreateToggle({ 
    Name = "Drink Bottles Silently", 
    CurrentValue = false, 
    Flag = "DrinkBottleSilent", 
    Callback = function(Value) 
        var.DrinkBottleSilent = Value 
        Rayfield:Notify({ 
            Title = "Bottles!", 
            Content = "Drink bottles silently enabled", 
            Duration = 4, 
            Image = "repeat" 
        }) 
    end 
})

ExploitsTab:CreateButton({ 
    Name = "Toggle Insanity Effects", 
    Callback = function() 
        local InsanityLocalScript = LocalPlayer.PlayerGui:WaitForChild("Temp",10):FindFirstChild("Insanity") 
        if InsanityLocalScript then 
            InsanityLocalScript.Disabled = not InsanityLocalScript.Disabled 
        else 
            Rayfield:Notify({ 
                Title = "Insanity", 
                Content = "Insanity script not found!", 
                Duration = 4, 
                Image = "repeat" 
            }) 
        end 
    end 
})

ExploitsTab:CreateSection("Boat Exploits")
ExploitsTab:CreateToggle({ Name = "Ship Repair Multiplier", CurrentValue = false, Flag = "FastBoatRepair", Callback = function(Value) var.FastBoatRepair = Value end })
ExploitsTab:CreateSlider({ Name = "Ship Repair Multiplier Amount", Range = {1, 50}, Increment = 1, Suffix = "x", CurrentValue = 1, Flag = "RepairMulti", Callback = function(Value) var.RepairMulti = Value end })

ExploitsTab:CreateSection("Item Exploits")
ExploitsTab:CreateButton({
    Name = "Quick Fill Empty Bottles",
    Callback = function()
        if FillDebounce then return end
        FillDebounce = true

        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        Humanoid:UnequipTools()

        for i = 1,100 do
            Remotes.Misc.EmptyBottle:FireServer()
        end

        task.delay(1, function()
            FillDebounce = false
        end)
    end
})

-- Dark Sea Tab
DarkSeaTab:CreateSection("Dark Sea Exploits")
DarkSeaTab:CreateToggle({
    Name = "Spawn Dark Sea Lightning",
    CurrentValue = false,
    Flag = "ToggleLightning",
    Callback = function(Value)
        var.ToggleLightning = Value
    end
})

DarkSeaTab:CreateButton({
    Name = "Disable Dark Sea Rain",
    Callback = function()
        local fx = workspace.Camera:FindFirstChild("OverheadFX",10)
        if fx and fx:FindFirstChild("DSRain") and fx:FindFirstChild("DSRain2") then
            fx.DSRain.Lifetime = NumberRange.new(0,0)
            fx.DSRain2.Lifetime = NumberRange.new(0,0)
            Rayfield:Notify({
                Title = "Dark Sea",
                Content = "Once you die you need to re-toggle this.",
                Duration = 4,
                Image = "repeat"
            })
        else
            Rayfield:Notify({
                Title = "Dark Sea",
                Content = "Rain FX not found!",
                Duration = 4,
                Image = "repeat"
            })
        end
    end
})

DarkSeaTab:CreateButton({
    Name = "Disable Fog Circle",
    Callback = function()
        local found = false
        local Sky1 = LocalPlayer.PlayerGui.Temp.DarkSea:FindFirstChild("DarkSky1")
        local Sky2 = LocalPlayer.PlayerGui.Temp.DarkSea:FindFirstChild("DarkSky2")
        if Sky1 and Sky1:FindFirstChildOfClass("SpecialMesh") then
            Sky1:FindFirstChildOfClass("SpecialMesh"):Destroy()
            found = true
        end
        if Sky2 and Sky2:FindFirstChildOfClass("SpecialMesh") then
            Sky2:FindFirstChildOfClass("SpecialMesh"):Destroy()
            found = true
        end
        local CSky1 = Camera:FindFirstChild("DarkSky1")
        local CSky2 = Camera:FindFirstChild("DarkSky2")
        if CSky1 and CSky1:FindFirstChildOfClass("SpecialMesh") then
            CSky1:FindFirstChildOfClass("SpecialMesh"):Destroy()
            found = true
        end
        if CSky2 and CSky2:FindFirstChildOfClass("SpecialMesh") then
            CSky2:FindFirstChildOfClass("SpecialMesh"):Destroy()
            found = true
        end
        if not found then
            Rayfield:Notify({
                Title = "Dark Sea",
                Content = "Fog meshes not found!",
                Duration = 4,
                Image = "repeat"
            })
        end
    end
})

DarkSeaTab:CreateToggle({
    Name = "Auto Wash Bin",
    CurrentValue = false,
    Flag = "AutoWash",
    Callback = function(Value)
        var.AutoWash = Value
    end
})

-- Misc Tab
MiscTab:CreateSection("Misc")
MiscTab:CreateButton({
    Name = "ArcaneYield (modded IY)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Idktbh12z/ArcaneYIELD/refs/heads/main/main.lua"))()
    end
})

MiscTab:CreateButton({
    Name = "Quick Clear Notoriety",
    Callback = function()
        if Remotes and Remotes.UI and Remotes.UI.ClearBounty then
            Remotes.UI.ClearBounty:InvokeServer("ClearNotoriety")
        else
            Rayfield:Notify({
                Title = "Notoriety",
                Content = "ClearBounty remote not found!",
                Duration = 4,
                Image = "repeat"
            })
        end
    end
})

MiscTab:CreateButton({
    Name = "Clear Fame",
    Callback = function()
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("UI"):WaitForChild("ClearBounty"):InvokeServer("ClearFame")
        end)
        if success then
            Rayfield:Notify({
                Title = "Clear Fame",
                Content = "Fame cleared!",
                Duration = 4,
                Image = "repeat"
            })
        else
            Rayfield:Notify({
                Title = "Clear Fame",
                Content = "Failed to clear fame!",
                Duration = 4,
                Image = "repeat"
            })
        end
    end
})

MiscTab:CreateSection("Environment")
MiscTab:CreateButton({
    Name = "Discover All Islands",
    Callback = function()
        for _, Island in pairs(workspace.Map:GetChildren()) do
            if Island:FindFirstChild("Center") then
                Remotes.Misc.UpdateLastSeen:FireServer(Island.Name, "")
            end
        end
        Rayfield:Notify({
            Title = "Islands",
            Content = "All islands have been discovered!",
            Duration = 4,
            Image = "repeat"
        })
    end
})

MiscTab:CreateButton({
    Name = "Load nearby NPCs",
    Callback = function()
        for i,NPC in pairs(workspace.NPCs:GetChildren()) do
            if NPC:FindFirstChild("CF") and NPC:IsA("Model") and (NPC.CF.Value.p - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 1000 then
                pcall(LoadNPC, NPC, NPC.CF.Value.p)
                pcall(LoadArea, NPC.CF.Value.p, false)
            end
        end
    end
})

MiscTab:CreateToggle({
    Name = "Disable Tree Shake",
    CurrentValue = false,
    Flag = "TreeShake",
    Callback = function(Value)
        SetWindShake(not Value)
    end
})

MiscTab:CreateToggle({
    Name = "Disable Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(Value)
        if Value then
            TweenService:Create(Lighting.Atmosphere,TweenInfo.new(1),{Density = 0}):Play()
        end
    end
})

MiscTab:CreateSection("Discord")
MiscTab:CreateButton({
    Name = "Join Our Discord!",
    Callback = function()
        local success, err = pcall(function()
            local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
            Module.Join("https://discord.gg/3jtCm4M5pq")
        end)
        if not success then
            Rayfield:Notify({
                Title = "Discord",
                Content = "Failed to join Discord!",
                Duration = 4,
                Image = "repeat"
            })
        end
    end
})

MiscTab:CreateSection("Factions")
MiscTab:CreateButton({
    Name = "Join Navy",
    Callback = function()
        local args = {
            "Join",
            "GrandNavy_F"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FactionService"):InvokeServer(unpack(args))
        Rayfield:Notify({
            Title = "Faction",
            Content = "Attempting to join Navy...",
            Duration = 4,
            Image = "repeat"
        })
    end
})

MiscTab:CreateButton({
    Name = "Join Assassin",
    Callback = function()
        local args = {
            "Join",
            "ASyndicate_F"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FactionService"):InvokeServer(unpack(args))
        Rayfield:Notify({
            Title = "Faction",
            Content = "Attempting to join Assassin...",
            Duration = 4,
            Image = "repeat"
        })
    end
})

MiscTab:CreateButton({
    Name = "Leave Clan",
    Callback = function()
        local args = {
            "Leave"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RS"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FactionService"):InvokeServer(unpack(args))
        Rayfield:Notify({
            Title = "Faction",
            Content = "Attempting to leave clan...",
            Duration = 4,
            Image = "repeat"
        })
    end
})

Rayfield:LoadConfiguration()

game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if Toggles.InstantProximityPrompt.Value == true then
        fireproximityprompt(prompt,1)
    end
end)

-- Hooks

task.spawn(function()
    local OneTapStructureHook
    OneTapStructureHook = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and (tostring(self) == "DamageStructure") and var.OneTapStructure then
            for i=1,1000 do
                self.InvokeServer(self, unpack(args))
        end
    end

        return OneTapStructureHook(self,unpack(args))
    end))
end)

task.spawn(function()
    local LightningHook
    LightningHook = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and (tostring(self) == "UpdateLastSeen") and var.ToggleLightning then
            if args[1] then
                args[1] = "The Dark Sea"
            end
            if args[2] then
                args[2] = ""
                        end
                    end

        return LightningHook(self,unpack(args))
    end))
end)

task.spawn(function()
    local NoTrackingHook
    NoTrackingHook = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and (tostring(self) == "UpdateLastSeen") and var.NoTracking then
            if args[1] then
                args[1] = ""
            end
            if args[2] then
                args[2] = ""
            end
        end

        return NoTrackingHook(self,unpack(args))
    end))
end)

task.spawn(function()
    local damageHook
    damageHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and table.find(remotes, tostring(self)) and var.dmgValue then
            for i = 1, var.dmgMulti do
                self.FireServer(self, unpack(args))
            end
        end

        return damageHook(self, unpack(args))
    end))
end)

task.spawn(function()
    local godHook
    godHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and (tostring(self) == "DealAttackDamage" or tostring(self) == "DealBossDamage") and var.godmode then
            if args[2] == LocalPlayer.Character then
                args[2] = nil
            end
        elseif not checkcaller() and tostring(self) == "DealMagicDamage" and var.godmode then
            if args[2] == LocalPlayer.Character then
                args[2] = nil
            end
        elseif not checkcaller() and (tostring(self) == "DealWeaponDamage" or tostring(self) == "DealStrengthDamage" ) and var.godmode then
            if args[3] == LocalPlayer.Character then
                args[3] = nil
            end
        elseif not checkcaller() and (tostring(self) == "TouchDamage") and var.godmode then
            return
        end

        return godHook(self, unpack(args))
    end))
end)

task.spawn(function()
    local blockHook
    blockHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and tostring(self) == "TargetBehavior" and method == "InvokeServer" and var.NPCBlock then
            return
        end

        return blockHook(self, unpack(args))
    end))
end)

task.spawn(function()
    local RepairHook
    RepairHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = { ... }
        local method = getnamecallmethod()

        if not checkcaller() and tostring(self) == "RepairHammer" and method == "InvokeServer" and var.FastBoatRepair then
            for i=1,var.RepairMulti do
                self.InvokeServer(self, unpack(args))
            end
        end

        return RepairHook(self, unpack(args))
    end))
end)

-- Input Handling
UserInputService.InputBegan:connect(function(Input, IsChatBox)
    if IsChatBox then return end
    if not var.DrinkBottleSilent then return end

    if Input.KeyCode == Enum.KeyCode.Period then
        Remotes.Misc.EmptyBottle:FireServer(true)
    end
end)

task.spawn(function()
    while task.wait(3) do
        if var.AutoWash then 
            Remotes.Boats.Wash:FireServer() 
            end
        end
end)

task.spawn(function()
    while task.wait(1) do
        for _,Player in ReplicatedStorage.RS.UnloadPlayers:GetChildren() do
            Player.Parent = game.Workspace.NPCs
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        for _,Instance in LocalPlayer.PlayerGui:GetChildren() do
            if Instance.Name:lower() == "deathscreen" then
                Instance.Enabled = false
            end
        end
    end
end)

-- Magic and Fighting Style Exploits
local RS = game:GetService("ReplicatedStorage"):WaitForChild("RS",10)
local MagicModule = require(RS.Modules.Magic)
local MeleeModule = require(RS.Modules.Melee)
local BasicModule = require(RS.Modules.Basic)

local SelectedMagic = nil
local SelectedStyle = nil
local MagicList = {}

for _,Magic in pairs(MagicModule["Types"]) do
    table.insert(MagicList, _)
end

ExploitsTab:CreateSection("Magic Exploits")
ExploitsTab:CreateDropdown({
    Name = "Select Magic",
    Options = MagicList,
    CurrentOption = nil,
    Flag = "MagicDropdown",
    Callback = function(Value)
        if type(Value) == "table" then
            SelectedMagic = Value[1]
        else
            SelectedMagic = Value
        end
        
        if not SelectedMagic then return end
        if not MagicModule["Types"][SelectedMagic] then return end
        
        Rayfield:Notify({
            Title = "Magic Selected",
            Content = "Selected magic: " .. SelectedMagic,
            Duration = 2,
            Image = "repeat"
        })
    end
})

ExploitsTab:CreateInput({
    Name = "Magic Size",
    PlaceholderText = "Enter size (max 75)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        if not SelectedMagic then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please select a magic first!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        if not tonumber(Value) then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please enter a valid number!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        local num = tonumber(Value)
        if num > 75 then 
            Rayfield:Notify({
                Title = "Warning!",
                Content = "This could break your game if you set it too high.",
                Duration = 4,
                Image = "repeat"
            })
        end
        pcall(function()
            MagicModule["Types"][SelectedMagic].Size = num
            Rayfield:Notify({
                Title = "Success",
                Content = "Magic size set to: " .. num,
                Duration = 2,
                Image = "repeat"
            })
        end)
    end
})

ExploitsTab:CreateInput({
    Name = "Magic Speed",
    PlaceholderText = "Enter speed (max 3)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        if not SelectedMagic then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please select a magic first!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        if not tonumber(Value) then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please enter a valid number!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        local num = tonumber(Value)
        if num > 3 then 
            Rayfield:Notify({
                Title = "Warning!",
                Content = "This could break your game if you set it too high.",
                Duration = 4,
                Image = "repeat"
            })
        end
        pcall(function()
            MagicModule["Types"][SelectedMagic].Speed = num
            Rayfield:Notify({
                Title = "Success",
                Content = "Magic speed set to: " .. num,
                Duration = 2,
                Image = "repeat"
            })
        end)
    end
})

ExploitsTab:CreateInput({
    Name = "Magic Imbue Speed",
    PlaceholderText = "Enter imbue speed (max 3)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        if not SelectedMagic then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please select a magic first!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        if not tonumber(Value) then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please enter a valid number!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        local num = tonumber(Value)
        if num > 3 then 
            Rayfield:Notify({
                Title = "Warning!",
                Content = "This could break your game if you set it too high.",
                Duration = 4,
                Image = "repeat"
            })
        end
        pcall(function()
            MagicModule["Types"][SelectedMagic].ImbueSpeed = num
            Rayfield:Notify({
                Title = "Success",
                Content = "Magic imbue speed set to: " .. num,
                Duration = 2,
                Image = "repeat"
            })
        end)
    end
})

-- Fighting Style Exploits
local StyleList = {}
for _,Style in pairs(MeleeModule["Types"]) do
    table.insert(StyleList, _)
end

ExploitsTab:CreateSection("Fighting Style Exploits")
ExploitsTab:CreateDropdown({
    Name = "Select Fighting Style",
    Options = StyleList,
    CurrentOption = nil,
    Flag = "StyleDropdown",
    Callback = function(Value)
        if type(Value) == "table" then
            SelectedStyle = Value[1]
        else
            SelectedStyle = Value
        end
        
        if not SelectedStyle then return end
        if not MeleeModule["Types"][SelectedStyle] then return end
        
        Rayfield:Notify({
            Title = "Style Selected",
            Content = "Selected style: " .. SelectedStyle,
            Duration = 2,
            Image = "repeat"
        })
    end
})

ExploitsTab:CreateInput({
    Name = "Style Size",
    PlaceholderText = "Enter size (max 75)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        if not SelectedStyle then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please select a fighting style first!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        if not tonumber(Value) then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please enter a valid number!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        local num = tonumber(Value)
        if num > 75 then 
            Rayfield:Notify({
                Title = "Warning!",
                Content = "This could break your game if you set it too high.",
                Duration = 4,
                Image = "repeat"
            })
        end
        pcall(function()
            MeleeModule["Types"][SelectedStyle].Size = num
            Rayfield:Notify({
                Title = "Success",
                Content = "Style size set to: " .. num,
                Duration = 2,
                Image = "repeat"
            })
        end)
    end
})

ExploitsTab:CreateInput({
    Name = "Style Speed",
    PlaceholderText = "Enter speed (max 1)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        if not SelectedStyle then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please select a fighting style first!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        if not tonumber(Value) then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please enter a valid number!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        local num = tonumber(Value)
        if num > 1 then 
            Rayfield:Notify({
                Title = "Warning!",
                Content = "Speed cannot be higher than 1 for fighting styles at the moment!",
                Duration = 4,
                Image = "repeat"
            })
            return
        end
        pcall(function()
            MeleeModule["Types"][SelectedStyle].Speed = num
            Rayfield:Notify({
                Title = "Success",
                Content = "Style speed set to: " .. num,
                Duration = 2,
                Image = "repeat"
            })
        end)
    end
})

ExploitsTab:CreateInput({
    Name = "Style Imbue Speed",
    PlaceholderText = "Enter imbue speed (max 3)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        if not SelectedStyle then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please select a fighting style first!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        if not tonumber(Value) then 
            Rayfield:Notify({
                Title = "Warning",
                Content = "Please enter a valid number!",
                Duration = 2,
                Image = "repeat"
            })
            return 
        end
        local num = tonumber(Value)
        if num > 3 then 
            Rayfield:Notify({
                Title = "Warning!",
                Content = "This could break your game if you set it too high.",
                Duration = 4,
                Image = "repeat"
            })
        end
        pcall(function()
            MeleeModule["Types"][SelectedStyle].ImbueSpeed = num
            Rayfield:Notify({
                Title = "Success",
                Content = "Style imbue speed set to: " .. num,
                Duration = 2,
                Image = "repeat"
            })
        end)
    end
})