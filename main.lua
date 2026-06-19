-- AutoClicker LocalScript
-- StarterPlayerScripts または StarterGui の中に入れてください

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- PC限定チェック
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    return -- モバイルでは起動しない
end

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- 状態管理
local isClicking = false
local isMinimized = false
local isDragging = false
local dragOffset = Vector2.new(0, 0)
local clickInterval = 0.001 -- 0.001秒間隔
local lastClickTime = 0

-- ScreenGui作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoClickerGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 180)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- 角丸
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- 外枠（グロー風）
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 80, 220)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- タイトルバー
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

-- タイトルバー下部の角を消す用のフレーム
local titleBarFix = Instance.new("Frame")
titleBarFix.Size = UDim2.new(1, 0, 0, 10)
titleBarFix.Position = UDim2.new(0, 0, 1, -10)
titleBarFix.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
titleBarFix.BorderSizePixel = 0
titleBarFix.Parent = titleBar

-- タイトルテキスト
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ AutoClicker"
titleLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- 最小化ボタン
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, 28, 0, 22)
minimizeBtn.Position = UDim2.new(1, -62, 0.5, -11)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 90)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 190, 255)
minimizeBtn.TextSize = 14
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minimizeBtn

-- 最大化ボタン
local maximizeBtn = Instance.new("TextButton")
maximizeBtn.Name = "MaximizeBtn"
maximizeBtn.Size = UDim2.new(0, 28, 0, 22)
maximizeBtn.Position = UDim2.new(1, -32, 0.5, -11)
maximizeBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 90)
maximizeBtn.BorderSizePixel = 0
maximizeBtn.Text = "□"
maximizeBtn.TextColor3 = Color3.fromRGB(200, 190, 255)
maximizeBtn.TextSize = 13
maximizeBtn.Font = Enum.Font.GothamBold
maximizeBtn.Parent = titleBar

local maxCorner = Instance.new("UICorner")
maxCorner.CornerRadius = UDim.new(0, 5)
maxCorner.Parent = maximizeBtn

-- コンテンツエリア
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- ステータスラベル
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "状態: 停止中"
statusLabel.TextColor3 = Color3.fromRGB(150, 140, 200)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

-- CPS表示ラベル
local cpsLabel = Instance.new("TextLabel")
cpsLabel.Name = "CPSLabel"
cpsLabel.Size = UDim2.new(1, -20, 0, 25)
cpsLabel.Position = UDim2.new(0, 10, 0, 38)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Text = "間隔: 0.001秒 (1000 CPS)"
cpsLabel.TextColor3 = Color3.fromRGB(120, 110, 180)
cpsLabel.TextSize = 12
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
cpsLabel.Parent = contentFrame

-- オン/オフトグルボタン
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(1, -20, 0, 48)
toggleBtn.Position = UDim2.new(0, 10, 0, 72)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 80)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "▶  クリック開始"
toggleBtn.TextColor3 = Color3.fromRGB(160, 255, 180)
toggleBtn.TextSize = 15
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(80, 220, 120)
toggleStroke.Thickness = 1.5
toggleStroke.Parent = toggleBtn

-- クリック数カウンター
local clickCountLabel = Instance.new("TextLabel")
clickCountLabel.Name = "ClickCountLabel"
clickCountLabel.Size = UDim2.new(1, -20, 0, 22)
clickCountLabel.Position = UDim2.new(0, 10, 0, 128)
clickCountLabel.BackgroundTransparency = 1
clickCountLabel.Text = "クリック数: 0"
clickCountLabel.TextColor3 = Color3.fromRGB(120, 110, 180)
clickCountLabel.TextSize = 12
clickCountLabel.Font = Enum.Font.Gotham
clickCountLabel.TextXAlignment = Enum.TextXAlignment.Left
clickCountLabel.Parent = contentFrame

-- クリックカウンター変数
local clickCount = 0

-- ドラッグ機能
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        local mousePos = UserInputService:GetMouseLocation()
        dragOffset = Vector2.new(
            mousePos.X - mainFrame.AbsolutePosition.X,
            mousePos.Y - mainFrame.AbsolutePosition.Y
        )
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if isDragging then
        local mousePos = UserInputService:GetMouseLocation()
        local newX = mousePos.X - dragOffset.X
        local newY = mousePos.Y - dragOffset.Y
        -- 画面外に出ないよう制限
        local screenSize = workspace.CurrentCamera.ViewportSize
        newX = math.clamp(newX, 0, screenSize.X - mainFrame.AbsoluteSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - mainFrame.AbsoluteSize.Y)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- 最小化機能
local normalSize = UDim2.new(0, 240, 0, 180)
local minimizedSize = UDim2.new(0, 240, 0, 40)
local isMaximized = false
local maxSize = UDim2.new(0, 320, 0, 240)

minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        -- 最大化状態から最小化の場合はノーマルサイズに戻す
        isMinimized = false
        isMaximized = false
        mainFrame.Size = normalSize
        contentFrame.Visible = true
        minimizeBtn.Text = "─"
        maximizeBtn.Text = "□"
    else
        -- 最小化
        isMinimized = true
        isMaximized = false
        mainFrame.Size = minimizedSize
        contentFrame.Visible = false
        minimizeBtn.Text = "＋"
        maximizeBtn.Text = "□"
    end
end)

-- 最大化機能
maximizeBtn.MouseButton1Click:Connect(function()
    if isMaximized then
        isMaximized = false
        isMinimized = false
        mainFrame.Size = normalSize
        contentFrame.Visible = true
        maximizeBtn.Text = "□"
    else
        isMaximized = true
        isMinimized = false
        mainFrame.Size = maxSize
        contentFrame.Visible = true
        minimizeBtn.Text = "─"
        maximizeBtn.Text = "❐"
    end
end)

-- ボタンホバーエフェクト
minimizeBtn.MouseEnter:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 70, 130)
end)
minimizeBtn.MouseLeave:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 90)
end)

maximizeBtn.MouseEnter:Connect(function()
    maximizeBtn.BackgroundColor3 = Color3.fromRGB(80, 70, 130)
end)
maximizeBtn.MouseLeave:Connect(function()
    maximizeBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 90)
end)

-- UI状態更新関数
local function updateUI()
    if isClicking then
        toggleBtn.Text = "⏹  クリック停止"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 40)
        toggleBtn.TextColor3 = Color3.fromRGB(255, 140, 140)
        toggleStroke.Color = Color3.fromRGB(220, 70, 80)
        statusLabel.Text = "状態: 動作中 🟢"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    else
        toggleBtn.Text = "▶  クリック開始"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 80)
        toggleBtn.TextColor3 = Color3.fromRGB(160, 255, 180)
        toggleStroke.Color = Color3.fromRGB(80, 220, 120)
        statusLabel.Text = "状態: 停止中 🔴"
        statusLabel.TextColor3 = Color3.fromRGB(150, 140, 200)
    end
end

-- トグルボタン処理
toggleBtn.MouseButton1Click:Connect(function()
    isClicking = not isClicking
    updateUI()
end)

toggleBtn.MouseEnter:Connect(function()
    if isClicking then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 55)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(65, 60, 105)
    end
end)
toggleBtn.MouseLeave:Connect(function()
    if isClicking then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 40)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 80)
    end
end)

-- オートクリック処理（RunService使用）
RunService.Heartbeat:Connect(function()
    if isClicking then
        local currentTime = tick()
        if currentTime - lastClickTime >= clickInterval then
            lastClickTime = currentTime
            -- マウスクリックをシミュレート
            mouse1click()
            clickCount = clickCount + 1
            clickCountLabel.Text = "クリック数: " .. tostring(clickCount)
        end
    end
end)

-- 初期UI更新
updateUI()

print("[AutoClicker] スクリプト起動完了 - PC限定UIが表示されました")
