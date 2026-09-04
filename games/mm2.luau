--[[
    Lunar X
    Copyright (c) 2026 nick (.weound)
    Licensed under the Non-Commercial Share-Alike License (see LICENSE in the repo root).
--]]

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/weound/lx/main/ui/fware/library.luau"))()

local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local run = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local ws = workspace
local plr = players.LocalPlayer
local mouse = plr:GetMouse()
local cam = ws.CurrentCamera
local ts = game:GetService("TweenService")
local hs = game:GetService("HttpService")
local tps = game:GetService("TeleportService")
local setclipboard = setclipboard or function() end
local gethui = gethui or function() return game:GetService("CoreGui") end

local w = library:window({ 
    title = "lunar x", 
    subtitle = " - mm2", 
    size = UDim2.new(0, 650, 0, 450),
    icon = "moon",
    changelog_url = "https://raw.githubusercontent.com/weound/lx/main/changelogs/mm2.md",
    discord_link = "discord.gg/n6SzrKpVnU",
    script_url = "https://raw.githubusercontent.com/weound/lx/main/games/mm2.luau"
})

local t1 = w:tab({ name = "combat", icon = "swords", search = true })
local t2 = w:tab({ name = "visuals", icon = "eye", search = true })
local t3 = w:tab({ name = "player", icon = "user", search = true })
local t5 = w:tab({ name = "gun", icon = "zap", search = true })
local t6 = w:tab({ name = "misc", icon = "box", search = true })

local is_tp = false
local function tp_to(cframe)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        is_tp = true
        plr.Character.HumanoidRootPart.CFrame = cframe
        task.wait(0.05)
        is_tp = false
    end
end

local get_data = rs.Remotes.Gameplay.GetCurrentPlayerData
local player_data = get_data:InvokeServer() or {}
rs.Remotes.Gameplay.PlayerDataChanged.OnClientEvent:Connect(function(data)
    player_data = data or {}
end)

local function getrole(p)
    if not p or not p.Character then return "dead" end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return "dead" end
    
    if not next(player_data) then return "dead" end
    
    local p_data = player_data[p.Name]
    if not p_data then return "dead" end
    if p_data.Dead then return "dead" end
    
    local role = p_data.Role:lower()
    if role == "innocent" or role == "murderer" or role == "sheriff" or role == "hero" then
        return role
    end
    
    return "innocent"
end

local function getmurderer()
    for name, data in pairs(player_data) do
        if data.Role == "Murderer" and not data.Dead then
            return players:FindFirstChild(name)
        end
    end
end

local function getsheriff()
    for name, data in pairs(player_data) do
        if data.Role == "Sheriff" and not data.Dead then
            return players:FindFirstChild(name)
        end
    end

    return nil
end

local function getmap()
   local map = nil
   for _, child in ws:GetChildren() do
      if child:GetAttribute("MapID") then
         map = child
         break
      end
   end
   return map
end

local function getcontainer()
   local map = getmap()
   if not map then return end
   return map:FindFirstChild("CoinContainer")
end

local function get_r6_r15_parts()
    local char = plr.Character
    if not char then return {} end
    if char:FindFirstChild("Torso") then
        return {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}
    else
        return {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}
    end
end

local aim_target_mode = "closest"
local shoot_at_part = "Head"
local aim_pos = nil
local aim_target_part = nil

local function get_silent_aim_pos()
    local target = nil
    if aim_target_mode == "closest" then
        local mp = uis:GetMouseLocation()
        local closest_dist = math.huge
        for _, v in pairs(players:GetPlayers()) do
            local char = v.Character
            if v ~= plr and char then
                local h = char:FindFirstChildOfClass("Humanoid")
                local p_data = player_data[v.Name]
                if h and h.Health > 0 and p_data and not p_data.Dead then
                    local part = char:FindFirstChild(shoot_at_part) or char:FindFirstChild("HumanoidRootPart")
                    if part then
                        local sp, on_screen = cam:WorldToViewportPoint(part.Position)
                        if on_screen then
                            local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                            if d < closest_dist then closest_dist = d; target = part end
                        end
                    end
                end
            end
        end
    elseif aim_target_mode == "murderer" then
        local m = getmurderer()
        if m and m.Character then
            target = m.Character:FindFirstChild(shoot_at_part) or m.Character:FindFirstChild("HumanoidRootPart")
        end
    elseif aim_target_mode == "sheriff" then
        local s = getsheriff()
        if s and s.Character then
            target = s.Character:FindFirstChild(shoot_at_part) or s.Character:FindFirstChild("HumanoidRootPart")
        end
    elseif aim_target_mode == "random" then
        local p_list = {}
        for _, v in pairs(players:GetPlayers()) do
            local char = v.Character
            if v ~= plr and char then
                local h = char:FindFirstChildOfClass("Humanoid")
                local p_data = player_data[v.Name]
                if h and h.Health > 0 and p_data and not p_data.Dead then
                    table.insert(p_list, char:FindFirstChild(shoot_at_part) or char:FindFirstChild("HumanoidRootPart"))
                end
            end
        end
        if #p_list > 0 then target = p_list[math.random(1, #p_list)] end
    end
    aim_target_part = target
    return target and target.Position or nil
end

local silent_aim = false
task.spawn(function()
    while true do
        if silent_aim then
            aim_pos = get_silent_aim_pos()
        else
            aim_pos = nil
            aim_target_part = nil
        end
        task.wait(0.001)
    end
end)

local mt = getrawmetatable(game)
local old_nc = mt.__namecall
if setreadonly then setreadonly(mt, false) end

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and silent_aim and aim_pos then
        if method == "FireServer" and (self.Name == "Shoot" or self.Name == "Throw") then
            if typeof(args[2]) == "Vector3" then
                args[2] = aim_pos
            elseif typeof(args[2]) == "CFrame" then
                args[2] = CFrame.new(aim_pos)
            end
        elseif method == "InvokeServer" and self.Name == "ShootGun" then
            if typeof(args[2]) == "Vector3" then
                args[2] = aim_pos
            elseif typeof(args[2]) == "CFrame" then
                args[2] = CFrame.new(aim_pos)
            end
        end
    end
    return old_nc(self, unpack(args))
end)

if setreadonly then setreadonly(mt, true) end

local s1 = t1:section({ name = "aimbot" })
library.toggle(s1, { name = "silent aim", default = false, keybind = true, default_key = Enum.KeyCode.G, callback = function(v) silent_aim = v end })
library.dropdown(s1, { name = "target", options = {"closest", "murderer", "sheriff", "random"}, default = "closest", callback = function(v) aim_target_mode = v end })
library.dropdown(s1, { name = "shoot at", options = get_r6_r15_parts(), default = "Head", callback = function(v) shoot_at_part = v end })

local kill_all_delay = 0.05
library.slider(s1, { name = "kill all delay", min = 0.01, max = 0.05, default = 0.05, callback = function(v) kill_all_delay = v end })

local function killall()
    local p = players.LocalPlayer
    if not p then return end
    local char = p.Character
    if not char then return end
    local knife = char:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
    if not knife then return end
    local events = knife:FindFirstChild("Events")
    if not events then return end 
    local handletouched = events:FindFirstChild("HandleTouched")
    if not handletouched then return end
    for i,v in pairs(players:GetPlayers()) do
        if v and v.Character then    
            local primary = v.Character:FindFirstChild("HumanoidRootPart")
            if not primary then continue end   
            handletouched:FireServer(primary)
            task.wait(kill_all_delay)
        end
    end
end

local auto_equip_knife = false
local function kill_user(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = plr.Character
    if not char then return end
    local knife = char:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife")
    if not knife then return end
    if auto_equip_knife and knife.Parent == plr.Backpack then
        knife.Parent = char
        task.wait(0.01)
    end
    if knife.Parent == char and knife:FindFirstChild("Handle") then
        knife:Activate()
        firetouchinterest(target.Character.HumanoidRootPart, knife.Handle, false)
        task.wait(0.01)
        firetouchinterest(target.Character.HumanoidRootPart, knife.Handle, true)
    end
end

local function notify_roles(type)
    local m = getmurderer()
    if m then
        local img, _ = players:GetUserThumbnailAsync(m.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        if type == "roblox" then
            game.StarterGui:SetCore("SendNotification", { Title = "murd", Text = m.Name, Icon = img, Duration = 5 })
        else
            library:notification({ text = "murd: " .. m.Name })
        end
    end
    local s = getsheriff()
    if s then
        local img, _ = players:GetUserThumbnailAsync(s.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        if type == "roblox" then
            game.StarterGui:SetCore("SendNotification", { Title = "sheriff", Text = s.Name, Icon = img, Duration = 5 })
        else
            library:notification({ text = "sheriff: " .. s.Name })
        end
    end
end

local notif_type = "roblox"
library.dropdown(s1, { name = "notification type", options = {"roblox", "ui"}, default = "roblox", callback = function(v) notif_type = v end })
library.button(s1, { name = "notify roles", callback = function() notify_roles(notif_type) end })

local auto_notify = false
local last_murd = nil
run.Heartbeat:Connect(function()
    if auto_notify then
        local m = getmurderer()
        if m ~= last_murd and m then
            last_murd = m
            notify_roles(notif_type)
        elseif m == nil then
            last_murd = nil
        end
    end
end)
library.toggle(s1, { name = "auto notify roles", default = false, callback = function(v) auto_notify = v end })

local function killm()
    local m = getmurderer()
    local char = plr.Character
    if not char then return end
    local gun = char:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun")
    if not gun then return end
    if m and m.Character and m.Character:FindFirstChild("Head") and char and char:FindFirstChild("HumanoidRootPart") then
        local orig = char.HumanoidRootPart.CFrame
        char.HumanoidRootPart.CFrame = m.Character.Head.CFrame * CFrame.new(0, 0, 3)
        run.Heartbeat:Wait()
        gun.Parent = char
        gun:Activate()
        run.Heartbeat:Wait()
        char.HumanoidRootPart.CFrame = orig
    end
end

local function kills()
    local s = getsheriff()
    local char = plr.Character
    if not char then return end
    local knife = char:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife")
    if not knife then return end
    if s and s.Character and s.Character:FindFirstChild("Head") and char and char:FindFirstChild("HumanoidRootPart") then
        local orig = char.HumanoidRootPart.CFrame
        char.HumanoidRootPart.CFrame = s.Character.Head.CFrame * CFrame.new(0, 0, 3)
        run.Heartbeat:Wait()
        if auto_equip_knife and knife.Parent == plr.Backpack then
            knife.Parent = char
            task.wait(0.01)
        end
        if knife.Parent == char and knife:FindFirstChild("Handle") then
            knife:Activate()
            firetouchinterest(s.Character.HumanoidRootPart, knife.Handle, false)
            task.wait(0.01)
            firetouchinterest(s.Character.HumanoidRootPart, knife.Handle, true)
        end
        run.Heartbeat:Wait()
        char.HumanoidRootPart.CFrame = orig
    end
end

library.button(s1, { name = "kill murderer", keybind = true, default_key = Enum.KeyCode.K, callback = killm })
library.button(s1, { name = "kill sheriff", keybind = true, default_key = Enum.KeyCode.L, callback = kills })
library.button(s1, { name = "kill all", keybind = true, default_key = Enum.KeyCode.J, callback = killall })
library.toggle(s1, { name = "auto equip knife", default = false, callback = function(v) auto_equip_knife = v end })

local s2 = t2:section({ name = "esp" })
local esp_on = false
local esp_boxes = {}
local excluded_roles = {}
local tracers = {}
local names = {}

local function get_esp_color(r)
    if r == "dead" then return Color3.new(0.5, 0.5, 0.5) end
    if r == "murderer" then return Color3.new(1, 0, 0) end
    if r == "sheriff" then return Color3.new(0, 0, 1) end
    if r == "hero" then return Color3.new(1, 0.6, 0) end
    return Color3.new(0, 1, 0)
end

local function clear_all_esp()
    for p, boxes in pairs(esp_boxes) do
        for _, b in pairs(boxes) do if b then b:Destroy() end end
    end
    esp_boxes = {}
    for p, l in pairs(tracers) do if l then l.Visible = false end end
    for p, t in pairs(names) do if t then t.Visible = false end end
end

local function upd_esp()
    if not esp_on then clear_all_esp(); return end
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr and p.Character then
            local r = getrole(p)
            if not excluded_roles[r] then
                local c = get_esp_color(r)
                if not esp_boxes[p] then esp_boxes[p] = {} end
                for _, part in pairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        if not esp_boxes[p][part] then
                            local b = Instance.new("BoxHandleAdornment")
                            b.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
                            b.Adornee = part
                            b.AlwaysOnTop = true
                            b.ZIndex = 5
                            b.Transparency = 0.7
                            b.Color3 = c
                            b.Parent = part
                            esp_boxes[p][part] = b
                        else
                            esp_boxes[p][part].Color3 = c
                        end
                    end
                end
            else
                if esp_boxes[p] then
                    for _, b in pairs(esp_boxes[p]) do b:Destroy() end
                    esp_boxes[p] = nil
                end
            end
        end
    end
end
run.Heartbeat:Connect(upd_esp)
library.toggle(s2, { name = "role esp", default = false, callback = function(v) esp_on = v; upd_esp() end })
library.dropdown(s2, { name = "exclude roles", options = {"dead", "innocent", "murderer", "sheriff", "hero"}, default = {}, multiple = true, callback = function(v)
    excluded_roles = {}
    for _, role in pairs(v) do
        excluded_roles[role] = true
    end
end })
players.PlayerRemoving:Connect(function(p)
    if esp_boxes[p] then
        for _, b in pairs(esp_boxes[p]) do b:Destroy() end
        esp_boxes[p] = nil
    end
    if tracers[p] then tracers[p]:Remove(); tracers[p] = nil end
    if names[p] then names[p]:Remove(); names[p] = nil end
end)

local coinesp = false
local function toggle_coin_chams(v)
    coinesp = v
    task.spawn(function()
        while coinesp do
            local m = getmap()
            
            if m then
                local c = getcontainer()
                if c then
                    for _, child in pairs(c:GetChildren()) do
                        if child:GetAttribute("CoinID") then
                            if child.CoinVisual.MainCoin.Transparency ~= 0 then end
                            local visual = child:FindFirstChild("CoinVisual")
                            if visual then
                                if child:FindFirstChild("TouchInterest") then
                                    if not visual:FindFirstChild("cham") then
                                        local b = Instance.new("BoxHandleAdornment")
                                        b.Name = "cham"
                                        b.Adornee = visual
                                        b.Size = visual.Size
                                        b.Color3 = Color3.new(1, 1, 0)
                                        b.AlwaysOnTop = true
                                        b.ZIndex = 10
                                        b.Transparency = 0.7
                                        b.Parent = visual
                                    end
                                else
                                    if visual:FindFirstChild("cham") then
                                        visual.cham:Destroy()
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
        for _, d in pairs(ws:GetDescendants()) do
            if d.Name == "cham" then d:Destroy() end
        end
    end)
end

library.toggle(s2, { name = "coin chams", default = false, callback = function(v) 
    toggle_coin_chams(v)
end})

local gunc = false
local gun_text = Drawing.new("Text")
gun_text.Visible = false
gun_text.Center = true
gun_text.Outline = true
gun_text.Font = 2
gun_text.Color = get_esp_color("sheriff")
gun_text.Text = "gun"
gun_text.Size = 14

run.RenderStepped:Connect(function()
    if gunc then
        local g = ws:FindFirstChild("GunDrop", true)
        if g then
            local pos, on = cam:WorldToViewportPoint(g.Position)
            if on then
                gun_text.Position = Vector2.new(pos.X, pos.Y - 25)
                gun_text.Visible = true
            else
                gun_text.Visible = false
            end
            if not g:FindFirstChild("gcham") then
                local b = Instance.new("BoxHandleAdornment")
                b.Name = "gcham"
                b.Adornee = g
                b.Size = g.Size
                b.Color3 = get_esp_color("sheriff")
                b.AlwaysOnTop = true
                b.ZIndex = 10
                b.Transparency = 0.7
                b.Parent = g
            end
        else
            gun_text.Visible = false
        end
    else
        gun_text.Visible = false
    end
end)
library.toggle(s2, { name = "gun cham", default = false, callback = function(v) 
    gunc = v
    if not v then
        local g = ws:FindFirstChild("GunDrop", true)
        if g and g:FindFirstChild("gcham") then g.gcham:Destroy() end
    end
end })

local tracers_on = false
run.RenderStepped:Connect(function()
    if not tracers_on then
        for p, l in pairs(tracers) do l.Visible = false end
        return
    end
    local mpos = uis:GetMouseLocation()
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local r = getrole(p)
            if not excluded_roles[r] then
                local pos, on = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if on then
                    if not tracers[p] then
                        tracers[p] = Drawing.new("Line")
                        tracers[p].Thickness = 1.5
                        tracers[p].Transparency = 1
                    end
                    tracers[p].From = Vector2.new(mpos.X, mpos.Y)
                    tracers[p].To = Vector2.new(pos.X, pos.Y)
                    tracers[p].Color = get_esp_color(r)
                    tracers[p].Visible = true
                else
                    if tracers[p] then tracers[p].Visible = false end
                end
            else
                if tracers[p] then tracers[p].Visible = false end
            end
        else
            if tracers[p] then tracers[p].Visible = false end
        end
    end
end)
library.toggle(s2, { name = "tracers", default = false, callback = function(v) tracers_on = v end })

local namesp = false
run.RenderStepped:Connect(function()
    if not namesp then
        for p, t in pairs(names) do t.Visible = false end
        return
    end
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
            local r = getrole(p)
            if not excluded_roles[r] then
                local pos, on = cam:WorldToViewportPoint(p.Character.Head.Position)
                if on and pos.Z > 0 then
                    if not names[p] then
                        names[p] = Drawing.new("Text")
                        names[p].Size = 14
                        names[p].Center = true
                        names[p].Outline = true
                        names[p].Font = 2
                    end
                    names[p].Text = p.Name
                    names[p].Color = get_esp_color(r)
                    names[p].Position = Vector2.new(pos.X, pos.Y - 40)
                    names[p].Visible = true
                else
                    if names[p] then names[p].Visible = false end
                end
            else
                if names[p] then names[p].Visible = false end
            end
        else
            if names[p] then names[p].Visible = false end
        end
    end
end)
library.toggle(s2, { name = "name esp", default = false, callback = function(v) namesp = v end })
local perk_esp_on = false
local perk_drawings = {}

local function clear_perk_esp()
    for p, draw in pairs(perk_drawings) do
        if draw then draw.Visible = false end
    end
end

run.RenderStepped:Connect(function()
    if not perk_esp_on then 
        clear_perk_esp() 
        return 
    end
    
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr then
            if not perk_drawings[p] then
                perk_drawings[p] = Drawing.new("Text")
                perk_drawings[p].Size = 13
                perk_drawings[p].Center = true
                perk_drawings[p].Outline = true
                perk_drawings[p].Font = 2
            end
            
            local draw = perk_drawings[p]
            local p_data = player_data[p.Name]
            
            if p_data and p_data.Perk and p_data.Perk ~= "None" and p_data.Role == "Murderer" and not p_data.Dead then
                local char = p.Character
                if char and char:FindFirstChild("Head") then
                    local head = char.Head
                    local pos, on = cam:WorldToViewportPoint(head.Position)
                    if on and pos.Z > 0 then
                        draw.Text = p_data.Perk
                        draw.Color = Color3.new(1, 0.5, 0)
                        draw.Position = Vector2.new(pos.X, pos.Y - 20)
                        draw.Visible = true
                    else
                        draw.Visible = false
                    end
                else
                    draw.Visible = false
                end
            else
                draw.Visible = false
            end
        end
    end
end)

players.PlayerRemoving:Connect(function(p)
    if perk_drawings[p] then
        perk_drawings[p]:Remove()
        perk_drawings[p] = nil
    end
end)

library.toggle(s2, { name = "perk esp", default = false, callback = function(v) perk_esp_on = v end })
local xray = false
local orig_trans = {}
local xray_conn

local function set_trans(part)
    if typeof(part) == "Instance" and part:IsA("BasePart") and not part:IsDescendantOf(plr.Character) then
        if orig_trans[part] == nil then
            orig_trans[part] = part.Transparency
        end
        part.Transparency = 0.5
    end
end

library.toggle(s2, { name = "x-ray", default = false, callback = function(v)
    xray = v
    if xray then
        for _, d in pairs(ws:GetDescendants()) do 
            set_trans(d) 
        end
        xray_conn = ws.DescendantAdded:Connect(function(d)
            if xray then set_trans(d) end
        end)
    else
        if xray_conn then 
            xray_conn:Disconnect() 
            xray_conn = nil
        end
        for part, t in pairs(orig_trans) do
            if part and part.Parent then 
                part.Transparency = t 
            end
        end
        orig_trans = {}
    end
end })

local role_gui = Instance.new("ScreenGui")
role_gui.Name = "role_gui"
role_gui.ResetOnSpawn = false
role_gui.IgnoreGuiInset = true
pcall(function() role_gui.Parent = gethui() end)
if not role_gui.Parent then role_gui.Parent = game:GetService("CoreGui") end

local role_label = Instance.new("TextLabel", role_gui)
role_label.Size = UDim2.new(0, 200, 0, 50)
role_label.Position = UDim2.new(0.5, -100, 1, -150)
role_label.BackgroundTransparency = 1
role_label.Font = Enum.Font.GothamBold
role_label.Text = ""
role_label.TextColor3 = Color3.new(1, 1, 1)
role_label.TextScaled = true
role_label.Visible = false

local role_label_on = false
library.toggle(s2, { name = "role label", default = false, callback = function(v) role_label_on = v end })

local mgui = plr.PlayerGui:FindFirstChild("MainGUI")
if not mgui:FindFirstChild("Game") then library:notification({ name = "re-execute the script cuz theres no game ui (u prob executed too soon)", duration = 5 }); return end
local gameui = mgui:FindFirstChild("Game")
run.Heartbeat:Connect(function()
    if not role_label_on then
        role_label.Visible = false
        return
    end
    local role_selector = gameui:FindFirstChild("RoleSelector")
    if role_selector and role_selector.Visible then
        local r = getrole(plr)
        if r ~= "dead" then
            role_label.Text = r
            role_label.TextColor3 = get_esp_color(r)
            role_label.Visible = true
        else
            role_label.Visible = false
        end
    else
        role_label.Visible = false
    end
end)

local temu_trail_on = false
local trail_color = Color3.fromRGB(255, 170, 0)
local function setup_trail(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    local a0 = Instance.new("Attachment", hrp)
    a0.Position = Vector3.new(0, 0, 1)
    local a1 = Instance.new("Attachment", hrp)
    a1.Position = Vector3.new(0, 0, -1)
    local t = Instance.new("Trail")
    t.Attachment0 = a0
    t.Attachment1 = a1
    t.Lifetime = 0.5
    t.Color = ColorSequence.new(trail_color)
    t.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    t.Enabled = temu_trail_on
    t.Parent = hrp
end
if plr.Character then setup_trail(plr.Character) end
plr.CharacterAdded:Connect(setup_trail)
library.toggle(s2, { name = "temu sprint trail", default = false, callback = function(v)
    temu_trail_on = v
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local trail = plr.Character.HumanoidRootPart:FindFirstChildOfClass("Trail")
        if trail then
            trail.Enabled = v
            trail.Color = ColorSequence.new(trail_color)
        end
    end
end })
library.colorpicker(s2, { name = "trail color", default = trail_color, callback = function(c) 
    trail_color = c
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local trail = plr.Character.HumanoidRootPart:FindFirstChildOfClass("Trail")
        if trail then trail.Color = ColorSequence.new(c) end
    end
end })

local knife_vis = false

run.RenderStepped:Connect(function()
    if knife_vis then
        for _, c in pairs(ws:GetChildren()) do
            if c.Name == "ThrowingKnife" and c:IsA("Model") then
                local box_part = c:FindFirstChild("knife_box")
                if not box_part then
                    box_part = Instance.new("Part")
                    box_part.Name = "knife_box"
                    box_part.Size = Vector3.new(1, 1, 1)
                    box_part.Transparency = 1
                    box_part.CanCollide = false
                    box_part.CanQuery = false
                    box_part.Anchored = true
                    box_part.Parent = c
                    
                    local adorn = Instance.new("BoxHandleAdornment")
                    adorn.Name = "box_adorn"
                    adorn.Adornee = box_part
                    adorn.Size = box_part.Size
                    adorn.AlwaysOnTop = true
                    adorn.ZIndex = 10
                    adorn.Transparency = 0.5
                    adorn.Color3 = Color3.new(1, 0, 0)
                    adorn.Parent = box_part
                end
                box_part.CFrame = c:GetPivot()
            end
        end
    else
        for _, c in pairs(ws:GetChildren()) do
            if c.Name == "ThrowingKnife" and c:IsA("Model") then
                local box_part = c:FindFirstChild("knife_box")
                if box_part then box_part:Destroy() end
            end
        end
    end
end)

library.toggle(s2, { name = "knife visualizer", default = false, callback = function(v) knife_vis = v end })

local bullet_tracers_on = false
local bullet_tracer_fade = 3
local GunFired = rs.ClientServices.WeaponService.GunFired

GunFired.OnClientEvent:Connect(function(shooter, originPos, targetPos, hitPart)
    if not bullet_tracers_on then return end
    local distance = (originPos - targetPos).Magnitude
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.new(1, 0.5, 0)
    part.Transparency = 0.5
    part.Size = Vector3.new(0.2, 0.2, distance)
    part.CFrame = CFrame.lookAt(originPos, targetPos) * CFrame.new(0, 0, -distance/2)
    part.Parent = ws
    
    local adorn = Instance.new("BoxHandleAdornment")
    adorn.Adornee = part
    adorn.Size = part.Size
    adorn.AlwaysOnTop = true
    adorn.ZIndex = 10
    adorn.Transparency = 0.5
    adorn.Color3 = Color3.new(1, 0.5, 0)
    adorn.Parent = part
    
    local tween = ts:Create(part, TweenInfo.new(bullet_tracer_fade), {Transparency = 1, Size = Vector3.new(0, 0, distance)})
    tween:Play()
    
    local adorn_tween = ts:Create(adorn, TweenInfo.new(bullet_tracer_fade), {Transparency = 1})
    adorn_tween:Play()
    
    tween.Completed:Connect(function()
        part:Destroy()
        adorn:Destroy()
    end)
end)

library.toggle(s2, { name = "bullet tracers", default = false, callback = function(v) bullet_tracers_on = v end })
library.slider(s2, { name = "tracer fade", min = 0.1, max = 5, default = 3, callback = function(v) bullet_tracer_fade = v end })

local s3 = t3:section({ name = "player" })
local plyr_sel = "All"
local function get_plr_list()
    local l = {"All"}
    for _, v in pairs(players:GetPlayers()) do
        if v ~= plr then table.insert(l, v.Name) end
    end
    return l
end
local dd1 = library.dropdown(s3, { name = "player", options = get_plr_list(), default = "All", callback = function(v) plyr_sel = v end })
players.PlayerAdded:Connect(function() dd1:refresh(get_plr_list()) end)
players.PlayerRemoving:Connect(function() dd1:refresh(get_plr_list()) end)

local function get_targets()
    if plyr_sel == "All" or not plyr_sel then
        local t = {}
        for _, v in pairs(players:GetPlayers()) do
            if v ~= plr then table.insert(t, v) end
        end
        return t
    else
        local t = players:FindFirstChild(plyr_sel)
        return t and {t} or {}
    end
end

local ltp = false
library.toggle(s3, { name = "loop tp", default = false, callback = function(v) 
    ltp = v
    task.spawn(function()
        while ltp do
            for _, t in pairs(get_targets()) do
                if t.Character and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    tp_to(t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                end
            end
            task.wait(0.1)
        end
    end)
end })

local spec = false
library.toggle(s3, { name = "spectate", default = false, callback = function(v) 
    spec = v
    if spec then
        local t = get_targets()[1]
        if t and t.Character and t.Character:FindFirstChild("Humanoid") then
            cam.CameraSubject = t.Character.Humanoid
        end
    else
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            cam.CameraSubject = plr.Character.Humanoid
        end
    end
end })

local hidden_fling_on = false
library.toggle(s3, { name = "fling", keybind = true, default = false, callback = function(v) hidden_fling_on = v end })
run.Heartbeat:Connect(function()
    if hidden_fling_on and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        local vel = hrp.Velocity
        hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
        run.RenderStepped:Wait()
        if hrp and hrp.Parent then hrp.Velocity = vel end
        run.Stepped:Wait()
        if hrp and hrp.Parent then hrp.Velocity = vel + Vector3.new(0, 0.1, 0) end
    end
end)

local function skid_fling(target_player)
    if not target_player or not target_player.Character or not target_player.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local thrp = target_player.Character.HumanoidRootPart
    
    local thrust = Instance.new('BodyThrust', hrp)
    thrust.Force = Vector3.new(9999, 9999, 9999)
    thrust.Name = "YeetForce"
    
    local old_pos = hrp.CFrame
    local start_time = tick()
    local target_moved_far = false
    
    repeat
        if not target_player or not target_player.Character or not target_player.Character:FindFirstChild("Head") or not hrp or not hrp.Parent then break end
        hrp.CFrame = thrp.CFrame
        thrust.Location = thrp.Position
        
        local dist = (thrp.Position - old_pos.p).Magnitude
        if dist >= 500 then
            target_moved_far = true
            break
        end
        
        run.Heartbeat:Wait()
    until tick() - start_time > 5
    
    if thrust then thrust:Destroy() end
    
    if target_moved_far then
        hrp.Anchored = true
        for i=1,10 do
            hrp.CFrame = old_pos
            task.wait(0.1)
        end
        task.wait(0.5)
        hrp.Anchored = false
    end
end

local lfling = false
library.toggle(s3, { name = "loop fling", default = false, callback = function(v) 
    lfling = v
    task.spawn(function()
        while lfling do
            for _, t in pairs(get_targets()) do
                skid_fling(t)
                task.wait(0.5)
            end
        end
    end)
end })

library.button(s3, { name = "teleport", callback = function()
    for _, t in pairs(get_targets()) do
        if t.Character and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            tp_to(t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end
end })
library.button(s3, { name = "fling selected", callback = function()
    for _, t in pairs(get_targets()) do skid_fling(t); task.wait(0.1) end
end })
library.button(s3, { name = "fling murderer", callback = function() 
    local m = getmurderer()
    if m then skid_fling(m) end
end })
library.button(s3, { name = "fling sheriff", callback = function() 
    local s = getsheriff()
    if s then skid_fling(s) end
end })
library.button(s3, { name = "kill selected", callback = function()
    for _, t in pairs(get_targets()) do kill_user(t); task.wait(0.1) end
end })
library.button(s3, { name = "map", callback = function()
    local m = getmap()
    if m then tp_to(m:GetModelCFrame()) end
end })
library.button(s3, { name = "above map", callback = function()
    local m = getmap()
    if m then tp_to(m:GetModelCFrame() * CFrame.new(0, 500, 0)) end
end })
library.button(s3, { name = "lobby", callback = function()
    for _, c in pairs(ws:GetChildren()) do
        if string.find(c.Name, "Lobby") and c:IsA("Model") then
            tp_to(c:GetModelCFrame() * CFrame.new(0, 5, 0))
            break
        end
    end
end })

local s4 = t3:section({ name = "mods" })
local walkspeed_on = false
local walkspeed_val = 32
library.toggle(s4, { name = "walkspeed", default = false, keybind = true, default_key = Enum.KeyCode.V, callback = function(v)
    walkspeed_on = v
    task.spawn(function()
        while walkspeed_on do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = walkspeed_val
            end
            task.wait(0.1)
        end
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.WalkSpeed = 16
        end
    end)
end })
library.slider(s4, { name = "walkspeed", min = 16, max = 100, default = 32, callback = function(v) walkspeed_val = v end })

local noclip_on = false
library.toggle(s4, { name = "noclip", default = false, keybind = true, default_key = Enum.KeyCode.B, callback = function(v)
    noclip_on = v
    task.spawn(function()
        while noclip_on do
            if plr.Character then
                for _, part in pairs(plr.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
            run.Stepped:Wait()
        end
    end)
end })

local inf_jump_on = false
library.toggle(s4, { name = "infinite jump", default = false, callback = function(v)
    inf_jump_on = v
end })
uis.JumpRequest:Connect(function()
    if inf_jump_on and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local fly_on = false
local fly_speed = 50
local fly_bv, fly_bg, fly_noclip_conn
local fly_modified_parts = {}
library.toggle(s4, { name = "fly", default = false, keybind = true, default_key = Enum.KeyCode.F, callback = function(v)
    fly_on = v
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    if v then
        hum.PlatformStand = true
        fly_bv = Instance.new("BodyVelocity")
        fly_bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        fly_bv.Velocity = Vector3.new(0, 0, 0)
        fly_bv.Parent = hrp
        fly_bg = Instance.new("BodyGyro")
        fly_bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        fly_bg.P = 10000
        fly_bg.CFrame = hrp.CFrame
        fly_bg.Parent = hrp
        fly_noclip_conn = run.Stepped:Connect(function()
            if char and fly_on then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide and not fly_modified_parts[part] then
                        part.CanCollide = false
                        fly_modified_parts[part] = true
                    end
                end
            end
        end)
        task.spawn(function()
            while fly_on do
                if not char or not char.Parent or not hum or hum.Health <= 0 then break end
                local move_vec = Vector3.new(0, 0, 0)
                if uis:IsKeyDown(Enum.KeyCode.W) then move_vec = move_vec + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then move_vec = move_vec - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then move_vec = move_vec - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then move_vec = move_vec + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then move_vec = move_vec + Vector3.new(0, 1, 0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move_vec = move_vec - Vector3.new(0, 1, 0) end
                fly_bv.Velocity = move_vec * fly_speed
                fly_bg.CFrame = cam.CFrame
                run.RenderStepped:Wait()
            end
        end)
    else
        hum.PlatformStand = false
        if fly_bv then fly_bv:Destroy() end
        if fly_bg then fly_bg:Destroy() end
        if fly_noclip_conn then fly_noclip_conn:Disconnect() end
        for part in pairs(fly_modified_parts) do
            if part and part.Parent == char then
                part.CanCollide = true
            end
        end
        fly_modified_parts = {}
    end
end })
library.slider(s4, { name = "fly speed", min = 10, max = 200, default = 50, callback = function(v) fly_speed = v end })

local float_on = false
local float_bv
library.toggle(s4, { name = "float", default = false, callback = function(v)
    float_on = v
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if v then
        float_bv = Instance.new("BodyVelocity")
        float_bv.MaxForce = Vector3.new(0, 9e9, 0)
        float_bv.Velocity = Vector3.new(0, 0, 0)
        float_bv.Parent = hrp
    else
        if float_bv then float_bv:Destroy() end
    end
end })

local s5 = t5:section({ name = "gun" })
local function grabgun()
    local r = getrole(plr)
    if r == "dead" or r == "murderer" then return end
    if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then return end
    local g = ws:FindFirstChild("GunDrop", true)
    if g and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        firetouchinterest(hrp, g, false)
        task.wait(0.01)
        firetouchinterest(hrp, g, true)
    end
end
library.button(s5, { name = "grab gun", keybind = true, default_key = Enum.KeyCode.E, callback = grabgun })

local agun = false
library.toggle(s5, { name = "auto grab gun", default = false, callback = function(v)
    agun = v
    task.spawn(function()
        while agun do
            grabgun()
            task.wait(0.5)
        end
    end)
end })

local gnotif = false
local last_gdrop = nil
library.toggle(s5, { name = "gun notification", default = false, callback = function(v) gnotif = v end })
task.spawn(function()
    while true do
        local g = ws:FindFirstChild("GunDrop", true)
        if g and gnotif and g ~= last_gdrop then
            library:notification({ text = "gun dropped" })
            last_gdrop = g
        elseif not g then
            last_gdrop = nil
        end
        task.wait(0.5)
    end
end)

local s6 = t6:section({ name = "misc" })
local aafk = false
library.toggle(s6, { name = "anti afk", default = false, callback = function(v) aafk = v end })
plr.Idled:Connect(function()
    if aafk then
        local v = Instance.new("VirtualInputManager")
        v:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait()
        v:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
end)

local coin_amt = library.textbox(s6, { name = "coin amount", placeholder = "amount", clear_on_focus = true })
library.button(s6, { name = "set coins", callback = function()
    local amt = tonumber(coin_amt.instance.Text)
    if amt then
        firesignal(rs.Remotes.Inventory.ChangeInventoryItem.OnClientEvent, "Materials", "Coins", amt)
    end
end })

local gem_amt = library.textbox(s6, { name = "gem amount", placeholder = "amount", clear_on_focus = true })
library.button(s6, { name = "set gems", callback = function()
    local amt = tonumber(gem_amt.instance.Text)
    if amt then
        firesignal(rs.Remotes.Inventory.ChangeInventoryItem.OnClientEvent, "Materials", "Gems", amt)
    end
end })

local em_list = {"sit", "ninja", "zen", "dab", "floss", "zombie", "headless"}
local selected_emote = "sit"
library.dropdown(s6, { name = "play emote", options = em_list, default = "sit", callback = function(v) 
    selected_emote = v
end })
library.button(s6, { name = "play selected emote", callback = function()
    rs.Remotes.Misc.PlayEmote:Fire(selected_emote)
end })
local seiz = false
library.toggle(s6, { name = "seizure", default = false, callback = function(v)
    seiz = v
    task.spawn(function()
        while seiz do
            for _, e in pairs(em_list) do
                pcall(function() rs.Remotes.Misc.PlayEmote:Fire(e) end)
                task.wait(0.1)
            end
        end
    end)
end })

local remove_stuck = false
library.toggle(s6, { name = "remove stuck knife", default = false, callback = function(v)
    remove_stuck = v
    task.spawn(function()
        while remove_stuck do
            for _, c in pairs(ws:GetChildren()) do
                if c.Name == "StuckKnife" then
                    c:Destroy()
                end
            end
            task.wait(1)
        end
    end)
end })

local fps_b = false
local fps_conn
library.toggle(s6, { name = "fps boost", default = false, callback = function(v)
    fps_b = v
    if fps_b then
        for _, d in pairs(ws:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Material = Enum.Material.SmoothPlastic
                d.Reflectance = 0
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = 1
            elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Fire") or d:IsA("Smoke") then
                d.Enabled = false
            elseif d:IsA("SpecialMesh") then
                d.TextureId = ""
                d.VertexColor = Vector3.new(1,1,1)
            end
        end
        fps_conn = ws.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") then d.Material = Enum.Material.SmoothPlastic; d.Reflectance = 0
            elseif d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1
            elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Fire") or d:IsA("Smoke") then d.Enabled = false
            elseif d:IsA("SpecialMesh") then d.TextureId = ""; d.VertexColor = Vector3.new(1,1,1) end
        end)
    else
        if fps_conn then fps_conn:Disconnect() end
        for _, d in pairs(ws:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Material = Enum.Material.Plastic
            end
        end
    end
end })

local afarm = false
local afarm_speed = 3
library.slider(s6, { name = "auto farm speed", min = 1, max = 10, default = 3, callback = function(v) afarm_speed = v end })
library.toggle(s6, { name = "auto farm", default = false, callback = function(v)
    afarm = v
    task.spawn(function()
        while afarm do
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hrp or not hum or hum.Health <= 0 then task.wait(1); continue end
            local container = getcontainer()
            if not container then task.wait(1); continue end
            
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.rad(90), 0, 0)
            
            local noclip = run.Stepped:Connect(function()
                if not afarm or not char or not char.Parent then return end
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
            
            local coins = {}
            for _, c in pairs(container:GetDescendants()) do
                if c:IsA("BasePart") and (c.Name == "CoinVisual" or c.Name == "Coin") then
                    table.insert(coins, c)
                end
            end
            table.sort(coins, function(a, b) return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude end)
            
            hrp.Anchored = false
            
            for _, child in pairs(coins) do
                if not afarm or not char or not hrp or not hum or hum.Health <= 0 then break end
                
                local dist = (hrp.Position - child.Position).Magnitude
                local dur = dist / (afarm_speed * 5)
                if dur < 0.05 then dur = 0.05 end
                
                local target = CFrame.new(child.Position.X, child.Position.Y - 1, child.Position.Z) * CFrame.Angles(math.rad(90), 0, 0)
                local info = TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tw = ts:Create(hrp, info, {CFrame = target})
                tw:Play()
                
                local elapsed = 0
                while tw.PlaybackState ~= Enum.PlaybackState.Completed and afarm do
                    if elapsed >= dur then break end
                    task.wait(0.03)
                    elapsed = elapsed + 0.03
                end
                if not afarm then tw:Cancel(); break end
                
                if child and child.Parent then
                    hrp.CFrame = target
                    if child:FindFirstChildWhichIsA("TouchInterest") then
                        firetouchinterest(hrp, child, true)
                        task.wait(0.01)
                        firetouchinterest(hrp, child, false)
                    else
                        task.wait(0.01)
                    end
                end
            end
            
            if hrp then hrp.Anchored = false end
            noclip:Disconnect()
            task.wait(0.5)
        end
    end)
end })

local function glitchproof()
    local map = getmap()
    if not map then return nil end
    local found = nil
    for _, child in map:GetDescendants() do
        if child.Name == "GlitchProof" then
            found = child
            break
        end
    end
    return found
end

library.toggle(s6, { name = "remove glitch proof", default = false, callback = function(v)
    local glitch_on = v
    task.spawn(function()
        while glitch_on do
            local hi = glitchproof()
            if hi then
                for _, child in pairs(hi:GetChildren()) do
                    if child.Name ~= "KillBrick" then 
                        child:Destroy() 
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end })

library.toggle(s6, { name = "remove killbricks", default = false, callback = function(v)
    local killbrick_on = v
    task.spawn(function()
        while killbrick_on do
            local map = getmap()
            if map then
                for _, child in pairs(map:GetDescendants()) do
                    if child.Name == "KillBrick" or child.Name == "killbrick" or child.Name == "Killbrick" then 
                        if child:IsA("BasePart") then
                            child.CanTouch = false
                            child.CanCollide = false
                            child.Transparency = 1
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end })

local RankIconsEmpty = require(rs:WaitForChild("RankIconsEmpty"))

local s_spoofer = t6:section({ name = "spoofer" })

local hide_name = false
local spoof_level = false
local level_val = 1
local prestige_val = 0

local prestige_numerals = {
    [1] = "I", [2] = "II", [3] = "III", [4] = "IV", [5] = "V",
    [6] = "VI", [7] = "VII", [8] = "VIII", [9] = "IX", [10] = "X"
}

task.spawn(function()
    while true do
        local gameui = plr.PlayerGui:FindFirstChild("MainGUI")
        if gameui then
            local game_frame = gameui:FindFirstChild("Game")
            if game_frame then
                local lb = game_frame:FindFirstChild("Leaderboard")
                if lb then
                    local container = lb:FindFirstChild("Container")
                    local inscontainer = lb:FindFirstChild("Inspect") and lb.Inspect:FindFirstChild("Container")
                    
                    if container then
                        for _, child in pairs(container:GetChildren()) do
                            local txt = child:FindFirstChild("PlayerLabel")
                            local is_mine = (child.Name == plr.Name) or (txt and (txt.Text == plr.DisplayName or txt.Text == plr.Name))
                            
                            if is_mine then
                                if hide_name and txt then
                                    txt.Text = " "
                                end
                                
                                if spoof_level then
                                    local lvl_img = child:FindFirstChild("Level")
                                    if lvl_img then
                                        lvl_img.Image = RankIconsEmpty[level_val] or lvl_img.Image
                                        local lvl_text = lvl_img:FindFirstChild("Level")
                                        if lvl_text then lvl_text.Text = tostring(level_val) end
                                        local pres_text = lvl_img:FindFirstChild("Prestige")
                                        if pres_text then
                                            pres_text.Text = prestige_numerals[prestige_val] or ""
                                            pres_text.Visible = prestige_val > 0
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if inscontainer and hide_name then
                        local txt2 = inscontainer:FindFirstChild("Username")
                        if txt2 and (txt2.Text == plr.Name or txt2.Text == plr.DisplayName) then 
                            txt2.Text = " " 
                        end
                    end
                end

                local view_profile = game_frame:FindFirstChild("ViewProfile")
                if view_profile then
                    local main_frame = view_profile:FindFirstChild("Main")
                    if main_frame then
                        local profile_frame = main_frame:FindFirstChild("Profile")
                        if profile_frame then
                            local profile_container = profile_frame:FindFirstChild("Container")
                            if profile_container then
                                local txt = profile_container:FindFirstChild("Username")
                                if txt and (txt.Text == plr.Name or txt.Text:match(plr.Name)) then
                                    if hide_name then
                                        txt.Text = " "
                                    else
                                        txt.Text = plr.DisplayName
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

library.toggle(s_spoofer, { name = "incognito", default = false, callback = function(v) hide_name = v end })
library.toggle(s_spoofer, { name = "level spoofer", default = false, callback = function(v) spoof_level = v end })
library.slider(s_spoofer, { name = "spoof level", min = 1, max = 100, default = 1, callback = function(v) level_val = v end })
library.slider(s_spoofer, { name = "spoof prestige", min = 0, max = 10, default = 0, callback = function(v) prestige_val = v end })

local unlock_cam = false
local cam_noclip = false

local metatable = getrawmetatable(game)
local old = metatable.__namecall
if setreadonly then setreadonly(metatable, false) end

metatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and cam_noclip and self == ws and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist") then
        if method == "Raycast" then
            return nil
        else
            return nil, Vector3.new(), Enum.Material.Air, nil
        end
    end
    return old(self, unpack(args))
end)

if setreadonly then setreadonly(metatable, true) end

library.toggle(s6, { name = "unlock camera", default = false, callback = function(v)
    unlock_cam = v
    if unlock_cam then
        plr.CameraMaxZoomDistance = 1e9
        plr.CameraMinZoomDistance = 0.5
    else
        plr.CameraMaxZoomDistance = 128
        plr.CameraMinZoomDistance = 0.5
    end
end })

library.toggle(s6, { name = "camera noclip", default = false, callback = function(v)
    cam_noclip = v
end })

local s8 = t6:section({ name = "server" })
library.button(s8, { name = "rejoin", callback = function()
    tps:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
end })
library.button(s8, { name = "serverhop", callback = function()
    local servers = hs:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in pairs(servers.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            tps:TeleportToPlaceInstance(game.PlaceId, s.id, plr)
            break
        end
    end
end })
library.button(s8, { name = "copy job id", callback = function()
    setclipboard(tostring(game.JobId))
end })
local job_id_input = library.textbox(s8, { placeholder = "job id", clear_on_focus = true })
library.button(s8, { name = "join job id", callback = function()
    local id = job_id_input.instance.Text
    if id ~= "" then
        tps:TeleportToPlaceInstance(game.PlaceId, id, plr)
    end
end })

local s7 = t6:section({ name = "anti exploiter" })
local af = false
local maxvel = 120
local maxang = 120
library.toggle(s7, { name = "anti fling", default = false, callback = function(v) 
    af = v
end })
run.Stepped:Connect(function()
    if not af then return end
    local char = plr.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local lv = root.AssemblyLinearVelocity
            local av = root.AssemblyAngularVelocity
            if lv.Magnitude > maxvel or av.Magnitude > maxang then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= plr and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

local av = false
library.toggle(s7, { name = "anti void", default = false, callback = function(v)
    av = v
    task.spawn(function()
        while av do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if plr.Character.HumanoidRootPart.Position.Y < -10 then
                    local map = getmap()
                    if map then
                        tp_to(map:GetModelCFrame() * CFrame.new(0, 10, 0))
                    else
                        local lobby = ws:FindFirstChild("Lobby")
                        if lobby then
                            tp_to(lobby:GetModelCFrame() * CFrame.new(0, 10, 0))
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end })

local al = false
library.toggle(s7, { name = "anti lock", default = false, callback = function(v)
    al = v
    task.spawn(function()
        while al do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                for _, d in pairs(plr.Character:GetDescendants()) do
                    if d:IsA("BodyVelocity") or d:IsA("BodyAngularVelocity") or d:IsA("BodyGyro") then
                        d:Destroy()
                    end
                end
            end
            task.wait(1)
        end
    end)
end })
