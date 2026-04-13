use super::translation::LuaRegexFacade;
use mlua::prelude::*;

#[mlua::lua_module]
fn marte_regex(lua: &Lua) -> LuaResult<LuaTable> {
    let regex_module = lua.create_table()?;

    regex_module.set("new", lua.create_function(LuaRegexFacade::new)?)?;

    Ok(regex_module)
}

impl LuaUserData for LuaRegexFacade {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("matches", Self::matches);
        methods.add_method("match", Self::find);
        methods.add_method("match_all", Self::match_all);
        methods.add_method("replace", Self::replace);
        methods.add_method("replace_all", Self::replace_all);
        methods.add_method("split", Self::split);
    }
}
