---@diagnostic disable: undefined-field

local vector = require("marte.vector")

describe("copy", function()
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

describe("reverse", function()
    it("Returns the original vector passed as an argument", function()
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
