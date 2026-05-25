---@diagnostic disable: undefined-field

local vector = require("marte.vector")

describe("Vector.copy", function()
    local original_vec, returned_vec, backup_vec;

    before_each(function()
        original_vec = vector.of(1, 2, 3, 4, 5, 6);
        backup_vec = vector.of(1, 2, 3, 4, 5, 6);
        returned_vec = original_vec:copy();
    end)

    it("Returns a new Vector", function()
        assert.is.falsy(
            original_vec:is_same(returned_vec),
            "This is returning the original Vector"
        )
    end)

    it("It does not modify the original Vector.", function()
        assert.are.equals(
            original_vec, backup_vec,
            "It's not leaving the original Vector intact"
        )
    end)

    it("The returned Vector is equal to the original Vector", function()
        assert.are.equals(
            original_vec, returned_vec,
            "The new Vector is not a copy of the original Vector"
        )
    end)
end)

describe("Vector.reverse", function()
    it("Returns the original vector provided as an argument.", function()
        local original_vec = vector.of(1, 2, 3, 4, 5, 6);
        local reversed_vec = original_vec:reverse();

        assert.is.truthy(
            reversed_vec:is_same(original_vec),
            "The method is creating a new vector"
        );
    end)

    it("Correctly inverts an even-sized vector", function()
        local reversed_vec = vector.of(3, 4, 5, 6, 7, 8):reverse();
        local expected_vec = vector.of(8, 7, 6, 5, 4, 3);

        assert.are.equals(
            reversed_vec, expected_vec,
            "It is failing to sort an even-sized vector"
        );
    end)

    it("Correctly inverts an odd-sized vector", function()
        local reversed_vec = vector.of(1, 2, 3, 4, 5):reverse();
        local expected_vec = vector.of(5, 4, 3, 2, 1);

        assert.are.equals(
            reversed_vec, expected_vec,
            "It is failing to sort an odd-sized vector"
        );
    end)
end)

describe("Vector.transform", function()
    it("Returns the original vector provided as an argument", function()
        local original_vec = vector.of(1, 2, 3, 4, 5, 6);
        local returned_vec = original_vec:transform(function(v) return v end);

        assert.is.truthy(
            original_vec:is_same(returned_vec),
            "It is creating a new Vector"
        );
    end)

    it("Applies the transformation function to each element in the vector", function()
        local transformed_vec = vector.of(1, 2, 3, 4, 5, 6);
        local expected_vec = vector.of(2, 4, 6, 8, 10, 12);

        transformed_vec:transform(function(v) return 2 * v end);

        assert.are.equals(
            transformed_vec, expected_vec,
            "The transformation function is not being applied to all elements of the Vector"
        );
    end)

    it("Provides Lua indices for the transformation function", function()
        local transformed_vec = vector.new(5);
        local expected_vec = vector.of(1, 2, 3, 4, 5);
        transformed_vec:transform(function(_, i) return i end);

        assert.are.equals(
            transformed_vec, expected_vec,
            "It is not correctly providing Lua vectors to the transformation function"
        )
    end)
end)

describe("Vector.keep", function()
    it("Returns the original vector passed as an argument", function()
        local original_vec = vector.of(1, 2, 3, 4, 5);
        local returned_vec = original_vec:keep(function(v, _) return v % 2 == 0 end);

        assert.is.truthy(
            original_vec:is_same(returned_vec),
            "This is creating a new Vector"
        );
    end)

    it("Keep in the vector only the elements that returned true in the function", function()
        local original_vec = vector.of(1, 2, 3, 4, 5);
        local expected_vec = vector.of(2, 4);

        original_vec:keep(function(v, _) return v % 2 == 0 end);

        assert.are.equals(
            original_vec, expected_vec,
            "It's not correctly filtering the elements that end up in the vector"
        );
    end)

    it("It must provide the lua index for the filtering function.", function()
        local original_vec = vector.of("A", "B", "C", "D", "E");
        local expected_vec = vector.of("A", "C", "E");

        original_vec:keep(function(_, i)
            return i % 2 == 1
        end
        );

        assert.are.equals(
            original_vec, expected_vec,
            "It is not correctly providing a Lua index for the filtering function"
        );
    end)

    it("The operation should be aborted upon encountering an error, leaving the vector in a coherent state", function()
        local original_vec = vector.of(1, 2, 3, 4, 5, 6);
        local expected_vec = vector.of(2, 4, 5);
        local keeper = function(v, _)
            if v >= 5 then
                error("Something goes wrong!");
            else
                return v % 2 == 0
            end
        end;

        assert.has.errors(
            function()
                original_vec:keep(keeper);
            end,
            nil,
            "It should raise an error if the filtering function throws an error"
        );

        assert.are.equals(
            original_vec, expected_vec,
            "Should leave only the filtered elements and the problematic element (at the end) in the vector"
        );
    end)
end)

describe("Vector.foldl", function()
    it("Reduces the entire vector to a single value using the reduction function", function()
        local base_vec = vector.of(1, 2, 3);
        local expected_value = 6;

        local result = base_vec:foldl(function(acc, v, _) return acc + v end);

        assert.are.equals(
            result, expected_value,
            "Reduction is not being performed correctly"
        );
    end)

    it("Accepts an optional value as the initial value", function()
        local base_vec = vector.of(1, 2, 3);
        local initial_value = 4;
        local expected_value = 10;

        local result = base_vec:foldl(
            function(acc, v, _) return acc + v end,
            initial_value
        );

        assert.are.equals(
            result, expected_value,
            "Fails to use the initial value when provided"
        );
    end)

    it("Iterate through the vector in the forward direction", function()
        local base_vector = vector.of(1, 2, 3, 4);
        local expected_vector = vector.of(1, 2, 3, 4);

        local pusher = function(vec, elem)
            vec:push(elem)
            return vec
        end

        base_vector:foldl(pusher, vector.new());

        assert.are.equals(
            base_vector, expected_vector,
            "The iteration is not following the standard direction"
        );
    end)

    it("Provides Lua indices to the reduction function", function()
        local base_vec = vector.new(5);
        local expected_vec = vector.of(1, 2, 3, 4, 5);

        local function index_pusher(vec, _, index)
            vec:push(index);

            return vec;
        end

        local result_vec = base_vec:foldl(index_pusher, vector.new());

        assert.are.equals(
            result_vec, expected_vec,
            "Is not correctly providing Lua indices to the reduction function"
        );
    end)

    it("Does not modify the provided vector", function()
        local base_vec = vector.of(2, 3, 4, 5, 7);
        local expected_vec = vector.of(2, 3, 4, 5, 7);

        base_vec:foldl(function(acc, v) return acc + v end)

        assert.are.equals(
            base_vec, expected_vec,
            "It is modifying the original vector"
        );
    end)
end)

describe("Vector.foldr", function()
    it("Reduces the entire vector to a single value using the reduction function", function()
        local base_vec = vector.of(1, 2, 3);
        local expected_value = 6;

        local result = base_vec:foldr(function(acc, v, _) return acc + v end);

        assert.are.equals(
            result, expected_value,
            "Reduction is not being performed correctly"
        );
    end)

    it("Accepts an optional value as the initial value", function()
        local base_vec = vector.of(1, 2, 3);
        local initial_value = 4;
        local expected_value = 10;

        local result = base_vec:foldr(
            function(acc, v, _) return acc + v end,
            initial_value
        );

        assert.are.equals(
            result, expected_value,
            "Fails to use the initial value when provided"
        );
    end)

    it("Iterate through the vector in the backward direction", function()
        local base_vector = vector.of(1, 2, 3, 4);
        local expected_vector = vector.of(4, 3, 2, 1);

        local function pusher(vec, elem)
            vec:push(elem)
            return vec
        end

        local result_vec = base_vector:foldr(pusher, vector.new());

        assert.are.equals(
            result_vec, expected_vector,
            "The iteration direction is not reversed"
        );
    end)

    it("Provides Lua indices to the reduction function", function()
        local base_vec = vector.new(5);
        local expected_vec = vector.of(5, 4, 3, 2, 1);

        local function index_pusher(vec, _, index)
            vec:push(index);

            return vec;
        end

        local result_vec = base_vec:foldr(index_pusher, vector.new());

        assert.are.equals(
            result_vec, expected_vec,
            "Is not correctly providing Lua indices to the reduction function"
        );
    end)

    it("Does not modify the provided vector", function()
        local base_vec = vector.of(2, 3, 4, 5, 7);
        local expected_vec = vector.of(2, 3, 4, 5, 7);

        base_vec:foldr(function(acc, v) return acc + v end)

        assert.are.equals(
            base_vec, expected_vec,
            "It is modifying the original vector"
        );
    end)
end)

describe("Vector.sort", function()
    it("Returns the original vector", function()
        local base_vec = vector.of(3, 1);
        local result_vec = base_vec:sort();

        assert.is.truthy(
            base_vec:is_same(result_vec),
            "It is modifying the original vector"
        );
    end)

    it("Sort the given vector", function()
        local base_vec = vector.of(9, 2, 5, 7, 5, 4, 1);
        local expected_vec = vector.of(1, 2, 4, 5, 5, 7, 9);
        base_vec:sort();

        assert.are.equals(
            base_vec, expected_vec,
            "Fails to sort the supplied vector correctly"
        )
    end)

    it("It does not cause errors when used in empty vectors", function()
        local base_vec = vector.new();

        assert.has.no_errors(
            function()
                base_vec:sort();
            end, nil,
            "Fails to handle empty vectors, causing errors"
        )
    end)

    it("Use the comparison function if it is provided", function()
        local base_vec = vector.of(1, 2, 3, 4, 5, 6);
        local expected_vec = vector.of(6, 5, 4, 3, 2, 1);
        base_vec:sort(function(a, b) return a > b end);

        assert.are.equals(
            base_vec, expected_vec,
            "The comparison function is not being applied correctly for sorting"
        );
    end)
end)

describe("Vector.for_each", function()
    it("Executes the iteration function for each element of the vector", function()
        local base_vec = vector.of(1, 2, 3, 4, 5);
        local count = 0;

        base_vec:for_each(function(_) count = count + 1 end);

        assert.are.equals(
            count, #base_vec,
            "Fails to visit every vector element once"
        )
    end)

    it("Does not modify the provided vector", function()
        local base_vec = vector.of(2, 3, 4, 5, 7);
        local expected_vec = vector.of(2, 3, 4, 5, 7);

        base_vec:for_each(function(v, i) return v + i end)

        assert.are.equals(
            base_vec, expected_vec,
            "It is modifying the original vector"
        );
    end)

    it("Iterates through the vector in the forward direction", function()
        local base_vec = vector.of(4, 5, 3, 2, 9, 0);
        local result_vec = vector.new();

        base_vec:for_each(function(v) result_vec:push(v) end);

        assert.are.equals(
            result_vec, base_vec,
            "It is not iterating through the vector in the correct direction"
        );
    end)

    it("Provides Lua indices to the iteration function", function()
        local base_vec = vector.new(8);
        local result_vec = vector.new();
        local expected_vec = vector.of(1, 2, 3, 4, 5, 6, 7, 8);

        base_vec:for_each(function(_, i) result_vec:push(i) end)

        assert.are.equals(
            result_vec, expected_vec,
            "Fails to pass correct Lua indices to the iteration function"
        );
    end)
end)
