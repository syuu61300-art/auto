-- AutoClicker (Rayfield UI版)
-- LocalScript として StarterPlayerScripts に入れてください

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- PC限定チェック
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    return
end

-- Rayfieldライブラリの読み込み
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ウィンドウ作成
local Window = Rayfield:CreateWindow({
    Name = "⚡ AutoClicker",
    LoadingTitle = "AutoClicker",
    LoadingSubtitle = "by Script",
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- タブ作成
local MainTab = Window:CreateTab("🖱️ クリッカー", 4483362458)
local InfoTab = Window:CreateTab("📊 情報", 4483362458)

-- 状態変数
local isClicking = false
local clickCount = 0
local lastClickTime = 0
local clickInterval = 0.001
local startTime = 0

-- 情報タブのラベル（先に定義）
local StatusLabel = InfoTab:CreateLabel("状態: 停止中 🔴")
local ClickCountLabel = InfoTab:CreateLabel("クリック数: 0")
local CPSLabel = InfoTab:CreateLabel("間隔: 0.001秒 (最大1000 CPS)")
local SessionLabel = InfoTab:CreateLabel("経過時間: 0秒")

-- メインタブ：トグルボタン
local Toggle = MainTab:CreateToggle({
    Name = "オートクリック",
    CurrentValue = false,
    Flag = "AutoClickToggle",
    Callback = function(value)
        isClicking = value
        if isClicking then
            clickCount = 0
            startTime = tick()
            StatusLabel:Set("状態: 動作中 🟢")
            ClickCountLabel:Set("クリック数: 0")
            Rayfield:Notify({
                Title = "AutoClicker",
                Content = "クリック開始しました",
                Duration = 2,
                Image = 4483362458,
            })
        else
            StatusLabel:Set("状態: 停止中 🔴")
            Rayfield:Notify({
                Title = "AutoClicker",
                Content = "クリック停止しました　合計: " .. tostring(clickCount) .. "回",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

-- メインタブ：クリックカウントリセットボタン
MainTab:CreateButton({
    Name = "カウントをリセット",
    Callback = function()
        clickCount = 0
        ClickCountLabel:Set("クリック数: 0")
        Rayfield:Notify({
            Title = "リセット",
            Content = "クリック数をリセットしました",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

-- メインタブ：セクション
MainTab:CreateSection("設定")

-- クリック間隔スライダー
MainTab:CreateSlider({
    Name = "クリック間隔 (ms)",
    Range = {1, 100},
    Increment = 1,
    Suffix = "ms",
    CurrentValue = 1,
    Flag = "ClickIntervalSlider",
    Callback = function(value)
        clickInterval = value / 1000
        CPSLabel:Set("間隔: " .. tostring(value) .. "ms (" .. tostring(math.floor(1000/value)) .. " CPS)")
    end,
})

-- 情報タブ：セクション
InfoTab:CreateSection("リアルタイム情報")

-- オートクリック処理
RunService.Heartbeat:Connect(function()
    if isClicking then
        local currentTime = tick()
        if currentTime - lastClickTime >= clickInterval then
            lastClickTime = currentTime
            mouse1click()
            clickCount = clickCount + 1

            -- 10クリックごとにUI更新（毎回更新すると重くなるため）
            if clickCount % 10 == 0 then
                ClickCountLabel:Set("クリック数: " .. tostring(clickCount))
                local elapsed = math.floor(tick() - startTime)
                SessionLabel:Set("経過時間: " .. tostring(elapsed) .. "秒")
            end
        end
    end
end)

print("[AutoClicker] Rayfield版 起動完了")
