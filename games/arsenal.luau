--[[
    Lunar X
    Copyright (c) 2026 nick (.weound)
    Licensed under the Non-Commercial Share-Alike License (see LICENSE in the repo root).
--]]

local function check(funcName)
    local f = _G[funcName] or getfenv(0)[funcName] or
    (funcName == "gethui" and gethui) or 
    (funcName == "mouse1press" and mouse1press) or 
    (funcName == "mouse1release" and mouse1release) or 
    (funcName == "firesignal" and firesignal) or 
    (funcName == "queue_on_teleport" and queue_on_teleport) or 
    (funcName == "setclipboard" and setclipboard) or 
    (funcName == "Drawing.new" and Drawing and Drawing.new) or 
    (funcName == "writefile" and writefile) or 
    (funcName == "delfile" and delfile) or 
    (funcName == "isfolder" and isfolder) or 
    (funcName == "isfile" and isfile) or 
    (funcName == "loadstring" and loadstring) or 
    (funcName == "getrawmetatable" and getrawmetatable) or 
    (funcName == "setreadonly" and setreadonly) or 
    (funcName == "hookmetamethod" and hookmetamethod) or 
    (funcName == "newcclosure" and newcclosure) or 
    (funcName == "checkcaller" and checkcaller) or 
    (funcName == "hookfunction" and hookfunction)
    
    if not f or type(f) ~= "function" then
        warn("your executor does not support '" .. funcName .. "', bye")
        return false
    end
    return true
end

local funcs = {"getrawmetatable", "setreadonly", "getgenv", "hookmetamethod", "newcclosure", "checkcaller", "loadstring", "gethui", "Drawing.new", "writefile", "delfile", "isfolder", "isfile", "queue_on_teleport", "setclipboard", "mouse1press", "mouse1release", "firesignal", "hookfunction"}
for _, f in ipairs(funcs) do
    if not check(f) then return end
end

if not game.HttpGet then
    warn("your executor does not support 'HttpGet', bye")
    return
end

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = getgenv().Options
local Toggles = getgenv().Toggles

local flags = {
    aim_on = false, triggerbot = false, hit_notifs = true, aim_team_check = false, wall_check = true, aim_prediction = false,
    aim_part = "Head", aim_priority = "Nearest Mouse", aim_smooth = 0.15, aim_max_dist = 500, aim_hit_chance = 100, aim_pred_val = 0.1,
    fov_visible = false, fov_filled = false, fov_color = Color3.new(0.392, 0.392, 1), fov_radius = 150, fov_thickness = 1,
    hitbox_on = false, hitbox_size = 8, snap_line = false, snap_line_color = Color3.new(1, 0.392, 0.392), snap_thickness = 1,
    trigger_delay = 0.01, trigger_fov = 80,
    esp_on = false, esp_team_check = true, esp_wall_check = false, esp_max_dist = 800, box_style = "Corner Box",
    box_esp = true, box_color = Color3.new(0.392, 1, 1), box_fill = false, box_fill_color = Color3.new(0.392, 1, 1), box_fill_trans = 0.5,
    tracers_on = false, tracer_color = Color3.new(0.392, 0.392, 1), tracer_origin = "Bottom", tracer_thick = 1,
    name_esp = false, name_color = Color3.new(1, 1, 1), dist_esp = false, dist_color = Color3.new(0.706, 0.706, 0.706), weapon_esp = false, weapon_color = Color3.new(0.392, 1, 0.392),
    hp_esp = false, hp_color_gradient = true, hp_text = false, skel_esp = false, skel_color = Color3.new(1, 0.392, 1),
    ammo_box_esp = false, hp_jug_esp = false,
    xhair_on = false, xhair_size = 10, xhair_gap = 3, xhair_thick = 2, xhair_dot = true, xhair_color = Color3.new(1, 1, 1),
    fullbright = false, remove_fog = false, no_particles = false, world_brightness = 1, time_of_day = 14,
    highlight_enemies = false, hl_enemy_fill = Color3.new(1, 0.196, 0.196), highlight_self = false,
    chams_on = false, chams_material = "Neon", chams_color = Color3.new(0.667, 0.333, 0.922),
    arm_chams_on = false, arm_mat = "Plastic", arm_color = Color3.new(0.196, 0.196, 0.196), rainbow_arm = false, 
    gun_chams_on = false, gun_mat = "Plastic", gun_color = Color3.new(0.196, 0.196, 0.196), rainbow_gun = false,
    speed_on = false, walkspeed = 50, jump_on = false, jump_power = 50, inf_jump = false, custom_gravity = false, gravity_val = 56,
    fly_on = false, fly_speed = 60, noclip_on = false, anti_afk = false,
    no_spread = false, no_recoil = false, rapid_fire = false, always_auto = false, fast_reload = false, custom_fire_rate_on = false, custom_fire_rate_val = 0.15, inf_ammo = false,
    anti_overheat = false, bullet_mult = 1, remove_kill_bricks = false, auto_deploy = false, auto_vote = false,
    kill_all = false, kill_target_user = "", kill_team_check = true, kill_all_wall_check = false, kill_auto_crouch = false, kill_auto_knife = false, kill_use_triggerbot = true, kill_use_max_engage = true, kill_max_dist = 1000, kill_delay = 0.06, kill_engage_time = 4, spin_on = false, spin_speed = 180, anti_aim_small = false,
    lx_melee = "", lx_skin = "", lx_announcer = "", lx_card = "", lx_crate = "",
    killfeed_on = false, killfeed_killer = "", killfeed_victim = "", killfeed_assist = "",
    ui_keybind_list = false, ui_player_list = false,
    auto_exec_on_join = false, silent_load = false,
    color_picker_anim_speed = 2,
    stats_spoof_on = false, spoof_level = 100, spoof_kills = 1000, spoof_kd = "2.5", spoof_hs = 50, spoof_win = 60, spoof_wins = 500, spoof_played = 1000, spoof_total_rounds = 1000,
    ping_spoof = false, fake_ping = 100,
    device_spoof = false, fake_device = "PC",
    fake_server_msg = "Hello",
    redeem_code = "",
    fav_sel = "",
    buy_feat_sel = "",
    stretched_res = false, stretched_x = 1920, stretched_y = 1080,
    rand_always_skip = false
}

local plrs = game:GetService("Players")
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ws = game:GetService("Workspace")
local light = game:GetService("Lighting")
local rs = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local s_url = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/codexvsberserkerxylo/scripts/refs/heads/main/arsenal.luau"))()'

local lp = plrs.LocalPlayer
local cam = ws.CurrentCamera
local mouse = lp:GetMouse()

local function getChar() return lp.Character end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function hex(s) return Color3.fromHex(s) end

local defaultFOV = 70
pcall(function() defaultFOV = lp.Settings.FOV.Value end)
local defaultCol = rgb(100, 100, 255)

local function is_spawned(plr)
    local c = plr.Character
    if not c then return false end
    local ws_char = ws:FindFirstChild(c.Name)
    return ws_char ~= nil and ws_char:FindFirstChild("Spawned") ~= nil
end

local function wall_check(target_char, target_part)
    if not flags["wall_check"] then return true end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {getChar(), target_char}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local origin = cam.CFrame.Position
    local dir = (target_part.Position - origin)
    local hit = ws:Raycast(origin, dir, rp)
    if hit and hit.Instance then
        if hit.Instance.Transparency == 1 then return true end
        if hit.Instance:IsDescendantOf(target_char) then return true end
        return false
    end
    return true
end

local function esp_wall_check(target_char, target_part)
    if not flags["esp_wall_check"] then return true end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {getChar(), target_char}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local origin = cam.CFrame.Position
    local dir = (target_part.Position - origin)
    local hit = ws:Raycast(origin, dir, rp)
    if hit and hit.Instance then
        if hit.Instance.Transparency == 1 then return true end
        if hit.Instance:IsDescendantOf(target_char) then return true end
        return false
    end
    return true
end

local conns = {}
local function connect(sig, cb) 
    local c = sig:Connect(cb)
    table.insert(conns, c)
    return c 
end

local function disconnect_all()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    conns = {}
end

local function newDraw(t, props)
    local d = Drawing.new(t)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local ws_hooked = false
local ws_enabled = false
local jp_enabled = false

local function setup_hooks()
    if ws_hooked then return end
    ws_hooked = true
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldindex = gmt.__index
    gmt.__index = newcclosure(function(self, b)
        if b == "WalkSpeed" and ws_enabled and self:IsA("Humanoid") then return 16 end
        if b == "JumpPower" and jp_enabled and self:IsA("Humanoid") then return 50 end
        return oldindex(self, b)
    end)
    
    local oldNamecall = gmt.__namecall
    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if not checkcaller() and method == "InvokeServer" and self == rs:FindFirstChild("GetPing") and flags["ping_spoof"] then
            return flags["fake_ping"] or 100
        end
        return oldNamecall(self, table.unpack(args))
    end)
    setreadonly(gmt, true)
end
setup_hooks()

local function apply_walkspeed(state, speed)
    setup_hooks()
    ws_enabled = state
    local hum = getHum()
    if hum then hum.WalkSpeed = state and (speed or 50) or 16 end
end

local function apply_jumppower(state, power)
    setup_hooks()
    jp_enabled = state
    local hum = getHum()
    if hum then hum.JumpPower = state and (power or 50) or 50 end
end

connect(run.Heartbeat, function()
    if ws_enabled then
        local hum = getHum()
        if hum and hum.WalkSpeed ~= (flags["walkspeed"] or 50) then hum.WalkSpeed = flags["walkspeed"] or 50 end
    end
    if jp_enabled then
        local hum = getHum()
        if hum and hum.JumpPower ~= (flags["jump_power"] or 50) then hum.JumpPower = flags["jump_power"] or 50 end
    end

    if flags["ping_spoof"] then
        pcall(function()
            local vars = lp.PlayerGui.GUI.Client.Variables
            if vars and vars:FindFirstChild("Ping") then
                vars.Ping.Value = flags["fake_ping"] or 100
            end
        end)
    end

    if flags["device_spoof"] then
        pcall(function()
            local vars = lp.PlayerGui.GUI.Client.Variables
            if vars and vars:FindFirstChild("Device") then
                vars.Device.Value = flags["fake_device"] or "PC"
            end
            if vars and vars:FindFirstChild("OS") then
                vars.OS.Value = flags["fake_device"] or "PC"
            end
            if vars and vars:FindFirstChild("IsMobile") then
                vars.IsMobile.Value = (flags["fake_device"] == "Mobile")
            end
        end)
    end

    if flags["remove_kill_bricks"] then
        pcall(function()
            for _, v in ipairs(ws.Map:GetChildren()) do
                if v.Name:lower():match("killbrick") or v.Name:lower():match("kill") then
                    v:Destroy()
                end
            end
        end)
    end

    if flags["auto_vote"] then
        pcall(function()
            if rs.wkspc.Status.IsVoting.Value then
                local maps = rs.wkspc.Status.VoteCount.MapVote:GetChildren()
                if #maps > 0 then rs.Events.Vote:FireServer({"MapVote", maps[math.random(#maps)].Name}) end
                local gametypes = rs.wkspc.Status.VoteCount.GameType:GetChildren()
                if #gametypes > 0 then rs.Events.Vote:FireServer({"GameType", gametypes[math.random(#gametypes)].Name}) end
                local teams = rs.wkspc.Status.VoteCount.TeamVote:GetChildren()
                if #teams > 0 then
                    local chosenTeam = "2Teams"
                    local found = false
                    for _, t in ipairs(teams) do if t.Name == "2Teams" then found = true break end end
                    if not found then chosenTeam = teams[1].Name end
                    rs.Events.Vote:FireServer({"TeamVote", chosenTeam})
                end
            end
        end)
    end
end)

local state = {
    skinMats = { arm = "Plastic", gun = "Plastic" },
    armSkinOn = false, gunSkinOn = false, rainbowOn = false, rainbowHue = 0,
    triggerAlive = true, triggerCooldown = 0,
    aim_target_part = nil, 
    aim_target_player = nil,
    lastClickTime = 0,
    colors = {
        box = rgb(100, 255, 255), boxFill = rgb(100, 255, 255), boxFillTr = 0.5,
        tracer = rgb(100, 100, 255), tracerThick = 1, snapLine = rgb(255, 100, 100), snapThick = 1,
        skel = rgb(255, 100, 255), xhair = rgb(255, 255, 255), fov = rgb(100, 100, 255), fovTr = 0,
        hlEnemy = rgb(255, 50, 50), chams = rgb(170, 85, 235), name = rgb(255, 255, 255),
        dist = rgb(180, 180, 180), weapon = rgb(100, 255, 100), armColor = rgb(50, 50, 50), gunColor = rgb(50, 50, 50)
    }
}

local keybinds = { aim = false, trigger = false, fly = false, killall = false }

local lightOrig = {
    Ambient = light.Ambient, Brightness = light.Brightness,
    FogEnd = light.FogEnd, FogStart = light.FogStart
}
local desiredBrightness = light.Brightness
local desiredClockTime = light.ClockTime

local skel_pairs = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"RightLowerLeg", "RightFoot"}
}

local xhairLines = {
    top = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.xhair}),
    bottom = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.xhair}),
    left = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.xhair}),
    right = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.xhair}),
    dot = newDraw("Circle", {Radius = 2, Filled = true, Visible = false, Color = state.colors.xhair})
}

local fovCircle = newDraw("Circle", {
    NumSides = 60, Thickness = 1, Filled = false,
    Visible = false, Color = state.colors.fov, Radius = 150
})

local espObjects = {}

local function buildESP(pl)
    if pl == lp then return end
    local corners = {}
    for i = 1, 8 do corners[i] = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.box}) end
    local skeleton = {}
    for i = 1, #skel_pairs do skeleton[i] = newDraw("Line", {Thickness = 1, Visible = false, Color = state.colors.skel}) end
    
    espObjects[pl] = {
        box = newDraw("Square", {Thickness = 1, Filled = false, Visible = false, Color = state.colors.box}),
        boxFill = newDraw("Square", {Filled = true, Visible = false, Color = state.colors.boxFill, Transparency = state.colors.boxFillTr}),
        corners = corners,
        skeleton = skeleton,
        nameText = newDraw("Text", {Size = 13, Center = true, Outline = true, Visible = false, Color = state.colors.name, Font = 2}),
        distText = newDraw("Text", {Size = 11, Center = true, Outline = true, Visible = false, Color = state.colors.dist, Font = 2}),
        weaponText = newDraw("Text", {Size = 12, Center = true, Outline = true, Visible = false, Color = state.colors.weapon, Font = 2}),
        hpBG = newDraw("Square", {Filled = true, Visible = false, Color = rgb(0, 0, 0)}),
        hpBar = newDraw("Square", {Filled = true, Visible = false, Color = rgb(0, 255, 0)}),
        hpText = newDraw("Text", {Size = 10, Center = true, Outline = true, Visible = false, Color = rgb(255, 255, 255), Font = 2}),
        tracer = newDraw("Line", {Thickness = 1, Visible = false, Color = state.colors.tracer}),
        snapLine = newDraw("Line", {Thickness = 1, Visible = false, Color = state.colors.snapLine})
    }
end

local function destroyESP(pl)
    local d = espObjects[pl]
    if not d then return end
    for _, v in pairs(d.corners) do pcall(function() v:Remove() end) end
    for _, v in pairs(d.skeleton) do pcall(function() v:Remove() end) end
    for k, v in pairs(d) do
        if k ~= "corners" and k ~= "skeleton" then pcall(function() v:Remove() end) end
    end
    espObjects[pl] = nil
end

for _, pl in ipairs(plrs:GetPlayers()) do buildESP(pl) end
connect(plrs.PlayerAdded, buildESP)
connect(plrs.PlayerRemoving, destroyESP)

local pickupESPObjects = {}
local pickupESPEnabled = { ammo = false, hp = false }

local function removePickupDraw(d) 
    pcall(function() d.text:Remove(); d.box:Remove() end) 
end

local function cleanupPickupESP()
    for obj, d in pairs(pickupESPObjects) do
        if not obj or not obj.Parent then removePickupDraw(d); pickupESPObjects[obj] = nil end
    end
end

local function buildPickupESPFor(obj)
    if pickupESPObjects[obj] then return end
    local isAmmo = obj.Name == "DeadAmmo"
    local col = state.colors.box
    pickupESPObjects[obj] = {
        text = newDraw("Text", {Size = 12, Center = true, Outline = true, Visible = false, Color = col, Font = 2, Text = isAmmo and "ammo box" or "hp jug"}),
        box = newDraw("Square", {Filled = true, Visible = false, Color = col, Transparency = 0.5, Thickness = 0})
    }
end

local function refreshPickupESP()
    cleanupPickupESP()
    local debris = ws:FindFirstChild("Debris")
    if not debris then return end
    for _, v in ipairs(debris:GetChildren()) do
        local isAmmo = v.Name == "DeadAmmo" and pickupESPEnabled.ammo
        local isHP = v.Name == "DeadHP" and pickupESPEnabled.hp
        if isAmmo or isHP then buildPickupESPFor(v) end
    end
end

local chamParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

local function applyChams(pl)
    if pl == lp then return end
    local c = pl.Character
    if not c then return end
    local mat = Enum.Material[flags["chams_material"] or "Neon"]
    for _, name in ipairs(chamParts) do
        local p = c:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            pcall(function()
                if not p:GetAttribute("__lx_mat") then
                    p:SetAttribute("__lx_mat", p.Material.Name)
                    p:SetAttribute("__lx_colR", p.Color.R)
                    p:SetAttribute("__lx_colG", p.Color.G)
                    p:SetAttribute("__lx_colB", p.Color.B)
                end
                p.Material = mat
                p.Color = state.colors.chams
            end)
        end
    end
end

local function removeChams(pl)
    local c = pl and pl.Character
    if not c then return end
    for _, name in ipairs(chamParts) do
        local p = c:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            pcall(function()
                local m = p:GetAttribute("__lx_mat")
                local cr, cg, cb = p:GetAttribute("__lx_colR"), p:GetAttribute("__lx_colG"), p:GetAttribute("__lx_colB")
                if m then p.Material = Enum.Material[m]; p:SetAttribute("__lx_mat", nil) end
                if cr and cg and cb then p.Color = Color3.new(cr, cg, cb); p:SetAttribute("__lx_colR", nil); p:SetAttribute("__lx_colG", nil); p:SetAttribute("__lx_colB", nil) end
            end)
        end
    end
end

local function reapplyAllChams()
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp then 
            if flags["chams_on"] then applyChams(pl) else removeChams(pl) end 
        end
    end
end

local hitboxOrigSizes = {}
local hitboxParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}

local function expandHitbox(pl)
    if pl == lp then return end
    local c = pl.Character
    if not c then return end
    hitboxOrigSizes[pl] = hitboxOrigSizes[pl] or {}
    local sz = flags["hitbox_size"] or 8
    for _, name in ipairs(hitboxParts) do
        local part = c:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if not hitboxOrigSizes[pl][name] then hitboxOrigSizes[pl][name] = part.Size end
            pcall(function() part.Size = Vector3.new(sz, sz, sz) end)
        end
    end
end

local function restoreHitbox(pl)
    local data = hitboxOrigSizes[pl]
    if not data then return end
    local c = pl and pl.Character
    if c then
        for name, orig in pairs(data) do
            local part = c:FindFirstChild(name)
            if part and part:IsA("BasePart") then pcall(function() part.Size = orig end) end
        end
    end
    hitboxOrigSizes[pl] = nil
end

local function updateAllHitboxes()
    local active = flags["hitbox_on"]
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp then 
            if active then expandHitbox(pl) else restoreHitbox(pl) end 
        end
    end
end

local hbCounter = 0
connect(run.Heartbeat, function()
    if not flags["hitbox_on"] then return end
    hbCounter = hbCounter + 1
    if hbCounter % 6 == 0 then updateAllHitboxes() end
end)

local myOrigSizes = {}
local function applyAntiAim()
    local c = getChar()
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hb = c:FindFirstChild("Hitbox")
    if hrp then
        if not myOrigSizes["hrp"] then myOrigSizes["hrp"] = hrp.Size end
        if hrp.Size ~= Vector3.new(0.5, 0.5, 0.5) then hrp.Size = Vector3.new(0.5, 0.5, 0.5) end
    end
    if hb then
        if not myOrigSizes["hb"] then myOrigSizes["hb"] = hb.Size end
        if hb.Size ~= Vector3.new(0.1, 0.1, 0.1) then hb.Size = Vector3.new(0.1, 0.1, 0.1) end
    end
end

local function removeAntiAim()
    local c = getChar()
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hb = c:FindFirstChild("Hitbox")
    if hrp and myOrigSizes["hrp"] then hrp.Size = myOrigSizes["hrp"] end
    if hb and myOrigSizes["hb"] then hb.Size = myOrigSizes["hb"] end
    myOrigSizes = {}
end

connect(uis.InputBegan, function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        state.lastClickTime = tick()
    end
    if input.KeyCode == Enum.KeyCode.E and flags["rand_always_skip"] then
        pcall(function() firesignal(rs.Events.RandomizeRandom.OnClientEvent, true) end)
    end
end)

local function applyArmChams()
    if not flags["arm_chams_on"] then return end
    local arms = ws.Camera:FindFirstChild("Arms")
    if not arms then return end
    for _, v in ipairs(arms:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name == "Right Arm" or v.Name == "Left Arm" or v.Name == "RightHand" or v.Name == "LeftHand" or v.Name == "RightArm" or v.Name == "LeftArm") then
            pcall(function()
                v.Material = Enum.Material[flags["arm_mat"] or "Plastic"]
                if flags["rainbow_arm"] then
                    v.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                else
                    v.Color = state.colors.armColor
                end
            end)
        end
    end
end

local function applyGunChams()
    if not flags["gun_chams_on"] then return end
    local arms = ws.Camera:FindFirstChild("Arms")
    if not arms then return end
    for _, v in ipairs(arms:GetDescendants()) do
        if v:IsA("MeshPart") then 
            pcall(function() 
                v.Material = Enum.Material[flags["gun_mat"] or "Plastic"]
                if flags["rainbow_gun"] then
                    v.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                else
                    v.Color = state.colors.gunColor
                end
            end) 
        end
    end
end

local window = library:CreateWindow({
    Title = 'lunar x | arsenal',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    aimbot = window:AddTab('aimbot'),
    visuals = window:AddTab('visuals'),
    movement = window:AddTab('movement'),
    weapon = window:AddTab('weapon'),
    skins = window:AddTab('skins'),
    misc = window:AddTab('misc'),
    settings = window:AddTab('settings')
}

local aimbotTab = Tabs.aimbot
local visualsTab = Tabs.visuals
local movementTab = Tabs.movement
local weaponTab = Tabs.weapon
local skinsTab = Tabs.skins
local miscTab = Tabs.misc
local settingsTab = Tabs.settings

local aimbotSec = aimbotTab:AddLeftGroupbox('aimbot')
local aimCfg = aimbotTab:AddLeftGroupbox('aim config')
local fovSec = aimbotTab:AddRightGroupbox('fov circle')
local hbSec = aimbotTab:AddRightGroupbox('hitbox expander')
local indSec = aimbotTab:AddRightGroupbox('target indicator')
local trigCfg = aimbotTab:AddRightGroupbox('trigger config')

aimbotSec:AddToggle('aim_on', { Text = 'Aimbot', Default = false, Callback = function(v) flags['aim_on'] = v end })
aimbotSec:AddLabel('Aimbot Bind'):AddKeyPicker('aim_key', { Default = 'E', Mode = 'Hold', Text = 'Aimbot Bind', SyncToggleState = false })

aimbotSec:AddToggle('triggerbot', { Text = 'Trigger Bot', Default = false, Callback = function(v) flags['triggerbot'] = v end })
aimbotSec:AddLabel('Trigger Bind'):AddKeyPicker('trigger_key', { Default = 'Q', Mode = 'Hold', Text = 'Trigger Bind', SyncToggleState = false })

aimbotSec:AddToggle('aim_team_check', { Text = 'Team Check', Default = false, Callback = function(v) flags['aim_team_check'] = v end })
aimbotSec:AddToggle('wall_check', { Text = 'Wall Check', Default = true, Callback = function(v) flags['wall_check'] = v end })
aimbotSec:AddToggle('aim_prediction', { Text = 'Prediction', Default = false, Callback = function(v) flags['aim_prediction'] = v end })

aimCfg:AddDropdown('aim_part', { Text = 'Target Part', Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso', 'LeftArm', 'RightArm'}, Default = 'Head', Callback = function(v) flags['aim_part'] = v end })
aimCfg:AddDropdown('aim_priority', { Text = 'Priority', Values = {'Nearest Mouse', 'Nearest Distance', 'Lowest HP'}, Default = 'Nearest Mouse', Callback = function(v) flags['aim_priority'] = v end })
aimCfg:AddSlider('aim_smooth', { Text = 'Smoothness', Min = 0.01, Max = 1, Default = 0.15, Rounding = 2, Suffix = 'x', Callback = function(v) flags['aim_smooth'] = v end })
aimCfg:AddSlider('aim_max_dist', { Text = 'Max Distance', Min = 50, Max = 2000, Default = 500, Rounding = 0, Suffix = ' st', Callback = function(v) flags['aim_max_dist'] = v end })
aimCfg:AddSlider('aim_hit_chance', { Text = 'Hit Chance', Min = 1, Max = 100, Default = 100, Rounding = 0, Suffix = '%', Callback = function(v) flags['aim_hit_chance'] = v end })
aimCfg:AddSlider('aim_pred_val', { Text = 'Pred Offset', Min = 0, Max = 1, Default = 0.1, Rounding = 2, Suffix = 's', Callback = function(v) flags['aim_pred_val'] = v end })

fovSec:AddToggle('fov_visible', { Text = 'Visible', Default = false, Callback = function(v) flags['fov_visible'] = v; fovCircle.Visible = v end })
fovSec:AddToggle('fov_filled', { Text = 'Filled', Default = false, Callback = function(v) flags['fov_filled'] = v; fovCircle.Filled = v end })
fovSec:AddLabel('FOV Color'):AddColorPicker('fov_color', { Default = flags['fov_color'], Title = 'FOV Color', Transparency = 0, Callback = function(c) 
    flags['fov_color'] = c 
    fovCircle.Color = c 
end })
fovSec:AddSlider('fov_radius', { Text = 'Radius', Min = 10, Max = 600, Default = 150, Rounding = 0, Suffix = 'px', Callback = function(v) flags['fov_radius'] = v; fovCircle.Radius = v end })
fovSec:AddSlider('fov_thickness', { Text = 'Thickness', Min = 1, Max = 5, Default = 1, Rounding = 0, Suffix = 'px', Callback = function(v) flags['fov_thickness'] = v; fovCircle.Thickness = v end })

hbSec:AddToggle('hitbox_on', { Text = 'Hitbox Expander', Default = false, Callback = function(v) flags['hitbox_on'] = v; if v then updateAllHitboxes() else for _, pl in ipairs(plrs:GetPlayers()) do restoreHitbox(pl) end end end })
hbSec:AddSlider('hitbox_size', { Text = 'Hitbox Size', Min = 1, Max = 10, Default = 8, Rounding = 1, Suffix = ' st', Callback = function(v) flags['hitbox_size'] = v; if flags['hitbox_on'] then updateAllHitboxes() end end })

indSec:AddToggle('snap_line', { Text = 'Snap Line', Default = false, Callback = function(v) flags['snap_line'] = v end })
indSec:AddLabel('Snap Color'):AddColorPicker('snap_line_color', { Default = state.colors.snapLine, Title = 'Snap Color', Callback = function(c) flags['snap_line_color'] = c; state.colors.snapLine = c; for _, d in pairs(espObjects) do d.snapLine.Color = c end end })
indSec:AddSlider('snap_thickness', { Text = 'Thickness', Min = 1, Max = 5, Default = 1, Rounding = 0, Suffix = 'px', Callback = function(v) flags['snap_thickness'] = v; state.colors.snapThick = v end })

trigCfg:AddSlider('trigger_delay', { Text = 'Trigger Delay', Min = 0.0001, Max = 0.5, Default = 0.01, Rounding = 4, Suffix = 's', Callback = function(v) flags['trigger_delay'] = v end })
trigCfg:AddSlider('trigger_fov', { Text = 'Trigger FOV', Min = 1, Max = 300, Default = 80, Rounding = 0, Suffix = 'px', Callback = function(v) flags['trigger_fov'] = v end })

local espSec = visualsTab:AddLeftGroupbox('player esp')
local pickupSec = visualsTab:AddLeftGroupbox('pickup esp')
local xhairSec = visualsTab:AddLeftGroupbox('custom crosshair')
local worldSec = visualsTab:AddRightGroupbox('world')
local hlSec = visualsTab:AddRightGroupbox('highlights')
local chamsSec = visualsTab:AddRightGroupbox('chams')
local skinsSec = visualsTab:AddRightGroupbox('viewmodel chams')

espSec:AddToggle('esp_on', { Text = 'ESP Enabled', Default = false, Callback = function(v) flags['esp_on'] = v end })
espSec:AddToggle('esp_team_check', { Text = 'Team Check', Default = true, Callback = function(v) flags['esp_team_check'] = v end })
espSec:AddToggle('esp_wall_check', { Text = 'Wall Check', Default = false, Callback = function(v) flags['esp_wall_check'] = v end })
espSec:AddSlider('esp_max_dist', { Text = 'Max Distance', Min = 50, Max = 3000, Default = 800, Rounding = 0, Suffix = ' st', Callback = function(v) flags['esp_max_dist'] = v end })
espSec:AddDropdown('box_style', { Text = 'Box Style', Values = {'None', 'Full Box', 'Corner Box'}, Default = 'Corner Box', Callback = function(v) flags['box_style'] = v end })

espSec:AddToggle('box_esp', { Text = 'Box ESP', Default = true, Callback = function(v) flags['box_esp'] = v end })
espSec:AddLabel('Box Color'):AddColorPicker('box_color', { Default = state.colors.box, Title = 'Box Color', Callback = function(c) flags['box_color'] = c; state.colors.box = c; for _, d in pairs(espObjects) do d.box.Color = c; for _, l in ipairs(d.corners) do l.Color = c end end end })
espSec:AddToggle('box_fill', { Text = 'Filled', Default = false, Callback = function(v) flags['box_fill'] = v end })
espSec:AddLabel('Fill Color'):AddColorPicker('box_fill_color', { Default = state.colors.boxFill, Title = 'Fill Color', Callback = function(c) flags['box_fill_color'] = c; state.colors.boxFill = c; for _, d in pairs(espObjects) do d.boxFill.Color = c end end })
espSec:AddSlider('box_fill_trans', { Text = 'Fill Transparency', Min = 0, Max = 1, Default = 0.5, Rounding = 2, Suffix = 'a', Callback = function(v) flags['box_fill_trans'] = v; state.colors.boxFillTr = v; for _, d in pairs(espObjects) do d.boxFill.Transparency = v end end })

espSec:AddToggle('tracers_on', { Text = 'Tracers', Default = false, Callback = function(v) flags['tracers_on'] = v end })
espSec:AddLabel('Tracer Color'):AddColorPicker('tracer_color', { Default = state.colors.tracer, Title = 'Tracer Color', Callback = function(c) flags['tracer_color'] = c; state.colors.tracer = c; for _, d in pairs(espObjects) do d.tracer.Color = c end end })
espSec:AddDropdown('tracer_origin', { Text = 'Origin', Values = {'Bottom', 'Center', 'Top', 'Mouse'}, Default = 'Bottom', Callback = function(v) flags['tracer_origin'] = v end })
espSec:AddSlider('tracer_thick', { Text = 'Thickness', Min = 1, Max = 4, Default = 1, Rounding = 0, Suffix = 'px', Callback = function(v) flags['tracer_thick'] = v; state.colors.tracerThick = v end })

espSec:AddToggle('name_esp', { Text = 'Name ESP', Default = false, Callback = function(v) flags['name_esp'] = v end })
espSec:AddLabel('Name Color'):AddColorPicker('name_color', { Default = state.colors.name, Title = 'Name Color', Callback = function(c) flags['name_color'] = c; state.colors.name = c; for _, d in pairs(espObjects) do d.nameText.Color = c end end })

espSec:AddToggle('dist_esp', { Text = 'Distance ESP', Default = false, Callback = function(v) flags['dist_esp'] = v end })
espSec:AddLabel('Distance Color'):AddColorPicker('dist_color', { Default = state.colors.dist, Title = 'Distance Color', Callback = function(c) flags['dist_color'] = c; state.colors.dist = c; for _, d in pairs(espObjects) do d.distText.Color = c end end })

espSec:AddToggle('weapon_esp', { Text = 'Weapon ESP', Default = false, Callback = function(v) flags['weapon_esp'] = v end })
espSec:AddLabel('Weapon Color'):AddColorPicker('weapon_color', { Default = state.colors.weapon, Title = 'Weapon Color', Callback = function(c) flags['weapon_color'] = c; state.colors.weapon = c; for _, d in pairs(espObjects) do d.weaponText.Color = c end end })

espSec:AddToggle('hp_esp', { Text = 'Health Bar', Default = false, Callback = function(v) flags['hp_esp'] = v end })
espSec:AddToggle('hp_color_gradient', { Text = 'Color by HP', Default = true, Callback = function(v) flags['hp_color_gradient'] = v end })
espSec:AddToggle('hp_text', { Text = 'Show HP Text', Default = false, Callback = function(v) flags['hp_text'] = v end })

espSec:AddToggle('skel_esp', { Text = 'Skeleton ESP', Default = false, Callback = function(v) flags['skel_esp'] = v end })
espSec:AddLabel('Skeleton Color'):AddColorPicker('skel_color', { Default = state.colors.skel, Title = 'Skeleton Color', Callback = function(c) flags['skel_color'] = c; state.colors.skel = c; for _, d in pairs(espObjects) do for _, l in ipairs(d.skeleton) do l.Color = c end end end })

pickupSec:AddToggle('ammo_box_esp', { Text = 'Ammo Box ESP', Default = false, Callback = function(v) flags['ammo_box_esp'] = v; pickupESPEnabled.ammo = v; if not v then for obj, d in pairs(pickupESPObjects) do if obj and obj.Name == 'DeadAmmo' then removePickupDraw(d); pickupESPObjects[obj] = nil end end end end })
pickupSec:AddToggle('hp_jug_esp', { Text = 'HP Jug ESP', Default = false, Callback = function(v) flags['hp_jug_esp'] = v; pickupESPEnabled.hp = v; if not v then for obj, d in pairs(pickupESPObjects) do if obj and obj.Name == 'DeadHP' then removePickupDraw(d); pickupESPObjects[obj] = nil end end end end })

xhairSec:AddToggle('xhair_on', { Text = 'Crosshair', Default = false, Callback = function(v) flags['xhair_on'] = v; if not v then for _, l in pairs(xhairLines) do l.Visible = false end end end })
xhairSec:AddSlider('xhair_size', { Text = 'Size', Min = 2, Max = 30, Default = 10, Rounding = 0, Suffix = 'px', Callback = function(v) flags['xhair_size'] = v end })
xhairSec:AddSlider('xhair_gap', { Text = 'Gap', Min = 0, Max = 15, Default = 3, Rounding = 0, Suffix = 'px', Callback = function(v) flags['xhair_gap'] = v end })
xhairSec:AddSlider('xhair_thick', { Text = 'Thickness', Min = 1, Max = 5, Default = 2, Rounding = 0, Suffix = 'px', Callback = function(v) flags['xhair_thick'] = v end })
xhairSec:AddToggle('xhair_dot', { Text = 'Dot', Default = true, Callback = function(v) flags['xhair_dot'] = v end })
xhairSec:AddLabel('Color'):AddColorPicker('xhair_color', { Default = state.colors.xhair, Title = 'Color', Callback = function(c) flags['xhair_color'] = c; state.colors.xhair = c; for _, l in pairs(xhairLines) do l.Color = c end end })

worldSec:AddToggle('fullbright', { Text = 'Fullbright', Default = false, Callback = function(v) flags['fullbright'] = v; if v then light.Ambient = rgb(178, 178, 178); light.Brightness = 2 else light.Ambient = lightOrig.Ambient; light.Brightness = desiredBrightness; light.ClockTime = desiredClockTime end end })
worldSec:AddToggle('remove_fog', { Text = 'Remove Fog', Default = false, Callback = function(v) flags['remove_fog'] = v; light.FogEnd = v and 1e6 or lightOrig.FogEnd; light.FogStart = v and 1e6 or lightOrig.FogStart end })
worldSec:AddToggle('no_particles', { Text = 'No Particles', Default = false, Callback = function(v) flags['no_particles'] = v; local atmo = light:FindFirstChildOfClass('Atmosphere'); if atmo then atmo.Density = v and 0 or 0.395 end; for _, obj in ipairs(ws:GetDescendants()) do if obj:IsA('ParticleEmitter') or obj:IsA('Smoke') or obj:IsA('Fire') or obj:IsA('Sparkles') then obj.Enabled = not v end end end })
worldSec:AddSlider('world_brightness', { Text = 'Brightness', Min = 0, Max = 5, Default = 1, Rounding = 1, Suffix = 'x', Callback = function(v) flags['world_brightness'] = v; desiredBrightness = v; if not flags['fullbright'] then light.Brightness = v end end })
worldSec:AddSlider('time_of_day', { Text = 'Time of Day', Min = 0, Max = 24, Default = 14, Rounding = 1, Suffix = 'h', Callback = function(v) flags['time_of_day'] = v; desiredClockTime = v; if not flags['fullbright'] then light.ClockTime = v end end })
worldSec:AddToggle('stretched_res', { Text = 'Stretched Resolution', Default = false, Callback = function(v) flags['stretched_res'] = v end })
worldSec:AddSlider('stretched_x', { Text = 'Res X', Min = 800, Max = 3840, Default = 1920, Rounding = 0, Suffix = 'px', Callback = function(v) flags['stretched_x'] = v end })
worldSec:AddSlider('stretched_y', { Text = 'Res Y', Min = 600, Max = 2160, Default = 1080, Rounding = 0, Suffix = 'px', Callback = function(v) flags['stretched_y'] = v end })

hlSec:AddToggle('highlight_enemies', { Text = 'Highlight Enemies', Default = false, Callback = function(v) flags['highlight_enemies'] = v; for _, pl in ipairs(plrs:GetPlayers()) do if pl ~= lp and pl.Character then local ex = pl.Character:FindFirstChild('LunarHL'); if v and not ex then local h = Instance.new('Highlight'); h.Name = 'LunarHL'; h.FillColor = state.colors.hlEnemy; h.OutlineColor = rgb(255, 255, 255); h.FillTransparency = 0.5; h.Parent = pl.Character elseif not v and ex then ex:Destroy() end end end end })
hlSec:AddLabel('HL Enemy Fill'):AddColorPicker('hl_enemy_fill', { Default = state.colors.hlEnemy, Title = 'HL Enemy Fill', Callback = function(c) flags['hl_enemy_fill'] = c; state.colors.hlEnemy = c; for _, pl in ipairs(plrs:GetPlayers()) do if pl ~= lp and pl.Character then local ex = pl.Character:FindFirstChild('LunarHL'); if ex then ex.FillColor = c end end end end })
hlSec:AddToggle('highlight_self', { Text = 'Highlight Self', Default = false, Callback = function(v) flags['highlight_self'] = v; local c = getChar(); if not c then return end; local ex = c:FindFirstChild('LunarSelfHL'); if v and not ex then local h = Instance.new('Highlight'); h.Name = 'LunarSelfHL'; h.FillColor = hex('#AA55EB'); h.OutlineColor = rgb(255, 255, 255); h.FillTransparency = 0.6; h.Parent = c elseif not v and ex then ex:Destroy() end end })

chamsSec:AddToggle('chams_on', { Text = 'Chams', Default = false, Callback = function(v) flags['chams_on'] = v; if v then reapplyAllChams() else for _, pl in ipairs(plrs:GetPlayers()) do removeChams(pl) end end end })
chamsSec:AddDropdown('chams_material', { Text = 'Material', Values = {'Neon', 'ForceField', 'SmoothPlastic', 'Glass'}, Default = 'Neon', Callback = function(v) flags['chams_material'] = v; if flags['chams_on'] then for _, pl in ipairs(plrs:GetPlayers()) do removeChams(pl); applyChams(pl) end end end })
chamsSec:AddLabel('Chams Color'):AddColorPicker('chams_color', { Default = state.colors.chams, Title = 'Chams Color', Callback = function(c) flags['chams_color'] = c; state.colors.chams = c; if flags['chams_on'] then reapplyAllChams() end end })

skinsSec:AddToggle('arm_chams_on', { Text = 'Arm Chams', Default = false, Callback = function(v) flags['arm_chams_on'] = v end })
skinsSec:AddToggle('rainbow_arm', { Text = 'Rainbow Arm', Default = false, Callback = function(v) flags['rainbow_arm'] = v end })
skinsSec:AddDropdown('arm_mat', { Text = 'Arm Material', Values = {'Plastic', 'Neon', 'ForceField', 'Wood', 'Grass', 'SmoothPlastic'}, Default = 'Plastic', Callback = function(v) flags['arm_mat'] = v end })
skinsSec:AddLabel('Arm Color'):AddColorPicker('arm_color', { Default = state.colors.armColor, Title = 'Arm Color', Callback = function(c) flags['arm_color'] = c; state.colors.armColor = c end })

skinsSec:AddToggle('gun_chams_on', { Text = 'Gun Chams', Default = false, Callback = function(v) flags['gun_chams_on'] = v end })
skinsSec:AddToggle('rainbow_gun', { Text = 'Rainbow Gun', Default = false, Callback = function(v) flags['rainbow_gun'] = v end })
skinsSec:AddDropdown('gun_mat', { Text = 'Gun Material', Values = {'Plastic', 'Neon', 'ForceField', 'Wood', 'Grass', 'SmoothPlastic'}, Default = 'Plastic', Callback = function(v) flags['gun_mat'] = v end })
skinsSec:AddLabel('Gun Color'):AddColorPicker('gun_color', { Default = state.colors.gunColor, Title = 'Gun Color', Callback = function(c) flags['gun_color'] = c; state.colors.gunColor = c end })

local speedSec = movementTab:AddLeftGroupbox('speed')
local jumpSec = movementTab:AddLeftGroupbox('jump')
local gravSec = movementTab:AddLeftGroupbox('gravity')
local flySec = movementTab:AddRightGroupbox('fly')
local miscMove = movementTab:AddRightGroupbox('misc movement')

speedSec:AddToggle('speed_on', { Text = 'Speed Hack', Default = false, Callback = function(v) flags['speed_on'] = v; apply_walkspeed(v, flags['walkspeed'] or 50) end })
speedSec:AddSlider('walkspeed', { Text = 'WalkSpeed', Min = 8, Max = 500, Default = 50, Rounding = 0, Suffix = ' ws', Callback = function(v) flags['walkspeed'] = v; if flags['speed_on'] then apply_walkspeed(true, v) end end })

jumpSec:AddToggle('jump_on', { Text = 'Jump Hack', Default = false, Callback = function(v) flags['jump_on'] = v; apply_jumppower(v, flags['jump_power'] or 50) end })
jumpSec:AddSlider('jump_power', { Text = 'JumpPower', Min = 7, Max = 500, Default = 50, Rounding = 0, Suffix = ' jp', Callback = function(v) flags['jump_power'] = v; if flags['jump_on'] then apply_jumppower(true, v) end end })

jumpSec:AddToggle('inf_jump', { Text = 'Infinite Jump', Default = false, Callback = function(v) flags['inf_jump'] = v end })

gravSec:AddToggle('custom_gravity', { Text = 'Custom Gravity', Default = false, Callback = function(v) flags['custom_gravity'] = v; pcall(function() rs.CurrentGrav.Value = v and (flags['gravity_val'] or 56) or 56 end) end })
gravSec:AddSlider('gravity_val', { Text = 'Gravity', Min = 1, Max = 400, Default = 56, Rounding = 0, Suffix = ' g', Callback = function(v) flags['gravity_val'] = v; if flags['custom_gravity'] then pcall(function() rs.CurrentGrav.Value = v end) end end })

local flyConn, bodyVel, bodyGyro
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
end
local function startFly()
    stopFly()
    local r = getRoot(); if not r then return end
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.zero; bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5); bodyVel.Parent = r
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5); bodyGyro.P = 1e4; bodyGyro.Parent = r
    flyConn = connect(run.RenderStepped, function()
        if not flags["fly_on"] then stopFly(); return end
        local r2 = getRoot(); if not r2 then stopFly(); return end
        local dir = Vector3.zero
        if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
        bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * (flags["fly_speed"] or 60) or Vector3.zero
        bodyGyro.CFrame = cam.CFrame
    end)
end

flySec:AddToggle('fly_on', { Text = 'Fly', Default = false, Callback = function(v) flags['fly_on'] = v; local h = getHum(); if v then if h then h.PlatformStand = true end; startFly() else stopFly(); if h then h.PlatformStand = false end end end })
flySec:AddLabel('Fly Bind'):AddKeyPicker('fly_key', { Default = 'X', Mode = 'Hold', Text = 'Fly Bind', SyncToggleState = false })
flySec:AddSlider('fly_speed', { Text = 'Fly Speed', Min = 5, Max = 300, Default = 60, Rounding = 0, Suffix = ' sp', Callback = function(v) flags['fly_speed'] = v end })

local noclipConn
miscMove:AddToggle('noclip_on', { Text = 'No Clip', Default = false, Callback = function(v) flags['noclip_on'] = v; if v then noclipConn = connect(run.Stepped, function() if not flags['noclip_on'] then noclipConn:Disconnect(); noclipConn = nil; return end; local c = getChar(); if not c then return end; for _, p in ipairs(c:GetDescendants()) do if p:IsA('BasePart') then p.CanCollide = false end end end) else if noclipConn then noclipConn:Disconnect(); noclipConn = nil end end end })
miscMove:AddToggle('anti_afk', { Text = 'Anti-AFK', Default = false, Callback = function(v) flags['anti_afk'] = v end })

local weaponMod = weaponTab:AddLeftGroupbox('weapon mods')
local combatSec = weaponTab:AddRightGroupbox('combat')
local randSec = weaponTab:AddLeftGroupbox('randomizer')

local function getWeapons() 
    local w = rs:FindFirstChild("Weapons")
    return w and w:GetChildren() or {} 
end

local origWV = {}
local function saveWV(w, n) 
    origWV[w] = origWV[w] or {}
    local o = w:FindFirstChild(n)
    if o and origWV[w][n] == nil then origWV[w][n] = o.Value end 
end
local function restoreWV(w, n) 
    local o = w:FindFirstChild(n)
    if o and origWV[w] and origWV[w][n] ~= nil then pcall(function() o.Value = origWV[w][n] end) end 
end
local function applyToWeapons(names, valFn, v)
    for _, w in ipairs(getWeapons()) do
        for _, n in ipairs(names) do
            local obj = w:FindFirstChild(n)
            if obj then 
                if v then saveWV(w, n); pcall(function() obj.Value = valFn() end) else restoreWV(w, n) end 
            end
        end
    end
end

weaponMod:AddToggle('no_spread', { Text = 'No Spread', Default = false, Callback = function(v) flags['no_spread'] = v; applyToWeapons({'Spread', 'MaxSpread', 'MinSpread', 'Bloom', 'SpreadControl'}, function() return 0 end, v) end })
weaponMod:AddToggle('no_recoil', { Text = 'No Recoil', Default = false, Callback = function(v) flags['no_recoil'] = v; applyToWeapons({'RecoilControl', 'RecoilMax', 'RecoilMin', 'Recoil'}, function() return 0 end, v); for _, w in ipairs(getWeapons()) do local rp = w:FindFirstChild('RecoilPunch'); if rp then if v then saveWV(w, 'RecoilPunch'); pcall(function() rp.Value = Vector3.zero end) else restoreWV(w, 'RecoilPunch') end end end end })
weaponMod:AddToggle('rapid_fire', { Text = 'Rapid Fire', Default = false, Callback = function(v) flags['rapid_fire'] = v; applyToWeapons({'FireRate', 'BFireRate'}, function() return 0.02 end, v) end })
weaponMod:AddToggle('always_auto', { Text = 'Always Auto', Default = false, Callback = function(v) flags['always_auto'] = v; applyToWeapons({'Auto', 'AutoFire', 'Automatic', 'AutoShoot', 'AutoGun'}, function() return true end, v) end })
weaponMod:AddToggle('fast_reload', { Text = 'Fast Reload', Default = false, Callback = function(v) flags['fast_reload'] = v; applyToWeapons({'ReloadTime', 'EReloadTime'}, function() return 0.01 end, v) end })

weaponMod:AddToggle('custom_fire_rate_on', { Text = 'Custom Fire Rate', Default = false, Callback = function(v) flags['custom_fire_rate_on'] = v; if v then for _, w in ipairs(getWeapons()) do for _, n in ipairs({'FireRate', 'BFireRate'}) do local o = w:FindFirstChild(n); if o then saveWV(w, n); pcall(function() o.Value = flags['custom_fire_rate_val'] or 0.15 end) end end end else for _, w in ipairs(getWeapons()) do for _, n in ipairs({'FireRate', 'BFireRate'}) do restoreWV(w, n) end end end end })
weaponMod:AddSlider('custom_fire_rate_val', { Text = 'Fire Rate Value', Min = 0.001, Max = 1, Default = 0.15, Rounding = 3, Suffix = 's', Callback = function(v) flags['custom_fire_rate_val'] = v; if flags['custom_fire_rate_on'] then for _, w in ipairs(getWeapons()) do for _, n in ipairs({'FireRate', 'BFireRate'}) do local o = w:FindFirstChild(n); if o then pcall(function() o.Value = v end) end end end end end })

local ammoVal = 677
local function setAllAmmo()
    for _, w in ipairs(getWeapons()) do 
        local o = w:FindFirstChild("Ammo")
        if o and o.Value ~= ammoVal then pcall(function() o.Value = ammoVal end) end 
    end
    pcall(function()
        local vars = lp.PlayerGui.GUI.Client.Variables
        if vars.ammocount.Value ~= ammoVal then vars.ammocount.Value = ammoVal end
        if vars.ammocount2.Value ~= ammoVal then vars.ammocount2.Value = ammoVal end
    end)
    pcall(function() 
        if flags["inf_ammo"] then rs.wkspc.CurrentCurse.Value = "Infinite Ammo" end 
    end)
end

local function hookWeaponAmmo(w)
    local o = w:FindFirstChild("Ammo")
    if not o then return end
    connect(o:GetPropertyChangedSignal("Value"), function() 
        if flags["inf_ammo"] and o.Value ~= ammoVal then pcall(function() o.Value = ammoVal end) end 
    end)
end

for _, w in ipairs(getWeapons()) do hookWeaponAmmo(w) end
local wf = rs:FindFirstChild("Weapons")
if wf then connect(wf.ChildAdded, function(w) task.wait(0.05); hookWeaponAmmo(w) end) end

local ammoCounter = 0
connect(run.Heartbeat, function()
    if not flags["inf_ammo"] then return end
    ammoCounter = ammoCounter + 1
    if ammoCounter % 3 == 0 then setAllAmmo() end
end)

weaponMod:AddToggle('inf_ammo', { Text = 'Infinite Ammo', Default = false, Callback = function(v) flags['inf_ammo'] = v; if v then setAllAmmo() else pcall(function() rs.wkspc.CurrentCurse.Value = '' end) end end })
weaponMod:AddSlider('bullet_mult', { Text = 'Bullet Multiplier', Min = 1, Max = 10, Default = 1, Rounding = 0, Suffix = 'x', Callback = function(v) flags['bullet_mult'] = v end })
weaponMod:AddToggle('remove_kill_bricks', { Text = 'Remove Kill Bricks', Default = false, Callback = function(v) flags['remove_kill_bricks'] = v end })

connect(run.Heartbeat, function()
    if flags["bullet_mult"] > 1 then
        for _, w in ipairs(getWeapons()) do
            local b = w:FindFirstChild("Bullets") or w:FindFirstChild("Bullets2")
            if b and b:IsA("IntValue") then pcall(function() b.Value = flags["bullet_mult"] end) end
        end
    end
end)

local killAllActive = false
local killAllThread = nil

local function getAliveEnemies()
    local list = {}
    local targetUser = (flags["kill_target_user"] or ""):lower()
    
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp and (not flags["kill_team_check"] or pl.Team ~= lp.Team) and is_spawned(pl) then 
            if targetUser == "" or string.find(pl.Name:lower(), targetUser, 1, true) or string.find(pl.DisplayName:lower(), targetUser, 1, true) then
                table.insert(list, pl) 
            end
        end
    end
    
    for i = #list, 2, -1 do 
        local j = math.random(1, i); list[i], list[j] = list[j], list[i] 
    end
    return list
end

local function runKillAll()
    local crouching = false
    while killAllActive do
        if is_spawned(lp) then
            local enemies = getAliveEnemies()
            if #enemies == 0 then 
                if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
                task.wait(0.5) 
            else
                for _, target in ipairs(enemies) do
                    if not killAllActive then 
                        if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
                        return 
                    end
                    if not is_spawned(target) then continue end

                    local r = getRoot()
                    local c = target.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    local head = c and c:FindFirstChild("Head")
                    
                    if r and hrp and h and h.Health > 0 then
                        if (hrp.Position - r.Position).Magnitude > (flags["kill_max_dist"] or 1000) then continue end
                        if flags["kill_all_wall_check"] and not wall_check(c, hrp) then 
                            task.wait(0.1)
                            continue 
                        end

                        if flags["kill_auto_crouch"] and not crouching then
                            VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                            crouching = true
                        end

                        local engageStart = tick()
                        local maxEngage = flags["kill_engage_time"] or 4
                        
                        while killAllActive and is_spawned(target) do
                            r = getRoot()
                            c = target.Character
                            h = c and c:FindFirstChildOfClass("Humanoid")
                            hrp = c and c:FindFirstChild("HumanoidRootPart")
                            head = c and c:FindFirstChild("Head")
                            
                            if not r or not c or not h or not hrp or not head then break end
                            if h.Health <= 0 then break end

                            if flags["kill_use_max_engage"] and (tick() - engageStart > maxEngage) then 
                                break 
                            end

                            local behindPos = hrp.Position - (hrp.CFrame.LookVector * 4.5)
                            r.CFrame = CFrame.new(behindPos, head.Position)
                            
                            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, head.Position)

                            state.aim_target_player = target
                            state.aim_target_part = head

                            if flags["kill_auto_knife"] then
                                VIM:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                                task.wait()
                                VIM:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                            end

                            if flags["kill_use_triggerbot"] then
                                mouse1press()
                                state.lastClickTime = tick() 
                                task.wait(0.02)
                                mouse1release()
                            end

                            task.wait(flags["kill_delay"] or 0.06)
                        end
                    else
                        if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
                    end
                    state.aim_target_player = nil
                    state.aim_target_part = nil
                end
            end
        else
            if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
        end
        task.wait(0.1)
    end
    if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
end

local function setKillAll(active)
    killAllActive = active; flags["kill_all"] = active
    if killAllThread then task.cancel(killAllThread); killAllThread = nil end
    if active then killAllThread = task.spawn(runKillAll) end
end

combatSec:AddToggle('kill_all', { Text = 'Kill All', Default = false, Callback = function(v) setKillAll(v) end })
combatSec:AddLabel('Kill All Bind'):AddKeyPicker('kill_all_key', { Default = 'T', Mode = 'Hold', Text = 'Kill All Bind', SyncToggleState = false })
combatSec:AddInput('kill_target_user', { Text = 'Target User', Default = '', Placeholder = 'username', Callback = function(v) flags['kill_target_user'] = v end })
combatSec:AddToggle('kill_team_check', { Text = 'Team Check', Default = true, Callback = function(v) flags['kill_team_check'] = v end })
combatSec:AddToggle('kill_all_wall_check', { Text = 'Wall Check', Default = false, Callback = function(v) flags['kill_all_wall_check'] = v end })
combatSec:AddToggle('kill_auto_crouch', { Text = 'Auto Crouch', Default = false, Callback = function(v) flags['kill_auto_crouch'] = v end })
combatSec:AddToggle('kill_auto_knife', { Text = 'Auto Equip Knife', Default = false, Callback = function(v) flags['kill_auto_knife'] = v end })
combatSec:AddToggle('kill_use_triggerbot', { Text = 'Use Triggerbot', Default = true, Callback = function(v) flags['kill_use_triggerbot'] = v end })
combatSec:AddToggle('kill_use_max_engage', { Text = 'Use Max Engage Time', Default = true, Callback = function(v) flags['kill_use_max_engage'] = v end })
combatSec:AddSlider('kill_max_dist', { Text = 'Max Distance', Min = 50, Max = 5000, Default = 1000, Rounding = 0, Suffix = ' st', Callback = function(v) flags['kill_max_dist'] = v end })
combatSec:AddSlider('kill_delay', { Text = 'TP Delay', Min = 0.001, Max = 0.5, Default = 0.06, Rounding = 3, Suffix = 's', Callback = function(v) flags['kill_delay'] = v end })
combatSec:AddSlider('kill_engage_time', { Text = 'Max Engage Time', Min = 0.5, Max = 10, Default = 4, Rounding = 1, Suffix = 's', Callback = function(v) flags['kill_engage_time'] = v end })

local spinConn
combatSec:AddToggle('spin_on', { Text = 'Spin Bot', Default = false, Callback = function(v) flags['spin_on'] = v; if v then spinConn = connect(run.RenderStepped, function(dt) if not flags['spin_on'] then spinConn:Disconnect(); spinConn = nil; return end; local r = getRoot(); if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad((flags['spin_speed'] or 180) * dt), 0) end end) else if spinConn then spinConn:Disconnect(); spinConn = nil end end end })
combatSec:AddSlider('spin_speed', { Text = 'Spin Speed', Min = 10, Max = 720, Default = 180, Rounding = 0, Suffix = '°/s', Callback = function(v) flags['spin_speed'] = v end })

combatSec:AddToggle('anti_aim_small', { Text = 'Anti-Aim', Default = false, Callback = function(v) flags['anti_aim_small'] = v end })

randSec:AddToggle('rand_always_skip', { Text = 'Always Skip', Default = false, Callback = function(v) flags['rand_always_skip'] = v end })

local function getItems(category)
    local list = {}
    local folder = rs:FindFirstChild("ItemData") and rs.ItemData:FindFirstChild("Images") and rs.ItemData.Images:FindFirstChild(category)
    if folder then 
        for _, v in ipairs(folder:GetChildren()) do table.insert(list, v.Name) end 
    end
    table.sort(list)
    return list
end

local meleeSec = skinsTab:AddLeftGroupbox('melee')
local skinSec = skinsTab:AddRightGroupbox('skin')
local announcerSec = skinsTab:AddLeftGroupbox('announcer')
local cardSec = skinsTab:AddRightGroupbox('card')
local crateSec = skinsTab:AddRightGroupbox('crates')

local function updatePreview(vp, category, name)
    for _, c in ipairs(vp:GetChildren()) do 
        if c:IsA("ImageLabel") then c:Destroy() end 
    end
    local imgFolder = rs:FindFirstChild("ItemData") and rs.ItemData:FindFirstChild("Images") and rs.ItemData.Images:FindFirstChild(category)
    if not imgFolder then return end
    local imgObj = imgFolder:FindFirstChild(name)
    if not imgObj then return end
    
    local imgAsset = imgObj:IsA("StringValue") and imgObj.Value or (imgObj:IsA("ImageLabel") and imgObj.Image or "")
    if imgAsset and not string.find(imgAsset, "rbxassetid") and tonumber(imgAsset) then
        imgAsset = "rbxassetid://" .. imgAsset
    end
    
    library:Create("ImageLabel", { 
        Parent = vp, 
        Size = UDim2.new(0, 100, 0, 100), 
        Position = UDim2.new(0.5, -50, 0.5, -50), 
        BackgroundTransparency = 1, 
        Image = imgAsset, 
        ZIndex = 6 
    })
end

local meleeVP = library:Create("Frame", { Parent = meleeSec.Container, Size = UDim2.new(1, -4, 0, 120), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, ZIndex = 5 })
local skinVP = library:Create("Frame", { Parent = skinSec.Container, Size = UDim2.new(1, -4, 0, 120), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, ZIndex = 5 })
local announcerVP = library:Create("Frame", { Parent = announcerSec.Container, Size = UDim2.new(1, -4, 0, 120), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, ZIndex = 5 })
local cardVP = library:Create("Frame", { Parent = cardSec.Container, Size = UDim2.new(1, -4, 0, 120), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, ZIndex = 5 })
local crateVP = library:Create("Frame", { Parent = crateSec.Container, Size = UDim2.new(1, -4, 0, 120), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, ZIndex = 5 })

meleeSec:AddBlank(0)
skinSec:AddBlank(0)
announcerSec:AddBlank(0)
cardSec:AddBlank(0)
crateSec:AddBlank(0)

local meleeList = getItems("Melees")
local skinList = getItems("Skins")
local announcerList = getItems("Announcers")
local cardList = getItems("Cards")
local crateList = getItems("Crate")

local meleeDrop = meleeSec:AddDropdown('lx_melee', { Text = 'Select Melee', Values = meleeList, Default = flags['lx_melee'], Callback = function(v) flags['lx_melee'] = v; updatePreview(meleeVP, 'Melees', v) end })
meleeSec:AddInput('search_melee', { Text = 'Search', Default = '', Placeholder = 'search...', Callback = function(text) local filtered = {}; for _, item in ipairs(meleeList) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end; meleeDrop:SetValues(filtered) end })
meleeSec:AddButton({ Text = 'Apply Melee', Func = function() local d = lp:FindFirstChild('Data'); if d and d.Melee then pcall(function() d.Melee.Value = flags['lx_melee'] end) end end })

local skinDrop = skinSec:AddDropdown('lx_skin', { Text = 'Select Skin', Values = skinList, Default = flags['lx_skin'], Callback = function(v) flags['lx_skin'] = v; updatePreview(skinVP, 'Skins', v) end })
skinSec:AddInput('search_skin', { Text = 'Search', Default = '', Placeholder = 'search...', Callback = function(text) local filtered = {}; for _, item in ipairs(skinList) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end; skinDrop:SetValues(filtered) end })
skinSec:AddButton({ Text = 'Apply Skin', Func = function()
    local skin_name = flags["lx_skin"]
    if skin_name and skin_name ~= "" then
        pcall(function()
            local d = lp:FindFirstChild('Data')
            if d and d.Skin then 
                d.Skin.Value = skin_name
                if d.Skin:FindFirstChild('Sleeve') then d.Skin.Sleeve.Value = skin_name end
            end
        end)
        pcall(function() firesignal(rs.Events.CharacterLoaded.OnClientEvent, getChar(), skin_name) end)
        library:Notify("applied skin: ".. skin_name)
    end
end })

local announcerDrop = announcerSec:AddDropdown('lx_announcer', { Text = 'Select Announcer', Values = announcerList, Default = flags['lx_announcer'], Callback = function(v) flags['lx_announcer'] = v; updatePreview(announcerVP, 'Announcers', v) end })
announcerSec:AddInput('search_announcer', { Text = 'Search', Default = '', Placeholder = 'search...', Callback = function(text) local filtered = {}; for _, item in ipairs(announcerList) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end; announcerDrop:SetValues(filtered) end })
announcerSec:AddButton({ Text = 'Apply Announcer', Func = function() local d = lp:FindFirstChild('Data'); if d and d.Announcer then pcall(function() d.Announcer.Value = flags['lx_announcer'] end) end end })

local cardDrop = cardSec:AddDropdown('lx_card', { Text = 'Select Card', Values = cardList, Default = flags['lx_card'], Callback = function(v) flags['lx_card'] = v; updatePreview(cardVP, 'Cards', v) end })
cardSec:AddInput('search_card', { Text = 'Search', Default = '', Placeholder = 'search...', Callback = function(text) local filtered = {}; for _, item in ipairs(cardList) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end; cardDrop:SetValues(filtered) end })
cardSec:AddButton({ Text = 'Apply Card', Func = function() 
    local d = lp:FindFirstChild('Data'); if d and d.Card then pcall(function() d.Card.Value = flags['lx_card'] end) end 
    pcall(function() 
        firesignal(rs.Events.GetStatData.OnClientEvent, {
            NewKills = flags['spoof_kills'], RoundsLost = flags['spoof_losses'], Card = flags['lx_card'], HeadshotKills = flags['spoof_hs'],
            FastestTimes = { Automatics = 130, Standard = 74, ["Shotguns Only"] = 93, ["Railgun Royale"] = 43, ["Snipers Only"] = 139 },
            RoundsWon = flags['spoof_wins']
        })
    end)
end })

local crateDrop = crateSec:AddDropdown('lx_crate', { Text = 'Select Crate', Values = crateList, Default = flags['lx_crate'], Callback = function(v) flags['lx_crate'] = v; updatePreview(crateVP, 'Crate', v) end })
crateSec:AddButton({ Text = 'Open Crate', Func = function()
    local crate = flags["lx_crate"]
    if crate then
        pcall(function() rs.Events.BuyItem:FireServer({"BuyItem", "Crate", crate}) end)
        pcall(function() rs.Events.OpenCase:FireServer(crate) end)
    end
end })

if flags['lx_melee'] ~= "" then updatePreview(meleeVP, "Melees", flags['lx_melee']) end
if flags['lx_skin'] ~= "" then updatePreview(skinVP, "Skins", flags['lx_skin']) end
if flags['lx_announcer'] ~= "" then updatePreview(announcerVP, "Announcers", flags['lx_announcer']) end
if flags['lx_card'] ~= "" then updatePreview(cardVP, "Cards", flags['lx_card']) end
if flags['lx_crate'] ~= "" then updatePreview(crateVP, "Crate", flags['lx_crate']) end

local miscSec = miscTab:AddLeftGroupbox('local player')
local serverSec = miscTab:AddLeftGroupbox('server')
local killfeedSec = miscTab:AddRightGroupbox('kill feed')
local chatTagSec = miscTab:AddRightGroupbox('chat tags')
local statsSec = miscTab:AddRightGroupbox('stats spoofer')
local codeSec = miscTab:AddRightGroupbox('code redeemer')
local favSec = miscTab:AddLeftGroupbox('favorite weapons')
local casePredSec = miscTab:AddLeftGroupbox('case predictor')
local featSec = miscTab:AddLeftGroupbox('featured items')

miscSec:AddToggle('anti_afk', { Text = 'Anti-AFK', Default = false, Callback = function(v) flags['anti_afk'] = v end })
miscSec:AddToggle('auto_deploy', { Text = 'Auto Deploy', Default = false, Callback = function(v) flags['auto_deploy'] = v end })
miscSec:AddToggle('auto_vote', { Text = 'Auto Vote', Default = false, Callback = function(v) flags['auto_vote'] = v end })
miscSec:AddSlider('cam_fov', { Text = 'Camera FOV', Min = 40, Max = 120, Default = defaultFOV, Rounding = 0, Suffix = '°', Callback = function(v) flags['cam_fov'] = v; cam.FieldOfView = v; pcall(function() lp.Settings.FOV.Value = v end) end })

miscSec:AddToggle('ping_spoof', { Text = 'Ping Spoofer', Default = false, Callback = function(v) flags['ping_spoof'] = v end })
miscSec:AddSlider('fake_ping', { Text = 'Fake Ping', Min = 0, Max = 9999, Default = 100, Rounding = 0, Suffix = ' ms', Callback = function(v) flags['fake_ping'] = v end })

miscSec:AddToggle('device_spoof', { Text = 'Device Spoofer', Default = false, Callback = function(v) flags['device_spoof'] = v end })
miscSec:AddDropdown('fake_device', { Text = 'Device', Values = {'PC', 'Mobile', 'Tablet', 'Console'}, Default = 'PC', Callback = function(v) flags['fake_device'] = v end })

miscSec:AddButton({ Text = 'Unlock All Crates', Func = function() local pgui = lp:FindFirstChild('PlayerGui'); if not pgui then return end; local gui = pgui:FindFirstChild('Menew'); if not gui then return end; local shop = gui:FindFirstChild('Shop'); if not shop then return end; local cases = shop:FindFirstChild('Cases'); if not cases then return end; for _, case in pairs(cases:GetChildren()) do if case:IsA('GuiObject') then case.Visible = true end end end })

killfeedSec:AddToggle('killfeed_on', { Text = 'Custom Kill Feed', Default = false, Callback = function(v) flags['killfeed_on'] = v end })
killfeedSec:AddInput('killfeed_killer', { Text = 'Killer', Default = '', Placeholder = 'Killer name...', Callback = function(v) flags['killfeed_killer'] = v end })
killfeedSec:AddInput('killfeed_victim', { Text = 'Victim', Default = '', Placeholder = 'Victim name...', Callback = function(v) flags['killfeed_victim'] = v end })
killfeedSec:AddInput('killfeed_assist', { Text = 'Assist', Default = '', Placeholder = 'Assist name...', Callback = function(v) flags['killfeed_assist'] = v end })

local tagsList = {
    {name = "IsAdmin", text = "Admin"}, {name = "IsChad", text = "Chad"}, {name = "VIP", text = "VIP"}, {name = "OldVIP", text = "Old VIP"},
    {name = "GroupMember", text = "Group Member"}, {name = "Romin", text = "Romin"}, {name = "Workshop", text = "Workshop"}
}
for _, tag in ipairs(tagsList) do
    chatTagSec:AddToggle('tag_' .. tag.name, { Text = tag.text, Default = false, Callback = function(v)
        if v then
            if not lp:FindFirstChild(tag.name) then
                local v = Instance.new("BoolValue")
                v.Name = tag.name
                v.Parent = lp
            end
        else
            if lp:FindFirstChild(tag.name) then
                lp[tag.name]:Destroy()
            end
        end
    end })
end

serverSec:AddButton({ Text = 'Copy Server ID', Func = function() pcall(function() setclipboard(game.JobId) end) end })
serverSec:AddButton({ Text = 'Rejoin Server', Func = function() game:GetService('TeleportService'):Teleport(game.PlaceId, lp) end })
serverSec:AddButton({ Text = 'Server Hop', Func = function() pcall(function() local http = game:GetService('HttpService'); local servers = http:JSONDecode(HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100')); for _, s in ipairs(servers.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, s.id, lp); break end end end) end })

serverSec:AddInput('fake_server_msg', { Text = 'Message', Default = 'Hello', Placeholder = 'Message...', Callback = function(v) flags['fake_server_msg'] = v end })
serverSec:AddButton({ Text = 'Send Fake Server Message', Func = function()
    pcall(function() firesignal(rs.Events.SendMsg.OnClientEvent, flags['fake_server_msg'], Color3.new(1, 1, 1)) end)
end })

statsSec:AddToggle('stats_spoof_on', { Text = 'Enabled', Default = false, Callback = function(v) flags['stats_spoof_on'] = v end })
statsSec:AddSlider('spoof_level', { Text = 'Career Level', Min = 1, Max = 999, Default = 100, Rounding = 0, Callback = function(v) flags['spoof_level'] = v end })
statsSec:AddSlider('spoof_kills', { Text = 'Career Kills', Min = 0, Max = 100000, Default = 1000, Rounding = 0, Callback = function(v) flags['spoof_kills'] = v end })
statsSec:AddInput('spoof_kd', { Text = 'K/D Ratio', Default = '2.5', Placeholder = '2.5', Callback = function(v) flags['spoof_kd'] = v end })
statsSec:AddSlider('spoof_hs', { Text = 'Headshot Percentage', Min = 0, Max = 100, Default = 50, Rounding = 0, Suffix = '%', Callback = function(v) flags['spoof_hs'] = v end })
statsSec:AddSlider('spoof_win', { Text = 'Win Percentage', Min = 0, Max = 100, Default = 60, Rounding = 0, Suffix = '%', Callback = function(v) flags['spoof_win'] = v end })
statsSec:AddSlider('spoof_wins', { Text = 'Rounds Won', Min = 0, Max = 100000, Default = 500, Rounding = 0, Callback = function(v) flags['spoof_wins'] = v end })
statsSec:AddSlider('spoof_played', { Text = 'Rounds Played', Min = 0, Max = 100000, Default = 1000, Rounding = 0, Callback = function(v) flags['spoof_played'] = v end })
statsSec:AddSlider('spoof_total_rounds', { Text = 'Total Rounds', Min = 0, Max = 100000, Default = 1000, Rounding = 0, Callback = function(v) flags['spoof_total_rounds'] = v end })
statsSec:AddButton({ Text = 'Apply Stats', Func = function()
    pcall(function()
        firesignal(rs.Events.GetStatData.OnClientEvent, {
            Level = flags['spoof_level'],
            Kills = flags['spoof_kills'],
            KDR = flags['spoof_kd'],
            HeadshotPercent = flags['spoof_hs'],
            WinPercent = flags['spoof_win'],
            RoundsWon = flags['spoof_wins'],
            RoundsPlayed = flags['spoof_played'],
            TotalRounds = flags['spoof_total_rounds'],
            Card = flags['lx_card'] or "Default"
        })
        library:Notify("applied stats")
    end)
end })

codeSec:AddInput('redeem_code', { Text = 'Code', Default = '', Placeholder = 'Enter code...', Callback = function(v) flags['redeem_code'] = v end })
codeSec:AddButton({ Text = 'Redeem Code', Func = function()
    local code = flags["redeem_code"]
    if code and code ~= "" then
        local success, codes = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/codexvsberserkerxylo/modules/refs/heads/main/codes.luau"))() end)
        if success and type(codes) == "table" and table.find(codes, code) then
            pcall(function() rs.Redeem:InvokeServer(code) end)
            library:Notify("Redeemed code: "..code)
        else
            library:Notify("Invalid code: "..code)
        end
    end
end })
codeSec:AddButton({ Text = 'Redeem All Codes', Func = function()
    local success, codes = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/codexvsberserkerxylo/modules/refs/heads/main/codes.luau"))() end)
    if success and type(codes) == "table" then
        for _, code in ipairs(codes) do
            pcall(function() rs.Redeem:InvokeServer(code) end)
            task.wait(0.5)
        end
        library:Notify("Redeemed all codes!")
    else
        library:Notify("Failed to load codes.")
    end
end })

local favList = {}
for _, v in ipairs(rs.FavoriteWeapons:GetChildren()) do
    if v:IsA("StringValue") then
        table.insert(favList, v.Name)
    end
end
table.sort(favList)

local favDrop = favSec:AddDropdown('fav_sel', { Text = 'Select Character', Values = favList, Default = favList[1] or '', Callback = function(v) flags['fav_sel'] = v end })
local favLabel = favSec:AddLabel('Click Fetch to view weapon')
favSec:AddButton({ Text = 'Fetch', Func = function()
    local sel = flags["fav_sel"]
    if sel and sel ~= "" then
        local weapon = rs.FavoriteWeapons:FindFirstChild(sel)
        if weapon then
            favLabel:SetText(weapon.Value)
        else
            favLabel:SetText("Weapon not found")
        end
    end
end })

local caseLabel1 = casePredSec:AddLabel('Case: None')
local caseLabel2 = casePredSec:AddLabel('Got: None')
local caseLabel3 = casePredSec:AddLabel('Type: None')
connect(rs.Events.RefreshInventory.OnClientEvent, function(...)
    local args = {...}
    if args[4] then
        local crateName = args[4]
        local gotItem = args[3] and args[3][1] or "Unknown"
        local itemType = args[3] and args[3][2] or "Unknown"
        caseLabel1:SetText("Case: " .. crateName)
        caseLabel2.SetText("Got: " .. gotItem)
        caseLabel3.SetText("Type: " .. itemType)
    end
end)

local featList = {}
pcall(function()
    for _, child in ipairs(lp.PlayerGui.Menew.Shop.FeaturedItems:GetChildren()) do
        table.insert(featList, child.Name)
    end
end)
local featDrop = featSec:AddDropdown('buy_feat_sel', { Text = 'Select Featured Item', Values = featList, Default = featList[1] or '', Callback = function(v) flags['buy_feat_sel'] = v end })
featSec:AddButton({ Text = 'Buy Featured Item', Func = function()
    local item = flags["buy_feat_sel"]
    if item and item ~= "" then
        pcall(function()
            rs.Events.BuyItem:FireServer({
                "BuyItem",
                "Featured",
                item
            })
        end)
        library:Notify("Buying " .. item)
    end
end })

local uiSec = settingsTab:AddRightGroupbox('ui')
local autoExecSec = settingsTab:AddRightGroupbox('auto execution')

local function applyLoadedSkins()
    local data = lp:FindFirstChild("Data")
    if not data then return end
    if flags["lx_melee"] and flags["lx_melee"] ~= "" then
        pcall(function() data.Melee.Value = flags["lx_melee"] end)
    end
    if flags["lx_skin"] and flags["lx_skin"] ~= "" then
        pcall(function()
            data.Skin.Value = flags["lx_skin"]
            if data.Skin:FindFirstChild("Sleeve") then data.Skin.Sleeve.Value = flags["lx_skin"] end
        end)
    end
    if flags["lx_announcer"] and flags["lx_announcer"] ~= "" then
        pcall(function() data.Announcer.Value = flags["lx_announcer"] end)
    end
end

autoExecSec:AddToggle('auto_exec_on_join', { Text = 'Auto exec on Join', Default = false, Callback = function(v) flags['auto_exec_on_join'] = v; if v then writefile("LunarX/arsenal/autoexec.cfg", "true"); library:Notify('place this script in your autoexec folder if auto exec isnt working!') else if isfile("LunarX/arsenal/autoexec.cfg") then delfile("LunarX/arsenal/autoexec.cfg") end end end })
autoExecSec:AddToggle('silent_load', { Text = 'Silent load', Default = false, Callback = function(v) flags['silent_load'] = v; if v then writefile("LunarX/arsenal/silentload.cfg", "true") else if isfile("LunarX/arsenal/silentload.cfg") then delfile("LunarX/arsenal/silentload.cfg") end end end })

uiSec:AddToggle('ui_keybind_list', { Text = 'Keybind List', Default = false, Callback = function(v) flags['ui_keybind_list'] = v; library.KeybindFrame.Visible = v end })
local ftimer = tick()
local fcounter = 0
local fps = 60

local wconn = game:GetService('RunService').RenderStepped:Connect(function()
    fcounter += 1
    if (tick() - ftimer) >= 1 then
        fps = fcounter
        ftimer = tick()
        fcounter = 0
    end
    library:SetWatermark(('lunar x | %s fps'):format(math.floor(fps)))
end)

uiSec:AddLabel('Menu Toggle'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', Mode = 'Toggle', Text = 'Menu Toggle', NoUI = true })
library.ToggleKeybind = Options.MenuKeybind

uiSec:AddButton({ Text = 'Unload', Func = function()
    disconnect_all()
    for pl, _ in pairs(espObjects) do destroyESP(pl) end
    for obj, d in pairs(pickupESPObjects) do removePickupDraw(d) end
    pickupESPObjects = {}
    fovCircle:Remove()
    for _, l in pairs(xhairLines) do l:Remove() end

    for _, pl in ipairs(plrs:GetPlayers()) do
        restoreHitbox(pl); removeChams(pl)
        if pl.Character then local ex = pl.Character:FindFirstChild("LunarHL"); if ex then ex:Destroy() end end
    end
    removeAntiAim()
    local c = getChar()
    if c then local ex = c:FindFirstChild("LunarSelfHL"); if ex then ex:Destroy() end end

    light.Ambient = lightOrig.Ambient
    light.Brightness = lightOrig.Brightness
    light.FogEnd = lightOrig.FogEnd
    light.FogStart = lightOrig.FogStart
    pcall(function() rs.CurrentGrav.Value = 56 end)
    pcall(function() lp.Settings.FOV.Value = defaultFOV end)
    apply_walkspeed(false, 16); apply_jumppower(false, 50)
    library:Unload()
end})

local function getTarget()
    if not is_spawned(lp) then return nil end
    local mp = uis:GetMouseLocation()
    local fov = flags["fov_radius"] or 150
    local maxDist = flags["aim_max_dist"] or 500
    local root = getRoot()
    local best, bestScore = nil, math.huge

    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl == lp then continue end
        if flags["aim_team_check"] and pl.Team == lp.Team then continue end
        if not is_spawned(pl) then continue end

        local c = pl.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local part = c and c:FindFirstChild(flags["aim_part"] or "Head")
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not (c and h and part and hrp and h.Health > 0) then continue end
        if root and (hrp.Position - root.Position).Magnitude > maxDist then continue end

        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local screenDist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
        if screenDist > fov then continue end

        if not wall_check(c, part) then continue end

        local priority = flags["aim_priority"] or "Nearest Mouse"
        local score
        if priority == "Nearest Mouse" then score = screenDist
        elseif priority == "Nearest Distance" then score = root and (hrp.Position - root.Position).Magnitude or screenDist
        elseif priority == "Lowest HP" then score = h.Health end
        if score and score < bestScore then best = pl; bestScore = score end
    end
    return best
end

local function isEnemyPlayer(pl) 
    return not flags["aim_team_check"] or pl.Team ~= lp.Team 
end

local function hookTriggerHumanoid(char)
    local h = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if h then connect(h.HealthChanged, function(hp) state.triggerAlive = hp > 0 end) end
    state.triggerAlive = true
end
connect(lp.CharacterAdded, hookTriggerHumanoid)
if getChar() then hookTriggerHumanoid(getChar()) end

local prevFly = false
local prevKill = false

connect(run.RenderStepped, function(dt)
    local mp = uis:GetMouseLocation()
    local vp = cam.ViewportSize
    local espOn = flags["esp_on"]
    local rootPos = getRoot() and getRoot().Position

    keybinds.aim = Options.aim_key and Options.aim_key:GetState() or false
    keybinds.trigger = Options.trigger_key and Options.trigger_key:GetState() or false

    local currFly = Options.fly_key and Options.fly_key:GetState() or false
    if currFly ~= prevFly then
        keybinds.fly = currFly; flags["fly_on"] = currFly
        local h = getHum()
        if currFly then 
            if h then h.PlatformStand = true end; startFly()
        else 
            stopFly(); if h then h.PlatformStand = false end 
        end
    end
    prevFly = currFly

    local currKill = Options.kill_all_key and Options.kill_all_key:GetState() or false
    if currKill ~= prevKill then
        setKillAll(currKill)
    end
    prevKill = currKill

    if flags["anti_aim_small"] then
        applyAntiAim()
    else
        removeAntiAim()
    end

    applyArmChams()
    applyGunChams()

    if flags["stretched_res"] then
        pcall(function()
            local aspect = flags["stretched_x"] / flags["stretched_y"]
            cam.ViewportSize = Vector2.new(flags["stretched_x"], flags["stretched_y"])
        end)
    end

    if flags["fov_visible"] then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(mp.X, mp.Y)
        fovCircle.Color = flags["fov_color"]
        fovCircle.Thickness = flags["fov_thickness"] or 1
        fovCircle.Filled = flags["fov_filled"] or false
        fovCircle.Radius = flags["fov_radius"] or 150
        fovCircle.NumSides = 60
    else
        fovCircle.Visible = false
    end

    local currentTarget = nil
    if flags["aim_on"] or flags["triggerbot"] then
        currentTarget = getTarget()
    end

    if flags["aim_on"] and keybinds.aim and currentTarget and currentTarget.Character and is_spawned(currentTarget) then
        local part = currentTarget.Character:FindFirstChild(flags["aim_part"] or "Head")
        if part then
            local smooth = flags["aim_smooth"] or 0.15
            if math.random(1, 100) <= (flags["aim_hit_chance"] or 100) then
                local targetPos = part.Position
                if flags["aim_prediction"] then
                    local hrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then targetPos = targetPos + hrp.AssemblyLinearVelocity * (flags["aim_pred_val"] or 0.1) end
                end
                cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, targetPos), smooth)
            end
        end
    end

    if flags["triggerbot"] and state.triggerAlive and is_spawned(lp) then
        if keybinds.trigger then
            local now = tick()
            if now - state.triggerCooldown >= (flags["trigger_delay"] or 0.08) then
                local tgt = mouse.Target
                if tgt and tgt.Parent then
                    local h = tgt.Parent:FindFirstChild("Humanoid")
                    if h and tgt.Parent.Name ~= lp.Name and h.Health > 0 then
                        local tp = plrs:FindFirstChild(tgt.Parent.Name)
                        if tp and isEnemyPlayer(tp) and is_spawned(tp) then
                            mouse1press()
                            state.lastClickTime = tick() 
                            task.delay(flags["trigger_delay"] or 0.08, function() mouse1release() end)
                            state.triggerCooldown = now
                        end
                    end
                end
            end
        end
    end

    if flags["xhair_on"] then
        local cx, cy = vp.X / 2, vp.Y / 2
        local sz, gap, thk = flags["xhair_size"] or 10, flags["xhair_gap"] or 3, flags["xhair_thick"] or 2
        local col = state.colors.xhair
        local function setL(l, fx, fy, tx, ty) 
            l.From, l.To = Vector2.new(fx, fy), Vector2.new(tx, ty)
            l.Thickness, l.Color, l.Visible = thk, col, true 
        end
        setL(xhairLines.top, cx, cy - gap - sz, cx, cy - gap)
        setL(xhairLines.bottom, cx, cy + gap, cx, cy + gap + sz)
        setL(xhairLines.left, cx - gap - sz, cy, cx - gap, cy)
        setL(xhairLines.right, cx + gap, cy, cx + gap + sz, cy)
        xhairLines.dot.Visible = flags["xhair_dot"] == true
        xhairLines.dot.Position = Vector2.new(cx, cy)
        xhairLines.dot.Color = col
    else
        for _, l in pairs(xhairLines) do l.Visible = false end
    end

    for pl, d in pairs(espObjects) do
        local c = pl.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local hrp = c and c:FindFirstChild("HumanoidRootPart")

        local function hideAll()
            d.box.Visible = false; d.boxFill.Visible = false
            d.nameText.Visible = false; d.distText.Visible = false
            d.weaponText.Visible = false
            d.hpBG.Visible = false; d.hpBar.Visible = false; d.hpText.Visible = false
            d.tracer.Visible = false; d.snapLine.Visible = false
            for _, l in ipairs(d.corners) do l.Visible = false end
            for _, l in ipairs(d.skeleton) do l.Visible = false end
        end

        if not espOn or not c or not h or not hrp or h.Health <= 0 or not is_spawned(pl) then hideAll(); continue end
        if flags["esp_team_check"] and pl.Team == lp.Team then hideAll(); continue end
        if rootPos and (hrp.Position - rootPos).Magnitude > (flags["esp_max_dist"] or 800) then hideAll(); continue end

        local sp, onScreen = cam:WorldToViewportPoint(hrp.Position)
        if not onScreen then hideAll(); continue end
        if not esp_wall_check(c, hrp) then hideAll(); continue end

        local topSP = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local botSP = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.8, 0))
        local boxH = math.abs(botSP.Y - topSP.Y)
        local boxW = boxH * 0.55
        local bx, by = sp.X - boxW / 2, topSP.Y
        local style = flags["box_style"] or "Corner Box"

        if flags["box_esp"] then
            if style == "Full Box" then
                for _, l in ipairs(d.corners) do l.Visible = false end
                d.box.Size = Vector2.new(boxW, boxH); d.box.Position = Vector2.new(bx, by)
                d.box.Color = state.colors.box; d.box.Visible = true
            elseif style == "Corner Box" then
                d.box.Visible = false
                local cL = math.min(boxW, boxH) * 0.28
                local co = d.corners
                co[1].From, co[1].To = Vector2.new(bx, by), Vector2.new(bx + cL, by)
                co[2].From, co[2].To = Vector2.new(bx, by), Vector2.new(bx, by + cL)
                co[3].From, co[3].To = Vector2.new(bx + boxW, by), Vector2.new(bx + boxW - cL, by)
                co[4].From, co[4].To = Vector2.new(bx + boxW, by), Vector2.new(bx + boxW, by + cL)
                co[5].From, co[5].To = Vector2.new(bx, by + boxH), Vector2.new(bx + cL, by + boxH)
                co[6].From, co[6].To = Vector2.new(bx, by + boxH), Vector2.new(bx, by + boxH - cL)
                co[7].From, co[7].To = Vector2.new(bx + boxW, by + boxH), Vector2.new(bx + boxW - cL, by + boxH)
                co[8].From, co[8].To = Vector2.new(bx + boxW, by + boxH), Vector2.new(bx + boxW, by + boxH - cL)
                for _, l in ipairs(co) do l.Color = state.colors.box; l.Visible = true end
            else
                d.box.Visible = false
                for _, l in ipairs(d.corners) do l.Visible = false end
            end
        else
            d.box.Visible = false
            for _, l in ipairs(d.corners) do l.Visible = false end
        end

        if flags["box_esp"] and flags["box_fill"] then
            d.boxFill.Size = Vector2.new(boxW, boxH); d.boxFill.Position = Vector2.new(bx, by)
            d.boxFill.Color = state.colors.boxFill; d.boxFill.Transparency = state.colors.boxFillTr
            d.boxFill.Visible = true
        else 
            d.boxFill.Visible = false 
        end

        local yOffset = by - 14
        if flags["name_esp"] then
            d.nameText.Text = pl.Name
            d.nameText.Position = Vector2.new(sp.X, yOffset)
            d.nameText.Color = state.colors.name
            d.nameText.Visible = true
            yOffset = yOffset - 13
        else 
            d.nameText.Visible = false 
        end

        if flags["weapon_esp"] then
            local tool = pl:FindFirstChild("NRPBS") and pl.NRPBS:FindFirstChild("EquippedTool")
            if tool then
                d.weaponText.Text = tostring(tool.Value)
                d.weaponText.Position = Vector2.new(sp.X, yOffset)
                d.weaponText.Color = state.colors.weapon
                d.weaponText.Visible = true
                yOffset = yOffset - 13
            else 
                d.weaponText.Visible = false 
            end
        else 
            d.weaponText.Visible = false 
        end

        if flags["dist_esp"] and rootPos then
            local dist = math.round((hrp.Position - rootPos).Magnitude)
            d.distText.Text = dist .. "m"
            d.distText.Position = Vector2.new(sp.X, by + boxH + 3)
            d.distText.Color = state.colors.dist
            d.distText.Visible = true
        else 
            d.distText.Visible = false 
        end

        if flags["hp_esp"] then
            local pct = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
            local hbX, barH = bx - 6, boxH * pct
            d.hpBG.Size = Vector2.new(4, boxH); d.hpBG.Position = Vector2.new(hbX, by); d.hpBG.Visible = true
            d.hpBar.Size = Vector2.new(4, barH); d.hpBar.Position = Vector2.new(hbX, by + boxH - barH)
            d.hpBar.Color = flags["hp_color_gradient"] and Color3.fromRGB(math.round((1 - pct) * 255), math.round(pct * 255), 0) or Color3.fromRGB(0, 255, 0)
            d.hpBar.Visible = true
            if flags["hp_text"] then
                d.hpText.Text = tostring(math.floor(h.Health))
                d.hpText.Position = Vector2.new(hbX - 10, by + boxH - barH - 6)
                d.hpText.Visible = true
            else 
                d.hpText.Visible = false 
            end
        else
            d.hpBG.Visible = false; d.hpBar.Visible = false; d.hpText.Visible = false
        end

        if flags["tracers_on"] then
            local origin = flags["tracer_origin"] or "Bottom"
            local fromX = origin == "Mouse" and mp.X or vp.X / 2
            local fromY = (origin == "Top" and 0) or (origin == "Center" and vp.Y / 2) or (origin == "Mouse" and mp.Y) or vp.Y
            d.tracer.From = Vector2.new(fromX, fromY); d.tracer.To = Vector2.new(sp.X, sp.Y)
            d.tracer.Color = state.colors.tracer; d.tracer.Thickness = state.colors.tracerThick; d.tracer.Visible = true
        else 
            d.tracer.Visible = false 
        end

        if flags["snap_line"] and currentTarget == pl then
            d.snapLine.From = Vector2.new(vp.X / 2, vp.Y / 2); d.snapLine.To = Vector2.new(sp.X, sp.Y)
            d.snapLine.Color = state.colors.snapLine; d.snapLine.Thickness = state.colors.snapThick; d.snapLine.Visible = true
        else 
            d.snapLine.Visible = false 
        end

        if flags["skel_esp"] then
            for i, pair in ipairs(skel_pairs) do
                local p1 = c:FindFirstChild(pair[1]); local p2 = c:FindFirstChild(pair[2])
                local ln = d.skeleton[i]
                if p1 and p2 then
                    local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                    local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                    if on1 and on2 then
                        ln.From = Vector2.new(s1.X, s1.Y); ln.To = Vector2.new(s2.X, s2.Y)
                        ln.Color = state.colors.skel; ln.Visible = true
                    else 
                        ln.Visible = false 
                    end
                else 
                    ln.Visible = false 
                end
            end
        else
            for _, l in ipairs(d.skeleton) do l.Visible = false end
        end
    end

    if pickupESPEnabled.ammo or pickupESPEnabled.hp then
        refreshPickupESP()
        for obj, d in pairs(pickupESPObjects) do
            if not obj or not obj.Parent then continue end
            local isAmmoObj = obj.Name == "DeadAmmo"
            local show = (isAmmoObj and pickupESPEnabled.ammo) or (not isAmmoObj and pickupESPEnabled.hp)
            if not show then 
                d.text.Visible = false; d.box.Visible = false
                continue 
            end
            local rootPart = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if not rootPart then continue end
            local sp, onScreen = cam:WorldToViewportPoint(rootPart.Position)
            if not onScreen then 
                d.text.Visible = false; d.box.Visible = false
                continue 
            end
            local col = state.colors.box
            local bw, bh = 10, 10
            d.box.Size = Vector2.new(bw, bh)
            d.box.Position = Vector2.new(sp.X - bw/2, sp.Y - bh/2)
            d.box.Color = col
            d.box.Visible = true
            d.text.Position = Vector2.new(sp.X, sp.Y - 20)
            d.text.Color = col
            d.text.Visible = true
        end
    end
end)

connect(run.Heartbeat, function()
    if flags["killfeed_on"] then
        pcall(function()
            local feed = ws:FindFirstChild("KillFeed")
            if feed then
                for _, child in ipairs(feed:GetChildren()) do
                    if child:FindFirstChild("Assist") then child.Assist.Value = flags["killfeed_assist"] or "" end
                    if child:FindFirstChild("Killer") then child.Killer.Value = flags["killfeed_killer"] or "" end
                    if child:FindFirstChild("Victim") then child.Victim.Value = flags["killfeed_victim"] or "" end
                end
            end
        end)
    end

    if flags["auto_deploy"] and not is_spawned(lp) then
        pcall(function() rs.Events.SpawnMe:FireServer() end)
        task.wait(1) 
    end
end)

connect(uis.JumpRequest, function()
    if flags["inf_jump"] then 
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end 
    end
end)

connect(lp.Idled, function()
    if flags["anti_afk"] then
        if VIM then 
            VIM:SendKeyEvent(true, Enum.KeyCode.ButtonB, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.ButtonB, false, game) 
        end
    end
end)

connect(lp.CharacterAdded, function(char)
    myOrigSizes = {} 
    local h = char:WaitForChild("Humanoid")
    task.wait(0.15)
    if flags["speed_on"] then apply_walkspeed(true, flags["walkspeed"] or 50) end
    if flags["jump_on"] then apply_jumppower(true, flags["jump_power"] or 50) end
    pcall(function() cam.FieldOfView = flags["cam_fov"] or defaultFOV end)
    pcall(function() lp.Settings.FOV.Value = flags["cam_fov"] or defaultFOV end)
    if flags["fly_on"] then h.PlatformStand = true end
    task.wait(0.5)
    if flags["chams_on"] then reapplyAllChams() end
    if flags["hitbox_on"] then updateAllHitboxes() end
    if flags["lx_skin"] and flags["lx_skin"] ~= "" then
        pcall(function() firesignal(rs.Events.CharacterLoaded.OnClientEvent, char, flags["lx_skin"]) end)
    end
end)

connect(plrs.PlayerAdded, function(pl)
    connect(pl.CharacterAdded, function(char)
        task.wait(1)
        if flags["highlight_enemies"] and not char:FindFirstChild("LunarHL") then
            local hh = Instance.new("Highlight")
            hh.Name = "LunarHL"; hh.FillColor = state.colors.hlEnemy
            hh.OutlineColor = rgb(255, 255, 255); hh.FillTransparency = 0.5; hh.Parent = char
        end
        task.wait(0.5)
        if flags["chams_on"] then applyChams(pl) end
        if flags["hitbox_on"] then expandHitbox(pl) end
    end)
    connect(pl.CharacterRemoving, function() hitboxOrigSizes[pl] = nil end)
end)

SaveManager:SetLibrary(library)
SaveManager:SetFolder('LunarX/arsenal')
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind', 'search_melee', 'search_skin', 'search_announcer', 'search_card', 'fav_search', 'config_name_text_box', 'config_name_list' })
SaveManager:BuildConfigSection(settingsTab)

ThemeManager:SetLibrary(library)
ThemeManager:SetFolder('LunarX')
ThemeManager:ApplyToTab(settingsTab)

task.spawn(function()
    task.wait(1)
    if isfile("LunarX/arsenal/silentload.cfg") then
        library.Toggle()
        flags["silent_load"] = true
    end
    if isfile("LunarX/arsenal/autoexec.cfg") then
        flags["auto_exec_on_join"] = true
        if queue_on_teleport then
            queue_on_teleport(s_url)
        end
    end
    SaveManager:LoadAutoloadConfig()
    applyLoadedSkins()
end)
