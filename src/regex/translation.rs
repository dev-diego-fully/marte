use super::core::LuaRegex;
use crate::vector::Vector;
use mlua::prelude::*;

pub(crate) type LuaRegexFacade = Regex;

pub(crate) struct Regex {
    inner: LuaRegex,
}

type NullableEither<L, R> = Option<LuaEither<L, R>>;

impl LuaRegexFacade {
    pub(crate) fn new(
        lua: &Lua,
        (pattern,): (LuaString,),
    ) -> LuaResult<(Option<Self>, Option<LuaString>)> {
        let lua_pattern = match pattern.to_str() {
            Err(_) => {
                let err_message =
                    lua.create_string("Invalid utf8 stirng provided as pattern to regex")?;
                let lua_err_message = Some(err_message);

                return Ok((None, lua_err_message));
            }
            Ok(str) => str,
        };

        match LuaRegex::new(&lua_pattern) {
            Err(_) => {
                let err_message =
                    lua.create_string("Provided pattern is not compilable as regex")?;
                let lua_err_message = Some(err_message);

                Ok((None, lua_err_message))
            }
            Ok(lua_regex) => {
                let out_regex = Some(Self { inner: lua_regex });

                Ok((out_regex, None))
            }
        }
    }

    pub(crate) fn matches(_: &Lua, this: &Self, (string,): (LuaString,)) -> LuaResult<LuaValue> {
        Ok(LuaValue::Boolean(true))
    }

    pub(crate) fn find(
        _: &Lua,
        this: &Self,
        (string,): (LuaString,),
    ) -> LuaResult<Option<LuaTable>> {
        Ok(None)
    }

    pub(crate) fn match_all(
        _: &Lua,
        this: &Self,
        (string, vec_or_op): (LuaString, NullableEither<LuaAnyUserData, LuaFunction>),
    ) -> LuaResult<Option<Vector>> {
        Ok(None)
    }

    pub(crate) fn replace(
        lua: &Lua,
        this: &Self,
        (string, replacement): (LuaString, LuaString),
    ) -> LuaResult<LuaString> {
        lua.create_string("s")
    }

    pub(crate) fn replace_all(
        lua: &Lua,
        this: &Self,
        (string, replacement): (LuaString, LuaString),
    ) -> LuaResult<LuaString> {
        lua.create_string("s")
    }

    pub(crate) fn split(lua: &Lua, this: &Self, (string,): (LuaString,)) -> LuaResult<LuaString> {
        lua.create_string("s")
    }
}
