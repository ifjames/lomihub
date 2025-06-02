Version = "indev-0.9.1"
Startup = tick()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Bin = LocalPlayer:WaitForChild("bin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Remotes = ReplicatedStorage:WaitForChild("RS"):WaitForChild("Remotes")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local promptGui = CoreGui:WaitForChild("RobloxPromptGui")
local promptOverlay = promptGui:WaitForChild("promptOverlay")
local Temporary = workspace.Map.Temporary
local LoadArea
local LoadNPC = nil
local anonEvent
local anonDB = false

local function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1

local IYMouse = Players.LocalPlayer:GetMouse()

local flyKeyDown
local flyKeyUp

function sFLY(vfly)
	repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	repeat wait() until IYMouse
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

	local T = getRoot(Players.LocalPlayer.Character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat wait()
				if not vfly and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				BG.cframe = workspace.CurrentCamera.CoordinateFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'd' then 
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif QEfly and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif QEfly and KEY:lower() == 'q' then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = 0
		elseif KEY:lower() == 's' then
			CONTROL.B = 0
		elseif KEY:lower() == 'a' then
			CONTROL.L = 0
		elseif KEY:lower() == 'd' then
			CONTROL.R = 0
		elseif KEY:lower() == 'e' then
			CONTROL.Q = 0
		elseif KEY:lower() == 'q' then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

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

local Islands = {}

for i,v in pairs(workspace.Map:GetChildren()) do
    if v:FindFirstChild("DetailsLoaded") and v:FindFirstChild("Center") and not v.Name:find("Shipwreck") then
        table.insert(Islands,v.Name)
    end
end

local Settings = {
    DebuggingEnabled = true
}

Debug = function(...)
    if Settings.DebuggingEnabled then
        print(...)
    end
end

local Round = function(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function SortByDistance(objects)
    table.sort(objects, function(a, b)
        local aDistance = (a.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).magnitude
        local bDistance = (b.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).magnitude
        return aDistance < bDistance
    end)
    return objects
end

local function SortByDistanceBaseParts(objects)
    table.sort(objects, function(a, b)
        local aDistance = (a.Position - LocalPlayer.Character.PrimaryPart.Position).magnitude
        local bDistance = (b.Position - LocalPlayer.Character.PrimaryPart.Position).magnitude
        return aDistance < bDistance
    end)
    return objects
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

local function GetLoadedIslands()
    local LoadedIslands = {}
    for i,v in pairs(workspace.Map:GetChildren()) do
        if v:FindFirstChild("DetailsLoaded") and v.DetailsLoaded.Value == true then
            table.insert(LoadedIslands,v)
        end
    end
    return LoadedIslands
end

local function GetFoodTools()
    local Food = {}

    local BackpackUI = LocalPlayer.PlayerGui.Backpack.Backpack.Inventory.ScrollingFrame.UIGridFrame
    for i, ToolFrame in pairs(BackpackUI:GetChildren()) do
        Debug(ToolFrame.Name)
        if FindChildByIndexSequence(ToolFrame, {"View", "HungerIcon"}) and ToolFrame:FindFirstChild("Tool") and ToolFrame:FindFirstChild("Tool").Value then
            Debug("Found food item")
            table.insert(Food, ToolFrame.Tool.Value)
        end
    end

    local BackpackUI = LocalPlayer.PlayerGui.Backpack.Backpack.Hotbar
    for i, ToolFrame in pairs(BackpackUI:GetChildren()) do
        Debug(ToolFrame.Name)
        if FindChildByIndexSequence(ToolFrame, {"View", "HungerIcon"}) and ToolFrame:FindFirstChild("Tool") and ToolFrame:FindFirstChild("Tool").Value then
            Debug("Found food item")
            table.insert(Food, ToolFrame.Tool.Value)
        end
    end

    return Food
end

local function FindNearestEnemy()
    local EnemiesFolder = workspace.Enemies
    local MinDistance = math.huge
    local NearestEnemy = nil
    
    for i, Enemy in ipairs(EnemiesFolder:GetChildren()) do
        if Enemy:IsA("Model") and Enemy:FindFirstChild("HumanoidRootPart") and Enemy:FindFirstChild("Humanoid") and Enemy.Humanoid.Health > 0 then
            local Distance = (Enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if Distance < 20 and Distance < MinDistance then
                MinDistance = Distance
                NearestEnemy = Enemy
            end
        end
    end
    
    return NearestEnemy
end

local function FindNearestPlayer()
    local MinDistance = math.huge
    local NearestEnemy = nil
    
    for _, Enemy in pairs(workspace:GetChildren()) do
        if Enemy:IsA("Model") and Enemy:FindFirstChild("HumanoidRootPart") and Players:FindFirstChild(Enemy.Name) and Enemy:FindFirstChild("Humanoid") and Enemy.Humanoid.Health > 0 then
            local Distance = (Enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if Distance < 20 and Distance < MinDistance then
                MinDistance = Distance
                NearestEnemy = Enemy
            end
        end
    end
    
    return NearestEnemy
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

local Enemies = {
    "Shark",
    "Jaw Pirate",
    "Greenwish Cultist",
    "Spire Bandit",
    "Commodore Kai",
    "Blackwater Criminal",
    "Marine",
    "Ravenna Ensign",
    "Ravenna Guard",
    "Ice Smuggler",
    "Frost Brigand",
    "Iris",
    "Lord Elius",
    "General Argos",
    "Lady Carina",
    "King Calvus",
    "Shura"
  }

local function OnCharacterChildAdded(Child)
    if (Toggles.NoKnockback.Value == true or Toggles.AutoFish.Value == true) and Child:IsA("BodyVelocity") and Child.Name == "BodyVelocity" and Child.Parent == LocalPlayer.Character.HumanoidRootPart then
        print(Child.Velocity)
        Child.Velocity = Vector3.new(0,0,0)
    end
end

local function GetShip()
    return workspace.Boats:FindFirstChild(LocalPlayer.Name .. "Boat") or false
end

local function SetWindShake(bool)
    local WindShake = game:GetService("Players").LocalPlayer.PlayerScripts.WindShake
    WindShake.Disabled = not bool
end

local function HeartbeatTP(Position)
    local Connection = RunService.Heartbeat:Connect(function()
        TP(Position)
    end)
    return Connection
end

local function GetClosestChest()
    for i, Island in pairs(GetLoadedIslands()) do
        if Island:FindFirstChild("Chests") then
            local Chests = {}
            for i,v in pairs(Island.Chests:GetChildren()) do
                if v:IsA("Model") then
                    table.insert(Chests,v)
                end
            end

            Chests = SortByDistance(Chests)

            for _,Chest in pairs(Chests) do
                if Chest:IsA("Model") then
                    local PrimaryPart = Chest.PrimaryPart
                    if PrimaryPart and PrimaryPart:FindFirstChild("Prompt") and PrimaryPart.Prompt.Enabled and PrimaryPart.Transparency ~= 1 then
                        return Chest
                    end
                end
            end
        end
    end
    return nil
end

local function GetClosestLostCargo()
    local Cargo = {}
    for i, LostCargo in pairs(Temporary:GetChildren()) do
        if LostCargo.Name == "LostCargo" then
            table.insert(Cargo,LostCargo)
        end
    end

    Cargo = SortByDistanceBaseParts(Cargo)

    for _,LostCargo in pairs(Cargo) do
        return LostCargo
    end

    return nil
end

local AutoChestCoroutine
local AutoLostCargoCoroutine
local AutoFishCoroutine
local AutoEatCoroutine
local AutoEnemyCoro

local Window = Rayfield:CreateWindow({
    Name = "Arcane Odyssey | " .. Version,
    LoadingTitle = "Loading Arcane Odyssey Hub...",
    LoadingSubtitle = "by Lomi",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ArcaneOdysseyHub",
        FileName = "Config"
    },
    KeySystem = false,
    KeySettings = {
        Title = "Arcane Odyssey Hub",
        Subtitle = "Key System",
        Note = "No key required",
        FileName = "ArcaneOdysseyKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"NoKeyRequired"}
    }
})

-- Create the tabs
local MainTab = Window:CreateTab("Main", "sword")
local UISettingsTab = Window:CreateTab("UI Settings", "settings")

-- Create sections for Main tab
local CombatSection = MainTab:CreateSection("Combat")
local TeleportsSection = MainTab:CreateSection("Teleports")
local CharacterSection = MainTab:CreateSection("Character")
local NPCSection = MainTab:CreateSection("NPCs")
local GameSection = MainTab:CreateSection("Game")
local EnvironmentSection = MainTab:CreateSection("Environment")

-- Combat Section
CombatSection:CreateToggle({
    Name = "NPC Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        Toggles.KillAura.Value = Value
    end
})

CombatSection:CreateToggle({
    Name = "Player Kill Aura",
    CurrentValue = false,
    Flag = "PlrKillAura",
    Callback = function(Value)
        Toggles.PlrKillAura.Value = Value
    end
})

CombatSection:CreateToggle({
    Name = "TP Aura",
    CurrentValue = false,
    Flag = "TPAura",
    Callback = function(Value)
        Toggles.TPAura.Value = Value
    end
})

CombatSection:CreateToggle({
    Name = "No Knockback",
    CurrentValue = false,
    Flag = "NoKnockback",
    Callback = function(Value)
        Toggles.NoKnockback.Value = Value
    end
})

CombatSection:CreateToggle({
    Name = "Godmode",
    CurrentValue = false,
    Flag = "NoWeaponDamage",
    Callback = function(Value)
        Toggles.NoWeaponDamage.Value = Value
    end
})

CombatSection:CreateToggle({
    Name = "Damage Multiplier",
    CurrentValue = false,
    Flag = "DamageMultiplier",
    Callback = function(Value)
        Toggles.DamageMultiplier.Value = Value
        if Value then
            Rayfield:Notify({
                Title = "Warning!",
                Content = "This multiplies damage against players, use it wisely.",
                Duration = 6.5,
                Image = "warning"
            })
        end
    end
})

CombatSection:CreateSlider({
    Name = "Damage Multiplier Amount",
    Range = {1, 15},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "DamageMultiplierAmount",
    Callback = function(Value)
        Options.DamageMultiplierAmount.Value = Value
    end
})

-- Character Section
CharacterSection:CreateToggle({
    Name = "Auto Eat",
    CurrentValue = false,
    Flag = "AutoEat",
    Callback = function(Value)
        Toggles.AutoEat.Value = Value
        if Value then
            AutoEatCoroutine = coroutine.create(function()
                while wait(1) do
                    local HV = tonumber(LocalPlayer.PlayerGui.MainGui.UI.HUD.Anchor.HungerBar.Back.Amount.Text)
                    HungerValue = HV
                    if HungerValue < 50 and Eating == false then
                        Eating = true
                        repeat
                            Debug("Starving!")
                            game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.Backquote,false,game)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.Backquote,false,game)
                            task.wait(0.2)
                            local Food = GetFoodTools()
                            task.wait(0.2)
                            game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.Backquote,false,game)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.Backquote,false,game)

                            Debug(#Food)
                            for i,v in pairs(Food) do
                                if not v.Name:find("Buffet") and not v.Name:find("Dinner") and not v.Name:find("Combo") then
                                    Remotes:WaitForChild("Misc"):WaitForChild("ToolAction"):FireServer(v)                                
                                    task.wait(.5)
                                end
                            end
                        until tonumber(LocalPlayer.PlayerGui.MainGui.UI.HUD.Anchor.HungerBar.Back.Amount.Text) >= 70 
                        Eating = false
                    end
                end
            end)
            coroutine.resume(AutoEatCoroutine)
        else
            if AutoEatCoroutine then
                coroutine.close(AutoEatCoroutine)
                AutoChestCoroutine = nil
            end
        end
    end
})

CharacterSection:CreateToggle({
    Name = "Boat/Character Fly",
    CurrentValue = false,
    Flag = "BoatFly",
    Callback = function(Value)
        if Value then
            NOFLY()
            wait()
            sFLY(true)
        else
            NOFLY()
        end
    end
})

CharacterSection:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "FlySpeed",
    Callback = function(Value)
        vehicleflyspeed = Value
    end
})

CharacterSection:CreateToggle({
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

CharacterSection:CreateToggle({
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

CharacterSection:CreateButton({
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

-- Teleports Section
TeleportsSection:CreateDropdown({
    Name = "Teleport to island",
    Options = Islands,
    CurrentOption = nil,
    Flag = "IslandsDropdown",
    Callback = function(Value)
        if Value ~= nil then
            local Island = workspace.Map:FindFirstChild(Value)
            if Island then
                LoadArea(Island.Center.Position, false)
                if HeartbeatConnection then
                    HeartbeatConnection:Disconnect()
                end
                HeartbeatConnection = RunService.Heartbeat:Connect(function()
                    TP(Island.Center.Position + Vector3.new(0,255,0))
                end)
                repeat task.wait() until Island:FindFirstChild("Notes")
                for i = 10,1,-1 do
                    for i,v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.Velocity = Vector3.zero
                        end
                    end
                    task.wait(0.1)
                end
                HeartbeatConnection:Disconnect()
                HeartbeatConnection = nil
                if IslandOffsets[Island.Name] then
                    TP(Island.Center.Position - IslandOffsets[Island.Name])
                end
            end
        end
    end
})

TeleportsSection:CreateButton({
    Name = "Teleport to current story quest",
    Callback = function()
        local StoryMarker = GetCurrentStoryMarker()
        if StoryMarker then
            LoadArea(StoryMarker.Position, false)
            TP(StoryMarker)
        end
    end
})

TeleportsSection:CreateButton({
    Name = "Teleport to ship",
    Callback = function()
        TP(GetShip().PrimaryPart.Position + Vector3.new(0,20,0))
    end
})

TeleportsSection:CreateButton({
    Name = "Teleport to current quest",
    Callback = function()
        local QuestMarker = GetCurrentQuestMarker()
        if QuestMarker then
            LoadArea(QuestMarker.Position, false)
            TP(QuestMarker)
        end
    end
})

-- Game Section
GameSection:CreateToggle({
    Name = "Auto-Skip Dialog",
    CurrentValue = false,
    Flag = "SkipDialog",
    Callback = function(Value)
        Toggles.SkipDialog.Value = Value
    end
})

GameSection:CreateToggle({
    Name = "Kill ALL enemies",
    CurrentValue = false,
    Flag = "AllFarm",
    Callback = function(Value)
        Toggles.AllFarm.Value = Value
    end
})

GameSection:CreateToggle({
    Name = "Auto-Kill Enemies",
    CurrentValue = false,
    Flag = "EnemyFarm",
    Callback = function(Value)
        Toggles.EnemyFarm.Value = Value
        if Value then
            AutoEnemyCoro = coroutine.create(function()
                while wait(1) do
                    if Toggles.AllFarm.Value == false then
                        local SelectedEnemies = Options.EnemyDropDown.Value
                        for i,EnemyObject in pairs(workspace.Enemies:GetChildren()) do
                            if SelectedEnemies[EnemyObject.Name] and EnemyObject:FindFirstChild("HumanoidRootPart") and EnemyObject:FindFirstChildOfClass("Humanoid") and EnemyObject.Humanoid.Health > 0 then
                                if EnemyObject.PrimaryPart.Position.Y > 350 and (LocalPlayer.Character.HumanoidRootPart.Position - EnemyObject.PrimaryPart.Position).Magnitude < 550 and EnemyObject:FindFirstChild("LOADED") then
                                    repeat
                                        if EnemyObject:FindFirstChild("HumanoidRootPart") then
                                            RunService.Heartbeat:Wait()
                                            if EnemyObject:FindFirstChild("HumanoidRootPart") and EnemyObject:FindFirstChild("HumanoidRootPart").Position.Y > 350 then
                                                TP(EnemyObject:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0,6,0))
                                            end
                                        end
                                    until (not EnemyObject:FindFirstChild("Humanoid")) or EnemyObject.Humanoid.Health <= 0
                                end
                            end
                        end
                    else
                        for i,EnemyObject in pairs(workspace.Enemies:GetChildren()) do
                            if EnemyObject:FindFirstChild("HumanoidRootPart") and EnemyObject:FindFirstChildOfClass("Humanoid") and EnemyObject.Humanoid.Health > 0 then
                                if EnemyObject.PrimaryPart.Position.Y > 350 and (LocalPlayer.Character.HumanoidRootPart.Position - EnemyObject.PrimaryPart.Position).Magnitude < 550 and EnemyObject:FindFirstChild("LOADED") then
                                    repeat
                                        if EnemyObject:FindFirstChild("HumanoidRootPart") then
                                            RunService.Heartbeat:Wait()
                                            if EnemyObject:FindFirstChild("HumanoidRootPart") and EnemyObject:FindFirstChild("HumanoidRootPart").Position.Y > 350 then
                                                TP(EnemyObject:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0,6,0))
                                            end
                                        end
                                    until EnemyObject.Humanoid.Health <= 0
                                end
                            end
                        end
                    end
                end
            end)
            coroutine.resume(AutoEnemyCoro)
        else
            coroutine.close(AutoEnemyCoro)
            AutoEnemyCoro = nil
        end
    end
})

GameSection:CreateDropdown({
    Name = "Teleport to enemies",
    Options = Enemies,
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "EnemyDropDown",
    Callback = function(Value)
        Options.EnemyDropDown.Value = Value
    end
})

GameSection:CreateButton({
    Name = "Rejoin",
    Callback = function()
        TeleportService:Teleport(12604352060, LocalPlayer, tonumber(Bin.File.Value) or 1)
    end
})

GameSection:CreateButton({
    Name = "Serverhop",
    Callback = function()
        local srvHop = loadstring(game:HttpGet('https://raw.githubusercontent.com/AlternateYT/Roblox-Scripts/main/Serverhop%20Module.lua'))()
        srvHop:Hop(game.PlaceId, tonumber(Bin.File.Value) or 1)
    end
})

GameSection:CreateButton({
    Name = "Discover all islands",
    Callback = function()
        for i,v in pairs(workspace.Map:GetChildren()) do
            if v:IsA("Folder") and v:FindFirstChild("DetailsLoaded") then
                Remotes:WaitForChild("Misc"):WaitForChild("UpdateLastSeen"):FireServer(v.Name, "")             
            end
        end
    end
})

-- Environment Section
EnvironmentSection:CreateButton({
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

EnvironmentSection:CreateToggle({
    Name = "Optimize Lighting",
    CurrentValue = false,
    Flag = "BadLighting",
    Callback = function(Value)
        if Value == true then
            sethiddenproperty(game.Lighting, "Technology", Enum.Technology.Compatibility)
            game.Lighting.GlobalShadows = false
        else
            sethiddenproperty(game.Lighting, "Technology", Enum.Technology.Future)
            game.Lighting.GlobalShadows = true
        end
    end
})

EnvironmentSection:CreateToggle({
    Name = "Disable Tree Shake",
    CurrentValue = false,
    Flag = "TreeShake",
    Callback = function(Value)
        SetWindShake(not Value)
    end
})

EnvironmentSection:CreateToggle({
    Name = "Daytime",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        Toggles.FullBright.Value = Value
    end
})

EnvironmentSection:CreateToggle({
    Name = "Disable Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(Value)
        if Value then
            TweenService:Create(Lighting.Atmosphere,TweenInfo.new(1),{Density = 0}):Play()
        end
    end
})

-- UI Settings Tab
UISettingsTab:CreateButton({
    Name = "Unload",
    Callback = function()
        Rayfield:Destroy()
    end
})

UISettingsTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "MenuKeybind",
    Callback = function(Keybind)
        Rayfield:SetVisibility(not Rayfield:IsVisible())
    end
})

Lighting.Atmosphere.Changed:Connect(function(Property)
    if Toggles.FullBright.Value == true then
        if Property == "Decay" then
            Lighting.Atmosphere.Decay = Color3.new(0.690196, 0.839215, 0.827450)
        end
    end
    if Toggles.NoFog.Value == true then
        if Property == "Density" then
            Lighting.Atmosphere.Density = 0
        end
    end
end)

Lighting.Changed:Connect(function(Property)
    if Toggles.FullBright.Value == true then
        if Property == "ClockTime" then
            Lighting.ClockTime = 12
        end
        if Property == "Brightness" then
            Lighting.Brightness = 3
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    local DCon
    DCon = character.DescendantAdded:Connect(OnCharacterChildAdded)
    character:WaitForChild("Humanoid").Died:Once(function()
        DCon:Disconnect()
    end)
end)

LocalPlayer.PlayerGui.ChildAdded:Connect(function(ScreenGui)
    if ScreenGui.Name == "Dialog" and Toggles.SkipDialog.Value == true then
        local ChosenOption = ScreenGui:WaitForChild("ChosenOption", 5)
        local UIOpen = ScreenGui:WaitForChild("Open", 5)
        local QuestDetails = ScreenGui.Background:WaitForChild("QuestDetails", 5)

        if ScreenGui.NPC.Value.Attributes:FindFirstChild("Quest") then
            Debug("QuestDetected")
            repeat
                if QuestDetails.Visible == false then
                    for i = 2,1,-1 do
                        game.VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
                        wait()
                        game.VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
                    end
                    ChosenOption.Value = 1
                    Debug("SetValue1")
                    wait(0.45)
                end
            until UIOpen.Value == false or QuestDetails.Visible == true
        else
            repeat
                for i = 2,1,-1 do
                    game.VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
                    wait()
                    game.VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
                end
                ChosenOption.Value = 1
                wait()
            until UIOpen.Value == false or QuestDetails.Visible == true
        end
    end
end)

LocalPlayer.Character:WaitForChild("Humanoid")

game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if Toggles.InstantProximityPrompt.Value == true then
        fireproximityprompt(prompt,1)
    end
end)

local DCon
DCon = LocalPlayer.Character.DescendantAdded:Connect(OnCharacterChildAdded)
LocalPlayer.Character:WaitForChild("Humanoid").Died:Once(function()
    DCon:Disconnect()
    Debug("Disconnected character DescendantAdded.")
end)