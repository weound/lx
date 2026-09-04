if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("main load")

local base = 'https://raw.githubusercontent.com/weound/lx/main/games/'

local games = {
    [1848960] = 'mm2.luau',
    [892039974] = 'deagle-arena.luau',
    [1047647644] = 'one-tap.luau',
    [2613928] = 'arsenal.luau',
    [4619164] = 'sell-lemons.luau',
    --[1848960] = 'spelling-bee.luau',
}

local cid = game.CreatorId
print(cid)
local file = games[cid]
if not file then warn("games file not found") return end
print("// "..file)
loadstring(game:HttpGet(base .. file))()
