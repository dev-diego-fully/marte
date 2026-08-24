local function clean()
    os.execute("cargo clean");
end

---
---@param version string
local function build(version)
    local cmd = ("sudo luarocks --lua-version=%s build"):format(version);
    os.execute(cmd);
end

---
---@param runner string
local function test(runner)
    local cmd = ("luarocks test tests -- --lua=%s"):format(runner);
    os.execute(cmd);
end

local supporteds_runners_and_version = {
    ["lua5.1"] = "5.1",
    ["lua5.2"] = "5.2",
    ["lua5.3"] = "5.3",
    ["lua5.4"] = "5.4",
    ["luajit"] = "5.1"
};

local quick_test = arg[1] == "quick";

for runner, version in pairs(supporteds_runners_and_version) do
    if not quick_test then
        clean();
    end
    build(version);
    test(runner);
end
