getgenv().loadout = {"AK","G36","Medkit","Sword"}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("aaaaaaaa", "Serpent")

local plr = game.Players.LocalPlayer

local rEvent = game:GetService("ReplicatedStorage").Events_UI.ChangeTeams

--Tab 1 -- TOGGLES

local Tab = Window:NewTab("Toggles")

local Section = Tab:NewSection("Toggles")

--Quick respawn toggle
Section:NewToggle("QuickRespawn", "Automatically respawn at a changable rate (options)", function(state)
    if state then
        getgenv().QRToggled = true
    else
        getgenv().QRToggled = false
    end
end)
getgenv().QRToggled = false
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

local Section2 = Tab:NewSection("God Mode")

getgenv().GodMethod = ""
--God mode method dropdown
Section2:NewDropdown("Method", "Method of god mode", {"FF"}, function(currentOption)
    getgenv().GodMethod = currentOption
end)

getgenv().GodToggle = false
--God mode toggle
Section2:NewToggle("GodMode", "LPlr.Character.Humanoid.Health = math.huge", function(state)
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

--Tab 2 -- KEYBINDS

local Tab2 = Window:NewTab("Keybinds")

local T2Section1 = Tab2:NewSection("General Keybinds")

T2Section1:NewKeybind("ToggleUI", "Toggle UI visibility", Enum.KeyCode.X, function()
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
        local m = game.Players.LocalPlayer.Backpack.Medkit
        local p = game.Players.LocalPlayer
        if p.Character:FindFirstChildOfClass("Tool") then
            print("has tool equipped")
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
                print("equipped tool is in backpack")
                p.Character.Humanoid:EquipTool(equippedTool) 
                print("equipped tool")
            end
        end
	end)
end

--Tab 3 -- OPTIONS

local Tab3 = Window:NewTab("Options")

local T3Section1 = Tab3:NewSection("Options")

T3Section1:NewSlider("RespawnDelay", "The delay before you auto-respawn", 3, 0, function(s)
    getgenv().QRDelay = s
end)

--Prep functions
rEvent:FireServer(plr.Team.Name)
