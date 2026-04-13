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

---
---@param self Regex
---@param str string
---@return boolean
function Regex.matches(self, str)
end

---
---@param self Regex
---@param str string
---@return string
function Regex.match(self, str)
end

---
---@param self Regex
---@param str string
---@param vec_or_op Vector<table>|fun(str: table)
---@return Vector<table> | nil
function Regex.match_all(self, str, vec_or_op)
end

---
---@param self Regex
---@param str string
---@param replacement string
---@return string
function Regex.replace(self, str, replacement)
end

---
---@param self Regex
---@param str string
---@param replacement string
---@return string
function Regex.replace_all(self, str, replacement)
end

---
---@param self Regex
---@param str string
---@return Vector<string>
function Regex.split(self, str)
end

return regex;
