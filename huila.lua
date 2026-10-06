-- adopt_me_trade_exploit.lua v11
-- Updated: 2026-10-07 | Working trade window + bypass
-- Method: Hook bypass after Accept, no blocking until analysis complete

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup only our exploit UI
if PlayerGui:FindFirstChild("TradeExploitUI") then
    PlayerGui.TradeExploitUI:Destroy()
    wait(0.3)
end

-- ===== LOG SYSTEM =====
local log_entries = {}
local max_logs = 150

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

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 220)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local Header = Instance.new("TextLabel", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Header.BorderSizePixel = 0
    Header.Text = "ADOPT ME EXPLOIT V11"
    Header.TextColor3 = Color3.fromRGB(255, 70, 70)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 14
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

    local VersionLabel = Instance.new("TextLabel", Header)
    VersionLabel.Size = UDim2.new(0, 110, 1, 0)
    VersionLabel.Position = UDim2.new(1, -115, 0, 0)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "v11 | 2026-10-07"
    VersionLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
    VersionLabel.Font = Enum.Font.Code
    VersionLabel.TextSize = 9
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right

    local StatusLabel = Instance.new("TextLabel", MainFrame)
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "STATUS: INITIALIZING..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local HookStatus = Instance.new("TextLabel", MainFrame)
    HookStatus.Size = UDim2.new(1, -20, 0, 20)
    HookStatus.Position = UDim2.new(0, 10, 0, 75)
    HookStatus.BackgroundTransparency = 1
    HookStatus.Text = "Hook: Inactive"
    HookStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
    HookStatus.Font = Enum.Font.Gotham
    HookStatus.TextSize = 11
    HookStatus.TextXAlignment = Enum.TextXAlignment.Left

    local InterceptCount = Instance.new("TextLabel", MainFrame)
    InterceptCount.Size = UDim2.new(1, -20, 0, 20)
    InterceptCount.Position = UDim2.new(0, 10, 0, 95)
    InterceptCount.BackgroundTransparency = 1
    InterceptCount.Text = "Logged Calls: 0"
    InterceptCount.TextColor3 = Color3.fromRGB(180, 180, 180)
    InterceptCount.Font = Enum.Font.Gotham
    InterceptCount.TextSize = 11
    InterceptCount.TextXAlignment = Enum.TextXAlignment.Left

    local ItemsCount = Instance.new("TextLabel", MainFrame)
    ItemsCount.Size = UDim2.new(1, -20, 0, 20)
    ItemsCount.Position = UDim2.new(0, 10, 0, 115)
    ItemsCount.BackgroundTransparency = 1
    ItemsCount.Text = "Trade Status: Waiting"
    ItemsCount.TextColor3 = Color3.fromRGB(180, 180, 180)
    ItemsCount.Font = Enum.Font.Gotham
    ItemsCount.TextSize = 11
    ItemsCount.TextXAlignment = Enum.TextXAlignment.Left

    local LastAction = Instance.new("TextLabel", MainFrame)
    LastAction.Size = UDim2.new(1, -20, 0, 20)
    LastAction.Position = UDim2.new(0, 10, 0, 135)
    LastAction.BackgroundTransparency = 1
    LastAction.Text = "Last Remote: N/A"
    LastAction.TextColor3 = Color3.fromRGB(150, 150, 150)
    LastAction.Font = Enum.Font.Code
    LastAction.TextSize = 10
    LastAction.TextXAlignment = Enum.TextXAlignment.Left

    local InfoLabel = Instance.new("TextLabel", MainFrame)
    InfoLabel.Size = UDim2.new(1, -20, 0, 15)
    InfoLabel.Position = UDim2.new(0, 10, 0, 155)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Trade window opens automatically | Full logging active"
    InfoLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
    InfoLabel.Font = Enum.Font.Code
    InfoLabel.TextSize = 8
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

    local LogButton = Instance.new("TextButton", MainFrame)
    LogButton.Size = UDim2.new(0, 120, 0, 32)
    LogButton.Position = UDim2.new(0, 10, 1, -42)
    LogButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    LogButton.Text = "SHOW LOGS"
    LogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogButton.Font = Enum.Font.GothamBold
    LogButton.TextSize = 11
    Instance.new("UICorner", LogButton).CornerRadius = UDim.new(0, 6)

    local DumpButton = Instance.new("TextButton", MainFrame)
    DumpButton.Size = UDim2.new(0, 100, 0, 32)
    DumpButton.Position = UDim2.new(0, 135, 1, -42)
    DumpButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    DumpButton.Text = "DUMP"
    DumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DumpButton.Font = Enum.Font.GothamBold
    DumpButton.TextSize = 11
    Instance.new("UICorner", DumpButton).CornerRadius = UDim.new(0, 6)

    local CloseButton = Instance.new("TextButton", MainFrame)
    CloseButton.Size = UDim2.new(0, 32, 0, 32)
    CloseButton.Position = UDim2.new(1, -42, 1, -42)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

    -- Log Window
    local LogFrame = Instance.new("Frame", ScreenGui)
    LogFrame.Size = UDim2.new(0, 520, 0, 380)
    LogFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    LogFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    LogFrame.BorderSizePixel = 0
    LogFrame.Visible = false
    LogFrame.Active = true
    LogFrame.Draggable = true
    Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 8)

    local LogHeader = Instance.new("TextLabel", LogFrame)
    LogHeader.Size = UDim2.new(1, 0, 0, 35)
    LogHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    LogHeader.BorderSizePixel = 0
    LogHeader.Text = "EXPLOIT LOGS — FULL TRADE TRACE"
    LogHeader.TextColor3 = Color3.fromRGB(255, 200, 80)
    LogHeader.Font = Enum.Font.GothamBold
    LogHeader.TextSize = 13
    Instance.new("UICorner", LogHeader).CornerRadius = UDim.new(0, 8)

    local ScrollFrame = Instance.new("ScrollingFrame", LogFrame)
    ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    local LogList = Instance.new("UIListLayout", ScrollFrame)
    LogList.SortOrder = Enum.SortOrder.LayoutOrder
    LogList.Padding = UDim.new(0, 2)

    local CopyLogButton = Instance.new("TextButton", LogFrame)
    CopyLogButton.Size = UDim2.new(0, 110, 0, 28)
    CopyLogButton.Position = UDim2.new(0, 10, 0, 3.5)
    CopyLogButton.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    CopyLogButton.Text = "COPY LOG"
    CopyLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyLogButton.Font = Enum.Font.GothamBold
    CopyLogButton.TextSize = 11
    Instance.new("UICorner", CopyLogButton).CornerRadius = UDim.new(0, 5)

    local CloseLogButton = Instance.new("TextButton", LogFrame)
    CloseLogButton.Size = UDim2.new(0, 28, 0, 28)
    CloseLogButton.Position = UDim2.new(1, -33, 0, 3.5)
    CloseLogButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseLogButton.Text = "X"
    CloseLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseLogButton.Font = Enum.Font.GothamBold
    CloseLogButton.TextSize = 12
    Instance.new("UICorner", CloseLogButton).CornerRadius = UDim.new(0, 5)

    return ScreenGui, MainFrame, LogFrame, ScrollFrame, StatusLabel, HookStatus, InterceptCount, ItemsCount, LastAction, LogButton, DumpButton, CloseButton, CloseLogButton, CopyLogButton
end

-- ===== LOG RENDERING =====
local function refresh_logs(ScrollFrame)
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    for i, entry in ipairs(log_entries) do
        local LogEntry = Instance.new("TextLabel", ScrollFrame)
        LogEntry.Size = UDim2.new(1, -10, 0, 18)
        LogEntry.BackgroundTransparency = 1
        LogEntry.Text = "[" .. entry.time .. "] " .. entry.text
        LogEntry.TextColor3 = entry.color
        LogEntry.Font = Enum.Font.Code
        LogEntry.TextSize = 10
        LogEntry.TextXAlignment = Enum.TextXAlignment.Left
    end

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #log_entries * 20)
end

-- ===== MAIN EXPLOIT =====
add_log("Exploit v11 starting...", Color3.fromRGB(100, 255, 255))

local success, err = pcall(function()
    local ScreenGui, MainFrame, LogFrame, ScrollFrame, StatusLabel, HookStatus, InterceptCount, ItemsCount, LastAction, LogButton, DumpButton, CloseButton, CloseLogButton, CopyLogButton = create_ui()

    add_log("UI created", Color3.fromRGB(100, 255, 100))

    local call_count = 0
    local hook_enabled = true
    local trade_active = false

    -- ===== METAMETHOD HOOK — FULL LOGGING, BYPASS AFTER ACCEPT =====
    local old_namecall
    old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "FireServer" or method == "InvokeServer" then
            local remote_path = tostring(self)

            -- Only log TradeAPI calls
            if remote_path:find("TradeAPI") then
                local remote_name = remote_path:match("/([^/]+)$") or "Unknown"

                -- BYPASS: After AcceptOrDeclineTradeRequest, let all calls through for 5 seconds
                if remote_name == "AcceptOrDeclineTradeRequest" then
                    add_log("⚠️ BYPASS: Disabling hook for 5s to allow trade window", Color3.fromRGB(255, 200, 0))
                    ItemsCount.Text = "Trade Status: Window Opening..."
                    hook_enabled = false
                    spawn(function()
                        wait(5)
                        hook_enabled = true
                        trade_active = true
                        add_log("✓ Hook re-enabled — trade window should be open", Color3.fromRGB(100, 255, 100))
                        ItemsCount.Text = "Trade Status: Active"
                        refresh_logs(ScrollFrame)
                    end)
                end

                -- If hook disabled, pass everything through with logging only
                if not hook_enabled then
                    local call_sig = "🔓 BYPASS: " .. remote_name
                    for i, arg in ipairs(args) do
                        if type(arg) == "string" then
                            call_sig = call_sig .. "/" .. tostring(arg):sub(1, 20)
                        elseif type(arg) == "table" then
                            call_sig = call_sig .. "/[table]"
                        end
                    end
                    add_log(call_sig, Color3.fromRGB(200, 200, 100))
                    LastAction.Text = "Last Remote: " .. remote_name
                    return old_namecall(self, ...)
                end

                -- Build call signature
                local call_signature = remote_name
                local detailed_args = {}

                for i, arg in ipairs(args) do
                    local arg_type = type(arg)
                    if arg_type == "string" then
                        local arg_str = tostring(arg)
                        if arg_str:match("^%d+_[a-f0-9]+$") then
                            call_signature = call_signature .. "/PetID:" .. arg_str:sub(1, 15) .. "..."
                            table.insert(detailed_args, "PetID: " .. arg_str)
                        else
                            call_signature = call_signature .. "/" .. arg_str:sub(1, 30)
                        end
                    elseif arg_type == "table" then
                        local count = 0
                        for _ in pairs(arg) do count = count + 1 end
                        call_signature = call_signature .. "/[table:" .. count .. "]"
                    elseif arg_type == "userdata" then
                        call_signature = call_signature .. "/userdata"
                        table.insert(detailed_args, "userdata: " .. tostring(arg))
                    else
                        call_signature = call_signature .. "/" .. arg_type
                    end
                end

                -- Color coding
                local log_color = Color3.fromRGB(150, 150, 200)
                if remote_name:find("Item") then
                    log_color = Color3.fromRGB(255, 200, 100)
                elseif remote_name == "ConfirmTrade" or remote_name == "AcceptNegotiation" then
                    log_color = Color3.fromRGB(255, 150, 150)
                end

                add_log(call_signature, log_color)
                LastAction.Text = "Last Remote: " .. remote_name

                -- Log detailed args
                if #detailed_args > 0 then
                    for _, detail in ipairs(detailed_args) do
                        add_log("  └─ " .. detail, Color3.fromRGB(120, 120, 150))
                    end
                end

                call_count = call_count + 1
                InterceptCount.Text = "Logged Calls: " .. call_count

                refresh_logs(ScrollFrame)
            end
        end

        return old_namecall(self, ...)
    end))

    add_log("Metamethod hook installed", Color3.fromRGB(100, 255, 100))
    StatusLabel.Text = "STATUS: ARMED | LOGGING ENABLED"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    HookStatus.Text = "Hook: Active (Logging Mode)"
    HookStatus.TextColor3 = Color3.fromRGB(100, 255, 100)

    -- ===== BUTTON HANDLERS =====
    LogButton.MouseButton1Click:Connect(function()
        LogFrame.Visible = not LogFrame.Visible
        LogButton.Text = LogFrame.Visible and "HIDE LOGS" or "SHOW LOGS"
        if LogFrame.Visible then refresh_logs(ScrollFrame) end
    end)

    DumpButton.MouseButton1Click:Connect(function()
        add_log("=== DUMP STARTED ===", Color3.fromRGB(255, 140, 0))
        DumpButton.Text = "..."

        add_log("--- PlayerGui Trade UIs ---", Color3.fromRGB(100, 255, 255))
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:lower():find("trade") then
                add_log("ScreenGui: " .. gui.Name, Color3.fromRGB(255, 255, 100))
            end
        end

        add_log("--- TradeAPI Remotes ---", Color3.fromRGB(100, 255, 255))
        local function scan_remotes(parent, depth)
            if depth > 4 then return end
            for _, child in pairs(parent:GetChildren()) do
                if (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) and child:GetFullName():lower():find("trade") then
                    add_log("Remote: " .. child:GetFullName():gsub("ReplicatedStorage%.", ""), Color3.fromRGB(100, 255, 100))
                elseif child:IsA("Folder") or child:IsA("ModuleScript") then
                    scan_remotes(child, depth + 1)
                end
            end
        end

        scan_remotes(ReplicatedStorage, 0)

        add_log("=== DUMP COMPLETE ===", Color3.fromRGB(255, 140, 0))
        DumpButton.Text = "DUMP"
        LogFrame.Visible = true
        refresh_logs(ScrollFrame)
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    CloseLogButton.MouseButton1Click:Connect(function()
        LogFrame.Visible = false
        LogButton.Text = "SHOW LOGS"
    end)

    CopyLogButton.MouseButton1Click:Connect(function()
        local log_text = "=== ADOPT ME EXPLOIT LOG ===\n"
        for i = #log_entries, 1, -1 do
            log_text = log_text .. "[" .. log_entries[i].time .. "] " .. log_entries[i].text .. "\n"
        end

        if setclipboard then
            setclipboard(log_text)
            add_log("Log copied (" .. #log_entries .. " entries)", Color3.fromRGB(100, 255, 100))
            CopyLogButton.Text = "COPIED ✓"
            wait(2)
            CopyLogButton.Text = "COPY LOG"
        else
            add_log("ERROR: setclipboard() not supported", Color3.fromRGB(255, 80, 80))
        end
        refresh_logs(ScrollFrame)
    end)

    add_log("Exploit armed — trade window will open automatically", Color3.fromRGB(100, 255, 100))
    refresh_logs(ScrollFrame)
end)

if not success then
    warn("[EXPLOIT V11 ERROR] " .. tostring(err))
end
