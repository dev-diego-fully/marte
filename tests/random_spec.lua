---@diagnostic disable: undefined-field

local random = require("marte.random");
local vector = require("marte.vector");

local generate_seeds, generate_sequence, generate_sequences;
local assert_sequences_are_differents;

local ZEROS_ULP = 2 ^ -1074;
local ONES_ULP = 2 ^ -52;
local MIN_INTEGER = math.mininteger or -(2 ^ 53);
local MAX_INTEGER = math.maxinteger or (2 ^ 53);
local MIN_FLOAT = -(2.0 ^ 53);
local MAX_FLOAT = (2.0 ^ 53);

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

describe("Random.integer", function()
    local SEQUENCE_LEN = 266;

    local INTERVAL_TEST_PAIRS = {
        { 0,           1 },
        { -1,          0 },
        { -1,          1 },
        { 0,           MAX_INTEGER },
        { MIN_INTEGER, MAX_INTEGER },
        { MIN_INTEGER, MAX_INTEGER },
    };

    local RANGE_CLOSENESS_TEST_PAIRS = {
        { 0,               1 }, { -1, 0 }, { -1, 1 },
        { MIN_INTEGER,     MIN_INTEGER + 1 },
        { MAX_INTEGER - 1, MAX_INTEGER },
    };

    ---
    ---@param generator Random
    ---@param min integer
    ---@param max integer
    ---@param closed boolean
    ---@return integer
    local function operation(generator, min, max, closed)
        return generator:integer(min, max, closed);
    end

    it("Should raise an error if min > max", function()
        local generator = random.new(0);

        for _, p in ipairs(INTERVAL_TEST_PAIRS) do
            local min, max = p[2], p[1];

            assert.has_errors(function()
                generator:integer(min, max, false);
            end);
            assert.has_errors(function()
                generator:integer(min, max, true);
            end);
        end
    end)

    it("Should always generate values within the [min, max] interval", function()
        local seed = 10;

        for _, p in ipairs(INTERVAL_TEST_PAIRS) do
            local min, max = p[1], p[2];
            local sequence = generate_sequence(
                seed, SEQUENCE_LEN,
                operation, min, max
            );

            for i = 1, #sequence, 1 do
                local value = sequence[i];

                assert.is.truthy(value >= min and value <= max);
            end
        end
    end)

    it("Should exclude the max value from the generation range if closed is absent or false", function()
        local seed = 11;

        for _, p in ipairs(RANGE_CLOSENESS_TEST_PAIRS) do
            local min, max = p[1], p[2];

            local sequence = generate_sequence(
                seed, SEQUENCE_LEN,
                operation, min, max, false
            );

            for i = 1, #sequence, 1 do
                local value = sequence[i];

                assert.is.truthy(value < max);
            end
        end
    end)

    it("Should include the max value in the generation range if closed is true", function()
        local seed = 12;

        for _, p in ipairs(RANGE_CLOSENESS_TEST_PAIRS) do
            local min, max = p[1], p[2];

            local sequence = generate_sequence(
                seed, SEQUENCE_LEN,
                operation, min, max, true
            );
            local seen_max = false;

            for i = 1, #sequence, 1 do
                if sequence[i] == max then
                    seen_max = true;
                end
            end

            if not seen_max then
                print(min, max);
            end

            assert.is.truthy(seen_max);
        end
    end)
end)

describe("Random.number", function()
    local SEQUENCE_LEN = 266;

    local INTERVAL_TEST_PAIRS = {
        { 0.0,       1.0 },
        { -1.0,      0.0 },
        { -1.0,      1.0 },
        { 0.0,       MAX_FLOAT },
        { MIN_FLOAT, MAX_FLOAT },
        { MIN_FLOAT, MAX_FLOAT },
    };

    local RANGE_CLOSENESS_TEST_PAIRS = {
        { 0.0,       ZEROS_ULP }, { -ZEROS_ULP, 0 }, { -ZEROS_ULP, ZEROS_ULP },
        { MIN_FLOAT, MIN_FLOAT + 1 }, { MAX_FLOAT - 1, MAX_FLOAT }
    };

    ---
    ---@param generator Random
    ---@param min number
    ---@param max number
    ---@param closed boolean
    ---@return number
    local function operation(generator, min, max, closed)
        return generator:number(min, max, closed);
    end

    it("Should raise an error if min > max", function()
        local generator = random.new(0);

        for _, p in ipairs(INTERVAL_TEST_PAIRS) do
            local min, max = p[2], p[1];

            assert.has_errors(function()
                generator:number(min, max, false);
            end);
            assert.has_errors(function()
                generator:number(min, max, true);
            end);
        end
    end)

    it("Should always generate values within the [min, max] interval", function()
        local seed = 10;

        for _, p in ipairs(INTERVAL_TEST_PAIRS) do
            local min, max = p[1], p[2];
            local sequence = generate_sequence(
                seed, SEQUENCE_LEN,
                operation, min, max
            );

            for i = 1, #sequence, 1 do
                local value = sequence[i];

                assert.is.truthy(value >= min and value <= max);
            end
        end
    end)

    it("Should exclude the max value from the generation range if closed is absent or false", function()
        local seed = 11;
        local options = vector.of(nil, false);

        for _, p in ipairs(RANGE_CLOSENESS_TEST_PAIRS) do
            for o = 1, #options, 1 do
                local min, max = p[1], p[2];

                local sequence = generate_sequence(
                    seed, SEQUENCE_LEN,
                    operation, min, max, options[o]
                );

                for i = 1, #sequence, 1 do
                    local value = sequence[i];

                    assert.is.truthy(
                        value < max,
                        ("min: %f, max: %f, value: %f"):format(min, max, value)
                    );
                end
            end
        end
    end)

    it("Should include the max value in the generation range if closed is true", function()
        local seed = 12;

        for _, p in ipairs(RANGE_CLOSENESS_TEST_PAIRS) do
            local min, max = p[1], p[2];

            local sequence = generate_sequence(
                seed, SEQUENCE_LEN,
                operation, min, max, true
            );
            local seen_max = false;

            for i = 1, #sequence, 1 do
                if sequence[i] == max then
                    seen_max = true;
                end
            end

            assert.is.truthy(seen_max, ("min: %f, max: %f"):format(min, max));
        end
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
        local probability = 1.0 + ONES_ULP;

        for seed in ipairs(TESTS_SEEDS) do
            local generator = random.new(seed);

            assert.has_errors(function()
                generator:boolean(probability);
            end)
        end
    end)

    it("Should raise an error if the probability is less than 0.0", function()
        local probability = -ZEROS_ULP;

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
