-- http://stackoverflow.com/questions/12674345/lua-retrieve-list-of-keys-in-a-table
local function keys(tbl)
  local n = 0
  local keyset = {}
  
  for k,_ in pairs(tbl) do
    n = n + 1
    keyset[n]=k
  end
  
  return keyset
end  

return keys
