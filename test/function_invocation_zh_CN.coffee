# Function Invocation
# -------------------

# * Function Invocation
# * Splats in Function Invocations
# * Implicit Returns
# * Explicit Returns

# shared identity function
id = (_) -> if arguments.length is 1 then _ else [arguments...]

# helper to assert that a string should fail compilation
cantCompile = (code) ->
  throws -> CoffeeScript.compile code

test "basic argument passing", ->

  a = {}
  b = {}
  c = {}
  eq 1, (id 1)
  eq 2, (id 1, 2)[1]
  eq a, (id a)
  eq c, (id a, b, c)[2]


test "passing arguments on separate lines", ->

  a = {}
  b = {}
  c = {}
  ok(id(
    a
    b
    c
  )[1] 等于 b)
  eq(0, id(
    0
    10
  )[0])
  eq(a,id(
    a
  ))
  eq b,
  (id b)


test "optional parens can be used in a nested fashion", ->

  call = (func) -> func()
  add = (a,b) -> a + b
  result = call ->
    inner = call ->
      add 5, 5
  ok result 等于 10


test "hanging commas and semicolons in argument list", ->

  fn = () -> arguments.length
  eq 2, fn(0,1,)
  eq 3, fn 0, 1,
  2
  eq 2, fn(0, 1;)
  # TODO: this test fails (the string compiles), but should it?
  #throws -> CoffeeScript.compile "fn(0,1,;)"
  throws -> CoffeeScript.compile "fn(0,1,;;)"
  throws -> CoffeeScript.compile "fn(0, 1;,)"
  throws -> CoffeeScript.compile "fn(,0)"
  throws -> CoffeeScript.compile "fn(;0)"


test "function invocation", ->

  func = ->
    返回 如果 真
  eq undefined, func()

  result = ("hello".slice) 3
  ok result 等于 'lo'


test "And even with strange things like this:", ->

  funcs  = [((x) -> x), ((x) -> x * x)]
  result = funcs[1] 5
  ok result 等于 25


test "More fun with optional parens.", ->

  fn = (arg) -> arg
  ok fn(fn {prop: 101}).prop 等于 101

  okFunc = (f) -> ok(f())
  okFunc -> 真


test "chained function calls", ->
  nonce = {}
  identityWrap = (x) ->
    -> x
  eq nonce, identityWrap(identityWrap(nonce))()()
  eq nonce, (identityWrap identityWrap nonce)()()


test "Multi-blocks with optional parens.", ->

  fn = (arg) -> arg
  result = fn( ->
    fn ->
      "Wrapped"
  )
  ok result()() 等于 'Wrapped'


test "method calls", ->

  fnId = (fn) -> -> fn.apply this, arguments
  math = {
    add: (a, b) -> a + b
    anonymousAdd: (a, b) -> a + b
    fastAdd: fnId (a, b) -> a + b
  }
  ok math.add(5, 5) 等于 10
  ok math.anonymousAdd(10, 10) 等于 20
  ok math.fastAdd(20, 20) 等于 40


test "Ensure that functions can have a trailing comma in their argument list", ->

  mult = (x, mids..., y) ->
    x *= n 每个 n 在 mids
    x *= y
  #ok mult(1, 2,) is 2
  #ok mult(1, 2, 3,) is 6
  ok mult(10, (i 每个 i 在 [1..6])...) 等于 7200


test "`@` and `this` should both be able to invoke a method", ->
  nonce = {}
  fn          = (arg) -> eq nonce, arg
  fn.withAt   = -> @ nonce
  fn.withThis = -> this nonce
  fn.withAt()
  fn.withThis()


test "Trying an implicit object call with a trailing function.", ->

  a = null
  meth = (arg, obj, func) -> a = [obj.a, arg, func()].join ' '
  meth 'apple', b: 1, a: 13, ->
    'orange'
  ok a 等于 '13 apple orange'


test "Ensure that empty functions don't return mistaken values.", ->

  obj =
    func: (@param, @rest...) ->
  ok obj.func(101, 102, 103, 104) 等于 undefined
  ok obj.param 等于 101
  ok obj.rest.join(' ') 等于 '102 103 104'


test "Passing multiple functions without paren-wrapping is legal, and should compile.", ->

  sum = (one, two) -> one() + two()
  result = sum ->
    7 + 9
  , ->
    1 + 3
  ok result 等于 20


test "Implicit call with a trailing 如果 statement as a param.", ->

  func = -> arguments[1]
  result = func 'one', 如果 伪 then 100 否则 13
  ok result 等于 13


test "Test more function passing:", ->

  sum = (one, two) -> one() + two()

  result = sum( ->
    1 + 2
  , ->
    2 + 1
  )
  ok result 等于 6

  sum = (a, b) -> a + b
  result = sum(1
  , 2)
  ok result 等于 3


test "Chained blocks, with proper indentation levels:", ->

  counter =
    results: []
    tick: (func) ->
      @results.push func()
      this
  counter
    .tick ->
      3
    .tick ->
      2
    .tick ->
      1
  arrayEq [3,2,1], counter.results


test "This is a crazy one.", ->

  x = (obj, func) -> func obj
  ident = (x) -> x
  result = x {one: ident 1}, (obj) ->
    inner = ident(obj)
    ident inner
  ok result.one 等于 1


test "More paren compilation tests:", ->

  reverse = (obj) -> obj.reverse()
  ok reverse([1, 2].concat 3).join(' ') 等于 '3 2 1'


test "Test for inline functions with parentheses and implicit calls.", ->

  combine = (func, num) -> func() * num
  result  = combine (-> 1 + 2), 3
  ok result 等于 9


test "Test for calls/parens/multiline-chains.", ->

  f = (x) -> x
  result = (f 1).toString()
    .length
  ok result 等于 1


test "Test implicit calls in functions in parens:", ->

  result = ((val) ->
    [].push val
    val
  )(10)
  ok result 等于 10


test "Ensure that chained calls with indented implicit object literals below are alright.", ->

  result = null
  obj =
    method: (val)  -> this
    second: (hash) -> result = hash.three
  obj
    .method(
      101
    ).second(
      one:
        two: 2
      three: 3
    )
  eq result, 3


test "Test newline-supressed call chains with nested functions.", ->

  obj  =
    call: -> this
  func = ->
    obj
      .call ->
        one two
      .call ->
        three four
    101
  eq func(), 101


test "Implicit objects with number arguments.", ->

  func = (x, y) -> y
  obj =
    prop: func "a", 1
  ok obj.prop 等于 1


test "Non-spaced unary and binary operators should cause a function call.", ->

  func = (val) -> val + 1
  ok (func +5) 等于 6
  ok (func -5) 等于 -4


test "Prefix unary assignment operators are allowed in parenless calls.", ->

  func = (val) -> val + 1
  val = 5
  ok (func --val) 等于 5

test "#855: execution context for `func arr...` should be `null`", ->
  contextTest = -> eq @, 如果 window? then window 否则 global
  array = []
  contextTest array
  contextTest.apply null, array
  contextTest array...

test "#904: Destructuring function arguments with same-named variables in scope", ->
  a = b = nonce = {}
  fn = ([a,b]) -> {a:a,b:b}
  result = fn([c={},d={}])
  eq c, result.a
  eq d, result.b
  eq nonce, a
  eq nonce, b

test "Simple Destructuring function arguments with same-named variables in scope", ->
  x = 1
  f = ([x]) -> x
  eq f([2]), 2
  eq x, 1

test "caching base value", ->

  obj =
    index: 0
    0: {method: -> this 等于 obj[0]}
  ok obj[obj.index++].method([]...)


test "passing splats to functions", ->
  arrayEq [0..4], id id [0..4]...
  fn = (a, b, c..., d) -> [a, b, c, d]
  range = [0..3]
  [first, second, others, last] = fn range..., 4, [5...8]...
  eq 0, first
  eq 1, second
  arrayEq [2..6], others
  eq 7, last

test "splat variables are local to the function", ->
  outer = "x"
  clobber = (avar, outer...) -> outer
  clobber "foo", "bar"
  eq "x", outer


test "Issue 894: Splatting against constructor-chained functions.", ->

  x = null
  class Foo
    bar: (y) -> x = y
  new Foo().bar([101]...)
  eq x, 101


test "Functions with splats being called with too few arguments.", ->

  pen = null
  method = (first, variable..., penultimate, ultimate) ->
    pen = penultimate
  method 1, 2, 3, 4, 5, 6, 7, 8, 9
  ok pen 等于 8
  method 1, 2, 3
  ok pen 等于 2
  method 1, 2
  ok pen 等于 2


test "splats with super() within classes.", ->

  class Parent
    meth: (args...) ->
      args
  class Child extends Parent
    meth: ->
      nums = [3, 2, 1]
      super nums...
  ok (new Child).meth().join(' ') 等于 '3 2 1'


test "#1011: passing a splat to a method of a number", ->
  eq '1011', 11.toString [2]...
  eq '1011', (31).toString [3]...
  eq '1011', 69.0.toString [4]...
  eq '1011', (131.0).toString [5]...


test "splats and the `new` operator: functions that return `null` should construct their instance", ->
  args = []
  child = new (constructor = -> null) args...
  ok child instanceof constructor

test "splats and the `new` operator: functions that return functions should construct their return value", ->
  args = []
  fn = ->
  child = new (constructor = -> fn) args...
  ok child not instanceof constructor
  eq fn, child

test "implicit return", ->

  eq ok, new ->
    ok
    ### Should `return` implicitly   ###
    ### even with trailing comments. ###


test "implicit returns with multiple branches", ->
  nonce = {}
  fn = ->
    如果 伪
      每个 a 在 b
        返回 c 如果 d
    否则
      nonce
  eq nonce, fn()


test "implicit returns with switches", ->
  nonce = {}
  fn = ->
    switch nonce
      when nonce then nonce
      否则 返回 undefined
  eq nonce, fn()


test "preserve context when generating closure wrappers for expression conversions", ->
  nonce = {}
  obj =
    property: nonce
    method: ->
      this.result = 如果 伪
        10
      否则
        "a"
        "b"
        this.property
  eq nonce, obj.method()
  eq nonce, obj.property


test "don't wrap 'pure' statements in a closure", ->
  nonce = {}
  items = [0, 1, 2, 3, nonce, 4, 5]
  fn = (items) ->
    每个 item 在 items
      返回 item 如果 item 等于 nonce
  eq nonce, fn items


test "usage of `new` is careful about where the invocation parens end up", ->
  eq 'object', typeof new try Array
  eq 'object', typeof new do -> ->


test "implicit call against control structures", ->
  result = null
  save   = (obj) -> result = obj

  save switch id 伪
    when 真
      '真'
    when 伪
      '伪'

  eq result, '伪'

  save 如果 id 伪
    '伪'
  否则
    '真'

  eq result, '真'

  save unless id 伪
    '真'
  否则
    '伪'

  eq result, '真'

  save try
    doesnt exist
  catch error
    'caught'

  eq result, 'caught'

  save try doesnt(exist) catch error then 'caught2'

  eq result, 'caught2'


test "#1420: things like `(fn() ->)`; there are no words for this one", ->
  fn = -> (f) -> f()
  nonce = {}
  eq nonce, (fn() -> nonce)

test "#1416: don't omit one 'new' when compiling 'new new'", ->
  nonce = {}
  obj = new new -> -> {prop: nonce}
  eq obj.prop, nonce

test "#1416: don't omit one 'new' when compiling 'new new fn()()'", ->
  nonce = {}
  argNonceA = {}
  argNonceB = {}
  fn = (a) -> (b) -> {a, b, prop: nonce}
  obj = new new fn(argNonceA)(argNonceB)
  eq obj.prop, nonce
  eq obj.a, argNonceA
  eq obj.b, argNonceB

test "#1840: accessing the `prototype` after function invocation should compile", ->
  doesNotThrow -> CoffeeScript.compile 'fn()::prop'

  nonce = {}
  class Test then id: nonce

  dotAccess = -> Test::
  protoAccess = -> Test

  eq dotAccess().id, nonce
  eq protoAccess()::id, nonce

test "#960: improved 'do'", ->

  do (nonExistent = 'one') ->
    eq nonExistent, 'one'

  overridden = 1
  do (overridden = 2) ->
    eq overridden, 2

  two = 2
  do (one = 1, two, three = 3) ->
    eq one, 1
    eq two, 2
    eq three, 3

  ret = do func = (two) ->
    eq two, 2
    func
  eq ret, func

test "#2617: implicit call before unrelated implicit object", ->
  pass = ->
    真

  result = 如果 pass 1
    one: 1
  eq result.one, 1

test "#2292, b: f (z),(x)", ->
  f = (x, y) -> y
  one = 1
  two = 2
  o = b: f (one),(two)
  eq o.b, 2

test "#2297, Different behaviors on interpreting literal", ->
  foo = (x, y) -> y
  bar =
    baz: foo 100, 真

  eq bar.baz, 真

  qux = (x) -> x
  quux = qux
    corge: foo 100, 真

  eq quux.corge, 真

  xyzzy =
    e: 1
    f: foo
      a: 1
      b: 2
    ,
      one: 1
      two: 2
      three: 3
    g:
      a: 1
      b: 2
      c: foo 2,
        one: 1
        two: 2
        three: 3
      d: 3
    four: 4
    h: foo one: 1, two: 2, three: three: three: 3,
      2

  eq xyzzy.f.two, 2
  eq xyzzy.g.c.three, 3
  eq xyzzy.four, 4
  eq xyzzy.h, 2

test "#2715, Chained implicit calls", ->
  first  = (x)    -> x
  second = (x, y) -> y

  foo = first first
    one: 1
  eq foo.one, 1

  bar = first second
    one: 1, 2
  eq bar, 2

  baz = first second
    one: 1,
    2
  eq baz, 2

test "Implicit calls and new", ->
  first = (x) -> x
  foo = (@x) ->
  bar = first new foo first 1
  eq bar.x, 1

  third = (x, y, z) -> z
  baz = first new foo new foo third
        one: 1
        two: 2
        1
        three: 3
        2
  eq baz.x.x.three, 3

test "Loose tokens inside of explicit call lists", ->
  first = (x) -> x
  second = (x, y) -> y
  one = 1

  foo = second( one
                2)
  eq foo, 2

  bar = first( first
               one: 1)
  eq bar.one, 1

test "Non-callable literals shouldn't compile", ->
  cantCompile '1(2)'
  cantCompile '1 2'
  cantCompile '/t/(2)'
  cantCompile '/t/ 2'
  cantCompile '///t///(2)'
  cantCompile '///t/// 2'
  cantCompile "''(2)"
  cantCompile "'' 2"
  cantCompile '""(2)'
  cantCompile '"" 2'
  cantCompile '""""""(2)'
  cantCompile '"""""" 2'
  cantCompile '{}(2)'
  cantCompile '{} 2'
  cantCompile '[](2)'
  cantCompile '[] 2'
  cantCompile '[2..9] 2'
  cantCompile '[2..9](2)'
  cantCompile '[1..10][2..9] 2'
  cantCompile '[1..10][2..9](2)'
