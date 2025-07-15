local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
local loadrnd = math.random(1, 5)
local loadname = nil

if loadrnd == 1 then
    loadname = "обемен напал на казахстан"
elseif loadrnd == 2 then
    loadname = "создатель красноярска не делает античит"
elseif loadrnd == 3 then
    loadname = "ыыы мошонки"
elseif loadrnd == 4 then
    loadname = "случайный текст"
else 
    loadname = "создатель тепал всех в казик сливать бабки"
end

local Window = Luna:CreateWindow({
    Name = "MashonkaScript",
    Subtitle = nil,
    LogoID = "84568162734817",
    LoadingEnabled = true,
    LoadingTitle = "MashonkaScript",
    LoadingSubtitle = loadname,
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "Big Hub"
    },
})

local VisualTab = Window:CreateTab({
    Name = "Visual",
    Icon = "view_in_ar",
    ImageSource = "Material",
    ShowTitle = true
})

local MovementTab = Window:CreateTab({
    Name = "Movement",
    Icon = "directions_run",
    ImageSource = "Material",
    ShowTitle = true
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Переменные для 3D Boxes
local is3DBoxesEnabled = false
local box3DColor = Color3.fromRGB(255, 0, 0)
local box3DParts = {}

-- Переменные для Highlights
local isHighlightsEnabled = false
local highlightColor = Color3.fromRGB(0, 255, 255)

-- Переменные для Name and HP
local isNameHPDisplayEnabled = false
local nameHPColor = Color3.fromRGB(255, 255, 255)

-- Переменные для Console Clear
local isConsoleClearEnabled = false
local consoleClearConnection = nil

-- Переменные для Movement
local isAutoSprintEnabled = false
local autoSprintConnection = nil
local isFlyEnabled = false
local flyConnection = nil
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50

-- Функция для очистки консоли
local function clearConsole()
    local success, err = pcall(function()
        for _ = 1, 50 do
            print("")
        end
    end)
    if not success then
        warn("Ошибка при очистке консоли: " .. tostring(err))
    end
end

-- Функция для включения очистки консоли
local function enableConsoleClear()
    local success, err = pcall(function()
        print("Enabling Console Clear...")
        if not consoleClearConnection then
            consoleClearConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if isConsoleClearEnabled then
                    staticConsoleClearTime = (staticConsoleClearTime or 0) + deltaTime
                    if staticConsoleClearTime >= 1 then
                        clearConsole()
                        staticConsoleClearTime = 0
                    end
                end
            end)
        end
    end)
    if not success then
        warn("Ошибка при включении очистки консоли: " .. tostring(err))
    end
end

-- Функция для выключения очистки консоли
local function disableConsoleClear()
    local success, err = pcall(function()
        print("Disabling Console Clear...")
        if consoleClearConnection then
            consoleClearConnection:Disconnect()
            consoleClearConnection = nil
        end
    end)
    if not success then
        warn("Ошибка при выключении очистки консоли: " .. tostring(err))
    end
end

-- Функция для создания 3D-коробки (Part)
local function create3DBox(character)
    if character and character ~= LocalPlayer.Character and character:FindFirstChildOfClass("Humanoid") then
        local success, err = pcall(function()
            local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            if not rootPart then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local size = Vector3.new(4, 5, 2)
            if humanoid then
                local hipHeight = humanoid.HipHeight
                size = Vector3.new(4, hipHeight + 3, 2)
            end

            local box = Instance.new("Part")
            box.Name = "Player3DBox"
            box.Size = size
            box.Position = rootPart.Position
            box.CFrame = rootPart.CFrame
            box.Anchored = true
            box.CanCollide = false
            box.Transparency = 0.5
            box.Color = box3DColor
            box.Material = Enum.Material.Neon
            box.Parent = character

            box3DParts[character] = box
            print("3D Box created for " .. (character.Parent and character.Parent.Name or "Unknown"))
        end)
        if not success then
            warn("Ошибка при создании 3D-коробки: " .. tostring(err))
        end
    else
        print("Invalid character or no Humanoid for " .. (character and character.Parent and character.Parent.Name or "nil"))
    end
end

-- Функция для удаления 3D-коробки
local function remove3DBox(character)
    if character then
        local success, err = pcall(function()
            local box = box3DParts[character]
            if box then
                box:Destroy()
                box3DParts[character] = nil
                print("3D Box removed for " .. (character.Parent and character.Parent.Name or "Unknown"))
            end
        end)
        if not success then
            warn("Ошибка при удалении 3D-коробки: " .. tostring(err))
        end
    end
end

-- Функция для обновления цвета 3D-коробок
local function update3DBoxColor()
    local success, err = pcall(function()
        for character, box in pairs(box3DParts) do
            if box then
                box.Color = box3DColor
                print("3D Box color updated for " .. (character.Parent and character.Parent.Name or "Unknown"))
            end
        end
    end)
    if not success then
        warn("Ошибка при обновлении цвета 3D-коробок: " .. tostring(err))
    end
end

-- Функция для создания Highlight
local function createHighlight(character)
    if character and character ~= LocalPlayer.Character and character:FindFirstChildOfClass("Humanoid") then
        local success, err = pcall(function()
            if not character:FindFirstChild("PlayerHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerHighlight"
                highlight.Adornee = character
                highlight.FillColor = highlightColor
                highlight.OutlineColor = highlightColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character
                print("Highlight created for " .. (character.Parent and character.Parent.Name or "Unknown"))
            else
                print("Highlight already exists for " .. (character.Parent and character.Parent.Name or "Unknown"))
            end
        end)
        if not success then
            warn("Ошибка при создании Highlight: " .. tostring(err))
        end
    else
        print("Invalid character or no Humanoid for " .. (character and character.Parent and character.Parent.Name or "nil"))
    end
end

-- Функция для удаления Highlight
local function removeHighlight(character)
    if character then
        local success, err = pcall(function()
            local highlight = character:FindFirstChild("PlayerHighlight")
            if highlight then
                highlight:Destroy()
                print("Highlight removed for " .. (character.Parent and character.Parent.Name or "Unknown"))
            end
        end)
        if not success then
            warn("Ошибка при удалении Highlight: " .. tostring(err))
        end
    end
end

-- Функция для обновления цвета Highlight
local function updateHighlightColor()
    local success, err = pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("PlayerHighlight")
                if highlight then
                    highlight.FillColor = highlightColor
                    highlight.OutlineColor = highlightColor
                    print("Highlight color updated for " .. player.Name)
                end
            end
        end
    end)
    if not success then
        warn("Ошибка при обновлении цвета Highlight: " .. tostring(err))
    end
end

-- Функция для создания Name and HP Display
local function createNameHPDisplay(character)
    if character and character ~= LocalPlayer.Character and character:FindFirstChildOfClass("Humanoid") then
        local success, err = pcall(function()
            local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            if not rootPart then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local player = Players:GetPlayerFromCharacter(character)
            if not player or not humanoid then return end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NameHPDisplay"
            billboard.Adornee = rootPart
            billboard.Size = UDim2.new(0, 100, 0, 25)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.LightInfluence = 0
            billboard.Parent = character

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = billboard

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = nameHPColor
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.Parent = frame

            local hpLabel = Instance.new("TextLabel")
            hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
            hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
            hpLabel.BackgroundTransparency = 1
            hpLabel.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
            hpLabel.TextColor3 = nameHPColor
            hpLabel.TextScaled = true
            hpLabel.Font = Enum.Font.Code
            hpLabel.Parent = frame

            print("Name and HP Display created for " .. (character.Parent and character.Parent.Name or "Unknown"))
        end)
        if not success then
            warn("Ошибка при создании Name and HP Display: " .. tostring(err))
        end
    else
        print("Invalid character or no Humanoid for " .. (character and character.Parent and character.Parent.Name or "nil"))
    end
end

-- Функция для удаления Name and HP Display
local function removeNameHPDisplay(character)
    if character then
        local success, err = pcall(function()
            local billboard = character:FindFirstChild("NameHPDisplay")
            if billboard then
                billboard:Destroy()
                print("Name and HP Display removed for " .. (character.Parent and character.Parent.Name or "Unknown"))
            end
        end)
        if not success then
            warn("Ошибка при удалении Name and HP Display: " .. tostring(err))
        end
    end
end

-- Функция для обновления цвета Name and HP Display
local function updateNameHPColor()
    local success, err = pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local billboard = player.Character:FindFirstChild("NameHPDisplay")
                if billboard then
                    local frame = billboard:FindFirstChildOfClass("Frame")
                    if frame then
                        for _, label in ipairs(frame:GetChildren()) do
                            if label:IsA("TextLabel") then
                                label.TextColor3 = nameHPColor
                            end
                        end
                        print("Name and HP Display color updated for " .. player.Name)
                    end
                end
            end
        end
    end)
    if not success then
        warn("Ошибка при обновлении цвета Name and HP Display: " .. tostring(err))
    end
end

-- Функция для обновления всех ESP функций
local function updateESP()
    local success, err = pcall(function()
        -- Очистка существующих 3D-коробок
        for character, box in pairs(box3DParts) do
            if not character or not character.Parent or not character:FindFirstChildOfClass("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
                remove3DBox(character)
            elseif box then
                box.CFrame = (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart).CFrame
            end
        end

        -- Обновление ESP для всех игроков
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

                if humanoid and rootPart and humanoid.Health > 0 then
                    -- 3D Boxes
                    if is3DBoxesEnabled then
                        if not box3DParts[character] then
                            create3DBox(character)
                        else
                            local box = box3DParts[character]
                            if box then
                                box.CFrame = rootPart.CFrame
                            end
                        end
                    else
                        remove3DBox(character)
                    end

                    -- Highlights
                    if isHighlightsEnabled then
                        if not character:FindFirstChild("PlayerHighlight") then
                            createHighlight(character)
                        end
                    else
                        removeHighlight(character)
                    end

                    -- Name and HP Display
                    if isNameHPDisplayEnabled then
                        local billboard = character:FindFirstChild("NameHPDisplay")
                        if not billboard then
                            createNameHPDisplay(character)
                        else
                            local frame = billboard:FindFirstChildOfClass("Frame")
                            if frame then
                                local hpLabel = frame:FindFirstChildWhichIsA("TextLabel", true)
                                if hpLabel and hpLabel.Text:match("^HP:") then
                                    hpLabel.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
                                end
                            end
                        end
                    else
                        removeNameHPDisplay(character)
                    end
                else
                    remove3DBox(character)
                    removeHighlight(character)
                    removeNameHPDisplay(character)
                end
            end
        end
    end)
    if not success then
        warn("Ошибка при обновлении ESP: " .. tostring(err))
    end
end

-- Запуск обновления ESP каждые 0.01 секунд
local espUpdateConnection
local function startESPUpdate()
    if not espUpdateConnection then
        espUpdateConnection = RunService.Heartbeat:Connect(function(deltaTime)
            staticESPUpdateTime = (staticESPUpdateTime or 0) + deltaTime
            if staticESPUpdateTime >= 0.01 then
                updateESP()
                staticESPUpdateTime = 0
            end
        end)
    end
end

local function stopESPUpdate()
    if espUpdateConnection then
        espUpdateConnection:Disconnect()
        espUpdateConnection = nil
    end
end

-- Функция для включения 3D-коробок
local function enable3DBoxes()
    local success, err = pcall(function()
        print("Enabling 3D Boxes...")
        is3DBoxesEnabled = true
        startESPUpdate()
    end)
    if not success then
        warn("Ошибка при включении 3D-коробок: " .. tostring(err))
    end
end

-- Функция для выключения 3D-коробок
local function disable3DBoxes()
    local success, err = pcall(function()
        print("Disabling 3D Boxes...")
        is3DBoxesEnabled = false
        for character, _ in pairs(box3DParts) do
            remove3DBox(character)
        end
        box3DParts = {}
        if not (is3DBoxesEnabled or isHighlightsEnabled or isNameHPDisplayEnabled) then
            stopESPUpdate()
        end
    end)
    if not success then
        warn("Ошибка при выключении 3D-коробок: " .. tostring(err))
    end
end

-- Функция для включения Highlight
local function enableHighlights()
    local success, err = pcall(function()
        print("Enabling Highlights...")
        isHighlightsEnabled = true
        startESPUpdate()
    end)
    if not success then
        warn("Ошибка при включении Highlight: " .. tostring(err))
    end
end

-- Функция для выключения Highlight
local function disableHighlights()
    local success, err = pcall(function()
        print("Disabling Highlights...")
        isHighlightsEnabled = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                removeHighlight(player.Character)
            end
        end
        if not (is3DBoxesEnabled or isHighlightsEnabled or isNameHPDisplayEnabled) then
            stopESPUpdate()
        end
    end)
    if not success then
        warn("Ошибка при выключении Highlight: " .. tostring(err))
    end
end

-- Функция для включения Name and HP Display
local function enableNameHPDisplay()
    local success, err = pcall(function()
        print("Enabling Name and HP Display...")
        isNameHPDisplayEnabled = true
        startESPUpdate()
    end)
    if not success then
        warn("Ошибка при включении Name and HP Display: " .. tostring(err))
    end
end

-- Функция для выключения Name and HP Display
local function disableNameHPDisplay()
    local success, err = pcall(function()
        print("Disabling Name and HP Display...")
        isNameHPDisplayEnabled = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                removeNameHPDisplay(player.Character)
            end
        end
        if not (is3DBoxesEnabled or isHighlightsEnabled or isNameHPDisplayEnabled) then
            stopESPUpdate()
        end
    end)
    if not success then
        warn("Ошибка при выключении Name and HP Display: " .. tostring(err))
    end
end

-- Функция для декалей
local function saveAndRemoveDecals()
    local success, err = pcall(function()
        savedDecals = {}
        for _, decal in ipairs(game.Workspace:GetDescendants()) do
            if decal:IsA("Decal") then
                table.insert(savedDecals, {
                    Decal = decal,
                    Parent = decal.Parent,
                    Texture = decal.Texture,
                    Transparency = decal.Transparency,
                    Color3 = decal.Color3,
                    Face = decal.Face
                })
                decal.Parent = nil
            end
        end
    end)
    if not success then
        warn("Ошибка при удалении декалей: " .. tostring(err))
    end
end

local function restoreDecals()
    local success, err = pcall(function()
        for _, decalData in ipairs(savedDecals) do
            local decal = decalData.Decal
            decal.Parent = decalData.Parent
            decal.Texture = decalData.Texture
            decal.Transparency = decalData.Transparency
            decal.Color3 = decalData.Color3
            decal.Face = decalData.Face
        end
        savedDecals = {}
    end)
    if not success then
        warn("Ошибка при восстановлении декалей: " .. tostring(err))
    end
end

-- Функция для текстур
local function saveAndRemoveTextures()
    local success, err = pcall(function()
        savedTextures = {}
        for _, texture in ipairs(game.Workspace:GetDescendants()) do
            if texture:IsA("Texture") then
                table.insert(savedTextures, {
                    Texture = texture,
                    Parent = texture.Parent,
                    TextureID = texture.Texture,
                    Transparency = texture.Transparency,
                    Color3 = texture.Color3,
                    Face = texture.Face,
                    OffsetStudsU = texture.OffsetStudsU,
                    OffsetStudsV = texture.OffsetStudsV,
                    StudsPerTileU = texture.StudsPerTileU,
                    StudsPerTileV = texture.StudsPerTileV
                })
                texture.Parent = nil
            end
        end
    end)
    if not success then
        warn("Ошибка при удалении текстур: " .. tostring(err))
    end
end

local function restoreTextures()
    local success, err = pcall(function()
        for _, textureData in ipairs(savedTextures) do
            local texture = textureData.Texture
            texture.Parent = textureData.Parent
            texture.Texture = textureData.TextureID
            texture.Transparency = textureData.Transparency
            texture.Color3 = textureData.Color3
            texture.Face = textureData.Face
            texture.OffsetStudsU = textureData.OffsetStudsU
            texture.OffsetStudsV = textureData.OffsetStudsV
            texture.StudsPerTileU = textureData.StudsPerTileU
            texture.StudsPerTileV = textureData.StudsPerTileV
        end
        savedTextures = {}
    end)
    if not success then
        warn("Ошибка при восстановлении текстур: " .. tostring(err))
    end
end

-- Функция для AutoSprint
local function enableAutoSprint()
    local success, err = pcall(function()
        print("Enabling AutoSprint...")
        if not autoSprintConnection then
            autoSprintConnection = RunService.RenderStepped:Connect(function()
                if isAutoSprintEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid.MoveDirection.Magnitude > 0 then
                        game:GetService("ContextActionService"):BindAction(
                            "AutoSprint",
                            function() return Enum.ContextActionResult.Sink end,
                            false,
                            Enum.KeyCode.LeftShift
                        )
                    else
                        game:GetService("ContextActionService"):UnbindAction("AutoSprint")
                    end
                end
            end)
        end
    end)
    if not success then
        warn("Ошибка при включении AutoSprint: " .. tostring(err))
    end
end

local function disableAutoSprint()
    local success, err = pcall(function()
        print("Disabling AutoSprint...")
        if autoSprintConnection then
            autoSprintConnection:Disconnect()
            autoSprintConnection = nil
            game:GetService("ContextActionService"):UnbindAction("AutoSprint")
        end
    end)
    if not success then
        warn("Ошибка при выключении AutoSprint: " .. tostring(err))
    end
end

-- Функция для Fly
local function enableFly()
    local success, err = pcall(function()
        print("Enabling Fly...")
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChildOfClass("Humanoid") then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "FlyGyro"
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.D = 500
        bodyGyro.Parent = rootPart

        flyConnection = RunService.RenderStepped:Connect(function()
            if not isFlyEnabled or not rootPart or not rootPart.Parent then
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
                if flyConnection then flyConnection:Disconnect() end
                flyConnection = nil
                return
            end

            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + Vector3.new(0, 0, -1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection + Vector3.new(0, 0, 1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection + Vector3.new(-1, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + Vector3.new(1, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection + Vector3.new(0, -1, 0)
            end

            local cameraCFrame = workspace.CurrentCamera.CFrame
            moveDirection = cameraCFrame:VectorToWorldSpace(moveDirection)
            bodyVelocity.Velocity = moveDirection * flySpeed
            bodyGyro.CFrame = cameraCFrame
        end)
    end)
    if not success then
        warn("Ошибка при включении Fly: " .. tostring(err))
    end
end

local function disableFly()
    local success, err = pcall(function()
        print("Disabling Fly...")
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart:FindFirstChild("FlyVelocity") then
                rootPart:FindFirstChild("FlyVelocity"):Destroy()
            end
            if rootPart:FindFirstChild("FlyGyro") then
                rootPart:FindFirstChild("FlyGyro"):Destroy()
            end
        end
    end)
    if not success then
        warn("Ошибка при выключении Fly: " .. tostring(err))
    end
end

-- Функция для удаления 64-й строки из скрипта ShiftToRun
local function removeShiftToRunLine64(player)
    local success, err = pcall(function()
        local playerFolder = game.Workspace:FindFirstChild(player.Name)
        if not playerFolder then
            print("Player folder not found in Workspace for: " .. player.Name)
            return
        end

        local shiftToRun = playerFolder:FindFirstChild("ShiftToRun")
        if not shiftToRun then
            print("ShiftToRun script not found for player: " .. player.Name)
            return
        end

        if not (shiftToRun:IsA("Script") or shiftToRun:IsA("LocalScript")) then
            print("ShiftToRun is not a Script or LocalScript for player: " .. player.Name)
            return
        end

        -- Try to modify the Source property
        local sourceSuccess, source = pcall(function()
            return shiftToRun.Source
        end)

        if sourceSuccess and source then
            local lines = {}
            for line in source:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            if #lines >= 64 then
                table.remove(lines, 64)
                local newSource = table.concat(lines, "\n")
                local setSourceSuccess, setSourceErr = pcall(function()
                    shiftToRun.Source = newSource
                end)
                if setSourceSuccess then
                    print("Removed line 64 from ShiftToRun for player: " .. player.Name)
                else
                    warn("Failed to set Source for ShiftToRun for " .. player.Name .. ": " .. tostring(setSourceErr))
                    print("Attempting to disable ShiftToRun as fallback...")
                    shiftToRun.Disabled = true
                end
            else
                warn("ShiftToRun script for " .. player.Name .. " has fewer than 64 lines (" .. #lines .. " lines)")
                print("Disabling ShiftToRun as fallback...")
                shiftToRun.Disabled = true
            end
        else
            warn("Cannot access Source of ShiftToRun for " .. player.Name .. ": " .. tostring(source))
            print("Attempting to disable ShiftToRun as fallback...")
            shiftToRun.Disabled = true
        end
    end)
    if not success then
        warn("Ошибка при попытке обработки ShiftToRun для " .. player.Name .. ": " .. tostring(err))
    end
end

-- Применение функции removeShiftToRunLine64 для существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        removeShiftToRunLine64(player)
    end
end

-- Применение функции removeShiftToRunLine64 для новых игроков
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            removeShiftToRunLine64(player)
        end)
    end
end)

-- UI элементы
local Label1 = VisualTab:CreateLabel({
    Text = "ESP Functions",
    Style = 1
})

-- Переключатель для 3D Boxes
local VESPToggle1 = VisualTab:CreateToggle({
    Name = "3D Boxes",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            print("3D Boxes toggle set to: " .. tostring(Value))
            if Value then
                enable3DBoxes()
            else
                disable3DBoxes()
            end
        end)
        if not success then
            warn("Callback error (3D Boxes): " .. tostring(err))
        end
    end
}, "3DBoxToggle")

-- ColorPicker для 3D Boxes
local ColorPicker3D = VisualTab:CreateColorPicker({
    Name = "3D Box Color",
    Default = box3DColor,
    Callback = function(Value)
        local success, err = pcall(function()
            box3DColor = Value
            print("3D Box color changed to: " .. tostring(Value))
            update3DBoxColor()
        end)
        if not success then
            warn("Ошибка при изменении цвета 3D-коробок: " .. tostring(err))
        end
    end
}, "3DBoxColorPicker")

-- Переключатель для Highlights
local HighlightToggle = VisualTab:CreateToggle({
    Name = "Player Highlights",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            print("Player Highlights toggle set to: " .. tostring(Value))
            if Value then
                enableHighlights()
            else
                disableHighlights()
            end
        end)
        if not success then
            warn("Callback error (Player Highlights): " .. tostring(err))
        end
    end
}, "HighlightToggle")

-- ColorPicker для Highlights
local ColorPickerHighlight = VisualTab:CreateColorPicker({
    Name = "Highlight Color",
    Default = highlightColor,
    Callback = function(Value)
        local success, err = pcall(function()
            highlightColor = Value
            print("Highlight color changed to: " .. tostring(Value))
            updateHighlightColor()
        end)
        if not success then
            warn("Ошибка при изменении цвета Highlight: " .. tostring(err))
        end
    end
}, "HighlightColorPicker")

-- Переключатель для Name and HP Display
local NameHPToggle = VisualTab:CreateToggle({
    Name = "Name and HP Display",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            print("Name and HP Display toggle set to: " .. tostring(Value))
            if Value then
                enableNameHPDisplay()
            else
                disableNameHPDisplay()
            end
        end)
        if not success then
            warn("Callback error (Name and HP Display): " .. tostring(err))
        end
    end
}, "NameHPToggle")

-- ColorPicker для Name and HP Display
local ColorPickerNameHP = VisualTab:CreateColorPicker({
    Name = "Name and HP Color",
    Default = nameHPColor,
    Callback = function(Value)
        local success, err = pcall(function()
            nameHPColor = Value
            print("Name and HP Display color changed to: " .. tostring(Value))
            updateNameHPColor()
        end)
        if not success then
            warn("Ошибка при изменении цвета Name and HP Display: " .. tostring(err))
        end
    end
}, "NameHPColorPicker")

-- Переключатель для AutoSprint
local AutoSprintToggle = MovementTab:CreateToggle({
    Name = "AutoSprint",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isAutoSprintEnabled = Value
            print("AutoSprint toggle set to: " .. tostring(Value))
            if isAutoSprintEnabled then
                enableAutoSprint()
            else
                disableAutoSprint()
            end
        end)
        if not success then
            warn("Callback error (AutoSprint): " .. tostring(err))
        end
    end
}, "AutoSprintToggle")

-- Input для WalkSpeed
local WalkSpeedInput = MovementTab:CreateInput({
    Name = "WalkSpeed",
    Description = nil,
    PlaceholderText = "Enter Walk Speed",
    CurrentValue = tostring(walkSpeed),
    Numeric = true,
    MaxCharacters = 4,
    Enter = true,
    Callback = function(value)
        local success, err = pcall(function()
            local newSpeed = tonumber(value)
            if newSpeed and newSpeed >= 0 then
                walkSpeed = newSpeed
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeed
                end
                print("WalkSpeed set to: " .. tostring(walkSpeed))
            else
                warn("Invalid WalkSpeed input: " .. tostring(value))
            end
        end)
        if not success then
            warn("Callback error (WalkSpeed): " .. tostring(err))
        end
    end
}, "WalkSpeedInput")

-- Input для JumpPower
local JumpPowerInput = MovementTab:CreateInput({
    Name = "JumpPower",
    Description = nil,
    PlaceholderText = "Enter Jump Power",
    CurrentValue = tostring(jumpPower),
    Numeric = true,
    MaxCharacters = 4,
    Enter = true,
    Callback = function(value)
        local success, err = pcall(function()
            local newPower = tonumber(value)
            if newPower and newPower >= 0 then
                jumpPower = newPower
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = jumpPower
                end
                print("JumpPower set to: " .. tostring(jumpPower))
            else
                warn("Invalid JumpPower input: " .. tostring(value))
            end
        end)
        if not success then
            warn("Callback error (JumpPower): " .. tostring(err))
        end
    end
}, "JumpPowerInput")

-- Переключатель для Fly
local FlyToggle = MovementTab:CreateToggle({
    Name = "Fly",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isFlyEnabled = Value
            print("Fly toggle set to: " .. tostring(Value))
            if isFlyEnabled then
                enableFly()
            else
                disableFly()
            end
        end)
        if not success then
            warn("Callback error (Fly): " .. tostring(err))
        end
    end
}, "FlyToggle")

local Label2 = VisualTab:CreateLabel({
    Text = "FPS Functions",
    Style = 1
})

local ConsoleClearToggle = VisualTab:CreateToggle({
    Name = "Clear Console",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isConsoleClearEnabled = Value
            print("Console Clear toggle set to: " .. tostring(Value))
            if isConsoleClearEnabled then
                enableConsoleClear()
            else
                disableConsoleClear()
            end
        end)
        if not success then
            warn("Callback error (Console Clear): " .. tostring(err))
        end
    end
}, "ConsoleClearToggle")

local DecalToggle = VisualTab:CreateToggle({
    Name = "Remove Decals",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isDecalsRemoved = Value
            if isDecalsRemoved then
                saveAndRemoveDecals()
            else
                restoreDecals()
            end
        end)
        if not success then
            warn("Callback error (Remove Decals): " .. tostring(err))
        end
    end
}, "DecalToggle")

local TextureToggle = VisualTab:CreateToggle({
    Name = "Remove Textures",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isTexturesRemoved = Value
            if isTexturesRemoved then
                saveAndRemoveTextures()
            else
                restoreTextures()
            end
        end)
        if not success then
            warn("Callback error (Remove Textures): " .. tostring(err))
        end
    end
}, "TextureToggle")

local Label3 = VisualTab:CreateLabel({
    Text = "Other Functions",
    Style = 1
})

local VSEPInput1 = VisualTab:CreateInput({
    Name = "FOV",
    Description = nil,
    PlaceholderText = "Enter FOV",
    CurrentValue = "90",
    Numeric = true,
    MaxCharacters = 3,
    Enter = true,
    Callback = function(value)
        local success, err = pcall(function()
            local newFOV = tonumber(value)
            if newFOV and newFOV >= 10 and newFOV <= 120 then
                local camera = workspace.CurrentCamera
                camera.FieldOfView = newFOV
                print("FOV set to: " .. tostring(newFOV))
            else
                warn("Invalid FOV input: " .. tostring(value))
            end
        end)
        if not success then
            warn("Callback error (FOV): " .. tostring(err))
        end
    end
}, "FOVInput")

-- Обновление WalkSpeed и JumpPower при появлении нового персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
    local success, err = pcall(function()
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.WalkSpeed = walkSpeed
            humanoid.JumpPower = jumpPower
            if isFlyEnabled then
                enableFly()
            end
        end
    end)
    if not success then
        warn("Ошибка при обновлении WalkSpeed/JumpPower для нового персонажа: " .. tostring(err))
    end
end)
