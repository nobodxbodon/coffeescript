# 控制流
# ------------

# * 条件语句

# TODO: make sure postfix forms and expression coercion are properly tested

# shared identity function
id = (_) -> if arguments.length is 1 then _ else Array::slice.call(arguments)

# Conditionals

test "基本条件", ->
  如果 伪
    ok 伪
  否则 如果 伪
    ok 伪
  否则
    ok 真

  如果 真
    ok 真
  否则 如果 真
    ok 伪
  否则
    ok 真

  unless 真
    ok 伪
  否则 unless 真
    ok 伪
  否则
    ok 真

  unless 伪
    ok 真
  否则 unless 伪
    ok 伪
  否则
    ok 真

test "single-line conditional", ->
  如果 伪 then ok 伪 否则 ok 真
  unless 伪 then ok 真 否则 ok 伪

test "nested conditionals", ->
  nonce = {}
  eq nonce, (如果 真
    unless 伪
      如果 伪 then 伪 否则
        如果 真
          nonce)

test "nested single-line conditionals", ->
  nonce = {}

  a = 如果 伪 then undefined 否则 b = 如果 0 then undefined 否则 nonce
  eq nonce, a
  eq nonce, b

  c = 如果 伪 then undefined 否则 (如果 0 then undefined 否则 nonce)
  eq nonce, c

  d = 如果 真 then id(如果 伪 then undefined 否则 nonce)
  eq nonce, d

test "empty conditional bodies", ->
  eq undefined, (如果 伪
  否则 如果 伪
  否则)

test "conditional bodies containing only comments", ->
  eq undefined, (如果 真
    ###
    block comment
    ###
  否则
    # comment
  )

  eq undefined, (如果 伪
    # comment
  否则 如果 真
    ###
    block comment
    ###
  否则)

test "return value of if-else is from the proper body", ->
  nonce = {}
  eq nonce, 如果 伪 then undefined 否则 nonce

test "return value of unless-else is from the proper body", ->
  nonce = {}
  eq nonce, unless 真 then undefined 否则 nonce

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
    返回 如果 伪 then 真
  eq undefined, fn()

test "function returns a conditional value", ->
  a = {}
  fnA = ->
    返回 如果 伪 then undefined 否则 a
  eq a, fnA()

  b = {}
  fnB = ->
    返回 unless 伪 then b 否则 undefined
  eq b, fnB()

test "passing a conditional value to a function", ->
  nonce = {}
  eq nonce, id 如果 伪 then undefined 否则 nonce

test "unmatched `then` should catch implicit calls", ->
  a = 0
  trueFn = -> 真
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
  ok 2, 1 + 如果 伪 then 0 否则 1


# Odd Formatting

test "if-else indented within an assignment", ->
  nonce = {}
  result =
    如果 伪
      undefined
    否则
      nonce
  eq nonce, result

test "suppressed indentation via assignment", ->
  nonce = {}
  result =
    如果      伪 then undefined
    否则 如果 no    then undefined
    否则 如果 0     then undefined
    否则 如果 1 < 0 then undefined
    否则               id(
         如果 伪 then undefined
         否则          nonce
    )
  eq nonce, result

test "tight formatting with leading `then`", ->
  nonce = {}
  eq nonce,
  如果 真
  then nonce
  否则 undefined

test "#738: inline function defintion", ->
  nonce = {}
  fn = 如果 真 then -> nonce
  eq nonce, fn()

test "#748: trailing reserved identifiers", ->
  nonce = {}
  obj = delete: 真
  result = 如果 obj.delete
    nonce
  eq nonce, result

# Postfix

test "#3056: multiple postfix conditionals", ->
  temp = 'initial'
  temp = 'ignored' unless 真 如果 伪
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

  value = 伪
  i = 0
  results = until value
    value = 真 如果 i is 5
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
    when 5 then 伪
    when 'a'
      真
      真
      伪
    when 10 then 真


    # Mid-switch comment with whitespace
    # and multi line
    when 11 then 伪
    否则 伪

  ok result


  func = (num) ->
    switch num
      when 2, 4, 6
        真
      when 1, 3, 5
        伪

  ok func(2)
  ok func(6)
  ok !func(3)
  eq func(8), undefined


test "Ensure that trailing switch elses don't get rewritten.", ->

  result = 伪
  switch "word"
    when "one thing"
      doSomething()
    否则
      result = 真 unless 伪

  ok result

  result = 伪
  switch "word"
    when "one thing"
      doSomething()
    when "other thing"
      doSomething()
    否则
      result = 真 unless 伪

  ok result


test "Should be able to handle switches sans-condition.", ->

  result = switch
    when null                     then 0
    when !1                       then 1
    when '' not of {''}           then 2
    when [] not instanceof Array  then 3
    when 真 is 伪            then 4
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
        when 真 then @num
        否则 'other'
      result
  }

  ok obj.func(真) is 101


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
    when 真
      如果 伪
        返回 5
    否则
      val = 2

  eq val, 1

# Throw

test "Throw should be usable as an expression.", ->
  try
    伪 或 throw 'up'
    throw new Error 'failed'
  catch e
    ok e is 'up'


test "#2555, strange function if bodies", ->
  success = -> ok 真
  failure = -> ok 伪

  success() 如果 do ->
    真

  failure() 如果 try
    伪

test "#1057: `catch` or `finally` in single-line functions", ->
  ok do -> try throw 'up' catch then 真
  ok do -> try 真 finally 'nothing'

test "#2367: super in for-loop", ->
  class Foo
    sum: 0
    add: (val) -> @sum += val

  class Bar extends Foo
    add: (vals...) ->
      super val for val in vals
      @sum

  eq 10, (new Bar).add 2, 3, 5