-- ====================================================================
-- MAXIMUM CLEAR PURGE ENGINE: Wipes all old script interfaces
-- ====================================================================
for _, folder in pairs({game:GetService("CoreGui"), game.Players.LocalPlayer:WaitForChild("PlayerGui")}) do
    for _, name in pairs({"LS_FinalTrueEngine", "LS_TimeEngine_Farm", "LS_SmartMonitor_Loop", "LS_Proximity_Loop", "LS_RakNet_Spoofer", "LS_Solara_UI", "ScreenGui"}) do
        local target = folder:FindFirstChild(name)
        if target then
            pcall(function() target:Destroy() end)
        end
    end
end

getgenv().farm_active = false

local p = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- CONFIGURABLE TIMER WINDOWS (In Seconds)
local GRAB_DURATION = 15
local SERVICE_DELAY = 1.2

-- Create isolated clean UI interface
local sg = Instance.new("ScreenGui", game:GetService("CoreGui") or p:WaitForChild("PlayerGui"))
sg.Name = "LS_FinalTrueEngine"

local f = Instance.new("Frame", sg)
f.Size, f.Position, f.BackgroundColor3, f.Draggable, f.Active = UDim2.new(0, 220, 0, 110), UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(20,20,25), true, true
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

local b = Instance.new("TextButton", f)
b.Size, b.Position, b.BackgroundColor3, b.Text, b.TextColor3, b.Font, b.TextSize = UDim2.new(0.9, 0, 0, 40), UDim2.new(0.05, 0, 0, 15), Color3.fromRGB(45,45,50), "Legit Walk Farm: OFF", Color3.fromRGB(220,80,80), Enum.Font.SourceSansBold, 14
Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

b.MouseButton1Click:Connect(function()
    getgenv().farm_active = not getgenv().farm_active
    b.BackgroundColor3 = getgenv().farm_active and Color3.fromRGB(60,120,60) or Color3.fromRGB(45,45,50)
    b.TextColor3 = getgenv().farm_active and Color3.fromRGB(255,255,255) or Color3.fromRGB(220,80,80)
    b.Text = "Legit Walk Farm: "..(getgenv().farm_active and "ON" or "OFF")
end)

local afk = Instance.new("TextButton", f)
afk.Size, afk.Position, afk.BackgroundColor3, afk.Text, afk.TextColor3, afk.Font, afk.TextSize = UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0, 60), Color3.fromRGB(40,55,75), "Force Anti-AFK Jump", Color3.fromRGB(255,255,255), Enum.Font.SourceSansBold, 14
Instance.new("UICorner", afk).CornerRadius = UDim.new(0, 6)
afk.MouseButton1Click:Connect(function()
    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game) task.wait(0.05) vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end)

local function getRem(n) return game:GetService("ReplicatedStorage"):FindFirstChild(n, true) end

local function getPlot()
    for _, v in pairs(game:GetService("Workspace").Plots:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value == p then return v end
    end
end

-- ====================================================================
-- LEGIT CHARACTER PATHFINDING ENGINE (Bypasses RakNet Anticheat)
-- ====================================================================
local function walkTo(targetPos)
    local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if not r or not hum then return end
    
    hum:MoveTo(targetPos)
    
    local timeout = tick()
    -- Wait until character reaches target or gets stuck for 3 seconds max
    while getgenv().farm_active and (r.Position - targetPos).Magnitude > 4.5 and (tick() - timeout) < 3 do
        task.wait()
    end
end

local function getClothingItem()
    local deb = game:GetService("Workspace"):FindFirstChild("Debris")
    if deb and deb:FindFirstChild("Clothing") then
        local close, sDist = nil, math.huge
        local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r then
            for _, v in pairs(deb.Clothing:GetChildren()) do
                local pt = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                if pt then
                    local d = (r.Position - pt.Position).Magnitude
                    if d < sDist then sDist = d close = v end
                end
            end
        end
        return close
    end
end

-- BACKGROUND ANTI-CHAIR LOOP
task.spawn(function()
    while true do
        task.wait(0.3)
        if getgenv().farm_active and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit then
                hum.Sit = false
                task.wait(0.02)
                vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end
        end
    end
end)

-- ====================================================================
-- MAIN CONTROL LOGIC LOOP (PURE LEGIT WALKING PHYSICS)
-- ====================================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        
        if getgenv().farm_active and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pl = getPlot()
            if pl then
                local machineFolder = pl:FindFirstChild("WashingMachines")
                
                -- PHASE 1: Collect Clothing via Organic Humanoid Walking
                local startTime = tick()
                while getgenv().farm_active and (tick() - startTime) < GRAB_DURATION do
                    task.wait(0.05)
                    local item = getClothingItem()
                    local part = item and (item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true))
                    if part then
                        walkTo(part.Position)
                        local gr = getRem("GrabClothing") or getRem("CollectItem")
                        -- Fires packet while physically standing 0-studs next to it
                        if gr and (p.Character.HumanoidRootPart.Position - part.Position).Magnitude <= 8 then 
                            gr:FireServer(item) 
                        end
                    end
                end
                
                -- PHASE 2: Walk Back to Base Plot to Interact with Appliances
                if getgenv().farm_active and machineFolder and #machineFolder:GetChildren() > 0 then
                    local firstMachine = machineFolder:GetChildren()[1]
                    local machinePart = firstMachine and (firstMachine:IsA("BasePart") and firstMachine or firstMachine:FindFirstChildWhichIsA("BasePart", true))
                    
                    if machinePart then
                        walkTo(machinePart.Position)
                        task.wait(0.1)
                        
                        local lr = getRem("LoadWashingMachine")
                        local ur = getRem("UnloadWashingMachine")
                        
                        for _, m in pairs(machineFolder:GetChildren()) do
                            if ur then ur:FireServer(m) end
                        end
                        task.wait(SERVICE_DELAY)
                        
                        for _, m in pairs(machineFolder:GetChildren()) do
                            if lr then lr:FireServer(m) end
                        end
                        task.wait(0.2)
                    end
                end
                
                -- PHASE 3: Fire Your Original Chute Remote
                if getgenv().farm_active then
                    -- Fired while character is physically inside your plot boundaries with valid walking history
                    local dr = getRem("DropClothesInChute")
                    if dr then 
                        dr:FireServer() 
                    end
                    task.wait(0.3)
                end
                
            end
        end
    end
end)

p.Idled:Connect(function()
    vim:SendKeyEvent(true, Enum.KeyCode.W, false, game) task.wait(0.1) vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
end)
