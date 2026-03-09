use mlua::prelude::*;

mod vector;

#[mlua::lua_module]
fn marte(lua: &Lua) -> LuaResult<LuaTable> {
    let mars_module = lua.create_table()?;

    Ok(mars_module)
}