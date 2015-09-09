local reduce = require("utils.reduce")

-- Picks key-value pairs from an object where values satisfy a predicate.
local function pick(obj, fn)
  return reduce(function(result, _, key)
    if fn(obj[key]) then
      result[key] = obj[key]
    end
    return result
  end, {}, obj)
end

return pick 
