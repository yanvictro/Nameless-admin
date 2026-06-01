--[[
    Nameless Admin - Painel de Controle Mobile
    Usando Rayfield UI
    Funcionalidades: WalkSpeed, JumpPower, Fly, Highlight, Noclip, Air Walk, Air Swim, Fling, Morph, ESP, Infinite Jump, Invisible, Camera Noclip, Infinite Camera Zoom
    Criado por: CriadorYan
]]

-- Carregar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar a janela principal
local Window = Rayfield:CreateWindow({
    Name = "🔥 Nameless Admin",
    LoadingTitle = "Nameless Admin",
    LoadingSubtitle = "por CriadorYan",
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Criar abas
local MainTab = Window:CreateTab("🏠 Principal", 4483362458)
local FlyTab = Window:CreateTab("✈️ Voo", 4483362458)
local MovementTab = Window:CreateTab("🏃 Movimento", 4483362458)
local CameraTab = Window:CreateTab("📷 Câmera", 4483362458)
local TrollTab = Window:CreateTab("👻 Troll", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local VisualTab = Window:CreateTab("🎨 Visual", 4483362458)

-- Variáveis de estado
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local flying = false
local flightConnection
local flySpeed = 50
local currentNotification = nil
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
local cameraNoclipEnabled = false
local cameraNoclipConnection
local infiniteCameraEnabled = false
local infiniteCameraConnection
local originalCameraDistance = 10
local currentCameraDistance = 10
local maxCameraDistance = 1000

-- Valores padrão
local defaultWalkSpeed = 16
local defaultJumpPower = 50

-- Variáveis para controle de notificações
local lastWalkSpeedNotify = 0
local lastJumpPowerNotify = 0
local notifyCooldown = 1.5

-- Função de notificação otimizada
local function notify(title, content, duration)
    if currentNotification then
        currentNotification = nil
    end
    
    currentNotification = Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 2,
        Image = 4483362458,
    })
end

-- Função para obter o Humanoid
local function getHumanoid()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        return player.Character.Humanoid
    end
    return nil
end

-- Função Camera Noclip (NOVO)
local function enableCameraNoclip()
    cameraNoclipEnabled = true
    
    -- Configurar câmera para modo livre
    local camera = workspace.CurrentCamera
    
    -- Salvar configurações originais
    local originalMinZoom = player.CameraMinZoomDistance
    local originalMaxZoom = player.CameraMaxZoomDistance
    
    -- Permitir câmera atravessar paredes
    cameraNoclipConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if cameraNoclipEnabled then
            -- Forçar câmera a ignorar colisões
            camera.CameraType = Enum.CameraType.Custom
            
            -- Desabilitar limite de zoom
            player.CameraMinZoomDistance = 0.5
            player.CameraMaxZoomDistance = maxCameraDistance
            
            -- Remover transparência forçada de objetos
            local cameraPosition = camera.CFrame.Position
            local playerPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
            
            if playerPosition then
                -- Raycast para verificar obstáculos
                local ray = Ray.new(playerPosition, (cameraPosition - playerPosition).Unit * 1000)
                local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
                
                -- Se houver obstáculo, permitir que a câmera passe
                if hit then
                    -- Não bloquear a câmera
                    camera.CameraType = Enum.CameraType.Custom
                end
            end
        end
    end)
    
    notify("📷 Camera Noclip", "Câmera agora atravessa paredes!", 2)
end

local function disableCameraNoclip()
    cameraNoclipEnabled = false
    
    if cameraNoclipConnection then
        cameraNoclipConnection:Disconnect()
        cameraNoclipConnection = nil
    end
    
    -- Restaurar configurações da câmera
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 20
    
    notify("📷 Camera Noclip", "Câmera voltou ao normal!", 2)
end

-- Função Infinite Camera Zoom (NOVO)
local function enableInfiniteCamera()
    infiniteCameraEnabled = true
    
    -- Configurar zoom infinito
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = maxCameraDistance
    currentCameraDistance = originalCameraDistance
    
    -- Permitir zoom infinito com gestos de pinça ou scroll
    infiniteCameraConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if infiniteCameraEnabled then
            -- Manter o zoom máximo sempre liberado
            player.CameraMaxZoomDistance = maxCameraDistance
            
            -- Verificar input do jogador para zoom
            local camera = workspace.CurrentCamera
            
            -- Aumentar zoom (afastar) - Botão Volume + ou gesto de pinça
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.E) then
                currentCameraDistance = math.min(currentCameraDistance + 5, maxCameraDistance)
                player.CameraMaxZoomDistance = currentCameraDistance
            end
            
            -- Diminuir zoom (aproximar) - Botão Volume - ou gesto de pinça
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Q) then
                currentCameraDistance = math.max(currentCameraDistance - 5, 1)
                player.CameraMaxZoomDistance = currentCameraDistance
            end
        end
    end)
    
    notify("📷 Infinite Camera", "Zoom infinito ativado! Afaste a câmera o quanto quiser", 3)
end

local function disableInfiniteCamera()
    infiniteCameraEnabled = false
    
    if infiniteCameraConnection then
        infiniteCameraConnection:Disconnect()
        infiniteCameraConnection = nil
    end
    
    -- Restaurar zoom normal
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 20
    currentCameraDistance = originalCameraDistance
    
    notify("📷 Infinite Camera", "Zoom da câmera restaurado!", 2)
end

-- Função de voo com rotação do personagem junto com a câmera
local function startFly()
    local hum = getHumanoid()
    if not hum then
        notify("Erro", "Humanoid não encontrado!", 2)
        return false
    end
    
    flying = true
    
    -- Configurar controles do personagem
    hum.PlatformStand = false
    hum.AutoRotate = false
    
    -- Forçar ShiftLock automaticamente
    if player.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
        player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
    end
    
    local camera = workspace.CurrentCamera
    local rootPart = hum.Parent:WaitForChild("HumanoidRootPart")
    
    -- Corpo do voo
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = camera.CFrame
    bodyGyro.Parent = rootPart
    
    bodyVelocity.Parent = rootPart
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    
    -- Sistema de voo com rotação do personagem seguindo a câmera
    flightConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        if not flying or not hum.Parent or not rootPart then
            return
        end
        
        -- Atualizar rotação do personagem para seguir a câmera
        local cameraCFrame = camera.CFrame
        local cameraDirection = cameraCFrame.LookVector
        local horizontalDirection = Vector3.new(cameraDirection.X, 0, cameraDirection.Z).Unit
        
        if horizontalDirection.Magnitude > 0 then
            local newCFrame = CFrame.new(rootPart.Position, rootPart.Position + horizontalDirection)
            bodyGyro.CFrame = newCFrame
        else
            bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(cameraCFrame.LookVector.X, 0, cameraCFrame.LookVector.Z).Unit)
        end
        
        local moveVector = hum.MoveDirection
        
        if moveVector.Magnitude == 0 then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            return
        end
        
        local cameraForward = cameraCFrame.LookVector
        local cameraRight = cameraCFrame.RightVector
        local velocity = Vector3.new()
        
        if moveVector.Z > 0 then
            velocity = velocity + cameraForward * flySpeed
        elseif moveVector.Z < 0 then
            velocity = velocity - cameraForward * flySpeed
        end
        
        if moveVector.X > 0 then
            velocity = velocity + cameraRight * flySpeed
        elseif moveVector.X < 0 then
            velocity = velocity - cameraRight * flySpeed
        end
        
        bodyVelocity.Velocity = velocity
    end)
    
    notify("✈️ Voo Ativado", "ShiftLock automático! Personagem vira junto com a câmera", 4)
    return true
end

local function stopFly()
    flying = false
    
    if flightConnection then
        flightConnection:Disconnect()
        flightConnection = nil
    end
    
    local hum = getHumanoid()
    if hum then
        hum.AutoRotate = true
        hum.PlatformStand = false
        
        if hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart") then
            local root = hum.Parent.HumanoidRootPart
            if root:FindFirstChild("BodyGyro") then
                root.BodyGyro:Destroy()
            end
            if root:FindFirstChild("BodyVelocity") then
                root.BodyVelocity:Destroy()
            end
        end
    end
    
    if player.DevCameraOcclusionMode == Enum.DevCameraOcclusionMode.Invisicam then
        player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
    end
    
    notify("Voo Desativado", "Sistema de voo e ShiftLock desligados!", 2)
end

-- Função Noclip
local function enableNoclip()
    noclipEnabled = true
    
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if noclipEnabled and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    notify("🚫 Noclip", "Atravessar paredes ativado!", 2)
end

local function disableNoclip()
    noclipEnabled = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    notify("🚫 Noclip", "Noclip desativado!", 2)
end

-- Função Air Walk
local function enableAirWalk()
    airWalkEnabled = true
    
    local function createPlatform()
        if not airWalkEnabled or not player.Character then return end
        
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if hum and root and hum:GetState() == Enum.HumanoidStateType.Freefall then
            local bodyVelocity = root:FindFirstChild("AirWalkVelocity")
            if not bodyVelocity then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Name = "AirWalkVelocity"
                bodyVelocity.MaxForce = Vector3.new(0, 5000, 0)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = root
            end
            
            local moveDirection = hum.MoveDirection
            local horizontalVelocity = Vector3.new(
                moveDirection.X * hum.WalkSpeed,
                0,
                moveDirection.Z * hum.WalkSpeed
            )
            
            bodyVelocity.Velocity = Vector3.new(horizontalVelocity.X, 0, horizontalVelocity.Z)
        else
            if root then
                local bodyVelocity = root:FindFirstChild("AirWalkVelocity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end
        end
    end
    
    airWalkConnection = game:GetService("RunService").RenderStepped:Connect(createPlatform)
    
    notify("🚶 Air Walk", "Andar no ar ativado! Pule e fique flutuando", 2)
end

local function disableAirWalk()
    airWalkEnabled = false
    
    if airWalkConnection then
        airWalkConnection:Disconnect()
        airWalkConnection = nil
    end
    
    if player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local bodyVelocity = root:FindFirstChild("AirWalkVelocity")
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end
    end
    
    notify("🚶 Air Walk", "Andar no ar desativado!", 2)
end

-- Função Air Swim
local function enableAirSwim()
    airSwimEnabled = true
    
    local function createSwimEffect()
        if not airSwimEnabled or not player.Character then return end
        
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            local swimVelocity = root:FindFirstChild("SwimVelocity")
            if not swimVelocity then
                swimVelocity = Instance.new("BodyVelocity")
                swimVelocity.Name = "SwimVelocity"
                swimVelocity.MaxForce = Vector3.new(5000, 5000, 5000)
                swimVelocity.Velocity = Vector3.new(0, 0, 0)
                swimVelocity.Parent = root
            end
            
            local moveDirection = hum.MoveDirection
            local camera = workspace.CurrentCamera
            
            if moveDirection.Magnitude > 0 then
                local forward = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                local up = camera.CFrame.UpVector
                
                local velocity = Vector3.new()
                velocity = velocity + (forward * -moveDirection.Z * hum.WalkSpeed)
                velocity = velocity + (right * moveDirection.X * hum.WalkSpeed)
                
                if hum.Jump then
                    velocity = velocity + (up * hum.JumpPower * 0.5)
                end
                
                swimVelocity.Velocity = velocity
            else
                swimVelocity.Velocity = Vector3.new(0, 0.5, 0)
            end
            
            local bodyGyro = root:FindFirstChild("SwimGyro")
            if not bodyGyro then
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.Name = "SwimGyro"
                bodyGyro.P = 3000
                bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
                bodyGyro.CFrame = camera.CFrame
                bodyGyro.Parent = root
            end
            bodyGyro.CFrame = camera.CFrame
        end
    end
    
    airSwimConnection = game:GetService("RunService").RenderStepped:Connect(createSwimEffect)
    
    notify("🏊 Air Swim", "Nadar no ar ativado! Use o joystick e botão de pular", 3)
end

local function disableAirSwim()
    airSwimEnabled = false
    
    if airSwimConnection then
        airSwimConnection:Disconnect()
        airSwimConnection = nil
    end
    
    if player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local swimVelocity = root:FindFirstChild("SwimVelocity")
            if swimVelocity then
                swimVelocity:Destroy()
            end
            
            local bodyGyro = root:FindFirstChild("SwimGyro")
            if bodyGyro then
                bodyGyro:Destroy()
            end
        end
    end
    
    notify("🏊 Air Swim", "Nadar no ar desativado!", 2)
end

-- Função Infinite Jump
local function enableInfiniteJump()
    infiniteJumpEnabled = true
    
    infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
        if infiniteJumpEnabled then
            local hum = getHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    notify("🦘 Infinite Jump", "Pulo infinito ativado! Pule quantas vezes quiser", 2)
end

local function disableInfiniteJump()
    infiniteJumpEnabled = false
    
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
    
    notify("🦘 Infinite Jump", "Pulo infinito desativado!", 2)
end

-- Função Invisible
local function enableInvisible()
    invisibleEnabled = true
    
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 1
            end
            if part:IsA("Accessory") then
                part.Handle.Transparency = 1
            end
        end
    end
    
    player.CharacterAdded:Connect(function(char)
        if invisibleEnabled then
            task.wait(0.1)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                end
                if part:IsA("Accessory") then
                    part.Handle.Transparency = 1
                end
            end
        end
    end)
    
    notify("👻 Invisível", "Invisibilidade ativada! Ninguém pode te ver", 2)
end

local function disableInvisible()
    invisibleEnabled = false
    
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 0
            end
            if part:IsA("Accessory") then
                part.Handle.Transparency = 0
            end
        end
    end
    
    notify("👻 Invisível", "Invisibilidade desativada!", 2)
end

-- Função Fling
local function enableFling()
    flingEnabled = true
    
    local function flingPlayers()
        if not flingEnabled or not player.Character then return end
        
        local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                local otherHum = otherPlayer.Character:FindFirstChild("Humanoid")
                
                if otherRoot and otherHum then
                    local distance = (myRoot.Position - otherRoot.Position).Magnitude
                    
                    if distance < 30 then
                        local flingForce = Instance.new("BodyVelocity")
                        flingForce.MaxForce = Vector3.new(1, 1, 1) * math.huge
                        
                        local direction = (otherRoot.Position - myRoot.Position).Unit
                        flingForce.Velocity = direction * 10000 + Vector3.new(0, 10000, 0)
                        
                        flingForce.Parent = otherRoot
                        
                        game:GetService("Debris"):AddItem(flingForce, 0.1)
                        
                        local flingSpin = Instance.new("BodyAngularVelocity")
                        flingSpin.MaxTorque = Vector3.new(1, 1, 1) * math.huge
                        flingSpin.AngularVelocity = Vector3.new(
                            math.random(-50, 50),
                            math.random(-50, 50),
                            math.random(-50, 50)
                        )
                        flingSpin.Parent = otherRoot
                        
                        game:GetService("Debris"):AddItem(flingSpin, 0.1)
                    end
                end
            end
        end
    end
    
    flingConnection = game:GetService("RunService").Heartbeat:Connect(flingPlayers)
    
    notify("💨 Fling", "Fling ativado! Aproxime-se dos jogadores para arremessá-los", 3)
end

local function disableFling()
    flingEnabled = false
    
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    
    notify("💨 Fling", "Fling desativado!", 2)
end

-- Função Morph
local function morphPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        notify("Erro", "Jogador não encontrado!", 2)
        return
    end
    
    local function cloneCharacter()
        local myChar = player.Character
        local targetChar = targetPlayer.Character
        
        if not myChar or not targetChar then return end
        
        for _, item in pairs(myChar:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                item:Destroy()
            end
        end
        
        for _, item in pairs(targetChar:GetChildren()) do
            if item:IsA("Shirt") then
                local newShirt = item:Clone()
                newShirt.Parent = myChar
            elseif item:IsA("Pants") then
                local newPants = item:Clone()
                newPants.Parent = myChar
            elseif item:IsA("ShirtGraphic") then
                local newShirtGraphic = item:Clone()
                newShirtGraphic.Parent = myChar
            elseif item:IsA("Accessory") then
                local newAccessory = item:Clone()
                newAccessory.Parent = myChar
            end
        end
        
        for _, partName in pairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
            local myPart = myChar:FindFirstChild(partName)
            local targetPart = targetChar:FindFirstChild(partName)
            
            if myPart and targetPart and myPart:IsA("BasePart") and targetPart:IsA("BasePart") then
                myPart.BrickColor = targetPart.BrickColor
                myPart.Color = targetPart.Color
                myPart.Size = targetPart.Size
                myPart.Transparency = targetPart.Transparency
                myPart.Material = targetPart.Material
            end
        end
    end
    
    pcall(cloneCharacter)
    notify("🎭 Morph", "Transformado em: " .. targetPlayer.Name, 3)
end

-- Função ESP
local function enableESP()
    espEnabled = true
    
    for _, existing in pairs(workspace:GetDescendants()) do
        if existing:IsA("BillboardGui") and existing.Name == "ESP_Gui" then
            existing:Destroy()
        end
        if existing:IsA("Highlight") and existing.Name == "ESP_Highlight" then
            existing:Destroy()
        end
    end
    
    local function createESP(model, name, color, isNPC)
        if not model then return end
        
        local head = model:FindFirstChild("Head")
        local humanoid = model:FindFirstChild("Humanoid")
        
        if not head or not humanoid then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
        highlight.Parent = model
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Gui"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Text = name
        
        if isNPC then
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
        
        textLabel.Parent = billboard
        
        table.insert(espConnections, {
            model = model,
            highlight = highlight,
            billboard = billboard
        })
    end
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player then
            if plr.Character then
                createESP(plr.Character, plr.Name, Color3.fromRGB(0, 255, 255), false)
            end
            
            plr.CharacterAdded:Connect(function(char)
                if espEnabled then
                    task.wait(0.5)
                    createESP(char, plr.Name, Color3.fromRGB(0, 255, 255), false)
                end
            end)
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local npcName = obj.Name
                createESP(obj, "[NPC] " .. npcName, Color3.fromRGB(255, 255, 0), true)
            end
        end
    end
    
    local npcMonitor = workspace.DescendantAdded:Connect(function(descendant)
        if espEnabled and descendant:IsA("Model") then
            task.wait(0.5)
            if descendant:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(descendant) then
                local humanoid = descendant:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local npcName = descendant.Name
                    createESP(descendant, "[NPC] " .. npcName, Color3.fromRGB(255, 255, 0), true)
                end
            end
        end
    end)
    
    table.insert(espConnections, npcMonitor)
    
    local playerMonitor = game.Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function(char)
            if espEnabled then
                task.wait(0.5)
                createESP(char, newPlayer.Name, Color3.fromRGB(0, 255, 255), false)
            end
        end)
    end)
    
    table.insert(espConnections, playerMonitor)
    
    notify("👁️ ESP", "ESP ativado! Jogadores (Ciano) e NPCs (Amarelo)", 3)
end

local function disableESP()
    espEnabled = false
    
    for _, connection in pairs(espConnections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        elseif type(connection) == "table" then
            if connection.highlight then
                connection.highlight:Destroy()
            end
            if connection.billboard then
                connection.billboard:Destroy()
            end
        end
    end
    
    espConnections = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") and obj.Name == "ESP_Gui" then
            obj:Destroy()
        end
        if obj:IsA("Highlight") and obj.Name == "ESP_Highlight" then
            obj:Destroy()
        end
    end
    
    notify("👁️ ESP", "ESP desativado!", 2)
end

-- Conectar eventos do personagem
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    
    if flying then
        stopFly()
    end
    
    if noclipEnabled then
        task.wait(0.1)
        enableNoclip()
    end
    
    if invisibleEnabled then
        task.wait(0.1)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 1
            end
            if part:IsA("Accessory") then
                part.Handle.Transparency = 1
            end
        end
    end
end)

-- ===== ABA PRINCIPAL =====

MainTab:CreateSlider({
    Name = "Velocidade de Andar",
    Range = {16, 200},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = defaultWalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = Value
            
            local currentTime = tick()
            if currentTime - lastWalkSpeedNotify > notifyCooldown then
                notify("🏃 Velocidade", Value .. " studs/s", 1.5)
                lastWalkSpeedNotify = currentTime
            end
        end
    end,
})

MainTab:CreateSlider({
    Name = "Poder de Pulo",
    Range = {50, 300},
    Increment = 1,
    Suffix = "power",
    CurrentValue = defaultJumpPower,
    Flag = "JumpPower",
    Callback = function(Value)
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = Value
            hum.UseJumpPower = true
            
            local currentTime = tick()
            if currentTime - lastJumpPowerNotify > notifyCooldown then
                notify("🦘 Pulo", "Power: " .. Value, 1.5)
                lastJumpPowerNotify = currentTime
            end
        end
    end,
})

MainTab:CreateSection("📋 Informações")

MainTab:CreateParagraph({
    Title = "Nameless Admin",
    Content = "Painel de controle criado por CriadorYan\nMúltiplas funcionalidades para mobile"
})

-- ===== ABA DE VOO =====

FlyTab:CreateToggle({
    Name = "Ativar Sistema de Voo",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        if Value then
            startFly()
        else
            if flying then
                stopFly()
            end
        end
    end,
})

FlyTab:CreateSlider({
    Name = "Velocidade do Voo",
    Range = {20, 200},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flySpeed = Value
        notify("✈️ Velocidade", Value .. " studs/s", 1.5)
    end,
})

FlyTab:CreateSection("📱 Controles de Voo")

FlyTab:CreateParagraph({
    Title = "Como Voar:",
    Content = "🎮 Joystick para frente = Voar para frente\n⬆️ Olhar para cima + frente = Subir\n⬇️ Olhar para baixo + frente = Descer\n⬅️➡️ Joystick lados = Voar lateralmente"
})

-- ===== ABA DE MOVIMENTO =====

MovementTab:CreateToggle({
    Name = "Noclip (Atravessar Paredes)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        if Value then
            enableNoclip()
        else
            disableNoclip()
        end
    end,
})

MovementTab:CreateToggle({
    Name = "Andar no Ar (Air Walk)",
    CurrentValue = false,
    Flag = "AirWalk",
    Callback = function(Value)
        if Value then
            enableAirWalk()
        else
            disableAirWalk()
        end
    end,
})

MovementTab:CreateToggle({
    Name = "Nadar no Ar (Air Swim)",
    CurrentValue = false,
    Flag = "AirSwim",
    Callback = function(Value)
        if Value then
            enableAirSwim()
        else
            disableAirSwim()
        end
    end,
})

MovementTab:CreateToggle({
    Name = "Pulo Infinito (Infinite Jump)",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        if Value then
            enableInfiniteJump()
        else
            disableInfiniteJump()
        end
    end,
})

-- ===== ABA DE CÂMERA (NOVO) =====

CameraTab:CreateToggle({
    Name = "Câmera Noclip (Atravessar Paredes)",
    CurrentValue = false,
    Flag = "CameraNoclip",
    Callback = function(Value)
        if Value then
            enableCameraNoclip()
        else
            disableCameraNoclip()
        end
    end,
})

CameraTab:CreateToggle({
    Name = "Zoom Infinito (Infinite Camera)",
    CurrentValue = false,
