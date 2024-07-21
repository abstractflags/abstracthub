-- INITIALIZE VERSION NUMBERS

print("Loading Aceware...")

local ACEWARE_VERSION_NUMBER = "1.0.0"
local ACEWARE_VERSION_VNUM = "v" .. ACEWARE_VERSION_NUMBER
local ACEWARE_VERSION_LONG = "version " .. ACEWARE_VERSION_NUMBER

print("ACEWARE_VERSION_NUMBER: " .. ACEWARE_VERSION_NUMBER)
print("ACEWARE_VERSION_VNUM:   " .. ACEWARE_VERSION_VNUM)
print("ACEWARE_VERSION_LONG:   " .. ACEWARE_VERSION_LONG)

-- INITIALIZE SERVICES AND LIBRARIES

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- INITIALIZE VARIABLES
    -- NAMING CONVENTION
        -- ALL_CAPITAL = Changeable Setting
        -- TitleCase   = Non-Changeable Setting
        -- camelCase   = Non-Setting

     -- GENERAL VARIABLES
    local camera = game.Workspace.CurrentCamera
    local localPlayer = Players.LocalPlayer
    local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    local gameName = gameInfo.Name
    local humanoid = localPlayer.Character:WaitForChild("Humanoid")
    local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")

     -- AIMBOT VARIABLES
    local AIMBOT_ON = false
    local AIMBOT_FOV = 150
    local AIMBOT_SMOOTHING = 50
    local AIMBOT_FOV_COLOR = Color3.fromRGB(255, 255, 255)
    local AimbotBind = Enum.UserInputType.MouseButton2
    local aiming = false
    local target = nil
    local fovCircle = nil

    -- ESP VARIABLES
    local BOX_ESP_COLOR = Color3.fromRGB(255, 255, 255)
    local SKELETON_ESP_COLOR = Color3.fromRGB(255, 255, 255)
    local CHAMS_COLOR = Color3.fromRGB(255, 255, 255)
    local ESPBoxToggle = {Value = false}
    local ESPSkeletonToggle = {Value = false}
    local CHAMS_ON = false
    local skeletonConnections = {}
    local skeletonDrawings = {}
    local boxDrawings = {}
    local highlightedCharacters = {}

    -- FLIGHT VARIABLES
    local SFLY_ON = false

    -- SPINBOT VARIABLES
    local horizSpinConnection
    local horizSpinAngle = 0

    local vertSpinConnection
    local vertSpinAngle = 0
    local originalY = humanoidRootPart.Position.Y
    
    -- BHOP VARIABLES
    local BHOP_ON = false

    -- RAGDOLL VARIABLES
    local RAGDOLL_ON = false

-- INITIALIZE FUNCTIONS

function getClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = camera:WorldToScreenPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance and distance <= AIMBOT_FOV then
                    closest = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closest
end

 local function createBone()
        local bone = Drawing.new("Line")
        bone.Visible = false
        bone.Color = SKELETON_ESP_COLOR
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
        createBone(), -- Head to UpperTorso
        createBone(), -- UpperTorso to LowerTorso
        createBone(), -- UpperTorso to LeftUpperArm
        createBone(), -- LeftUpperArm to LeftLowerArm
        createBone(), -- LeftLowerArm to LeftHand
        createBone(), -- UpperTorso to RightUpperArm
        createBone(), -- RightUpperArm to RightLowerArm
        createBone(), -- RightLowerArm to RightHand
        createBone(), -- LowerTorso to LeftUpperLeg
        createBone(), -- LeftUpperLeg to LeftLowerLeg
        createBone(), -- LeftLowerLeg to LeftFoot
        createBone(), -- LowerTorso to RightUpperLeg
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

        updateBonePositions(bones[1], character:FindFirstChild("Head"), character:FindFirstChild("UpperTorso"))
        updateBonePositions(bones[2], character:FindFirstChild("UpperTorso"), character:FindFirstChild("LowerTorso"))
        updateBonePositions(bones[3], character:FindFirstChild("UpperTorso"), character:FindFirstChild("LeftUpperArm"))
        updateBonePositions(bones[4], character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm"))
        updateBonePositions(bones[5], character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand"))
        updateBonePositions(bones[6], character:FindFirstChild("UpperTorso"), character:FindFirstChild("RightUpperArm"))
        updateBonePositions(bones[7], character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm"))
        updateBonePositions(bones[8], character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand"))
        updateBonePositions(bones[9], character:FindFirstChild("LowerTorso"), character:FindFirstChild("LeftUpperLeg"))
        updateBonePositions(bones[10], character:FindFirstChild("LeftUpperLeg"), character:FindFirstChild("LeftLowerLeg"))
        updateBonePositions(bones[11], character:FindFirstChild("LeftLowerLeg"), character:FindFirstChild("LeftFoot"))
        updateBonePositions(bones[12], character:FindFirstChild("LowerTorso"), character:FindFirstChild("RightUpperLeg"))
        updateBonePositions(bones[13], character:FindFirstChild("RightUpperLeg"), character:FindFirstChild("RightLowerLeg"))
        updateBonePositions(bones[14], character:FindFirstChild("RightLowerLeg"), character:FindFirstChild("RightFoot"))

        for _, bone in ipairs(bones) do
            bone.Color = ESP_COLOR
        end
    end

    skeletonConnections[player] = game:GetService("RunService").RenderStepped:Connect(updateSkeleton)
end


    local function createBox(player)
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = BOX_ESP_COLOR
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
        box.Color = BOX_ESP_COLOR
        box.Visible = true
    end

    local function createHighlight(character)
        local highlight = Instance.new("Highlight")
        highlight.FillColor = CHAMS_COLOR
        highlight.FillTransparency = 0
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Enabled = CHAMS_ON
        highlight.Parent = character
        highlightedCharacters[character] = highlight
    end

    local function updateHighlights()
        for character, highlight in pairs(highlightedCharacters) do
            highlight.Enabled = CHAMS_ON
            highlight.FillColor = CHAMS_COLOR
        end
    end

    local function onPlayerAdded(player)
        if player ~= localPlayer then
            player.CharacterAdded:Connect(function(character)
                createSkeleton(player)
                createBox(player)
                createHighlight(character)
            end)
            if player.Character then
                createSkeleton(player)
                createBox(player)
                createHighlight(player.Character)
            end
        end
    end

    local function onPlayerRemoving(player)
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
        if boxDrawings[player] then
            boxDrawings[player]:Remove()
            boxDrawings[player] = nil
        end
        if player.Character then
            local highlight = highlightedCharacters[player.Character]
            if highlight then
                highlight:Destroy()
                highlightedCharacters[player.Character] = nil
            end
        end
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
        if localPlayer.Character then
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Running then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end

    local connection
    function fly(delta)
        if not localPlayer.Character:IsDescendantOf(workspace) or not humanoid.Health > 0 then return end
        
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
        
        humanoidRootPart.Velocity = moveDirection * 50
    end

-- INITIALIZE RAYFIELD

local Window = Rayfield:CreateWindow({
    Name = "Aceware " .. ACEWARE_VERSION_VNUM,
    LoadingTitle = "Aceware",
    LoadingSubtitle = ACEWARE_VERSION_LONG
})

-- TABS

local TabInfo = Window:CreateTab("Information", 7733964719)
local TabAimbot = Window:CreateTab("Aimbot", 7733765307)
local TabESP = Window:CreateTab("ESP", 7733774602)
local TabMovement = Window:CreateTab("Movement", 7743870731)
local TabMisc = Window:CreateTab("Miscellaneous", 7733954760)

-- ELEMENTS

     -- INFO ELEMENTS
    TabInfo:CreateParagraph({Title = "Version", Content = ACEWARE_VERSION_NUMBER})
    TabInfo:CreateParagraph({Title = "Executor", Content = identifyexecutor()})
    TabInfo:CreateParagraph({Title = "Game", Content = gameName})
    TabInfo:CreateParagraph({Title = "Game ID", Content = game.placeId})
    TabInfo:CreateParagraph({Title = "Aceware Discord", Content = "discord.gg/kMDWV94sTP"})

    -- AIMBOT ELEMENTS
    TabAimbot:CreateSection("Main")
    TabAimbot:CreateToggle({
        Name = "Aimbot Enabled",
        CurrentValue = false,
        Callback = function(Value)
            AIMBOT_ON = Value
        end
    })

    TabAimbot:CreateSlider({
        Name = "FOV Radius",
        Range = {10, 500},
        Increment = 1,
        Suffix = "px",
        CurrentValue = 150,
        Callback = function(Value)
            AIMBOT_FOV = Value
        end,
    })

    TabAimbot:CreateSlider({
        Name = "Smoothing",
        Range = {0, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 50,
        Callback = function(Value)
            AIMBOT_SMOOTHING = Value
        end,
    })

    TabAimbot:CreateSection("Appearance")    

    TabAimbot:CreateToggle({
        Name = "Show FOV",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                fovCircle = Drawing.new("Circle")
                fovCircle.Visible = true
                fovCircle.Color = AIMBOT_FOV_COLOR
                fovCircle.Thickness = 1
                fovCircle.NumSides = 64
                fovCircle.Radius = AIMBOT_FOV
                fovCircle.Filled = false
                fovCircle.Transparency = 1
            else
                if fovCircle then
                    fovCircle:Remove()
                    fovCircle = nil
                end
            end
        end
    })

    TabAimbot:CreateColorPicker({
        Name = "FOV Circle Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            AIMBOT_FOV_COLOR = Value
        end
    })

    -- ESP ELEMENTS
    TabESP:CreateSection("Box ESP")
    TabESP:CreateToggle({
        Name = "Box ESP Enabled",
        CurrentValue = false,
        Callback = function(Value)
            ESPBoxToggle.Value = Value
        end
    })
    TabESP:CreateColorPicker({
        Name = "Box ESP Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            BOX_ESP_COLOR = Value
        end
    })

    TabESP:CreateSection("Skeleton ESP")
    TabESP:CreateToggle({
        Name = "Skeleton ESP Enabled",
        CurrentValue = false,
        Callback = function(Value)
            ESPSkeletonToggle.Value = Value
        end
    })
    TabESP:CreateColorPicker({
        Name = "Skeleton ESP Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            SKELETON_ESP_COLOR = Value
        end
    })

    TabESP:CreateSection("Chams")
    TabESP:CreateToggle({
        Name = "Chams Enabled",
        CurrentValue = false,
        Callback = function(Value)
            CHAMS_ON = Value
            updateHighlights()
        end
    })
    TabESP:CreateColorPicker({
        Name = "Chams Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            CHAMS_COLOR = Value
            updateHighlights()
        end
    })

    -- MOVEMENT ELEMENTS
    TabMovement:CreateSection("Flight")
    TabMovement:CreateToggle({
        Name = "Swim Fly",
        CurrentValue = false,
        Callback = function(Value)
            SFLY_ON = Value
            if SFLY_ON then
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
    

    TabMovement:CreateSection("Spinbot")
    TabMovement:CreateToggle({
        Name = "Horizontal Spinbot",
        CurrentValue = false,
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
    TabMovement:CreateToggle({
        Name = "Vertical Spinbot",
        CurrentValue = false,
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

    TabMovement:CreateSection("BHop")

    TabMovement:CreateToggle({
        Name = "BHop Enabled",
        CurrentValue = false,
        Callback = function(Value)
            BHOP_ON = Value
        end
    })

    -- MISC ELEMENTS
    TabMisc:CreateSection("Ragdoll")
    TabMisc:CreateToggle({
        Name = "Ragdoll",
        CurrentValue = false,
        Callback = function(Value)
            RAGDOLL_ON = Value
            if RAGDOLL_ON then
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
                humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
            else
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

    TabMisc:CreateSection("Chat Logger")
    TabMisc:CreateButton({
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

        Rayfield:Notify({
            Title = "Chat Logger Started",
            Content = "Log will be saved to " .. LogFile,
            Duration = 5,
            Image = 18540617874,
            Actions = {
                Ignore = {
                    Name = "Close",
                }
            }
        })
    end
})

-- CONNECT FUNCTIONS TO SERVICES

local inputBeganConnection
local inputEndedConnection
local renderSteppedConnection

local function setupConnections()
    inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == AimbotBind then
            aiming = true
        end
    end)

    inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == AimbotBind then
            aiming = false
        end
    end)

    renderSteppedConnection = RunService.RenderStepped:Connect(function()
        if AIMBOT_ON and aiming then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local targetPos = target.Character.Head.Position
                local cameraPos = camera.CFrame.Position
                local newCFrame = CFrame.new(cameraPos, targetPos)
                
                local smoothFactor = math.clamp(1 - (AIMBOT_SMOOTHING / 100), 0.01, 1)
                camera.CFrame = camera.CFrame:Lerp(newCFrame, smoothFactor)
            end
        end

        if fovCircle and fovCircle.Visible then
            fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            fovCircle.Radius = AIMBOT_FOV
            fovCircle.Color = AIMBOT_FOV_COLOR            
        end

        if BHOP_ON then
            checkForBhop()
        end
    end)
end

-- ESP Connections
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    RunService.RenderStepped:Connect(function()
        for player, box in pairs(boxDrawings) do
            updateBox(player, box)
        end
    end)

setupConnections()

-- FINISH LOADING
print("Aceware " .. ACEWARE_VERSION_VNUM .. " loaded!")

Rayfield:Notify({
    Title = "Welcome to Aceware! [ " .. ACEWARE_VERSION_VNUM .. " ]",
    Content = "Join our Discord! [ .gg/kMDWV94sTP ]",
    Duration = 5,
    Image = 18540617874,
    Actions = {
        Ignore = {
            Name = "Close",
        }
    }
})
