use mlua::prelude::*;

#[mlua::lua_module]
fn marte(lua: &Lua) -> LuaResult<LuaTable> {
    let mars_module = lua.create_table()?;

    Ok(mars_module)
}

#[mlua::lua_module]
fn marte_vector(lua: &Lua) -> LuaResult<LuaTable> {
    let mars_vector_module = lua.create_table()?;
    
    Ok(mars_vector_module)
}
