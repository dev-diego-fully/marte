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
}

impl LuaRandom {
    pub(super) fn discard_value(&mut self) {
        self.generator.next_u64();
    }
}
