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

    pub(in crate::vector) fn transform<F>(&mut self, transformer: F) -> Result<(), usize>
    where
        F: Fn(LuaValue, usize) -> Result<LuaValue, LuaInteger>,
    {
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

    pub(in crate::vector) fn keep<F>(&mut self, keeper: F) -> Result<(), usize>
    where
        F: Fn(LuaValue, usize) -> Result<LuaValue, LuaInteger>,
    {
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

    pub(in crate::vector) fn foldl<F>(
        &self,
        folder: F,
        initial: Option<LuaValue>,
    ) -> Result<LuaValue, LuaInteger>
    where
        F: Fn(LuaValue, LuaValue, usize) -> Result<LuaValue, LuaInteger>,
    {
        if self.inner.is_empty() {
            return match initial {
                Some(v) => Ok(v),
                None => Ok(LuaNil),
            };
        }
        let (mut result_value, skip) = match initial {
            Some(v) => (v, 0),
            None => (self.inner[0].clone(), 1),
        };
        for i in (0..self.inner.len()).skip(skip) {
            let value = self.inner[i].clone();
            result_value = folder(result_value.clone(), value, i)?;
        }
        Ok(result_value)
    }

    pub(in crate::vector) fn foldr<F>(
        &self,
        folder: F,
        initial: Option<LuaValue>,
    ) -> Result<LuaValue, LuaInteger>
    where
        F: Fn(LuaValue, LuaValue, usize) -> Result<LuaValue, LuaInteger>,
    {
        if self.inner.is_empty() {
            return match initial {
                Some(v) => Ok(v),
                None => Ok(LuaNil),
            };
        }
        let (mut result_value, skip) = match initial {
            Some(v) => (v, 0),
            None => (self.inner.last().unwrap().clone(), 1),
        };
        for i in (0..self.inner.len()).rev().skip(skip) {
            let value = self.inner[i].clone();
            result_value = folder(result_value.clone(), value, i)?;
        }
        Ok(result_value)
    }

    pub(in crate::vector) fn sort<F>(&mut self, comparer: F) -> Result<(), (LuaValue, LuaValue)>
    where
        F: Fn(LuaValue, LuaValue) -> Result<bool, (LuaValue, LuaValue)>,
    {
        self.quicksort(&comparer, 0 as LuaInteger, self.len())?;
        Ok(())
    }

    fn quicksort<F>(
        &mut self,
        comparer: &F,
        begin: LuaInteger,
        end: LuaInteger,
    ) -> Result<(), (LuaValue, LuaValue)>
    where
        F: Fn(LuaValue, LuaValue) -> Result<bool, (LuaValue, LuaValue)>,
    {
        if begin >= (end - 1) {
            return Ok(());
        }
        let (mut i, mut j) = (begin, end - 1);
        let pivot_index = (begin + (end - begin) / 2) as usize;
        let pivot = self.inner[pivot_index].clone();

        while i <= j {
            while i < end {
                let a = self.inner[i as usize].clone();

                match comparer(a.clone(), pivot.clone()) {
                    Ok(true) => i += 1,
                    Ok(false) => break,
                    Err(v) => return Err(v),
                }
            }
            while j >= begin {
                let b = self.inner[j as usize].clone();

                match comparer(pivot.clone(), b.clone()) {
                    Ok(true) => j -= 1,
                    Ok(false) => break,
                    Err(v) => return Err(v),
                }
            }
            if i <= j {
                self.inner.swap(i as usize, j as usize);
                i += 1;
                j -= 1;
            }
        }

        if begin < j {
            self.quicksort(comparer, begin, j + 1)?;
        }
        if i < end {
            self.quicksort(comparer, i, end)?;
        }
        Ok(())
    }

    fn clean(&mut self, starting_index: usize) {
        for _ in starting_index..self.inner.len() {
            self.inner.pop();
        }
    }
}
