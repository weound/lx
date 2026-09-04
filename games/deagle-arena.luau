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
    (funcName == "getrawmetatable" and getrawmetatable) or 
    (funcName == "setreadonly" and setreadonly) or 
    (funcName == "hookmetamethod" and hookmetamethod) or 
    (funcName == "newcclosure" and newcclosure) or 
    (funcName == "checkcaller" and checkcaller)
    
    if not f or type(f) ~= "function" then
        warn("your executor does not support '" .. funcName .. "', bye")
        return false
    end
    return true
end

local funcs = {"getrawmetatable", "setreadonly", "getgenv", "hookmetamethod", "newcclosure", "checkcaller", "loadstring", "gethui", "Drawing.new", "setclipboard", "mouse1press", "mouse1release"}
for _, f in ipairs(funcs) do
    if not check(f) then return end
end

if not game.HttpGet then
    warn("your executor does not support 'HttpGet', bye")
    return
end

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local lib = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Toggles = getgenv().Toggles
local Options = getgenv().Options
lib.Toggles = Toggles
lib.Options = Options

local flags = {}
lib.directory = "LunarX/deagle-arena"

local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local input_service = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local replicated_storage = game:GetService("ReplicatedStorage")
local virtual_input_manager = game:GetService("VirtualInputManager")
local debris_service = game:GetService("Debris")
local http_service = game:GetService("HttpService")

local local_player = players.LocalPlayer
local player_gui = local_player:FindFirstChild("PlayerGui")
local camera = workspace.CurrentCamera
local mouse = local_player:GetMouse()

local player_scripts = local_player:WaitForChild("PlayerScripts")
local module_loader = player_scripts:WaitForChild("ModuleLoader")

local player = game.Players.LocalPlayer
local kick_msg = "the game files are not the same as expected (are u in the right game?)"

local function get_module(parent, ...)
	local current = parent
	for _, name in ipairs({...}) do
		if not current then
			player:Kick(kick_msg)
		end
		current = current:WaitForChild(name, 5)
	end
	if not current then
		player:Kick(kick_msg)
        return
	end
	return require(current)
end

local deagle_controller = get_module(module_loader, "DeagleController")
local viewmodel_controller = get_module(module_loader, "ViewmodelController")
local camera_controller = get_module(module_loader, "CameraController")
local movement_controller = get_module(module_loader, "MovementController")
local crosshair_controller = get_module(module_loader, "CrosshairController")
local effects_controller = get_module(module_loader, "EffectsController")
local round_controller = get_module(module_loader, "RoundController")
local spectate_controller = get_module(module_loader, "SpectateController")
local settings = get_module(module_loader, "UI", "Menus", "Settings")
local deagle_shared = get_module(replicated_storage, "Modules", "Shared", "DeagleShared")
local network = get_module(replicated_storage, "Modules", "Packages", "Network")
local config = get_module(replicated_storage, "Modules", "Shared", "Config")
local cases = get_module(replicated_storage, "Modules", "Shared", "Config", "Cases")
local skins = get_module(replicated_storage, "Modules", "Shared", "Config", "Skins")
local kill_effects = get_module(replicated_storage, "Modules", "Shared", "Config", "KillEffects")
local mouse_module = get_module(replicated_storage, "Modules", "Packages", "Mouse")

local function notify(text)
    pcall(function() lib:Notify(text) end)
end

local function getchar() return local_player.Character end
local function gethum() local c = getchar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getroot() local c = getchar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local hit_sound_presets = { cod = 77082587278347, ["bubble pop"] = 119697580657161, ["jet set"] = 97113622160405, osu = 123941247147792, whip = 90487264912905, hint = 134763632925481, ["bubble pop 2"] = 104824514322839, ["coin flip"] = 99636386529233, custom = 0 }

local box_color = rgb(100, 255, 255)
local tracer_color = rgb(100, 100, 255)
local skeleton_color = rgb(255, 100, 255)
local name_color = rgb(255, 255, 255)
local distance_color = rgb(180, 180, 180)
local chams_color = rgb(170, 85, 235)
local crosshair_color = rgb(255, 255, 255)
local fov_color = rgb(100, 100, 255)
local aura_color = rgb(255, 255, 0)
local danger_color = rgb(255, 0, 0)

local weapon_chams_color = rgb(255, 0, 0)
local weapon_chams_transparency = 0
local arm_chams_color = rgb(0, 255, 0)
local arm_chams_transparency = 0
local beam_color = rgb(255, 0, 255)

local state = {
    aim_target_part = nil,
    aim_target_player = nil,
    silent_target_part = nil,
    silent_target_player = nil,
    lastClickTime = 0
}

local keybinds = { aim = false, trigger = false }
local walkspeed_enabled = false
local jumppower_enabled = false
local current_target = nil
local connections = {}
local hit_cooldown = {}

local function connect(sig, cb)
    local c = sig:Connect(cb)
    table.insert(connections, c)
    return c
end

local function disconnect_all()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    connections = {}
end

local function new_drawing(t, props)
    local d, err = Drawing.new(t)
    if not d then return nil end
    for k, v in pairs(props) do
        pcall(function() d[k] = v end)
    end
    return d
end

local original_shoot = deagle_controller.Shoot
local original_get_mouse_pos = mouse_module.GetMousePos
local original_ray = deagle_shared.Raycast
local original_on_client_event = network.OnClientEvent
local original_set_deagle = viewmodel_controller.SetDeagle
local original_fire_server = network.FireServer
local original_cam_shoot = camera_controller.Shoot
local original_cam_land = camera_controller.Land
local original_crosshair_reload = crosshair_controller.Reload
local original_spawn_beam = effects_controller.SpawnBeam
local original_vm_shoot = viewmodel_controller.OnShoot

pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old_namecall = mt.__namecall
    if old_namecall and not hookmetamethod then
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then return end
            return old_namecall(self, ...)
        end)
    end
    setreadonly(mt, true)
end)

local old_index
old_index = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if key == "WalkSpeed" and walkspeed_enabled and self:IsA("Humanoid") then return 16 end
        if key == "JumpPower" and jumppower_enabled and self:IsA("Humanoid") then return 50 end
        if self == camera and key == "FieldOfView" and flags["custom_fov_on"] then
            return flags["custom_fov_val"] or 90
        end
    end
    return old_index(self, key)
end))

local old_newindex
old_newindex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
    if not checkcaller() then
        if key == "AssemblyLinearVelocity" and typeof(value) == "Vector3" then
            if self:IsA("BasePart") and self.Name == "HumanoidRootPart" then
                local char = self:FindFirstAncestorOfClass("Model")
                if char and char == local_player.Character then
                    if walkspeed_enabled and value.X == 0 and value.Z == 0 then return end
                    if jumppower_enabled and value.Y < -40 then return end
                end
            end
        end
        if self == camera and key == "FieldOfView" and flags["custom_fov_on"] then
            return
        end
    end
    return old_newindex(self, key, value)
end))

local function send_hit_notif(char, part_name)
    if not char or not flags["hit_notifs"] or hit_cooldown[char] then return end
    hit_cooldown[char] = true
    task.delay(0.2, function() hit_cooldown[char] = nil end)
    
    local tname = char.Name or "Bot"
    local hpart = (part_name == "Head" or part_name == "HeadHitbox") and "head" or "body"
    local hplost = math.random(10, 50)
    local msg = flags["hit_notif_msg"] or "hit (target) for (hp) in the (part)!"
    msg = string.gsub(msg, "%(target%)", tname)
    msg = string.gsub(msg, "%(part%)", hpart)
    msg = string.gsub(msg, "%(hp%)", tostring(hplost))
    notify(msg)
end

network.FireServer = function(self, name, ...)
    local args = {...}
    if name == "Shoot" and current_target and flags["silent_aim"] and flags["silent_method"] == "Packet" then
        local head = current_target:FindFirstChild(flags["aim_part"] or "Head") or current_target:FindFirstChild("HumanoidRootPart")
        if head then
            local hitchance = flags["silent_hitchance"] or 100
            if math.random(1, 100) <= hitchance then
                args[2] = head.Position
                args[3] = head
                args[4] = head.Position
                send_hit_notif(current_target, head.Name)
            end
        end
    end
    return original_fire_server(self, name, table.unpack(args))
end

mouse_module.GetMousePos = function()
    if current_target and flags["silent_aim"] and flags["silent_method"] == "Raycast" then
        local head = current_target:FindFirstChild(flags["aim_part"] or "Head") or current_target:FindFirstChild("HumanoidRootPart")
        if head then
            return head.Position
        end
    end
    return original_get_mouse_pos()
end

deagle_shared.Raycast = function(ignore, origin, target)
    if current_target and flags["silent_aim"] and flags["silent_method"] == "Raycast" then
        local head = current_target:FindFirstChild(flags["aim_part"] or "Head") or current_target:FindFirstChild("HumanoidRootPart")
        if head then
            local hitchance = flags["silent_hitchance"] or 100
            if math.random(1, 100) <= hitchance then
                send_hit_notif(current_target, head.Name)
                return {
                    Instance = head,
                    Position = head.Position,
                    Normal = Vector3.new(0, 1, 0)
                }
            end
        end
    end
    local res = original_ray(ignore, origin, target)
    if res and res.Instance then
        local char = res.Instance:FindFirstAncestorOfClass("Model")
        if char and char:FindFirstChildOfClass("Humanoid") and char ~= local_player.Character then
            send_hit_notif(char, res.Instance.Name)
        end
    end
    return res
end

network.OnClientEvent = function(self, name, func)
    if name == "Effect" then
        local hooked = function(...)
            local args = {...}
            if flags["custom_kill_sounds"] and args[1] and args[1]:FindFirstChildOfClass("Humanoid") and args[1]:FindFirstChildOfClass("Humanoid").Health <= 0 then
                local id = 0
                local prst = flags["kill_sound_preset"]
                if prst == "custom" then
                    local txt = flags["custom_kill_sound_id"] or ""
                    local num = string.match(txt, "%d+")
                    if num then id = tonumber(num) end
                else
                    id = hit_sound_presets[prst] or 0
                end
                if id > 0 then
                    local s = Instance.new("Sound")
                    s.SoundId = "rbxassetid://" .. id
                    s.Volume = 1
                    s.Parent = workspace
                    s:Play()
                    debris_service:AddItem(s, 5)
                end
            end
            return func(table.unpack(args))
        end
        return original_on_client_event(self, name, hooked)
    end
    return original_on_client_event(self, name, func)
end

viewmodel_controller.SetDeagle = function(skin, ...)
    if skin and skin ~= "" then
        local char = local_player.Character
        if char then
            local deagle = char:FindFirstChild("Deagle")
            if deagle then
                deagle:SetAttribute("DeagleSkinName", skin)
            end
        end
    end
    return original_set_deagle(skin, ...)
end

viewmodel_controller.OnShoot = function(...)
    if flags["remove_gun_anim"] then return end
    return original_vm_shoot(...)
end

crosshair_controller.Reload = function(...)
    if flags["no_spread"] then return end
    return original_crosshair_reload(...)
end

effects_controller.SpawnBeam = function(...)
    local args = {...}
    if flags["custom_beam"] then
        args[5] = args[5] or {}
        args[5].Time = flags["beam_time"]
        args[5].Size = flags["beam_size"]
        args[5].Color = beam_color
    end
    return original_spawn_beam(table.unpack(args))
end

camera_controller.Land = function(...)
    if flags["no_shake"] then return end
    return original_cam_land(...)
end

camera_controller.Shoot = function(...)
    if flags["no_recoil"] then return end
    return original_cam_shoot(...)
end

local function apply_walkspeed(state, speed)
    walkspeed_enabled = state
    local hum = gethum()
    if hum then hum.WalkSpeed = state and (speed or 50) or 16 end
end

local function apply_jumppower(state, power)
    jumppower_enabled = state
    local hum = gethum()
    if hum then hum.JumpPower = state and (power or 50) or 50 end
end

local kill_aura_on = false
local function run_kill_aura()
    while kill_aura_on do
        local root = getroot()
        if root then
            for _, char in ipairs(get_targets()) do
                local hum = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")
                if hum and head and hum.Health > 0 then
                    local dist = (head.Position - root.Position).Magnitude
                    if dist <= (flags["kill_aura_range"] or 50) then
                        current_target = char
                        pcall(function() deagle_controller.Shoot() end)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

local function set_kill_aura(active)
    kill_aura_on = active
    if active then task.spawn(run_kill_aura) end
end

local hitbox_parts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
local function expand_hitbox(char)
    local sz = flags["hitbox_size"] or 8
    for _, name in ipairs(hitbox_parts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            pcall(function() part.Size = Vector3.new(sz, sz, sz) end)
        end
    end
end

function get_targets()
    local targets = {}
    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= local_player and plr.Character then
            table.insert(targets, plr.Character)
        end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not players:GetPlayerFromCharacter(obj) and obj:GetAttribute("IsBot") then
            table.insert(targets, obj)
        end
    end
    return targets
end

local function get_aim_target()
    local mouse_pos = input_service:GetMouseLocation()
    local fov = flags["aim_radius"] or 150
    local max_dist = flags["aim_max_dist"] or 5000
    local root = getroot()
    local cam_pos = camera.CFrame.Position
    local cam_look = camera.CFrame.LookVector
    local best, best_score = nil, math.huge

    for _, char in ipairs(get_targets()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local part = char:FindFirstChild(flags["aim_part"] or "Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if h and part and hrp and h.Health > 0 then
            local dist3d = root and (hrp.Position - root.Position).Magnitude or 0
            if dist3d > max_dist then continue end

            if flags["aim_wall_check"] then
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {getchar(), char}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local hit = workspace:Raycast(cam_pos, (part.Position - cam_pos), rp)
                if hit and not hit.Instance:IsDescendantOf(char) then continue end
            end

            local sp = camera:WorldToViewportPoint(part.Position)
            if sp.Z <= 0 then continue end
            
            local screen_dist = (Vector2.new(sp.X, sp.Y) - mouse_pos).Magnitude
            if screen_dist > fov then continue end

            local score = screen_dist
            if score < best_score then best = char; best_score = score end
        end
    end
    return best
end

local function get_silent_target()
    local mouse_pos = input_service:GetMouseLocation()
    local fov = flags["silent_radius"] or 150
    local max_dist = flags["aim_max_dist"] or 5000
    local root = getroot()
    local cam_pos = camera.CFrame.Position
    local best, best_score = nil, math.huge

    for _, char in ipairs(get_targets()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local part = char:FindFirstChild(flags["aim_part"] or "Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if h and part and hrp and h.Health > 0 then
            local dist3d = root and (hrp.Position - root.Position).Magnitude or 0
            if not flags["inf_distance"] and dist3d > max_dist then continue end

            if flags["silent_wall_check"] then
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {getchar(), char}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local hit = workspace:Raycast(cam_pos, (part.Position - cam_pos), rp)
                if hit and not hit.Instance:IsDescendantOf(char) then continue end
            end

            local sp = camera:WorldToViewportPoint(part.Position)
            if sp.Z <= 0 then continue end
            
            local screen_dist = (Vector2.new(sp.X, sp.Y) - mouse_pos).Magnitude
            if screen_dist > fov then continue end

            local score = screen_dist
            if score < best_score then best = char; best_score = score end
        end
    end
    return best
end

local esp_objects = {}
local danger_indicators = {}
local skeleton_pairs = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"RightLowerLeg", "RightFoot"}
}
local skeleton_pairs_r6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function build_esp(char)
    if esp_objects[char] then return end
    local corners = {}
    for i = 1, 8 do corners[i] = new_drawing("Line", {Thickness = 2, Visible = false, Color = box_color}) end
    local skeleton = {}
    for i = 1, #skeleton_pairs do skeleton[i] = new_drawing("Line", {Thickness = 1, Visible = false, Color = skeleton_color}) end
    
    esp_objects[char] = {
        box = new_drawing("Square", {Thickness = 1, Filled = false, Visible = false, Color = box_color}),
        corners = corners,
        skeleton = skeleton,
        nameText = new_drawing("Text", {Size = 13, Center = true, Outline = true, Visible = false, Color = name_color, Font = 2}),
        distText = new_drawing("Text", {Size = 11, Center = true, Outline = true, Visible = false, Color = distance_color, Font = 2}),
        hpBG = new_drawing("Square", {Filled = true, Visible = false, Color = rgb(0, 0, 0)}),
        hpBar = new_drawing("Square", {Filled = true, Visible = false, Color = rgb(0, 255, 0)}),
        tracer = new_drawing("Line", {Thickness = 1, Visible = false, Color = tracer_color})
    }
end

local function destroy_esp(char)
    local d = esp_objects[char]
    if not d then return end
    for _, v in pairs(d.corners) do pcall(function() v:Remove() end) end
    for _, v in pairs(d.skeleton) do pcall(function() v:Remove() end) end
    for k, v in pairs(d) do
        if k ~= "corners" and k ~= "skeleton" then pcall(function() v:Remove() end) end
    end
    esp_objects[char] = nil
end

local function random_id()
   return math.random(1, 967676767)
end

local function apply_chams(char)
    if not char or not char.Parent then return end
    if not flags["chams_on"] then
        if char:FindFirstChild("LunarChams") then char.LunarChams:Destroy() end
        return
    end
    
    if not char:FindFirstChild("LunarChams") then
        local h = Instance.new("Highlight")
        h.Name = "LunarChams"
        h.FillColor = chams_color
        h.OutlineColor = Color3.new(1, 1, 1)
        h.Parent = char
    end
    
    local c = char.LunarChams
    c.FillColor = chams_color
    c.FillTransparency = 0.5
    c.OutlineTransparency = 0
    c.Enabled = true
end

local function apply_viewmodel_chams()
    local vm = viewmodel_controller.GetViewmodel()
    if not vm then return end
    
    local function apply(part, color, material, trans, enabled)
        if not part or not part:IsA("BasePart") then return end
        if enabled then
            if not part:GetAttribute("lunxorig") then
                part:SetAttribute("lunxorig", true)
                part:SetAttribute("omat", part.Material)
                part:SetAttribute("ocol", part.Color)
                part:SetAttribute("otra", part.Transparency)
            end
            part.Color = color
            part.Material = material
            part.Transparency = trans
        else
            if part:GetAttribute("lunxorig") then
                part.Material = part:GetAttribute("omat")
                part.Color = part:GetAttribute("ocol")
                part.Transparency = part:GetAttribute("otra")
                part:SetAttribute("lunxorig", nil)
            end
        end
    end

    for _, child in ipairs(vm:GetChildren()) do
        if string.find(child.Name, "Arm") or string.find(child.Name, "Hand") then
            apply(child, arm_chams_color, Enum.Material[flags["arm_chams_mat"] or "Neon"], arm_chams_transparency, flags["arm_chams_on"])
            for _, desc in ipairs(child:GetDescendants()) do
                apply(desc, arm_chams_color, Enum.Material[flags["arm_chams_mat"] or "Neon"], arm_chams_transparency, flags["arm_chams_on"])
            end
        elseif child.Name == "Deagle" then
            apply(child, weapon_chams_color, Enum.Material[flags["wpn_chams_mat"] or "Neon"], weapon_chams_transparency, flags["wpn_chams_on"])
            for _, desc in ipairs(child:GetDescendants()) do
                apply(desc, weapon_chams_color, Enum.Material[flags["wpn_chams_mat"] or "Neon"], weapon_chams_transparency, flags["wpn_chams_on"])
            end
        end
    end
end

local case_list = {}
for name, _ in pairs(cases) do
    table.insert(case_list, name)
end
table.sort(case_list)

local deagle_skins_list = {}
if skins then
    for name, _ in pairs(skins) do
        if name ~= "DefaultBeam" then
            table.insert(deagle_skins_list, name)
        end
    end
    table.sort(deagle_skins_list)
end

local kill_effect_list = {}
if kill_effects then
    for name, _ in pairs(kill_effects) do
        table.insert(kill_effect_list, name)
    end
    table.sort(kill_effect_list)
end

local radar_gui = Instance.new("ScreenGui")
radar_gui.Name = tostring(random_id())
radar_gui.Parent = gethui()
radar_gui.Enabled = false

local radar_frame = Instance.new("Frame", radar_gui)
radar_frame.Size = UDim2.new(0, 150, 0, 150)
radar_frame.Position = UDim2.new(0, 15, 0, 15)
radar_frame.BackgroundColor3 = Color3.new(0, 0, 0)
radar_frame.BackgroundTransparency = 0.5
radar_frame.BorderSizePixel = 0
Instance.new("UICorner", radar_frame).CornerRadius = UDim.new(1, 0)

local radar_center = Instance.new("Frame", radar_frame)
radar_center.Size = UDim2.new(0, 4, 0, 4)
radar_center.Position = UDim2.new(0.5, -2, 0.5, -2)
radar_center.BackgroundColor3 = Color3.new(1, 1, 1)
radar_center.BorderSizePixel = 0
Instance.new("UICorner", radar_center).CornerRadius = UDim.new(1, 0)

local radar_dots = {}
local radar_dot_color = rgb(255, 0, 0)

local aura_part = Instance.new("Part")
aura_part.Name = tostring(random_id())
aura_part.Anchored = true
aura_part.CanCollide = false
aura_part.Transparency = 0.5
aura_part.Material = Enum.Material.Neon
aura_part.Size = Vector3.new(1, 1, 1)
aura_part.Parent = nil

local aura_mesh = Instance.new("SpecialMesh", aura_part)
aura_mesh.MeshType = Enum.MeshType.Brick

local function set_aura_shape(shape)
    aura_mesh.MeshId = ""
    if shape == "Circle" then
        aura_mesh.MeshType = Enum.MeshType.Sphere
    elseif shape == "Cube" then
        aura_mesh.MeshType = Enum.MeshType.Brick
    elseif shape == "Cylinder" then
        aura_mesh.MeshType = Enum.MeshType.Cylinder
    elseif shape == "Diamond" then
        aura_mesh.MeshType = Enum.MeshType.FileMesh
        aura_mesh.MeshId = "rbxassetid://9756362"
    end
end

local window = lib:CreateWindow({ Title = "lunar x | deagle arena", Center = true, AutoShow = true, TabPadding = 8, MenuFadeTime = 0.2 })

local aim_tab = window:AddTab('aimbot')
local visuals_tab = window:AddTab('visuals')
local weapon_tab = window:AddTab('weapon')
local skins_tab = window:AddTab('skins')
local misc_tab = window:AddTab('misc')
local settings_tab = window:AddTab('settings')

local aim_sec = aim_tab:AddLeftGroupbox('aimbot')
local sil_sec = aim_tab:AddLeftGroupbox('silent aim')
local aim_cfg = aim_tab:AddLeftGroupbox('config')
local fov_sec = aim_tab:AddRightGroupbox('fov circle')
local aura_sec = aim_tab:AddRightGroupbox('aura')

aim_sec:AddToggle('aim_on', { Text = 'Aimbot', Default = false, Callback = function(v) flags['aim_on'] = v end })
aim_sec:AddLabel('Aimbot Bind'):AddKeyPicker('aim_key', { Default = 'E', Mode = 'Hold', Text = 'Aimbot Bind' })
aim_sec:AddToggle('aim_wall_check', { Text = 'Wall Check', Default = true, Callback = function(v) flags['aim_wall_check'] = v end })
aim_sec:AddToggle('triggerbot', { Text = 'Trigger Bot', Default = false, Callback = function(v) flags['triggerbot'] = v end })
aim_sec:AddLabel('Trigger Bind'):AddKeyPicker('trigger_key', { Default = 'Q', Mode = 'Hold', Text = 'Trigger Bind' })
aim_sec:AddToggle('auto_shoott', { Text = 'Auto Shoot', Default = false, Callback = function(v) flags['auto_shoott'] = v end })
aim_sec:AddSlider('auto_shoot_delay', { Text = 'Auto Shoot Delay', Min = 0.01, Max = 1, Default = 0.05, Rounding = 2, Suffix = 's', Callback = function(v) flags['auto_shoot_delay'] = v end })

sil_sec:AddToggle('silent_aim', { Text = 'Silent Aim', Default = false, Callback = function(v) flags['silent_aim'] = v end })
sil_sec:AddDropdown('silent_method', { Text = 'Silent Aim Method', Values = {'Raycast', 'Packet'}, Default = 'Packet', Callback = function(v) flags['silent_method'] = v end })
sil_sec:AddSlider('silent_hitchance', { Text = 'Hit Chance', Min = 1, Max = 100, Default = 100, Rounding = 0, Suffix = '%', Callback = function(v) flags['silent_hitchance'] = v end })
sil_sec:AddToggle('silent_wall_check', { Text = 'Wall Check', Default = true, Callback = function(v) flags['silent_wall_check'] = v end })
sil_sec:AddToggle('inf_distance', { Text = 'Inf Distance', Default = false, Callback = function(v) flags['inf_distance'] = v end })
sil_sec:AddSlider('silent_radius', { Text = 'Silent Aim Radius', Min = 10, Max = 1000, Default = 150, Rounding = 0, Suffix = 'px', Callback = function(v) flags['silent_radius'] = v end })

aim_cfg:AddDropdown('aim_part', { Text = 'Target Part', Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'}, Default = 'Head', Callback = function(v) flags['aim_part'] = v end })
aim_cfg:AddSlider('aim_smooth', { Text = 'Smoothness', Min = 0.01, Max = 1, Default = 0.15, Rounding = 2, Suffix = 'x', Callback = function(v) flags['aim_smooth'] = v end })
aim_cfg:AddSlider('aim_max_dist', { Text = 'Max Distance', Min = 50, Max = 5000, Default = 1000, Rounding = 0, Suffix = ' st', Callback = function(v) flags['aim_max_dist'] = v end })

local fov_circle = new_drawing("Circle", { Thickness = 1, Filled = false, Visible = false, Color = fov_color, Radius = 150 })
fov_sec:AddToggle('fov_visible', { Text = 'Visible', Default = false, Callback = function(v) flags['fov_visible'] = v; if fov_circle then fov_circle.Visible = v end end })
fov_sec:AddLabel('FOV Color'):AddColorPicker('fov_color', { Default = fov_color, Title = 'FOV Color', Transparency = 0, Callback = function(c) flags['fov_color'] = c; fov_color = c; if fov_circle then fov_circle.Color = c end end })
fov_sec:AddSlider('aim_radius', { Text = 'Radius', Min = 10, Max = 1000, Default = 150, Rounding = 0, Suffix = 'px', Callback = function(v) flags['aim_radius'] = v; if fov_circle then fov_circle.Radius = v end end })

aura_sec:AddToggle('kill_aura', { Text = 'Kill Aura', Default = false, Callback = function(v) flags['kill_aura'] = v; set_kill_aura(v) end })
aura_sec:AddSlider('kill_aura_range', { Text = 'Kill Aura Range', Min = 10, Max = 500, Default = 50, Rounding = 0, Suffix = ' st', Callback = function(v) flags['kill_aura_range'] = v end })
aura_sec:AddToggle('hitbox_on', { Text = 'Hitbox Expander', Default = false, Callback = function(v) flags['hitbox_on'] = v end })
aura_sec:AddSlider('hitbox_size', { Text = 'Hitbox Size', Min = 1, Max = 60, Default = 8, Rounding = 1, Suffix = ' st', Callback = function(v) flags['hitbox_size'] = v end })

local esp_sec = visuals_tab:AddLeftGroupbox('player esp')
local trac_sec = visuals_tab:AddLeftGroupbox('tracer config')
local chams_sec = visuals_tab:AddLeftGroupbox('chams')
local beam_sec = visuals_tab:AddLeftGroupbox('beam config')
local fx_sec = visuals_tab:AddLeftGroupbox('effects')
local env_sec = visuals_tab:AddRightGroupbox('environment')
local xhair_sec = visuals_tab:AddRightGroupbox('custom crosshair')
local vm_sec = visuals_tab:AddRightGroupbox('viewmodel chams')

local mats = {"Neon", "ForceField", "Glass", "Ice", "Plastic", "Metal", "SmoothPlastic"}

vm_sec:AddToggle('wpn_chams_on', { Text = 'Weapon Chams', Default = false, Callback = function(v) flags['wpn_chams_on'] = v end })
vm_sec:AddLabel('Color'):AddColorPicker('wpn_chams_color', { Default = weapon_chams_color, Title = 'Weapon Chams Color', Transparency = 0, Callback = function(c) flags['wpn_chams_color'] = c; weapon_chams_color = c end })
vm_sec:AddDropdown('wpn_chams_mat', { Text = 'Material', Values = mats, Default = 'Neon', Callback = function(v) flags['wpn_chams_mat'] = v end })
vm_sec:AddSlider('wpn_chams_trans', { Text = 'Transparency', Min = 0, Max = 1, Default = 0, Rounding = 1, Callback = function(v) flags['wpn_chams_trans'] = v; weapon_chams_transparency = v end })

vm_sec:AddToggle('arm_chams_on', { Text = 'Arm Chams', Default = false, Callback = function(v) flags['arm_chams_on'] = v end })
vm_sec:AddLabel('Color'):AddColorPicker('arm_chams_color', { Default = arm_chams_color, Title = 'Arm Chams Color', Transparency = 0, Callback = function(c) flags['arm_chams_color'] = c; arm_chams_color = c end })
vm_sec:AddDropdown('arm_chams_mat', { Text = 'Material', Values = mats, Default = 'Neon', Callback = function(v) flags['arm_chams_mat'] = v end })
vm_sec:AddSlider('arm_chams_trans', { Text = 'Transparency', Min = 0, Max = 1, Default = 0, Rounding = 1, Callback = function(v) flags['arm_chams_trans'] = v; arm_chams_transparency = v end })

esp_sec:AddToggle('esp_on', { Text = 'ESP Enabled', Default = false, Callback = function(v) flags['esp_on'] = v end })
esp_sec:AddSlider('esp_max_dist', { Text = 'Max Distance', Min = 50, Max = 5000, Default = 2000, Rounding = 0, Suffix = ' st', Callback = function(v) flags['esp_max_dist'] = v end })
esp_sec:AddDropdown('box_style', { Text = 'Box Style', Values = {'None', 'Full Box', 'Corner Box'}, Default = 'Corner Box', Callback = function(v) flags['box_style'] = v end })
esp_sec:AddToggle('box_esp', { Text = 'Box ESP', Default = true, Callback = function(v) flags['box_esp'] = v end })
esp_sec:AddLabel('Box Color'):AddColorPicker('box_color', { Default = box_color, Title = 'Box Color', Transparency = 0, Callback = function(c) flags['box_color'] = c; box_color = c end })
esp_sec:AddToggle('name_esp', { Text = 'Name ESP', Default = false, Callback = function(v) flags['name_esp'] = v end })
esp_sec:AddToggle('dist_esp', { Text = 'Distance ESP', Default = false, Callback = function(v) flags['dist_esp'] = v end })
esp_sec:AddToggle('hp_esp', { Text = 'Health Bar', Default = false, Callback = function(v) flags['hp_esp'] = v end })
esp_sec:AddToggle('skel_esp', { Text = 'Skeleton ESP', Default = false, Callback = function(v) flags['skel_esp'] = v end })
esp_sec:AddLabel('Skeleton Color'):AddColorPicker('skel_color', { Default = skeleton_color, Title = 'Skeleton Color', Transparency = 0, Callback = function(c) flags['skel_color'] = c; skeleton_color = c end })

trac_sec:AddToggle('tracers_on', { Text = 'Tracers', Default = false, Callback = function(v) flags['tracers_on'] = v end })
trac_sec:AddLabel('Tracer Color'):AddColorPicker('tracer_color', { Default = tracer_color, Title = 'Tracer Color', Transparency = 0, Callback = function(c) flags['tracer_color'] = c; tracer_color = c end })
trac_sec:AddSlider('tracer_thick', { Text = 'Thickness', Min = 1, Max = 5, Default = 1, Rounding = 0, Suffix = 'px', Callback = function(v) flags['tracer_thick'] = v end })
trac_sec:AddDropdown('tracer_origin', { Text = 'Origin', Values = {'Mouse', 'HRP', 'Arms'}, Default = 'Mouse', Callback = function(v) flags['tracer_origin'] = v end })
trac_sec:AddDropdown('tracer_dest', { Text = 'Destination', Values = {'Head', 'HRP', 'Torso'}, Default = 'Head', Callback = function(v) flags['tracer_dest'] = v end })

chams_sec:AddToggle('chams_on', { Text = 'Chams', Default = false, Callback = function(v) flags['chams_on'] = v end })
chams_sec:AddLabel('Chams Color'):AddColorPicker('chams_color', { Default = chams_color, Title = 'Chams Color', Transparency = 0, Callback = function(c) flags['chams_color'] = c; chams_color = c end })

beam_sec:AddToggle('custom_beam', { Text = 'Custom Beam', Default = false, Callback = function(v) flags['custom_beam'] = v end })
beam_sec:AddLabel('Beam Color'):AddColorPicker('beam_color', { Default = beam_color, Title = 'Beam Color', Transparency = 0, Callback = function(c) flags['beam_color'] = c; beam_color = c end })
beam_sec:AddSlider('beam_size', { Text = 'Beam Size', Min = 0, Max = 5, Default = 1, Rounding = 1, Suffix = ' st', Callback = function(v) flags['beam_size'] = v end })
beam_sec:AddSlider('beam_time', { Text = 'Beam Time', Min = 0, Max = 2, Default = 0.1, Rounding = 2, Suffix = 's', Callback = function(v) flags['beam_time'] = v end })

fx_sec:AddToggle('aura_vis', { Text = 'Kill Aura Visualizer', Default = false, Callback = function(v) flags['aura_vis'] = v end })
fx_sec:AddDropdown('aura_vis_shape', { Text = 'Aura Shape', Values = {'Circle', 'Cube', 'Cylinder', 'Diamond'}, Default = 'Cylinder', Callback = function(v) flags['aura_vis_shape'] = v; set_aura_shape(v) end })
fx_sec:AddLabel('Aura Vis Color'):AddColorPicker('aura_vis_color', { Default = aura_color, Title = 'Aura Vis Color', Transparency = 0, Callback = function(c) flags['aura_vis_color'] = c; aura_color = c end })
fx_sec:AddSlider('aura_vis_trans', { Text = 'Aura Transparency', Min = 0, Max = 1, Default = 0.5, Rounding = 1, Callback = function(v) flags['aura_vis_trans'] = v end })
fx_sec:AddDropdown('aura_vis_mat', { Text = 'Aura Material', Values = mats, Default = 'Neon', Callback = function(v) flags['aura_vis_mat'] = v end })
fx_sec:AddDropdown('aura_vis_pos', { Text = 'Aura Position', Values = {'Head', 'HumanoidRootPart', 'LeftUpperLeg', 'RightUpperLeg'}, Default = 'HumanoidRootPart', Callback = function(v) flags['aura_vis_pos'] = v end })
fx_sec:AddSlider('aura_vis_x', { Text = 'Aura X Offset', Min = -10, Max = 10, Default = 0, Rounding = 1, Callback = function(v) flags['aura_vis_x'] = v end })
fx_sec:AddSlider('aura_vis_y', { Text = 'Aura Y Offset', Min = -10, Max = 10, Default = 0, Rounding = 1, Callback = function(v) flags['aura_vis_y'] = v end })
fx_sec:AddSlider('aura_vis_thick', { Text = 'Aura Thickness', Min = 0.1, Max = 10, Default = 0.1, Rounding = 1, Callback = function(v) flags['aura_vis_thick'] = v end })

fx_sec:AddToggle('danger_indicators', { Text = 'Danger Indicators', Default = false, Callback = function(v) flags['danger_indicators'] = v end })
fx_sec:AddLabel('Danger Color'):AddColorPicker('danger_color', { Default = danger_color, Title = 'Danger Color', Transparency = 0, Callback = function(c) flags['danger_color'] = c; danger_color = c end })

local atmosphere = lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Name = tostring(random_id())
atmosphere.Parent = lighting

local function get_color_correction()
    local cc = lighting:FindFirstChild("lccc")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "lccc"
        cc.Parent = lighting
    end
    return cc
end

env_sec:AddDropdown('skybox_preset', { Text = 'Skybox Preset', Values = {"default", "space", "nebula", "sword fight", "checker", "67", "larp", "astolfo", "rin tohsaka", "black and white", "sinister", "nick was here", "israel", "tung tung tung sahur", "lore accurate rayquaza", "my goat", "volt", "custom"}, Default = 'default', Callback = function(v)
    flags['skybox_preset'] = v
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
    elseif v == "custom" then id = tostring(flags["skybox_id"] or "0") end

    local sky = Instance.new("Sky")
    sky.Name = "Sky"
    sky.SkyboxBk = "rbxassetid://"..id
    sky.SkyboxDn = "rbxassetid://"..id
    sky.SkyboxFt = "rbxassetid://"..id
    sky.SkyboxLf = "rbxassetid://"..id
    sky.SkyboxRt = "rbxassetid://"..id
    sky.SkyboxUp = "rbxassetid://"..id
    sky.Parent = game.Lighting
end })

env_sec:AddInput('skybox_id', { Text = 'Custom Skybox ID', Default = '', Placeholder = 'ID', Callback = function(v) 
    flags['skybox_id'] = v
    if flags["skybox_preset"] == "custom" then 
        local p = flags["skybox_preset"]
        flags["skybox_preset"] = "default"
        flags["skybox_preset"] = p 
    end 
end })
env_sec:AddSlider('env_brightness', { Text = 'Brightness', Min = 0, Max = 5, Default = 2, Rounding = 1, Callback = function(v) flags['env_brightness'] = v; lighting.Brightness = v end })
env_sec:AddSlider('env_time', { Text = 'Time of Day', Min = 0, Max = 24, Default = 12, Rounding = 1, Callback = function(v) flags['env_time'] = v; lighting.ClockTime = v end })
env_sec:AddSlider('env_fogend', { Text = 'Fog End', Min = 0, Max = 100000, Default = 100000, Rounding = 0, Callback = function(v) flags['env_fogend'] = v; lighting.FogEnd = v end })
env_sec:AddSlider('env_fogstart', { Text = 'Fog Start', Min = 0, Max = 100000, Default = 0, Rounding = 0, Callback = function(v) flags['env_fogstart'] = v; lighting.FogStart = v end })
env_sec:AddLabel('Fog Color'):AddColorPicker('fog_color', { Default = rgb(128, 128, 128), Title = 'Fog Color', Transparency = 0, Callback = function(c) flags['fog_color'] = c; lighting.FogColor = c end })
env_sec:AddSlider('atm_density', { Text = 'Atmosphere Density', Min = 0, Max = 1, Default = 0.3, Rounding = 2, Callback = function(v) flags['atm_density'] = v; atmosphere.Density = v end })
env_sec:AddSlider('atm_glare', { Text = 'Atmosphere Glare', Min = 0, Max = 1, Default = 0, Rounding = 2, Callback = function(v) flags['atm_glare'] = v; atmosphere.Glare = v end })
env_sec:AddSlider('atm_haze', { Text = 'Atmosphere Haze', Min = 0, Max = 1, Default = 0, Rounding = 2, Callback = function(v) flags['atm_haze'] = v; atmosphere.Haze = v end })
env_sec:AddLabel('Atmosphere Color'):AddColorPicker('atm_color', { Default = rgb(199, 170, 107), Title = 'Atmosphere Color', Transparency = 0, Callback = function(c) flags['atm_color'] = c; atmosphere.Color = c end })
env_sec:AddLabel('Atmosphere Decay'):AddColorPicker('atm_decay', { Default = rgb(106, 112, 125), Title = 'Atmosphere Decay', Transparency = 0, Callback = function(c) flags['atm_decay'] = c; atmosphere.Decay = c end })

env_sec:AddSlider('saturation', { Text = 'Saturation', Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(v) flags['saturation'] = v; get_color_correction().Saturation = v end })
env_sec:AddSlider('cc_bright', { Text = 'Brightness CC', Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(v) flags['cc_bright'] = v; get_color_correction().Brightness = v end })
env_sec:AddSlider('cc_contrast', { Text = 'Contrast CC', Min = -1, Max = 1, Default = 0, Rounding = 2, Callback = function(v) flags['cc_contrast'] = v; get_color_correction().Contrast = v end })
env_sec:AddLabel('CC Tint'):AddColorPicker('cc_tint', { Default = rgb(255, 255, 255), Title = 'CC Tint', Transparency = 0, Callback = function(c) flags['cc_tint'] = c; get_color_correction().TintColor = c end })

local xhair_lns = {
    top = new_drawing("Line", {Thickness = 2, Visible = false, Color = crosshair_color}),
    bottom = new_drawing("Line", {Thickness = 2, Visible = false, Color = crosshair_color}),
    left = new_drawing("Line", {Thickness = 2, Visible = false, Color = crosshair_color}),
    right = new_drawing("Line", {Thickness = 2, Visible = false, Color = crosshair_color}),
    dot = new_drawing("Circle", {Radius = 2, Filled = true, Visible = false, Color = crosshair_color})
}

xhair_sec:AddToggle('xhair_on', { Text = 'Crosshair', Default = false, Callback = function(v) flags['xhair_on'] = v; if not v then for _, l in pairs(xhair_lns) do if l then l.Visible = false end end end end })
xhair_sec:AddSlider('xhair_size', { Text = 'Size', Min = 2, Max = 30, Default = 10, Rounding = 0, Suffix = 'px', Callback = function(v) flags['xhair_size'] = v end })
xhair_sec:AddSlider('xhair_gap', { Text = 'Gap', Min = 0, Max = 15, Default = 3, Rounding = 0, Suffix = 'px', Callback = function(v) flags['xhair_gap'] = v end })
xhair_sec:AddToggle('xhair_dot', { Text = 'Center Dot', Default = true, Callback = function(v) flags['xhair_dot'] = v end })
xhair_sec:AddLabel('Color'):AddColorPicker('xhair_color', { Default = crosshair_color, Title = 'Crosshair Color', Transparency = 0, Callback = function(c) flags['xhair_color'] = c; crosshair_color = c; for _, l in pairs(xhair_lns) do if l then l.Color = c end end end })

local weapon_main_section = weapon_tab:AddLeftGroupbox('weapon mods')
weapon_main_section:AddToggle('no_shoot_delay', { Text = 'No Shoot Delay', Default = false, Callback = function(v) flags['no_shoot_delay'] = v end })
weapon_main_section:AddToggle('no_spread', { Text = 'No Spread', Default = false, Callback = function(v) flags['no_spread'] = v end })
weapon_main_section:AddToggle('no_recoil', { Text = 'No Recoil', Default = false, Callback = function(v) flags['no_recoil'] = v end })
weapon_main_section:AddToggle('no_shake', { Text = 'No Camera Shake', Default = false, Callback = function(v) flags['no_shake'] = v end })
weapon_main_section:AddToggle('remove_gun_anim', { Text = 'Remove Gun Animations', Default = false, Callback = function(v) flags['remove_gun_anim'] = v end })
weapon_main_section:AddToggle('remove_aim_assist', { Text = 'Remove Game Aim Assist', Default = false, Callback = function(v)
    flags['remove_aim_assist'] = v
    pcall(function()
        if v then
            run_service:UnbindFromRenderStep("DeagleAimAssist")
        else
            local Settings = require(module_loader.UI.Menus.Settings)
            Settings.AimAssist = false
        end
    end)
end })
weapon_main_section:AddDropdown('game_aim_assist', { Text = 'Game Aim Assist', Values = {'Disabled', 'Enabled'}, Default = 'Disabled', Callback = function(v)
    flags['game_aim_assist'] = v
    pcall(function()
        local Settings = require(module_loader.UI.Menus.Settings)
        Settings.AimAssist = (v == "Enabled")
    end)
end })

local case_section = weapon_tab:AddRightGroupbox('cases')
case_section:AddDropdown('case_select', { Text = 'Select Case', Values = case_list, Default = case_list[1], Callback = function(v) flags['case_select'] = v end })
case_section:AddButton({ Text = 'Open Case', Func = function()
    pcall(function() network:InvokeServer("OpenCase", flags["case_select"]) end)
    pcall(function() network:FireServer("OpenCase", flags["case_select"]) end)
end })
case_section:AddToggle('auto_open_cases', { Text = 'Auto Open Cases', Default = false, Callback = function(v)
    flags['auto_open_cases'] = v
    if v then
        task.spawn(function()
            while flags["auto_open_cases"] do
                pcall(function() network:InvokeServer("OpenCase", flags["case_select"]) end)
                pcall(function() network:FireServer("OpenCase", flags["case_select"]) end)
                task.wait(1)
            end
        end)
    end
end })

local skin_section = skins_tab:AddLeftGroupbox('skin changer')
local skin_dropdown = skin_section:AddDropdown('deagle_skin', { Text = 'Deagle Skin', Values = deagle_skins_list, Default = 'Default Deagle', Callback = function(v) flags['deagle_skin'] = v end })
skin_section:AddInput('search_deagle_skin', { Text = 'Search Deagle Skin', Default = '', Placeholder = 'Search...', Callback = function(v)
    flags['search_deagle_skin'] = v
    local filtered = {}
    for _, item in ipairs(deagle_skins_list) do
        if string.find(string.lower(item), string.lower(v)) then
            table.insert(filtered, item)
        end
    end
    if skin_dropdown then skin_dropdown:SetValues(filtered) end
end })
skin_section:AddButton({ Text = 'Apply Deagle Skin', Func = function()
    local skin_name = flags["deagle_skin"]
    if skin_name and skin_name ~= "" then
        pcall(function() network:FireServer("EquipDeagleSkin", skin_name) end)
        pcall(function() network:FireServer("SetDeagleSkin", skin_name) end)
        pcall(function() network:FireServer("EquipSkin", skin_name) end)
        task.wait(0.5)
        local char = local_player.Character
        if char then
            local deagle = char:FindFirstChild("Deagle")
            if deagle then
                deagle:SetAttribute("DeagleSkinName", skin_name)
            end
        end
        task.wait(0.1)
        pcall(function() viewmodel_controller.SetDeagle(skin_name) end)
        notify("applied deagle: ".. skin_name)
    end
end })

local effect_dropdown = skin_section:AddDropdown('kill_effect', { Text = 'Kill Effect', Values = kill_effect_list, Default = 'Knock', Callback = function(v) flags['kill_effect'] = v end })
skin_section:AddInput('search_kill_effect', { Text = 'Search Kill Effect', Default = '', Placeholder = 'Search...', Callback = function(v)
    flags['search_kill_effect'] = v
    local filtered = {}
    for _, item in ipairs(kill_effect_list) do
        if string.find(string.lower(item), string.lower(v)) then
            table.insert(filtered, item)
        end
    end
    if effect_dropdown then effect_dropdown:SetValues(filtered) end
end })
skin_section:AddButton({ Text = 'Apply Kill Effect', Func = function()
    if network then
        pcall(function() network:FireServer("SetKillEffect", flags["kill_effect"]) end)
        pcall(function() local_player:SetAttribute("KillEffect", flags["kill_effect"]) end)
        notify("applied kill effect: ".. (flags["kill_effect"] or "Unknown"))
    end
end })

local misc_section = misc_tab:AddLeftGroupbox('local player')
local movement_section = misc_tab:AddLeftGroupbox('movement')
local radar_section = misc_tab:AddLeftGroupbox('radar')
local server_section = misc_tab:AddRightGroupbox('server')
local sound_section = misc_tab:AddRightGroupbox('sounds')

misc_section:AddToggle('anti_afk', { Text = 'Anti-AFK', Default = false, Callback = function(v) flags['anti_afk'] = v end })
misc_section:AddToggle('noclip_on', { Text = 'Noclip', Default = false, Callback = function(v) flags['noclip_on'] = v end })
misc_section:AddToggle('inf_jump', { Text = 'Infinite Jump', Default = false, Callback = function(v) flags['inf_jump'] = v end })
misc_section:AddToggle('hit_notifs', { Text = 'Hit Notifications', Default = false, Callback = function(v) flags['hit_notifs'] = v end })
misc_section:AddInput('hit_notif_msg', { Text = 'Hit Notif Message', Default = 'hit (target) for (hp) in the (part)!', Placeholder = 'hit (target) for (hp) in (part)', Callback = function(v) flags['hit_notif_msg'] = v end })

misc_section:AddToggle('auto_claim_rewards', { Text = 'Auto Claim Rewards', Default = false, Callback = function(v)
    flags['auto_claim_rewards'] = v
    if v then
        task.spawn(function()
            while flags["auto_claim_rewards"] do
                for i=1, 5 do pcall(function() network:FireServer("ClaimDailyReward", i) end) end
                for i=1, 20 do pcall(function() network:FireServer("ClaimTimeReward", i) end) end
                task.wait(5)
            end
        end)
    end
end })
misc_section:AddToggle('auto_claim_quests', { Text = 'Auto Claim Quests', Default = false, Callback = function(v)
    flags['auto_claim_quests'] = v
    if v then
        task.spawn(function()
            while flags["auto_claim_quests"] do
                for i=1, 5 do pcall(function() network:FireServer("ClaimDailyTask", i) end) end
                task.wait(5)
            end
        end)
    end
end })
misc_section:AddToggle('auto_claim_achievements', { Text = 'Auto Claim Achievements', Default = false, Callback = function(v)
    flags['auto_claim_achievements'] = v
    if v then
        task.spawn(function()
            while flags["auto_claim_achievements"] do
                for i=1, 50 do pcall(function() network:FireServer("ClaimAchievement", i) end) end
                task.wait(5)
            end
        end)
    end
end })

misc_section:AddToggle('auto_deploy', { Text = 'Auto Deploy', Default = false, Callback = function(v)
    flags['auto_deploy'] = v
    if v then
        task.spawn(function()
            while flags["auto_deploy"] do 
                if local_player:GetAttribute("InRound") == false then
                    pcall(function() round_controller.Spawn() end)
                    task.wait(1)
                else
                    task.wait(1)
                end
            end
        end)
    end
end })
misc_section:AddToggle('i_hate_the_leave_gui', { Text = 'Hide the Leave gui', Default = false, Callback = function(v)
    flags['i_hate_the_leave_gui'] = v
    if v then
        task.spawn(function()
            while task.wait(0.25) do
                local leavegui = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.LeavingGui
                if leavegui.Visible == true then
                    leavegui.Visible = false
                end
            end
        end)
    end
end })
misc_section:AddToggle('instant_respawn', { Text = 'Instant Respawn', Default = false, Callback = function(v)
    flags['instant_respawn'] = v
    if v then
        task.spawn(function()
            while flags["instant_respawn"] do
                local hum = gethum()
                if not hum or hum.Health <= 0 then
                    pcall(function() round_controller.Spawn() end)
                end
                task.wait(0.1)
            end
        end)
    end
end })
misc_section:AddToggle('third_person', { Text = 'Third Person', Default = false, Callback = function(v)
    flags['third_person'] = v
    if v then
        local_player.CameraMode = Enum.CameraMode.Classic
        local_player.CameraMaxZoomDistance = 128
    else
        if local_player:GetAttribute("InRound") == true then
            local_player.CameraMaxZoomDistance = 0
        else
            local_player.CameraMaxZoomDistance = 128
        end
    end
end })
misc_section:AddToggle('spin_on', { Text = 'Spin Bot', Default = false, Callback = function(v) flags['spin_on'] = v end })
misc_section:AddSlider('spin_speed', { Text = 'Spin Speed', Min = 10, Max = 10000, Default = 180, Rounding = 0, Suffix = ' deg/s', Callback = function(v) flags['spin_speed'] = v end })
misc_section:AddToggle('custom_fov_on', { Text = 'Custom FOV', Default = false, Callback = function(v) flags['custom_fov_on'] = v end })
misc_section:AddSlider('custom_fov_val', { Text = 'FOV Value', Min = 70, Max = 120, Default = 90, Rounding = 0, Callback = function(v) flags['custom_fov_val'] = v end })

movement_section:AddToggle('speed_onnn', { Text = 'Speed Hack', Default = false, Callback = function(v) flags['speed_onnn'] = v; apply_walkspeed(v, flags["walkspeed"] or 50) end })
movement_section:AddDropdown('speed_method', { Text = 'Speed Method', Values = {'WalkSpeed', 'CFrame', 'Velocity'}, Default = 'CFrame', Callback = function(v) flags['speed_method'] = v end })
movement_section:AddSlider('walkspeed', { Text = 'WalkSpeed', Min = 16, Max = 500, Default = 50, Rounding = 0, Suffix = ' ws', Callback = function(v) flags['walkspeed'] = v end })
movement_section:AddToggle('jump_on', { Text = 'Jump Hack', Default = false, Callback = function(v) flags['jump_on'] = v; apply_jumppower(v, flags["jump_power"] or 50) end })
movement_section:AddDropdown('jump_method', { Text = 'Jump Method', Values = {'JumpPower', 'Velocity'}, Default = 'JumpPower', Callback = function(v) flags['jump_method'] = v end })
movement_section:AddSlider('jump_power', { Text = 'JumpPower', Min = 50, Max = 500, Default = 50, Rounding = 0, Suffix = ' jp', Callback = function(v) flags['jump_power'] = v end })

radar_section:AddToggle('radar_on', { Text = 'Player Radar', Default = false, Callback = function(v) flags['radar_on'] = v; radar_gui.Enabled = v end })
radar_section:AddSlider('radar_size', { Text = 'Radar Size', Min = 50, Max = 500, Default = 150, Rounding = 0, Callback = function(v) flags['radar_size'] = v; radar_frame.Size = UDim2.new(0, v, 0, v) end })
radar_section:AddSlider('radar_range', { Text = 'Radar Range', Min = 100, Max = 2000, Default = 500, Rounding = 0, Suffix = ' st', Callback = function(v) flags['radar_range'] = v end })
radar_section:AddSlider('radar_x', { Text = 'Radar X', Min = 0, Max = 1920, Default = 15, Rounding = 0, Callback = function(v) flags['radar_x'] = v; radar_frame.Position = UDim2.new(0, v, 0, flags["radar_y"] or 15) end })
radar_section:AddSlider('radar_y', { Text = 'Radar Y', Min = 0, Max = 1080, Default = 15, Rounding = 0, Callback = function(v) flags['radar_y'] = v; radar_frame.Position = UDim2.new(0, flags["radar_x"] or 15, 0, v) end })
radar_section:AddLabel('Radar Color'):AddColorPicker('radar_color', { Default = radar_dot_color, Title = 'Radar Color', Transparency = 0, Callback = function(c) flags['radar_color'] = c; radar_dot_color = c end })

server_section:AddButton({ Text = 'Copy j*b ID', Func = function() pcall(function() setclipboard(game.JobId) end) end })
server_section:AddInput('jb_id_input', { Text = 'j*b ID', Default = '', Placeholder = 'Enter j*b Id', Callback = function(v) flags['jb_id_input'] = v end })
server_section:AddButton({ Text = 'Join Server', Func = function()
    local id = flags["jb_id_input"]
    if id and id ~= "" then
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, id, local_player)
        end)
    else
        notify("pls enter a valid j*b Id")
    end
end })
server_section:AddButton({ Text = 'Server hop', Func = function() game:GetService("TeleportService"):Teleport(game.PlaceId, local_player) end })

sound_section:AddToggle('custom_kill_sounds', { Text = 'Custom Kill Sounds', Default = false, Callback = function(v) flags['custom_kill_sounds'] = v end })
sound_section:AddDropdown('kill_sound_preset', { Text = 'Kill Sound Preset', Values = {"cod", "bubble pop", "jet set", "osu", "whip", "hint", "bubble pop 2", "coin flip", "custom"}, Default = 'cod', Callback = function(v) flags['kill_sound_preset'] = v end })
sound_section:AddInput('custom_kill_sound_id', { Text = 'Custom Kill Sound ID', Default = '', Placeholder = 'rbxassetid://', Callback = function(v) flags['custom_kill_sound_id'] = v end })

local ui_section = settings_tab:AddRightGroupbox('ui')

ui_section:AddToggle('ui_keybind_list', { Text = 'Keybind List', Default = false, Callback = function(v) flags['ui_keybind_list'] = v; lib.KeybindFrame.Visible = v end })
local menu_visible = true
ui_section:AddLabel('Menu Toggle'):AddKeyPicker('menu_key', { Default = 'RightShift', Mode = 'Toggle', Text = 'Menu Toggle', NoUI = true, Callback = function(v) menu_visible = v end })
lib.ToggleKeybind = Options.menu_key

local function unload_gui()
    if lib and type(lib.Unload) == "function" then lib:Unload()
    else if lib and lib.gui then lib.gui:Destroy() end; getgenv().lib = nil end
end

ui_section:AddButton({ Text = 'Unload', Func = function()
    disconnect_all()
    for char, _ in pairs(esp_objects) do destroy_esp(char) end
    if fov_circle then fov_circle:Remove() end
    for _, l in pairs(xhair_lns) do if l then l:Remove() end end
    radar_gui:Destroy()
    aura_part:Destroy()
    
    hookmetamethod(game, "__index", old_index)
    hookmetamethod(game, "__newindex", old_newindex)
    
    network.OnClientEvent = original_on_client_event
    network.FireServer = original_fire_server
    deagle_controller.Shoot = original_shoot
    viewmodel_controller.SetDeagle = original_set_deagle
    viewmodel_controller.OnShoot = original_vm_shoot
    camera_controller.Shoot = original_cam_shoot
    camera_controller.Land = original_cam_land
    mouse_module.GetMousePos = original_get_mouse_pos
    deagle_shared.Raycast = original_ray
    crosshair_controller.Reload = original_crosshair_reload
    effects_controller.SpawnBeam = original_spawn_beam
    
    apply_walkspeed(false)
    apply_jumppower(false)
    local_player.CameraMaxZoomDistance = 0.5

    unload_gui()
end })

connect(run_service.Heartbeat, function(dt)
    local hum = gethum()
    if hum then
        if walkspeed_enabled then
            local method = flags["speed_method"] or "WalkSpeed"
            local speed_val = flags["walkspeed"] or 50
            local is_walking = hum.MoveDirection.Magnitude > 0
            if is_walking then
                if method == "WalkSpeed" then
                    if hum.WalkSpeed ~= speed_val then hum.WalkSpeed = speed_val end
                elseif method == "CFrame" then
                    local root = getroot()
                    if root then
                        root.CFrame = root.CFrame + (hum.MoveDirection * speed_val * dt)
                    end
                elseif method == "Velocity" then
                    local root = getroot()
                    if root then
                        local vel = hum.MoveDirection * speed_val
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
        if jumppower_enabled then
            local method = flags["jump_method"] or "JumpPower"
            local jump_val = flags["jump_power"] or 50
            if method == "JumpPower" then
                if hum.JumpPower ~= jump_val then hum.JumpPower = jump_val end
            elseif method == "Velocity" then
                local root = getroot()
                if root and hum:GetState() == Enum.HumanoidStateType.Jumping then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, jump_val, root.AssemblyLinearVelocity.Z)
                end
            end
        end
    end
end)

connect(run_service.Stepped, function()
    if flags["noclip_on"] then
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

connect(run_service.Heartbeat, function()
    if flags["no_shoot_delay"] then
        deagle_controller.CanShoot = true
        deagle_controller.ShootCooldownUntil = 0
    end
end)

connect(input_service.JumpRequest, function()
    if flags["inf_jump"] and input_service:IsKeyDown(Enum.KeyCode.Space) then
        local hum = gethum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local trigger_cd = 0
local auto_shoot_cd = 0
connect(run_service.RenderStepped, function(dt)
    local mp = input_service:GetMouseLocation()
    local vp = camera.ViewportSize
    local esp_on = flags["esp_on"]
    local root_pos = getroot() and getroot().Position

    keybinds.aim = Options.aim_key and Options.aim_key:GetState() or false
    keybinds.trigger = Options.trigger_key and Options.trigger_key:GetState() or false

    local current_aim_target = get_aim_target()
    state.aim_target_player = current_aim_target
    state.aim_target_part = current_aim_target and current_aim_target:FindFirstChild(flags["aim_part"] or "Head") or nil

    if flags["silent_aim"] then
        current_target = get_silent_target()
    else
        current_target = nil
    end

    apply_viewmodel_chams()

    if flags["aim_on"] and keybinds.aim and state.aim_target_part then
        local smooth = flags["aim_smooth"] or 0.15
        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, state.aim_target_part.Position), smooth)
    end

    if flags["triggerbot"] and keybinds.trigger and state.aim_target_player and tick() - trigger_cd > 0.1 then
        mouse1press(); task.wait(0.02); mouse1release(); trigger_cd = tick()
    end

    if flags["auto_shoott"] and tick() - auto_shoot_cd > (flags["auto_shoot_delay"] or 0.05) then
        pcall(function() deagle_controller.Shoot() end)
        auto_shoot_cd = tick()
    end

    if flags["fov_visible"] and fov_circle then
        fov_circle.Visible = true
        fov_circle.Position = Vector2.new(mp.X, mp.Y)
        fov_circle.Color = fov_color
        fov_circle.Thickness = 1
        fov_circle.Radius = flags["aim_radius"] or 150
    else
        if fov_circle then fov_circle.Visible = false end
    end

    if flags["xhair_on"] then
        local cx, cy = vp.X / 2, vp.Y / 2
        local sz, gap, thk = flags["xhair_size"] or 10, flags["xhair_gap"] or 3, 2
        local col = crosshair_color
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
            xhair_lns.dot.Visible = flags["xhair_dot"] == true
            xhair_lns.dot.Position = Vector2.new(cx, cy)
            xhair_lns.dot.Color = col
        end
    else
        for _, l in pairs(xhair_lns) do if l then l.Visible = false end end
    end

    if flags["custom_fov_on"] then
        camera.FieldOfView = flags["custom_fov_val"] or 90
    end

    if flags["spin_on"] then
        local r = getroot()
        if r then
            r.CFrame = r.CFrame * CFrame.Angles(0, math.rad((flags["spin_speed"] or 180) * dt), 0)
        end
    end

    if flags["danger_indicators"] and root_pos then
        for _, char in ipairs(get_targets()) do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local h = char:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.Health > 0 then
                local dir_to_target = (hrp.Position - root_pos)
                local dist = dir_to_target.Magnitude
                if dist < 300 then
                    local rel_pos = camera.CFrame:VectorToObjectSpace(dir_to_target)
                    if rel_pos.Z < 0 then
                        local angle = math.atan2(rel_pos.X, -rel_pos.Y)
                        local radius = 200
                        local ex = vp.X/2 + math.cos(angle) * radius
                        local ey = vp.Y/2 + math.sin(angle) * radius
                        
                        if not danger_indicators[char] then
                            danger_indicators[char] = new_drawing("Text", {Size = 13, Center = true, Outline = true, Visible = false, Color = danger_color, Font = 2})
                        end
                        danger_indicators[char].Text = "!\n"..math.floor(dist).."m"
                        danger_indicators[char].Position = Vector2.new(ex, ey)
                        danger_indicators[char].Color = danger_color
                        danger_indicators[char].Visible = true
                    else
                        if danger_indicators[char] then danger_indicators[char].Visible = false end
                    end
                else
                    if danger_indicators[char] then danger_indicators[char].Visible = false end
                end
            else
                if danger_indicators[char] then danger_indicators[char]:Remove(); danger_indicators[char] = nil end
            end
        end
    else
        for char, d in pairs(danger_indicators) do d:Remove() end
        danger_indicators = {}
    end

    if flags["aura_vis"] and kill_aura_on then
        local char = getchar()
        if char then
            local p = char:FindFirstChild(flags["aura_vis_pos"] or "HumanoidRootPart")
            if p then
                aura_part.Color = aura_color
                aura_part.Transparency = flags["aura_vis_trans"] or 0.5
                aura_part.Material = Enum.Material[flags["aura_vis_mat"] or "Neon"]
                
                local range = flags["kill_aura_range"] or 50
                local thick = flags["aura_vis_thick"] or 0.1
                local offset = Vector3.new(flags["aura_vis_x"] or 0, flags["aura_vis_y"] or 0, 0)
                local cur_shape = flags["aura_vis_shape"] or "Circle"
                
                if cur_shape == "Cylinder" then
                    aura_mesh.Scale = Vector3.new(thick, range*2, range*2)
                    aura_part.CFrame = CFrame.new(p.Position + offset) * CFrame.Angles(0, 0, math.rad(90))
                else
                    aura_mesh.Scale = Vector3.new(range*2, range*2, range*2)
                    aura_part.CFrame = CFrame.new(p.Position + offset)
                end
                
                aura_part.Parent = workspace
            else
                aura_part.Parent = nil
            end
        else
            aura_part.Parent = nil
        end
    else
        aura_part.Parent = nil
    end

    for _, char in ipairs(get_targets()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (h and hrp) then continue end

        build_esp(char)
        local d = esp_objects[char]

        local function hide_all()
            if d.box then d.box.Visible = false end
            if d.nameText then d.nameText.Visible = false end
            if d.distText then d.distText.Visible = false end
            if d.hpBG then d.hpBG.Visible = false end
            if d.hpBar then d.hpBar.Visible = false end
            if d.tracer then d.tracer.Visible = false end
            for _, l in ipairs(d.corners) do if l then l.Visible = false end end
            for _, l in ipairs(d.skeleton) do if l then l.Visible = false end end
        end

        if not esp_on or h.Health <= 0 then hide_all(); continue end
        if root_pos and (hrp.Position - root_pos).Magnitude > (flags["esp_max_dist"] or 800) then hide_all(); continue end

        apply_chams(char)
        if flags["hitbox_on"] then expand_hitbox(char) end

        local sp, on_screen = camera:WorldToViewportPoint(hrp.Position)
        if sp.Z <= 0 then hide_all(); continue end

        local top_sp = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local bot_sp = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.8, 0))
        local box_h = math.abs(bot_sp.Y - top_sp.Y)
        local box_w = box_h * 0.55
        local bx, by = sp.X - box_w / 2, top_sp.Y
        local style = flags["box_style"] or "Corner Box"

        if flags["box_esp"] then
            if style == "Full Box" then
                for _, l in ipairs(d.corners) do if l then l.Visible = false end end
                if d.box then
                    d.box.Size = Vector2.new(box_w, box_h); d.box.Position = Vector2.new(bx, by)
                    d.box.Color = box_color; d.box.Visible = true
                end
            elseif style == "Corner Box" then
                if d.box then d.box.Visible = false end
                local cL = math.min(box_w, box_h) * 0.28
                local co = d.corners
                if co[1] then co[1].From, co[1].To = Vector2.new(bx, by), Vector2.new(bx + cL, by) end
                if co[2] then co[2].From, co[2].To = Vector2.new(bx, by), Vector2.new(bx, by + cL) end
                if co[3] then co[3].From, co[3].To = Vector2.new(bx + box_w, by), Vector2.new(bx + box_w - cL, by) end
                if co[4] then co[4].From, co[4].To = Vector2.new(bx + box_w, by), Vector2.new(bx + box_w, by + cL) end
                if co[5] then co[5].From, co[5].To = Vector2.new(bx, by + box_h), Vector2.new(bx + cL, by + box_h) end
                if co[6] then co[6].From, co[6].To = Vector2.new(bx, by + box_h), Vector2.new(bx, by + box_h - cL) end
                if co[7] then co[7].From, co[7].To = Vector2.new(bx + box_w, by + box_h), Vector2.new(bx + box_w - cL, by + box_h) end
                if co[8] then co[8].From, co[8].To = Vector2.new(bx + box_w, by + box_h), Vector2.new(bx + box_w, by + box_h - cL) end
                for _, l in ipairs(co) do if l then l.Color = box_color; l.Visible = true end end
            else
                if d.box then d.box.Visible = false end
                for _, l in ipairs(d.corners) do if l then l.Visible = false end end
            end
        else
            if d.box then d.box.Visible = false end
            for _, l in ipairs(d.corners) do if l then l.Visible = false end end
        end

        if flags["name_esp"] and d.nameText then
            local plr = players:GetPlayerFromCharacter(char)
            d.nameText.Text = plr and plr.Name or char.Name
            d.nameText.Position = Vector2.new(sp.X, by - 14)
            d.nameText.Color = name_color
            d.nameText.Visible = true
        else 
            if d.nameText then d.nameText.Visible = false end 
        end

        if flags["dist_esp"] and root_pos and d.distText then
            local dist = math.round((hrp.Position - root_pos).Magnitude)
            d.distText.Text = dist .. "m"
            d.distText.Position = Vector2.new(sp.X, by + box_h + 3)
            d.distText.Color = distance_color
            d.distText.Visible = true
        else 
            if d.distText then d.distText.Visible = false end 
        end

        if flags["hp_esp"] then
            local pct = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
            local hb_x, bar_h = bx - 6, box_h * pct
            if d.hpBG then
                d.hpBG.Size = Vector2.new(4, box_h); d.hpBG.Position = Vector2.new(hb_x, by); d.hpBG.Visible = true
            end
            if d.hpBar then
                d.hpBar.Size = Vector2.new(4, bar_h); d.hpBar.Position = Vector2.new(hb_x, by + box_h - bar_h)
                d.hpBar.Color = Color3.fromRGB(math.round((1 - pct) * 255), math.round(pct * 255), 0)
                d.hpBar.Visible = true
            end
        else
            if d.hpBG then d.hpBG.Visible = false end
            if d.hpBar then d.hpBar.Visible = false end
        end

        if flags["skel_esp"] then
            local rig_type = h.RigType.Name
            local pairs_to_use = rig_type == "R15" and skeleton_pairs or skeleton_pairs_r6
            for i, pair in ipairs(pairs_to_use) do
                local p1 = char:FindFirstChild(pair[1])
                local p2 = char:FindFirstChild(pair[2])
                local ln = d.skeleton[i]
                if p1 and p2 and ln then
                    local s1, on1 = camera:WorldToViewportPoint(p1.Position)
                    local s2, on2 = camera:WorldToViewportPoint(p2.Position)
                    if on1 and on2 then
                        ln.From = Vector2.new(s1.X, s1.Y); ln.To = Vector2.new(s2.X, s2.Y)
                        ln.Color = skeleton_color; ln.Visible = true
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

        if flags["tracers_on"] and d.tracer then
            local origin = flags["tracer_origin"] or "Mouse"
            local from_x = origin == "Mouse" and mp.X or vp.X / 2
            local from_y = origin == "Mouse" and mp.Y or vp.Y
            
            local dest = flags["tracer_dest"] or "Head"
            local dest_part = char:FindFirstChild(dest) or hrp
            local dest_sp = camera:WorldToViewportPoint(dest_part.Position)
            
            d.tracer.From = Vector2.new(from_x, from_y); d.tracer.To = Vector2.new(dest_sp.X, dest_sp.Y)
            d.tracer.Color = tracer_color; d.tracer.Thickness = flags["tracer_thick"] or 1; d.tracer.Visible = true
        else 
            if d.tracer then d.tracer.Visible = false end 
        end
    end
end)

connect(run_service.Heartbeat, function()
    local root_pos = getroot() and getroot().Position
    if flags["radar_on"] and root_pos then
        for _, char in ipairs(get_targets()) do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local h = char:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.Health > 0 then
                local rel_pos = camera.CFrame:PointToObjectSpace(hrp.Position)
                local dist = (hrp.Position - root_pos).Magnitude
                if dist < (flags["radar_range"] or 500) then
                    if not radar_dots[char] then
                        radar_dots[char] = Instance.new("Frame", radar_frame)
                        radar_dots[char].Size = UDim2.new(0, 4, 0, 4)
                        radar_dots[char].BorderColor3 = Color3.new(0, 0, 0)
                        Instance.new("UICorner", radar_dots[char]).CornerRadius = UDim.new(1, 0)
                    end
                    radar_dots[char].BackgroundColor3 = radar_dot_color
                    local scale = (flags["radar_size"] or 150) / 2
                    radar_dots[char].Position = UDim2.new(0.5, rel_pos.X / (flags["radar_range"] or 500) * scale, 0.5, rel_pos.Z / (flags["radar_range"] or 500) * scale)
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

connect(run_service.Heartbeat, function()
    for char, _ in pairs(esp_objects) do
        if not char.Parent or not char:IsDescendantOf(workspace) or not char:FindFirstChild("Humanoid") or char:FindFirstChildOfClass("Humanoid").Health <= 0 then
            destroy_esp(char)
        end
    end
end)

connect(local_player.Idled, function()
    if flags["anti_afk"] then
        if virtual_input_manager then 
            virtual_input_manager:SendKeyEvent(true, Enum.KeyCode.ButtonB, false, game)
            virtual_input_manager:SendKeyEvent(false, Enum.KeyCode.ButtonB, false, game) 
        end
    end
end)

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

    lib:SetWatermark(('lunar x | %s fps'):format(math.floor(fps)))
end)

task.spawn(function()
    task.wait(1)
    if isfile(lib.directory .. "/silentload.cfg") then
        lib.Toggle()
        flags["silent_load"] = true
    end
end)

SaveManager:SetLibrary(lib)
SaveManager:SetFolder('LunarX/deagle-arena')
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'menu_key' })
SaveManager:BuildConfigSection(settings_tab)

ThemeManager:SetLibrary(lib)
ThemeManager:SetFolder('LunarX/deagle-arena')
ThemeManager:ApplyToTab(settings_tab)

SaveManager:LoadAutoloadConfig()

aim_tab:ShowTab()
