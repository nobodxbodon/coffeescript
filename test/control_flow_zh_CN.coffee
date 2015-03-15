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
  否则 如果 false
    ok false
  否则
    ok true

  如果 true
    ok true
  否则 如果 true
    ok false
  否则
    ok true

  unless true
    ok false
  否则 unless true
    ok false
  否则
    ok true

  unless false
    ok true
  否则 unless false
    ok false
  否则
    ok true

test "single-line conditional", ->
  如果 false then ok false 否则 ok true
  unless false then ok true 否则 ok false

test "nested conditionals", ->
  nonce = {}
  eq nonce, (如果 true
    unless false
      如果 false then false 否则
        如果 true
          nonce)

test "nested single-line conditionals", ->
  nonce = {}

  a = 如果 false then undefined 否则 b = 如果 0 then undefined 否则 nonce
  eq nonce, a
  eq nonce, b

  c = 如果 false then undefined 否则 (如果 0 then undefined 否则 nonce)
  eq nonce, c

  d = 如果 true then id(如果 false then undefined 否则 nonce)
  eq nonce, d

test "empty conditional bodies", ->
  eq undefined, (如果 false
  否则 如果 false
  否则)

test "conditional bodies containing only comments", ->
  eq undefined, (如果 true
    ###
    block comment
    ###
  否则
    # comment
  )

  eq undefined, (如果 false
    # comment
  否则 如果 true
    ###
    block comment
    ###
  否则)

test "return value of if-else is from the proper body", ->
  nonce = {}
  eq nonce, 如果 false then undefined 否则 nonce

test "return value of unless-else is from the proper body", ->
  nonce = {}
  eq nonce, unless true then undefined 否则 nonce

test "assign inside the condition of a conditional statement", ->
  nonce = {}
  如果 a = nonce then 1
  eq nonce, a
  1 如果 b = nonce
  eq nonce, b


# Interactions With Functions

test "single-line function definition with single-line conditional", ->
  fn = -> 如果 1 < 0.5 then 1 否则 -1
  ok fn() is -1

test "function resturns conditional value with no `else`", ->
  fn = ->
    return 如果 false then true
  eq undefined, fn()

test "function returns a conditional value", ->
  a = {}
  fnA = ->
    return 如果 false then undefined 否则 a
  eq a, fnA()

  b = {}
  fnB = ->
    return unless false then b 否则 undefined
  eq b, fnB()

test "passing a conditional value to a function", ->
  nonce = {}
  eq nonce, id 如果 false then undefined 否则 nonce

test "unmatched `then` should catch implicit calls", ->
  a = 0
  trueFn = -> true
  如果 trueFn undefined then a++
  eq 1, a


# if-to-ternary

test "if-to-ternary with instanceof requires parentheses", ->
  nonce = {}
  eq nonce, (如果 {} instanceof Object
    nonce
  否则
    undefined)

test "if-to-ternary as part of a larger operation requires parentheses", ->
  ok 2, 1 + 如果 false then 0 否则 1


# Odd Formatting

test "if-else indented within an assignment", ->
  nonce = {}
  result =
    如果 false
      undefined
    否则
      nonce
  eq nonce, result

test "suppressed indentation via assignment", ->
  nonce = {}
  result =
    如果      false then undefined
    否则 如果 no    then undefined
    否则 如果 0     then undefined
    否则 如果 1 < 0 then undefined
    否则               id(
         如果 false then undefined
         否则          nonce
    )
  eq nonce, result

test "tight formatting with leading `then`", ->
  nonce = {}
  eq nonce,
  如果 true
  then nonce
  否则 undefined

test "#738: inline function defintion", ->
  nonce = {}
  fn = 如果 true then -> nonce
  eq nonce, fn()

test "#748: trailing reserved identifiers", ->
  nonce = {}
  obj = delete: true
  result = 如果 obj.delete
    nonce
  eq nonce, result

# Postfix

test "#3056: multiple postfix conditionals", ->
  temp = 'initial'
  temp = 'ignored' unless true 如果 false
  eq temp, 'initial'

# Loops

test "basic `while` loops", ->

  i = 5
  list = while i -= 1
    i * 2
  ok list.join(' ') is "8 6 4 2"

  i = 5
  list = (i * 3 while i -= 1)
  ok list.join(' ') is "12 9 6 3"

  i = 5
  func   = (num) -> i -= num
  assert = -> ok i < 5 > 0
  results = while func 1
    assert()
    i
  ok results.join(' ') is '4 3 2 1'

  i = 10
  results = while i -= 1 when i % 2 is 0
    i * 2
  ok results.join(' ') is '16 12 8 4'


test "Issue 759: `if` within `while` condition", ->

  2 while 如果 1 then 0


test "assignment inside the condition of a `while` loop", ->

  nonce = {}
  count = 1
  a = nonce while count--
  eq nonce, a
  count = 1
  while count--
    b = nonce
  eq nonce, b


test "While over break.", ->

  i = 0
  result = while i < 10
    i++
    break
  arrayEq result, []


test "While over continue.", ->

  i = 0
  result = while i < 10
    i++
    continue
  arrayEq result, []


test "Basic `until`", ->

  value = false
  i = 0
  results = until value
    value = true 如果 i is 5
    i++
  ok i is 6


test "Basic `loop`", ->

  i = 5
  list = []
  loop
    i -= 1
    break 如果 i is 0
    list.push i * 2
  ok list.join(' ') is '8 6 4 2'


test "break at the top level", ->
  for i in [1,2,3]
    result = i
    如果 i == 2
      break
  eq 2, result

test "break *not* at the top level", ->
  someFunc = ->
    i = 0
    while ++i < 3
      result = i
      break 如果 i > 1
    result
  eq 2, someFunc()

# Switch

test "basic `switch`", ->

  num = 10
  result = switch num
    when 5 then false
    when 'a'
      true
      true
      false
    when 10 then true


    # Mid-switch comment with whitespace
    # and multi line
    when 11 then false
    否则 false

  ok result


  func = (num) ->
    switch num
      when 2, 4, 6
        true
      when 1, 3, 5
        false

  ok func(2)
  ok func(6)
  ok !func(3)
  eq func(8), undefined


test "Ensure that trailing switch elses don't get rewritten.", ->

  result = false
  switch "word"
    when "one thing"
      doSomething()
    否则
      result = true unless false

  ok result

  result = false
  switch "word"
    when "one thing"
      doSomething()
    when "other thing"
      doSomething()
    否则
      result = true unless false

  ok result


test "Should be able to handle switches sans-condition.", ->

  result = switch
    when null                     then 0
    when !1                       then 1
    when '' not of {''}           then 2
    when [] not instanceof Array  then 3
    when true is false            then 4
    when 'x' < 'y' > 'z'          then 5
    when 'a' in ['b', 'c']        then 6
    when 'd' in (['e', 'f'])      then 7
    否则 ok

  eq result, ok


test "Should be able to use `@properties` within the switch clause.", ->

  obj = {
    num: 101
    func: ->
      switch @num
        when 101 then '101!'
        否则 'other'
  }

  ok obj.func() is '101!'


test "Should be able to use `@properties` within the switch cases.", ->

  obj = {
    num: 101
    func: (yesOrNo) ->
      result = switch yesOrNo
        when yes then @num
        否则 'other'
      result
  }

  ok obj.func(yes) is 101


test "Switch with break as the return value of a loop.", ->

  i = 10
  results = while i > 0
    i--
    switch i % 2
      when 1 then i
      when 0 then break

  eq results.join(', '), '9, 7, 5, 3, 1'


test "Issue #997. Switch doesn't fallthrough.", ->

  val = 1
  switch true
    when true
      如果 false
        return 5
    否则
      val = 2

  eq val, 1

# Throw

test "Throw should be usable as an expression.", ->
  try
    false or throw 'up'
    throw new Error 'failed'
  catch e
    ok e is 'up'


test "#2555, strange function if bodies", ->
  success = -> ok true
  failure = -> ok false

  success() 如果 do ->
    yes

  failure() 如果 try
    false

test "#1057: `catch` or `finally` in single-line functions", ->
  ok do -> try throw 'up' catch then yes
  ok do -> try yes finally 'nothing'

test "#2367: super in for-loop", ->
  class Foo
    sum: 0
    add: (val) -> @sum += val

  class Bar extends Foo
    add: (vals...) ->
      super val for val in vals
      @sum

  eq 10, (new Bar).add 2, 3, 5