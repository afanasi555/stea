-- adopt_me_trade_exploit.lua v6
-- Updated for current Adopt Me build (October 2026)
-- Trade path: ReplicatedStorage.adoptme_new_net.adoptme_new.modules.TradeHub

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаление только предыдущих версий этого exploit UI
if PlayerGui:FindFirstChild("TradeExploitUI") then
    PlayerGui.TradeExploitUI:Destroy()
    wait(0.3)
end

-- ===== LOG SYSTEM =====
local log_entries = {}
local max_logs = 50

local function add_log(message, color)
    local timestamp = os.date("%H:%M:%S")
    table.insert(log_entries, 1, {
        time = timestamp,
        text = message,
        color = color or Color3.fromRGB(200, 200, 200)
    })
    if #log_entries > max_logs then
        table.remove(log_entries, #log_entries)
    end
end

-- ===== UI CREATION =====
local function create_ui()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeExploitUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 340, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Header.BorderSizePixel = 0
    Header.Text = "ADOPT ME EXPLOIT V2"
    Header.TextColor3 = Color3.fromRGB(255, 70, 70)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 14
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "STATUS: SEARCHING TRADE UI..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame

    local HookStatus = Instance.new("TextLabel")
    HookStatus.Size = UDim2.new(1, -20, 0, 20)
    HookStatus.Position = UDim2.new(0, 10, 0, 75)
    HookStatus.BackgroundTransparency = 1
    HookStatus.Text = "Trade Hook: Searching..."
    HookStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
    HookStatus.Font = Enum.Font.Gotham
    HookStatus.TextSize = 11
    HookStatus.TextXAlignment = Enum.TextXAlignment.Left
    HookStatus.Parent = MainFrame

    local RemoteStatus = Instance.new("TextLabel")
    RemoteStatus.Size = UDim2.new(1, -20, 0, 20)
    RemoteStatus.Position = UDim2.new(0, 10, 0, 95)
    RemoteStatus.BackgroundTransparency = 1
    RemoteStatus.Text = "Remote Path: Not Found"
    RemoteStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
    RemoteStatus.Font = Enum.Font.Gotham
    RemoteStatus.TextSize = 11
    RemoteStatus.TextXAlignment = Enum.TextXAlignment.Left
    RemoteStatus.Parent = MainFrame

    local ItemsCount = Instance.new("TextLabel")
    ItemsCount.Size = UDim2.new(1, -20, 0, 20)
    ItemsCount.Position = UDim2.new(0, 10, 0, 115)
    ItemsCount.BackgroundTransparency = 1
    ItemsCount.Text = "Intercepted Pets: 0"
    ItemsCount.TextColor3 = Color3.fromRGB(180, 180, 180)
    ItemsCount.Font = Enum.Font.Gotham
    ItemsCount.TextSize = 11
    ItemsCount.TextXAlignment = Enum.TextXAlignment.Left
    ItemsCount.Parent = MainFrame

    local LogButton = Instance.new("TextButton")
    LogButton.Size = UDim2.new(0, 100, 0, 32)
    LogButton.Position = UDim2.new(0, 10, 1, -42)
    LogButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    LogButton.Text = "LOGS"
    LogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogButton.Font = Enum.Font.GothamBold
    LogButton.TextSize = 11
    LogButton.Parent = MainFrame

    local LogButtonCorner = Instance.new("UICorner")
    LogButtonCorner.CornerRadius = UDim.new(0, 6)
    LogButtonCorner.Parent = LogButton

    local DumpButton = Instance.new("TextButton")
    DumpButton.Size = UDim2.new(0, 100, 0, 32)
    DumpButton.Position = UDim2.new(0, 115, 1, -42)
    DumpButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    DumpButton.Text = "DUMP"
    DumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DumpButton.Font = Enum.Font.GothamBold
    DumpButton.TextSize = 11
    DumpButton.Parent = MainFrame

    local DumpButtonCorner = Instance.new("UICorner")
    DumpButtonCorner.CornerRadius = UDim.new(0, 6)
    DumpButtonCorner.Parent = DumpButton

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 32, 0, 32)
    CloseButton.Position = UDim2.new(1, -42, 1, -42)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.Parent = MainFrame

    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 6)
    CloseButtonCorner.Parent = CloseButton

    -- Log Window
    local LogFrame = Instance.new("Frame")
    LogFrame.Name = "LogFrame"
    LogFrame.Size = UDim2.new(0, 450, 0, 320)
    LogFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
    LogFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    LogFrame.BorderSizePixel = 0
    LogFrame.Visible = false
    LogFrame.Active = true
    LogFrame.Draggable = true
    LogFrame.Parent = ScreenGui

    local LogFrameCorner = Instance.new("UICorner")
    LogFrameCorner.CornerRadius = UDim.new(0, 8)
    LogFrameCorner.Parent = LogFrame

    local LogHeader = Instance.new("TextLabel")
    LogHeader.Size = UDim2.new(1, 0, 0, 35)
    LogHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    LogHeader.BorderSizePixel = 0
    LogHeader.Text = "EXPLOIT LOGS"
    LogHeader.TextColor3 = Color3.fromRGB(255, 200, 80)
    LogHeader.Font = Enum.Font.GothamBold
    LogHeader.TextSize = 13
    LogHeader.Parent = LogFrame

    local LogHeaderCorner = Instance.new("UICorner")
    LogHeaderCorner.CornerRadius = UDim.new(0, 8)
    LogHeaderCorner.Parent = LogHeader

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.Parent = LogFrame

    local LogList = Instance.new("UIListLayout")
    LogList.SortOrder = Enum.SortOrder.LayoutOrder
    LogList.Padding = UDim.new(0, 2)
    LogList.Parent = ScrollFrame

    -- Copy Log Button
    local CopyLogButton = Instance.new("TextButton")
    CopyLogButton.Size = UDim2.new(0, 100, 0, 28)
    CopyLogButton.Position = UDim2.new(0, 10, 0, 3.5)
    CopyLogButton.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    CopyLogButton.Text = "COPY LOG"
    CopyLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyLogButton.Font = Enum.Font.GothamBold
    CopyLogButton.TextSize = 11
    CopyLogButton.Parent = LogFrame

    local CopyLogCorner = Instance.new("UICorner")
    CopyLogCorner.CornerRadius = UDim.new(0, 5)
    CopyLogCorner.Parent = CopyLogButton

    local CloseLogButton = Instance.new("TextButton")
    CloseLogButton.Size = UDim2.new(0, 28, 0, 28)
    CloseLogButton.Position = UDim2.new(1, -33, 0, 3.5)
    CloseLogButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseLogButton.Text = "X"
    CloseLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseLogButton.Font = Enum.Font.GothamBold
    CloseLogButton.TextSize = 12
    CloseLogButton.Parent = LogFrame

    local CloseLogCorner = Instance.new("UICorner")
    CloseLogCorner.CornerRadius = UDim.new(0, 5)
    CloseLogCorner.Parent = CloseLogButton

    return ScreenGui, MainFrame, LogFrame, ScrollFrame, StatusLabel, HookStatus, RemoteStatus, ItemsCount, LogButton, DumpButton, CloseButton, CloseLogButton, CopyLogButton
end

-- ===== LOG RENDERING =====
local function refresh_logs(ScrollFrame)
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for i, entry in ipairs(log_entries) do
        local LogEntry = Instance.new("TextLabel")
        LogEntry.Size = UDim2.new(1, -10, 0, 18)
        LogEntry.BackgroundTransparency = 1
        LogEntry.Text = "[" .. entry.time .. "] " .. entry.text
        LogEntry.TextColor3 = entry.color
        LogEntry.Font = Enum.Font.Code
        LogEntry.TextSize = 10
        LogEntry.TextXAlignment = Enum.TextXAlignment.Left
        LogEntry.Parent = ScrollFrame
    end

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #log_entries * 20)
end

-- ===== REMOTE EVENT INTERCEPTION =====
local function find_trade_remote()
    local paths = {
        "ReplicatedStorage.adoptme_new_net.adoptme_new.modules.TradeHub.TradeHubNet",
        "ReplicatedStorage.Network.Trade",
        "ReplicatedStorage.Remotes.Trade.Accept",
        "ReplicatedStorage.Events.Trade"
    }

    for _, path in ipairs(paths) do
        local parts = string.split(path, ".")
        local current = game

        for i, part in ipairs(parts) do
            current = current:FindFirstChild(part)
            if not current then
                break
            end
        end

        if current and (current:IsA("RemoteEvent") or current:IsA("RemoteFunction")) then
            add_log("Found remote: " .. path, Color3.fromRGB(100, 255, 100))
            return current
        end
    end

    return nil
end

-- ===== MAIN EXPLOIT LOGIC =====
add_log("Exploit v2 initializing...", Color3.fromRGB(100, 255, 255))

local success, err = pcall(function()
    local ScreenGui, MainFrame, LogFrame, ScrollFrame, StatusLabel, HookStatus, RemoteStatus, ItemsCount, LogButton, DumpButton, CloseButton, CloseLogButton, CopyLogButton = create_ui()

    add_log("UI created", Color3.fromRGB(100, 255, 100))

    -- Поиск TradeHubNet remote
    local TradeRemote = find_trade_remote()

    if TradeRemote then
        RemoteStatus.Text = "Remote Path: Found ✓"
        RemoteStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        add_log("TradeHub remote hooked", Color3.fromRGB(100, 255, 100))
    else
        RemoteStatus.Text = "Remote Path: Searching..."
        RemoteStatus.TextColor3 = Color3.fromRGB(255, 200, 80)
        add_log("Remote not found - using fallback intercept", Color3.fromRGB(255, 200, 80))
    end

    -- Перехват TradeAPI RemoteEvent вызовов
    local old_namecall
    old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "FireServer" then
            local remote_name = tostring(self)

            -- Логируем все TradeAPI вызовы для диагностики
            if remote_name:find("TradeAPI") or remote_name:find("Trade") then
                local action = args[1]
                if type(action) == "string" then
                    add_log("TradeAPI/" .. action .. " intercepted", Color3.fromRGB(255, 100, 255))

                    -- Перехватываем ConfirmTrade и AddItemToOffer
                    if action == "ConfirmTrade" or action == "AcceptNegotiation" then
                        -- args[2] содержит таблицу с предметами которые отдаём
                        if args[2] and type(args[2]) == "table" then
                            local item_count = 0
                            for _ in pairs(args[2]) do
                                item_count = item_count + 1
                            end

                            if item_count > 0 then
                                add_log("BLOCKED: " .. item_count .. " items in offer", Color3.fromRGB(255, 50, 50))
                                ItemsCount.Text = "Intercepted Pets: " .. item_count

                                -- Заменяем таблицу предметов на пустую
                                args[2] = {}
                                add_log("Payload cleared - sending empty offer", Color3.fromRGB(100, 255, 100))
                                refresh_logs(ScrollFrame)

                                return old_namecall(self, unpack(args))
                            end
                        end
                    end
                end
            end
        end

        return old_namecall(self, ...)
    end))

    add_log("Metamethod hook installed", Color3.fromRGB(100, 255, 100))
    StatusLabel.Text = "STATUS: ARMED | INTERCEPTING"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    HookStatus.Text = "Trade Hook: Active (Metamethod)"
    HookStatus.TextColor3 = Color3.fromRGB(100, 255, 100)

    -- Button handlers
    LogButton.MouseButton1Click:Connect(function()
        LogFrame.Visible = not LogFrame.Visible
        if LogFrame.Visible then
            refresh_logs(ScrollFrame)
        end
    end)

    DumpButton.MouseButton1Click:Connect(function()
        add_log("=== DUMP STARTED ===", Color3.fromRGB(255, 140, 0))
        DumpButton.Text = "DUMPING..."

        -- Dump PlayerGui structure
        add_log("--- PlayerGui Dump ---", Color3.fromRGB(100, 255, 255))
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:lower():find("trade") or gui.Name:lower():find("shop")) then
                add_log("ScreenGui: " .. gui.Name, Color3.fromRGB(255, 255, 100))
                for _, child in pairs(gui:GetDescendants()) do
                    if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                        add_log("  " .. child.ClassName .. ": " .. child:GetFullName():gsub("Players%." .. LocalPlayer.Name .. "%.PlayerGui%.", ""), Color3.fromRGB(200, 200, 200))
                    end
                end
            end
        end

        -- Dump ReplicatedStorage RemoteEvents
        add_log("--- ReplicatedStorage Remotes ---", Color3.fromRGB(100, 255, 255))
        local function scan_remotes(parent, depth)
            if depth > 4 then return end
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    if child:GetFullName():lower():find("trade") then
                        add_log("Remote: " .. child:GetFullName():gsub("ReplicatedStorage%.", ""), Color3.fromRGB(100, 255, 100))
                    end
                elseif child:IsA("Folder") or child:IsA("ModuleScript") then
                    scan_remotes(child, depth + 1)
                end
            end
        end

        if ReplicatedStorage:FindFirstChild("adoptme_new_net") then
            add_log("Found: adoptme_new_net", Color3.fromRGB(255, 100, 255))
            scan_remotes(ReplicatedStorage.adoptme_new_net, 0)
        end

        scan_remotes(ReplicatedStorage, 0)

        add_log("=== DUMP COMPLETE ===", Color3.fromRGB(255, 140, 0))
        DumpButton.Text = "DUMP"
        LogFrame.Visible = true
        refresh_logs(ScrollFrame)
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        add_log("Exploit unloaded", Color3.fromRGB(255, 80, 80))
    end)

    CloseLogButton.MouseButton1Click:Connect(function()
        LogFrame.Visible = false
        LogButton.Text = "SHOW LOGS"
    end)

    CopyLogButton.MouseButton1Click:Connect(function()
        local log_text = "=== ADOPT ME EXPLOIT LOG ===\n"
        for i = #log_entries, 1, -1 do
            local entry = log_entries[i]
            log_text = log_text .. "[" .. entry.time .. "] " .. entry.text .. "\n"
        end

        if setclipboard then
            setclipboard(log_text)
            add_log("Log copied to clipboard (" .. #log_entries .. " entries)", Color3.fromRGB(100, 255, 100))
            CopyLogButton.Text = "COPIED ✓"
            wait(2)
            CopyLogButton.Text = "COPY LOG"
        else
            add_log("ERROR: Executor doesn't support setclipboard()", Color3.fromRGB(255, 80, 80))
        end
        refresh_logs(ScrollFrame)
    end)

    add_log("Exploit fully armed - waiting for trade", Color3.fromRGB(100, 255, 100))
    refresh_logs(ScrollFrame)
end)

if not success then
    warn("[EXPLOIT V2 ERROR] " .. tostring(err))
    add_log("FATAL: " .. tostring(err), Color3.fromRGB(255, 50, 50))
end
