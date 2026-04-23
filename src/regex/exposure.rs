use super::translation::{LuaMatchFacade, LuaRegexFacade};
use mlua::prelude::*;

#[mlua::lua_module]
fn marte_regex(lua: &Lua) -> LuaResult<LuaTable> {
    let regex_module = lua.create_table()?;

    regex_module.set("new", lua.create_function(LuaRegexFacade::new)?)?;

    Ok(regex_module)
}

impl LuaUserData for LuaRegexFacade {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("test", Self::test);
        methods.add_method("find_first", Self::find_first);
        methods.add_method("replace_all", Self::replace_all);
        methods.add_method("split_all", Self::split_all);
        methods.add_method("process_all", Self::process_all);
        methods.add_method("collect_all", Self::collect_all);
    }
}

impl LuaUserData for LuaMatchFacade {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_meta_method("__index", Self::index);
        methods.add_meta_method("__newindex", Self::newindex);
        methods.add_meta_method("__eq", Self::equals);
        methods.add_meta_method("__len", Self::len);
    }
}
