---@diagnostic disable: undefined-field

local vector = require("marte.vector");

describe("Uses one-based indexing", function()
    describe("Should consider the first index as 1", function()
        it("In the get method", function()
            local expected = 0;

            local vec = vector.new();
            vec:push(expected);

            local _, value = vec:get(1);
            assert.are.equals(expected, value);
        end);

        it("In the set method", function()
            local initial = 0;
            local expected = "first";

            local vec = vector.new();
            vec:push(initial);
            vec:set(1, expected);

            local _, value = vec:get(1);

            assert.are.equals(expected, value);
        end);

        it("In the __index meta method", function()
            local expected = 0;

            local vec = vector.new();
            vec:push(expected);

            assert.has.no_errors(function()
                assert.are.equals(expected, vec[1]);
            end);
        end);

        it("In the __newindex meta method", function()
            local initial = 0;
            local expected = "first";

            local vec = vector.new();
            vec:push(initial);
            vec[1] = expected;

            assert.has.no_errors(function()
                assert.are.equals(expected, vec[1]);
            end);
        end);
    end);

    describe("Should consider the last index as the length", function()
        it("In the get method", function()
            local expected = "value";
            local vec = vector.of(nil, nil, nil, expected);
            local is_present, value = vec:get(#vec);

            assert.is.truthy(is_present);
            assert.are.equals(expected, value);
        end);

        it("In the set method", function()
            local initial = "initital"
            local expected = "expected";

            local vec = vector.of(nil, nil, nil, initial);
            local is_present = vec:set(#vec, expected);

            assert.is.truthy(is_present);
            assert.are.equals(expected, vec[#vec]);
        end);

        it("In the __index meta method", function()
            local expected = "expected";

            local vec = vector.of(nil, nil, nil, expected);

            assert.are.equals(expected, vec[#vec]);
        end);

        it("In the __newindex meta method", function()
            local initial = "initial";
            local expected = "expected";

            local vec = vector.of(nil, nil, nil, initial);
            vec[#vec] = expected;

            assert.are.equals(expected, vec[#vec]);
        end);
    end);
end);

describe("Supports negative indexing", function()
    describe("Should treat -1 as the last element of the Vector", function()
        local base_vector;

        before_each(function()
            base_vector = vector.of(5, 6, 7, 8);
        end)

        it("In the get method", function()
            local _, last_value = base_vector:get(#base_vector);
            local _, value = base_vector:get(-1);

            assert.are.equals(last_value, value);
        end);

        it("In the set method", function()
            local new_value = 10;

            base_vector:set(-1, new_value);
            local _, last_value = base_vector:get(#base_vector);
            local _, value = base_vector:get(-1);

            assert.are.equals(last_value, value);
            assert.are.equals(new_value, value);
        end);

        it("In the __index meta method", function()
            assert.has.no_errors(function()
                local last_value = base_vector[#base_vector]
                local value = base_vector[-1];

                assert.are.equals(last_value, value);
            end)
        end);

        it("In the __newindex meta method", function()
            local new_value = 20;

            assert.has.no_errors(function()
                base_vector[-1] = new_value;

                local last_value = base_vector[#base_vector];
                local value = base_vector[-1];

                assert.are.equals(last_value, value);
                assert.are.equals(new_value, value);
            end)
        end);
    end);

    describe("Should treat -#vec as the first element of the Vector", function()
        local base_vector;

        before_each(function()
            base_vector = vector.of(5, 6, 7, 8);
        end)

        it("In the get method", function()
            local _, first_value = base_vector:get(1);
            local _, value = base_vector:get(- #base_vector);

            assert.are.equals(first_value, value);
        end);

        it("In the set method", function()
            local new_value = 10;

            base_vector:set(- #base_vector, new_value);
            local _, first_value = base_vector:get(1);
            local _, value = base_vector:get(- #base_vector);

            assert.are.equals(first_value, value);
            assert.are.equals(new_value, value);
        end);

        it("In the __index meta method", function()
            assert.has.no_errors(function()
                local first_value = base_vector[1];
                local value = base_vector[- #base_vector];

                assert.are.equals(first_value, value);
            end)
        end);

        it("In the __newindex meta method", function()
            local new_value = 20;

            assert.has.no_errors(function()
                base_vector[- #base_vector] = new_value;
                local first_value = base_vector[1];
                local value = base_vector[- #base_vector];

                assert.are.equals(first_value, value)
                assert.are.equals(new_value, value);
            end)
        end);
    end);
end)

describe("vector.new", function()
    it("Should create an empty vector", function()
        local vec = vector.new();
        assert.are.equals(0, #vec);
    end);

    it("Should create an array of given size padded with nils", function()
        local expected_len = 10;
        local vec = vector.new(expected_len);

        assert.are.equals(expected_len, #vec);

        for i = 1, expected_len, 1 do
            assert.are.equals(nil, vec[i]);
        end
    end);

    it("Should create an array of given size filled with the provided value", function()
        local expected_len = 10;
        local vec = vector.new(expected_len, true);

        assert.are.equals(expected_len, #vec);

        for i = 1, expected_len, 1 do
            assert.are.equals(true, vec[i]);
        end
    end);
end);

describe("Vector.of", function()
    it("Should create a vector with the provided elements", function()
        local expecteds = { 0, 1, 2, 3 };
        local vec = vector.of(0, 1, 2, 3);

        assert.are.equals(4, #vec);

        for i, _ in ipairs(expecteds) do
            assert.are.equals(expecteds[i], vec[i]);
        end
    end);
end)

describe("Vector.get", function()
    it("Should return a present element along with a presence indicator", function()
        local expected_value = 10;

        local vec = vector.new();
        vec:push(expected_value);

        local is_present, value = vec:get(1);

        assert.is.truthy(is_present);
        assert.are.equals(expected_value, value);
    end);

    it("Should treat nils as present values", function()
        local vec = vector.new();
        vec:push(nil);

        local is_present, value = vec:get(1);

        assert.is.truthy(is_present);
        assert.are.equals(nil, value);
    end);

    it("Should return not present/nil for indices outside the bounds", function()
        local out_of_bound_index = 2

        local vec = vector.new();
        vec:push(10);

        local is_present, value = vec:get(out_of_bound_index);

        assert.is.falsy(is_present);
        assert.are.equals(nil, value);
    end);
end);

describe("Vector.set", function()
    it("Should return true for indices within the Vector bounds", function()
        local len = 5;
        local tested_index = 2;

        local vec = vector.new(len);
        local succeed = vec:set(tested_index, false);

        assert.is.truthy(succeed);
    end);

    it("Should return false for indices outside the Vector bounds", function()
        local len = 5;
        local tested_index = len + 1;

        local vec = vector.new(len);
        local succeed = vec:set(tested_index, false);

        assert.is.falsy(succeed);
    end);
end);

describe("Vector.push", function()
    describe("Increase the size of the current vector", function()
        local starting_len = 5;
        local expected_len = starting_len + 1;

        local vec = vector.new(starting_len);
        vec:push(nil);

        assert.are.equals(expected_len, #vec);
    end);

    describe("Adds a new element at the end of the Vector", function()
        local initial_len = 10
        local expected = "expected";

        local vec = vector.new(initial_len);
        vec:push(expected);

        assert.are.equals(expected, vec[#vec]);
    end);
end)

describe("Vector.pop", function()
    it("Should return a failure flag and nil on an empty Vector", function()
        local vec = vector.new();

        local is_present, value = vec:pop();

        assert.is.falsy(is_present);
        assert.are.equals(nil, value);
    end);

    it("Should return success and the last element on a non-empty vector", function()
        local expected_value = true;

        local vec = vector.of(nil, nil, nil, expected_value);
        local is_present, value = vec:pop();

        assert.is.truthy(is_present);
        assert.are.equals(expected_value, value);
    end);

    it("Should remove and return the last element of the Vector", function()
        local expected_value = "expected";
        local expected_len = 3;

        local vec = vector.of(true, false, nil, expected_value);

        local _, value = vec:pop();

        assert.are.equals(expected_len, #vec);
        assert.are.equals(expected_value, value);
    end);
end);

describe("Vector.is_same", function()
    local base_vector;

    before_each(function()
        base_vector = vector.of(1, 2, 3, 4);
    end);

    it("Should return true for the same vector instance", function()
        assert.is.truthy(base_vector:is_same(base_vector));
    end);

    it("Should return false for distinct but equal vectors", function()
        local other_vector = vector.of(1, 2, 3, 4);

        assert.is.falsy(base_vector:is_same(other_vector));
    end);

    it("Should return false for different vectors", function()
        local other_vector = vector.of(2, 3, 1, 4);

        assert.is.falsy(base_vector:is_same(other_vector));
    end);
end)

describe("Vector.__index", function()
    it("Should raise an error for indices outside the Vector's bounds", function()
        local vec = vector.of(4, 6, 5, 7);

        assert.has.errors(function()
            local _ = vec[#vec + 1];
        end);
    end);

    it("Should retrieve the value without using presence flags", function()
        local expected = 4;
        local vec = vector.of(expected);
        local value = vec[1];

        assert.are.equals(expected, value);
    end);
end);

describe("Vector.__newindex", function()
    it("Should raise an error for indices outside the Vector's bounds", function()
        local vec = vector.of(4, 6, 5, 7);

        assert.has.errors(function()
            vec[#vec + 1] = 10;
        end);
    end);

    it("Should modify the value at a valid index", function()
        local len = 10;
        local expected = true;
        local vec = vector.new(len, false);

        assert.has.no_errors(function()
            vec[len] = expected;
        end);

        assert.are.equals(expected, vec[len]);
    end);
end);

describe("Vector.__len", function()
    it("Should return 0 for empty vectors", function()
        local expected_len = 0;
        local vec = vector.new();

        assert.are.equals(expected_len, #vec);
    end);

    it("Should be correct for a Vector created with elements", function()
        local expected_len = 5;
        local vec = vector.new(expected_len, nil);

        assert.are.equals(expected_len, #vec);
    end);

    it("Should increase with each new insertion", function()
        local max_tested_len = 100;
        local vec = vector.new();

        for expected_len = 1, max_tested_len, 1 do
            vec:push(true);
            assert.are.equals(expected_len, #vec);
        end
    end);

    it("Should decrease with each removal", function()
        local max_tested_len = 100;
        local vec = vector.new(max_tested_len);

        for expected_len = max_tested_len, 0, 1 do
            vec:pop();
            assert.are.equals(expected_len, #vec);
        end
    end);
end)

describe("Vector.__eq", function()
    local base_vector;

    before_each(function()
        base_vector = vector.of(1, 2, 3, 4);
    end)

    it("Should be true for self-comparison", function()
        assert.are.equals(base_vector, base_vector);
    end);

    it("Should be true for vectors with equal elements in the same order", function()
        local other_vector = vector.of(1, 2, 3, 4);

        assert.are.equals(base_vector, other_vector);
    end);

    it("Should be false for vectors with the same elements in a different order", function()
        local other_vector = vector.of(4, 3, 2, 1);

        assert.are.not_equals(base_vector, other_vector);
    end);
end)
