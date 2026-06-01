--[[
    Nameless Admin - Painel de Controle Mobile
    Usando Rayfield UI
    Criado por: CriadorYan
]]

-- Carregar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 Nameless Admin",
    LoadingTitle = "Nameless Admin",
    LoadingSubtitle = "por CriadorYan",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("🏠 Principal", 4483362458)
local FlyTab = Window:CreateTab("✈️ Voo", 4483362458)
local MovementTab = Window:CreateTab("🏃 Movimento", 4483362458)
local CameraTab = Window:CreateTab("📷 Câmera", 4483362458)
local WorldTab = Window:CreateTab("🌍 Mundo", 4483362458)
local TrollTab = Window:CreateTab("👻 Troll", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local VisualTab = Window:CreateTab("🎨 Visual", 4483362458)
local ConfigTab = Window:CreateTab("⚙️ Configurações", 4483362458)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local flying = false
local flightConnection
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
local espConnections = {}
local highlightEnabled = false
local infiniteJumpEnabled = false
local infiniteJumpConnection
local invisibleEnabled = false
local invisibleLoopConnection = nil
local invisibleCharConnection = nil
local cameraNoclipEnabled = false
local cameraNoclipConnection
local infiniteCameraEnabled = false
local infiniteCameraConnection
local fullbrightEnabled = false
local noFogEnabled = false
local lighting = game:GetService("Lighting")
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local lastWalkSpeedNotify = 0
local lastJumpPowerNotify = 0
local notifyCooldown = 1.5
local currentNotification = nil

-- Background Image
local backgroundImageId = nil
local backgroundFrame = nil

local function notify(title, content, duration)
    if currentNotification then currentNotification = nil end
    currentNotification = Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 2,
        Image = 4483362458,
    })
end

local function getHumanoid()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        return player.Character.Humanoid
    end
    return nil
end

-- ============================================
-- MUDAR FUNDO DA UI
-- ============================================
local function changeBackground(imageId)
    if not imageId or imageId == "" then
        notify("❌ Erro", "Link da imagem inválido!", 2)
        return
    end
    
    -- Remover fundo anterior se existir
    if backgroundFrame then
        backgroundFrame:Destroy()
        backgroundFrame = nil
    end
    
    -- Criar ScreenGui para o fundo
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NamelessBackground"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = -1 -- Ficar atrás de tudo
    
    -- Criar frame de fundo
    backgroundFrame = Instance.new("Frame")
    backgroundFrame.Name = "BackgroundFrame"
    backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
    backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundFrame.BackgroundTransparency = 0.3
    backgroundFrame.Parent = screenGui
    
    -- Criar ImageLabel
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "BackgroundImage"
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.ScaleType = Enum.ScaleType.Crop
    imageLabel.Parent = backgroundFrame
    
    -- Tentar carregar a imagem
    pcall(function()
        -- Verificar se é um ID numérico (roblox asset) ou URL
        local success, result = pcall(function()
            local number = tonumber(imageId)
            return number
        end)
        
        if success and result then
            -- É um ID numérico do Roblox
            imageLabel.Image = "rbxassetid://" .. imageId
        else
            -- É uma URL
            imageLabel.Image = imageId
        end
        
        -- Adicionar um leve blur para dar profundidade
        local blur = Instance.new("BlurEffect")
        blur.Size = 3
        blur.Parent = imageLabel
        
        notify("🖼️ Fundo Alterado", "Background da UI atualizado com sucesso!", 3)
    end)
    
    -- Salvar o ID para reaplicar ao renascer
    backgroundImageId = imageId
end

local function removeBackground()
    if backgroundFrame then
        backgroundFrame:Destroy()
        backgroundFrame = nil
    end
    
    -- Remover ScreenGui
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        local bg = playerGui:FindFirstChild("NamelessBackground")
        if bg then
            bg:Destroy()
        end
    end
    
    backgroundImageId = nil
    notify("🖼️ Fundo Removido", "Background restaurado ao padrão!", 2)
end

-- Reaplicar fundo ao renascer
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    if flying then stopFly() end
    if noclipEnabled then task.wait(0.1); enableNoclip() end
    
    -- Reaplicar background se existir
    if backgroundImageId then
        task.wait(0.5)
        changeBackground(backgroundImageId)
    end
end)

-- ============================================
-- INVISIBLE - REFEITO COMPLETO
-- ============================================
local function makeInvisible(char)
    if not char then return end
    task.wait(0.3)
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CastShadow = false
            part.ShadowOpacity = 0
        end
        if part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
        if part:IsA("Accessory") and part:FindFirstChild("Handle") then
            part.Handle.Transparency = 1
            part.Handle.CastShadow = false
        end
        if part:IsA("MeshPart") or part:IsA("Part") then
            part.Transparency = 1
            part.CastShadow = false
        end
    end
    
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in pairs(head:GetChildren()) do
            if child:IsA("BillboardGui") or child:IsA("SurfaceGui") or child:IsA("Decal") then
                child.Enabled = false
            end
        end
    end
    
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") or child:IsA("Sparkles") or child:IsA("Fire") or child:IsA("Smoke") then
            child.Enabled = false
        end
    end
    
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.NameOcclusion = Enum.NameOcclusion.NoOcclusion
    end
end

local function enableInvisible()
    invisibleEnabled = true
    
    if player.Character then
        makeInvisible(player.Character)
    end
    
    invisibleCharConnection = player.CharacterAdded:Connect(function(char)
        if invisibleEnabled then makeInvisible(char) end
    end)
    
    invisibleLoopConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not invisibleEnabled or not player.Character then return end
        local char = player.Character
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Transparency < 1 then part.Transparency = 1 end
                if part.CastShadow then part.CastShadow = false end
            end
            if part:IsA("Decal") or part:IsA("Texture") then
                if part.Transparency < 1 then part.Transparency = 1 end
            end
            if part:IsA("Accessory") and part:FindFirstChild("Handle") then
                if part.Handle.Transparency < 1 then part.Handle.Transparency = 1 end
            end
        end
        
        local head = char:FindFirstChild("Head")
        if head then
            for _, child in pairs(head:GetChildren()) do
                if (child:IsA("BillboardGui") or child:IsA("SurfaceGui")) and child.Enabled then
                    child.Enabled = false
                end
            end
        end
        
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end)
    
    notify("👻 Invisível", "Verdadeira invisibilidade ativada! NINGUÉM te vê", 3)
end

local function disableInvisible()
    invisibleEnabled = false
    
    if invisibleLoopConnection then invisibleLoopConnection:Disconnect(); invisibleLoopConnection = nil end
    if invisibleCharConnection then invisibleCharConnection:Disconnect(); invisibleCharConnection = nil end
    
    if player.Character then
        local char = player.Character
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 0; part.CastShadow = true end
            if part:IsA("Decal") or part:IsA("Texture") then part.Transparency = 0 end
            if part:IsA("Accessory") and part:FindFirstChild("Handle") then part.Handle.Transparency = 0 end
        end
        
        local head = char:FindFirstChild("Head")
        if head then
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then child.Enabled = true end
            end
        end
        
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") or child:IsA("Sparkles") then
                child.Enabled = true
            end
        end
        
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            hum.NameOcclusion = Enum.NameOcclusion.OccludeAll
        end
    end
    
    notify("👻 Invisível", "Visibilidade restaurada!", 2)
end

-- ============================================
-- CAMERA NOCLIP
-- ============================================
local function enableCameraNoclip()
    cameraNoclipEnabled = true
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
    
    cameraNoclipConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not cameraNoclipEnabled then return end
        if camera.CameraType ~= Enum.CameraType.Scriptable then
            camera.CameraType = Enum.CameraType.Scriptable
        end
        player.CameraMinZoomDistance = 0.1
        player.CameraMaxZoomDistance = 99999
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local newCFrame = CFrame.new(root.Position + Vector3.new(0, 5, 15), root.Position)
            camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.1)
        end
    end)
    
    notify("📷 Camera Noclip", "Câmera atravessa paredes!", 3)
end

local function disableCameraNoclip()
    cameraNoclipEnabled = false
    if cameraNoclipConnection then cameraNoclipConnection:Disconnect(); cameraNoclipConnection = nil end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 20
    notify("📷 Camera Noclip", "Câmera restaurada!", 2)
end

-- ============================================
-- INFINITE CAMERA ZOOM
-- ============================================
local function enableInfiniteCamera()
    infiniteCameraEnabled = true
    player.CameraMinZoomDistance = 0.1
    player.CameraMaxZoomDistance = 999999
    
    infiniteCameraConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not infiniteCameraEnabled then return end
        if player.CameraMaxZoomDistance < 999999 then player.CameraMaxZoomDistance = 999999 end
        if player.CameraMinZoomDistance > 0.1 then player.CameraMinZoomDistance = 0.1 end
    end)
    
    notify("📷 Infinite Zoom", "Zoom infinito ativado!", 3)
end

local function disableInfiniteCamera()
    infiniteCameraEnabled = false
    if infiniteCameraConnection then infiniteCameraConnection:Disconnect(); infiniteCameraConnection = nil end
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 20
    notify("📷 Infinite Zoom", "Zoom restaurado!", 2)
end

-- ============================================
-- FLING TURBINADO
-- ============================================
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
                        flingForce.MaxForce = Vector3.new(1, 1, 1) * math.huge
                        flingForce.P = math.huge
                        local direction = (otherRoot.Position - myPosition).Unit
                        flingForce.Velocity = Vector3.new(direction.X * 50000 + math.random(-20000, 20000), 50000 + math.random(0, 30000), direction.Z * 50000 + math.random(-20000, 20000))
                        flingForce.Parent = otherRoot
                        game:GetService("Debris"):AddItem(flingForce, 0.3)
                        
                        local flingSpin = Instance.new("BodyAngularVelocity")
                        flingSpin.MaxTorque = Vector3.new(1, 1, 1) * math.huge
                        flingSpin.AngularVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
                        flingSpin.Parent = otherRoot
                        game:GetService("Debris"):AddItem(flingSpin, 0.3)
                        
                        otherHum.PlatformStand = true
                        task.wait(0.5)
                        pcall(function() otherHum.PlatformStand = false end)
                        
                        otherRoot.Velocity = Vector3.new(direction.X * 500 + math.random(-200, 200), 500 + math.random(0, 300), direction.Z * 500 + math.random(-200, 200))
                        pcall(function() otherRoot:SetNetworkOwner(nil) end)
                    end
                end
            end
        end
    end
    
    flingConnection = game:GetService("RunService").Heartbeat:Connect(flingPlayers)
    notify("💨 Fling TURBINADO", "Alcance: 50 studs! Jogadores voam LONGE!", 3)
end

local function disableFling()
    flingEnabled = false
    if flingConnection then flingConnection:Disconnect(); flingConnection = nil end
    notify("💨 Fling", "Fling desativado!", 2)
end

-- ============================================
-- DESTRUIR HUB
-- ============================================
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
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui.Name:find("Rayfield") or gui.Name:find("sirius") or gui.Name == "NamelessBackground" then
                gui:Destroy()
            end
        end
    end
    
    notify("🗑️ Hub Destruído", "Nameless Admin removido!", 2)
end

-- ============================================
-- FULLBRIGHT / NOFOG / VOO / NOCLIP / AIR WALK / AIR SWIM / INFINITE JUMP / MORPH / ESP
-- ============================================
local function enableFullbright()
    fullbrightEnabled = true
    lighting.Brightness = 3; lighting.ClockTime = 14; lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    lighting.Ambient = Color3.fromRGB(255, 255, 255)
    notify("💡 Fullbright", "Máxima visibilidade!", 2)
end

local function disableFullbright()
    fullbrightEnabled = false
    lighting.Brightness = 2; lighting.GlobalShadows = true
    lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    lighting.Ambient = Color3.fromRGB(127, 127, 127)
    notify("💡 Fullbright", "Iluminação restaurada!", 2)
end

local function enableNoFog()
    noFogEnabled = true
    lighting.FogEnd = 1000000; lighting.FogStart = 1000000
    if lighting:FindFirstChild("Atmosphere") then lighting.Atmosphere:Destroy() end
    notify("🌫️ NoFog", "Neblina removida!", 2)
end

local function disableNoFog()
    noFogEnabled = false
    lighting.FogEnd = 10000; lighting.FogStart = 0
    notify("🌫️ NoFog", "Neblina restaurada!", 2)
end

local function startFly()
    local hum = getHumanoid()
    if not hum then return false end
    flying = true; hum.PlatformStand = false; hum.AutoRotate = false
    local camera = workspace.CurrentCamera
    local rootPart = hum.Parent:WaitForChild("HumanoidRootPart")
    local bodyGyro = Instance.new("BodyGyro"); bodyGyro.P = 9e4; bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = camera.CFrame; bodyGyro.Parent = rootPart
    local bodyVelocity = Instance.new("BodyVelocity"); bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0,0,0); bodyVelocity.Parent = rootPart
    
    flightConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not flying or not hum.Parent or not rootPart then return end
        local cf = camera.CFrame
        local hDir = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
        bodyGyro.CFrame = hDir.Magnitude > 0 and CFrame.new(rootPart.Position, rootPart.Position + hDir) or bodyGyro.CFrame
        local mv = hum.MoveDirection
        if mv.Magnitude == 0 then bodyVelocity.Velocity = Vector3.new(0,0,0); return end
        local vel = Vector3.new()
        if mv.Z > 0 then vel += cf.LookVector * flySpeed elseif mv.Z < 0 then vel -= cf.LookVector * flySpeed end
        if mv.X > 0 then vel += cf.RightVector * flySpeed elseif mv.X < 0 then vel -= cf.RightVector * flySpeed end
        bodyVelocity.Velocity = vel
    end)
    notify("✈️ Voo", "Ativado!", 2)
    return true
end

local function stopFly()
    flying = false
    if flightConnection then flightConnection:Disconnect(); flightConnection = nil end
    local hum = getHumanoid()
    if hum then
        hum.AutoRotate = true
        if hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart") then
            local r = hum.Parent.HumanoidRootPart
            if r:FindFirstChild("BodyGyro") then r.BodyGyro:Destroy() end
            if r:FindFirstChild("BodyVelocity") then r.BodyVelocity:Destroy() end
        end
    end
    notify("✈️ Voo", "Desativado!", 2)
end

local function enableNoclip()
    noclipEnabled = true
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if noclipEnabled and player.Character then
            for _, p in pairs(player.Character:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end)
    notify("🚫 Noclip", "Ativado!", 2)
end

local function disableNoclip()
    noclipEnabled = false
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if player.Character then
        for _, p in pairs(player.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    notify("🚫 Noclip", "Desativado!", 2)
end

local function enableAirWalk()
    airWalkEnabled = true
    local function createPlatform()
        if not airWalkEnabled or not player.Character then return end
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum:GetState() == Enum.HumanoidStateType.Freefall then
            local bv = root:FindFirstChild("AirWalkVelocity")
            if not bv then bv = Instance.new("BodyVelocity"); bv.Name = "AirWalkVelocity"; bv.MaxForce = Vector3.new(0, 5000, 0); bv.Parent = root end
            local md = hum.MoveDirection
            bv.Velocity = Vector3.new(md.X * hum.WalkSpeed, 0, md.Z * hum.WalkSpeed)
        elseif root and root:FindFirstChild("AirWalkVelocity") then
            root.AirWalkVelocity:Destroy()
        end
    end
    airWalkConnection = game:GetService("RunService").RenderStepped:Connect(createPlatform)
    notify("🚶 Air Walk", "Ativado!", 2)
end

local function disableAirWalk()
    airWalkEnabled = false
    if airWalkConnection then airWalkConnection:Disconnect(); airWalkConnection = nil end
    if player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root and root:FindFirstChild("AirWalkVelocity") then root.AirWalkVelocity:Destroy() end
    end
    notify("🚶 Air Walk", "Desativado!", 2)
end

local function enableAirSwim()
    airSwimEnabled = true
    local function createSwimEffect()
        if not airSwimEnabled or not player.Character then return end
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            local sv = root:FindFirstChild("SwimVelocity")
            if not sv then sv = Instance.new("BodyVelocity"); sv.Name = "SwimVelocity"; sv.MaxForce = Vector3.new(5000, 5000, 5000); sv.Parent = root end
            local md = hum.MoveDirection; local cam = workspace.CurrentCamera
            if md.Magnitude > 0 then
                local vel = cam.CFrame.LookVector * (-md.Z * hum.WalkSpeed) + cam.CFrame.RightVector * (md.X * hum.WalkSpeed)
                if hum.Jump then vel += cam.CFrame.UpVector * hum.JumpPower * 0.5 end
                sv.Velocity = vel
            else sv.Velocity = Vector3.new(0, 0.5, 0) end
        end
    end
    airSwimConnection = game:GetService("RunService").RenderStepped:Connect(createSwimEffect)
    notify("🏊 Air Swim", "Ativado!", 2)
end

local function disableAirSwim()
    airSwimEnabled = false
    if airSwimConnection then airSwimConnection:Disconnect(); airSwimConnection = nil end
    if player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if root:FindFirstChild("SwimVelocity") then root.SwimVelocity:Destroy() end
            if root:FindFirstChild("SwimGyro") then root.SwimGyro:Destroy() end
        end
    end
    notify("🏊 Air Swim", "Desativado!", 2)
end

local function enableInfiniteJump()
    infiniteJumpEnabled = true
    infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
        if infiniteJumpEnabled then
            local hum = getHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    notify("🦘 Infinite Jump", "Ativado!", 2)
end

local function disableInfiniteJump()
    infiniteJumpEnabled = false
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect(); infiniteJumpConnection = nil end
    notify("🦘 Infinite Jump", "Desativado!", 2)
end

local function morphPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then notify("Erro", "Jogador não encontrado!", 2) return end
    local function cloneCharacter()
        local myChar = player.Character
        local targetChar = targetPlayer.Character
        if not myChar or not targetChar then return end
        for _, item in pairs(myChar:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then item:Destroy() end
        end
        for _, item in pairs(targetChar:GetChildren()) do
            if item:IsA("Shirt") then item:Clone().Parent = myChar
            elseif item:IsA("Pants") then item:Clone().Parent = myChar
            elseif item:IsA("ShirtGraphic") then item:Clone().Parent = myChar
            elseif item:IsA("Accessory") then item:Clone().Parent = myChar end
        end
        for _, partName in pairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
            local myPart = myChar:FindFirstChild(partName)
            local targetPart = targetChar:FindFirstChild(partName)
            if myPart and targetPart and myPart:IsA("BasePart") and targetPart:IsA("BasePart") then
                myPart.BrickColor = targetPart.BrickColor; myPart.Color = targetPart.Color
                myPart.Size = targetPart.Size; myPart.Transparency = targetPart.Transparency
                myPart.Material = targetPart.Material
            end
        end
    end
    pcall(cloneCharacter)
    notify("🎭 Morph", "Transformado em: " .. targetPlayer.Name, 3)
end

local function enableESP()
    espEnabled = true
    for _, existing in pairs(workspace:GetDescendants()) do
        if existing:IsA("BillboardGui") and existing.Name == "ESP_Gui" then existing:Destroy() end
        if existing:IsA("Highlight") and existing.Name == "ESP_Highlight" then existing:Destroy() end
    end
    local function createESP(model, name, color, isNPC)
        if not model then return end
        local head = model:FindFirstChild("Head")
        if not head or not model:FindFirstChild("Humanoid") then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"; highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7; highlight.OutlineTransparency = 0.3; highlight.Parent = model
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Gui"; billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.AlwaysOnTop = true; billboard.Parent = head
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = isNPC and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0; textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextSize = 14; textLabel.Font = Enum.Font.SourceSansBold; textLabel.Text = name
        textLabel.Parent = billboard
    end
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player then
            if plr.Character then createESP(plr.Character, plr.Name, Color3.fromRGB(0, 255, 255), false) end
            plr.CharacterAdded:Connect(function(char) if espEnabled then task.wait(0.5); createESP(char, plr.Name, Color3.fromRGB(0, 255, 255), false) end end)
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
            if obj.Humanoid.Health > 0 then createESP(obj, "[NPC] " .. obj.Name, Color3.fromRGB(255, 255, 0), true) end
        end
    end
    notify("👁️ ESP", "Ativado!", 2)
end

local function disableESP()
    espEnabled = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") and obj.Name == "ESP_Gui" then obj:Destroy() end
        if obj:IsA("Highlight") and obj.Name == "ESP_Highlight" then obj:Destroy() end
    end
    notify("👁️ ESP", "Desativado!", 2)
end

-- ============================================
-- ABAS DA UI
-- ============================================

-- PRINCIPAL
MainTab:CreateSlider({ Name = "Velocidade de Andar", Range = {16, 200}, Increment = 1, Suffix = "studs/s", CurrentValue = defaultWalkSpeed, Callback = function(v) local h = getHumanoid() if h then h.WalkSpeed = v end end })
MainTab:CreateSlider({ Name = "Poder de Pulo", Range = {50, 300}, Increment = 1, Suffix = "power", CurrentValue = defaultJumpPower, Callback = function(v) local h = getHumanoid() if h then h.JumpPower = v; h.UseJumpPower = true end end })

-- VOO
FlyTab:CreateToggle({ Name = "Ativar Voo", CurrentValue = false, Callback = function(v) if v then startFly() else if flying then stopFly() end end end })
FlyTab:CreateSlider({ Name = "Velocidade do Voo", Range = {20, 200}, Increment = 5, Suffix = "studs/s", CurrentValue = 50, Callback = function(v) flySpeed = v end })

-- MOVIMENTO
MovementTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) if v then enableNoclip() else disableNoclip() end end })
MovementTab:CreateToggle({ Name = "Air Walk", CurrentValue = false, Callback = function(v) if v then enableAirWalk() else disableAirWalk() end end })
MovementTab:CreateToggle({ Name = "Air Swim", CurrentValue = false, Callback = function(v) if v then enableAirSwim() else disableAirSwim() end end })
MovementTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Callback = function(v) if v then enableInfiniteJump() else disableInfiniteJump() end end })

-- CÂMERA
CameraTab:CreateToggle({ Name = "Camera Noclip", CurrentValue = false, Callback = function(v) if v then enableCameraNoclip() else disableCameraNoclip() end end })
CameraTab:CreateToggle({ Name = "Zoom Infinito", CurrentValue = false, Callback = function(v) if v then enableInfiniteCamera() else disableInfiniteCamera() end end })

-- MUNDO
WorldTab:CreateToggle({ Name = "Fullbright", CurrentValue = false, Callback = function(v) if v then enableFullbright() else disableFullbright() end end })
WorldTab:CreateToggle({ Name = "NoFog", CurrentValue = false, Callback = function(v) if v then enableNoFog() else disableNoFog() end end })

-- TROLL
TrollTab:CreateToggle({ Name = "Fling TURBINADO", CurrentValue = false, Callback = function(v) if v then enableFling() else disableFling() end end })
TrollTab:CreateSection("🎭 Morph")
for _, tp in pairs(game.Players:GetPlayers()) do
    if tp ~= player then TrollTab:CreateButton({ Name = "Morph: " .. tp.Name, Callback = function() morphPlayer(tp) end }) end
end
game.Players.PlayerAdded:Connect(function(np)
    if np ~= player then TrollTab:CreateButton({ Name = "Morph: " .. np.Name, Callback = function() morphPlayer(np) end }) end
end)

-- ESP
ESPTab:CreateToggle({ Name = "ESP", CurrentValue = false, Callback = function(v) if v then enableESP() else disableESP() end end })

-- VISUAL
VisualTab:CreateToggle({ Name = "Invisível (NINGUÉM te vê)", CurrentValue = false, Callback = function(v) if v then enableInvisible() else disableInvisible() end end })
VisualTab:CreateToggle({ Name = "Highlight Jogadores", CurrentValue = false, Callback = function(v)
    highlightEnabled = v
    if v then
        local function ah(c) if c and not c:FindFirstChild("PlayerHighlight") then local h = Instance.new("Highlight"); h.Name = "PlayerHighlight"; h.FillColor = Color3.fromRGB(0,255,255); h.OutlineColor = Color3.fromRGB(255,255,255); h.FillTransparency = 0.5; h.Parent = c end end
        for _, plr in pairs(game.Players:GetPlayers()) do if plr ~= player and plr.Character then ah(plr.Character) end end
    else
        for _, plr in pairs(game.Players:GetPlayers()) do if plr.Character then local h = plr.Character:FindFirstChild("PlayerHighlight") if h then h:Destroy() end end end
    end
end })

-- CONFIGURAÇÕES
ConfigTab:CreateSection("🖼️ Background da UI")

-- Input para link da imagem
ConfigTab:CreateInput({
    Name = "Link da Imagem de Fundo",
    PlaceholderText = "Cole o link ou ID da imagem...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        if text and text ~= "" then
            changeBackground(text)
        end
    end,
})

ConfigTab:CreateParagraph({
    Title = "📋 Como usar:",
    Content = "1. Cole um link de imagem (URL)\n2. Ou cole um ID numérico do Roblox\n3. Aperte Enter para aplicar\n\nExemplos:\n• https://exemplo.com/imagem.png\n• 1234567890 (ID do Roblox)\n\nPara remover, deixe vazio e aperte Enter"
})

ConfigTab:CreateButton({
    Name = "🗑️ Remover Fundo",
    Callback = function()
        removeBackground()
    end,
})

ConfigTab:CreateSection("⚙️ Sistema")

ConfigTab:CreateButton({
    Name = "🗑️ Destruir Hub",
    Callback = function() destroyHub() end,
})

ConfigTab:CreateParagraph({
    Title = "⚠️ Aviso:",
    Content = "Ao destruir o hub, todas as funções serão desativadas e o fundo removido."
})

notify("🔥 Nameless Admin", "Carregado! Criado por CriadorYan", 3)

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    if flying then stopFly() end
    if flingEnabled then disableFling() end
    if espEnabled then disableESP() end
    if cameraNoclipEnabled then disableCameraNoclip() end
    if infiniteCameraEnabled then disableInfiniteCamera() end
end)
