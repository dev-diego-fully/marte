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
}
