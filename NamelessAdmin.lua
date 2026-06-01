local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 Nameless Admin",
    LoadingTitle = "Nameless Admin",
    LoadingSubtitle = "por CriadorYan",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false,
})

local player = game.Players.LocalPlayer
local lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flying = false
local flySpeed = 50
local noclipEnabled = false
local noclipConnection
local airWalkEnabled = false
local airWalkConnection
local airSwimEnabled = false
local airSwimConnection
local flingEnabled = false
local flingConnection
local espEnabled = false
local infiniteJumpEnabled = false
local infiniteJumpConnection
local invisibleEnabled = false
local invisibleParts = {}
local cameraNoclipEnabled = false
local cameraNoclipConnection
local infiniteCameraEnabled = false
local infiniteCameraConnection
local fullbrightEnabled = false
local noFogEnabled = false
local highlightEnabled = false
local backgroundImageId = nil
local backgroundFrame = nil
local f3xLoaded = false

local InvisibleConfig = { Transparency = 0.7 }

local function notify(title, content, duration)
    Rayfield:Notify({Title = title, Content = content, Duration = duration or 2, Image = 4483362458})
end

local function getHumanoid()
    if player.Character and player.Character:FindFirstChild("Humanoid") then return player.Character.Humanoid end
    return nil
end

local function changeBackground(imageId)
    if not imageId or imageId == "" then notify("Erro", "Link invalido!") return end
    if backgroundFrame then backgroundFrame:Destroy(); backgroundFrame = nil end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NamelessBackground"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = -1
    backgroundFrame = Instance.new("Frame")
    backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
    backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundFrame.BackgroundTransparency = 0.3
    backgroundFrame.Parent = screenGui
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.ScaleType = Enum.ScaleType.Crop
    imageLabel.Parent = backgroundFrame
    pcall(function()
        local success, result = pcall(function() return tonumber(imageId) end)
        if success and result then imageLabel.Image = "rbxassetid://" .. imageId else imageLabel.Image = imageId end
        local blur = Instance.new("BlurEffect"); blur.Size = 3; blur.Parent = imageLabel
        notify("Sucesso", "Background atualizado!", 3)
    end)
    backgroundImageId = imageId
end

local function removeBackground()
    if backgroundFrame then backgroundFrame:Destroy(); backgroundFrame = nil end
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then local bg = playerGui:FindFirstChild("NamelessBackground") if bg then bg:Destroy() end end
    backgroundImageId = nil
    notify("Sucesso", "Background removido!", 2)
end

local function setupInvisibleParts()
    invisibleParts = {}
    if player.Character then
        for _, obj in pairs(player.Character:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(invisibleParts, obj)
            end
        end
        if invisibleEnabled then
            for _, part in pairs(invisibleParts) do
                part.Transparency = InvisibleConfig.Transparency
            end
        end
    end
end

local function enableInvisible()
    invisibleEnabled = true
    setupInvisibleParts()
    for _, part in pairs(invisibleParts) do
        if part:IsA("BasePart") then
            part.Transparency = InvisibleConfig.Transparency
        end
    end
    notify("Invisivel", "Ativado! Ninguem te ve", 2)
end

local function disableInvisible()
    invisibleEnabled = false
    for _, part in pairs(invisibleParts) do
        if part:IsA("BasePart") then
            part.Transparency = 0
        end
    end
    invisibleParts = {}
    notify("Invisivel", "Desativado!", 2)
end

setupInvisibleParts()

player.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if flying then stopFly() end
    if noclipEnabled then task.wait(0.1); enableNoclip() end
    if backgroundImageId then task.wait(0.5); changeBackground(backgroundImageId) end
    setupInvisibleParts()
    if invisibleEnabled then
        for _, part in pairs(invisibleParts) do
            if part:IsA("BasePart") then
                part.Transparency = InvisibleConfig.Transparency
            end
        end
    end
end)

local function enableCameraNoclip()
    cameraNoclipEnabled = true
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
    cameraNoclipConnection = RunService.RenderStepped:Connect(function()
        if not cameraNoclipEnabled then return end
        if camera.CameraType ~= Enum.CameraType.Scriptable then camera.CameraType = Enum.CameraType.Scriptable end
        player.CameraMinZoomDistance = 0.1; player.CameraMaxZoomDistance = 99999
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local newCFrame = CFrame.new(root.Position + Vector3.new(0, 5, 15), root.Position)
            camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.1)
        end
    end)
    notify("Camera Noclip", "Ativado! Atravessa paredes", 3)
end

local function disableCameraNoclip()
    cameraNoclipEnabled = false
    if cameraNoclipConnection then cameraNoclipConnection:Disconnect(); cameraNoclipConnection = nil end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    player.CameraMinZoomDistance = 0.5; player.CameraMaxZoomDistance = 20
    notify("Camera Noclip", "Desativado!", 2)
end

local function enableInfiniteCamera()
    infiniteCameraEnabled = true
    player.CameraMinZoomDistance = 0.1; player.CameraMaxZoomDistance = 999999
    infiniteCameraConnection = RunService.RenderStepped:Connect(function()
        if not infiniteCameraEnabled then return end
        if player.CameraMaxZoomDistance < 999999 then player.CameraMaxZoomDistance = 999999 end
        if player.CameraMinZoomDistance > 0.1 then player.CameraMinZoomDistance = 0.1 end
    end)
    notify("Zoom Infinito", "Ativado!", 3)
end

local function disableInfiniteCamera()
    infiniteCameraEnabled = false
    if infiniteCameraConnection then infiniteCameraConnection:Disconnect(); infiniteCameraConnection = nil end
    player.CameraMinZoomDistance = 0.5; player.CameraMaxZoomDistance = 20
    notify("Zoom Infinito", "Desativado!", 2)
end

local function enableFling()
    flingEnabled = true
    local function flingPlayers()
        if not flingEnabled or not player.Character then return end
        local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local myPosition = myRoot.Position
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                local otherHum = otherPlayer.Character:FindFirstChild("Humanoid")
                if otherRoot and otherHum then
                    local distance = (myPosition - otherRoot.Position).Magnitude
                    if distance < 50 then
                        local flingForce = Instance.new("BodyVelocity")
                        flingForce.MaxForce = Vector3.new(1, 1, 1) * math.huge; flingForce.P = math.huge
                        local direction = (otherRoot.Position - myPosition).Unit
                        flingForce.Velocity = Vector3.new(direction.X * 50000 + math.random(-20000, 20000), 50000 + math.random(0, 30000), direction.Z * 50000 + math.random(-20000, 20000))
                        flingForce.Parent = otherRoot; game:GetService("Debris"):AddItem(flingForce, 0.3)
                        local flingSpin = Instance.new("BodyAngularVelocity")
                        flingSpin.MaxTorque = Vector3.new(1, 1, 1) * math.huge
                        flingSpin.AngularVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
                        flingSpin.Parent = otherRoot; game:GetService("Debris"):AddItem(flingSpin, 0.3)
                        otherHum.PlatformStand = true; task.wait(0.5); pcall(function() otherHum.PlatformStand = false end)
                        otherRoot.Velocity = Vector3.new(direction.X * 500 + math.random(-200, 200), 500 + math.random(0, 300), direction.Z * 500 + math.random(-200, 200))
                        pcall(function() otherRoot:SetNetworkOwner(nil) end)
                    end
                end
            end
        end
    end
    flingConnection = RunService.Heartbeat:Connect(flingPlayers)
    notify("Fling TURBINADO", "Ativado! Alcance: 50 studs", 3)
end

local function disableFling()
    flingEnabled = false
    if flingConnection then flingConnection:Disconnect(); flingConnection = nil end
    notify("Fling", "Desativado!", 2)
end

local function destroyHub()
    if flying then stopFly() end
    if noclipEnabled then disableNoclip() end
    if airWalkEnabled then disableAirWalk() end
    if airSwimEnabled then disableAirSwim() end
    if infiniteJumpEnabled then disableInfiniteJump() end
    if invisibleEnabled then disableInvisible() end
    if cameraNoclipEnabled then disableCameraNoclip() end
    if infiniteCameraEnabled then disableInfiniteCamera() end
    if fullbrightEnabled then disableFullbright() end
    if noFogEnabled then disableNoFog() end
    if flingEnabled then disableFling() end
    if espEnabled then disableESP() end
    if backgroundFrame then removeBackground() end
    pcall(function() Window:Destroy() end)
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then for _, gui in pairs(playerGui:GetChildren()) do if gui.Name:find("Rayfield") or gui.Name:find("sirius") or gui.Name == "NamelessBackground" then gui:Destroy() end end end
    notify("Hub Destruido", "Nameless Admin removido!", 2)
end

local function enableFullbright()
    fullbrightEnabled = true
    lighting.Brightness = 3; lighting.ClockTime = 14; lighting.FogEnd = 100000; lighting.GlobalShadows = false
    lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255); lighting.Ambient = Color3.fromRGB(255, 255, 255)
    notify("Fullbright", "Ativado!", 2)
end

local function disableFullbright()
    fullbrightEnabled = false
    lighting.Brightness = 2; lighting.GlobalShadows = true
    lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127); lighting.Ambient = Color3.fromRGB(127, 127, 127)
    notify("Fullbright", "Desativado!", 2)
end

local function enableNoFog()
    noFogEnabled = true
    lighting.FogEnd = 1000000; lighting.FogStart = 1000000
    if lighting:FindFirstChild("Atmosphere") then lighting.Atmosphere:Destroy() end
    notify("NoFog", "Ativado!", 2)
end

local function disableNoFog()
    noFogEnabled = false
    lighting.FogEnd = 10000; lighting.FogStart = 0
    notify("NoFog", "Desativado!", 2)
end

local function loadF3X()
    if f3xLoaded then
        notify("F3X", "Ferramenta ja carregada!", 2)
        return
    end
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ImFEARLESScheat/F3X/main/F3X.lua"))()
        f3xLoaded = true
        notify("F3X", "Ferramenta carregada! Use B para abrir", 4)
    end)
end

local function createPart(partType)
    local char = player.Character
    if not char then notify("Erro", "Personagem nao encontrado!", 2) return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then notify("Erro", "RootPart nao encontrada!", 2) return end
    
    local part = Instance.new("Part")
    part.Position = root.Position + Vector3.new(0, 5, 0)
    part.Anchored = true
    part.CanCollide = true
    part.BrickColor = BrickColor.random()
    part.Material = Enum.Material.SmoothPlastic
    part.Parent = workspace
    
    if partType == "Block" then
        part.Size = Vector3.new(4, 2, 4)
    elseif partType == "Sphere" then
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(4, 4, 4)
    elseif partType == "Cylinder" then
        part.Shape = Enum.PartType.Cylinder
        part.Size = Vector3.new(4, 4, 4)
    elseif partType == "Triangle" then
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Wedge
        mesh.Parent = part
        part.Size = Vector3.new(4, 2, 4)
    elseif partType == "CornerWedge" then
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.CornerWedge
        mesh.Parent = part
        part.Size = Vector3.new(4, 4, 4)
    elseif partType == "Truss" then
        part.Size = Vector3.new(4, 8, 4)
        part.Material = Enum.Material.Metal
    end
    
    notify("Construcao", partType .. " criado!", 2)
end

local function deleteAllBuilds()
    local count = 0
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Part") and obj.Anchored and obj.Parent == workspace and not obj:FindFirstChildOfClass("Humanoid") then
            obj:Destroy()
            count = count + 1
        end
    end
    notify("Construcao", count .. " pecas deletadas!", 2)
end

local function startFly()
    local hum = getHumanoid()
    if not hum then notify("Erro", "Humanoid nao encontrado!", 2) return false end
    flying = true
    pcall(function()
        loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\40\39\104\116\116\112\115\58\47\47\103\105\115\116\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\109\101\111\122\111\110\101\89\84\47\98\102\48\51\55\100\102\102\57\102\48\97\55\48\48\49\55\51\48\52\100\100\100\54\55\102\100\99\100\51\55\48\47\114\97\119\47\101\49\52\101\55\52\102\52\50\53\98\48\54\48\100\102\53\50\51\51\52\51\99\102\51\48\98\55\56\55\48\55\52\101\98\51\99\53\100\50\47\97\114\99\101\117\115\37\50\53\50\48\120\37\50\53\50\48\102\108\121\37\50\53\50\48\50\37\50\53\50\48\111\98\102\108\117\99\97\116\111\114\39\41\44\116\114\117\101\41\41\40\41\10\10")()
    end)
    notify("Voo", "Ativado! Script de fly carregado", 2)
    return true
end

local function stopFly()
    flying = false
    local hum = getHumanoid()
    if hum then
        hum.AutoRotate = true
        if hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart") then
            local r = hum.Parent.HumanoidRootPart
            for _, child in pairs(r:GetChildren()) do
                if child:IsA("BodyVelocity") or child:IsA("BodyGyro") then child:Destroy() end
            end
        end
    end
    notify("Voo", "Desativado!", 2)
end

local function enableNoclip()
    noclipEnabled = true
    noclipConnection = RunService.Stepped:Connect(function()
        if noclipEnabled and player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end
    end)
    notify("Noclip", "Ativado!", 2)
end

local function disableNoclip()
    noclipEnabled = false
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
    notify("Noclip", "Desativado!", 2)
end

local function enableAirWalk()
    airWalkEnabled = true
    local function createPlatform()
        if not airWalkEnabled or not player.Character then return end
        local hum = player.Character:FindFirstChild("Humanoid"); local root = player.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum:GetState() == Enum.HumanoidStateType.Freefall then
            local bv = root:FindFirstChild("AirWalkVelocity")
            if not bv then bv = Instance.new("BodyVelocity"); bv.Name = "AirWalkVelocity"; bv.MaxForce = Vector3.new(0, 5000, 0); bv.Parent = root end
            local md = hum.MoveDirection; bv.Velocity = Vector3.new(md.X * hum.WalkSpeed, 0, md.Z * hum.WalkSpeed)
        elseif root and root:FindFirstChild("AirWalkVelocity") then root.AirWalkVelocity:Destroy() end
    end
    airWalkConnection = RunService.RenderStepped:Connect(createPlatform)
    notify("Air Walk", "Ativado!", 2)
end

local function disableAirWalk()
    airWalkEnabled = false
    if airWalkConnection then airWalkConnection:Disconnect(); airWalkConnection = nil end
    if player.Character then local root = player.Character:FindFirstChild("HumanoidRootPart"); if root and root:FindFirstChild("AirWalkVelocity") then root.AirWalkVelocity:Destroy() end end
    notify("Air Walk", "Desativado!", 2)
end

local function enableAirSwim()
    airSwimEnabled = true
    local function createSwimEffect()
        if not airSwimEnabled or not player.Character then return end
        local hum = player.Character:FindFirstChild("Humanoid"); local root = player.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            local sv = root:FindFirstChild("SwimVelocity")
            if not sv then sv = Instance.new("BodyVelocity"); sv.Name = "SwimVelocity"; sv.MaxForce = Vector3.new(5000, 5000, 5000); sv.Parent = root end
            local md = hum.MoveDirection; local cam = workspace.CurrentCamera
            if md.Magnitude > 0 then
                local vel = cam.CFrame.LookVector * (-md.Z * hum.WalkSpeed) + cam.CFrame.RightVector * (md.X * hum.WalkSpeed)
                if hum.Jump then vel += cam.CFrame.UpVector * hum.JumpPower * 0.5 end; sv.Velocity = vel
            else sv.Velocity = Vector3.new(0, 0.5, 0) end
        end
    end
    airSwimConnection = RunService.RenderStepped:Connect(createSwimEffect)
    notify("Air Swim", "Ativado!", 2)
end

local function disableAirSwim()
    airSwimEnabled = false
    if airSwimConnection then airSwimConnection:Disconnect(); airSwimConnection = nil end
    if player.Character then local root = player.Character:FindFirstChild("HumanoidRootPart"); if root then if root:FindFirstChild("SwimVelocity") then root.SwimVelocity:Destroy() end; if root:FindFirstChild("SwimGyro") then root.SwimGyro:Destroy() end end end
    notify("Air Swim", "Desativado!", 2)
end

local function enableInfiniteJump()
    infiniteJumpEnabled = true
    infiniteJumpConnection = UIS.JumpRequest:Connect(function()
        if infiniteJumpEnabled then local hum = getHumanoid(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
    end)
    notify("Infinite Jump", "Ativado!", 2)
end

local function disableInfiniteJump()
    infiniteJumpEnabled = false
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect(); infiniteJumpConnection = nil end
    notify("Infinite Jump", "Desativado!", 2)
end

local function morphPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then notify("Erro", "Jogador nao encontrado!") return end
    local function cloneCharacter()
        local myChar = player.Character; local targetChar = targetPlayer.Character
        if not myChar or not targetChar then return end
        for _, item in pairs(myChar:GetChildren()) do if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then item:Destroy() end end
        for _, item in pairs(targetChar:GetChildren()) do if item:IsA("Shirt") then item:Clone().Parent = myChar elseif item:IsA("Pants") then item:Clone().Parent = myChar elseif item:IsA("ShirtGraphic") then item:Clone().Parent = myChar elseif item:IsA("Accessory") then item:Clone().Parent = myChar end end
        for _, partName in pairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
            local myPart = myChar:FindFirstChild(partName); local targetPart = targetChar:FindFirstChild(partName)
            if myPart and targetPart and myPart:IsA("BasePart") and targetPart:IsA("BasePart") then myPart.BrickColor = targetPart.BrickColor; myPart.Color = targetPart.Color; myPart.Size = targetPart.Size; myPart.Transparency = targetPart.Transparency; myPart.Material = targetPart.Material end
        end
    end
    pcall(cloneCharacter); notify("Morph", "Transformado em: " .. targetPlayer.Name, 3)
end

local function enableESP()
    espEnabled = true
    for _, existing in pairs(workspace:GetDescendants()) do if existing:IsA("BillboardGui") and existing.Name == "ESP_Gui" then existing:Destroy() end; if existing:IsA("Highlight") and existing.Name == "ESP_Highlight" then existing:Destroy() end end
    local function createESP(model, name, color, isNPC)
        if not model then return end; local head = model:FindFirstChild("Head")
        if not head or not model:FindFirstChild("Humanoid") then return end
        local highlight = Instance.new("Highlight"); highlight.Name = "ESP_Highlight"; highlight.FillColor = color; highlight.OutlineColor = Color3.fromRGB(255, 255, 255); highlight.FillTransparency = 0.7; highlight.OutlineTransparency = 0.3; highlight.Parent = model
        local billboard = Instance.new("BillboardGui"); billboard.Name = "ESP_Gui"; billboard.Size = UDim2.new(0, 200, 0, 50); billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.AlwaysOnTop = true; billboard.Parent = head
        local textLabel = Instance.new("TextLabel"); textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1; textLabel.TextColor3 = isNPC and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255); textLabel.TextStrokeTransparency = 0; textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); textLabel.TextSize = 14; textLabel.Font = Enum.Font.SourceSansBold; textLabel.Text = name; textLabel.Parent = billboard
    end
    for _, plr in pairs(game.Players:GetPlayers()) do if plr ~= player then if plr.Character then createESP(plr.Character, plr.Name, Color3.fromRGB(0, 255, 255), false) end; plr.CharacterAdded:Connect(function(char) if espEnabled then task.wait(0.5); createESP(char, plr.Name, Color3.fromRGB(0, 255, 255), false) end end) end end
    for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then if obj.Humanoid.Health > 0 then createESP(obj, "[NPC] " .. obj.Name, Color3.fromRGB(255, 255, 0), true) end end end
    notify("ESP", "Ativado!", 2)
end

local function disableESP()
    espEnabled = false
    for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("BillboardGui") and obj.Name == "ESP_Gui" then obj:Destroy() end; if obj:IsA("Highlight") and obj.Name == "ESP_Highlight" then obj:Destroy() end end
    notify("ESP", "Desativado!", 2)
end

local MainTab = Window:CreateTab("Principal", 4483362458)
MainTab:CreateSlider({Name = "Velocidade", Range = {16, 200}, Increment = 1, Suffix = "studs/s", CurrentValue = 16, Flag = "WalkSpeed", Callback = function(v) local h = getHumanoid() if h then h.WalkSpeed = v end end})
MainTab:CreateSlider({Name = "Pulo", Range = {50, 300}, Increment = 1, Suffix = "power", CurrentValue = 50, Flag = "JumpPower", Callback = function(v) local h = getHumanoid() if h then h.JumpPower = v; h.UseJumpPower = true end end})

local FlyTab = Window:CreateTab("Voo", 4483362458)
FlyTab:CreateToggle({Name = "Ativar Voo", CurrentValue = false, Flag = "Fly", Callback = function(v) if v then startFly() else if flying then stopFly() end end end})
FlyTab:CreateSlider({Name = "Velocidade Voo", Range = {20, 200}, Increment = 5, Suffix = "studs/s", CurrentValue = 50, Flag = "FlySpeed", Callback = function(v) flySpeed = v end})

local MovementTab = Window:CreateTab("Movimento", 4483362458)
MovementTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) if v then enableNoclip() else disableNoclip() end end})
MovementTab:CreateToggle({Name = "Air Walk", CurrentValue = false, Callback = function(v) if v then enableAirWalk() else disableAirWalk() end end})
MovementTab:CreateToggle({Name = "Air Swim", CurrentValue = false, Callback = function(v) if v then enableAirSwim() else disableAirSwim() end end})
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) if v then enableInfiniteJump() else disableInfiniteJump() end end})

local WorldTab = Window:CreateTab("Mundo", 4483362458)
WorldTab:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(v) if v then enableFullbright() else disableFullbright() end end})
WorldTab:CreateToggle({Name = "NoFog", CurrentValue = false, Callback = function(v) if v then enableNoFog() else disableNoFog() end end})

WorldTab:CreateSection("Construcao (F3X)")
WorldTab:CreateButton({Name = "Abrir F3X Building Tools", Callback = function() loadF3X() end})
WorldTab:CreateLabel("Pressione B para abrir/fechar o F3X")

WorldTab:CreateSection("Criar Pecas Rapidas")
WorldTab:CreateButton({Name = "Criar Bloco", Callback = function() createPart("Block") end})
WorldTab:CreateButton({Name = "Criar Esfera", Callback = function() createPart("Sphere") end})
WorldTab:CreateButton({Name = "Criar Cilindro", Callback = function() createPart("Cylinder") end})
WorldTab:CreateButton({Name = "Criar Triangulo", Callback = function() createPart("Triangle") end})
WorldTab:CreateButton({Name = "Criar Cunha de Canto", Callback = function() createPart("CornerWedge") end})
WorldTab:CreateButton({Name = "Criar Trelica", Callback = function() createPart("Truss") end})

WorldTab:CreateSection("Limpar")
WorldTab:CreateButton({Name = "Deletar Todas Construcoes", Callback = function() deleteAllBuilds() end})

local CameraTab = Window:CreateTab("Camera", 4483362458)
CameraTab:CreateToggle({Name = "Camera Noclip", CurrentValue = false, Callback = function(v) if v then enableCameraNoclip() else disableCameraNoclip() end end})
CameraTab:CreateToggle({Name = "Zoom Infinito", CurrentValue = false, Callback = function(v) if v then enableInfiniteCamera() else disableInfiniteCamera() end end})

local TrollTab = Window:CreateTab("Troll", 4483362458)
TrollTab:CreateToggle({Name = "Fling TURBINADO", CurrentValue = false, Callback = function(v) if v then enableFling() else disableFling() end end})
TrollTab:CreateSection("Morph")
for _, tp in pairs(game.Players:GetPlayers()) do if tp ~= player then TrollTab:CreateButton({Name = "Morph: " .. tp.Name, Callback = function() morphPlayer(tp) end}) end end
game.Players.PlayerAdded:Connect(function(np) if np ~= player then TrollTab:CreateButton({Name = "Morph: " .. np.Name, Callback = function() morphPlayer(np) end}) end end)

local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) if v then enableESP() else disableESP() end end})

local VisualTab = Window:CreateTab("Visual", 4483362458)
VisualTab:CreateToggle({Name = "Invisivel", CurrentValue = false, Callback = function(v) if v then enableInvisible() else disableInvisible() end end})
VisualTab:CreateToggle({Name = "Highlight Jogadores", CurrentValue = false, Callback = function(v)
    highlightEnabled = v
    if v then
        local function ah(c) if c and not c:FindFirstChild("PlayerHighlight") then local h = Instance.new("Highlight"); h.Name = "PlayerHighlight"; h.FillColor = Color3.fromRGB(0, 255, 255); h.OutlineColor = Color3.fromRGB(255, 255, 255); h.FillTransparency = 0.5; h.Parent = c end end
        for _, plr in pairs(game.Players:GetPlayers()) do if plr ~= player and plr.Character then ah(plr.Character) end end
    else for _, plr in pairs(game.Players:GetPlayers()) do if plr.Character then local h = plr.Character:FindFirstChild("PlayerHighlight") if h then h:Destroy() end end end end
end})

local ConfigTab = Window:CreateTab("Config", 4483362458)
ConfigTab:CreateSection("Background")
ConfigTab:CreateInput({Name = "Link da Imagem", PlaceholderText = "URL ou ID do Roblox...", RemoveTextAfterFocusLost = false, Callback = function(text) if text and text ~= "" then changeBackground(text) end end})
ConfigTab:CreateButton({Name = "Remover Fundo", Callback = function() removeBackground() end})
ConfigTab:CreateSection("Sistema")
ConfigTab:CreateButton({Name = "Destruir Hub", Callback = function() destroyHub() end})

notify("Nameless Admin", "Carregado! por CriadorYan", 3)

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    if flying then stopFly() end
    if flingEnabled then disableFling() end
    if espEnabled then disableESP() end
    if cameraNoclipEnabled then disableCameraNoclip() end
    if infiniteCameraEnabled then disableInfiniteCamera() end
end)
