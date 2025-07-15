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

local VehicleTab = Window:CreateTab({
    Name = "Vehicle",
    Icon = "view_in_ar",
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
local isFlyEnabled = false
local flyConnection = nil
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50
local isFlingEnabled = false
local flingConnection = nil
local isNoClipEnabled = false
local noClipConnection = nil
local flingDiedConnection = nil
local flingAutoNoClip = false
local isFakeLagEnabled = false
local fakeLagConnection = nil
local fakeLagInterval = 0.5

-- Переменные для Vehicle
local isVehicleFlyEnabled = false
local vehicleFlyConnection = nil
local vehicleFlySpeed = 50
local isVehicleSpeedUnlockerEnabled = false
local vehicleSpeedConnection = nil
local vehicleSpeedMultiplier = 2
local isVehicleFlingEnabled = false
local vehicleFlingConnection = nil
local vehicleFlingAutoNoClip = false

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
        for character, box in pairs(box3DParts) do
            if not character or not character.Parent or not character:FindFirstChildOfClass("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
                remove3DBox(character)
            elseif box then
                box.CFrame = (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart).CFrame
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

                if humanoid and rootPart and humanoid.Health > 0 then
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

                    if isHighlightsEnabled then
                        if not character:FindFirstChild("PlayerHighlight") then
                            createHighlight(character)
                        end
                    else
                        removeHighlight(character)
                    end

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

local function flingLocalPlayer()
    local success, err = pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart or humanoid.Health <= 0 then return end

        for _, child in ipairs(character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
                child.CanCollide = false
                child.CanTouch = false
                child.Massless = true
                child.Velocity = Vector3.new(0, 0, 0)
                child.AngularVelocity = Vector3.new(0, 0, 0)
            end
        end

        local bambam = Instance.new("BodyAngularVelocity")
        bambam.Name = "FlingAngularVelocity"
        bambam.Parent = rootPart
        bambam.AngularVelocity = Vector3.new(0, 50000, 0) -- Уменьшено для стабильности
        bambam.MaxTorque = Vector3.new(0, math.huge, 0)
        bambam.P = 10000

        if not isNoClipEnabled then
            flingAutoNoClip = true
            enableNoClip()
        end

        local flingTimer = 0
        local flingPhase = true
        flingConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if not isFlingEnabled or not rootPart or not rootPart.Parent or not humanoid or humanoid.Health <= 0 then
                if bambam and bambam.Parent then bambam:Destroy() end
                if flingConnection then flingConnection:Disconnect() flingConnection = nil end
                if flingAutoNoClip and not isNoClipEnabled then
                    disableNoClip()
                    flingAutoNoClip = false
                end
                return
            end

            flingTimer = flingTimer + deltaTime
            if flingPhase and flingTimer >= 0.2 then
                bambam.AngularVelocity = Vector3.new(0, 0, 0)
                flingPhase = false
                flingTimer = 0
            elseif not flingPhase and flingTimer >= 0.1 then
                bambam.AngularVelocity = Vector3.new(0, 50000, 0)
                flingPhase = true
                flingTimer = 0
            end
        end)
    end)
    if not success then
        warn("Ошибка при выполнении Fling: " .. tostring(err))
    end
end

local function enableFling()
    local success, err = pcall(function()
        print("Enabling Fling...")
        isFlingEnabled = true
        if isFakeLagEnabled then
            disableFakeLag()
        end
        if isVehicleFlyEnabled or isVehicleSpeedUnlockerEnabled or isVehicleFlingEnabled then
            disableVehicleFly()
            disableVehicleSpeedUnlocker()
            disableVehicleFling()
        end
        flingLocalPlayer()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                flingDiedConnection = humanoid.Died:Connect(function()
                    disableFling()
                end)
            end
        end
    end)
    if not success then
        warn("Ошибка при включении Fling: " .. tostring(err))
    end
end

local function disableFling()
    local success, err = pcall(function()
        print("Disabling Fling...")
        isFlingEnabled = false
        if flingConnection then
            flingConnection:Disconnect()
            flingConnection = nil
        end
        if flingDiedConnection then
            flingDiedConnection:Disconnect()
            flingDiedConnection = nil
        end
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart:FindFirstChild("FlingAngularVelocity") then
                rootPart:FindFirstChild("FlingAngularVelocity"):Destroy()
            end
            rootPart.Anchored = true
            for _, child in ipairs(character:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CustomPhysicalProperties = nil
                    child.Massless = false
                    child.Velocity = Vector3.new(0, 0, 0)
                    child.AngularVelocity = Vector3.new(0, 0, 0)
                    if not isNoClipEnabled then
                        child.CanCollide = true
                        child.CanTouch = true
                    end
                end
            end
            wait(0.1) -- Короткая задержка для стабилизации
            rootPart.Anchored = false
        end
        if flingAutoNoClip and not isNoClipEnabled then
            disableNoClip()
            flingAutoNoClip = false
        end
    end)
    if not success then
        warn("Ошибка при выключении Fling: " .. tostring(err))
    end
end

local function enableNoClip()
    local success, err = pcall(function()
        print("Enabling NoClip...")
        isNoClipEnabled = true
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChildOfClass("Humanoid") then return end

        noClipConnection = RunService.Stepped:Connect(function()
            if not isNoClipEnabled or not LocalPlayer.Character then
                return
            end
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanTouch = false
                end
            end
        end)
    end)
    if not success then
        warn("Ошибка при включении NoClip: " .. tostring(err))
    end
end

local function disableNoClip()
    local success, err = pcall(function()
        print("Disabling NoClip...")
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if not isFlingEnabled then
                        part.CanCollide = true
                        part.CanTouch = true
                    end
                end
            end
        end
    end)
    if not success then
        warn("Ошибка при выключении NoClip: " .. tostring(err))
    end
end

local function enableFakeLag()
    local success, err = pcall(function()
        print("Enabling FakeLag...")
        isFakeLagEnabled = true
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChildOfClass("Humanoid") then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local originalAnchored = rootPart.Anchored
        local lagTimer = 0
        local lagPhase = true
        fakeLagConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if not isFakeLagEnabled or not rootPart or not rootPart.Parent or isFlingEnabled or isFlyEnabled then
                if fakeLagConnection then
                    fakeLagConnection:Disconnect()
                    fakeLagConnection = nil
                end
                if rootPart then
                    rootPart.Anchored = originalAnchored
                end
                return
            end

            lagTimer = lagTimer + deltaTime
            if lagPhase and lagTimer >= fakeLagInterval then
                rootPart.Anchored = true
                lagPhase = false
                lagTimer = 0
            elseif not lagPhase and lagTimer >= 0.1 then
                rootPart.Anchored = false
                lagPhase = true
                lagTimer = 0
            end
        end)
    end)
    if not success then
        warn("Ошибка при включении FakeLag: " .. tostring(err))
    end
end

local function disableFakeLag()
    local success, err = pcall(function()
        print("Disabling FakeLag...")
        isFakeLagEnabled = false
        if fakeLagConnection then
            fakeLagConnection:Disconnect()
            fakeLagConnection = nil
        end
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            rootPart.Anchored = false
        end
    end)
    if not success then
        warn("Ошибка при выключении FakeLag: " .. tostring(err))
    end
end

-- Функции для Vehicle
local function getVehicle()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart or not humanoid.SeatPart.Parent then return nil end
    local vehicle = humanoid.SeatPart.Parent
    local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return nil end
    return vehicle, primaryPart
end

local function enableVehicleFly()
    local success, err = pcall(function()
        print("Enabling Vehicle Fly...")
        isVehicleFlyEnabled = true
        if isFlyEnabled or isFlingEnabled or isFakeLagEnabled then
            disableFly()
            disableFling()
            disableFakeLag()
        end
        local vehicle, primaryPart = getVehicle()
        if not vehicle or not primaryPart then
            isVehicleFlyEnabled = false
            return
        end

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "VehicleFlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = primaryPart

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "VehicleFlyGyro"
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.D = 500
        bodyGyro.Parent = primaryPart

        vehicleFlyConnection = RunService.RenderStepped:Connect(function()
            local currentVehicle, currentPrimaryPart = getVehicle()
            if not isVehicleFlyEnabled or not currentVehicle or not currentPrimaryPart or currentVehicle ~= vehicle then
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
                if vehicleFlyConnection then vehicleFlyConnection:Disconnect() end
                vehicleFlyConnection = nil
                isVehicleFlyEnabled = false
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
            bodyVelocity.Velocity = moveDirection * vehicleFlySpeed
            bodyGyro.CFrame = cameraCFrame
        end)
    end)
    if not success then
        warn("Ошибка при включении Vehicle Fly: " .. tostring(err))
    end
end

local function disableVehicleFly()
    local success, err = pcall(function()
        print("Disabling Vehicle Fly...")
        isVehicleFlyEnabled = false
        if vehicleFlyConnection then
            vehicleFlyConnection:Disconnect()
            vehicleFlyConnection = nil
        end
        local vehicle, primaryPart = getVehicle()
        if vehicle and primaryPart then
            if primaryPart:FindFirstChild("VehicleFlyVelocity") then
                primaryPart:FindFirstChild("VehicleFlyVelocity"):Destroy()
            end
            if primaryPart:FindFirstChild("VehicleFlyGyro") then
                primaryPart:FindFirstChild("VehicleFlyGyro"):Destroy()
            end
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.AngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
    if not success then
        warn("Ошибка при выключении Vehicle Fly: " .. tostring(err))
    end
end

local function enableVehicleSpeedUnlocker()
    local success, err = pcall(function()
        print("Enabling Vehicle Speed Unlocker...")
        isVehicleSpeedUnlockerEnabled = true
        if isFlyEnabled or isFlingEnabled or isFakeLagEnabled then
            disableFly()
            disableFling()
            disableFakeLag()
        end
        local vehicle, primaryPart = getVehicle()
        if not vehicle or not primaryPart then
            isVehicleSpeedUnlockerEnabled = false
            return
        end

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "VehicleSpeedVelocity"
        bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = primaryPart

        vehicleSpeedConnection = RunService.RenderStepped:Connect(function()
            local currentVehicle, currentPrimaryPart = getVehicle()
            if not isVehicleSpeedUnlockerEnabled or not currentVehicle or not currentPrimaryPart or currentVehicle ~= vehicle then
                if bodyVelocity then bodyVelocity:Destroy() end
                if vehicleSpeedConnection then vehicleSpeedConnection:Disconnect() end
                vehicleSpeedConnection = nil
                isVehicleSpeedUnlockerEnabled = false
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

            local cameraCFrame = workspace.CurrentCamera.CFrame
            moveDirection = cameraCFrame:VectorToWorldSpace(moveDirection)
            bodyVelocity.Velocity = moveDirection * vehicleFlySpeed * vehicleSpeedMultiplier
        end)
    end)
    if not success then
        warn("Ошибка при включении Vehicle Speed Unlocker: " .. tostring(err))
    end
end

local function disableVehicleSpeedUnlocker()
    local success, err = pcall(function()
        print("Disabling Vehicle Speed Unlocker...")
        isVehicleSpeedUnlockerEnabled = false
        if vehicleSpeedConnection then
            vehicleSpeedConnection:Disconnect()
            vehicleSpeedConnection = nil
        end
        local vehicle, primaryPart = getVehicle()
        if vehicle and primaryPart then
            if primaryPart:FindFirstChild("VehicleSpeedVelocity") then
                primaryPart:FindFirstChild("VehicleSpeedVelocity"):Destroy()
            end
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.AngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
    if not success then
        warn("Ошибка при выключении Vehicle Speed Unlocker: " .. tostring(err))
    end
end

local function enableVehicleFling()
    local success, err = pcall(function()
        print("Enabling Vehicle Fling...")
        isVehicleFlingEnabled = true
        if isFlyEnabled or isFlingEnabled or isFakeLagEnabled or isVehicleFlyEnabled or isVehicleSpeedUnlockerEnabled then
            disableFly()
            disableFling()
            disableFakeLag()
            disableVehicleFly()
            disableVehicleSpeedUnlocker()
        end
        local vehicle, primaryPart = getVehicle()
        if not vehicle or not primaryPart then
            isVehicleFlingEnabled = false
            return
        end

        for _, part in ipairs(vehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CanTouch = false
                part.Massless = true
                part.Velocity = Vector3.new(0, 0, 0)
                part.AngularVelocity = Vector3.new(0, 0, 0)
            end
        end

        local bambam = Instance.new("BodyAngularVelocity")
        bambam.Name = "VehicleFlingAngularVelocity"
        bambam.Parent = primaryPart
        bambam.AngularVelocity = Vector3.new(0, 50000, 0)
        bambam.MaxTorque = Vector3.new(0, math.huge, 0)
        bambam.P = 10000

        if not isNoClipEnabled then
            vehicleFlingAutoNoClip = true
            enableNoClip()
        end

        local flingTimer = 0
        local flingPhase = true
        vehicleFlingConnection = RunService.Heartbeat:Connect(function(deltaTime)
            local currentVehicle, currentPrimaryPart = getVehicle()
            if not isVehicleFlingEnabled or not currentVehicle or not currentPrimaryPart or currentVehicle ~= vehicle then
                if bambam and bambam.Parent then bambam:Destroy() end
                if vehicleFlingConnection then vehicleFlingConnection:Disconnect() end
                vehicleFlingConnection = nil
                if vehicleFlingAutoNoClip and not isNoClipEnabled then
                    disableNoClip()
                    vehicleFlingAutoNoClip = false
                end
                isVehicleFlingEnabled = false
                return
            end

            flingTimer = flingTimer + deltaTime
            if flingPhase and flingTimer >= 0.2 then
                bambam.AngularVelocity = Vector3.new(0, 0, 0)
                flingPhase = false
                flingTimer = 0
            elseif not flingPhase and flingTimer >= 0.1 then
                bambam.AngularVelocity = Vector3.new(0, 50000, 0)
                flingPhase = true
                flingTimer = 0
            end
        end)
    end)
    if not success then
        warn("Ошибка при включении Vehicle Fling: " .. tostring(err))
    end
end

local function disableVehicleFling()
    local success, err = pcall(function()
        print("Disabling Vehicle Fling...")
        isVehicleFlingEnabled = false
        if vehicleFlingConnection then
            vehicleFlingConnection:Disconnect()
            vehicleFlingConnection = nil
        end
        local vehicle, primaryPart = getVehicle()
        if vehicle and primaryPart then
            if primaryPart:FindFirstChild("VehicleFlingAngularVelocity") then
                primaryPart:FindFirstChild("VehicleFlingAngularVelocity"):Destroy()
            end
            primaryPart.Anchored = true
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = false
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.AngularVelocity = Vector3.new(0, 0, 0)
                    if not isNoClipEnabled then
                        part.CanCollide = true
                        part.CanTouch = true
                    end
                end
            end
            wait(0.1)
            primaryPart.Anchored = false
        end
        if vehicleFlingAutoNoClip and not isNoClipEnabled then
            disableNoClip()
            vehicleFlingAutoNoClip = false
        end
    end)
    if not success then
        warn("Ошибка при выключении Vehicle Fling: " .. tostring(err))
    end
end

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

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        removeShiftToRunLine64(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            removeShiftToRunLine64(player)
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    local success, err = pcall(function()
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.WalkSpeed = walkSpeed
            humanoid.JumpPower = jumpPower
            if isFlyEnabled then
                enableFly()
            end
            if isNoClipEnabled or isFlingEnabled then
                enableNoClip()
            end
            if isFlingEnabled then
                enableFling()
            end
            if isFakeLagEnabled then
                enableFakeLag()
            end
            if isVehicleFlyEnabled then
                enableVehicleFly()
            end
            if isVehicleSpeedUnlockerEnabled then
                enableVehicleSpeedUnlocker()
            end
            if isVehicleFlingEnabled then
                enableVehicleFling()
            end
        end
    end)
    if not success then
        warn("Ошибка при обновлении WalkSpeed/JumpPower/NoClip/Fling/FakeLag/Vehicle для нового персонажа: " .. tostring(err))
    end
end)

-- Обработчик выхода из транспорта
LocalPlayer.Character:WaitForChild("Humanoid").Seated:Connect(function(isSeated, seatPart)
    if not isSeated then
        if isVehicleFlyEnabled then
            disableVehicleFly()
        end
        if isVehicleSpeedUnlockerEnabled then
            disableVehicleSpeedUnlocker()
        end
        if isVehicleFlingEnabled then
            disableVehicleFling()
        end
    end
end)

-- UI элементы
local Label1 = VisualTab:CreateLabel({
    Text = "ESP Functions",
    Style = 1
})

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

local Label4 = MovementTab:CreateLabel({
    Text = "Speed/Power Modifications",
    Style = 1
})

local FlySpeedInput = MovementTab:CreateInput({
    Name = "Fly Speed",
    Description = nil,
    PlaceholderText = "Enter Fly Speed",
    CurrentValue = tostring(flySpeed),
    Numeric = true,
    MaxCharacters = 3,
    Enter = true,
    Callback = function(value)
        local success, err = pcall(function()
            local newSpeed = tonumber(value)
            if newSpeed and newSpeed >= 0 and newSpeed <= 500 then
                flySpeed = newSpeed
                print("Fly Speed set to: " .. tostring(flySpeed))
                if isFlyEnabled then
                    disableFly()
                    enableFly()
                end
            else
                warn("Invalid Fly Speed input: " .. tostring(value))
            end
        end)
        if not success then
            warn("Callback error (Fly Speed): " .. tostring(err))
        end
    end
}, "FlySpeedInput")

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

local FakeLagIntervalInput = MovementTab:CreateInput({
    Name = "FakeLag Interval",
    Description = nil,
    PlaceholderText = "Enter Lag Interval (0.1-2)",
    CurrentValue = tostring(fakeLagInterval),
    Numeric = true,
    MaxCharacters = 3,
    Enter = true,
    Callback = function(value)
        local success, err = pcall(function()
            local newInterval = tonumber(value)
            if newInterval and newInterval >= 0.1 and newInterval <= 2 then
                fakeLagInterval = newInterval
                print("FakeLag Interval set to: " .. tostring(fakeLagInterval))
                if isFakeLagEnabled then
                    disableFakeLag()
                    enableFakeLag()
                end
            else
                warn("Invalid FakeLag Interval input: " .. tostring(value))
            end
        end)
        if not success then
            warn("Callback error (FakeLag Interval): " .. tostring(err))
        end
    end
}, "FakeLagIntervalInput")

local Label5 = MovementTab:CreateLabel({
    Text = "Speed/Power Functions",
    Style = 1
})

local FlyToggle = MovementTab:CreateToggle({
    Name = "Fly",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isFlyEnabled = Value
            print("Fly toggle set to: " .. tostring(Value))
            if isFlyEnabled then
                if isFakeLagEnabled then
                    disableFakeLag()
                end
                if isVehicleFlyEnabled or isVehicleSpeedUnlockerEnabled or isVehicleFlingEnabled then
                    disableVehicleFly()
                    disableVehicleSpeedUnlocker()
                    disableVehicleFling()
                end
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

local FlingToggle = MovementTab:CreateToggle({
    Name = "Fling",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isFlingEnabled = Value
            print("Fling toggle set to: " .. tostring(Value))
            if isFlingEnabled then
                enableFling()
            else
                disableFling()
            end
        end)
        if not success then
            warn("Callback error (Fling): " .. tostring(err))
        end
    end
}, "FlingToggle")

local NoClipToggle = MovementTab:CreateToggle({
    Name = "NoClip",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isNoClipEnabled = Value
            print("NoClip toggle set to: " .. tostring(Value))
            if isNoClipEnabled then
                enableNoClip()
            else
                disableNoClip()
            end
        end)
        if not success then
            warn("Callback error (NoClip): " .. tostring(err))
        end
    end
}, "NoClipToggle")

local FakeLagToggle = MovementTab:CreateToggle({
    Name = "FakeLag",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isFakeLagEnabled = Value
            print("FakeLag toggle set to: " .. tostring(Value))
            if isFakeLagEnabled then
                if isVehicleFlyEnabled or isVehicleSpeedUnlockerEnabled or isVehicleFlingEnabled then
                    disableVehicleFly()
                    disableVehicleSpeedUnlocker()
                    disableVehicleFling()
                end
                enableFakeLag()
            else
                disableFakeLag()
            end
        end)
        if not success then
            warn("Callback error (FakeLag): " .. tostring(err))
        end
    end
}, "FakeLagToggle")

local Label6 = VehicleTab:CreateLabel({
    Text = "Vehicle Modifications",
    Style = 1
})

local VehicleFlySpeedInput = VehicleTab:CreateInput({
    Name = "Vehicle Fly Speed",
    Description = nil,
    PlaceholderText = "Enter Vehicle Fly Speed",
    CurrentValue = tostring(vehicleFlySpeed),
    Numeric = true,
    MaxCharacters = 3,
    Enter = true,
    Callback = function(value)
        local success, err = pcall(function()
            local newSpeed = tonumber(value)
            if newSpeed and newSpeed >= 0 and newSpeed <= 500 then
                vehicleFlySpeed = newSpeed
                print("Vehicle Fly Speed set to: " .. tostring(vehicleFlySpeed))
                if isVehicleFlyEnabled then
                    disableVehicleFly()
                    enableVehicleFly()
                end
            else
                warn("Invalid Vehicle Fly Speed input: " .. tostring(value))
            end
        end)
        if not success then
            warn("Callback error (Vehicle Fly Speed): " .. tostring(err))
        end
    end
}, "VehicleFlySpeedInput")

local VehicleSpeedMultiplierInput = VehicleTab:CreateInput({
    Name = "Vehicle Speed Multiplier",
    Description = nil,
    PlaceholderText = "Enter Speed Multiplier (1-10)",
    CurrentValue = tostring(vehicleSpeedMultiplier),
    Numeric = true,
    MaxCharacters = 2,
    Enter = true,
    Callback = function(value)
        local success, err = pcall(function()
            local newMultiplier = tonumber(value)
            if newMultiplier and newMultiplier >= 1 and newMultiplier <= 10 then
                vehicleSpeedMultiplier = newMultiplier
                print("Vehicle Speed Multiplier set to: " .. tostring(vehicleSpeedMultiplier))
                if isVehicleSpeedUnlockerEnabled then
                    disableVehicleSpeedUnlocker()
                    enableVehicleSpeedUnlocker()
                end
            else
                warn("Invalid Vehicle Speed Multiplier input: " .. tostring(value))
            end
        end)
        if not success then
            warn("Callback error (Vehicle Speed Multiplier): " .. tostring(err))
        end
    end
}, "VehicleSpeedMultiplierInput")

local Label7 = VehicleTab:CreateLabel({
    Text = "Vehicle Functions",
    Style = 1
})

local VehicleFlyToggle = VehicleTab:CreateToggle({
    Name = "Vehicle Fly",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isVehicleFlyEnabled = Value
            print("Vehicle Fly toggle set to: " .. tostring(Value))
            if isVehicleFlyEnabled then
                enableVehicleFly()
            else
                disableVehicleFly()
            end
        end)
        if not success then
            warn("Callback error (Vehicle Fly): " .. tostring(err))
        end
    end
}, "VehicleFlyToggle")

local VehicleSpeedUnlockerToggle = VehicleTab:CreateToggle({
    Name = "Vehicle Speed Unlocker",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isVehicleSpeedUnlockerEnabled = Value
            print("Vehicle Speed Unlocker toggle set to: " .. tostring(Value))
            if isVehicleSpeedUnlockerEnabled then
                enableVehicleSpeedUnlocker()
            else
                disableVehicleSpeedUnlocker()
            end
        end)
        if not success then
            warn("Callback error (Vehicle Speed Unlocker): " .. tostring(err))
        end
    end
}, "VehicleSpeedUnlockerToggle")

local VehicleFlingToggle = VehicleTab:CreateToggle({
    Name = "Vehicle Fling",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        local success, err = pcall(function()
            isVehicleFlingEnabled = Value
            print("Vehicle Fling toggle set to: " .. tostring(Value))
            if isVehicleFlingEnabled then
                enableVehicleFling()
            else
                disableVehicleFling()
            end
        end)
        if not success then
            warn("Callback error (Vehicle Fling): " .. tostring(err))
        end
    end
}, "VehicleFlingToggle")

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
