use mlua::prelude::*;

use super::LuaRandomFacade;

#[mlua::lua_module]
fn _marte_random(lua: &Lua) -> LuaResult<LuaTable> {
    let module = lua.create_table()?;

    module.set("new", lua.create_function(LuaRandomFacade::new)?)?;

    Ok(module)
}

impl LuaUserData for LuaRandomFacade {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut("boolean", Self::boolean);
        methods.add_method_mut("number", Self::number);
        methods.add_method_mut("integer", Self::integer);
    }
}
