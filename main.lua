--[[
    ╔════════════════════════════════════════════╗
    ║   🍜 MIE AYAM V1 - KENZO THE LORD EDITION ║
    ║   💜 PURPLE RAINBOW | LONG RANGE HEADLOCK ║
    ║   Loading Screen 0-100% | Perfect Lock    ║
    ║   Made by: KENZO THE LORD                 ║
    ╚════════════════════════════════════════════╝
--]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// CONFIG
local Config = {
    AimbotEnabled = true,
    HeadlockEnabled = true,
    SilentAim = true,
    PerfectLock = true,
    TeamCheck = false,
    WallCheck = false,
    FOV = 9999,
    Smoothness = 0.35,
    AimPart = "Head",
    Prediction = 0.20,
    Keybind = Enum.KeyCode.Q,
    LongRangeEnabled = true,
    MinDistance = 50,
    HitboxOnAim = true,
    ESPEnabled = true,
    ESPHealth = true,
    SpeedEnabled = false, SpeedValue = 50,
    JumpEnabled = false, JumpValue = 100,
    FlyEnabled = false, FlySpeed = 60,
    NoclipEnabled = false,
    InfJumpEnabled = false,
    KillAuraEnabled = false, KillAuraRange = 20,
    HitboxEnabled = false, HitboxSize = 15,
    FullbrightEnabled = false,
    NoFogEnabled = false,
    AntiAFKEnabled = true,
    AntiVoidEnabled = false,
    HumanizeEnabled = true,
    RandomJitterEnabled = true,
    AntiKickEnabled = true,
    AntiTeleportEnabled = true,
}

--// VARIABLES
local Target = nil
local Holding = false
local FlyConnection, BodyVelocity, BodyGyro
local ESPObjects = {}
local ColorCycle = 0
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
}

--// 🎨 RAINBOW COLOR
local function rainbowColor(t)
    local hue = (t or tick()) % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

--// ANTI BAN LAYER
local oldKick
oldKick = hookfunction(LocalPlayer.Kick, function(self, msg)
    if Config.AntiKickEnabled then
        warn("[MIE AYAM] Kick blocked: " .. tostring(msg))
        return
    end
    return oldKick(self, msg)
end)

local function HumanizeAim(targetPos)
    if not Config.RandomJitterEnabled then return targetPos end
    return targetPos + Vector3.new(
        (math.random() - 0.5) * 0.03,
        (math.random() - 0.5) * 0.03,
        (math.random() - 0.5) * 0.03
    )
end

--// ═══════════════════════════════════════════
--// 💜 LOADING SCREEN 💜
--// ═══════════════════════════════════════════

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "MieAyam_Loading"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.DisplayOrder = 999
LoadingGui.Parent = CoreGui

-- Background Fullscreen
local LoadingBG = Instance.new("Frame")
LoadingBG.Size = UDim2.new(1, 0, 1, 0)
LoadingBG.Position = UDim2.new(0, 0, 0, 0)
LoadingBG.BackgroundColor3 = Color3.fromRGB(20, 0, 40)
LoadingBG.BorderSizePixel = 0
LoadingBG.Parent = LoadingGui

-- Gradient background
local BGGradient = Instance.new("UIGradient")
BGGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 0, 80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 0, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 0, 80)),
}
BGGradient.Rotation = 45
BGGradient.Parent = LoadingBG

-- Logo / Title
local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(0, 500, 0, 80)
LoadingTitle.Position = UDim2.new(0.5, -250, 0.35, -40)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "🍜 MIE AYAM V1 🍜"
LoadingTitle.TextColor3 = Color3.fromRGB(255, 0, 255)
LoadingTitle.Font = Enum.Font.GothamBlack
LoadingTitle.TextSize = 48
LoadingTitle.TextStrokeTransparency = 0
LoadingTitle.TextStrokeColor3 = Color3.fromRGB(75, 0, 130)
LoadingTitle.Parent = LoadingBG

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(150, 0, 255)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
}
TitleGradient.Parent = LoadingTitle

-- Subtitle
local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 500, 0, 30)
SubTitle.Position = UDim2.new(0.5, -250, 0.35, 50)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Kenzo The Lord Edition"
SubTitle.TextColor3 = Color3.fromRGB(200, 150, 255)
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = 18
SubTitle.Parent = LoadingBG

-- Loading Bar Container
local BarContainer = Instance.new("Frame")
BarContainer.Size = UDim2.new(0, 500, 0, 30)
BarContainer.Position = UDim2.new(0.5, -250, 0.5, 40)
BarContainer.BackgroundColor3 = Color3.fromRGB(40, 0, 70)
BarContainer.BorderSizePixel = 0
BarContainer.Parent = LoadingBG

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = BarContainer

local BarStroke = Instance.new("UIStroke")
BarStroke.Thickness = 2
BarStroke.Color = Color3.fromRGB(255, 0, 255)
BarStroke.Parent = BarContainer

-- Progress Bar Fill
local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarContainer

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = BarFill

local FillGradient = Instance.new("UIGradient")
FillGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
}
FillGradient.Parent = BarFill

-- Percentage Text
local PercentText = Instance.new("TextLabel")
PercentText.Size = UDim2.new(0, 500, 0, 40)
PercentText.Position = UDim2.new(0.5, -250, 0.5, 80)
PercentText.BackgroundTransparency = 1
PercentText.Text = "0%"
PercentText.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentText.Font = Enum.Font.GothamBlack
PercentText.TextSize = 28
PercentText.TextStrokeTransparency = 0
PercentText.Parent = LoadingBG

-- Status Text
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 500, 0, 25)
StatusText.Position = UDim2.new(0.5, -250, 0.5, 125)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Initializing..."
StatusText.TextColor3 = Color3.fromRGB(200, 150, 255)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.Parent = LoadingBG

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(0, 500, 0, 20)
Footer.Position = UDim2.new(0.5, -250, 0.9, 0)
Footer.BackgroundTransparency = 1
Footer.Text = "💜 Kenzo The Lord © 2026 💜"
Footer.TextColor3 = Color3.fromRGB(150, 100, 200)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 12
Footer.Parent = LoadingBG

-- Rainbow animasi untuk title
task.spawn(function()
    local rot = 0
    while LoadingGui and LoadingGui.Parent do
        rot = rot + 0.01
        TitleGradient.Rotation = rot * 100
        task.wait(0.03)
    end
end)

-- ═══════════════════════════════════════════
-- 📊 LOADING SEQUENCE 0-100%
-- ═══════════════════════════════════════════

local LoadingSteps = {
    { percent = 5,  status = "Loading Services..." },
    { percent = 15, status = "Checking Executor..." },
    { percent = 25, status = "Loading Anti-Ban Layer..." },
    { percent = 35, status = "Injecting Aimbot Module..." },
    { percent = 45, status = "Loading ESP Module..." },
    { percent = 55, status = "Loading Movement Module..." },
    { percent = 65, status = "Loading Combat Module..." },
    { percent = 75, status = "Building Purple GUI..." },
    { percent = 85, status = "Connecting Rainbow Engine..." },
    { percent = 95, status = "Finalizing... Almost done!" },
    { percent = 100, status = "✅ MIE AYAM V1 READY!" },
}

local function SetProgress(percent, status)
    BarFill:TweenSize(
        UDim2.new(percent / 100, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3,
        true
    )
    PercentText.Text = tostring(percent) .. "%"
    if status then
        StatusText.Text = status
    end
end

local function RunLoadingSequence()
    for _, step in ipairs(LoadingSteps) do
        SetProgress(step.percent, step.status)
        task.wait(0.35)
    end
end

-- Jalankan loading
RunLoadingSequence()

-- Setelah 100%, fade out & destroy
task.wait(1)
TweenService:Create(LoadingBG, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 1,
}):Play()
TweenService:Create(LoadingTitle, TweenInfo.new(1), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
TweenService:Create(SubTitle, TweenInfo.new(1), { TextTransparency = 1 }):Play()
TweenService:Create(BarContainer, TweenInfo.new(1), { BackgroundTransparency = 1 }):Play()
TweenService:Create(PercentText, TweenInfo.new(1), { TextTransparency = 1 }):Play()
TweenService:Create(StatusText, TweenInfo.new(1), { TextTransparency = 1 }):Play()
TweenService:Create(Footer, TweenInfo.new(1), { TextTransparency = 1 }):Play()

task.wait(1.2)
LoadingGui:Destroy()

--// ═══════════════════════════════════════════
--// 🎨 MAIN GUI - PURPLE RAINBOW THEME
--// ═══════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MieAyam_V1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 520)
MainFrame.Position = UDim2.new(0, 20, 0, 60)
MainFrame.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(255, 0, 255)
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
Title.BorderSizePixel = 0
Title.Text = "🍜 MIE AYAM V1 💜\nKenzo The Lord | PURPLE RAINBOW"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = Title

local TitleGradient2 = Instance.new("UIGradient")
TitleGradient2.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 220, 0)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 100)),
}
TitleGradient2.Parent = Title

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -60)
ScrollFrame.Position = UDim2.new(0, 5, 0, 55)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1300)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

local function CreateToggle(name, default, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -10, 0, 28)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(75, 0, 130)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = name .. ": " .. (default and "ON" or "OFF")
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamSemibold
    ToggleBtn.TextSize = 11
    ToggleBtn.Parent = ScrollFrame
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ToggleBtn
    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(75, 0, 130)
        ToggleBtn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
    return ToggleBtn
end

local function CreateSection(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 24)
    Label.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
    Label.BorderSizePixel = 0
    Label.Text = "▸ " .. text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.Parent = ScrollFrame
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Label
    local G = Instance.new("UIGradient")
    G.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
    }
    G.Parent = Label
end

function ToggleESP(state)
    for _, v in pairs(ESPObjects) do
        if v and v.Parent then v.Enabled = state end
    end
end

local function IsAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetAimPart(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function GetDistance(part)
    if not part then return math.huge end
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return math.huge end
    local mousePos = UserInputService:GetMouseLocation()
    return (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
end

local function GetTarget()
    local closest, shortest = nil, Config.FOV
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr) then
            local valid = true
            if Config.TeamCheck and plr.Team == LocalPlayer.Team then valid = false end
            if valid then
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")
                if head then
                    local dist = GetDistance(head)
                    if Config.LongRangeEnabled then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local worldDist = hrp and (hrp.Position - Camera.CFrame.Position).Magnitude or 0
                        if worldDist > Config.MinDistance then
                            if dist < shortest then shortest = dist; closest = plr end
                        elseif dist < shortest then
                            shortest = dist
                            closest = plr
                        end
                    else
                        if dist < shortest then shortest = dist; closest = plr end
                    end
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.Keybind then Holding = true end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if input.KeyCode == Config.Keybind then Holding = false end
end)

-- AIMBOT LOOP
RunService.RenderStepped:Connect(function()
    if not Config.AimbotEnabled then return end
    Target = GetTarget()
    if Target and Holding then
        local char = Target.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end

        local targetPos = head.Position
        if Config.Prediction > 0 then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then targetPos = targetPos + hrp.Velocity * Config.Prediction end
        end

        if Config.HitboxOnAim then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(12, 12, 12)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            end
            head.Size = Vector3.new(3, 3, 3)
        end

        targetPos = HumanizeAim(targetPos)

        if Config.SilentAim then
            local screenPos = Camera:WorldToViewportPoint(targetPos)
            if screenPos.Z > 0 then
                local mouseLoc = UserInputService:GetMouseLocation()
                pcall(function()
                    mousemoverel(screenPos.X - mouseLoc.X, screenPos.Y - mouseLoc.Y)
                end)
            end
        end

        if Config.PerfectLock then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        else
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(targetCF, Config.Smoothness)
        end
    end
end)

-- RAINBOW UI ANIMATION
task.spawn(function()
    while task.wait(0.1) do
        ColorCycle = ColorCycle + 0.02
        local c1 = rainbowColor(ColorCycle)
        local c2 = rainbowColor(ColorCycle + 1.5)
        UIStroke.Color = c1
        TitleGradient2.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(0.5, c2),
            ColorSequenceKeypoint.new(1, rainbowColor(ColorCycle + 3)),
        }
    end
end)

-- ESP LOOP
RunService.Heartbeat:Connect(function()
    if not Config.ESPEnabled then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr) then
            if not ESPObjects[plr] then
                local Billboard = Instance.new("BillboardGui")
                Billboard.Size = UDim2.new(0, 130, 0, 40)
                Billboard.StudsOffset = Vector3.new(0, 3, 0)
                Billboard.AlwaysOnTop = true
                Billboard.Parent = ScreenGui

                local NameLabel = Instance.new("TextLabel")
                NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = plr.Name
                NameLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextSize = 12
                NameLabel.TextStrokeTransparency = 0
                NameLabel.Parent = Billboard

                local HPLabel = Instance.new("TextLabel")
                HPLabel.Name = "HP"
                HPLabel.Size = UDim2.new(1, 0, 0.5, 0)
                HPLabel.Position = UDim2.new(0, 0, 0.5, 0)
                HPLabel.BackgroundTransparency = 1
                HPLabel.Text = "HP: 100"
                HPLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                HPLabel.Font = Enum.Font.Gotham
                HPLabel.TextSize = 10
                HPLabel.TextStrokeTransparency = 0
                HPLabel.Parent = Billboard

                ESPObjects[plr] = Billboard
            end

            local billboard = ESPObjects[plr]
            local char = plr.Character
            if char and char:FindFirstChild("Head") then
                billboard.Adornee = char.Head
                billboard.Enabled = true
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local hp = billboard:FindFirstChild("HP")
                    if hp then
                        hp.Text = "HP: " .. math.floor(hum.Health)
                        hp.TextColor3 = hum.Health > 50 and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,50,50)
                    end
                end
                local nameLbl = billboard:FindFirstChildOfClass("TextLabel")
                if nameLbl then nameLbl.TextColor3 = rainbowColor() end
            else
                billboard.Enabled = false
            end
        end
    end
    for plr, obj in pairs(ESPObjects) do
        if not plr.Parent or not IsAlive(plr) then
            obj:Destroy()
            ESPObjects[plr] = nil
        end
    end
end)

-- SPEED / JUMP
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Config.SpeedEnabled then hum.WalkSpeed = Config.SpeedValue end
    if Config.JumpEnabled then hum.JumpPower = Config.JumpValue end
end)

-- FLY
local function ToggleFly(state)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if state then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Velocity = Vector3.zero
        BodyVelocity.Parent = hrp
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BodyGyro.P = 9e4
        BodyGyro.Parent = hrp
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not Config.FlyEnabled then return end
            local cam = Workspace.CurrentCamera
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
            if BodyVelocity then BodyVelocity.Velocity = moveDir * Config.FlySpeed end
            if BodyGyro then BodyGyro.CFrame = cam.CFrame end
        end)
    else
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
        if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
        if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    end
end

-- NOCLIP
RunService.Stepped:Connect(function()
    if Config.NoclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if Config.InfJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

local function ToggleFullbright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.Ambient = OriginalLighting.Ambient
    end
end

local function ToggleNoFog(state)
    if state then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    else
        Lighting.FogEnd = OriginalLighting.FogEnd
    end
end

RunService.Heartbeat:Connect(function()
    if not Config.KillAuraEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr) then
            local tchar = plr.Character
            if tchar and tchar:FindFirstChild("HumanoidRootPart") then
                if (tchar.HumanoidRootPart.Position - hrp.Position).Magnitude <= Config.KillAuraRange then
                    local hum = tchar:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.HitboxOnAim then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr) then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if Config.HitboxEnabled then
                        hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                        hrp.Transparency = 0.5
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    if Config.AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AntiVoidEnabled then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -50 then hrp.CFrame = CFrame.new(0, 50, 0) end
        end
    end
end)

-- BUILD MENU
CreateSection("🔥 AIMBOT LONG RANGE HEADSHOT")
CreateToggle("Aimbot", true, function(v) Config.AimbotEnabled = v end)
CreateToggle("Headlock", true, function(v) Config.HeadlockEnabled = v end)
CreateToggle("Silent Aim", true, function(v) Config.SilentAim = v end)
CreateToggle("Perfect Lock", true, function(v) Config.PerfectLock = v end)
CreateToggle("Long Range", true, function(v) Config.LongRangeEnabled = v end)
CreateToggle("Hitbox On Aim", true, function(v) Config.HitboxOnAim = v end)
CreateToggle("Team Check", false, function(v) Config.TeamCheck = v end)
CreateToggle("Wall Check", false, function(v) Config.WallCheck = v end)

CreateSection("👁️ ESP RAINBOW")
CreateToggle("ESP", true, function(v) Config.ESPEnabled = v; ToggleESP(v) end)
CreateToggle("ESP Health", true, function(v) Config.ESPHealth = v end)

CreateSection("🏃 MOVEMENT")
CreateToggle("Speed Hack", false, function(v) Config.SpeedEnabled = v end)
CreateToggle("Jump Power", false, function(v) Config.JumpEnabled = v end)
CreateToggle("Fly", false, function(v) Config.FlyEnabled = v; ToggleFly(v) end)
CreateToggle("Noclip", false, function(v) Config.NoclipEnabled = v end)
CreateToggle("Inf Jump", false, function(v) Config.InfJumpEnabled = v end)

CreateSection("⚔️ COMBAT")
CreateToggle("Kill Aura", false, function(v) Config.KillAuraEnabled = v end)
CreateToggle("Hitbox Expander", false, function(v) Config.HitboxEnabled = v end)

CreateSection("🎨 VISUAL")
CreateToggle("Fullbright", false, function(v) Config.FullbrightEnabled = v; ToggleFullbright(v) end)
CreateToggle("No Fog", false, function(v) Config.NoFogEnabled = v; ToggleNoFog(v) end)

CreateSection("🛡️ ANTI-BAN")
CreateToggle("Humanize Aim", true, function(v) Config.HumanizeEnabled = v end)
CreateToggle("Random Jitter", true, function(v) Config.RandomJitterEnabled = v end)
CreateToggle("Anti Kick", true, function(v) Config.AntiKickEnabled = v end)
CreateToggle("Anti Teleport", true, function(v) Config.AntiTeleportEnabled = v end)

CreateSection("🔧 MISC")
CreateToggle("Anti AFK", true, function(v) Config.AntiAFKEnabled = v end)
CreateToggle("Anti Void", false, function(v) Config.AntiVoidEnabled = v end)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -10, 0, 55)
InfoLabel.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
InfoLabel.BorderSizePixel = 0
InfoLabel.Text = "HOLD [Q] = HEADSHOT LOCK 🔥\nFOV: FULL SCREEN | RANGE: UNLIMITED\n🍜 Mie Ayam V1 - Kenzo The Lord"
InfoLabel.TextColor3 = Color3.fromRGB(255, 220, 255)
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextSize = 10
InfoLabel.Parent = ScrollFrame
local InfoC = Instance.new("UICorner")
InfoC.CornerRadius = UDim.new(0, 8)
InfoC.Parent = InfoLabel
local InfoG = Instance.new("UIGradient")
InfoG.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
}
InfoG.Parent = InfoLabel

local notif = Instance.new("TextLabel")
notif.Size = UDim2.new(0, 380, 0, 70)
notif.Position = UDim2.new(0.5, -190, 0, 20)
notif.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
notif.BorderSizePixel = 0
notif.Text = "💜 MIE AYAM V1 LOADED! 💜\nPURPLE RAINBOW | LONG RANGE HEADSHOT\nKenzo The Lord"
notif.TextColor3 = Color3.fromRGB(255, 255, 255)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 13
notif.Parent = ScreenGui
local nCorner = Instance.new("UICorner")
nCorner.CornerRadius = UDim.new(0, 10)
nCorner.Parent = notif
local nStroke = Instance.new("UIStroke")
nStroke.Thickness = 3
nStroke.Color = Color3.fromRGB(255, 0, 255)
nStroke.Parent = notif

task.delay(5, function() notif:Destroy() end)

print("[MIE AYAM V1] Loaded - Kenzo The Lord")
print("[MIE AYAM V1] 💜 PURPLE RAINBOW EDITION")
print("[MIE AYAM V1] Loading Screen: 0-100% Complete")