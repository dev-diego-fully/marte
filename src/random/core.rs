use rand::{Rng, SeedableRng, rngs::Xoshiro256PlusPlus};

pub(super) struct LuaRandom {
    generator: Xoshiro256PlusPlus,
}

impl LuaRandom {
    pub(super) fn new(seed: [u8; 32]) -> Self {
        let generator = Xoshiro256PlusPlus::from_seed(seed);

        Self { generator }
    }
}

impl LuaRandom {
    pub(super) fn discard_value(&mut self) {
        self.generator.next_u64();
    }
}
