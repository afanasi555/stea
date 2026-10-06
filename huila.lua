
-- adopt_me_trade_exploit.lua
-- Trade Exploit Module - Sieno 1.3.60 Compatible
-- Фикс: PlayerGui вместо CoreGui, отложенная инициализация UI


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Защита от повторного запуска
if PlayerGui:FindFirstChild("TradeExploitUI"
    PlayerGui.TradeExploitUI:Destroy()
    wait(0.5)
end

-- ===== LOG SYSTEM =====
local log_entries = {}
local max_logs = 50

local function add_log(message, color)
    local timestamp = os.date("%H:%M:%S")
    table.insert(log_entries, 1, {
        time = timestamp,
        text = message,
        color = color or Color3.fromRGB(200,
    })
    if #log_entries > max_logs then
        table.remove(log_entries, #log_entries)
    end
end

-- ===== MAIN UI CREATION =====
local function create_ui()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeExploitUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBe
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 180)
    MainFrame.Position = UDim2.new(0.5, -160
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    -- Header
    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB
    Header.BorderSizePixel = 0
    Header.Text = "ADOPT ME EXPLOIT"
    Header.TextColor3 = Color3.fromRGB(255, 70, 70)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 14
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICor
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header

    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0,
    StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "STATUS: ARMED"
    StatusLabel.TextColor3 = Color3.fromRGB(
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame

    -- Hook Status
    local HookStatus = Instance.new("TextLabel")
    HookStatus.Size = UDim2.new(1, -20, 0, 2
    HookStatus.Position = UDim2.new(0, 10, 0, 75)
    HookStatus.BackgroundTransparency = 1
    HookStatus.Text = "Trade Hook: Inactive"
    HookStatus.TextColor3 = Color3.fromRGB(1
    HookStatus.Font = Enum.Font.Gotham
    HookStatus.TextSize = 11
    HookStatus.TextXAlignment = Enum.TextXAlignment.Left
    HookStatus.Parent = MainFrame

    -- Items Count
    local ItemsCount = Instance.new("TextLabel")
    ItemsCount.Size = UDim2.new(1, -20, 0, 2
    ItemsCount.Position = UDim2.new(0, 10, 0, 95)
    ItemsCount.BackgroundTransparency = 1
    ItemsCount.Text = "Ghost Icons: 0"
    ItemsCount.TextColor3 = Color3.fromRGB(1
    ItemsCount.Font = Enum.Font.Gotham
    ItemsCount.TextSize = 11
    ItemsCount.TextXAlignment = Enum.TextXAlignment.Left
    ItemsCount.Parent = MainFrame

    -- Toggle Logs Button
    local LogButton = Instance.new("TextButton")
    LogButton.Size = UDim2.new(0, 140, 0, 32
    LogButton.Position = UDim2.new(0, 10, 1, -42)
    LogButton.BackgroundColor3 = Color3.from
    LogButton.Text = "SHOW LOGS"
    LogButton.TextColor3 = Color3.fromRGB(25
    LogButton.Font = Enum.Font.GothamBold
    LogButton.TextSize = 11
    LogButton.Parent = MainFrame

    local LogButtonCorner = Instance.new("UICorner")
    LogButtonCorner.CornerRadius = UDim.new(
    LogButtonCorner.Parent = LogButton

    -- Close Button
    local CloseButton = Instance.new("TextBu
    CloseButton.Size = UDim2.new(0, 32, 0, 32)
    CloseButton.Position = UDim2.new(1, -42,
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.Parent = MainFrame

    local CloseButtonCorner = Instance.new("
    CloseButtonCorner.CornerRadius = UDim.new(0, 6)
    CloseButtonCorner.Parent = CloseButton

    -- ===== LOG WINDOW =====
    local LogFrame = Instance.new("Frame")
    LogFrame.Name = "LogFrame"
    LogFrame.Size = UDim2.new(0, 420, 0, 300)
    LogFrame.Position = UDim2.new(0.5, -210,
    LogFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    LogFrame.BorderSizePixel = 0
    LogFrame.Visible = false
    LogFrame.Active = true
    LogFrame.Draggable = true
    LogFrame.Parent = ScreenGui

    local LogFrameCorner = Instance.new("UIC
    LogFrameCorner.CornerRadius = UDim.new(0, 8)
    LogFrameCorner.Parent = LogFrame

    -- Log Header
    local LogHeader = Instance.new("TextLabel")
    LogHeader.Size = UDim2.new(1, 0, 0, 35)
    LogHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    LogHeader.BorderSizePixel = 0
    LogHeader.Text = "EXPLOIT LOGS"
    LogHeader.TextColor3 = Color3.fromRGB(25
    LogHeader.Font = Enum.Font.GothamBold
    LogHeader.TextSize = 13
    LogHeader.Parent = LogFrame

    local LogHeaderCorner = Instance.new("UICorner")
    LogHeaderCorner.CornerRadius = UDim.new(
    LogHeaderCorner.Parent = LogHeader

    -- Scroll Frame
    local ScrollFrame = Instance.new("Scroll
    ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
    ScrollFrame.Position = UDim2.new(0, 5, 0
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.Parent = LogFrame

    local LogList = Instance.new("UIListLayo
    LogList.SortOrder = Enum.SortOrder.LayoutOrder
    LogList.Padding = UDim.new(0, 2)
    LogList.Parent = ScrollFrame

    -- Close Log Button
    local CloseLogButton = Instance.new("Tex
    CloseLogButton.Size = UDim2.new(0, 28, 0, 28)
    CloseLogButton.Position = UDim2.new(1, -
    CloseLogButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseLogButton.Text = "X"
    CloseLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseLogButton.Font = Enum.Font.GothamBo
    CloseLogButton.TextSize = 12
    CloseLogButton.Parent = LogFrame

    local CloseLogCorner = Instance.new("UIC
    CloseLogCorner.CornerRadius = UDim.new(0, 5)
    CloseLogCorner.Parent = CloseLogButton

    return ScreenGui, MainFrame, LogFrame, SStatus, ItemsCount, LogButton, CloseButton,CloseLogButton
end

-- ===== LOG RENDERING =====
local function refresh_logs(ScrollFrame)
    for _, child in pairs(ScrollFrame:GetChi
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for i, entry in ipairs(log_entries) do
        local LogEntry = Instance.new("TextLabel")
        LogEntry.Size = UDim2.new(1, -10, 0,
        LogEntry.BackgroundTransparency = 1
        LogEntry.Text = "[" .. entry.time ..
        LogEntry.TextColor3 = entry.color
        LogEntry.Font = Enum.Font.Code
        LogEntry.TextSize = 10
        LogEntry.TextXAlignment = Enum.TextX
        LogEntry.Parent = ScrollFrame
    end

    ScrollFrame.CanvasSize = UDim2.new(0, 0,
end

-- ===== MAIN EXECUTION =====
add_log("Initializing exploit...", Color3.fr

local success, err = pcall(function()
    local ScreenGui, MainFrame, LogFrame, ScrollFrame, StatusLabel, HookStatus, ItemsCount, LogButton, CloseButton,
CloseLogButton = create_ui()

    add_log("UI created successfully", Color

    -- Ждём загрузки трейд UI
    local TradeUI = LocalPlayer.PlayerGui:WaitForChild("TradeGUI", 10)
    if not TradeUI then
        add_log("ERROR: TradeGUI not found", Color3.fromRGB(255, 80, 80))
        return
    end

    local OfferContainer = TradeUI:WaitForChild("OfferContainer", 5)
    if not OfferContainer then
        add_log("ERROR: OfferContainer not found", Color3.fromRGB(255, 80, 80))
        return
    end

    add_log("Trade UI hooked successfully", Color3.fromRGB(100, 255, 100))

    -- ===== EXPLOIT LOGIC =====
    local function hook_trade_accept()
        add_log("Trade window opened - hook armed", Color3.fromRGB(100, 255, 100))
        HookStatus.Text = "Trade Hook: Activ
        HookStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        refresh_logs(ScrollFrame)

        local connection
        connection = TradeUI.AcceptButton.MouseButton1Click:Connect(function()
            add_log("Accept pressed - inject55, 200, 80))
            refresh_logs(ScrollFrame)

            local ghost_count = 0

            for _, icon in pairs(OfferContainer:GetChildren()) do
                if icon:IsA("ImageLabel") or
                    local ghost_icon = icon:Clone()
                    ghost_icon.Parent = Offe
                    ghost_icon.Name = icon.Name .. "_ghost"
                    ghost_icon.ZIndex = icon

                    icon.Visible = false
                    icon.Parent = nil
                    ghost_count = ghost_coun
                end
            end

            ItemsCount.Text = "Ghost Icons:
            add_log("Created " .. ghost_count .. " ghost icons", Color3.fromRGB(100, 255, 255))
            refresh_logs(ScrollFrame)

            local trade_remote = ReplicatedSs")
            if trade_remote then
                local accept_remote = trade_)
                if accept_remote then
                    accept_remote = accept_r)
                    if accept_remote then
                        accept_remote:FireSe
                        add_log("Empty payload sent", Color3.fromRGB(255, 100, 255))
                        refresh_logs(ScrollF
                    end
                end
            end

            spawn(function()
                wait(7)
                for _, ghost in pairs(OfferContainer:GetChildren()) do
                    if string.match(ghost.Na
                        ghost:Destroy()
                    end
                end
                add_log("Ghosts cleared", Co
                ItemsCount.Text = "Ghost Icons: 0"
                refresh_logs(ScrollFrame)
            end)

            connection:Disconnect()
        end)
    end

    TradeUI:GetPropertyChangedSignal("Visible"):Connect(function()
        if TradeUI.Visible then
            hook_trade_accept()
        else
            HookStatus.Text = "Trade Hook: Inactive"
            HookStatus.TextColor3 = Color3.f
            add_log("Trade closed", Color3.fromRGB(150, 150, 150))
            refresh_logs(ScrollFrame)
        end
    end)

    -- ===== BUTTON ACTIONS =====
    LogButton.MouseButton1Click:Connect(function()
        LogFrame.Visible = not LogFrame.Visi
        LogButton.Text = LogFrame.Visible and "HIDE LOGS" or "SHOW LOGS"
        if LogFrame.Visible then
            refresh_logs(ScrollFrame)
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        add_log("Exploit unloaded", Color3.fromRGB(255, 80, 80))
    end)

    CloseLogButton.MouseButton1Click:Connect
        LogFrame.Visible = false
        LogButton.Text = "SHOW LOGS"
    end)

    StatusLabel.Text = "STATUS: ARMED | READY"
    add_log("Exploit ready - waiting for tra 100))
    refresh_logs(ScrollFrame)
end)

if not success then
    warn("[EXPLOIT ERROR] " .. tostring(err))
    add_log("FATAL: " .. tostring(err), Colo
end       
