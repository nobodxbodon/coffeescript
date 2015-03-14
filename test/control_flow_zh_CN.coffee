# 控制流
# ------------

# * 条件语句

# TODO: make sure postfix forms and expression coercion are properly tested

# shared identity function
id = (_) -> if arguments.length is 1 then _ else Array::slice.call(arguments)

# Conditionals

test "基本条件", ->
  如果 false
    ok false
  else if false
    ok false
  else
    ok true

