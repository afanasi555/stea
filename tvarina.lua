-- ============================================================
--  STEAL AN EGG — COMPLETE SCRIPT v4.0
--  + Fly Mode: Straight / Zigzag (wall-aware)
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  СОСТОЯНИЕ
-- ============================================================
local State = {
    AutoCollect   = false,
    ThrowAura     = false,
    SpeedBoost    = false,
    FlyMode       = "straight",   -- "straight" | "zigzag"
    WalkSpeed     = 16,
    FlySpeed      = 5000,
    ThrowRadius   = 30,
    ThrowForce    = 120,
    CollectDelay  = 0.1,
    MinValue      = 1000,
    Connections   = {},
    Flying        = false,
    ZigTime       = 0,            -- таймер для синуса
}

-- ============================================================
--  ТАБЛИЦА ПЕТОВ (160 шт)
-- ============================================================
local PET_VALUES = {
    Aetheron=6900000000,ArchAngel=5000000000,WorldBurner=5000000000,
    ShatteredColossus=3500000000,Nightflame=3000000000,Kitsune=1800000000,
    Unicorn=1000000000,Dreadscale=1000000000,MechaDreadscale=1000000000,
    Cthulhu=1000000000,LuminousCthulhu=1000000000,
    Equinox=1800000000,Pegasus=1300000000,SkeletonHorse=1300000000,
    GorillKing=880000000,VoidSerpent=900000000,ShatteredDrake=800000000,
    WorldEater=500000000,OniTiger=600000000,EternalLunarDragon=250000000,
    Mosasaurus=180000000,ElMaja=130000000,VoidDragon=120000000,
    LavaDragon=100000000,Phoenix=85000000,IceDragon=65000000,
    StrawberryElephant=65000000,Krakenoid=65000000,MechaKrakenoid=65000000,
    TerraSnapper=65000000,LuminousTerraSnapper=65000000,
    EmberDragon=600000000,Centaur=350000000,RazorFang=350000000,
    Stag=145000000,Shardwing=145000000,MutantShark=215000000,
    PureJellyfish=225000000,Gargoyle=225000000,Experiment001=285000000,
    Tralaledon=32000000,TRex=25000000,ScorchedDragon=35000000,
    CosmicDragon=60000000,CosmicSkeletonBoss=45000000,Mawbreaker=60000000,
    Kraken=15000000,Wendigo=15000000,Yeti=5000000,Cerberus=8000000,
    KingSnake=3500000,BomboclatCrocolat=3500000,Crocodon=3500000,
    MechaCrocodon=3500000,ElectricEel=3500000,LuminousElectricEel=3500000,
    AbyssOverlord=100000000,
    Koi=12000000,SnowyOwl=7500000,Rhinotaur=17500000,Mantaris=11000000,
    SacredMoth=16000000,HolyPeacock=25000000,Imp=16000000,DemonHound=25000000,
    LaVaccaSaturnoSaturnita=2200000,ShatteredRam=8000000,Dreadclaw=2200000,
    Ventinal=585000,Drilla=100000000,Nibbles013=185000,
    Triceratops=1200000,Bronto=1500000,BelugaWhale=850000,WhaleShark=700000,
    KingMammoth=400000,RoyalSphinx=280000,Leviathan=220000,
    MangoliniParrochini=220000,Crawler=220000,MechaCrawler=220000,
    AbyssShark=220000,LuminousAbyssShark=220000,
    WingedLamb=1250000,Toro=1250000,Bladehide=750000,RedPanda=450000,
    Shardling=450000,CosmicGorilla=180000,Ankylosaurus=120000,Orca=80000,
    ChillinChilli=55000,Mammoth=42000,SabertoothTiger=35000,Tiger=28000,
    Spider=22000,Riftwing=220000,Voidmaw=50000,Scorpion=18500,
    SandSpider=16000,ShadowDragon=25000000,BelulaBluga=20000,Froggo=20000,
    MechaFroggo=20000,SpiritManta=20000,LuminousSpiritManta=20000,
    LightDove=225000,FlameSprite=225000,Crustacia=130000,Spideron=95000,
    Salamander=74000,CosmicGecko=30000,Pterodactyl=22000,Shark=15000,
    LavaIguana=11000,FlamingBull=9500,PolarBear=7000,
    OrangutiniAnanassini=5500,BabyAuroraDragon=5000000,Gorilla=4800,
    Snake=3600,Axolotl=2800,BrrBrrPatapim=1800,RiftEye=11000,
    VoidAngler=30000,Scorpio=5000,MechaScorpio=5000,Spike=5000,
    LuminousSpike=5000,
    Crane=4000,Centapede=1500,Swordfish=1100,LavaFrog=850,Walrus=600,
    Crocodile=420,TobTobiTobTob=325,Swan=320,TrulimeroTrulicina=260,
    Bear=240,Fox=180,BananitaDolphinita=250,
    Dodo=280,LavaGecko=180,Parrotfish=220,Penguin=140,Toucan=110,
    Chimpanzee=90,Camel=75,Turtle=60,Raccoon=45,Owl=35,TungTungSahur=40,
    Fennec=18,Catfish=12,Bird=8,
    Jerboa=6,Duckling=4,Frog=3,Dog=2,Chicken=1,
}

-- ============================================================
--  ДИНАМИЧЕСКИЙ ДОХОД
-- ============================================================
local INCOME_ATTRS   = {"Income","MoneyPerSecond","Mps","Earnings","IncomePerSecond","Value","Money","Cash","EarningsPerSecond","Profit","Revenue"}
local MUTATION_ATTRS = {"Multiplier","MutationMultiplier","Boost","IncomeMultiplier","Modifier","Multi"}
local SIZE_MULT      = {tiny=0.5,small=0.75,normal=1,big=2,huge=4,giant=8}

local function readAttr(obj, list)
    for _, name in ipairs(list) do
        local ok, v = pcall(function() return obj:GetAttribute(name) end)
        if ok and type(v)=="number" and v>0 then return v end
    end
end

local function getRealIncome(obj)
    local v = readAttr(obj, INCOME_ATTRS)
    if v then return v end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("NumberValue") or c:IsA("IntValue") then
            for _, n in ipairs(INCOME_ATTRS) do
                if c.Name:lower()==n:lower() and c.Value>0 then return c.Value end
            end
        end
        if c:IsA("StringValue") then
            for _, n in ipairs(INCOME_ATTRS) do
                if c.Name:lower()==n:lower() then
                    local num = tonumber(c.Value:match("[%d%.]+"))
                    if num and num>0 then return num end
                end
            end
        end
    end
    if obj:IsA("Model") then
        local r = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        if r then local rv=readAttr(r,INCOME_ATTRS) if rv then return rv end end
    end
end

local function getMutMult(obj)
    local v = readAttr(obj, MUTATION_ATTRS)
    if v and v>1 then return v end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("NumberValue") then
            for _, n in ipairs(MUTATION_ATTRS) do
                if c.Name:lower()==n:lower() and c.Value>1 then return c.Value end
            end
        end
    end
    return 1
end

local function getSizeMult(obj)
    local s
    local ok,v = pcall(function() return obj:GetAttribute("Size") end)
    if ok and type(v)=="string" then s=v:lower() end
    if not s then
        local sv=obj:FindFirstChild("Size")
        if sv and sv:IsA("StringValue") then s=sv.Value:lower() end
    end
    if s then for n,m in pairs(SIZE_MULT) do if s:find(n) then return m end end end
    return 1
end

local function getFallback(obj)
    local raw = obj.Name:gsub("[%s%-_#]",""):lower()
    local best = 0
    for k,v in pairs(PET_VALUES) do
        local key=k:lower()
        if raw:find(key) or key:find(raw) then if v>best then best=v end end
    end
    return best
end

local function getEffectiveIncome(obj)
    local live = getRealIncome(obj)
    if live then return live * getSizeMult(obj) end
    local base = getFallback(obj)
    if base==0 then return 0 end
    return base * getMutMult(obj) * getSizeMult(obj)
end

-- ============================================================
--  УТИЛИТЫ
-- ============================================================
local function getChar() return LocalPlayer.Character end
local function getHRP()
    local c=getChar() return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c=getChar() return c and c:FindFirstChildOfClass("Humanoid")
end
local function objPos(obj)
    if obj:IsA("Model") then
        local p=obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        return p and p.Position
    elseif obj:IsA("BasePart") then return obj.Position end
end

local function getBasePosition()
    local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
    if spawn then return spawn.Position + Vector3.new(0,3,0) end
    for _, name in ipairs({"Base","PlayerBase","MyBase","Home","Nest"}) do
        local b = Workspace:FindFirstChild(name, true)
        if b then local p=objPos(b) if p then return p+Vector3.new(0,3,0) end end
    end
    local pb = Workspace:FindFirstChild(LocalPlayer.Name, true)
    if pb then local p=objPos(pb) if p then return p+Vector3.new(0,3,0) end end
    return Vector3.new(0,5,0)
end

local function applyWalkSpeed()
    local hum = getHum()
    if hum then hum.WalkSpeed = State.SpeedBoost and State.WalkSpeed or 16 end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid",10)
    task.wait(0.5)
    applyWalkSpeed()
end)

-- ============================================================
--  ЗИГЗАГ — raycast боковой проверки
--  Возвращает смещение (Vector3) которое безопасно добавить к вектору
-- ============================================================
local ZIGZAG_AMP      = 18    -- амплитуда в студдах (не слишком мало, не много)
local ZIGZAG_FREQ     = 1.4   -- частота колебаний
local WALL_CHECK_DIST = 12    -- расстояние до стены при котором гасим зигзаг

local function safeZigzag(hrpPos, forward, dt)
    State.ZigTime = State.ZigTime + dt * ZIGZAG_FREQ

    -- Перпендикуляр к направлению движения (горизонтальный)
    local right = forward:Cross(Vector3.new(0,1,0)).Unit
    local rawSin = math.sin(State.ZigTime)  -- -1 .. 1

    -- Raycast влево и вправо чтобы не врезаться
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {getChar()}

    local leftHit  = Workspace:Raycast(hrpPos,  right * (-WALL_CHECK_DIST), rayParams)
    local rightHit = Workspace:Raycast(hrpPos,  right * ( WALL_CHECK_DIST), rayParams)

    -- Дистанция до стен (если нет стены — считаем WALL_CHECK_DIST)
    local leftDist  = leftHit  and leftHit.Distance  or WALL_CHECK_DIST
    local rightDist = rightHit and rightHit.Distance or WALL_CHECK_DIST

    -- Коэффициент подавления зигзага у стен (0 = стена вплотную, 1 = чисто)
    local leftDamp  = math.clamp(leftDist  / WALL_CHECK_DIST, 0, 1)
    local rightDamp = math.clamp(rightDist / WALL_CHECK_DIST, 0, 1)

    -- Если летим вправо (rawSin > 0) — дампируем правым, иначе левым
    local damp = rawSin > 0 and rightDamp or leftDamp
    local offset = rawSin * ZIGZAG_AMP * damp

    return right * offset
end

-- ============================================================
--  ПОЛЁТ ДОМОЙ
-- ============================================================
local FlyConn = nil

local function stopFly()
    State.Flying  = false
    State.ZigTime = 0
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    local hrp = getHRP()
    if hrp then
        local bg = hrp:FindFirstChild("SAE_BG")
        local bv = hrp:FindFirstChild("SAE_BV")
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
    end
    applyWalkSpeed()
end

local function flyHome(onArrived)
    if State.Flying then return end
    State.Flying  = true
    State.ZigTime = 0

    local hrp = getHRP()
    if not hrp then State.Flying=false return end

    local bg = Instance.new("BodyGyro", hrp)
    bg.Name      = "SAE_BG"
    bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
    bg.P         = 1e5
    bg.CFrame    = hrp.CFrame

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Name     = "SAE_BV"
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    bv.Velocity = Vector3.new(0,0,0)

    FlyConn = RunService.Heartbeat:Connect(function(dt)
        if not State.Flying then return end
        local hrp2 = getHRP()
        if not hrp2 then stopFly() return end

        local target = getBasePosition()
        local toTarget = target - hrp2.Position
        local dist   = toTarget.Magnitude

        if dist < 4 then
            stopFly()
            if onArrived then onArrived() end
            return
        end

        local forward = toTarget.Unit
        local speed   = math.min(State.FlySpeed, dist * 10)

        if State.FlyMode == "zigzag" then
            -- Базовый вектор + боковое смещение синусом
            local zigOffset = safeZigzag(hrp2.Position, forward, dt)
            -- Нормализуем итоговый вектор чтобы скорость не менялась
            local combined  = (forward * speed + zigOffset * (speed * 0.35))
            bv.Velocity     = combined
            bg.CFrame       = CFrame.lookAt(hrp2.Position, hrp2.Position + forward)
        else
            -- Прямо
            bv.Velocity = forward * speed
            bg.CFrame   = CFrame.lookAt(hrp2.Position, target)
        end
    end)
end

-- ============================================================
--  СБОР ЯИЦ
-- ============================================================
local SEARCH_FOLDERS = {"Eggs","Items","Collectibles","Map","Pets","Drops"}

local function getEggs()
    local eggs, seen = {}, {}
    for _, fname in ipairs(SEARCH_FOLDERS) do
        local f = Workspace:FindFirstChild(fname, true)
        if f then
            for _, obj in ipairs(f:GetDescendants()) do
                if not seen[obj]
                    and (obj:IsA("BasePart") or obj:IsA("Model"))
                    and not obj:FindFirstChildOfClass("Humanoid")
                then
                    local inc = getEffectiveIncome(obj)
                    if inc >= State.MinValue then
                        seen[obj]=true
                        table.insert(eggs,{obj=obj,value=inc})
                    end
                end
            end
        end
    end
    table.sort(eggs,function(a,b) return a.value>b.value end)
    return eggs
end

local function isCarrying(egg)
    local c = getChar()
    if not c then return false end
    if egg:IsDescendantOf(c) then return true end
    if not egg:IsDescendantOf(Workspace) then return true end
    return false
end

local function startAutoCollect()
    if State.Connections["collect"] then
        State.Connections["collect"]:Disconnect()
    end
    local tickAcc = 0
    local lastEgg = nil

    State.Connections["collect"] = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoCollect then return end
        if State.Flying then return end
        tickAcc = tickAcc + dt
        if tickAcc < State.CollectDelay then return end
        tickAcc = 0

        local hrp = getHRP()
        if not hrp then return end

        if lastEgg and isCarrying(lastEgg) then
            flyHome(function() lastEgg = nil end)
            return
        end

        local eggs = getEggs()
        if #eggs == 0 then lastEgg=nil return end
        lastEgg = eggs[1].obj
        local pos = objPos(lastEgg)
        if not pos then lastEgg=nil return end

        if (hrp.Position - pos).Magnitude > 4 then
            local hum = getHum()
            if hum then hum:MoveTo(pos) end
        end
    end)
end

-- ============================================================
--  АУРА
-- ============================================================
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
        local hrp = getHRP()
        if not hrp then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local oh = p.Character:FindFirstChild("HumanoidRootPart")
                if oh then
                    local d = (hrp.Position - oh.Position).Magnitude
                    if d <= State.ThrowRadius then
                        local dir = (oh.Position - hrp.Position).Unit
                        oh.Velocity = Vector3.new(
                            dir.X*State.ThrowForce,
                            State.ThrowForce*1.5,
                            dir.Z*State.ThrowForce
                        )
                        oh.CFrame = CFrame.new(oh.Position + Vector3.new(
                            dir.X*2000,500,dir.Z*2000
                        ))
                    end
                end
            end
        end
    end)
end

-- ============================================================
--  GUI
-- ============================================================
local old = LocalPlayer.PlayerGui:FindFirstChild("SAE_Menu")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "SAE_Menu"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = LocalPlayer.PlayerGui

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size             = UDim2.new(0,36,0,36)
ToggleBtn.Position         = UDim2.new(0,10,0.5,-18)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,30)
ToggleBtn.TextColor3       = Color3.fromRGB(255,220,80)
ToggleBtn.Text             = "☰"
ToggleBtn.Font             = Enum.Font.GothamBold
ToggleBtn.TextSize         = 20
Instance.new("UICorner",ToggleBtn).CornerRadius = UDim.new(0,8)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size             = UDim2.new(0,300,0,580)
Frame.Position         = UDim2.new(0.5,-150,0.5,-290)
Frame.BackgroundColor3 = Color3.fromRGB(14,14,22)
Frame.BorderSizePixel  = 0
Frame.ClipsDescendants = true
Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke",Frame)
stroke.Color=Color3.fromRGB(80,60,200) stroke.Thickness=1.5

local Title = Instance.new("TextLabel",Frame)
Title.Size             = UDim2.new(1,0,0,40)
Title.BackgroundColor3 = Color3.fromRGB(25,15,55)
Title.Text             = "  🥚  Steal an Egg v4.0"
Title.Font             = Enum.Font.GothamBold
Title.TextSize         = 14
Title.TextColor3       = Color3.fromRGB(220,200,255)
Title.TextXAlignment   = Enum.TextXAlignment.Left
Instance.new("UICorner",Title).CornerRadius = UDim.new(0,12)

local Layout = Instance.new("UIListLayout",Frame)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding   = UDim.new(0,5)
local Pad = Instance.new("UIPadding",Frame)
Pad.PaddingTop=UDim.new(0,46) Pad.PaddingLeft=UDim.new(0,10) Pad.PaddingRight=UDim.new(0,10)

-- ── Хелперы GUI ──────────────────────────────────────────────
local function makeRow(h)
    local r = Instance.new("Frame",Frame)
    r.Size=UDim2.new(1,0,0,h or 38)
    r.BackgroundColor3=Color3.fromRGB(22,22,36)
    r.BorderSizePixel=0
    Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
    return r
end

local function makeToggle(icon, label, key, onEnable, onDisable)
    local row = makeRow(38)
    local lbl = Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0.72,0,1,0) lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=icon.."  "..label
    lbl.Font=Enum.Font.Gotham lbl.TextSize=13
    lbl.TextColor3=Color3.fromRGB(200,200,220)
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton",row)
    btn.Size=UDim2.new(0,52,0,24) btn.Position=UDim2.new(1,-62,0.5,-12)
    btn.BackgroundColor3=Color3.fromRGB(60,60,80)
    btn.Text="OFF" btn.Font=Enum.Font.GothamBold btn.TextSize=12
    btn.TextColor3=Color3.fromRGB(160,160,180)
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        if State[key] then
            btn.BackgroundColor3=Color3.fromRGB(70,40,180)
            btn.Text="ON" btn.TextColor3=Color3.fromRGB(220,200,255)
            if onEnable then onEnable() end
        else
            btn.BackgroundColor3=Color3.fromRGB(60,60,80)
            btn.Text="OFF" btn.TextColor3=Color3.fromRGB(160,160,180)
            if onDisable then onDisable() end
        end
    end)
    return btn
end

-- Переключатель двух режимов (не bool, а строка)
local function makeModeSwitch()
    local row = makeRow(42)

    local lbl = Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,0,0,18) lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1 lbl.Text="✈  Режим полёта"
    lbl.Font=Enum.Font.GothamBold lbl.TextSize=12
    lbl.TextColor3=Color3.fromRGB(200,200,220)
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    -- Кнопка ПРЯМО
    local btnS = Instance.new("TextButton",row)
    btnS.Size=UDim2.new(0,110,0,20) btnS.Position=UDim2.new(0,10,0,22)
    btnS.Font=Enum.Font.GothamBold btnS.TextSize=11
    btnS.Text="➡ Прямо"

    -- Кнопка ЗИГЗАГ
    local btnZ = Instance.new("TextButton",row)
    btnZ.Size=UDim2.new(0,110,0,20) btnZ.Position=UDim2.new(0,130,0,22)
    btnZ.Font=Enum.Font.GothamBold btnZ.TextSize=11
    btnZ.Text="〰 Зигзаг"

    Instance.new("UICorner",btnS).CornerRadius=UDim.new(0,6)
    Instance.new("UICorner",btnZ).CornerRadius=UDim.new(0,6)

    local function refresh()
        if State.FlyMode == "straight" then
            btnS.BackgroundColor3=Color3.fromRGB(70,40,180)
            btnS.TextColor3=Color3.fromRGB(220,200,255)
            btnZ.BackgroundColor3=Color3.fromRGB(40,40,60)
            btnZ.TextColor3=Color3.fromRGB(140,140,160)
        else
            btnZ.BackgroundColor3=Color3.fromRGB(70,40,180)
            btnZ.TextColor3=Color3.fromRGB(220,200,255)
            btnS.BackgroundColor3=Color3.fromRGB(40,40,60)
            btnS.TextColor3=Color3.fromRGB(140,140,160)
        end
    end

    refresh()

    btnS.MouseButton1Click:Connect(function()
        State.FlyMode="straight"
        refresh()
    end)
    btnZ.MouseButton1Click:Connect(function()
        State.FlyMode="zigzag"
        State.ZigTime=0
        refresh()
    end)
end

local function makeLogSlider(label, minV, maxV, defaultV, onChange)
    local row = makeRow(52)
    local function fmt(n)
        if n>=1000000 then return string.format("%.1fM",n/1000000)
        elseif n>=1000 then return string.format("%.0fK",n/1000)
        else return tostring(math.floor(n)) end
    end
    local lbl = Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-10,0,20) lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1 lbl.Text=label..": "..fmt(defaultV)
    lbl.Font=Enum.Font.Gotham lbl.TextSize=12
    lbl.TextColor3=Color3.fromRGB(180,180,210)
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-20,0,8) track.Position=UDim2.new(0,10,0,32)
    track.BackgroundColor3=Color3.fromRGB(40,40,60)
    Instance.new("UICorner",track).CornerRadius=UDim.new(0,4)
    local logMin=math.log(minV) local logMax=math.log(maxV)
    local initRel=(math.log(defaultV)-logMin)/(logMax-logMin)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(initRel,0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(100,70,220)
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,4)
    local knob=Instance.new("TextButton",track)
    knob.Size=UDim2.new(0,16,0,16) knob.Position=UDim2.new(initRel,-8,0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(180,140,255) knob.Text=""
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0,8)
    local drag=false
    knob.MouseButton1Down:Connect(function() drag=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local abs=track.AbsolutePosition local sz=track.AbsoluteSize
            local rel=math.clamp((i.Position.X-abs.X)/sz.X,0,1)
            local val=math.floor(math.exp(logMin+rel*(logMax-logMin)))
            fill.Size=UDim2.new(rel,0,1,0)
            knob.Position=UDim2.new(rel,-8,0.5,-8)
            lbl.Text=label..": "..fmt(val)
            if onChange then onChange(val) end
        end
    end)
end

local function makeLinSlider(label, minV, maxV, defaultV, onChange)
    local row=makeRow(52)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-10,0,20) lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1 lbl.Text=label..": "..tostring(defaultV)
    lbl.Font=Enum.Font.Gotham lbl.TextSize=12
    lbl.TextColor3=Color3.fromRGB(180,180,210)
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-20,0,8) track.Position=UDim2.new(0,10,0,32)
    track.BackgroundColor3=Color3.fromRGB(40,40,60)
    Instance.new("UICorner",track).CornerRadius=UDim.new(0,4)
    local initRel=(defaultV-minV)/(maxV-minV)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(initRel,0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(100,70,220)
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,4)
    local knob=Instance.new("TextButton",track)
    knob.Size=UDim2.new(0,16,0,16) knob.Position=UDim2.new(initRel,-8,0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(180,140,255) knob.Text=""
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0,8)
    local drag=false
    knob.MouseButton1Down:Connect(function() drag=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local abs=track.AbsolutePosition local sz=track.AbsoluteSize
            local rel=math.clamp((i.Position.X-abs.X)/sz.X,0,1)
            local val=math.floor(minV+rel*(maxV-minV))
            fill.Size=UDim2.new(rel,0,1,0)
            knob.Position=UDim2.new(rel,-8,0.5,-8)
            lbl.Text=label..": "..tostring(val)
            if onChange then onChange(val) end
        end
    end)
end

-- ── Меню ─────────────────────────────────────────────────────
makeToggle("🥚","Авто-сбор + полёт домой","AutoCollect",startAutoCollect,nil)
makeToggle("💫","Выкидывание ауры","ThrowAura",startThrowAura,nil)
makeToggle("⚡","Ускорение ходьбы","SpeedBoost",applyWalkSpeed,applyWalkSpeed)

makeModeSwitch()

makeLogSlider("Скорость ходьбы",   1,   1000000, State.WalkSpeed, function(v)
    State.WalkSpeed = v
    if State.SpeedBoost then applyWalkSpeed() end
end)
makeLogSlider("Скорость полёта 🏠", 500, 1000000, State.FlySpeed, function(v)
    State.FlySpeed = v
end)
makeLogSlider("Мин. доход ($/сек)", 1,   1000000, State.MinValue, function(v)
    State.MinValue = v
end)
makeLinSlider("Радиус ауры (ст)",  5,  150, State.ThrowRadius, function(v) State.ThrowRadius=v end)
makeLinSlider("Сила броска",       50, 300, State.ThrowForce,  function(v) State.ThrowForce=v  end)

-- Статус
local StatRow = makeRow(28)
local StatLbl = Instance.new("TextLabel",StatRow)
StatLbl.Size=UDim2.new(1,-10,1,0) StatLbl.Position=UDim2.new(0,10,0,0)
StatLbl.BackgroundTransparency=1 StatLbl.Font=Enum.Font.Gotham
StatLbl.TextSize=11 StatLbl.TextColor3=Color3.fromRGB(120,120,150)
StatLbl.TextXAlignment=Enum.TextXAlignment.Left

RunService.Heartbeat:Connect(function()
    local p={}
    if State.AutoCollect then
        table.insert(p, State.Flying
            and (State.FlyMode=="zigzag" and "〰 зигзаг домой" or "➡ летим домой")
            or  "🥚 сбор")
    end
    if State.ThrowAura  then table.insert(p,"💫 аура") end
    if State.SpeedBoost then table.insert(p,"⚡ спид") end
    StatLbl.Text="Статус: "..(#p>0 and table.concat(p," | ") or "ожидание")
end)

-- ── Перетаскивание ───────────────────────────────────────────
local function drag(frame, handle)
    local d,ds,sp=false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            d=true ds=i.Position sp=frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and i.UserInputType==Enum.UserInputType.MouseMovement then
            local dv=i.Position-ds
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dv.X,sp.Y.Scale,sp.Y.Offset+dv.Y)
        end
    end)
end

drag(Frame,ToggleBtn) drag(ToggleBtn,ToggleBtn)

local vis=true
ToggleBtn.MouseButton1Click:Connect(function()
    vis=not vis Frame.Visible=vis
    ToggleBtn.Text=vis and "✕" or "☰"
end)

-- ============================================================
--  ЗАПУСК
-- ============================================================
startAutoCollect()
startThrowAura()
