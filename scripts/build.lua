local build;
local build_core, remove_file, move_builded_file;
local get_paths, get_lua_feature;
local get_build_prefix, get_lib_format;

local TARGET_OS = arg[1];
local SUPPORTEDS_OS = {
    WINDOWS = "windows",
    LINUX = "linux",
    MACOSX = "macosx"
};

---
---@param src_path string
---@param dest_path string
---@param lua_feature string
function build(src_path, dest_path, lua_feature)
    remove_file(dest_path);

    if not build_core(lua_feature) then
        os.exit(1);
    end

    move_builded_file(src_path, dest_path);
end

---
---@param dest_path string
function remove_file(dest_path)
    os.remove(dest_path)
end

---
---@param lua_feature string
---@return boolean
function build_core(lua_feature)
    local cmd = "cargo build --release --no-default-features --features %s";
    local result = os.execute(
        cmd:format(lua_feature)
    );

    return (type(result) == "boolean" and result) or result == 0;
end

---
---@param src_path string
---@param dest_path string
function move_builded_file(src_path, dest_path)
    os.rename(src_path, dest_path)
end

---
---@param target_os string
---@return string, string
function get_paths(target_os)
    local path_pattern = "target/release/%smarte.%s";
    local build_prefix = get_build_prefix(target_os);
    local lib_format = get_lib_format(target_os);

    local src = path_pattern:format(build_prefix, lib_format);
    local dest = path_pattern:format("_", lib_format);

    return src, dest;
end

---
---@param target_os string
---@return string
function get_build_prefix(target_os)
    if target_os == SUPPORTEDS_OS.WINDOWS then
        return "";
    else
        return "lib";
    end
end

---
---@param target_os string
---@return string
function get_lib_format(target_os)
    if target_os == SUPPORTEDS_OS.WINDOWS then
        return "dll";
    elseif target_os == SUPPORTEDS_OS.MACOSX then
        return "dylib"
    else
        return "so"
    end
end

---
---@return string
function get_lua_feature()
    ---@diagnostic disable-next-line: undefined-global
    if type(jit) == "table" then
        return "luajit";
    end

    local version = _VERSION:match("%d+.%d+"):gsub("%.", "");
    return "lua" .. version;
end

local src_path, dest_path = get_paths(TARGET_OS);
build(src_path, dest_path, get_lua_feature());
