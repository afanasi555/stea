-- ============================================================
--  STEAL AN EGG — COMPLETE SCRIPT
--  Auto-collect (dynamic income) + Throw Aura + GUI
--  v2.0 | eldorado.gg index | сентябрь 2026
-- ============================================================

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace     = game:GetService("Workspace")

local LocalPlayer   = Players.LocalPlayer
local Mouse         = LocalPlayer:GetMouse()

-- ============================================================
--  СОСТОЯНИЕ
-- ============================================================
local State = {
    AutoCollect  = false,
    ThrowAura    = false,
    MinValue     = 1000,
    ThrowRadius  = 30,
    ThrowForce   = 120,
    CollectDelay = 0.15,
    Connections  = {},
}

-- ============================================================
--  ПОЛНАЯ ТАБЛИЦА ПЕТОВ (160 шт, eldorado.gg, сен 2026)
--  Используется как ФОЛБЭК если живые данные недоступны
-- ============================================================
local PET_VALUES = {
    -- DIVINE
    Aetheron             = 6900000000,
    ArchAngel            = 5000000000,
    WorldBurner          = 5000000000,
    ShatteredColossus    = 3500000000,
    Nightflame           = 3000000000,
    Kitsune              = 1800000000,
    Unicorn              = 1000000000,
    Dreadscale           = 1000000000,
    MechaDreadscale      = 1000000000,
    Cthulhu              = 1000000000,
    LuminousCthulhu      = 1000000000,
    -- ETERNAL
    Equinox              = 1800000000,
    Pegasus              = 1300000000,
    SkeletonHorse        = 1300000000,
    GorillKing           = 880000000,
    VoidSerpent          = 900000000,
    ShatteredDrake       = 800000000,
    WorldEater           = 500000000,
    OniTiger             = 600000000,
    EternalLunarDragon   = 250000000,
    Mosasaurus           = 180000000,
    ElMaja               = 130000000,
    VoidDragon           = 120000000,
    LavaDragon           = 100000000,
    Phoenix              = 85000000,
    IceDragon            = 65000000,
    StrawberryElephant   = 65000000,
    Krakenoid            = 65000000,
    MechaKrakenoid       = 65000000,
    TerraSnapper         = 65000000,
    LuminousTerraSnapper = 65000000,
    -- SECRET
    EmberDragon          = 600000000,
    Centaur              = 350000000,
    RazorFang            = 350000000,
    Stag                 = 145000000,
    Shardwing            = 145000000,
    MutantShark          = 215000000,
    PureJellyfish        = 225000000,
    Gargoyle             = 225000000,
    Experiment001        = 285000000,
    Tralaledon           = 32000000,
    TRex                 = 25000000,
    ScorchedDragon       = 35000000,
    CosmicDragon         = 60000000,
    CosmicSkeletonBoss   = 45000000,
    Mawbreaker           = 60000000,
    Kraken               = 15000000,
    Wendigo              = 15000000,
    Yeti                 = 5000000,
    Cerberus             = 8000000,
    KingSnake            = 3500000,
    BomboclatCrocolat    = 3500000,
    Crocodon             = 3500000,
    MechaCrocodon        = 3500000,
    ElectricEel          = 3500000,
    LuminousElectricEel  = 3500000,
    AbyssOverlord        = 100000000,
    -- COSMIC
    Koi                  = 12000000,
    SnowyOwl             = 7500000,
    Rhinotaur            = 17500000,
    Mantaris             = 11000000,
    SacredMoth           = 16000000,
    HolyPeacock          = 25000000,
    Imp                  = 16000000,
    DemonHound           = 25000000,
    LaVaccaSaturnoSaturnita = 2200000,
    ShatteredRam         = 8000000,
    Dreadclaw            = 2200000,
    Ventinal             = 585000,
    Drilla               = 100000000,
    Nibbles013           = 185000,
    Triceratops          = 1200000,
    Bronto               = 1500000,
    BelugaWhale          = 850000,
    WhaleShark           = 700000,
    KingMammoth          = 400000,
    RoyalSphinx          = 280000,
    Leviathan            = 220000,
    MangoliniParrochini  = 220000,
    Crawler              = 220000,
    MechaCrawler         = 220000,
    AbyssShark           = 220000,
    LuminousAbyssShark   = 220000,
    -- MYTHIC
    WingedLamb           = 1250000,
    Toro                 = 1250000,
    Bladehide            = 750000,
    RedPanda             = 450000,
    Shardling            = 450000,
    CosmicGorilla        = 180000,
    Ankylosaurus         = 120000,
    Orca                 = 80000,
    ChillinChilli        = 55000,
    Mammoth              = 42000,
    SabertoothTiger      = 35000,
    Tiger                = 28000,
    Spider               = 22000,
    Riftwing             = 220000,
    Voidmaw              = 50000,
    Scorpion             = 18500,
    SandSpider           = 16000,
    ShadowDragon         = 25000000,
    BelulaBluga          = 20000,
    Froggo               = 20000,
    MechaFroggo          = 20000,
    SpiritManta          = 20000,
    LuminousSpiritManta  = 20000,
    -- LEGENDARY
    LightDove            = 225000,
    FlameSprite          = 225000,
    Crustacia            = 130000,
    Spideron             = 95000,
    Salamander           = 74000,
    CosmicGecko          = 30000,
    Pterodactyl          = 22000,
    Shark                = 15000,
    LavaIguana           = 11000,
    FlamingBull          = 9500,
    PolarBear            = 7000,
    OrangutiniAnanassini = 5500,
    BabyAuroraDragon     = 5000000,
    Gorilla              = 4800,
    Snake                = 3600,
    Axolotl              = 2800,
    BrrBrrPatapim        = 1800,
    RiftEye              = 11000,
    VoidAngler           = 30000,
    Scorpio              = 5000,
    MechaScorpio         = 5000,
    Spike                = 5000,
    LuminousSpike        = 5000,
    -- EPIC
    Crane                = 4000,
    Centapede            = 1500,
    Swordfish            = 1100,
    LavaFrog             = 850,
    Walrus               = 600,
    Crocodile            = 420,
    TobTobiTobTob        = 325,
    Swan                 = 320,
    TrulimeroTrulicina   = 260,
    Bear                 = 240,
    Fox                  = 180,
    BananitaDolphinita   = 250,
    -- RARE
    Dodo                 = 280,
    LavaGecko            = 180,
    Parrotfish           = 220,
    Penguin              = 140,
    Toucan               = 110,
    Chimpanzee           = 90,
    Camel                = 75,
    Turtle               = 60,
    Raccoon              = 45,
    Owl                  = 35,
    TungTungSahur        = 40,
    -- UNCOMMON
    Fennec               = 18,
    Catfish              = 12,
    Bird                 = 8,
    -- COMMON
    Jerboa               = 6,
    Duckling             = 4,
    Frog                 = 3,
    Dog                  = 2,
    Chicken              = 1,
}

-- ============================================================
--  ДИНАМИЧЕСКИЙ ДОХОД — читает живые данные из объекта
-- ============================================================
local INCOME_ATTRS  = {"Income","MoneyPerSecond","Mps","Earnings","IncomePerSecond","Value","Money","Cash","EarningsPerSecond","Profit","Revenue"}
local MUTATION_ATTRS= {"Multiplier","MutationMultiplier","Boost","IncomeMultiplier","Modifier","Multi"}
local SIZE_MULT     = {tiny=0.5,small=0.75,normal=1,big=2,huge=4,giant=8}

local function readAttr(obj, list)
    for _, name in ipairs(list) do
        local ok, v = pcall(function() return obj:GetAttribute(name) end)
        if ok and type(v) == "number" and v > 0 then return v end
    end
end

local function getRealIncome(obj)
    -- 1. атрибуты
    local v = readAttr(obj, INCOME_ATTRS)
    if v then return v end
    -- 2. NumberValue / IntValue в детях
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("NumberValue") or c:IsA("IntValue") then
            for _, name in ipairs(INCOME_ATTRS) do
                if c.Name:lower() == name:lower() and c.Value > 0 then
                    return c.Value
                end
            end
        end
        if c:IsA("StringValue") then
            for _, name in ipairs(INCOME_ATTRS) do
                if c.Name:lower() == name:lower() then
                    local n = tonumber(c.Value:match("[%d%.]+"))
                    if n and n > 0 then return n end
                end
            end
        end
    end
    -- 3. PrimaryPart атрибуты
    if obj:IsA("Model") then
        local root = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        if root then
            local rv = readAttr(root, INCOME_ATTRS)
            if rv then return rv end
        end
    end
    return nil
end

local function getMutMult(obj)
    local v = readAttr(obj, MUTATION_ATTRS)
    if v and v > 1 then return v end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("NumberValue") then
            for _, name in ipairs(MUTATION_ATTRS) do
                if c.Name:lower() == name:lower() and c.Value > 1 then return c.Value end
            end
        end
    end
    return 1
end

local function getSizeMult(obj)
    local s
    local ok, v = pcall(function() return obj:GetAttribute("Size") end)
    if ok and type(v) == "string" then s = v:lower() end
    if not s then
        local sv = obj:FindFirstChild("Size")
        if sv and sv:IsA("StringValue") then s = sv.Value:lower() end
    end
    if s then
        for name, m in pairs(SIZE_MULT) do
            if s:find(name) then return m end
        end
    end
    return 1
end

local function getPetValueFallback(obj)
    local raw = obj.Name:gsub("[%s%-_#]",""):lower()
    local best = 0
    for k, v in pairs(PET_VALUES) do
        local key = k:lower()
        if raw:find(key) or key:find(raw) then
            if v > best then best = v end
        end
    end
    return best
end

local function getEffectiveIncome(obj)
    local live = getRealIncome(obj)
    if live then
        return live * getSizeMult(obj)
    end
    local base = getPetValueFallback(obj)
    if base == 0 then return 0 end
    return base * getMutMult(obj) * getSizeMult(obj)
end

-- ============================================================
--  СБОР ЯИЦ — возвращает список отсортированный по доходу
-- ============================================================
local SEARCH_FOLDERS = {"Eggs","Items","Collectibles","Map","Pets","Drops","Workspace"}

local function getEggs()
    local eggs, seen = {}, {}
    for _, fname in ipairs(SEARCH_FOLDERS) do
        local f = fname == "Workspace" and Workspace
              or Workspace:FindFirstChild(fname, true)
        if f then
            for _, obj in ipairs(f:GetDescendants()) do
                if not seen[obj]
                    and (obj:IsA("BasePart") or obj:IsA("Model"))
                    and not obj:FindFirstChildOfClass("Humanoid")
                then
                    local inc = getEffectiveIncome(obj)
                    if inc >= State.MinValue then
                        seen[obj] = true
                        table.insert(eggs, {obj=obj, value=inc})
                    end
                end
            end
        end
    end
    table.sort(eggs, function(a,b) return a.value > b.value end)
    return eggs
end

-- ============================================================
--  УТИЛИТЫ ДВИЖЕНИЯ
-- ============================================================
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function walkTo(pos)
    local c = LocalPlayer.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then h:MoveTo(pos) end
end

local function objPos(obj)
    if obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        return p and p.Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
end

-- ============================================================
--  АВТО-СБОР
-- ============================================================
local function startAutoCollect()
    if State.Connections["collect"] then
        State.Connections["collect"]:Disconnect()
    end
    local tick = 0
    State.Connections["collect"] = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoCollect then return end
        tick = tick + dt
        if tick < State.CollectDelay then return end
        tick = 0

        local hrp = getHRP()
        if not hrp then return end
        local eggs = getEggs()
        if #eggs == 0 then return end

        local pos = objPos(eggs[1].obj)
        if not pos then return end
        if (hrp.Position - pos).Magnitude > 5 then
            walkTo(pos)
        end
    end)
end

-- ============================================================
--  ВЫКИДЫВАНИЕ АУРЫ
-- ============================================================
local function throwNearby()
    local hrp = getHRP()
    if not hrp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local oh = p.Character:FindFirstChild("HumanoidRootPart")
            if oh then
                local dist = (hrp.Position - oh.Position).Magnitude
                if dist <= State.ThrowRadius then
                    local dir = (oh.Position - hrp.Position).Unit
                    oh.Velocity = Vector3.new(
                        dir.X * State.ThrowForce,
                        State.ThrowForce * 1.5,
                        dir.Z * State.ThrowForce
                    )
                    oh.CFrame = CFrame.new(oh.Position + Vector3.new(
                        dir.X * 2000, 500, dir.Z * 2000
                    ))
                end
            end
        end
    end
end

local function startThrowAura()
    if State.Connections["throw"] then
        State.Connections["throw"]:Disconnect()
    end
    local tick = 0
    State.Connections["throw"] = RunService.Heartbeat:Connect(function(dt)
        if not State.ThrowAura then return end
        tick = tick + dt
        if tick < 0.5 then return end
        tick = 0
        throwNearby()
    end)
end

-- ============================================================
--  GUI
-- ============================================================
-- Чистим старый экземпляр если был
local old = LocalPlayer.PlayerGui:FindFirstChild("SAE_Menu")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "SAE_Menu"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = LocalPlayer.PlayerGui

-- Кнопка скрыть/показать
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size            = UDim2.new(0,36,0,36)
ToggleBtn.Position        = UDim2.new(0,10,0.5,-18)
ToggleBtn.BackgroundColor3= Color3.fromRGB(20,20,30)
ToggleBtn.TextColor3      = Color3.fromRGB(255,220,80)
ToggleBtn.Text            = "☰"
ToggleBtn.Font            = Enum.Font.GothamBold
ToggleBtn.TextSize        = 20
Instance.new("UICorner",ToggleBtn).CornerRadius = UDim.new(0,8)

-- Главный фрейм
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size              = UDim2.new(0,290,0,420)
Frame.Position          = UDim2.new(0.5,-145,0.5,-210)
Frame.BackgroundColor3  = Color3.fromRGB(14,14,22)
Frame.BorderSizePixel   = 0
Frame.ClipsDescendants  = true
Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke",Frame)
stroke.Color     = Color3.fromRGB(80,60,200)
stroke.Thickness = 1.5

-- Заголовок
local Title = Instance.new("TextLabel", Frame)
Title.Size             = UDim2.new(1,0,0,40)
Title.BackgroundColor3 = Color3.fromRGB(25,15,55)
Title.Text             = "  🥚  Steal an Egg v2.0"
Title.Font             = Enum.Font.GothamBold
Title.TextSize         = 14
Title.TextColor3       = Color3.fromRGB(220,200,255)
Title.TextXAlignment   = Enum.TextXAlignment.Left
Instance.new("UICorner",Title).CornerRadius = UDim.new(0,12)

-- Layout + Padding
local Layout = Instance.new("UIListLayout", Frame)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding   = UDim.new(0,6)
local Pad = Instance.new("UIPadding", Frame)
Pad.PaddingTop   = UDim.new(0,46)
Pad.PaddingLeft  = UDim.new(0,10)
Pad.PaddingRight = UDim.new(0,10)

-- ── Хелперы ──────────────────────────────────────────────────

local function makeRow(parent, h)
    local r = Instance.new("Frame", parent)
    r.Size             = UDim2.new(1,0,0,h or 38)
    r.BackgroundColor3 = Color3.fromRGB(22,22,36)
    r.BorderSizePixel  = 0
    Instance.new("UICorner",r).CornerRadius = UDim.new(0,8)
    return r
end

local function makeLabel(parent, text, size)
    local l = Instance.new("TextLabel", parent)
    l.Size               = UDim2.new(0.72,0,1,0)
    l.Position           = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1
    l.Text               = text
    l.Font               = Enum.Font.Gotham
    l.TextSize           = size or 13
    l.TextColor3         = Color3.fromRGB(200,200,220)
    l.TextXAlignment     = Enum.TextXAlignment.Left
    return l
end

local function makeToggle(labelText, stateKey, onEnable)
    local row = makeRow(Frame, 38)
    makeLabel(row, labelText)

    local btn = Instance.new("TextButton", row)
    btn.Size             = UDim2.new(0,52,0,24)
    btn.Position         = UDim2.new(1,-62,0.5,-12)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    btn.Text             = "OFF"
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 12
    btn.TextColor3       = Color3.fromRGB(160,160,180)
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        if State[stateKey] then
            btn.BackgroundColor3 = Color3.fromRGB(70,40,180)
            btn.Text             = "ON"
            btn.TextColor3       = Color3.fromRGB(220,200,255)
            if onEnable then onEnable() end
        else
            btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
            btn.Text             = "OFF"
            btn.TextColor3       = Color3.fromRGB(160,160,180)
        end
    end)
    return row
end

local function makeSlider(labelText, minV, maxV, defaultV, onChange)
    local row = makeRow(Frame, 52)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size             = UDim2.new(1,-10,0,20)
    lbl.Position         = UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Text             = labelText..": "..tostring(defaultV)
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 12
    lbl.TextColor3       = Color3.fromRGB(180,180,210)
    lbl.TextXAlignment   = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size             = UDim2.new(1,-20,0,8)
    track.Position         = UDim2.new(0,10,0,32)
    track.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Instance.new("UICorner",track).CornerRadius = UDim.new(0,4)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((defaultV-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(100,70,220)
    Instance.new("UICorner",fill).CornerRadius = UDim.new(0,4)

    local knob = Instance.new("TextButton", track)
    knob.Size             = UDim2.new(0,16,0,16)
    knob.Position         = UDim2.new((defaultV-minV)/(maxV-minV),-8,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(180,140,255)
    knob.Text             = ""
    Instance.new("UICorner",knob).CornerRadius = UDim.new(0,8)

    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local abs  = track.AbsolutePosition
            local sz   = track.AbsoluteSize
            local rel  = math.clamp((i.Position.X - abs.X) / sz.X, 0, 1)
            local val  = math.floor(minV + rel*(maxV-minV))
            fill.Size  = UDim2.new(rel,0,1,0)
            knob.Position = UDim2.new(rel,-8,0.5,-8)
            lbl.Text   = labelText..": "..tostring(val)
            if onChange then onChange(val) end
        end
    end)
end

-- ── Строим меню ───────────────────────────────────────────────

makeToggle("🥚  Авто-сбор (лучший пет)", "AutoCollect", startAutoCollect)
makeToggle("💫  Выкидывание ауры",        "ThrowAura",   startThrowAura)

makeSlider("Мин. доход ($/сек)", 0, 1000000, State.MinValue, function(v)
    State.MinValue = v
end)
makeSlider("Радиус ауры (студдов)", 5, 150, State.ThrowRadius, function(v)
    State.ThrowRadius = v
end)
makeSlider("Сила броска", 50, 300, State.ThrowForce, function(v)
    State.ThrowForce = v
end)

-- Статус
local StatusRow = makeRow(Frame, 28)
local StatusLbl = Instance.new("TextLabel", StatusRow)
StatusLbl.Size               = UDim2.new(1,-10,1,0)
StatusLbl.Position           = UDim2.new(0,10,0,0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text               = "Статус: ожидание"
StatusLbl.Font               = Enum.Font.Gotham
StatusLbl.TextSize           = 11
StatusLbl.TextColor3         = Color3.fromRGB(120,120,150)
StatusLbl.TextXAlignment     = Enum.TextXAlignment.Left

-- Живой статус
RunService.Heartbeat:Connect(function()
    local parts = {}
    if State.AutoCollect then table.insert(parts,"Сбор ✓") end
    if State.ThrowAura   then table.insert(parts,"Аура ✓") end
    StatusLbl.Text = "Статус: "..(#parts>0 and table.concat(parts," | ") or "ожидание")
end)

-- ── Перетаскивание ────────────────────────────────────────────
local function makeDraggable(frame, handle)
    local drag, ds, sp = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(
                sp.X.Scale, sp.X.Offset + d.X,
                sp.Y.Scale, sp.Y.Offset + d.Y
            )
        end
    end)
end

makeDraggable(Frame,     Title)
makeDraggable(ToggleBtn, ToggleBtn)

-- ── Скрыть / показать ─────────────────────────────────────────
local visible = true
ToggleBtn.MouseButton1Click:Connect(function()
    visible = not visible
    Frame.Visible = visible
    ToggleBtn.Text = visible and "✕" or "☰"
end)

-- ============================================================
--  ЗАПУСК
-- ============================================================
startAutoCollect()
startThrowAura()
