---@diagnostic disable: undefined-field

local random = require("marte.random");
local vector = require("marte.vector");

local generate_seeds, generate_sequence;
local EPSILON = 2 ^ -52;

describe("random.new", function()
    local prob = 0.5;

    it("Should accept no seed", function()
        assert.has.no_errors(
            function()
                local generator = random.new();
                generator:boolean(prob);
            end
        );
    end)

    it("Should accept one integer as a seed", function()
        local int_1 = 5;

        assert.has.no_errors(function()
            local generator = random.new(int_1);
            generator:boolean(prob);
        end)
    end)

    it("Should accept two integers as a seed", function()
        local int_1 = 2;
        local int_2 = 100;

        assert.has.no_errors(function()
            local generator = random.new(int_1, int_2);
            generator:boolean(prob);
        end)
    end)

    it("Should accept 0 as a seed", function()
        local int_1 = 0;

        assert.has.no_errors(function()
            local generator = random.new(int_1);
            generator:boolean(prob);
        end)
    end)

    it("Should accept 0, 0 as a seed", function()
        local int_1 = 0;
        local int_2 = 0;

        assert.has.no_errors(function()
            local generator = random.new(int_1, int_2);
            generator:boolean(prob);
        end)
    end)
end)

describe("Random.boolean", function()
    local BOOLEAN_SOURCE_SEED = 12;
    local TESTS_SEEDS = generate_seeds(BOOLEAN_SOURCE_SEED, 10);
    local SEQUENCES_LEN = 266;

    ---
    ---@param gen Random
    ---@param probability number
    ---@return boolean
    local function operation(gen, probability)
        return gen:boolean(probability);
    end

    it("Should always return false if the provided probability is 0.0", function()
        local probability = 0.0;

        for _, seed in ipairs(TESTS_SEEDS) do
            local sequence = generate_sequence(
                seed, SEQUENCES_LEN, operation, probability
            );

            for i = 1, #sequence, 1 do
                local value = sequence[i];

                assert.is.falsy(value);
            end
        end
    end)

    it("Should raise an error if the probability is greater than 1.0", function()
        local probability = 1.0 + EPSILON;

        for seed in ipairs(TESTS_SEEDS) do
            local generator = random.new(seed);

            assert.has_errors(function()
                generator:boolean(probability);
            end)
        end
    end)

    it("Should raise an error if the probability is less than 0.0", function()
        local probability = -EPSILON;

        for seed in ipairs(TESTS_SEEDS) do
            local generator = random.new(seed);

            assert.has_errors(function()
                generator:boolean(probability);
            end)
        end
    end)
end)

local MIN_SEED, MAX_SEED;
if math.maxinteger then
    MIN_SEED, MAX_SEED = -2 ^ 62, 2 ^ 62;
else
    MIN_SEED, MAX_SEED = -2 ^ 30, 2 ^ 30;
end

---
---@param source_seed integer
---@param count integer
---@return integer[]
function generate_seeds(source_seed, count)
    local seeds = {};
    local seens_seed = {};

    math.randomseed(source_seed);

    while #seeds < count do
        local candidate = math.random(MIN_SEED, MAX_SEED);
        if seens_seed[candidate] == nil then
            seens_seed[candidate] = true;
            table.insert(seeds, candidate);
        end
    end

    return seeds;
end

---
---@generic T
---@param seed integer
---@param len integer
---@param operation fun(r: Random, ...): T
---@return Vector<T>
function generate_sequence(seed, len, operation, ...)
    local generator = random.new(seed);
    local sequence = vector.new();

    for _ = 1, len, 1 do
        local value = operation(generator, ...);

        sequence:push(value);
    end

    return sequence;
end
