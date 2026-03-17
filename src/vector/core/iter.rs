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

    pub(in crate::vector) fn transform<F: Fn(LuaValue, usize) -> LuaResult<LuaValue>>(
        &mut self,
        transformer: F,
    ) -> Result<(), usize> {
        for i in 0..self.inner.len() {
            let value = self.inner[i].clone();
            let result = transformer(value, i);

            match result {
                Ok(v) => self.inner[i] = v,
                Err(_) => {
                    return Err(i);
                }
            }
        }
        Ok(())
    }

    pub(in crate::vector) fn keep<F: Fn(LuaValue, usize) -> LuaResult<LuaValue>>(
        &mut self,
        keeper: F,
    ) -> Result<(), usize> {
        let len = self.inner.len();
        let mut last = 0;

        for i in 0..len {
            let value = self.inner[i].clone();

            match keeper(value.clone(), i) {
                Ok(LuaValue::Boolean(true)) => {
                    self.inner[last] = value.clone();
                    last += 1;
                }
                Err(_) => {
                    self.inner[last] = value.clone();
                    self.clean(last + 1);
                    return Err(i);
                }
                Ok(_) => continue,
            }
        }

        self.clean(last);
        Ok(())
    }

    fn clean(&mut self, starting_index: usize) {
        for _ in starting_index..self.inner.len() {
            self.inner.pop();
        }
    }
}
