--[[
    Death Ball Auto Farm Script
    Funcionalidades: Auto Farm, Auto Deflect, Auto Skill
    Criado por: CriadorYan
]]

-- Carregar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar a janela principal
local Window = Rayfield:CreateWindow({
    Name = "⚽ Death Ball Farm",
    LoadingTitle = "Death Ball Auto Farm",
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
local MainTab = Window:CreateTab("⚽ Principal", 4483362458)
local SkillsTab = Window:CreateTab("🎯 Skills", 4483362458)

-- Variáveis
local player = game.Players.LocalPlayer
local autoFarmEnabled = false
local autoDeflectEnabled = false
local autoSkillEnabled = false
local farmConnection
local deflectConnection
local skillConnection

-- Notificação
local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 2,
        Image = 4483362458,
    })
end

-- Função para encontrar a bola
local function findBall()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("ball") or obj.Name:lower():find("bola") then
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                return obj
            end
        end
    end
    
    -- Procurar por partes vermelhas grandes (a bola geralmente é vermelha)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.BrickColor == BrickColor.new("Bright red") then
            if obj.Size.Magnitude > 5 then
                return obj
            end
        end
    end
    
    return nil
end

-- Função para encontrar área de jogo/pronto
local function findGameArea()
    -- Procurar por spawn points ou áreas de jogo
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("spawn") or obj.Name:lower():find("arena") or obj.Name:lower():find("field") then
            if obj:IsA("BasePart") then
                return obj
            end
        end
    end
    
    -- Se não encontrar, usar o centro do mapa
    local mapCenter = Vector3.new(0, 10, 0)
    
    -- Tentar encontrar o centro da arena
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            return obj
        end
    end
    
    return nil
end

-- Função para encontrar skills disponíveis
local function findSkills()
    local skills = {}
    
    -- Procurar por botões de skill na tela
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                if gui.Name:lower():find("skill") or gui.Name:lower():find("ability") or gui.Name:lower():find("dash") then
                    table.insert(skills, gui)
                end
            end
        end
    end
    
    return skills
end

-- Auto Farm - Andar automaticamente para área de jogo
local function startAutoFarm()
    autoFarmEnabled = true
    
    local targetPosition = nil
    
    -- Encontrar posição alvo
    local gameArea = findGameArea()
    if gameArea then
        targetPosition = gameArea.Position
    else
        -- Posição padrão no centro do mapa
        targetPosition = Vector3.new(0, 10, 0)
    end
    
    farmConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not autoFarmEnabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not root then return end
        
        -- Verificar se está na área de jogo
        if targetPosition then
            local distance = (root.Position - targetPosition).Magnitude
            
            -- Se estiver longe, mover para a área
            if distance > 10 then
                humanoid:MoveTo(targetPosition)
            else
                -- Ficar na área pronto para jogar
                humanoid:Move(Vector3.new(0, 0, 0)) -- Parar
            end
        end
    end)
    
    notify("🚶 Auto Farm", "Indo automaticamente para área de jogo!", 3)
end

local function stopAutoFarm()
    autoFarmEnabled = false
    
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    
    notify("🚶 Auto Farm", "Auto Farm desativado!", 2)
end

-- Auto Deflect - Refletir a bola automaticamente
local function startAutoDeflect()
    autoDeflectEnabled = true
    
    deflectConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not autoDeflectEnabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not root then return end
        
        -- Encontrar a bola
        local ball = findBall()
        
        if ball then
            local ballPosition = ball.Position
            local playerPosition = root.Position
            local distance = (ballPosition - playerPosition).Magnitude
            
            -- Se a bola estiver perto (menos de 20 studs)
            if distance < 20 then
                -- Calcular direção da bola
                local direction = (ballPosition - playerPosition).Unit
                
                -- Posicionar-se para refletir a bola
                -- Virar o personagem na direção da bola
                root.CFrame = CFrame.new(playerPosition, playerPosition + direction)
                
                -- Se a bola estiver MUITO perto, tentar refletir
                if distance < 8 then
                    -- Simular clique para refletir (pressionar botão de defesa)
                    local playerGui = player:FindFirstChild("PlayerGui")
                    if playerGui then
                        -- Procurar botão de defesa/reflexo
                        for _, gui in pairs(playerGui:GetDescendants()) do
                            if gui:IsA("TextButton") and (gui.Name:lower():find("deflect") or gui.Name:lower():find("block") or gui.Name:lower():find("parry") or gui.Text:lower():find("deflect")) then
                                -- Simular clique
                                firesignal(gui.MouseButton1Click)
                                firesignal(gui.Activated)
                            end
                        end
                    end
                    
                    -- Também tentar pular para refletir
                    humanoid.Jump = true
                end
                
                -- Mover em direção à bola para interceptar
                humanoid:MoveTo(ballPosition)
            else
                -- Bola longe, ir para o centro da arena
                local gameArea = findGameArea()
                if gameArea then
                    humanoid:MoveTo(gameArea.Position)
                end
            end
        end
    end)
    
    notify("🛡️ Auto Deflect", "Refletindo bola automaticamente!", 3)
end

local function stopAutoDeflect()
    autoDeflectEnabled = false
    
    if deflectConnection then
        deflectConnection:Disconnect()
        deflectConnection = nil
    end
    
    notify("🛡️ Auto Deflect", "Auto Deflect desativado!", 2)
end

-- Auto Skill - Usar habilidades automaticamente
local function startAutoSkill()
    autoSkillEnabled = true
    
    skillConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not autoSkillEnabled then return end
        
        local skills = findSkills()
        
        for _, skill in pairs(skills) do
            if skill.Visible then
                -- Simular clique na skill
                pcall(function()
                    firesignal(skill.MouseButton1Click)
                    firesignal(skill.Activated)
                end)
            end
        end
        
        -- Também tentar ativar skills por teclado (teclas comuns)
        pcall(function()
            -- Tentar teclas comuns de skills (1, 2, 3, 4, E, Q, R, F)
            local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.R, Enum.KeyCode.F}
            for _, key in pairs(keys) do
                keypress(key)
                task.wait(0.05)
                keyrelease(key)
            end
        end)
    end)
    
    notify("🎯 Auto Skill", "Usando habilidades automaticamente!", 3)
end

local function stopAutoSkill()
    autoSkillEnabled = false
    
    if skillConnection then
        skillConnection:Disconnect()
        skillConnection = nil
    end
    
    notify("🎯 Auto Skill", "Auto Skill desativado!", 2)
end

-- Conectar eventos
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    
    -- Reativar funções se estavam ativas
    if autoFarmEnabled then
        stopAutoFarm()
        startAutoFarm()
    end
    if autoDeflectEnabled then
        stopAutoDeflect()
        startAutoDeflect()
    end
end)

-- ===== ABA PRINCIPAL =====

MainTab:CreateSection("⚽ Funções Principais")

MainTab:CreateToggle({
    Name = "Auto Farm (Ir para área de jogo)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        if Value then
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Deflect (Refletir bola)",
    CurrentValue = false,
    Flag = "AutoDeflect",
    Callback = function(Value)
        if Value then
            startAutoDeflect()
        else
            stopAutoDeflect()
        end
    end,
})

MainTab:CreateParagraph({
    Title = "Como funciona:",
    Content = "🚶 Auto Farm: Anda automaticamente para a área de jogo\n🛡️ Auto Deflect: Reflete a bola automaticamente quando se aproxima\n🎯 Auto Skill: Usa todas as skills disponíveis automaticamente"
})

MainTab:CreateParagraph({
    Title = "Dica:",
    Content = "Ative o Auto Farm primeiro para ir até a arena,\ndepois ative o Auto Deflect para jogar automaticamente!"
})

-- ===== ABA SKILLS =====

SkillsTab:CreateSection("🎯 Auto Skills")

SkillsTab:CreateToggle({
    Name = "Auto Skill (Usar habilidades)",
    CurrentValue = false,
    Flag = "AutoSkill",
    Callback = function(Value)
        if Value then
            startAutoSkill()
        else
            stopAutoSkill()
        end
    end,
})

SkillsTab:CreateParagraph({
    Title = "Skills suportadas:",
    Content = "✅ Dash\n✅ Habilidade especial\n✅ Defesa\n✅ Qualquer skill na tela"
})

SkillsTab:CreateParagraph({
    Title = "Teclas usadas:",
    Content = "1, 2, 3, 4, E, Q, R, F\nTodas as skills visíveis na tela"
})

-- Notificação inicial
notify("⚽ Death Ball Farm", "Script carregado! Ative as funções desejadas", 3)

-- Segurança
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    if autoFarmEnabled then stopAutoFarm() end
    if autoDeflectEnabled then stopAutoDeflect() end
    if autoSkillEnabled then stopAutoSkill() end
end)
