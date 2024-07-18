print("Injecting Aceware...")

local ACEWARE_VERSION = "0.9.0"

print("Version is " .. ACEWARE_VERSION)

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local AIMBOT_ON = false
local AIMBOT_FOV = 150
local AIMBOT_SMOOTHING = 50
local AIMBOT_FOV_COLOR = Color3.fromRGB(255, 255, 255)
local AIMBOT_BIND = Enum.UserInputType.MouseButton2

local TRIGGERBOT_ON = false
local TRIGGERBOT_DELAY = 0.1

local SPINBOT_SPEED = 10

local BHOP_ON = false

local CHAMS_ON = false

local FLY_ON = false

local FPS_ON = true

local PING_ON = true

local horizSpinConnection
local horizSpinAngle = 0

local vertSpinConnection
local vertSpinAngle = 0

local ESP_COLOR = Color3.fromRGB(255, 255, 255) 

local circle

local camera = game.Workspace.CurrentCamera
local localplayer = game:GetService("Players").LocalPlayer
local dist = math.huge
local target = nil
local aiming = false

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local originalY = humanoidRootPart.Position.Y


local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- Skeleton ESP variables and functions
local skeletonConnections = {}
local skeletonDrawings = {}
local ESPSkeletonToggle = {Value = false}
local ESPColor = {Value = Color3.new(1, 1, 1)}

-- Box ESP variables and functions
local boxDrawings = {}
local ESPBoxToggle = {Value = false}

local function createBone()
    local bone = Drawing.new("Line")
    bone.Visible = false
    bone.Color = Color3.new(1, 1, 1)
    bone.Thickness = 1
    bone.Transparency = 1
    return bone
end

local function updateBone(bone, from, to)
    bone.From = from
    bone.To = to
end

local function createSkeleton(player)
    local character = player.Character
    if not character then return end

    local bones = {
        createBone(), -- UpperTorso to LowerTorso
        createBone(), -- LeftUpperArm to LeftLowerArm
        createBone(), -- LeftLowerArm to LeftHand
        createBone(), -- RightUpperArm to RightLowerArm
        createBone(), -- RightLowerArm to RightHand
        createBone(), -- LeftUpperLeg to LeftLowerLeg
        createBone(), -- LeftLowerLeg to LeftFoot
        createBone(), -- RightUpperLeg to RightLowerLeg
        createBone(), -- RightLowerLeg to RightFoot
    }

    skeletonDrawings[player] = bones

    local function updateSkeleton()
        if not ESPSkeletonToggle.Value or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            for _, bone in ipairs(bones) do
                bone.Visible = false
            end
            return
        end

        local function updateBonePositions(bone, part1, part2)
            if not part1 or not part2 then return end
            local p1, vis1 = camera:WorldToViewportPoint(part1.Position)
            local p2, vis2 = camera:WorldToViewportPoint(part2.Position)
            
            if vis1 and vis2 then
                updateBone(bone, Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y))
                bone.Visible = true
            else
                bone.Visible = false
            end
        end

        updateBonePositions(bones[1], character:FindFirstChild("UpperTorso"), character:FindFirstChild("LowerTorso"))
        updateBonePositions(bones[2], character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm"))
        updateBonePositions(bones[3], character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand"))
        updateBonePositions(bones[4], character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm"))
        updateBonePositions(bones[5], character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand"))
        updateBonePositions(bones[6], character:FindFirstChild("LeftUpperLeg"), character:FindFirstChild("LeftLowerLeg"))
        updateBonePositions(bones[7], character:FindFirstChild("LeftLowerLeg"), character:FindFirstChild("LeftFoot"))
        updateBonePositions(bones[8], character:FindFirstChild("RightUpperLeg"), character:FindFirstChild("RightLowerLeg"))
        updateBonePositions(bones[9], character:FindFirstChild("RightLowerLeg"), character:FindFirstChild("RightFoot"))

        for _, bone in ipairs(bones) do
            bone.Color = ESP_COLOR
        end
    end

    skeletonConnections[player] = game:GetService("RunService").RenderStepped:Connect(updateSkeleton)
end

local function updateSkeleton(player, bones)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        for _, bone in ipairs(bones) do
            bone.Visible = false
        end
        return
    end

    local function updateBonePositions(bone, part1, part2)
        if not part1 or not part2 then return end
        local p1, vis1 = camera:WorldToViewportPoint(part1.Position)
        local p2, vis2 = camera:WorldToViewportPoint(part2.Position)
        
        if vis1 and vis2 then
            updateBone(bone, Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y))
            bone.Visible = true
        else
            bone.Visible = false
        end
    end

    -- Update bone positions (same as before)
    updateBonePositions(bones[1], player.Character:FindFirstChild("UpperTorso"), player.Character:FindFirstChild("LowerTorso"))
    -- ... (update other bones)

    for _, bone in ipairs(bones) do
        bone.Color = ESP_COLOR
    end
end


local function createBox(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP_COLOR
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false
    boxDrawings[player] = box
    return box
end


local function updateBox(player, box)
    if not player or not player.Parent or not ESPBoxToggle.Value or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        box.Visible = false
        return
    end

    local rootPart = player.Character.HumanoidRootPart
    local head = player.Character:FindFirstChild("Head")
    if not head then
        box.Visible = false
        return
    end

    local rootPos, rootVis = camera:WorldToViewportPoint(rootPart.Position)
    if not rootVis then
        box.Visible = false
        return
    end

    local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local legPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

    box.Size = Vector2.new(2350 / rootPos.Z, headPos.Y - legPos.Y)
    box.Position = Vector2.new(rootPos.X - box.Size.X / 2, rootPos.Y - box.Size.Y / 2)
    box.Color = ESP_COLOR
    box.Visible = true
end



local function removeSkeleton(player)
    if skeletonConnections[player] then
        skeletonConnections[player]:Disconnect()
        skeletonConnections[player] = nil
    end

    if skeletonDrawings[player] then
        for _, bone in ipairs(skeletonDrawings[player]) do
            bone:Remove()
        end
        skeletonDrawings[player] = nil
    end
end

local function removeBox(player)
    if boxDrawings[player] then
        boxDrawings[player]:Remove()
        boxDrawings[player] = nil
    end
end

local function playerAdded(player)
    player.CharacterAdded:Connect(function()
        createSkeleton(player)
        createBox(player)
    end)
    player.CharacterRemoving:Connect(function()
        removeSkeleton(player)
        removeBox(player)
    end)
    if player.Character then
        createSkeleton(player)
        createBox(player)
    end
end

local function playerRemoved(player)
    removeSkeleton(player)
    removeBox(player)
    if boxDrawings[player] then
        boxDrawings[player]:Remove()
        boxDrawings[player] = nil
    end
end


UIS.InputBegan:Connect(function(inp)
    if inp.UserInputType == AIMBOT_BIND and AIMBOT_ON then
        aiming = true
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == AIMBOT_BIND then
        aiming = false
    end
end)

function closestplayer()
    local closest = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= localplayer and player.Character and player.Character:FindFirstChild("Head") then
            local vector, onScreen = camera:WorldToScreenPoint(player.Character.Head.Position)
            if onScreen then
                local vectorDistance = (Vector2.new(vector.X, vector.Y) - screenCenter).Magnitude
                local playerDistance = (player.Character.Head.Position - localplayer.Character.Head.Position).Magnitude
                
                -- Combine both distances (you can adjust the weights if needed)
                local combinedDistance = (vectorDistance * 0.40) + (playerDistance * 0.60)
                
                if combinedDistance < shortestDistance and vectorDistance <= AIMBOT_FOV then
                    closest = player
                    shortestDistance = combinedDistance
                end
            end
        end
    end

    return closest
end


local function spinhoriz(deltaTime)
    if type(SPIN_SPEED) ~= "number" then
        warn("SPIN_SPEED is not a number. Setting to default value of 10.")
        SPIN_SPEED = 10
    end

    horizSpinAngle = horizSpinAngle + math.rad(SPIN_SPEED)
    
    local currentPosition = humanoidRootPart.Position
    local lookVector = humanoidRootPart.CFrame.LookVector
    
    local newCFrame = CFrame.new(currentPosition, currentPosition + lookVector) * CFrame.Angles(0, horizSpinAngle, 0)
    
    humanoidRootPart.CFrame = newCFrame
end

local function spinvert(deltaTime)
    originalY = humanoidRootPart.Position.Y

    if type(SPIN_SPEED) ~= "number" then
        warn("SPIN_SPEED is not a number. Setting to default value of 10.")
        SPIN_SPEED = 10
    end

    vertSpinAngle = vertSpinAngle + math.rad(SPIN_SPEED * deltaTime * 60) -- Frame rate independence
    
    local currentPosition = humanoidRootPart.Position
    local lookVector = humanoidRootPart.CFrame.LookVector
    
    -- Create rotation CFrame
    local rotationCF = CFrame.Angles(vertSpinAngle, 0, 0)
    
    -- Apply rotation while preserving original height
    local newCFrame = CFrame.new(currentPosition.X, originalY, currentPosition.Z) * rotationCF
    
    -- Preserve look direction
    newCFrame = newCFrame * CFrame.new(Vector3.new(0, 0, -1), lookVector)
    
    humanoidRootPart.CFrame = newCFrame
end

local function checkForBhop()
    if character then
        if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Running then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local highlightedCharacters = {}

local function updateHighlightColor(highlight)
    highlight.FillColor = ESP_COLOR
end

local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    updateHighlightColor(highlight)
    highlight.FillTransparency = 0
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Enabled = CHAMS_ON
    highlight.Parent = character
    
    highlightedCharacters[character] = highlight
end

local function removeHighlight(character)
    local highlight = highlightedCharacters[character]
    if highlight then
        highlight:Destroy()
        highlightedCharacters[character] = nil
    end
end

local function updateHighlights()
    for character, highlight in pairs(highlightedCharacters) do
        highlight.Enabled = CHAMS_ON
        updateHighlightColor(highlight)
    end
end

local function onPlayerAdded(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            createHighlight(character)
        end)
        player.CharacterRemoving:Connect(function(character)
            removeHighlight(character)
        end)
        if player.Character then
            createHighlight(player.Character)
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeHighlight(player.Character)
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

local connection
function fly(delta)
    if not character:IsDescendantOf(workspace) or not humanoid.Health > 0 then return end
    
    local moveDirection = Vector3.new()
    local cameraCFrame = workspace.CurrentCamera.CFrame
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + cameraCFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - cameraCFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - cameraCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + cameraCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end
    
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
    end
    
    rootPart.Velocity = moveDirection * flySpeed
end

-- FPS COUNTER

local ScreenGui = Instance.new("ScreenGui")
local TextLabel = Instance.new("TextLabel")

-- Set up the ScreenGui
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Set up the TextLabel
TextLabel.Parent = ScreenGui
TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BackgroundTransparency = 0.5
TextLabel.Position = UDim2.new(0, 10, 0, 10)
TextLabel.Size = UDim2.new(0, 100, 0, 20)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 14
TextLabel.TextXAlignment = Enum.TextXAlignment.Center

local frameCount = 0
local lastTime = tick()

RS.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    
    if currentTime - lastTime >= 1 then
        if FPS_ON then
            TextLabel.Text = tostring(frameCount) .. " FPS"
            TextLabel.Transparency = 0
            TextLabel.BackgroundTransparency = 0.5
        else
            TextLabel.Transparency = 1
        end
        frameCount = 0
        lastTime = currentTime
    end
end)

RS.Heartbeat:Connect(function()
    if tick() - lastIteration >= 0.1 then
        updateFPS()
        lastIteration = tick()
    end
end)

-- PING COUNTER

local pingGui = Instance.new("ScreenGui")
local pingLabel = Instance.new("TextLabel")

pingGui.Name = "PingDisplay"
pingGui.Parent = game.CoreGui

pingLabel.Name = "PingLabel"
pingLabel.Parent = pingGui
pingLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pingLabel.BackgroundTransparency = 0.5
pingLabel.Position = UDim2.new(0, 10, 1, -10)
pingLabel.Size = UDim2.new(0, 100, 0, 20)
pingLabel.Font = Enum.Font.SourceSans
pingLabel.Text = "inf ms"
pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pingLabel.TextSize = 14

local Stats = game:GetService("Stats")

game:GetService("RunService").RenderStepped:Connect(function()
    local ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    if PING_ON then
        pingLabel.Text = tostring(ping) .. " ms"
        pingLabel.Transparency = 0
        pingLabel.BackgroundTransparency = 0.5
    else
        pingLabel.Transparency = 1
    end
end)



local Window = OrionLib:MakeWindow({
    Name = "Aceware v" .. ACEWARE_VERSION,
    HidePremium = false,
    IntroEnabled = true,
    IntroText = "Loading Aceware... ( version " .. ACEWARE_VERSION .. " )",
    Icon = "rbxassetid://18540617874",
    IntroIcon = "rbxassetid://18540617874",
    CloseCallback = function()
        OrionLib:Destroy()
        if circle then
            circle:Remove()
        end
        AIMBOT_ON = false
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            removeSkeleton(player)
            removeBox(player)
        end
        TRIGGERBOT_ON = false
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
        BHOP_ON = false
        CHAMS_ON = false
        FLY_ON = false
        FPS_ON = false
        PING_ON = false
    end
})

local InfoTab = Window:MakeTab({
    Name = "Information"
})

local MarketplaceService = game:GetService("MarketplaceService")
local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local gameName = gameInfo.Name

InfoTab:AddParagraph("Version", ACEWARE_VERSION)
InfoTab:AddParagraph("Executor", identifyexecutor())
InfoTab:AddParagraph("Game", gameName)
InfoTab:AddParagraph("Game ID", game.placeId)
InfoTab:AddParagraph("Aceware Support Discord", "discord.gg/kMDWV94sTP")

local UITab = Window:MakeTab({
    Name = "UI"
})

local FPSCounterSection = UITab:AddSection({
    Name = "FPS Counter"
})

FPSCounterSection:AddToggle({
    Name = "FPS Counter",
    Default = true,
    Callback = function(Value)
        FPS_ON = Value
    end
})

FPSCounterSection:AddDropdown({
    Name = "Position",
    Default = "Top Left",
    Options = {"Top Left", "Bottom Left", "Top Right", "Bottom Right"},
    Callback = function(Value)
        if Value == "Top Left" then
            TextLabel.AnchorPoint = Vector2.new(0, 0)
            TextLabel.Position = UDim2.new(0, 10, 0, 10)
        end
        if Value == "Bottom Left" then
            TextLabel.AnchorPoint = Vector2.new(0, 1)
            TextLabel.Position = UDim2.new(0, 10, 1, -10)
        end
        if Value == "Top Right" then
            TextLabel.AnchorPoint = Vector2.new(1, 0)
            TextLabel.Position = UDim2.new(1, -10, 0, 10)
        end
        if Value == "Bottom Right" then
            TextLabel.AnchorPoint = Vector2.new(1, 1)
            TextLabel.Position = UDim2.new(1, -10, 1, -10)
        end
    end
})

local PingCounterSection = UITab:AddSection({
    Name = "Ping Counter"
})

PingCounterSection:AddToggle({
    Name = "Ping Counter",
    Default = true,
    Callback = function(Value)
        PING_ON = Value
    end
})

PingCounterSection:AddDropdown({
    Name = "Position",
    Default = "Bottom Left",
    Options = {"Top Left", "Bottom Left", "Top Right", "Bottom Right"},
    Callback = function(Value)
        if Value == "Top Left" then
            pingLabel.AnchorPoint = Vector2.new(0, 0)
            pingLabel.Position = UDim2.new(0, 10, 0, 10)
        end
        if Value == "Bottom Left" then
            pingLabel.AnchorPoint = Vector2.new(0, 1)
            pingLabel.Position = UDim2.new(0, 10, 1, -10)
        end
        if Value == "Top Right" then
            pingLabel.AnchorPoint = Vector2.new(1, 0)
            pingLabel.Position = UDim2.new(1, -10, 0, 10)
        end
        if Value == "Bottom Right" then
            pingLabel.AnchorPoint = Vector2.new(1, 1)
            pingLabel.Position = UDim2.new(1, -10, 1, -10)
        end
    end
})

local AimbotTab = Window:MakeTab({
    Name = "Aimbot"
})

local AimbotMain = AimbotTab:AddSection({
    Name = "Main"
})

local AimbotToggle = AimbotMain:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        AIMBOT_ON = Value
    end
})

AimbotMain:AddSlider({
    Name = "Smoothing",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(205, 125, 255),
    Increment = 1,
    ValueName = "Smoothness",
    Callback = function(Value)
        AIMBOT_SMOOTHING = Value / 100
    end
})

local AimbotFOVSection = AimbotTab:AddSection({
    Name = "FOV"
})

local FOVToggle = AimbotFOVSection:AddToggle({
    Name = "Show FOV",
    Default = false,
    Callback = function(Value)
        if Value then
            circle = Drawing.new("Circle")
            circle.Visible = true
            circle.Color = AIMBOT_FOV_COLOR
            circle.Thickness = 1
            circle.NumSides = 64
            circle.Radius = AIMBOT_FOV
            circle.Filled = false
            circle.Transparency = 1
        else
            if circle then
                circle:Remove()
                circle = nil
            end
        end
    end
})

AimbotFOVSection:AddSlider({
    Name = "FOV Radius",
    Min = 10,
    Max = 500,
    Default = 150,
    Color = Color3.fromRGB(205, 125, 255),
    Increment = 1,
    ValueName = "Radius",
    Callback = function(Value)
        AIMBOT_FOV = Value
        if circle then
            circle.Radius = Value
        end
    end
})

local AimbotColorSection = AimbotTab:AddSection({
    Name = "Color"
})

AimbotColorSection:AddColorpicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        AIMBOT_FOV_COLOR = Value
        if circle then
            circle.Color = Value
        end
    end
})

local ESPTab = Window:MakeTab({
    Name = "ESP"
})

local ESPMain = ESPTab:AddSection({
    Name = "Main"
})

local ESPBoxToggle = ESPMain:AddToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(Value)
        ESPBoxToggle.Value = Value
        for player, box in pairs(boxDrawings) do
            if player ~= localplayer then
                if Value then
                    updateBox(player, box)
                else
                    box.Visible = false
                end
            end
        end
    end
})




local ESPSkeletonToggle = ESPMain:AddToggle({
    Name = "Skeleton ESP",
    Default = false,
    Callback = function(Value)
        ESPSkeletonToggle.Value = Value
        if Value then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= localplayer then
                    createSkeleton(player)
                end
            end
            game:GetService("Players").PlayerAdded:Connect(playerAdded)
            game:GetService("Players").PlayerRemoving:Connect(playerRemoved)
        else
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                removeSkeleton(player)
            end
            for _, connection in pairs(skeletonConnections) do
                connection:Disconnect()
            end
            skeletonConnections = {}
        end
        
        -- Clear Box ESP frames when toggling Skeleton ESP
        if not ESPBoxToggle.Value then
            for _, box in pairs(boxDrawings) do
                box.Visible = false
            end
        end
    end
})

local ESPChams = ESPTab:AddSection({
    Name = "Chams"
})

ESPChams:AddToggle({
    Name = "Chams",
    Default = false,
    Callback = function(Value)
        CHAMS_ON = Value
        updateHighlights()
    end
})


local ESPColor = ESPTab:AddSection({
    Name = "Color"
})

ESPColor:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        ESP_COLOR = Value
        for _, bones in pairs(skeletonDrawings) do
            for _, bone in ipairs(bones) do
                bone.Color = Value
            end
        end
        for _, box in pairs(boxDrawings) do
            box.Color = Value
        end

        updateHighlights()
    end
})

local TriggerbotTab = Window:MakeTab({
    Name = "Triggerbot"
})

local TriggerbotToggle = TriggerbotTab:AddToggle({
    Name = "Triggerbot",
    Default = false,
    Callback = function(Value)
        TRIGGERBOT_ON = Value
    end
})

TriggerbotTab:AddSlider({
    Name = "Delay",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Color = Color3.fromRGB(205, 125, 255),
    Increment = 0.01,
    ValueName = "seconds",
    Callback = function(Value)
        TRIGGERBOT_DELAY = Value
    end
})

TriggerbotTab:AddParagraph("Notice", "Aceware triggerbot is currently extremely buggy. On Solara, you need to click again after the triggerbot fires or it will continue to fire.")

local MoveTab = Window:MakeTab({
    Name = "Movement"
})

local FlySection = MoveTab:AddSection({
    Name = "Fly"
})

FlySection:AddToggle({
    Name = "Swim Fly",
    Callback = function(Value)
        FLY_ON = Value
        if FLY_ON then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            
            connection = RunService.Heartbeat:Connect(fly)
        else
            if connection then
                connection:Disconnect()
            end
            
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
})

local SpinbotSection = MoveTab:AddSection({
    Name = "Spinbot"
})

SpinbotSection:AddToggle({
    Name = "Horizontal Spinbot",
    Default = false,
    Callback = function(Value)
        if Value then
            if not horizSpinConnection then
                horizSpinConnection = game:GetService("RunService").Heartbeat:Connect(spinhoriz)
            end
        else
            if horizSpinConnection then
                horizSpinConnection:Disconnect()
                horizSpinConnection = nil
            end
            horizSpinAngle = 0
        end
    end
})

SpinbotSection:AddToggle({
    Name = "Vertical Spinbot",
    Default = false,
    Callback = function(Value)
        if Value then
            if not vertSpinConnection then
                vertSpinConnection = game:GetService("RunService").Heartbeat:Connect(spinvert)
            end
        else
            if vertSpinConnection then
                vertSpinConnection:Disconnect()
                vertSpinConnection = nil
            end
            vertSpinAngle = 0
        end
    end
})

SpinbotSection:AddSlider({
    Name = "Spin Speed",
    Min = 0,
    Max = 50,
    Default = 10,
    Color = Color3.fromRGB(205, 125, 255),
    Increment = 1,
    Callback = function(Value)
        SPINBOT_SPEED = Value
    end
})

local BhopSection = MoveTab:AddSection({
    Name = "Bunny Hop"
})

BhopSection:AddToggle({
    Name = "Bunny Hop",
    Default = false,
    Callback = function(Value)
        if Value == true then
            BHOP_ON = true
        else
            BHOP_ON = false
        end
    end
})


local MiscTab = Window:MakeTab({
    Name = "Miscellaneous"
})

local BypassSection = MiscTab:AddSection({
    Name = "Filter Bypass"
})

local function bypassString(inputText)
    local normalChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz"
    local stylizedChars = "🅰🅱🅲🅳🅴🅵🅶🅷🅸🅹🅺🅻🅼🅽🅾🅿🆀🆁🆂🆃🆄🆅🆆🆇🆈🆉 🅰🅱🅲🅳🅴🅵🅶🅷🅸🅹🅺🅻🅼🅽🅾🅿🆀🆁🆂🆃🆄🆅🆆🆇🆈🆉"
    
    local result = ""
    
    for i = 1, #inputText do
        local char = inputText:sub(i, i)
        local index = normalChars:find(char, 1, true)
        
        if index then
            result = result .. stylizedChars:sub(index, index)
        else
            result = result .. char
        end
    end
    
    return result
end

BypassSection:AddTextbox({
    Name = "Text",
    TextDisappear = true,
    Callback = function(Value)
        local bypassed = bypassString(Value)
        
        if setclipboard then
            setclipboard(bypassed);
        else
            OrionLib:MakeNotification({
                Name = "Failed",
                Content = "Copying to clipboard is not supported by " .. identifyexecutor(),
                Image = "rbxassetid://18540617874",
                Time = 5
            })
        end

        OrionLib:MakeNotification({
            Name = "Copied",
            Content = "Bypassed text copied to clipboard!",
            Image = "rbxassetid://18540617874",
            Time = 5
        })
    end      
})

BypassSection:AddParagraph("Notice", "If it is not copying to clipboard, your executor does not support it. An alternative will be added in the future.")

local ChatLogSection = MiscTab:AddSection({
    Name = "Chat Logger"
})

ChatLogSection:AddButton({
    Name = "Start Logger",
    Callback = function()
        local LogFile = "ChatLog_" .. os.date("%Y-%m-%d") .. ".txt"

        local function LogChat(player, message)
            local timestamp = os.date("%H:%M:%S")
            local logMessage = string.format("[%s] %s: %s\n", timestamp, player.Name, message)
            appendfile(LogFile, logMessage)
        end

        for _, player in ipairs(Players:GetPlayers()) do
            player.Chatted:Connect(function(message)
                LogChat(player, message)
            end)
        end

        Players.PlayerAdded:Connect(function(player)
            player.Chatted:Connect(function(message)
                LogChat(player, message)
            end)
        end)

        OrionLib:MakeNotification({
            Name = "Started logger",
            Content = "Chat logger started. Logs will save to " .. LogFile,
            Image = "rbxassetid://18540617874",
            Time = 5
        })
    end
})

local CreditsTab = Window:MakeTab({
    Name = "Credits"
})

CreditsTab:AddLabel("Aceware Credits")
CreditsTab:AddParagraph("Main Programmer", "Lilaf / AbstractFlags")
CreditsTab:AddParagraph("Skeleton ESP Programmer", "Yazz")
CreditsTab:AddParagraph("UI Library", "Orion Library")
CreditsTab:AddParagraph("UI Library Creator", "Shlexware")

OrionLib:Init()

game:GetService("RunService").RenderStepped:Connect(function()
    if circle and circle.Visible then
        circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end
    
    for player, box in pairs(boxDrawings) do
        if player and player.Parent and player ~= localplayer then
            if ESPBoxToggle.Value then
                updateBox(player, box)
            else
                box.Visible = false
            end
        else
            box.Visible = false
            boxDrawings[player] = nil
        end
    end

    -- Update Skeleton ESP here if needed
    if ESPSkeletonToggle.Value then
        for player, bones in pairs(skeletonDrawings) do
            if player and player.Parent and player ~= localplayer then
                updateSkeleton(player, bones)
            else
                for _, bone in ipairs(bones) do
                    bone.Visible = false
                end
                skeletonDrawings[player] = nil
            end
        end
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if AIMBOT_ON and aiming then
        local target = closestplayer()
        if target then
            local targetPos = target.Character.Head.Position
            local cameraPos = camera.CFrame.Position
            local newCFrame = CFrame.new(cameraPos, targetPos)
            
            local smoothFactor = 1 - AIMBOT_SMOOTHING
            camera.CFrame = camera.CFrame:Lerp(newCFrame, smoothFactor)
        end
    end

    if TRIGGERBOT_ON then
        local mouse = game.Players.LocalPlayer:GetMouse()
        local target = mouse.target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
            local player = game.Players:GetPlayerFromCharacter(target.Parent)
            if player and player ~= localplayer then
                wait(TRIGGERBOT_DELAY)
                mouse1click();
            end
        end
    end

    if BHOP_ON then
        checkForBhop()
    end
end)

for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    if player ~= localplayer then
        playerAdded(player)
    end
end



game:GetService("Players").PlayerAdded:Connect(playerAdded)
game:GetService("Players").PlayerRemoving:Connect(playerRemoved)

OrionLib:MakeNotification({
    Name = "Welcome to Aceware! [ v" .. ACEWARE_VERSION .. " ]",
    Content = "Join our Discord! [ .gg/kMDWV94sTP ]",
    Image = "rbxassetid://18540617874",
    Time = 5
})

print("Loaded Aceware!")
