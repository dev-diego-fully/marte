---@diagnostic disable: undefined-field

local random = require("marte.random");
local vector = require("marte.vector");
local utils = require("marte._testsutils.random");

local ZEROS_ULP = 2 ^ -1074;
local ONES_ULP = 2 ^ -52;
local MIN_INTEGER = math.mininteger or -(2 ^ 53);
local MAX_INTEGER = math.maxinteger or (2 ^ 53);
local MIN_FLOAT = -(2.0 ^ 53);
local MAX_FLOAT = (2.0 ^ 53);

local get_seed = (function()
    local seeds = utils.generate_seeds(0, 10);
    local current = 0;

    return function()
        current = current + 1;

        return seeds[current];
    end
end)();

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
        local seed = get_seed();

        for _, p in ipairs(INTERVAL_TEST_PAIRS) do
            local min, max = p[1], p[2];
            local sequence = utils.generate_sequence.integer(
                seed, SEQUENCE_LEN,
                min, max, true
            );

            for i = 1, #sequence, 1 do
                local value = sequence[i];

                assert.is.truthy(value >= min and value <= max);
            end
        end
    end)

    it("Should exclude the max value from the generation range if closed is absent or false", function()
        local seed = get_seed();

        for _, p in ipairs(RANGE_CLOSENESS_TEST_PAIRS) do
            local min, max = p[1], p[2];

            local sequence = utils.generate_sequence.integer(
                seed, SEQUENCE_LEN,
                min, max, false
            );

            for i = 1, #sequence, 1 do
                local value = sequence[i];

                assert.is.truthy(value < max);
            end
        end
    end)

    it("Should include the max value in the generation range if closed is true", function()
        local seed = get_seed();

        for _, p in ipairs(RANGE_CLOSENESS_TEST_PAIRS) do
            local min, max = p[1], p[2];

            local sequence = utils.generate_sequence.integer(
                seed, SEQUENCE_LEN,
                min, max, true
            );
            local seen_max = false;

            for i = 1, #sequence, 1 do
                if sequence[i] == max then
                    seen_max = true;
                end
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
        local seed = get_seed();

        for _, p in ipairs(INTERVAL_TEST_PAIRS) do
            local min, max = p[1], p[2];
            local sequence = utils.generate_sequence.number(
                seed, SEQUENCE_LEN,
                min, max, true
            );

            for i = 1, #sequence, 1 do
                local value = sequence[i];

                assert.is.truthy(value >= min and value <= max);
            end
        end
    end)

    it("Should exclude the max value from the generation range if closed is absent or false", function()
        local seed = get_seed();
        local options = vector.of(nil, false);

        for _, p in ipairs(RANGE_CLOSENESS_TEST_PAIRS) do
            for o = 1, #options, 1 do
                local min, max = p[1], p[2];

                local sequence = utils.generate_sequence.number(
                    seed, SEQUENCE_LEN,
                    min, max, options[o]
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
        local seed = get_seed();

        for _, p in ipairs(RANGE_CLOSENESS_TEST_PAIRS) do
            local min, max = p[1], p[2];

            local sequence = utils.generate_sequence.number(
                seed, SEQUENCE_LEN,
                min, max, true
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
    local SEQUENCES_LEN = 266;

    it("Should always return false if the provided probability is 0.0", function()
        local seed = get_seed();
        local probability = 0.0;

        local sequence = utils.generate_sequence.boolean(
            seed, SEQUENCES_LEN, probability
        );

        for i = 1, #sequence, 1 do
            local value = sequence[i];

            assert.is.falsy(value);
        end
    end)

    it("Should raise an error if the probability is greater than 1.0", function()
        local seed = get_seed();

        local probability = 1.0 + ONES_ULP;

        local generator = random.new(seed);

        assert.has_errors(function()
            generator:boolean(probability);
        end)
    end)

    it("Should raise an error if the probability is less than 0.0", function()
        local seed = get_seed();
        local probability = -ZEROS_ULP;

        local generator = random.new(seed);

        assert.has_errors(function()
            generator:boolean(probability);
        end)
    end)
end)

describe("Deterministic nature", function()
    local SEQUENCE_LEN = 266;

    describe("Two instances with equal seeds and the same generated value count:", function()
        it("Should return the same sequence when using the integer method", function()
            local seeds = utils.generate_seeds(10, 10);
            local min, max, closed = 0, 1, true;

            for _, seed in ipairs(seeds) do
                local seq_1 = utils.generate_sequence.integer(
                    seed, SEQUENCE_LEN, min, max, closed
                );
                local seq_2 = utils.generate_sequence.integer(
                    seed, SEQUENCE_LEN, min, max, closed
                );

                assert.are.equals(seq_1, seq_2);
            end
        end)

        it("Should return the same sequence when using the number method", function()
            local seeds = utils.generate_seeds(20, 10);
            local min, max, closed = 0, ZEROS_ULP, true;

            for _, seed in ipairs(seeds) do
                local seq_1 = utils.generate_sequence.number(
                    seed, SEQUENCE_LEN, min, max, closed
                );
                local seq_2 = utils.generate_sequence.number(
                    seed, SEQUENCE_LEN, min, max, closed
                );

                assert.are.equals(seq_1, seq_2);
            end
        end)

        it("Should return the same sequence when using the boolean method", function()
            local seeds = utils.generate_seeds(20, 10);
            local prob = 0.5;

            for _, seed in ipairs(seeds) do
                local seq_1 = utils.generate_sequence.boolean(
                    seed, SEQUENCE_LEN, prob
                );
                local seq_2 = utils.generate_sequence.boolean(
                    seed, SEQUENCE_LEN, prob
                );

                assert.are.equals(seq_1, seq_2);
            end
        end)
    end)

    describe("Two instances with different seeds and the same generated value count:", function()
        it("Should return a different sequence when using the integer method", function()
            local seeds = utils.generate_seeds(10, 10);
            local min, max, closed = 0, 1, true;

            for i = 1, #seeds - 1, 1 do
                local seed_1 = seeds[i];

                for j = i + 1, #seeds, 1 do
                    local seed_2 = seeds[j];

                    local seq_1 = utils.generate_sequence.integer(
                        seed_1, SEQUENCE_LEN,
                        min, max, closed
                    );
                    local seq_2 = utils.generate_sequence.integer(
                        seed_2, SEQUENCE_LEN,
                        min, max, closed
                    );

                    assert.are.not_equals(seq_1, seq_2);
                end
            end
        end)

        it("Should return a different sequence when using the number method", function()
            local seeds = utils.generate_seeds(10, 10);
            local min, max, closed = 0, ZEROS_ULP, true;

            for i = 1, #seeds - 1, 1 do
                local seed_1 = seeds[i];

                for j = i + 1, #seeds, 1 do
                    local seed_2 = seeds[j];

                    local seq_1 = utils.generate_sequence.number(
                        seed_1, SEQUENCE_LEN,
                        min, max, closed
                    );
                    local seq_2 = utils.generate_sequence.number(
                        seed_2, SEQUENCE_LEN,
                        min, max, closed
                    );

                    assert.are.not_equals(seq_1, seq_2);
                end
            end
        end)

        it("Should return a different sequence when using the boolean method", function()
            local seeds = utils.generate_seeds(10, 10);
            local prob = 0.5;

            for i = 1, #seeds - 1, 1 do
                local seed_1 = seeds[i];

                for j = i + 1, #seeds, 1 do
                    local seed_2 = seeds[j];

                    local seq_1 = utils.generate_sequence.boolean(
                        seed_1, SEQUENCE_LEN, prob
                    );
                    local seq_2 = utils.generate_sequence.boolean(
                        seed_2, SEQUENCE_LEN, prob
                    );

                    assert.are.not_equals(seq_1, seq_2);
                end
            end
        end)
    end)
end)
