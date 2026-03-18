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
        let op = |v, i| {
            let lua_index = to_lua_index(i);
            match transformer.call((v, lua_index)) {
                Ok(v) => Ok(v),
                Err(_) => Err(lua_index),
            }
        };
        let mut this = this_any.borrow_mut::<Self>()?;

        match this.vec.transform(op) {
            Err(index) => {
                let err = LuaError::runtime(format!(
                    "The transformation failed. Error trying to transform the {} nth element",
                    index
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
        let op = |v, i| {
            let lua_index = to_lua_index(i);

            match keep.call((v, lua_index)) {
                Ok(v) => Ok(v),
                Err(_) => Err(lua_index),
            }
        };
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

    pub(in crate::vector) fn foldl(
        _: &Lua,
        this: &Self,
        (folder, initial): (LuaFunction, Option<LuaValue>),
    ) -> LuaResult<LuaValue> {
        let callback = |acc, value, index| {
            let lua_index = to_lua_index(index);

            match folder.call((acc, value, lua_index)) {
                Ok(v) => Ok(v),
                Err(_) => Err(lua_index),
            }
        };

        match this.vec.foldl(callback, initial) {
            Ok(v) => Ok(v),
            Err(index) => Err(LuaError::runtime(format!(
                "Reduction failure. Error encountered during processing of the {}th element",
                index
            ))),
        }
    }

    pub(in crate::vector) fn foldr(
        _: &Lua,
        this: &Self,
        (folder, initial): (LuaFunction, Option<LuaValue>),
    ) -> LuaResult<LuaValue> {
        let callback = |acc, value, index| {
            let lua_index = to_lua_index(index);

            match folder.call((acc, value, lua_index)) {
                Ok(v) => Ok(v),
                Err(_) => Err(lua_index),
            }
        };

        match this.vec.foldr(callback, initial) {
            Ok(v) => Ok(v),
            Err(index) => Err(LuaError::runtime(format!(
                "Reduction failure. Error encountered during processing of the {}th element",
                index
            ))),
        }
    }

    pub(in crate::vector) fn sort(
        lua: &Lua,
        (this_any, comparer): (LuaAnyUserData, Option<LuaFunction>),
    ) -> LuaResult<LuaAnyUserData> {
        let mut this = this_any.borrow_mut::<Self>()?;
        let comparer = match comparer {
            Some(f) => f,
            None => lua.load("function(a, b) return a < b end").eval()?,
        };

        let op = |a: LuaValue, b: LuaValue| {
            let args = (a.clone(), b.clone());

            match comparer.call(args) {
                Ok(LuaValue::Boolean(bool_val)) => Ok(bool_val),
                Ok(_) | Err(_) => Err((a, b)),
            }
        };

        match this.vec.sort(op) {
            Ok(_) => Ok(this_any),
            Err(_) => {
                let msg = String::from(
                    "Sort failed. An error occurred while comparing the vector elements.",
                );
                Err(LuaError::runtime(msg))
            }
        }
    }
}

fn to_lua_index(rust_index: usize) -> LuaInteger {
    (rust_index + 1) as LuaInteger
}
