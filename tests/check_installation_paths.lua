local function test_importation(path)
    local ok = pcall(require, path)

    if not ok then
        print("Module " .. path .. " has invalid LuaRock path and importation does not work.");
    else
        print("Module " .. path .. " has valid LuaRocks path.");
    end
    return not ok;
end

local result = test_importation("marte.vector");
result = test_importation("marte.regex") and result;
result = test_importation("marte.random") and result;

return result;
