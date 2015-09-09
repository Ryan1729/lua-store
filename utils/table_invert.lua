--i'm putting this (common?) lua-ism here to reduce dependencies.
-- http://stackoverflow.com/questions/9754285/in-lua-how-do-you-find-out-the-key-an-object-is-stored-in
local function table_invert(t)
  local u = {}
  for k, v in pairs(t) do u[v] = k end
  return u
end

return table_invert