local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/codexvsberserkerxylo/femboy-ware/main/library.luau"))()

local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local player = players.LocalPlayer

local window = library:window({ 
    title = "example", 
    subtitle = " - im a subtitle", 
    size = UDim2.new(0, 650, 0, 450),
    icon = "moon",
    discord_link = "discord.gg/example",
    script_url = "https://raw.githubusercontent.com/codexvsberserkerxylo/femboy-ware/refs/heads/main/example.luau"
})

library:loading_screen({ text = "loading...", duration = 3, size = window.size })

local combat_tab = window:tab({ name = "combat", icon = "swords", search = true })
local aimbot_section = combat_tab:section({ name = "aimbot" })

aimbot_section:toggle({
    name = "enabled",
    default = false,
    --keybind = true,
    --default_key = Enum.KeyCode.RightShift
    --default_mode = "hold"
    flag = "aimbot_enabled",
    callback = function(val) print("aimbot enabled:", val) end
})

aimbot_section:slider({
    name = "smoothness",
    min = 0, max = 10, default = 5,
    flag = "aimbot_smoothness",
    callback = function(val) print("smoothness:", val) end
})

aimbot_section:toggle({
    name = "enabled",
    default = false,
    flag = "aimbot_enabled",
    callback = function(val) print("aimbot enabled:", val) end
})

aimbot_section:slider({
    name = "smoothness",
    min = 0, max = 10, default = 5,
    flag = "aimbot_smoothness",
    callback = function(val) print("smoothness:", val) end
})

aimbot_section:toggle({
    name = "enabled",
    default = false,
    flag = "aimbot_enabled",
    callback = function(val) print("aimbot enabled:", val) end
})

aimbot_section:slider({
    name = "smoothness",
    min = 0, max = 10, default = 5,
    flag = "aimbot_smoothness",
    callback = function(val) print("smoothness:", val) end
})

aimbot_section:toggle({
    name = "enabled",
    default = false,
    flag = "aimbot_enabled",
    callback = function(val) print("aimbot enabled:", val) end
})

aimbot_section:slider({
    name = "smoothness",
    min = 0, max = 10, default = 5,
    flag = "aimbot_smoothness",
    callback = function(val) print("smoothness:", val) end
})

aimbot_section:toggle({
    name = "enabled",
    default = false,
    flag = "aimbot_enabled",
    callback = function(val) print("aimbot enabled:", val) end
})

aimbot_section:slider({
    name = "smoothness",
    min = 0, max = 10, default = 5,
    flag = "aimbot_smoothness",
    callback = function(val) print("smoothness:", val) end
})

aimbot_section:dropdown({
    name = "target part",
    options = { "Head", "Torso", "Left Arm", "Right Arm" },
    default = "Head",
    flag = "aimbot_part",
    callback = function(val) print("target part:", val) end
})

local player_tab = window:tab({ name = "player", icon = "user", search = true })
local movement_section = player_tab:section({ name = "movement" })

movement_section:toggle({
    name = "infinite jump",
    default = false,
    flag = "inf_jump",
    callback = function(state)
        if state then
            library.connections.inf_jump = uis.JumpRequest:Connect(function()
                if library.flags["inf_jump"] then
                    local char = player.Character
                    if char and char:FindFirstChildOfClass("Humanoid") then
                        char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if library.connections.inf_jump then
                library.connections.inf_jump:Disconnect()
                library.connections.inf_jump = nil
            end
        end
    end
})

movement_section:slider({
    name = "walk speed",
    min = 16, max = 500, default = 16,
    flag = "walk_speed",
    callback = function(val)
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        end
    end
})

player.CharacterAdded:Connect(function()
    if library.flags["walk_speed"] then
        local hum = player.Character:WaitForChild("Humanoid")
        hum.WalkSpeed = library.flags["walk_speed"]
    end
end)
