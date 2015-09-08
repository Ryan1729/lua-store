local actionCreators = {}

function actionCreators.addTodo(text) 
  return { type = "ADD_TODO", text = text }
end

function actionCreators.addTodoIfEmpty(text)
  return function(dispatch, getState)
    if #getState() == 0 then
      dispatch(actionCreators.addTodo(text));
    end
  end
end

function actionCreators.throwError()
  return {
    type = "THROW_ERROR"
  }
end

return actionCreators