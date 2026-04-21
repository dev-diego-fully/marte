use super::core::LuaRegex;
use crate::vector::Vector;
use mlua::prelude::*;

pub(crate) type LuaRegexFacade = Regex;

pub(crate) struct Regex {
    inner: LuaRegex,
}

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

    pub(crate) fn test(_: &Lua, this: &Self, (string,): (LuaString,)) -> LuaResult<LuaValue> {
        let matched = this.inner.test(&string.as_bytes());

        Ok(LuaValue::Boolean(matched))
    }

    pub(crate) fn find_first(
        _: &Lua,
        this: &Self,
        (string,): (LuaString,),
    ) -> LuaResult<Option<LuaTable>> {
        Ok(None)
    }

    pub(crate) fn replace_all(
        lua: &Lua,
        this: &Self,
        (string, replacement, limit): (LuaString, LuaString, Option<LuaInteger>),
    ) -> LuaResult<LuaString> {
        match limit {
            Some(0) => Ok(string),
            Some(n) if n < 0 => Err(LuaError::runtime(
                "Invalid negative limit for replace_all method",
            )),
            value => lua.create_string(this.inner.replace_all(
                &string.as_bytes(),
                &replacement.as_bytes(),
                value.map(|n| n as u64),
            )),
        }
    }

    pub(crate) fn split_all(
        lua: &Lua,
        this: &Self,
        (string, limit): (LuaString, Option<LuaInteger>),
    ) -> LuaResult<Vector> {
        match limit {
            Some(0) => Vector::lua_new(lua, (Some(0), None)),
            Some(n) if n < 0 => Err(LuaError::runtime(
                "Invalid negative limit for replace_all method",
            )),
            value => {
                let mut lua_strings_vec = Vec::new();

                for str in this
                    .inner
                    .split_all(&string.as_bytes(), value.map(|n| n as u64))
                {
                    let lua_str = lua.create_string(str)?;
                    lua_strings_vec.push(LuaValue::String(lua_str));
                }

                Vector::lua_of(lua, LuaVariadic::from(lua_strings_vec))
            }
        }
    }

    pub(crate) fn process_all(
        lua: &Lua,
        this: &Self,
        (string, callback, limit): (LuaString, Option<LuaFunction>, Option<LuaInteger>),
    ) -> LuaResult<()> {
        Ok(())
    }

    pub(crate) fn collect_all(
        lua: &Lua,
        this: &Self,
        (string, limit, output): (LuaString, Option<LuaInteger>, Option<LuaAnyUserData>),
    ) -> LuaResult<LuaAnyUserData> {
        let lua_vec = Vector::lua_new(lua, (Some(0), None));

        lua.create_any_userdata(lua_vec)
    }
}
