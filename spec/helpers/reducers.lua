local reduce = require("utils.reduce")
local copy = require("utils.copy")
local push = table.insert
local pop = table.remove

local reducers = {}

local function id(state) 
  state = state or {}
  return reduce(function (result, item)
    return (item.id and item.id > result) and item.id or result
  end, 0, state) + 1
end

function reducers.todos(state, action)
  local newState = copy(state or {})

  if action.type == "ADD_TODO" then
    push(newState, {
      id = id(state),
      text = action.text
    })
    return newState
  else
    return newState
  end
end

function reducers.todosReverse(state, action)
  local newState = copy(state or {})

  if action.type == "ADD_TODO" then
    push(newState, 1, {
      id = id(state),
      text = action.text
    })
    return newState
  else
    return newState
  end
end

function reducers.errorThrowingReducer(state, action)
  state = state or {}
  if action.type == "THROW_ERROR" then
    error("requested error")
  else
    return state
  end
end

return reducers