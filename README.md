--[[
    Nameless Admin - Painel de Controle Mobile
    Usando Rayfield UI
    Funcionalidades: WalkSpeed, JumpPower, Fly, Highlight, Noclip, Air Walk, Air Swim, Fling, Morph, ESP
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

-- Função Air Walk (CORRIGIDO)
local function enableAirWalk()
    airWalkEnabled = true
    
    local function createPlatform()
        if not airWalkEnabled or not player.Character then return end
        
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if hum and root and hum:GetState() == Enum.HumanoidStateType.Freefall then
            -- Criar uma força para manter o jogador no ar
            local bodyVelocity = root:FindFirstChild("AirWalkVelocity")
            if not bodyVelocity then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Name = "AirWalkVelocity"
                bodyVelocity.MaxForce = Vector3.new(0, 5000, 0)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = root
            end
            
            -- Permitir movimento horizontal
            local moveDirection = hum.MoveDirection
            local horizontalVelocity = Vector3.new(
                moveDirection.X * hum.WalkSpeed,
                0,
                moveDirection.Z * hum.WalkSpeed
            )
            
            bodyVelocity.Velocity = Vector3.new(horizontalVelocity.X, 0, horizontalVelocity.Z)
        else
            -- Remover quando não estiver caindo
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
    
    -- Limpar
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

-- Função Air Swim (CORRIGIDO)
local function enableAirSwim()
    airSwimEnabled = true
    
    local function createSwimEffect()
        if not airSwimEnabled or not player.Character then return end
        
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            -- Simular natação no ar
            local swimVelocity = root:FindFirstChild("SwimVelocity")
            if not swimVelocity then
                swimVelocity = Instance.new("BodyVelocity")
                swimVelocity.Name = "SwimVelocity"
                swimVelocity.MaxForce = Vector3.new(5000, 5000, 5000)
                swimVelocity.Velocity = Vector3.new(0, 0, 0)
                swimVelocity.Parent = root
            end
            
            -- Movimento de natação
            local moveDirection = hum.MoveDirection
            local camera = workspace.CurrentCamera
            
            if moveDirection.Magnitude > 0 then
                local forward = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                local up = camera.CFrame.UpVector
                
                local velocity = Vector3.new()
                
                -- Movimento horizontal
                velocity = velocity + (forward * -moveDirection.Z * hum.WalkSpeed)
                velocity = velocity + (right * moveDirection.X * hum.WalkSpeed)
                
                -- Movimento vertical com o salto
                if hum.Jump then
                    velocity = velocity + (up * hum.JumpPower * 0.5)
                end
                
                swimVelocity.Velocity = velocity
            else
                -- Flutuar suavemente
                swimVelocity.Velocity = Vector3.new(0, 0.5, 0)
            end
            
            -- Efeito de rotação suave
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
    
    -- Limpar
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

-- Função Fling (CORRIGIDO E MELHORADO)
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
                    
                    -- Aumentado alcance para 30 studs
                    if distance < 30 then
                        -- Criar força explosiva
                        local flingForce = Instance.new("BodyVelocity")
                        flingForce.MaxForce = Vector3.new(1, 1, 1) * math.huge
                        
                        -- Direção aleatória mas com força extrema
                        local direction = (otherRoot.Position - myRoot.Position).Unit
                        flingForce.Velocity = direction * 10000 + Vector3.new(0, 10000, 0)
                        
                        flingForce.Parent = otherRoot
                        
                        -- Destruir após aplicar força
                        game:GetService("Debris"):AddItem(flingForce, 0.1)
                        
                        -- Também aplicar força rotacional para efeito mais caótico
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
        
        -- Remover roupas atuais
        for _, item in pairs(myChar:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                item:Destroy()
            end
        end
        
        -- Copiar roupas do alvo
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
        
        -- Copiar cores do corpo e escalas
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

-- Função ESP para NPCs e Jogadores
local function enableESP()
    espEnabled = true
    
    -- Limpar ESPs existentes
    for _, existing in pairs(workspace:GetDescendants()) do
        if existing:IsA("BillboardGui") and existing.Name == "ESP_Gui" then
            existing:Destroy()
        end
        if existing:IsA("Highlight") and existing.Name == "ESP_Highlight" then
            existing:Destroy()
        end
    end
    
    -- Função para criar ESP em um modelo
    local function createESP(model, name, color, isNPC)
        if not model then return end
        
        local head = model:FindFirstChild("Head")
        local humanoid = model:FindFirstChild("Humanoid")
        
        if not head or not humanoid then return end
        
        -- Criar Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
        highlight.Parent = model
        
        -- Criar BillboardGui para nome
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
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Amarelo para NPCs
        end
        
        textLabel.Parent = billboard
        
        -- Armazenar conexão
        table.insert(espConnections, {
            model = model,
            highlight = highlight,
            billboard = billboard
        })
    end
    
    -- Adicionar ESP para jogadores
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
    
    -- Adicionar ESP para NPCs
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local npcName = obj.Name
                createESP(obj, "[NPC] " .. npcName, Color3.fromRGB(255, 255, 0), true)
            end
        end
    end
    
    -- Monitorar novos NPCs
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
    
    -- Monitorar novos jogadores
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
    
    -- Limpar todas as conexões
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
    
    -- Limpar todos os ESPs visuais
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

-- ===== ABA DE TROLL =====

TrollTab:CreateToggle({
    Name = "Fling (Arremessar Jogadores)",
    CurrentValue = false,
    Flag = "Fling",
    Callback = function(Value)
        if Value then
            enableFling()
        else
            disableFling()
        end
    end,
})

TrollTab:CreateSection("🎭 Morph")

local function updateMorphButtons()
    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer ~= player then
            TrollTab:CreateButton({
                Name = "Morph: " .. targetPlayer.Name,
                Callback = function()
                    morphPlayer(targetPlayer)
                end,
            })
        end
    end
end

updateMorphButtons()

game.Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= player then
        TrollTab:CreateButton({
            Name = "Morph: " .. newPlayer.Name,
            Callback = function()
                morphPlayer(newPlayer)
            end,
        })
    end
end)

-- ===== ABA DE ESP =====

ESPTab:CreateToggle({
    Name = "ESP (Ver através das paredes)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        if Value then
            enableESP()
        else
            disableESP()
        end
    end,
})

ESPTab:CreateSection("📋 Informações ESP")

ESPTab:CreateParagraph({
    Title = "Cores do ESP:",
    Content = "🔵 Jogadores - Ciano com nome acima\n🟡 NPCs - Amarelo permanente com [NPC] acima\n✅ Todos visíveis através das paredes"
})

-- ===== ABA VISUAL =====

VisualTab:CreateToggle({
    Name = "Highlight de Jogadores",
    CurrentValue = false,
    Flag = "Highlight",
    Callback = function(Value)
        highlightEnabled = Value
        
        if Value then
            notify("👁️ Highlight", "Jogadores destacados!", 2)
            
            local function addHighlight(character)
                if character and not character:FindFirstChild("PlayerHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = character
                    highlight.FillColor = Color3.fromRGB(0, 255, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Name = "PlayerHighlight"
                end
            end
            
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    addHighlight(plr.Character)
                end
            end
            
            game.Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    if highlightEnabled then
                        addHighlight(char)
                    end
                end)
            end)
        else
            notify("👁️ Highlight", "Destaques removidos!", 2)
            
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr.Character then
                    local highlight = plr.Character:FindFirstChild("PlayerHighlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end,
})

VisualTab:CreateSection("ℹ️ Nameless Admin")

VisualTab:CreateParagraph({
    Title = "Criado por CriadorYan",
    Content = "Hub otimizado para mobile\nMúltiplas funcionalidades\nAtualizado e melhorado"
})

-- Notificação inicial
notify("🔥 Nameless Admin", "Carregado com sucesso! Criado por CriadorYan", 3)

-- Segurança
game:GetService("RunService").Heartbeat:Connect(function()
    if flying then
        local hum = getHumanoid()
        if not hum or not hum.Parent or not hum.Parent:FindFirstChild("HumanoidRootPart") then
            stopFly()
        end
    end
end)

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    if flying then stopFly() end
    if flingEnabled then disableFling() end
    if espEnabled then disableESP() end
end)
