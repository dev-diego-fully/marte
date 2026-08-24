local random = require("marte.random");
local vector = require("marte.vector");

local utils = {};

local MIN_SEED, MAX_SEED;

local GENERATOR_OPERATION = {};

local generate_sequence;

---
---@param source_seed integer
---@param count integer
---@return integer[]
function utils.generate_seeds(source_seed, count)
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

utils.generate_sequence = {};


---
---@param seed integer
---@param len integer
---@param min integer
---@param max integer
---@param closed boolean
---@return Vector<integer>
function utils.generate_sequence.integer(seed, len, min, max, closed)
    return generate_sequence(seed, len, GENERATOR_OPERATION.integer, min, max, closed)
end

---
---@param seed integer
---@param len integer
---@param min number
---@param max number
---@param closed boolean
---@return Vector<number>
function utils.generate_sequence.number(seed, len, min, max, closed)
    return generate_sequence(seed, len, GENERATOR_OPERATION.number, min, max, closed)
end

---
---@param seed integer
---@param len integer
---@param probability number
---@return Vector<boolean>
function utils.generate_sequence.boolean(seed, len, probability)
    return generate_sequence(seed, len, GENERATOR_OPERATION.boolean, probability)
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

---
---@param generator Random
---@param min integer
---@param max integer
---@param closed boolean
---@return integer
function GENERATOR_OPERATION.integer(generator, min, max, closed)
    return generator:integer(min, max, closed);
end

---
---@param generator Random
---@param min number
---@param max number
---@param closed boolean
---@return number
function GENERATOR_OPERATION.number(generator, min, max, closed)
    return generator:number(min, max, closed);
end

---
---@param gen Random
---@param probability number
---@return boolean
function GENERATOR_OPERATION.boolean(gen, probability)
    return gen:boolean(probability);
end

if math.maxinteger then
    MIN_SEED, MAX_SEED = -2 ^ 61, 2 ^ 61;
else
    MIN_SEED, MAX_SEED = -2 ^ 30, 2 ^ 30;
end

return utils;
