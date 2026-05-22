use mlua::prelude::*;
use rand::{Rng, RngExt, SeedableRng, rngs::Xoshiro256PlusPlus};

pub(super) struct LuaRandom {
    generator: Xoshiro256PlusPlus,
}

impl LuaRandom {
    pub(super) fn new(seed: [u8; 32]) -> Self {
        let generator = Xoshiro256PlusPlus::from_seed(seed);

        Self { generator }
    }

    pub(super) fn boolean(&mut self, probability: LuaNumber) -> Result<bool, String> {
        match probability {
            p if !(0.0..=1.0).contains(&p) => {
                let msg = format!(
                    "The probability must be in the interval [0.0, 1.0], obtained {}",
                    p
                );
                Err(msg)
            }
            p => Ok(self.generator.random_bool(p)),
        }
    }

    pub(super) fn integer(
        &mut self,
        min: LuaInteger,
        max: LuaInteger,
        closed: bool,
    ) -> Result<LuaInteger, String> {
        match (min, max, closed) {
            (m, n, false) if n < m => Err(format!("Interval [{}, {}) is empty", m, n)),
            (m, n, true) if n < m => Err(format!("Interval [{}, {}] is empty", m, n)),
            (m, n, false) => Ok(self.generator.random_range(m..n)),
            (m, n, true) => Ok(self.generator.random_range(m..=n)),
        }
    }

    pub(super) fn number(
        &mut self,
        min: LuaNumber,
        max: LuaNumber,
        closed: bool,
    ) -> Result<LuaNumber, String> {
        match (min, max, closed) {
            (m, n, false) if n < m => Err(format!("Interval [{}, {}) is empty", m, n)),
            (m, n, true) if n < m => Err(format!("Interval [{}, {}] is empty", m, n)),
            (m, n, false) => {
                let mut value = self.generator.random_range(m..n);
                while value >= n {
                    value = self.generator.random_range(m..n);
                }
                Ok(value)
            }
            (m, n, true) => Ok(self.generator.random_range(m..=n)),
        }
    }
}

impl LuaRandom {
    pub(super) fn discard_value(&mut self) {
        self.generator.next_u64();
    }
}
