local p = {
    None = false,
    Plugin = false,
    LocalUser = false,
    WritePlayer = false,
    RobloxScript = false,
    RobloxEngine = false,
    NotAccessible = false
}

local function try(func, ...)
    local success, _ = pcall(func, ...)
    return success
end

local function invert(t: {any}): {any}
    local result = {}
    for i,v in pairs(t) do
        result[i] = not v
    end
    return result
end

local function eliminate(t: {any}): {any}
    local result = {}
    for i,v in pairs(t) do
        if v then
            table.insert(result, i)
        end
    end
    return result
end



local function isSame(table1, table2)
    if #table1 ~= #table2 then
        return false
    end

    for i,v in pairs(table1) do
        if table2[i] ~= v then
            return false
        end
    end
    return true
end

p["None"] = try(function() return game.Name end)
p["Plugin"] = try(function() return game:GetService("CoreGui").Name end)
p["LocalUser"] = try(function() return game.DataCost end)
p["WritePlayer"] = try(Instance.new, "Player")
p["RobloxScript"] = try(function() return game:GetService("CorePackages").Name end)
p["RobloxEngine"] = try(function() return Instance.new("SurfaceAppearance").TexturePack end)
p["NotAccessible"] = try(function() Instance.new("MeshPart").MeshId = "" end)



local identity = -1

local requireds = {
    {"None"},
    {"None", "Plugin", "LocalUser"},
    {"None"},
    {"None", "Plugin", "LocalUser", "RobloxScript"},
    {"None", "Plugin", "LocalUser"},
    {"None", "Plugin"},
    {"None", "Plugin", "LocalUser", "RobloxScript"},
    {"None", "Plugin", "RobloxPlace", "LocalUser", "WritePlayer", "RobloxScript", "RobloxEngine"},
    {"None", "Plugin", "RobloxPlace", "LocalUser", "WritePlayer", "RobloxScript", "RobloxEngine"},
    {"WritePlayer", "RobloxScript"},
    {"None", "Plugin", "RobloxPlace", "LocalUser", "WritePlayer", "RobloxScript", "RobloxEngine", "NotAccessible"}
}

local candidates = {}
local inverted = eliminate(p)

for i,v in pairs(requireds) do
    table.sort(v, sorter)
    table.sort(inverted, sorter)

    if isSame(v, inverted) then
        print("insert")
        table.insert(candidates, tostring(tonumber(i) - 1))
    end
end

printidentity()
task.wait(.1)

local messages = game:GetService('LogService'):GetLogHistory()
local message;
if not messages[#messages].message:match("Current identity is") then
  for i = #messages, 1, -1 do
   if messages[i].message:match("Current identity is %d") then
    message = messages[i].message
    break
   end
  end
else
  message = messages[#messages].message:match('Current identity is %d'):gsub("Current identity is ", '')
end

local detected = message
print(("\n"):rep(500))
print(`{#candidates} candidates found.`)

if #candidates == 0 then
    print("Error. 0 candidates.")
elseif #candidates == 1 then
    identity = candidates[1]
elseif #candidates > 1 then
    if table.find(candidates, detected) then
        identity = detected
    end
end

if identity ~= -1 then
    if identity == detected then
        print(`✅ Your executor's identity is {identity}. Matches with printidentity() ✅`)
    else
        if setthreadidentity then
            print(`❎ Your executor's identity is {identity}. Doesn't match with printidentity(). \nNote: Your executor is probably spoofing its identity or setthreadidentity() may have been used.`)
        else
            print(`❎ Your executor's identity is {identity}. Doesn't match with printidentity(). \nNote: Your executor is probably spoofing its identity.`)
        end
    end
else
    print(`❌ Executor identity not found. Using printidentity...`)
    printidentity()
end
