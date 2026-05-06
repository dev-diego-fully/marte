use std::collections::HashMap;

use super::core::LuaRegex;
use crate::vector::Vector;
use mlua::prelude::*;
use regex::bytes::Captures;

pub(crate) type LuaRegexFacade = Regex;
pub(in crate::regex) type LuaMatchFacade = Match;

pub(crate) struct Regex {
    inner: LuaRegex,
}

impl LuaRegexFacade {
    pub(in crate::regex) fn new(
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

    pub(in crate::regex) fn test(
        _: &Lua,
        this: &Self,
        (string,): (LuaString,),
    ) -> LuaResult<LuaValue> {
        let matched = this.inner.test(&string.as_bytes());

        Ok(LuaValue::Boolean(matched))
    }

    pub(in crate::regex) fn find_first(
        lua: &Lua,
        this: &Self,
        (string,): (LuaString,),
    ) -> LuaResult<Option<Match>> {
        Ok(match this.inner.find_first(&string.as_bytes()) {
            Some(caps) => Some(Match::from(lua, &caps, this.inner.capture_names())?),
            None => None,
        })
    }

    pub(in crate::regex) fn replace_all(
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

    pub(in crate::regex) fn split_all(
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

    pub(in crate::regex) fn process_all(
        lua: &Lua,
        this: &Self,
        (string, callback, limit): (LuaString, LuaFunction, Option<LuaInteger>),
    ) -> LuaResult<()> {
        let lim = match limit {
            Some(n) if n < 0 => return Err(LuaError::runtime("Invalid limit negativa value")),
            Some(n) => Some(n as u64),
            None => None,
        };

        let operation = |mat: &Captures<'_>, index: usize| {
            let lua_match = match LuaMatchFacade::from(lua, mat, this.inner.capture_names()) {
                Ok(matc) => matc,
                Err(_) => return Err("Error parsing rust Match"),
            };
            let lua_index = (index + 1) as LuaInteger;

            let result = match callback.call::<LuaValue>((lua_match, lua_index)) {
                Ok(v) => v,
                Err(_) => return Err("Error parsing lua result"),
            };

            match result {
                LuaValue::Boolean(boolean) => Ok(boolean),
                LuaNil => Ok(false),
                _ => Ok(true),
            }
        };

        match this.inner.process_all(&string.as_bytes(), operation, lim) {
            Err(msg) => Err(LuaError::runtime(msg)),
            _ => Ok(()),
        }
    }

    pub(in crate::regex) fn collect_all(
        lua: &Lua,
        this: &Self,
        (string, limit, output): (LuaString, Option<LuaInteger>, Option<LuaAnyUserData>),
    ) -> LuaResult<LuaAnyUserData> {
        let output = match output {
            Some(aud) => aud,
            None => {
                let vec = Vector::lua_new(lua, (None, None))?;
                lua.create_any_userdata(vec)?
            }
        };

        let mut vec = output.borrow_mut()?;

        for cap in this
            .inner
            .collect_all(&string.as_bytes(), limit.map(|u| u as u64))
        {
            let mat = LuaMatchFacade::from(lua, &cap, this.inner.capture_names())?;
            let lua_match = mat.into_lua(lua)?;

            Vector::push(lua, &mut vec, (lua_match,))?;
        }

        Ok(output)
    }
}

pub(in crate::regex) struct Match {
    enumarateds: Vec<Option<LuaString>>,
    nameds: HashMap<LuaString, usize>,
}

impl LuaMatchFacade {
    pub(in crate::regex) fn from<'a>(
        lua: &Lua,
        captures: &Captures,
        names: impl Iterator<Item = Option<&'a str>>,
    ) -> LuaResult<Self> {
        let mut nameds = HashMap::new();

        for (i, s) in names.enumerate() {
            if let Some(key) = s {
                nameds.insert(lua.create_string(key)?, i);
            }
        }

        let mut enums = Vec::new();

        for opt_match in captures.iter() {
            match opt_match {
                Some(mat) => {
                    let s = lua.create_string(mat.as_bytes())?;
                    enums.push(Some(s));
                }
                None => enums.push(None),
            }
        }

        Ok(Self {
            enumarateds: enums,
            nameds,
        })
    }

    pub(in crate::regex) fn index(
        _: &Lua,
        this: &Self,
        (key,): (LuaEither<LuaInteger, LuaString>,),
    ) -> LuaResult<Option<LuaString>> {
        let index = match key {
            LuaEither::Left(i) if i >= 0 => Some(i as usize),
            LuaEither::Right(s) => this.nameds.get(&s).cloned(),
            _ => return Err(LuaError::runtime("Invalid negative index for Match object")),
        };
        let index = match index {
            None => return Ok(None),
            Some(i) => i,
        };
        if index <= this.enumarateds.len() {
            return Ok(this.enumarateds[index].clone());
        }
        Ok(None)
    }

    pub(in crate::regex) fn newindex(_: &Lua, _: &Self, _: (LuaValue, LuaValue)) -> LuaResult<()> {
        Err(LuaError::runtime("Match objects are immutable"))
    }

    pub(in crate::regex) fn equals(
        _: &Lua,
        this: &Self,
        other: LuaAnyUserData,
    ) -> LuaResult<LuaValue> {
        let mtc = match other.borrow::<LuaMatchFacade>() {
            Ok(udr) => udr,
            Err(_) => return Ok(LuaValue::Boolean(false)),
        };
        let equality = this.enumarateds == mtc.enumarateds;

        Ok(LuaValue::Boolean(equality))
    }

    pub(in crate::regex) fn len(_: &Lua, this: &Self, _: ()) -> LuaResult<usize> {
        let len = this.enumarateds.len();

        if len == 0 {
            return Err(LuaError::runtime("Invalid empty Match object"));
        }

        Ok(this.enumarateds.len() - 1)
    }
}
