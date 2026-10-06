-- adopt_me_trade_exploit.lua v10
-- Updated: 2026-10-07 | Visual pet removal strategy
-- Method: RemoveItemFromOffer after AddItemToOffer with UI preservation

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup only our exploit UI — DO NOT touch game UI
if PlayerGui:FindFirstChild("TradeExploitUI") then
    PlayerGui.TradeExploitUI:Destroy()
    wait(0.3)
end

-- ===== LOG SYSTEM =====
local log_entries = {}
local max_logs = 100

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
    MainFrame.Size = UDim2.new(0, 360, 0, 210)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -105)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainFrame.Parent = ScreenGui

    -- CRITICAL: Set low ZIndex so game UI stays on top
    for _, child in pairs(MainFrame:GetDescendants()) do
        if child:IsA("GuiObject") then
            child.ZIndex = 1
        end
    end
    MainFrame.ZIndex = 1

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local Header = Instance.new("TextLabel", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Header.BorderSizePixel = 0
    Header.Text = "ADOPT ME EXPLOIT V10"
    Header.TextColor3 = Color3.fromRGB(255, 70, 70)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 14
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

    local VersionLabel = Instance.new("TextLabel", Header)
    VersionLabel.Size = UDim2.new(0, 100, 1, 0)
    VersionLabel.Position = UDim2.new(1, -105, 0, 0)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "v10.2026"
    VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    VersionLabel.Font = Enum.Font.Code
    VersionLabel.TextSize = 10
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
    InterceptCount.Text = "Blocked Trades: 0"
    InterceptCount.TextColor3 = Color3.fromRGB(180, 180, 180)
    InterceptCount.Font = Enum.Font.Gotham
    InterceptCount.TextSize = 11
    InterceptCount.TextXAlignment = Enum.TextXAlignment.Left

    local ItemsCount = Instance.new("TextLabel", MainFrame)
    ItemsCount.Size = UDim2.new(1, -20, 0, 20)
    ItemsCount.Position = UDim2.new(0, 10, 0, 115)
    ItemsCount.BackgroundTransparency = 1
    ItemsCount.Text = "Last Intercept: None"
    ItemsCount.TextColor3 = Color3.fromRGB(180, 180, 180)
    ItemsCount.Font = Enum.Font.Gotham
    ItemsCount.TextSize = 11
    ItemsCount.TextXAlignment = Enum.TextXAlignment.Left

    local LastAction = Instance.new("TextLabel", MainFrame)
    LastAction.Size = UDim2.new(1, -20, 0, 20)
    LastAction.Position = UDim2.new(0, 10, 0, 135)
    LastAction.BackgroundTransparency = 1
    LastAction.Text = "Last Action: N/A"
    LastAction.TextColor3 = Color3.fromRGB(150, 150, 150)
    LastAction.Font = Enum.Font.Code
    LastAction.TextSize = 10
    LastAction.TextXAlignment = Enum.TextXAlignment.Left

    local LogButton = Instance.new("TextButton", MainFrame)
    LogButton.Size = UDim2.new(0, 70, 0, 32)
    LogButton.Position = UDim2.new(0, 10, 1, -42)
    LogButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    LogButton.Text = "LOGS"
    LogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogButton.Font = Enum.Font.GothamBold
    LogButton.TextSize = 10
    Instance.new("UICorner", LogButton).CornerRadius = UDim.new(0, 6)

    local DumpButton = Instance.new("TextButton", MainFrame)
    DumpButton.Size = UDim2.new(0, 70, 0, 32)
    DumpButton.Position = UDim2.new(0, 85, 1, -42)
    DumpButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    DumpButton.Text = "DUMP"
    DumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DumpButton.Font = Enum.Font.GothamBold
    DumpButton.TextSize = 10
    Instance.new("UICorner", DumpButton).CornerRadius = UDim.new(0, 6)

    local RemovePetButton = Instance.new("TextButton", MainFrame)
    RemovePetButton.Size = UDim2.new(0, 100, 0, 32)
    RemovePetButton.Position = UDim2.new(0, 160, 1, -42)
    RemovePetButton.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    RemovePetButton.Text = "REMOVE PET"
    RemovePetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RemovePetButton.Font = Enum.Font.GothamBold
    RemovePetButton.TextSize = 9
    Instance.new("UICorner", RemovePetButton).CornerRadius = UDim.new(0, 6)

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
    LogFrame.Size = UDim2.new(0, 480, 0, 350)
    LogFrame.Position = UDim2.new(0.5, -240, 0.5, -175)
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
    LogHeader.Text = "EXPLOIT LOGS"
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
    CopyLogButton.Size = UDim2.new(0, 100, 0, 28)
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

    return ScreenGui, MainFrame, LogFrame, ScrollFrame, StatusLabel, HookStatus, InterceptCount, ItemsCount, LastAction, LogButton, DumpButton, RemovePetButton, CloseButton, CloseLogButton, CopyLogButton
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
add_log("Exploit v3 starting...", Color3.fromRGB(100, 255, 255))

local success, err = pcall(function()
    local ScreenGui, MainFrame, LogFrame, ScrollFrame, StatusLabel, HookStatus, InterceptCount, ItemsCount, LastAction, LogButton, DumpButton, RemovePetButton, CloseButton, CloseLogButton, CopyLogButton = create_ui()

    add_log("UI created", Color3.fromRGB(100, 255, 100))

    local blocked_count = 0
    local last_pet_id = nil  -- Track last added pet ID
    local trade_api_remote = nil  -- Store TradeAPI remote reference

    -- ===== METAMETHOD HOOK — FULL DIAGNOSTIC LOGGING =====
    local old_namecall
    old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "FireServer" or method == "InvokeServer" then
            local remote_path = tostring(self)

            -- Only intercept TradeAPI calls
            if remote_path:find("TradeAPI") then
                -- Store remote reference for manual operations
                if not trade_api_remote then
                    trade_api_remote = self
                end

                -- Extract remote name
                local remote_name = remote_path:match("/([^/]+)$") or "Unknown"

                -- Track pet IDs from AddItemToOffer
                if remote_name == "AddItemToOffer" then
                    for i, arg in ipairs(args) do
                        if type(arg) == "string" and arg:match("^%d+_[a-f0-9]{32}$") then
                            last_pet_id = arg
                            add_log("📌 Tracked Pet ID: " .. arg:sub(1, 20) .. "...", Color3.fromRGB(100, 255, 255))
                        elseif type(arg) == "table" then
                            for k, v in pairs(arg) do
                                if type(v) == "string" and v:match("^%d+_[a-f0-9]{32}$") then
                                    last_pet_id = v
                                    add_log("📌 Tracked Pet ID: " .. v:sub(1, 20) .. "...", Color3.fromRGB(100, 255, 255))
                                end
                            end
                        end
                    end
                end

                -- Build FULL call signature with remote name
                local call_signature = remote_name
                local detailed_args = {}

                for i, arg in ipairs(args) do
                    local arg_type = type(arg)
                    if arg_type == "string" then
                        local arg_str = tostring(arg)
                        -- Truncate long strings but show full pet IDs
                        if arg_str:match("^%d+_[a-f0-9]+$") then
                            call_signature = call_signature .. "/PetID:" .. arg_str:sub(1, 15) .. "..."
                            table.insert(detailed_args, "PetID: " .. arg_str)
                        else
                            call_signature = call_signature .. "/" .. arg_str:sub(1, 30)
                            table.insert(detailed_args, "str: " .. arg_str:sub(1, 50))
                        end
                    elseif arg_type == "table" then
                        local count = 0
                        local has_pet_id = false
                        for k, v in pairs(arg) do
                            count = count + 1
                            if type(v) == "string" and v:match("^%d+_[a-f0-9]+$") then
                                has_pet_id = true
                                table.insert(detailed_args, "table[" .. tostring(k) .. "]: " .. v)
                            end
                        end
                        call_signature = call_signature .. "/[table:" .. count .. "]"
                        if has_pet_id then
                            call_signature = call_signature .. "*PET"
                        end
                    elseif arg_type == "userdata" then
                        call_signature = call_signature .. "/userdata"
                        table.insert(detailed_args, "userdata: " .. tostring(arg))
                    else
                        call_signature = call_signature .. "/" .. arg_type
                    end
                end

                -- Log with color coding
                local log_color = Color3.fromRGB(150, 150, 200)
                if remote_name == "AddItemToOffer" or remote_name:find("Item") then
                    log_color = Color3.fromRGB(255, 200, 100)
                elseif remote_name == "ConfirmTrade" or remote_name == "AcceptNegotiation" then
                    log_color = Color3.fromRGB(255, 150, 150)
                end

                add_log(call_signature, log_color)
                LastAction.Text = "Last: " .. remote_name

                -- Log detailed args if they exist
                if #detailed_args > 0 then
                    for _, detail in ipairs(detailed_args) do
                        add_log("  └─ " .. detail, Color3.fromRGB(120, 120, 150))
                    end
                end

                -- INTERCEPT STRATEGY: Block GiveItem
                if remote_name == "GiveItem" then
                    add_log("🔴🔴🔴 BLOCKING: GiveItem", Color3.fromRGB(255, 0, 0))
                    blocked_count = blocked_count + 1
                    InterceptCount.Text = "Blocked: " .. blocked_count
                    ItemsCount.Text = "BLOCKED: GiveItem"
                    add_log("✓ Item transfer blocked", Color3.fromRGB(100, 255, 100))
                    refresh_logs(ScrollFrame)
                    return old_namecall(self)
                end

                -- INTERCEPT: Direct pet ID calls (outside of AddItemToOffer)
                if type(args[1]) == "string" and args[1]:match("^%d+_[a-f0-9]{32}$") then
                    if remote_name ~= "AddItemToOffer" and remote_name ~= "RemoveItemFromOffer" then
                        add_log("🔴 BLOCKING: Direct pet ID on " .. remote_name, Color3.fromRGB(255, 100, 0))
                        blocked_count = blocked_count + 1
                        InterceptCount.Text = "Blocked: " .. blocked_count
                        ItemsCount.Text = "BLOCKED: " .. remote_name
                        add_log("✓ Pet transfer cancelled", Color3.fromRGB(100, 255, 100))
                        refresh_logs(ScrollFrame)
                        return old_namecall(self)
                    end
                end

                refresh_logs(ScrollFrame)
            end
        end

        return old_namecall(self, ...)
    end))

    add_log("Metamethod hook installed", Color3.fromRGB(100, 255, 100))
    StatusLabel.Text = "STATUS: ARMED | INTERCEPTING"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    HookStatus.Text = "Hook: Active (TradeAPI)"
    HookStatus.TextColor3 = Color3.fromRGB(100, 255, 100)

    -- ===== BUTTON HANDLERS =====
    LogButton.MouseButton1Click:Connect(function()
        LogFrame.Visible = not LogFrame.Visible
        if LogFrame.Visible then refresh_logs(ScrollFrame) end
    end)

    RemovePetButton.MouseButton1Click:Connect(function()
        if not last_pet_id then
            add_log("❌ No pet ID tracked — add pet to trade first", Color3.fromRGB(255, 100, 100))
            ItemsCount.Text = "ERROR: No pet tracked"
            ItemsCount.TextColor3 = Color3.fromRGB(255, 100, 100)
            refresh_logs(ScrollFrame)
            return
        end

        if not trade_api_remote then
            add_log("❌ TradeAPI remote not found", Color3.fromRGB(255, 100, 100))
            ItemsCount.Text = "ERROR: Remote not found"
            refresh_logs(ScrollFrame)
            return
        end

        add_log("🔴 MANUALLY REMOVING PET: " .. last_pet_id:sub(1, 25), Color3.fromRGB(255, 50, 50))
        RemovePetButton.Text = "REMOVING..."

        -- Find RemoveItemFromOffer remote
        local remove_remote = nil
        for _, remote in pairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                if tostring(remote):find("RemoveItemFromOffer") then
                    remove_remote = remote
                    break
                end
            end
        end

        if remove_remote then
            -- Call RemoveItemFromOffer with the tracked pet ID
            pcall(function()
                remove_remote:FireServer(last_pet_id)
            end)
            add_log("✓ RemoveItemFromOffer called with pet ID", Color3.fromRGB(100, 255, 100))
            ItemsCount.Text = "Pet removed (visual stays)"
            ItemsCount.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            add_log("❌ RemoveItemFromOffer remote not found", Color3.fromRGB(255, 100, 100))
            ItemsCount.Text = "ERROR: Remote missing"
        end

        wait(1)
        RemovePetButton.Text = "REMOVE PET"
        refresh_logs(ScrollFrame)
    end)

    DumpButton.MouseButton1Click:Connect(function()
        add_log("=== DUMP STARTED ===", Color3.fromRGB(255, 140, 0))
        DumpButton.Text = "..."

        -- Dump PlayerGui
        add_log("--- PlayerGui Dump ---", Color3.fromRGB(100, 255, 255))
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:lower():find("trade") or gui.Name:lower():find("shop")) then
                add_log("ScreenGui: " .. gui.Name, Color3.fromRGB(255, 255, 100))
                for _, child in pairs(gui:GetDescendants()) do
                    if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                        add_log("  " .. child.ClassName .. ": " .. child.Name, Color3.fromRGB(200, 200, 200))
                    end
                end
            end
        end

        -- Dump ReplicatedStorage TradeAPI
        add_log("--- TradeAPI Remotes ---", Color3.fromRGB(100, 255, 255))
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
    end)

    CopyLogButton.MouseButton1Click:Connect(function()
        local log_text = "=== ADOPT ME EXPLOIT LOG ===\n"
        for i = #log_entries, 1, -1 do
            local entry = log_entries[i]
            log_text = log_text .. "[" .. entry.time .. "] " .. entry.text .. "\n"
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

    add_log("Exploit armed — waiting for ConfirmTrade", Color3.fromRGB(100, 255, 100))
    refresh_logs(ScrollFrame)
end)

if not success then
    warn("[EXPLOIT V3 ERROR] " .. tostring(err))
    add_log("FATAL: " .. tostring(err), Color3.fromRGB(255, 50, 50))
end
