---@diagnostic disable: missing-return

local regex = {};

---@class Regex
local Regex = {};

---Tries to build a regex from the supplied string. Returns regex and nil if
---the string is valid UTF-8 and a valid pattern is formed. On failure,
---returns nil followed by an error message describing the occurrence.
---@param pattern string
---@return Regex | nil, string | nil
function regex.new(pattern)
end

---Determines whether the pattern exists within the given string. The search
---short-circuits upon finding the first occurrence for optimal performance.
---@param self Regex
---@param str string
---@return boolean
function Regex.test(self, str)
end

---
---@param self Regex
---@param str string
---@return table | nil
function Regex.find_first(self, str)
end

---
---@param str string
---@param cb fun(s: string): boolean
---@param limit integer?
function Regex.process_all(self, str, cb, limit)
end

---
---@param str string
---@param limit integer?
---@param vec Vector<string>?
---@return Vector<string>
function Regex.collect_all(self, str, limit, vec)
end

---Replaces occurrences of the pattern in the provided string with the
---replacement value. If no limit is specified, it replaces all occurrences
---found. If a limit is provided, it performs at most 'limit' substitutions.
---This function is internally optimized to use the most efficient
---replacement strategy based on the required number of operations.
---@param self Regex
---@param str string
---@param replacement string
---@param limit integer?
---@return string
function Regex.replace_all(self, str, replacement, limit)
end

---Splits the string exactly where the pattern occurs. When a limit is specified,
---it executes up to 'limit-1' splits, keeping the rest of the string as the final
---element in the returned Vector.
---@param self Regex
---@param str string
---@param limit integer?
---@return Vector<string>
function Regex.split_all(self, str, limit)
end

return regex;
