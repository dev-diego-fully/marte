use super::LuaVector;

impl LuaVector {
    pub(in crate::vector) fn copy(&self) -> Self {
        Self::of(self.inner.to_vec())
    }
}
