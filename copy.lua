--  let's keep dependancies down by writng a few things here ourselves ...
local function copy(tbl)
  local res = {}
  
  for k,v in pairs(tbl) do
      res[k] = v
  end
  
  return res
end

return copy