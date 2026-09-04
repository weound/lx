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
    (funcName == "setclipboard" and setclipboard) or 
    (funcName == "Drawing.new" and Drawing and Drawing.new) or 
    (funcName == "loadstring" and loadstring) or 
    (funcName == "hookmetamethod" and hookmetamethod) or 
    (funcName == "newcclosure" and newcclosure) or 
    (funcName == "checkcaller" and checkcaller)
    
    if not f or type(f) ~= "function" then
        warn("your executor does not support '" .. funcName .. "', bye")
        return false
    end
    return true
end

local funcs = {"getgenv", "hookmetamethod", "newcclosure", "checkcaller", "loadstring", "gethui", "Drawing.new", "setclipboard", "mouse1press", "mouse1release"}
for _, f in ipairs(funcs) do
    if not check(f) then return end
end

if not game.HttpGet then
    warn("your executor does not support 'HttpGet', bye")
    return
end

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Toggles = getgenv().Toggles or {}
local Options = getgenv().Options or {}

local flgs = setmetatable({}, {
    __index = function(t, k)
        if Toggles[k] ~= nil then return Toggles[k].Value end
        if Options[k] ~= nil then return Options[k].Value end
        return nil
    end
})

local plrs = game:GetService("Players")
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ws = game:GetService("Workspace")
local light = game:GetService("Lighting")
local rs = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local debris = game:GetService("Debris")
local http = game:GetService("HttpService")

local lp = plrs.LocalPlayer
local pgui = lp:FindFirstChild("PlayerGui")
local cam = ws.CurrentCamera
local mouse = lp:GetMouse()

local wpnmng = require(rs.Common.Managers.WeaponManager)
local wpnpkts = require(rs.Common.Packets.WeaponPackets)
local mdlmng = require(rs.Common.Managers.ModelsManager)
local qstpkts = require(rs.Common.Packets.QuestPackets)
local lvlrewpkts = require(rs.Common.Packets.LevelRewardPackets)
local dataclnt = require(lp.PlayerScripts.Start.Backend.DataClient)
local mngmpkts = require(rs.Common.Packets.MainGamePackets)
local wpnclnt = require(lp.PlayerScripts.Start.Game.WeaponClient)
local vwmdlclnt = require(lp.PlayerScripts.Start.Game.ViewmodelClient)
local char_mngr = require(rs.Common.Managers.CharacterManager)
local killeffmng = require(rs.Common.Managers.KillEffectManager)
local util_mngrs_fld = rs.Common.Managers.UtilityManagers
local tblmngr = require(util_mngrs_fld:WaitForChild("TableManager"))
local battlepasspkts = require(rs.Common.Packets.BattlepassPackets)
local killeffpkts = require(rs.Common.Packets.Replication.KillEffectPackets)
local bytenetrel = rs:WaitForChild('ByteNetReliable')

local function getchar() return lp.Character end
local function gethum() local c = getchar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getroot() local c = getchar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local _wpns = wpnmng.getWeapons()
for name, data in pairs(_wpns) do
    data._firerate = data.firerate
    data._damage = data.damage
    data._reloadTime = data.reloadTime
    data._magazine = data.magazine
end

local orig_getwpnmdl = mdlmng.getWeaponModel
local orig_getknfmdl = mdlmng.getKnifeModel
local orig_getwpnanim = mdlmng.getWeaponAnimation
local orig_getknfanim = mdlmng.getKnifeAnimation
local orig_getwpnname = char_mngr.getHoldingWeaponName
local orig_getfiresnd = wpnmng.getFireSound
local orig_vmshoot = vwmdlclnt.shoot
local orig_scope = wpnclnt.scope
local orig_lazymod = tblmngr.lazyLoadModule

mdlmng.getWeaponModel = function(name)
    if type(name) == "buffer" then name = tostring(name) end
    if type(name) ~= "string" then return nil end
    local cw = lp.Character and lp.Character:GetAttribute("currentWeapon")
    if cw == "Primary" and flgs["ot_primary_skin"] ~= "" and flgs["ot_primary_skin"] ~= nil then
        local m = orig_getwpnmdl(flgs["ot_primary_skin"])
        if m then return m end
    elseif cw == "Secondary" and flgs["ot_secondary_skin"] ~= "" and flgs["ot_secondary_skin"] ~= nil then
        local m = orig_getwpnmdl(flgs["ot_secondary_skin"])
        if m then return m end
    end
    return orig_getwpnmdl(name)
end

mdlmng.getKnifeModel = function(name)
    if type(name) == "buffer" then name = tostring(name) end
    if type(name) ~= "string" then return nil end
    if flgs["ot_knife_skin"] ~= "" and flgs["ot_knife_skin"] ~= nil then
        local m = orig_getknfmdl(flgs["ot_knife_skin"])
        if m then return m end
    end
    return orig_getknfmdl(name)
end

mdlmng.getWeaponAnimation = function(name)
    if type(name) ~= "string" then return nil end
    local cw = lp.Character and lp.Character:GetAttribute("currentWeapon")
    if cw == "Primary" and flgs["ot_primary_skin"] ~= "" and flgs["ot_primary_skin"] ~= nil then
        local a = orig_getwpnanim(flgs["ot_primary_skin"])
        if a then return a end
    elseif cw == "Secondary" and flgs["ot_secondary_skin"] ~= "" and flgs["ot_secondary_skin"] ~= nil then
        local a = orig_getwpnanim(flgs["ot_secondary_skin"])
        if a then return a end
    end
    return orig_getwpnanim(name)
end

mdlmng.getKnifeAnimation = function(name)
    if type(name) ~= "string" then return nil end
    if flgs["ot_knife_skin"] ~= "" and flgs["ot_knife_skin"] ~= nil then
        local a = orig_getknfanim(flgs["ot_knife_skin"])
        if a then return a end
    end
    return orig_getknfanim(name)
end

char_mngr.getHoldingWeaponName = function(char)
    if char == lp.Character then
        local cw = char:GetAttribute("currentWeapon")
        if cw == "Primary" and flgs["ot_primary_skin"] ~= "" and flgs["ot_primary_skin"] ~= nil then
            return flgs["ot_primary_skin"]
        elseif cw == "Secondary" and flgs["ot_secondary_skin"] ~= "" and flgs["ot_secondary_skin"] ~= nil then
            return flgs["ot_secondary_skin"]
        elseif cw == "Knife" and flgs["ot_knife_skin"] ~= "" and flgs["ot_knife_skin"] ~= nil then
            return flgs["ot_knife_skin"]
        end
    end
    return orig_getwpnname(char)
end

tblmngr.lazyLoadModule = function(name, dict, parent)
    if type(name) == "string" and string.sub(name, 1, 1) == "_" then
        if flgs["ot_kill_effect"] ~= "" and flgs["ot_kill_effect"] ~= nil then
            name = "_" .. flgs["ot_kill_effect"]
        end
    end
    return orig_lazymod(name, dict, parent)
end

local hitsnd_prsts = { cod = 77082587278347, ["bubble pop"] = 119697580657161, ["jet set"] = 97113622160405, osu = 123941247147792, whip = 90487264912905, hint = 134763632925481, ["bubble pop 2"] = 104824514322839, ["coin flip"] = 99636386529233, custom = 0 }
local pri_sht_prsts = { glock = 6581933860, tank = 138839154527248, ["tf2 shit"] = 124218436566507, custom = 0 }
local sec_sht_prsts = { ["desert eagle"] = 82286818216627, m1911 = 1136243671, custom = 0 }

wpnmng.getFireSound = function(name, ...)
    local isPistol = false
    if type(name) == "string" then
        local wd = wpnmng.getWeaponData(name)
        if wd and wd.isPistol then isPistol = true end
    end
    
    if isPistol and flgs["custom_sec_shoot_sounds"] then
        local id = 0
        local prst = flgs["sec_shoot_sound_preset"]
        if prst == "custom" then
            local txt = flgs["custom_sec_shoot_sound_id"] or ""
            local num = string.match(txt, "%d+")
            if num then id = tonumber(num) end
        else
            id = sec_sht_prsts[prst] or 0
        end
        if id > 0 then return id end
    elseif not isPistol and flgs["custom_pri_shoot_sounds"] then
        local id = 0
        local prst = flgs["pri_shoot_sound_preset"]
        if prst == "custom" then
            local txt = flgs["custom_pri_shoot_sound_id"] or ""
            local num = string.match(txt, "%d+")
            if num then id = tonumber(num) end
        else
            id = pri_sht_prsts[prst] or 0
        end
        if id > 0 then return id end
    end
    return orig_getfiresnd(name, ...)
end

local box_col = rgb(100, 255, 255)
local trac_col = rgb(100, 100, 255)
local skel_col = rgb(255, 100, 255)
local name_col = rgb(255, 255, 255)
local dist_col = rgb(180, 180, 180)
local chams_col = rgb(170, 85, 235)
local xhair_col = rgb(255, 255, 255)
local fov_col = rgb(100, 100, 255)
local aura_vis_col = rgb(255, 255, 0)
local dang_col = rgb(255, 0, 0)

local wpn_chams_col = rgb(255, 0, 0)
local wpn_chams_trans = 0
local arm_chams_col = rgb(0, 255, 0)
local arm_chams_trans = 0

local ckf_txt = ""

local st = {
    aim_target_part = nil, 
    aim_target_player = nil,
    silent_target_part = nil,
    silent_target_player = nil,
    lastClickTime = 0
}

local keyb = { aim = false, trigger = false }
local ws_en = false
local jp_en = false
local currtarg = nil
local cons = {}
local function connct(sig, cb) 
    local c = sig:Connect(cb)
    table.insert(cons, c)
    return c 
end

local function disc_all()
    for _, c in ipairs(cons) do pcall(function() c:Disconnect() end) end
    cons = {}
end

local function newdraw(t, props)
    local d, err = Drawing.new(t)
    if not d then return nil end
    for k, v in pairs(props) do
        pcall(function() d[k] = v end)
    end
    return d
end

local function apply_wpn_mods()
    for name, data in pairs(_wpns) do
        data.firerate = flgs["no_shoot_delay"] and 9999 or data._firerate
        data.damage = data._damage
        data.reloadTime = flgs["instant_reload"] and 0 or data._reloadTime
        data.magazine = flgs["inf_ammo"] and 999 or data._magazine
    end
    wpnmng.Constants.DEFAULT_FIRERATE = flgs["no_shoot_delay"] and 9999 or 2
    wpnmng.Constants.DEFAULT_PISTOL_FIRERATE = flgs["no_shoot_delay"] and 9999 or 4
    wpnmng.Constants.DEFAULT_DAMAGE = 100
    wpnmng.Constants.DEFAULT_PISTOL_DAMAGE = 50
    wpnmng.Constants.DEFAULT_RELOAD_TIME = flgs["instant_reload"] and 0 or 0.75
    wpnmng.Constants.DEFAULT_PISTOL_RELOAD_TIME = flgs["instant_reload"] and 0 or 0.5
    wpnmng.Constants.DEFAULT_MAGAZINE = flgs["inf_ammo"] and 999 or 1
end

mngmpkts.hitResult.listen(function(data)
    task.spawn(function()
        if flgs["hit_notifs"] then
            setthreadidentity(8)
            local tname = (typeof(data.target) == "Instance" and data.target.Name) or "Enemy"
            local hpart = (data.bonus and data.bonus.headshot) and "head" or "body"
            local hplost = data.killed and 100 or math.random(10, 50)
            local msg = flgs["hit_notif_msg"] or "hit (target) for (hp) in the (part)!"
            msg = string.gsub(msg, "%(target%)", tname)
            msg = string.gsub(msg, "%(part%)", hpart)
            msg = string.gsub(msg, "%(hp%)", tostring(hplost))
            
            local ok, err = pcall(function() Library:Notify(msg, 3) end)
            if not ok then
                warn("fatal err: " .. tostring(err))
            end
        end
    end)
    
    task.spawn(function()
        if flgs["custom_kill_sounds"] and data.killed then
            local id = 0
            local prst = flgs["kill_sound_preset"]
            if prst == "custom" then
                local txt = flgs["custom_kill_sound_id"] or ""
                local num = string.match(txt, "%d+")
                if num then id = tonumber(num) end
            else
                id = hitsnd_prsts[prst] or 0
            end
            if id > 0 then
                local s = Instance.new("Sound")
                s.SoundId = "rbxassetid://" .. id
                s.Volume = 1
                s.Parent = ws
                s:Play()
                debris:AddItem(s, 5)
            end
        end
    end)
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if key == "WalkSpeed" and ws_en and self:IsA("Humanoid") then return 16 end
        if key == "JumpPower" and jp_en and self:IsA("Humanoid") then return 50 end
    end
    return oldIndex(self, key)
end))

local oldnm
oldnm = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
    local m = getnamecallmethod()
    if m == 'FireServer' and self == bytenetrel and currtarg then
        local args = {...}
        if typeof(args[2]) == 'table' and typeof(args[2][1]) == 'Instance' then
            local hitchance = flgs["silent_hitchance"] or 100
            if math.random(1, 100) <= hitchance then
                args[2][1] = currtarg
                args[2][2] = currtarg.Head
            end
        end
    elseif m == "FindFirstChild" and flgs["ff_bypass"] then
        local args = {...}
        if args[1] == "ForceField" then
            return nil
        end
    end
    return oldnm(self, ...)
end))

local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
    if not checkcaller() and key == "AssemblyLinearVelocity" and typeof(value) == "Vector3" then
        if self:IsA("BasePart") and self.Name == "HumanoidRootPart" then
            local char = self:FindFirstAncestorOfClass("Model")
            if char and char == lp.Character then
                if ws_en and value.X == 0 and value.Z == 0 then
                    return
                end
                if jp_en and value.Y < -40 then
                    return
                end
            end
        end
    end
    return oldNewIndex(self, key, value)
end))

local function apply_ws(state, speed)
    ws_en = state
    local hum = gethum()
    if hum then hum.WalkSpeed = state and (speed or 50) or 16 end
end

local function apply_jp(state, power)
    jp_en = state
    local hum = gethum()
    if hum then hum.JumpPower = state and (power or 50) or 50 end
end

local killaura_on = false
local function run_killaura()
    while killaura_on do
        local root = getroot()
        if root then
            for _, char in ipairs(get_targs()) do
                local hum = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")
                if hum and head and hum.Health > 0 then
                    local dist = (head.Position - root.Position).Magnitude
                    if dist <= (flgs["kill_aura_range"] or 50) then
                        currtarg = char
                        pcall(function() wpnclnt.fire() end)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end
local function set_killaura(active)
    killaura_on = active
    if active then task.spawn(run_killaura) end
end

local hitbox_pts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
local function expand_hb(char)
    local sz = flgs["hitbox_size"] or 8
    for _, name in ipairs(hitbox_pts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            pcall(function() part.Size = Vector3.new(sz, sz, sz) end)
        end
    end
end

function get_targs()
    local targs = {}
    for _, plr in ipairs(plrs:GetPlayers()) do
        if plr ~= lp and plr.Character then
            table.insert(targs, plr.Character)
        end
    end
    for _, obj in ipairs(ws:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not plrs:GetPlayerFromCharacter(obj) then
            table.insert(targs, obj)
        end
    end
    return targs
end

local function get_aimtarg()
    local mp = uis:GetMouseLocation()
    local fov = flgs["aim_radius"] or 150
    local maxDist = flgs["aim_max_dist"] or 500
    local root = getroot()
    local best, bestScore = nil, math.huge

    for _, char in ipairs(get_targs()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local part = char:FindFirstChild(flgs["aim_part"] or "Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (h and part and hrp and h.Health > 0) then continue end
        
        if root and (hrp.Position - root.Position).Magnitude > maxDist then continue end

        if flgs["aim_wall_check"] then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {getchar(), char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = ws:Raycast(cam.CFrame.Position, (part.Position - cam.CFrame.Position), rp)
            if hit and not hit.Instance:IsDescendantOf(char) then continue end
        end

        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        
        local screenDist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
        if screenDist > fov then continue end

        if screenDist < bestScore then best = char; bestScore = screenDist end
    end
    return best
end

local function get_siltarg()
    local mp = uis:GetMouseLocation()
    local fov = flgs["silent_radius"] or 150
    local maxDist = flgs["aim_max_dist"] or 500
    local root = getroot()
    local best, bestScore = nil, math.huge

    for _, char in ipairs(get_targs()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local part = char:FindFirstChild(flgs["aim_part"] or "Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (h and part and hrp and h.Health > 0) then continue end
        
        local dist3D = root and (hrp.Position - root.Position).Magnitude or 0
        if not flgs["inf_distance"] and dist3D > maxDist then continue end

        if flgs["silent_wall_check"] and not flgs["wallbang"] then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {getchar(), char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = ws:Raycast(cam.CFrame.Position, (part.Position - cam.CFrame.Position), rp)
            if hit and not hit.Instance:IsDescendantOf(char) then continue end
        end

        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
        if not flgs["inf_distance"] and not onScreen then continue end
        
        local screenDist = onScreen and (Vector2.new(sp.X, sp.Y) - mp).Magnitude or math.huge
        if not flgs["inf_distance"] and screenDist > fov then continue end

        local score = flgs["inf_distance"] and dist3D or screenDist

        if score < bestScore then best = char; bestScore = score end
    end
    return best
end

local esp_objs = {}
local dang_inds = {}
local skel_prs = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"RightLowerLeg", "RightFoot"}
}
local skel_prs_r6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function build_esp(char)
    if esp_objs[char] then return end
    local corners = {}
    for i = 1, 8 do corners[i] = newdraw("Line", {Thickness = 2, Visible = false, Color = box_col}) end
    local skeleton = {}
    for i = 1, #skel_prs do skeleton[i] = newdraw("Line", {Thickness = 1, Visible = false, Color = skel_col}) end
    
    esp_objs[char] = {
        box = newdraw("Square", {Thickness = 1, Filled = false, Visible = false, Color = box_col}),
        corners = corners,
        skeleton = skeleton,
        nameText = newdraw("Text", {Size = 13, Center = true, Outline = true, Visible = false, Color = name_col, Font = 2}),
        distText = newdraw("Text", {Size = 11, Center = true, Outline = true, Visible = false, Color = dist_col, Font = 2}),
        hpBG = newdraw("Square", {Filled = true, Visible = false, Color = rgb(0, 0, 0)}),
        hpBar = newdraw("Square", {Filled = true, Visible = false, Color = rgb(0, 255, 0)}),
        tracer = newdraw("Line", {Thickness = 1, Visible = false, Color = trac_col})
    }
end

local function destroy_esp(char)
    local d = esp_objs[char]
    if not d then return end
    for _, v in pairs(d.corners) do pcall(function() v:Remove() end) end
    for _, v in pairs(d.skeleton) do pcall(function() v:Remove() end) end
    for k, v in pairs(d) do
        if k ~= "corners" and k ~= "skeleton" then pcall(function() v:Remove() end) end
    end
    esp_objs[char] = nil
end

local function rng()
   return math.random(1, 967676767)
end

local function apply_chams(char)
    if not char or not char.Parent then return end
    if not flgs["chams_on"] then
        if char:FindFirstChild("oikwerwe") then char.oikwerwe:Destroy() end
        return
    end
    
    if not char:FindFirstChild("oikwerwe") then
        local h = Instance.new("Highlight")
        h.Name = "oikwerwe"
        h.FillColor = chams_col
        h.OutlineColor = Color3.new(1, 1, 1)
        h.Parent = char
    end
    
    local c = char.oikwerwe
    c.FillColor = chams_col
    c.FillTransparency = 0.5
    c.OutlineTransparency = 0
end

local function apply_vm_chams()
    local vm = cam:FindFirstChild("Viewmodel")
    if not vm then return end
    
    local function apply(part, color, material, trans, enabled)
        if not part or not part:IsA("BasePart") then return end
        if enabled then
            if not part:GetAttribute("LunarVMOrig") then
                part:SetAttribute("LunarVMOrig", true)
                part:SetAttribute("OrigMat", part.Material)
                part:SetAttribute("OrigColor", part.Color)
                part:SetAttribute("OrigTrans", part.Transparency)
            end
            part.Color = color
            part.Material = material
            part.Transparency = trans
        else
            if part:GetAttribute("LunarVMOrig") then
                part.Material = part:GetAttribute("OrigMat")
                part.Color = part:GetAttribute("OrigColor")
                part.Transparency = part:GetAttribute("OrigTrans")
                part:SetAttribute("LunarVMOrig", nil)
            end
        end
    end

    for _, child in ipairs(vm:GetChildren()) do
        if string.find(child.Name, "Arm") then
            apply(child, arm_chams_col, Enum.Material[flgs["arm_chams_mat"] or "Neon"], arm_chams_trans, flgs["arm_chams_on"])
            for _, desc in ipairs(child:GetDescendants()) do
                apply(desc, arm_chams_col, Enum.Material[flgs["arm_chams_mat"] or "Neon"], arm_chams_trans, flgs["arm_chams_on"])
            end
        elseif child.Name == "Weapon" then
            apply(child, wpn_chams_col, Enum.Material[flgs["wpn_chams_mat"] or "Neon"], wpn_chams_trans, flgs["wpn_chams_on"])
            for _, desc in ipairs(child:GetDescendants()) do
                apply(desc, wpn_chams_col, Enum.Material[flgs["wpn_chams_mat"] or "Neon"], wpn_chams_trans, flgs["wpn_chams_on"])
            end
        end
    end
end

local pri_skins, sec_skins, knf_skins = {}, {}, {}
for k, v in pairs(wpnmng.getWeapons()) do
    if v.isPistol then
        table.insert(sec_skins, k)
    else
        table.insert(pri_skins, k)
    end
end
for k, v in pairs(wpnmng.getKnives()) do table.insert(knf_skins, k) end
table.sort(pri_skins)
table.sort(sec_skins)
table.sort(knf_skins)

local killeff_list = {}
for k, v in pairs(killeffmng.getKillEffects()) do table.insert(killeff_list, k) end
table.sort(killeff_list)

local radar_gui = Instance.new("ScreenGui")
radar_gui.Name = tostring(rng())
radar_gui.Parent = gethui()
radar_gui.Enabled = false

local radar_frm = Instance.new("Frame", radar_gui)
radar_frm.Size = UDim2.new(0, 150, 0, 150)
radar_frm.Position = UDim2.new(0, 15, 0, 15)
radar_frm.BackgroundColor3 = Color3.new(0, 0, 0)
radar_frm.BackgroundTransparency = 0.5
radar_frm.BorderSizePixel = 0
Instance.new("UICorner", radar_frm).CornerRadius = UDim.new(1, 0)

local radar_cntr = Instance.new("Frame", radar_frm)
radar_cntr.Size = UDim2.new(0, 4, 0, 4)
radar_cntr.Position = UDim2.new(0.5, -2, 0.5, -2)
radar_cntr.BackgroundColor3 = Color3.new(1, 1, 1)
radar_cntr.BorderSizePixel = 0
Instance.new("UICorner", radar_cntr).CornerRadius = UDim.new(1, 0)

local radar_dots = {}
local radar_dot_col = rgb(255, 0, 0)

local aura_pt = Instance.new("Part")
aura_pt.Name = tostring(rng())
aura_pt.Anchored = true
aura_pt.CanCollide = false
aura_pt.Transparency = 0.5
aura_pt.Material = Enum.Material.Neon
aura_pt.Size = Vector3.new(1, 1, 1)
aura_pt.Parent = nil

local aura_msh = Instance.new("SpecialMesh", aura_pt)
aura_msh.MeshType = Enum.MeshType.Brick

local function set_aura_shp(shape)
    aura_msh.MeshId = ""
    if shape == "Circle" then
        aura_msh.MeshType = Enum.MeshType.Sphere
    elseif shape == "Cube" then
        aura_msh.MeshType = Enum.MeshType.Brick
    elseif shape == "Cylinder" then
        aura_msh.MeshType = Enum.MeshType.Cylinder
    elseif shape == "Diamond" then
        aura_msh.MeshType = Enum.MeshType.FileMesh
        aura_msh.MeshId = "rbxassetid://9756362"
    end
end

local Window = Library:CreateWindow({
    Title = "lunar x | one tap",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Aimbot = Window:AddTab('Aimbot'),
    Visuals = Window:AddTab('Visuals'),
    Weapon = Window:AddTab('Weapon'),
    Skins = Window:AddTab('Skins'),
    Misc = Window:AddTab('Misc'),
    Settings = Window:AddTab('Settings'),
}

local aim_sec = Tabs.Aimbot:AddLeftGroupbox('Aimbot')
local sil_sec = Tabs.Aimbot:AddLeftGroupbox('Silent Aim')
local aim_cfg = Tabs.Aimbot:AddLeftGroupbox('Config')
local fov_sec = Tabs.Aimbot:AddRightGroupbox('FOV Circle')
local aura_sec = Tabs.Aimbot:AddRightGroupbox('Aura')

aim_sec:AddToggle('aim_on', { Text = 'Aimbot', Default = false })
aim_sec:AddLabel('Aimbot Bind'):AddKeyPicker('aim_key', { Default = 'E', Mode = 'Hold', Text = 'Aimbot', Callback = function(v) keyb.aim = v end })
aim_sec:AddToggle('aim_wall_check', { Text = 'Wall Check', Default = true })
aim_sec:AddToggle('triggerbot', { Text = 'Trigger Bot', Default = false })
aim_sec:AddLabel('Trigger Bind'):AddKeyPicker('trigger_key', { Default = 'Q', Mode = 'Hold', Text = 'Trigger Bot', Callback = function(v) keyb.trigger = v end })
aim_sec:AddToggle('auto_shoott', { Text = 'Auto Shoot', Default = false })
aim_sec:AddSlider('auto_shoot_delay', { Text = 'Auto Shoot Delay', Default = 0.05, Min = 0.01, Max = 1, Rounding = 2, Suffix = 's' })

sil_sec:AddToggle('silent_aim', { Text = 'Silent Aim', Default = false })
sil_sec:AddSlider('silent_hitchance', { Text = 'Hit Chance', Default = 100, Min = 1, Max = 100, Rounding = 0, Suffix = '%' })
sil_sec:AddToggle('silent_wall_check', { Text = 'Wall Check', Default = true })
sil_sec:AddToggle('wallbang', { Text = 'Wallbang', Default = false })
sil_sec:AddToggle('inf_distance', { Text = 'Inf Distance', Default = false })
sil_sec:AddSlider('silent_radius', { Text = 'Silent Aim Radius', Default = 150, Min = 10, Max = 1000, Rounding = 0, Suffix = 'px' })

aim_cfg:AddDropdown('aim_part', { Text = 'Target Part', Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'}, Default = 1 })
aim_cfg:AddSlider('aim_smooth', { Text = 'Smoothness', Default = 0.15, Min = 0.01, Max = 1, Rounding = 2, Suffix = 'x' })
aim_cfg:AddSlider('aim_max_dist', { Text = 'Max Distance', Default = 1000, Min = 50, Max = 5000, Rounding = 0, Suffix = ' st' })

local fov_circle = newdraw("Circle", { Thickness = 1, Filled = false, Visible = false, Color = fov_col, Radius = 150 })
fov_sec:AddToggle('fov_visible', { Text = 'Visible', Default = false }):OnChanged(function(v) if fov_circle then fov_circle.Visible = v end end)
fov_sec:AddLabel('FOV Color'):AddColorPicker('fov_color', { Default = fov_col, Transparency = 0, Callback = function(c, t)
    fov_col = c
    if fov_circle then fov_circle.Color = c end
end})
fov_sec:AddSlider('aim_radius', { Text = 'Radius', Default = 150, Min = 10, Max = 1000, Rounding = 0, Suffix = 'px' }):OnChanged(function(v) if fov_circle then fov_circle.Radius = v end end)

aura_sec:AddToggle('kill_aura', { Text = 'Kill Aura', Default = false }):OnChanged(set_killaura)
aura_sec:AddSlider('kill_aura_range', { Text = 'Kill Aura Range', Default = 50, Min = 10, Max = 500, Rounding = 0, Suffix = ' st' })
aura_sec:AddToggle('hitbox_on', { Text = 'Hitbox Expander', Default = false })
aura_sec:AddSlider('hitbox_size', { Text = 'Hitbox Size', Default = 8, Min = 1, Max = 60, Rounding = 1, Suffix = ' st' })

local esp_sec = Tabs.Visuals:AddLeftGroupbox('Player ESP')
local trac_sec = Tabs.Visuals:AddLeftGroupbox('Tracer Config')
local chams_sec = Tabs.Visuals:AddLeftGroupbox('Chams')
local fx_sec = Tabs.Visuals:AddLeftGroupbox('Effects')
local env_sec = Tabs.Visuals:AddRightGroupbox('Environment')
local xhair_sec = Tabs.Visuals:AddRightGroupbox('Custom Crosshair')
local vm_sec = Tabs.Visuals:AddRightGroupbox('Viewmodel Chams')

local mats = {"Neon", "ForceField", "Glass", "Ice", "Plastic", "Metal", "SmoothPlastic"}

vm_sec:AddToggle('wpn_chams_on', { Text = 'Weapon Chams', Default = false })
vm_sec:AddLabel('Color'):AddColorPicker('wpn_chams_color', { Default = wpn_chams_col, Transparency = 0, Callback = function(c, t)
    wpn_chams_col = c
end})
vm_sec:AddDropdown('wpn_chams_mat', { Text = 'Material', Values = mats, Default = 1 })
vm_sec:AddSlider('wpn_chams_trans', { Text = 'Transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Callback = function(v) wpn_chams_trans = v end })

vm_sec:AddToggle('arm_chams_on', { Text = 'Arm Chams', Default = false })
vm_sec:AddLabel('Color'):AddColorPicker('arm_chams_color', { Default = arm_chams_col, Transparency = 0, Callback = function(c, t)
    arm_chams_col = c
end})
vm_sec:AddDropdown('arm_chams_mat', { Text = 'Material', Values = mats, Default = 1 })
vm_sec:AddSlider('arm_chams_trans', { Text = 'Transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Callback = function(v) arm_chams_trans = v end })

esp_sec:AddToggle('esp_on', { Text = 'ESP Enabled', Default = false })
esp_sec:AddSlider('esp_max_dist', { Text = 'Max Distance', Default = 2000, Min = 50, Max = 5000, Rounding = 0, Suffix = ' st' })
esp_sec:AddDropdown('box_style', { Text = 'Box Style', Values = {'None', 'Full Box', 'Corner Box'}, Default = 3 })
esp_sec:AddToggle('box_esp', { Text = 'Box ESP', Default = true })
esp_sec:AddLabel('Box Color'):AddColorPicker('box_color', { Default = box_col, Transparency = 0, Callback = function(c) box_col = c end })
esp_sec:AddToggle('name_esp', { Text = 'Name ESP', Default = false })
esp_sec:AddToggle('dist_esp', { Text = 'Distance ESP', Default = false })
esp_sec:AddToggle('hp_esp', { Text = 'Health Bar', Default = false })
esp_sec:AddToggle('skel_esp', { Text = 'Skeleton ESP', Default = false })
esp_sec:AddLabel('Skeleton Color'):AddColorPicker('skel_color', { Default = skel_col, Transparency = 0, Callback = function(c) skel_col = c end })

trac_sec:AddToggle('tracers_on', { Text = 'Tracers', Default = false })
trac_sec:AddLabel('Tracer Color'):AddColorPicker('tracer_color', { Default = trac_col, Transparency = 0, Callback = function(c) trac_col = c end })
trac_sec:AddSlider('tracer_thick', { Text = 'Thickness', Default = 1, Min = 1, Max = 5, Rounding = 0, Suffix = 'px' })
trac_sec:AddDropdown('tracer_origin', { Text = 'Origin', Values = {'Mouse', 'HRP', 'Arms'}, Default = 1 })
trac_sec:AddDropdown('tracer_dest', { Text = 'Destination', Values = {'Head', 'HRP', 'Torso'}, Default = 1 })

chams_sec:AddToggle('chams_on', { Text = 'Chams', Default = false })
chams_sec:AddLabel('Chams Color'):AddColorPicker('chams_color', { Default = chams_col, Transparency = 0, Callback = function(c) chams_col = c end })

fx_sec:AddToggle('aura_vis', { Text = 'Kill Aura Visualizer', Default = false })
fx_sec:AddDropdown('aura_vis_shape', { Text = 'Aura Shape', Values = {'Circle', 'Cube', 'Cylinder', 'Diamond'}, Default = 3, Callback = function(v) set_aura_shp(v) end })
fx_sec:AddLabel('Aura Vis Color'):AddColorPicker('aura_vis_color', { Default = aura_vis_col, Transparency = 0, Callback = function(c) aura_vis_col = c end })
fx_sec:AddSlider('aura_vis_trans', { Text = 'Aura Transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 1 })
fx_sec:AddDropdown('aura_vis_mat', { Text = 'Aura Material', Values = mats, Default = 1 })
fx_sec:AddDropdown('aura_vis_pos', { Text = 'Aura Position', Values = {'Head', 'HumanoidRootPart', 'LeftUpperLeg', 'RightUpperLeg'}, Default = 2 })
fx_sec:AddSlider('aura_vis_x', { Text = 'Aura X Offset', Default = 0, Min = -10, Max = 10, Rounding = 1 })
fx_sec:AddSlider('aura_vis_y', { Text = 'Aura Y Offset', Default = 0, Min = -10, Max = 10, Rounding = 1 })
fx_sec:AddSlider('aura_vis_thick', { Text = 'Aura Thickness', Default = 0.1, Min = 0.1, Max = 10, Rounding = 1 })

fx_sec:AddToggle('danger_indicators', { Text = 'Danger Indicators', Default = false })
fx_sec:AddLabel('Danger Color'):AddColorPicker('danger_color', { Default = dang_col, Transparency = 0, Callback = function(c) dang_col = c end })

local atmosphere = light:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Name = tostring(rng())
atmosphere.Parent = light

local function get_cc()
    local cc = light:FindFirstChild("lccc")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "lccc"
        cc.Parent = light
    end
    return cc
end

env_sec:AddDropdown('skybox_preset', { Text = 'Skybox Preset', Values = {"default", "space", "nebula", "sword fight", "checker", "67", "larp", "astolfo", "rin tohsaka", "black and white", "sinister", "nick was here", "israel", "tung tung tung sahur", "lore accurate rayquaza", "my goat", "volt", "custom"}, Default = 1, Callback = function(v)
    for _, obj in pairs(game.Lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end

    if v == "default" then
        return
    end

    local id = "0"
    if v == "space" then id = "2677508605"
    elseif v == "nebula" then id = "11992958367"
    elseif v == "sword fight" then id = "138569010610226"
    elseif v == "checker" then id = "2424906060"
    elseif v == "67" then id = "123574199714471"
    elseif v == "larp" then id = "92504539826208"
    elseif v == "astolfo" then id = "17871757372"
    elseif v == "rin tohsaka" then id = "18726861143"
    elseif v == "black and white" then id = "11526322514"
    elseif v == "sinister" then id = "80534607281301"
    elseif v == "nick was here" then id = "139071281654202"
    elseif v == "israel" then id = "10012831703"
    elseif v == "tung tung tung sahur" then id = "76287583641908"
    elseif v == "lore accurate rayquaza" then id = "4899954361"
    elseif v == "my goat" then id = "139932718825873"
    elseif v == "volt" then id = "120346696354096"
    elseif v == "custom" then id = tostring(Options.skybox_id.Value or "0") end

    local sky = Instance.new("Sky")
    sky.Name = "Sky"
    sky.SkyboxBk = "rbxassetid://"..id
    sky.SkyboxDn = "rbxassetid://"..id
    sky.SkyboxFt = "rbxassetid://"..id
    sky.SkyboxLf = "rbxassetid://"..id
    sky.SkyboxRt = "rbxassetid://"..id
    sky.SkyboxUp = "rbxassetid://"..id
    sky.Parent = game.Lighting
end})

env_sec:AddInput('skybox_id', { Text = 'Custom Skybox ID', Placeholder = 'ID', Callback = function() 
    if Options.skybox_preset.Value == "custom" then 
        local p = Options.skybox_preset.Value
        Options.skybox_preset:SetValue("default")
        Options.skybox_preset:SetValue(p) 
    end 
end})
env_sec:AddSlider('env_brightness', { Text = 'Brightness', Default = 2, Min = 0, Max = 5, Rounding = 1, Callback = function(v) light.Brightness = v end })
env_sec:AddSlider('env_time', { Text = 'Time of Day', Default = 12, Min = 0, Max = 24, Rounding = 1, Callback = function(v) light.ClockTime = v end })
env_sec:AddSlider('env_fogend', { Text = 'Fog End', Default = 100000, Min = 0, Max = 100000, Rounding = 0, Callback = function(v) light.FogEnd = v end })
env_sec:AddSlider('env_fogstart', { Text = 'Fog Start', Default = 0, Min = 0, Max = 100000, Rounding = 0, Callback = function(v) light.FogStart = v end })
env_sec:AddLabel('Fog Color'):AddColorPicker('fog_color', { Default = rgb(128, 128, 128), Transparency = 0, Callback = function(c) light.FogColor = c end })
env_sec:AddSlider('atm_density', { Text = 'Atmosphere Density', Default = 0.3, Min = 0, Max = 1, Rounding = 2, Callback = function(v) atmosphere.Density = v end })
env_sec:AddSlider('atm_glare', { Text = 'Atmosphere Glare', Default = 0, Min = 0, Max = 1, Rounding = 2, Callback = function(v) atmosphere.Glare = v end })
env_sec:AddSlider('atm_haze', { Text = 'Atmosphere Haze', Default = 0, Min = 0, Max = 1, Rounding = 2, Callback = function(v) atmosphere.Haze = v end })
env_sec:AddLabel('Atmosphere Color'):AddColorPicker('atm_color', { Default = rgb(199, 170, 107), Transparency = 0, Callback = function(c) atmosphere.Color = c end })
env_sec:AddLabel('Atmosphere Decay'):AddColorPicker('atm_decay', { Default = rgb(106, 112, 125), Transparency = 0, Callback = function(c) atmosphere.Decay = c end })

env_sec:AddSlider('saturation', { Text = 'Saturation', Default = 0, Min = -1, Max = 1, Rounding = 2, Callback = function(v) get_cc().Saturation = v end })
env_sec:AddSlider('cc_bright', { Text = 'Brightness CC', Default = 0, Min = -1, Max = 1, Rounding = 2, Callback = function(v) get_cc().Brightness = v end })
env_sec:AddSlider('cc_contrast', { Text = 'Contrast CC', Default = 0, Min = -1, Max = 1, Rounding = 2, Callback = function(v) get_cc().Contrast = v end })
env_sec:AddLabel('CC Tint'):AddColorPicker('cc_tint', { Default = rgb(255, 255, 255), Transparency = 0, Callback = function(c) get_cc().TintColor = c end })

local xhair_lns = {
    top = newdraw("Line", {Thickness = 2, Visible = false, Color = xhair_col}),
    bottom = newdraw("Line", {Thickness = 2, Visible = false, Color = xhair_col}),
    left = newdraw("Line", {Thickness = 2, Visible = false, Color = xhair_col}),
    right = newdraw("Line", {Thickness = 2, Visible = false, Color = xhair_col}),
    dot = newdraw("Circle", {Radius = 2, Filled = true, Visible = false, Color = xhair_col})
}

xhair_sec:AddToggle('xhair_on', { Text = 'Crosshair', Default = false }):OnChanged(function(v) if not v then for _, l in pairs(xhair_lns) do if l then l.Visible = false end end end end)
xhair_sec:AddSlider('xhair_size', { Text = 'Size', Default = 10, Min = 2, Max = 30, Rounding = 0, Suffix = 'px' })
xhair_sec:AddSlider('xhair_gap', { Text = 'Gap', Default = 3, Min = 0, Max = 15, Rounding = 0, Suffix = 'px' })
xhair_sec:AddToggle('xhair_dot', { Text = 'Center Dot', Default = true })
xhair_sec:AddLabel('Color'):AddColorPicker('xhair_color', { Default = xhair_col, Transparency = 0, Callback = function(c) xhair_col = c; for _, l in pairs(xhair_lns) do if l then l.Color = c end end end })

local xp_hkd = false
local orig_vals = wpnclnt.__setValues
wpnclnt.__setValues = function(self, key)
    local res = orig_vals(self, key)
    if not xp_hkd and wpnpkts.useWeapon and wpnpkts.useWeapon.send then
        local origsendd = wpnpkts.useWeapon.send
        wpnpkts.useWeapon.send = function(data)
            if flgs["max_xp"] then
                data.was360 = true
                data.quickscope = true
                data.scoped = true
            end
            return origsendd(data)
        end
        xp_hkd = true
    end
    return res
end

local wpn_main_sec = Tabs.Weapon:AddLeftGroupbox('Weapon Mods')
wpn_main_sec:AddToggle('no_shoot_delay', { Text = 'Inf Fire Rate', Default = false }):OnChanged(apply_wpn_mods)
wpn_main_sec:AddToggle('no_recoil', { Text = 'No Recoil', Default = false, Callback = function(v)
    if v then
        vwmdlclnt.shoot = function(...) end
    else
        vwmdlclnt.shoot = orig_vmshoot
    end
end})
wpn_main_sec:AddToggle('instant_reload', { Text = 'Instant Reload', Default = false }):OnChanged(apply_wpn_mods)
wpn_main_sec:AddToggle('inf_ammo', { Text = 'Infinite Ammo', Default = false }):OnChanged(apply_wpn_mods)
wpn_main_sec:AddToggle('max_xp', { Text = 'Max XP', Default = false })
wpn_main_sec:AddToggle('no_knife_cd', { Text = 'No Knife Cooldown', Default = false })
wpn_main_sec:AddToggle('ff_bypass', { Text = 'Forcefield Bypass', Default = false })

local wpn_skn_sec = Tabs.Skins:AddLeftGroupbox('Weapons')
local pri_drp = wpn_skn_sec:AddDropdown('ot_primary_skin', { Text = 'Primary Skin', Values = pri_skins, Default = 1 })
wpn_skn_sec:AddInput('search_pri', { Text = 'Search Primary', Placeholder = 'search primary...', Callback = function(text)
    local filtered = {}
    for _, item in ipairs(pri_skins) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end
    pri_drp:SetValues(filtered)
end })
wpn_skn_sec:AddButton({ Text = 'Apply Primary', Func = function()
    if lp.Character and lp.Character:GetAttribute("deployed") then
        wpnclnt.setWeapon(1)
        task.wait(0.1)
        wpnclnt.setWeapon(1)
    end
end})

local sec_drp = wpn_skn_sec:AddDropdown('ot_secondary_skin', { Text = 'Secondary Skin', Values = sec_skins, Default = 1 })
wpn_skn_sec:AddInput('search_sec', { Text = 'Search Secondary', Placeholder = 'search secondary...', Callback = function(text)
    local filtered = {}
    for _, item in ipairs(sec_skins) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end
    sec_drp:SetValues(filtered)
end })
wpn_skn_sec:AddButton({ Text = 'Apply Secondary', Func = function()
    if lp.Character and lp.Character:GetAttribute("deployed") then
        wpnclnt.setWeapon(2)
        task.wait(0.1)
        wpnclnt.setWeapon(2)
    end
end})

local knf_skn_sec = Tabs.Skins:AddLeftGroupbox('Knife')
local knf_drp = knf_skn_sec:AddDropdown('ot_knife_skin', { Text = 'Select Knife Skin', Values = knf_skins, Default = 1 })
knf_skn_sec:AddInput('search_knife', { Text = 'Search Knife', Placeholder = 'search...', Callback = function(text)
    local filtered = {}
    for _, item in ipairs(knf_skins) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end
    knf_drp:SetValues(filtered)
end })
knf_skn_sec:AddButton({ Text = 'Apply Knife', Func = function()
    if lp.Character and lp.Character:GetAttribute("deployed") then
        wpnclnt.setWeapon(3)
        task.wait(0.1)
        wpnclnt.setWeapon(3)
    end
end})

local eff_skn_sec = Tabs.Skins:AddRightGroupbox('Kill Effects')
local eff_drp = eff_skn_sec:AddDropdown('ot_kill_effect', { Text = 'Select Kill Effect', Values = killeff_list, Default = 1 })
eff_skn_sec:AddInput('search_effect', { Text = 'Search Effect', Placeholder = 'search...', Callback = function(text)
    local filtered = {}
    for _, item in ipairs(killeff_list) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end
    eff_drp:SetValues(filtered)
end })
eff_skn_sec:AddButton({ Text = 'Apply Kill Effect', Func = function()
    Library:Notify("applied: "..Options.ot_kill_effect.Value, 3)
end})

local misc_sec = Tabs.Misc:AddLeftGroupbox('Local Player')
local move_sec = Tabs.Misc:AddLeftGroupbox('Movement')
local radar_sec = Tabs.Misc:AddLeftGroupbox('Radar')
local srv_sec = Tabs.Misc:AddRightGroupbox('Server')
local snd_sec = Tabs.Misc:AddRightGroupbox('Sounds')

misc_sec:AddToggle('anti_afk', { Text = 'Anti-AFK', Default = false })
misc_sec:AddToggle('noclip_on', { Text = 'Noclip', Default = false })
misc_sec:AddToggle('auto_deploy', { Text = 'Auto Deploy', Default = false, Callback = function(v)
    if v then
        while v do 
            mngmpkts.deploy.send()
            task.wait(1)
        end
    end
end})
misc_sec:AddToggle('instant_respawn', { Text = 'Instant Respawn', Default = false, Callback = function(v)
    if v then
        task.spawn(function()
            while Toggles.instant_respawn.Value do
                if pgui:FindFirstChild("Game Interface") and pgui:FindFirstChild("Game Interface"):FindFirstChild("Deathscreen") then
                    if pgui:FindFirstChild("Game Interface").Deathscreen.Visible then
                        mngmpkts.respawn.send(true)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end})

misc_sec:AddToggle('auto_equip', { Text = 'Auto Equip Weapon', Default = false })
misc_sec:AddDropdown('auto_equip_weapon', { Text = 'Equip Weapon', Values = {'Primary', 'Secondary', 'Knife'}, Default = 1 })
local tp_con
misc_sec:AddToggle('third_person', { Text = 'Third Person', Default = false, Callback = function(v)
    if v then
        lp.CameraMode = Enum.CameraMode.Classic
        lp.CameraMaxZoomDistance = 128
        wpnclnt.scope = function(...) end
        tp_con = lp:GetPropertyChangedSignal("CameraMode"):Connect(function()
            if lp.CameraMode ~= Enum.CameraMode.Classic then
                lp.CameraMode = Enum.CameraMode.Classic
            end
        end)
    else
        if tp_con then tp_con:Disconnect() tp_con = nil end
    end
end})
misc_sec:AddToggle('spin_on', { Text = 'Spin Bot', Default = false })
misc_sec:AddSlider('spin_speed', { Text = 'Spin Speed', Default = 180, Min = 10, Max = 10000, Rounding = 0, Suffix = ' deg/s' })
misc_sec:AddToggle('custom_kill_feed', { Text = 'Custom Kill Feed', Default = false })
misc_sec:AddInput('kill_feed_text', { Text = 'Kill Feed Text', Placeholder = 'Text', Default = '', Callback = function(text) ckf_txt = text end })
misc_sec:AddToggle('hit_notifs', { Text = 'Hit Notifications', Default = false })
misc_sec:AddInput('hit_notif_msg', { Text = 'Hit Notif Message', Placeholder = 'hit (target) for (hp) in (part)', Default = 'hit (target) for (hp) in the (part)!' })

misc_sec:AddToggle('auto_quests', { Text = 'Auto Collect Quests', Default = false, Callback = function(v)
    if v then
        task.spawn(function()
            while Toggles.auto_quests.Value do
                for i=1, 3 do pcall(function() qstpkts.claimDailyQuest.send(i) end) end
                for i=1, 3 do pcall(function() qstpkts.claimHourlyQuest.send(i) end) end
                task.wait(5)
            end
        end)
    end
end})
misc_sec:AddToggle('auto_lvl_rewards', { Text = 'Auto Collect Level Rewards', Default = false, Callback = function(v)
    if v then
        task.spawn(function()
            local level = 1
            pcall(function()
                level = dataclnt.getData().Data.level or 1
            end)
            for i = 1, level do
                pcall(function() lvlrewpkts.claimLevelReward.send(i) end)
                task.wait(0.5)
            end
            Toggles.auto_lvl_rewards:SetValue(false)
        end)
    end
end})
misc_sec:AddToggle('auto_bp', { Text = 'Auto Collect Battlepass', Default = false, Callback = function(v)
    if v then
        task.spawn(function()
            while Toggles.auto_bp.Value do
                for i = 1, 30 do
                    pcall(function() battlepasspkts.claimItem.send({ tierIndex = i, isPremiumTier = false }) end)
                    pcall(function() battlepasspkts.claimItem.send({ tierIndex = i, isPremiumTier = true }) end)
                    task.wait(0.5)
                end
                task.wait(5)
            end
        end)
    end
end})

move_sec:AddToggle('speed_onnn', { Text = 'Speed Hack', Default = false, Callback = function(v) apply_ws(v, Options.walkspeed.Value or 50) end })
move_sec:AddDropdown('speed_method', { Text = 'Speed Method', Values = {'WalkSpeed', 'CFrame', 'Velocity'}, Default = 1 })
move_sec:AddSlider('walkspeed', { Text = 'WalkSpeed', Default = 50, Min = 16, Max = 500, Rounding = 0, Suffix = ' ws' })
move_sec:AddToggle('jump_on', { Text = 'Jump Hack', Default = false, Callback = function(v) apply_jp(v, Options.jump_power.Value or 50) end })
move_sec:AddDropdown('jump_method', { Text = 'Jump Method', Values = {'JumpPower', 'Velocity'}, Default = 1 })
move_sec:AddSlider('jump_power', { Text = 'JumpPower', Default = 50, Min = 50, Max = 500, Rounding = 0, Suffix = ' jp' })

radar_sec:AddToggle('radar_on', { Text = 'Player Radar', Default = false, Callback = function(v) radar_gui.Enabled = v end })
radar_sec:AddSlider('radar_size', { Text = 'Radar Size', Default = 150, Min = 50, Max = 500, Rounding = 0, Callback = function(v) radar_frm.Size = UDim2.new(0, v, 0, v) end })
radar_sec:AddSlider('radar_range', { Text = 'Radar Range', Default = 500, Min = 100, Max = 2000, Rounding = 0, Suffix = ' st' })
radar_sec:AddSlider('radar_x', { Text = 'Radar X', Default = 15, Min = 0, Max = 1920, Rounding = 0, Callback = function(v) radar_frm.Position = UDim2.new(0, v, 0, Options.radar_y.Value or 15) end })
radar_sec:AddSlider('radar_y', { Text = 'Radar Y', Default = 15, Min = 0, Max = 1080, Rounding = 0, Callback = function(v) radar_frm.Position = UDim2.new(0, Options.radar_x.Value or 15, 0, v) end })
radar_sec:AddLabel('Radar Color'):AddColorPicker('radar_color', { Default = radar_dot_col, Transparency = 0, Callback = function(c) radar_dot_col = c end })

srv_sec:AddButton({ Text = 'Copy Job ID', Func = function() pcall(function() setclipboard(game.JobId) end) end })
srv_sec:AddInput('jb_id_input', { Text = 'Job ID', Placeholder = 'Enter Job Id' })
srv_sec:AddButton({ Text = 'Join Server', Func = function()
    local id = Options.jb_id_input.Value
    if id and id ~= "" then
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, id, lp)
        end)
    else
        Library:Notify("pls enter a valid Job Id", 3)
    end
end })
srv_sec:AddButton({ Text = 'Server hop', Func = function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end })

snd_sec:AddToggle('custom_kill_sounds', { Text = 'Custom Kill Sounds', Default = false })
snd_sec:AddDropdown('kill_sound_preset', { Text = 'Kill Sound Preset', Values = {'cod', 'bubble pop', 'jet set', 'osu', 'whip', 'hint', 'bubble pop 2', 'coin flip', 'custom'}, Default = 1 })
snd_sec:AddInput('custom_kill_sound_id', { Text = 'Custom Kill Sound ID', Placeholder = 'rbxassetid://' })

snd_sec:AddToggle('custom_pri_shoot_sounds', { Text = 'Custom Primary Shoot Sounds', Default = false })
snd_sec:AddDropdown('pri_shoot_sound_preset', { Text = 'Primary Shoot Sound', Values = {'glock', 'tank', 'tf2 shit', 'custom'}, Default = 1 })
snd_sec:AddInput('custom_pri_shoot_sound_id', { Text = 'Custom Primary Sound ID', Placeholder = 'rbxassetid://' })

snd_sec:AddToggle('custom_sec_shoot_sounds', { Text = 'Custom Secondary Shoot Sounds', Default = false })
snd_sec:AddDropdown('sec_shoot_sound_preset', { Text = 'Secondary Shoot Sound', Values = {'desert eagle', 'm1911', 'custom'}, Default = 2 })
snd_sec:AddInput('custom_sec_shoot_sound_id', { Text = 'Custom Secondary Sound ID', Placeholder = 'rbxassetid://' })

local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

MenuGroup:AddToggle('ui_keybind_list', { Text = 'Keybind List', Default = false, Callback = function(v) Library.KeybindFrame.Visible = v end })
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
    Library:SetWatermark(('lunar x | %s fps'):format(math.floor(fps)))
end)

MenuGroup:AddLabel('Accent Color'):AddColorPicker('accent_color', { Default = rgb(100, 100, 255), Transparency = 0, Callback = function(c) 
    Library.AccentColor = c 
    Library.AccentColorDark = Library:GetDarkerColor(c)
    Library:UpdateColorsUsingRegistry()
end})

Library:OnUnload(function()
    disc_all()
    for char, _ in pairs(esp_objs) do destroy_esp(char) end
    if fov_circle then fov_circle:Remove() end
    for _, l in pairs(xhair_lns) do if l then l:Remove() end end
    radar_gui:Destroy()
    aura_pt:Destroy()
    
    uis.MouseIconEnabled = true
    if oldnm then hookmetamethod(game, "__namecall", oldnm) end
    if oldIndex then hookmetamethod(game, "__index", oldIndex) end
    if oldNewIndex then hookmetamethod(game, "__newindex", oldNewIndex) end
    
    mdlmng.getWeaponModel = orig_getwpnmdl
    mdlmng.getKnifeModel = orig_getknfmdl
    mdlmng.getWeaponAnimation = orig_getwpnanim
    mdlmng.getKnifeAnimation = orig_getknfanim
    char_mngr.getHoldingWeaponName = orig_getwpnname
    wpnmng.getFireSound = orig_getfiresnd
    tblmngr.lazyLoadModule = orig_lazymod
    vwmdlclnt.shoot = orig_vmshoot
    wpnclnt.scope = orig_scope
    
    if Toggles.no_shoot_delay then Toggles.no_shoot_delay:SetValue(false) end
    if Toggles.instant_reload then Toggles.instant_reload:SetValue(false) end
    if Toggles.inf_ammo then Toggles.inf_ammo:SetValue(false) end
    apply_wpn_mods()
    
    Library.Unloaded = true
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('LunarX')
SaveManager:SetFolder('LunarX/one-tap')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

local is_firing = false
connct(uis.InputBegan, function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gpe then
        is_firing = true
        st.lastClickTime = tick()
        task.spawn(function()
            while is_firing do
                if not uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then break end
                if flgs["auto_fire"] then
                    VIM:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, true, game, 0)
                    task.wait(0.02)
                    VIM:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, false, game, 0)
                    task.wait(0.05)
                else
                    task.wait(0.1)
                end
            end
        end)
    end
end)
connct(uis.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then is_firing = false end
end)

connct(run.Heartbeat, function(dt)
    local hum = gethum()
    if hum then
        if ws_en then
            local method = flgs["speed_method"] or "WalkSpeed"
            local speedVal = flgs["walkspeed"] or 50
            local isWalking = hum.MoveDirection.Magnitude > 0
            if isWalking then
                if method == "WalkSpeed" then
                    if hum.WalkSpeed ~= speedVal then hum.WalkSpeed = speedVal end
                elseif method == "CFrame" then
                    local root = getroot()
                    if root then
                        root.CFrame = root.CFrame + (hum.MoveDirection * speedVal * dt)
                    end
                elseif method == "Velocity" then
                    local root = getroot()
                    if root then
                        local vel = hum.MoveDirection * speedVal
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, root.AssemblyLinearVelocity.Y, vel.Z)
                    end
                end
            else
                if method == "WalkSpeed" then
                    if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
                elseif method == "Velocity" then
                    local root = getroot()
                    if root then
                        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
                    end
                end
            end
        end
        if jp_en then
            local method = flgs["jump_method"] or "JumpPower"
            local jumpVal = flgs["jump_power"] or 50
            if method == "JumpPower" then
                if hum.JumpPower ~= jumpVal then hum.JumpPower = jumpVal end
            elseif method == "Velocity" then
                local root = getroot()
                if root and hum:GetState() == Enum.HumanoidStateType.Jumping then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, jumpVal, root.AssemblyLinearVelocity.Z)
                end
            end
        end
    end
end)

connct(run.Stepped, function()
    if flgs["noclip_on"] then
        local char = getchar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

connct(run.Heartbeat, function()
    if flgs["no_shoot_delay"] then
        pcall(function() wpnclnt.resetBullets(true) end)
    end
end)

local trig_cd = 0
local auto_shoot_cd = 0
connct(run.RenderStepped, function(dt)
    local mp = uis:GetMouseLocation()
    local vp = cam.ViewportSize
    local espOn = flgs["esp_on"]
    local rootPos = getroot() and getroot().Position

    local currentAimTarget = get_aimtarg()
    st.aim_target_player = currentAimTarget
    st.aim_target_part = currentAimTarget and currentAimTarget:FindFirstChild(flgs["aim_part"] or "Head") or nil

    if flgs["silent_aim"] or flgs["wallbang"] then
        currtarg = get_siltarg()
    else
        currtarg = nil
    end

    apply_vm_chams()

    if flgs["aim_on"] and keyb.aim and st.aim_target_part then
        local smooth = flgs["aim_smooth"] or 0.15
        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, st.aim_target_part.Position), smooth)
    end

    if flgs["triggerbot"] and keyb.trigger and st.aim_target_player and tick() - trig_cd > 0.1 then
        mouse1press(); task.wait(0.02); mouse1release(); trig_cd = tick()
    end

    if flgs["auto_shoott"] and tick() - auto_shoot_cd > (flgs["auto_shoot_delay"] or 0.05) then
        pcall(function() wpnclnt.fire() end)
        auto_shoot_cd = tick()
    end

    if flgs["fov_visible"] and fov_circle then
        fov_circle.Visible = true
        fov_circle.Position = Vector2.new(mp.X, mp.Y)
        fov_circle.Color = fov_col
        fov_circle.Thickness = 1
        fov_circle.Radius = flgs["aim_radius"] or 150
    else
        if fov_circle then fov_circle.Visible = false end
    end

    if flgs["xhair_on"] then
        local cx, cy = vp.X / 2, vp.Y / 2
        local sz, gap, thk = flgs["xhair_size"] or 10, flgs["xhair_gap"] or 3, 2
        local col = xhair_col
        local function setL(l, fx, fy, tx, ty) 
            if not l then return end
            l.From, l.To = Vector2.new(fx, fy), Vector2.new(tx, ty)
            l.Thickness, l.Color, l.Visible = thk, col, true 
        end
        setL(xhair_lns.top, cx, cy - gap - sz, cx, cy - gap)
        setL(xhair_lns.bottom, cx, cy + gap, cx, cy + gap + sz)
        setL(xhair_lns.left, cx - gap - sz, cy, cx - gap, cy)
        setL(xhair_lns.right, cx + gap, cy, cx + gap + sz, cy)
        if xhair_lns.dot then
            xhair_lns.dot.Visible = flgs["xhair_dot"] == true
            xhair_lns.dot.Position = Vector2.new(cx, cy)
            xhair_lns.dot.Color = col
        end
    else
        for _, l in pairs(xhair_lns) do if l then l.Visible = false end end
    end

    if flgs["spin_on"] then
        local r = getroot()
        if r then
            r.CFrame = r.CFrame * CFrame.Angles(0, math.rad((flgs["spin_speed"] or 180) * dt), 0)
        end
    end

    if flgs["danger_indicators"] and rootPos then
        for _, char in ipairs(get_targs()) do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local h = char:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.Health > 0 then
                local dirToTarget = (hrp.Position - rootPos)
                local dist = dirToTarget.Magnitude
                if dist < 300 then
                    local relPos = cam.CFrame:VectorToObjectSpace(dirToTarget)
                    if relPos.Z < 0 then
                        local angle = math.atan2(relPos.X, -relPos.Y)
                        local radius = 200
                        local ex = vp.X/2 + math.cos(angle) * radius
                        local ey = vp.Y/2 + math.sin(angle) * radius
                        
                        if not dang_inds[char] then
                            dang_inds[char] = newdraw("Text", {Size = 13, Center = true, Outline = true, Visible = false, Color = dang_col, Font = 2})
                        end
                        dang_inds[char].Text = "!\n"..math.floor(dist).."m"
                        dang_inds[char].Position = Vector2.new(ex, ey)
                        dang_inds[char].Color = dang_col
                        dang_inds[char].Visible = true
                    else
                        if dang_inds[char] then dang_inds[char].Visible = false end
                    end
                else
                    if dang_inds[char] then dang_inds[char].Visible = false end
                end
            else
                if dang_inds[char] then dang_inds[char]:Remove(); dang_inds[char] = nil end
            end
        end
    else
        for char, d in pairs(dang_inds) do d:Remove() end
        dang_inds = {}
    end

    if flgs["aura_vis"] and killaura_on then
        local char = getchar()
        if char then
            local p = char:FindFirstChild(flgs["aura_vis_pos"] or "HumanoidRootPart")
            if p then
                aura_pt.Color = aura_vis_col
                aura_pt.Transparency = flgs["aura_vis_trans"] or 0.5
                aura_pt.Material = Enum.Material[flgs["aura_vis_mat"] or "Neon"]
                
                local range = flgs["kill_aura_range"] or 50
                local thick = flgs["aura_vis_thick"] or 0.1
                local offset = Vector3.new(flgs["aura_vis_x"] or 0, flgs["aura_vis_y"] or 0, 0)
                local curShape = flgs["aura_vis_shape"] or "Circle"
                
                if curShape == "Cylinder" then
                    aura_msh.Scale = Vector3.new(thick, range*2, range*2)
                    aura_pt.CFrame = CFrame.new(p.Position + offset) * CFrame.Angles(0, 0, math.rad(90))
                else
                    aura_msh.Scale = Vector3.new(range*2, range*2, range*2)
                    aura_pt.CFrame = CFrame.new(p.Position + offset)
                end
                
                aura_pt.Parent = ws
            else
                aura_pt.Parent = nil
            end
        else
            aura_pt.Parent = nil
        end
    else
        aura_pt.Parent = nil
    end

    if flgs["custom_kill_feed"] then
        pcall(function()
            local t = lp.PlayerGui.Gameplay.Kill.Tabs.TargetName
            if t and t.Visible then
                t.Text = ckf_txt
            end
        end)
    end

    for _, char in ipairs(get_targs()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (h and hrp) then continue end

        build_esp(char)
        local d = esp_objs[char]

        local function hideAll()
            if d.box then d.box.Visible = false end
            if d.nameText then d.nameText.Visible = false end
            if d.distText then d.distText.Visible = false end
            if d.hpBG then d.hpBG.Visible = false end
            if d.hpBar then d.hpBar.Visible = false end
            if d.tracer then d.tracer.Visible = false end
            for _, l in ipairs(d.corners) do if l then l.Visible = false end end
            for _, l in ipairs(d.skeleton) do if l then l.Visible = false end end
        end

        if not espOn or h.Health <= 0 then hideAll(); continue end
        if rootPos and (hrp.Position - rootPos).Magnitude > (flgs["esp_max_dist"] or 800) then hideAll(); continue end

        apply_chams(char)
        if flgs["hitbox_on"] then expand_hb(char) end

        local sp, onScreen = cam:WorldToViewportPoint(hrp.Position)
        if not onScreen then hideAll(); continue end

        local topSP = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local botSP = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.8, 0))
        local boxH = math.abs(botSP.Y - topSP.Y)
        local boxW = boxH * 0.55
        local bx, by = sp.X - boxW / 2, topSP.Y
        local style = flgs["box_style"] or "Corner Box"

        if flgs["box_esp"] then
            if style == "Full Box" then
                for _, l in ipairs(d.corners) do if l then l.Visible = false end end
                if d.box then
                    d.box.Size = Vector2.new(boxW, boxH); d.box.Position = Vector2.new(bx, by)
                    d.box.Color = box_col; d.box.Visible = true
                end
            elseif style == "Corner Box" then
                if d.box then d.box.Visible = false end
                local cL = math.min(boxW, boxH) * 0.28
                local co = d.corners
                if co[1] then co[1].From, co[1].To = Vector2.new(bx, by), Vector2.new(bx + cL, by) end
                if co[2] then co[2].From, co[2].To = Vector2.new(bx, by), Vector2.new(bx, by + cL) end
                if co[3] then co[3].From, co[3].To = Vector2.new(bx + boxW, by), Vector2.new(bx + boxW - cL, by) end
                if co[4] then co[4].From, co[4].To = Vector2.new(bx + boxW, by), Vector2.new(bx + boxW, by + cL) end
                if co[5] then co[5].From, co[5].To = Vector2.new(bx, by + boxH), Vector2.new(bx + cL, by + boxH) end
                if co[6] then co[6].From, co[6].To = Vector2.new(bx, by + boxH), Vector2.new(bx, by + boxH - cL) end
                if co[7] then co[7].From, co[7].To = Vector2.new(bx + boxW, by + boxH), Vector2.new(bx + boxW - cL, by + boxH) end
                if co[8] then co[8].From, co[8].To = Vector2.new(bx + boxW, by + boxH), Vector2.new(bx + boxW, by + boxH - cL) end
                for _, l in ipairs(co) do if l then l.Color = box_col; l.Visible = true end end
            else
                if d.box then d.box.Visible = false end
                for _, l in ipairs(d.corners) do if l then l.Visible = false end end
            end
        else
            if d.box then d.box.Visible = false end
            for _, l in ipairs(d.corners) do if l then l.Visible = false end end
        end

        if flgs["name_esp"] and d.nameText then
            local plr = plrs:GetPlayerFromCharacter(char)
            d.nameText.Text = plr and plr.Name or char.Name
            d.nameText.Position = Vector2.new(sp.X, by - 14)
            d.nameText.Color = name_col
            d.nameText.Visible = true
        else 
            if d.nameText then d.nameText.Visible = false end 
        end

        if flgs["dist_esp"] and rootPos and d.distText then
            local dist = math.round((hrp.Position - rootPos).Magnitude)
            d.distText.Text = dist .. "m"
            d.distText.Position = Vector2.new(sp.X, by + boxH + 3)
            d.distText.Color = dist_col
            d.distText.Visible = true
        else 
            if d.distText then d.distText.Visible = false end 
        end

        if flgs["hp_esp"] then
            local pct = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
            local hbX, barH = bx - 6, boxH * pct
            if d.hpBG then
                d.hpBG.Size = Vector2.new(4, boxH); d.hpBG.Position = Vector2.new(hbX, by); d.hpBG.Visible = true
            end
            if d.hpBar then
                d.hpBar.Size = Vector2.new(4, barH); d.hpBar.Position = Vector2.new(hbX, by + boxH - barH)
                d.hpBar.Color = Color3.fromRGB(math.round((1 - pct) * 255), math.round(pct * 255), 0)
                d.hpBar.Visible = true
            end
        else
            if d.hpBG then d.hpBG.Visible = false end
            if d.hpBar then d.hpBar.Visible = false end
        end

        if flgs["skel_esp"] then
            local rigType = h.RigType.Name
            local pairsToUse = rigType == "R15" and skel_prs or skel_prs_r6
            for i, pair in ipairs(pairsToUse) do
                local p1 = char:FindFirstChild(pair[1])
                local p2 = char:FindFirstChild(pair[2])
                local ln = d.skeleton[i]
                if p1 and p2 and ln then
                    local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                    local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                    if on1 and on2 then
                        ln.From = Vector2.new(s1.X, s1.Y); ln.To = Vector2.new(s2.X, s2.Y)
                        ln.Color = skel_col; ln.Visible = true
                    else
                        ln.Visible = false
                    end
                else
                    if ln then ln.Visible = false end
                end
            end
        else
            for _, l in ipairs(d.skeleton) do if l then l.Visible = false end end
        end

        if flgs["tracers_on"] and d.tracer then
            local origin = flgs["tracer_origin"] or "Mouse"
            local fromX = origin == "Mouse" and mp.X or vp.X / 2
            local fromY = origin == "Mouse" and mp.Y or vp.Y
            
            local dest = flgs["tracer_dest"] or "Head"
            local destPart = char:FindFirstChild(dest) or hrp
            local destSP = cam:WorldToViewportPoint(destPart.Position)
            
            d.tracer.From = Vector2.new(fromX, fromY); d.tracer.To = Vector2.new(destSP.X, destSP.Y)
            d.tracer.Color = trac_col; d.tracer.Thickness = flgs["tracer_thick"] or 1; d.tracer.Visible = true
        else 
            if d.tracer then d.tracer.Visible = false end 
        end
    end

    if flgs["auto_equip"] then
        local c = getchar()
        if c and c:GetAttribute("deployed") then
            local cw = c:GetAttribute("currentWeapon")
            local tw = flgs["auto_equip_weapon"] or "Primary"
            if cw ~= tw then
                local idx = 1
                if tw == "Secondary" then idx = 2 elseif tw == "Knife" then idx = 3 end
                pcall(function() wpnclnt.setWeapon(idx) end)
            end
        end
    end
end)

connct(run.Heartbeat, function()
    local rootPos = getroot() and getroot().Position
    if flgs["radar_on"] and rootPos then
        for _, char in ipairs(get_targs()) do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local h = char:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.Health > 0 then
                local relPos = cam.CFrame:PointToObjectSpace(hrp.Position)
                local dist = (hrp.Position - rootPos).Magnitude
                if dist < (flgs["radar_range"] or 500) then
                    if not radar_dots[char] then
                        radar_dots[char] = Instance.new("Frame", radar_frm)
                        radar_dots[char].Size = UDim2.new(0, 4, 0, 4)
                        radar_dots[char].BorderColor3 = Color3.new(0, 0, 0)
                        Instance.new("UICorner", radar_dots[char]).CornerRadius = UDim.new(1, 0)
                    end
                    radar_dots[char].BackgroundColor3 = radar_dot_col
                    local scale = (flgs["radar_size"] or 150) / 2
                    radar_dots[char].Position = UDim2.new(0.5, relPos.X / (flgs["radar_range"] or 500) * scale, 0.5, relPos.Z / (flgs["radar_range"] or 500) * scale)
                else
                    if radar_dots[char] then radar_dots[char]:Destroy(); radar_dots[char] = nil end
                end
            else
                if radar_dots[char] then radar_dots[char]:Destroy(); radar_dots[char] = nil end
            end
        end
    else
        for _, dot in pairs(radar_dots) do dot:Destroy() end
        radar_dots = {}
    end
end)

connct(run.Heartbeat, function()
    for char, _ in pairs(esp_objs) do
        if not char.Parent or not char:IsDescendantOf(ws) or not char:FindFirstChild("Humanoid") or char:FindFirstChildOfClass("Humanoid").Health <= 0 then
            destroy_esp(char)
        end
    end
end)

connct(lp.Idled, function()
    if flgs["anti_afk"] then
        if VIM then 
            VIM:SendKeyEvent(true, Enum.KeyCode.ButtonB, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.ButtonB, false, game) 
        end
    end
end)
