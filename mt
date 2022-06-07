getgenv().loadout = {"AK","G36","Medkit","Sword"}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("aaaaaa", "Serpent")

local plr = game.Players.LocalPlayer

local rEvent = game:GetService("ReplicatedStorage").Events_UI.ChangeTeams

--Tab 1 -- TOGGLES

local Tab = Window:NewTab("Toggles")

local Section = Tab:NewSection("Toggles")

--Quick respawn toggle
Section:NewToggle("QuickRespawn", "Automatically respawn", function(state)
    if state then
        getgenv().QRToggled = true
    else
        getgenv().QRToggled = false
    end
end)
getgenv().QRToggled = false
Section:NewSlider("Delay", "The delay before you auto-respawn", 3, 0, function(s)
    getgenv().QRDelay = s
end)
getgenv().QRDelay = 0
--Quick respawn function
plr.CharacterAdded:Connect(function(chr)
	chr:WaitForChild("Humanoid").Died:Connect(function()
		if getgenv().QRToggled then
			wait(getgenv().QRDelay)
			rEvent:FireServer(plr.Team.Name)
		end
	end)
end)

getgenv().SRToggled = false
--Safe respawn toggle
Section:NewToggle("SafeRespawn", "Respawn at your death location", function(state)
    if state then
        getgenv().SRToggled = true
    else
        getgenv().SRToggled = false
    end
end)
--Safe respawn died detect (save pos)
plr.CharacterAdded:Connect(function(chr)
	chr:WaitForChild("Humanoid").Died:Connect(function()
		if getgenv().SRToggled then
			if plr.Character:FindFirstChild("HumanoidRootPart") then
				oldPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
			end
		end
	end)
end)
--Safe respawn tp function
function safeSpawn()
	repeat wait() until plr.Character:FindFirstChild("HumanoidRootPart")
	wait(.1)
	plr.Character:FindFirstChild("HumanoidRootPart").CFrame = oldPos + Vector3.new(0,5,0)
	oldPos = 0
end
--Safe respawn respawned detect (trigger safe spawn function)
plr.CharacterAdded:Connect(function(chr)
	if oldPos then
		if oldPos ~= 0 then
			safeSpawn()
		end
	end
end)

--Loadout toggle
Section:NewToggle("Loadout", "Sort loadout on spawn", function(state)
	if state then
        getgenv().LOToggled = true
    else
        getgenv().LOToggled = false
    end
end)
--Loadout function
plr.CharacterAdded:Connect(function(chr)
	if getgenv().LOToggled then
		--Wait for tools to load
		repeat
			wait()
		until #plr.Backpack:GetChildren() > 0
		--Transport to leaderstats
		for _, v in pairs(plr.Backpack:GetChildren()) do
			v.Parent = plr.leaderstats
		end
		--Transport prioritized tools
		for i, v in pairs(getgenv().loadout) do
			for o, x in pairs(plr.leaderstats:GetChildren()) do
				if x.Name == v then
					x.Parent = plr.Backpack
				else
					if i == #getgenv().loadout and o == #plr.leaderstats:GetChildren() then
						--Transport rest of tools
						for _, y in pairs(plr.leaderstats:GetChildren()) do
							if y:IsA("Tool") then
								y.Parent = plr.Backpack
							end
						end
					end
				end
			end
		end
	end
end)

--Auto collect medkit toggle
Section:NewToggle("AutoMedkit", "Auto collect everybody's medkits", function(state)
	if state then
        getgenv().MKToggled = true
    else
        getgenv().MKToggled = false
    end
end)
--Auto collect medkits function
game.Workspace.ChildAdded:Connect(function(c)
    if not MKToggled then return end
    if c.Name == "Handle" then
        wait(0.05)
        if c:FindFirstChild("TouchInterest") then
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,c,0)
        end
    end
end)

local Section2 = Tab:NewSection("Auto purchase gun")
--Auto purchase gun function
plr.CharacterAdded:Connect(function()
    if getgenv().AGToggled then
        repeat wait() until #plr.Backpack:GetChildren() > 1
        game:GetService("ReplicatedStorage").BuyGun:FireServer(getgenv().AGGun)
    end
end)
--Auto purchase gun
Section2:NewToggle("Auto purchase gun", "Purchase gun on respawn", function(state)
    if state then
        getgenv().AGToggled = true
    else
        getgenv().AGToggled = false
    end
end)
--Auto purchase gun select gun
Section2:NewDropdown("Gun", "Purchase this gun on respawn", {"AK","G36","Minigun"}, function(currentOption)
    getgenv().AGGun = currentOption
end)

local Section3 = Tab:NewSection("God Mode")
--God mode toggle
getgenv().GodToggle = false
Section3:NewToggle("GodMode", "LPlr.Character.Humanoid.Health = math.huge", function(state)
	if state then
		getgenv().GodToggle = true
		while wait() do
			if getgenv().GodToggle then
				if getgenv().GodMethod == "FF" then
					oldPos = plr.Character:WaitForChild("HumanoidRootPart").CFrame
					rEvent:FireServer(plr.Team.Name)
					wait(9.5)
				elseif getgenv().GodMethod == "PLACEHOLDER" then
					
				end
			else
				oldPos = 0
				break
			end
		end
	else
		getgenv().GodToggle = false
	end
end)
--God mode method dropdown
getgenv().GodMethod = ""
Section3:NewDropdown("Method", "Method of god mode", {"FF"}, function(currentOption)
    getgenv().GodMethod = currentOption
end)

--Tab 2 -- KEYBINDS

local Tab2 = Window:NewTab("Keybinds")

local T2Section1 = Tab2:NewSection("General Keybinds")

T2Section1:NewKeybind("ToggleUI", "Toggle UI visibility", Enum.KeyCode.B, function()
	Library:ToggleUI()
end)

--Respawn keybind
if not getgenv().respawnKey then
	T2Section1:NewKeybind("Respawn", "Respawn instantly", Enum.KeyCode.LeftControl, function()
		if getgenv().SRToggled then
			oldPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
		end
		rEvent:FireServer(plr.Team.Name)
	end)
end

--Medkit keybind
if not getgenv().medkitKey then
	T2Section1:NewKeybind("Medkit", "Use medkit", Enum.KeyCode.Q, function()
	    if game.Players.LocalPlayer.Backpack:FindFirstChild("Medkit") then
            local m = game.Players.LocalPlayer.Backpack.Medkit
            local p = game.Players.LocalPlayer
            if p.Character:FindFirstChildOfClass("Tool") then
                equippedTool = p.Character:FindFirstChildOfClass("Tool")
            else
                equippedTool = false
            end
            
            p.Character.Humanoid:EquipTool(m)
            wait(.15)
            m:Activate()
            wait(.15)
            p.Character.Humanoid:UnequipTools()
            
            if not equippedTool then
                
            else
                if p.Backpack:FindFirstChild(equippedTool.Name) then
                    p.Character.Humanoid:EquipTool(equippedTool)
                    if equippedTool:FindFirstChild("Barrel") then
                        wait()
                        keypress(70)
                        keyrelease(70)
                    end
                end
            end
	    elseif game.Players.LocalPlayer.Character:FindFirstChild("Medkit") then
            game.Players.LocalPlayer.Character:FindFirstChild("Medkit"):Activate()
        end
	end)
end

--Tab 3 -- OPTIONS

local Tab3 = Window:NewTab("Options")

local T3Section1 = Tab3:NewSection("Options")

--Tab 4 -- Other

local Tab4 = Window:NewTab("Other")

local T4Section1 = Tab4:NewSection("Other")

--Purchase gun
T4Section1:NewDropdown("Purchase gun", "Purchase a gun (takes money)", {"AK","G36","Minigun"}, function(currentOption)
    game:GetService("ReplicatedStorage").BuyGun:FireServer(currentOption)
end)

--Toggle capitol gate
T4Section1:NewButton("Toggle capitol gate", "Open/close the gate to the capitol", function()
    fireclickdetector(game:GetService("Workspace").HLSDOOR3.Click.ClickDetector)
end)

--Spawn heli
T4Section1:NewButton("Spawn heli", "Spawns a helicopter at the helipad", function()
    fireclickdetector(game:GetService("Workspace").Heli.Button1.ClickDetector)
end)
--spam heli function
function spamHeli()
    while getgenv().spamHeli do
        wait()
        fireclickdetector(game:GetService("Workspace").Heli.Button1.ClickDetector)
    end
end
--spam heli
T4Section1:NewToggle("Spam heli (CANT SHOOT)", "Spams helicopters, disabling heli spawning (CANT SHOOT)", function(state)
    if state then
        getgenv().spamHeli = true
        spamHeli()
    else
        getgenv().spamHeli = false
    end
end)

--Toggle AFK
local tafk = false
T4Section1:NewButton("Toggle AFK", "Toggle AFK overhead", function()
    tafk = not tafk
    game:GetService("ReplicatedStorage").Events_UI.SetAFK:FireServer(tafk)
end)
--Always AFK function
--spawned
plr.CharacterAdded:Connect(function(c)
    --spawned
    repeat wait() until c:WaitForChild("Head"):FindFirstChild("OverheadGui")
    if getgenv().afk then
        game:GetService("ReplicatedStorage").Events_UI.SetAFK:FireServer(true)
    end
    --changed
    c.Head.OverheadGui:WaitForChild("Labels"):WaitForChild("AFK"):GetPropertyChangedSignal("Visible"):Connect(function()
        if getgenv().afk then
            game:GetService("ReplicatedStorage").Events_UI.SetAFK:FireServer(true)
        end
    end)
end)
--Always AFK
T4Section1:NewToggle("Always AFK", "makes u look cool", function(state)
    if state then
        getgenv().afk = true
    else
        getgenv().afk = false
    end
    game:GetService("ReplicatedStorage").Events_UI.SetAFK:FireServer(getgenv().afk)
end)

--Prep functions
rEvent:FireServer(plr.Team.Name)
