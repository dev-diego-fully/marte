use super::LuaVectorFacade;
use mlua::prelude::*;

impl LuaVectorFacade {
    pub(in crate::vector) fn copy(_: &Lua, this: &Self, _: ()) -> LuaResult<Self> {
        Ok(Self::new(this.vec.copy()))
    }

    pub(in crate::vector) fn reverse(
        _: &Lua,
        this_any: LuaAnyUserData,
    ) -> LuaResult<LuaAnyUserData> {
        let mut this = this_any.borrow_mut::<Self>()?;
        this.vec.reverse();
        Ok(this_any)
    }

    pub(in crate::vector) fn transform(
        _: &Lua,
        (this_any, transformer): (LuaAnyUserData, LuaFunction),
    ) -> LuaResult<LuaAnyUserData> {
        let op = |v, i| transformer.call((v, to_lua_index(i)));
        let mut this = this_any.borrow_mut::<Self>()?;

        match this.vec.transform(op) {
            Err(index) => {
                let err = LuaError::runtime(format!(
                    "The transformation failed. Error trying to transform the {} nth element",
                    to_lua_index(index)
                ));
                Err(err)
            }
            Ok(_) => Ok(this_any),
        }
    }

    pub(in crate::vector) fn keep(
        _: &Lua,
        (this_any, keep): (LuaAnyUserData, LuaFunction),
    ) -> LuaResult<LuaAnyUserData> {
        let op = |v, i| keep.call((v, to_lua_index(i)));
        let mut this = this_any.borrow_mut::<Self>()?;

        match this.vec.keep(op) {
            Err(index) => {
                let err = LuaError::runtime(format!(
                    "The keep operation failed. An error occurred while trying to evaluate the {} th element",
                    to_lua_index(index)
                ));
                Err(err)
            }
            Ok(_) => Ok(this_any),
        }
    }
}

fn to_lua_index(rust_index: usize) -> LuaInteger {
    (rust_index + 1) as LuaInteger
}
