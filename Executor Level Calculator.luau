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

local consoleTab = (" "):rep(12)
local output = {}

local function out(data)
    local str = tostring(data:gsub("\n", "\n" .. consoleTab))
    local maxLineLength = 121
    local outputStr = ""
    local i = 1

    while i <= #str do
        if (i - 1) % maxLineLength == 0 and i ~= 1 then
            outputStr = outputStr .. "\n" .. consoleTab
        end
        outputStr = outputStr .. str:sub(i, i)
        i = i + 1
    end

    table.insert(output, outputStr)
end

local function outAll()
    print(table.concat(output, "\n" .. consoleTab))
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
p["Plugin"] = try(function() return #game:GetService("CoreGui"):GetChildren() end) and try(function() return workspace.RobloxLocked end)
p["LocalUser"] = try(function() return game.DataCost end)
p["WritePlayer"] = not try(Instance.new, "Player", workspace)
p["RobloxScript"] = try(function() return game:GetService("CorePackages").Name end) and try(function() return game:GetService("CoreGui").SelectionImageObject end)
p["RobloxEngine"] = try(function() return Instance.new("SurfaceAppearance").TexturePack end) and try(function() return game:GetService("CSGDictionaryService").Name end)
p["NotAccessible"] = try(function() Instance.new("MeshPart").MeshId = "rbxassetid://10124180584" end) and try(function() game:GetService("Chat").LoadDefaultChat = game:GetService("Chat").LoadDefaultChat end)

local identity = -1

local requireds = {
    {"None"},
    {"None", "Plugin", "LocalUser"},
    {"None"},
    {"None", "Plugin", "LocalUser", "RobloxScript"},
    {"None", "Plugin", "LocalUser"},
    {"None", "Plugin"},
    {"None", "Plugin", "LocalUser", "RobloxScript"},
    {"None", "Plugin", "LocalUser", "WritePlayer", "RobloxScript", "RobloxEngine"},
    {"None", "Plugin", "LocalUser", "WritePlayer", "RobloxScript", "RobloxEngine", "NotAccessible"},
    {"WritePlayer", "RobloxScript"}
}

local candidates = {}
local inverted = eliminate(p)

for i,v in pairs(requireds) do
    table.sort(v, sorter)
    table.sort(inverted, sorter)

    if isSame(v, inverted) then
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

local getthreadidentity = getthreadidentity or function() return nil end
local thread = getthreadidentity

local spoofed = thread and thread() ~= detected

print(("\n"):rep(500))
out(`{#candidates} candidates found.`)

if #candidates == 0 then
    out("Error. 0 candidates.")
elseif #candidates == 1 then
    identity = candidates[1]
elseif #candidates > 1 then
    if table.find(candidates, detected) then
        identity = detected
    end
end

if identity ~= -1 then
    if identity == detected then
        out(`✅ Your executor's identity is {identity}. Matches with printidentity() ✅`)
    else
        if spoofed then
            out(`❎ Your executor's identity is {identity}. Doesn't match with printidentity(). \n{consoleTab}Note: setthreadidentity() have been used.`)
        else
            out(`❎ Your executor's identity is {identity}. Doesn't match with printidentity(). \n{consoleTab}Note: Your executor is probably spoofing its identity.`)
        end
    end
else
    out(`❌ Executor identity not found. But printidentity() returns {detected}...\n`)
end

out(`\nExecutor capabilies (for 🤓s): {table.concat(inverted, ", ")}`)

outAll()
