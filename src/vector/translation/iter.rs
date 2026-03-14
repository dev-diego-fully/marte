use super::LuaVectorFacade;
use mlua::prelude::*;

impl LuaVectorFacade {
    pub(crate) fn copy(_: &Lua, this: &Self, _: ()) -> LuaResult<Self> {
        Ok(Self::new(this.vec.copy()))
    }
}
