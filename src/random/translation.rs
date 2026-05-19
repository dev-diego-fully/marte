use mlua::prelude::*;

use super::LuaRandom;

pub(super) type LuaRandomFacade = Random;

pub(super) struct Random {
    inner: LuaRandom,
}

impl Random {
    const FIXED_VALUE_1: LuaInteger = 0xff;
    const FIXED_VALUE_2: LuaInteger = 0;

    pub(super) fn new(
        _: &Lua,
        (seed1, seed2): (Option<LuaInteger>, Option<LuaInteger>),
    ) -> LuaResult<Self> {
        let (s1, s2) = match (seed1, seed2) {
            (None, None) => (0, 0),
            (None, Some(s)) => (0, s),
            (Some(s), None) => (s, 0),
            (Some(s1), Some(s2)) => (s1, s2),
        };

        Ok(Self {
            inner: Self::create_inner_engine(s1, s2),
        })
    }

    pub(super) fn integer(
        lua: &Lua,
        this: &mut Self,
        (min, max): (LuaInteger, LuaInteger),
    ) -> LuaResult<LuaInteger> {
        Ok(0)
    }

    pub(super) fn number(
        lua: &Lua,
        this: &mut Self,
        (min, max): (LuaNumber, LuaNumber),
    ) -> LuaResult<LuaNumber> {
        Ok(0.0)
    }

    pub(super) fn boolean(
        lua: &Lua,
        this: &mut Self,
        (prob,): (Option<LuaNumber>,),
    ) -> LuaResult<LuaValue> {
        Ok(LuaValue::Boolean(false))
    }
}

impl Random {
    fn to_rust_seed(a: LuaInteger, b: LuaInteger, c: LuaInteger, d: LuaInteger) -> [u8; 32] {
        let mut seed = [0u8; 32];

        for (i, &s) in [a, b, c, d].iter().enumerate() {
            let (first, last) = (i, i + 8);
            seed[first..last].copy_from_slice(&s.to_be_bytes());
        }

        seed
    }

    fn create_inner_engine(seed1: LuaInteger, seed2: LuaInteger) -> LuaRandom {
        let seed = Self::to_rust_seed(seed1, Self::FIXED_VALUE_1, seed2, Self::FIXED_VALUE_2);
        let mut inner = LuaRandom::new(seed);

        for _ in 0..16 {
            inner.discard_value();
        }

        inner
    }
}
