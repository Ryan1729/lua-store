-- put the data, (what will change the most,) last to encourage partial application
-- see "Hey Underscore, You're Doing It Wrong!" https://www.youtube.com/watch?v=m3svKOdZijA 
local function reduce (func, memo, tbl)
  for k, v in pairs(tbl) do
    memo = func(memo, v, k, tbl)
  end
  
  return memo
end

return reduce