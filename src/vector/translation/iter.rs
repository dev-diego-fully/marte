use super::LuaVectorFacade;
use mlua::prelude::*;

impl LuaVectorFacade {
    pub(crate) fn copy(_: &Lua, this: &Self, _: ()) -> LuaResult<Self> {
        Ok(Self::new(this.vec.copy()))
    }

    pub(crate) fn reverse(_: &Lua, this_any: LuaAnyUserData) -> LuaResult<LuaAnyUserData> {
        let mut this = this_any.borrow_mut::<Self>()?;
        this.vec.reverse();
        Ok(this_any)
    }
}
