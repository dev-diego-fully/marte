---@meta marte.random

---@class random
local random = {};

--- Creates an instance of a PRNG using the provided integers as a seed.
--- One or two integer values can be used to seed the generator.
--- If no seed is provided, the generator will be initialized using
--- a randomly generated seed.
---@param s1 integer?
---@param s2 integer?
---@return Random
function random.new(s1, s2)
end

--- Creates an instance of a PRNG using the provided integers as a seed.
--- One or two integer values can be used to seed the generator.
--- If no seed is provided, the generator will be initialized using
--- a randomly generated seed.
---@class Random
local Random = {};

--- Returns a random integer value in the interval [min, max) if closed is
--- false, and [min, max] if closed is true.
--- Raises an error if min > max.
---@param self Random
---@param min integer
---@param max integer
---@param closed boolean?
---@return integer
function Random.integer(self, min, max, closed)
end

--- Returns a random floating-point value in the interval [min, max) if
--- closed is false, and [min, max] if closed is true.
--- Raises an error if min > max.
---@param self Random
---@param min number
---@param max number
---@param closed boolean?
---@return number
function Random.number(self, min, max, closed)
end

--- Returns a random boolean value according to the provided probability.
--- The chance of returning true is equal to the probability, and the
--- chance of returning false is 1 - probability.
--- Raises an error if probability > 1.0 or probability < 0.0.
---@param self Random
---@param probability number
---@return boolean
function Random.boolean(self, probability)
end

---@type random
local core = require("_marte.random");

return core;
