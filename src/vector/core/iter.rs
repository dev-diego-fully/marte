use mlua::prelude::*;

use super::LuaVector;

impl LuaVector {
    pub(in crate::vector) fn copy(&self) -> Self {
        Self::of(self.inner.to_vec())
    }

    pub(in crate::vector) fn reverse(&mut self) {
        let len = self.inner.len();

        for i in 0..len / 2 {
            self.inner.swap(i, len - 1 - i);
        }
    }

    pub(in crate::vector) fn transform<F: Fn(LuaValue, LuaInteger) -> LuaResult<LuaValue>>(
        &mut self,
        transformer: F,
    ) -> Result<(), String> {
        for i in 0..self.inner.len() {
            let lua_index = (i + 1) as LuaInteger;
            let value = self.inner[i].clone();
            let result = transformer(value, lua_index);

            match result {
                Ok(v) => self.inner[i] = v,
                Err(_) => {
                    return Err(format!(
                        "Error trying to transform the {} nth element",
                        lua_index
                    ));
                }
            }
        }
        Ok(())
    }
}
