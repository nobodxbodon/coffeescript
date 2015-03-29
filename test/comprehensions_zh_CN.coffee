# Comprehensions
# --------------

# * Array Comprehensions
# * Range Comprehensions
# * Object Comprehensions
# * Implicit Destructuring Assignment
# * Comprehensions with Nonstandard Step

# TODO: refactor comprehension tests

test "Basic array comprehensions.", ->

  nums    = (n * n 每个 n 在 [1, 2, 3] when n & 1)
  results = (n * 2 每个 n 在 nums)

  ok results.join(',') 等于 '2,18'


test "Basic object comprehensions.", ->

  obj   = {one: 1, two: 2, three: 3}
  names = (prop + '!' 每个 prop of obj)
  odds  = (prop + '!' 每个 prop, value of obj when value & 1)

  ok names.join(' ') 等于 "one! two! three!"
  ok odds.join(' ')  等于 "one! three!"


test "Basic range comprehensions.", ->

  nums = (i * 3 每个 i 在 [1..3])

  negs = (x 每个 x 在 [-20..-5*2])
  negs = negs[0..2]

  result = nums.concat(negs).join(', ')

  ok result 等于 '3, 6, 9, -20, -19, -18'


test "With range comprehensions, you can loop in steps.", ->

  results = (x 每个 x 在 [0...15] by 5)
  ok results.join(' ') 等于 '0 5 10'

  results = (x 每个 x 在 [0..100] by 10)
  ok results.join(' ') 等于 '0 10 20 30 40 50 60 70 80 90 100'


test "And can loop downwards, with a negative step.", ->

  results = (x 每个 x 在 [5..1])

  ok results.join(' ') 等于 '5 4 3 2 1'
  ok results.join(' ') 等于 [(10-5)..(-2+3)].join(' ')

  results = (x 每个 x 在 [10..1])
  ok results.join(' ') 等于 [10..1].join(' ')

  results = (x 每个 x 在 [10...0] by -2)
  ok results.join(' ') 等于 [10, 8, 6, 4, 2].join(' ')


test "Range comprehension gymnastics.", ->

  eq "#{i 每个 i 在 [5..1]}", '5,4,3,2,1'
  eq "#{i 每个 i 在 [5..-5] by -5}", '5,0,-5'

  a = 6
  b = 0
  c = -2

  eq "#{i 每个 i 在 [a..b]}", '6,5,4,3,2,1,0'
  eq "#{i 每个 i 在 [a..b] by c}", '6,4,2,0'


test "Multiline array comprehension with filter.", ->

  evens = 每个 num 在 [1, 2, 3, 4, 5, 6] when not (num & 1)
             num *= -1
             num -= 2
             num * -1
  eq evens + '', '4,6,8'


  test "The in operator still works, standalone.", ->

    ok 2 of evens


test "all isn't reserved.", ->

  all = 1


test "Ensure that the closure wrapper preserves local variables.", ->

  obj = {}

  每个 method 在 ['one', 'two', 'three'] then do (method) ->
    obj[method] = ->
      "I'm " + method

  ok obj.one()   等于 "I'm one"
  ok obj.two()   等于 "I'm two"
  ok obj.three() 等于 "I'm three"


test "Index values at the end of a loop.", ->

  i = 0
  每个 i 在 [1..3]
    -> 'func'
    break 如果 伪
  ok i 等于 4


test "Ensure that local variables are closed over for range comprehensions.", ->

  funcs = for i 在 [1..3]
    do (i) ->
      -> -i

  eq (func() 每个 func 在 funcs).join(' '), '-1 -2 -3'
  ok i 等于 4


test "Even when referenced in the filter.", ->

  list = ['one', 'two', 'three']

  methods = 每个 num, i 在 list when num isnt 'two' 且 i isnt 1
    do (num, i) ->
      -> num + ' ' + i

  ok methods.length 等于 2
  ok methods[0]() 等于 'one 0'
  ok methods[1]() 等于 'three 2'


test "Even a convoluted one.", ->

  funcs = []

  每个 i 在 [1..3]
    do (i) ->
      x = i * 2
      ((z)->
        funcs.push -> z + ' ' + i
      )(x)

  ok (func() 每个 func 在 funcs).join(', ') 等于 '2 1, 4 2, 6 3'

  funcs = []

  results = 每个 i 在 [1..3]
    do (i) ->
      z = (x * 3 每个 x 在 [1..i])
      ((a, b, c) -> [a, b, c].join(' ')).apply this, z

  ok results.join(', ') 等于 '3  , 3 6 , 3 6 9'


test "Naked ranges are expanded into arrays.", ->

  array = [0..10]
  ok(num % 2 等于 0 每个 num 在 array by 2)


test "Nested shared scopes.", ->

  foo = ->
    每个 i 在 [0..7]
      do (i) ->
        每个 j 在 [0..7]
          do (j) ->
            -> i + j

  eq foo()[3][4](), 7


test "Scoped loop pattern matching.", ->

  a = [[0], [1]]
  funcs = []

  每个 [v] 在 a
    do (v) ->
      funcs.push -> v

  eq funcs[0](), 0
  eq funcs[1](), 1


test "Nested comprehensions.", ->

  multiLiner =
    每个 x 在 [3..5]
      每个 y 在 [3..5]
        [x, y]

  singleLiner =
    (([x, y] 每个 y 在 [3..5]) 每个 x 在 [3..5])

  ok multiLiner.length 等于 singleLiner.length
  ok 5 等于 multiLiner[2][2][1]
  ok 5 等于 singleLiner[2][2][1]


test "Comprehensions within parentheses.", ->

  result = null
  store = (obj) -> result = obj
  store (x * 2 每个 x 在 [3, 2, 1])

  ok result.join(' ') 等于 '6 4 2'


test "Closure-wrapped comprehensions that refer to the 'arguments' object.", ->

  expr = ->
    result = (item * item 每个 item 在 arguments)

  ok expr(2, 4, 8).join(' ') 等于 '4 16 64'


test "Fast object comprehensions over all properties, including prototypal ones.", ->

  class Cat
    constructor: -> @name = 'Whiskers'
    breed: 'tabby'
    hair:  'cream'

  whiskers = new Cat
  own = (value 每个 own key, value of whiskers)
  all = (value 每个 key, value of whiskers)

  ok own.join(' ') 等于 'Whiskers'
  ok all.sort().join(' ') 等于 'Whiskers cream tabby'


test "Optimized range comprehensions.", ->

  exxes = ('x' 每个 [0...10])
  ok exxes.join(' ') 等于 'x x x x x x x x x x'


test "#3671: Allow step in optimized range comprehensions.", ->

  exxes = ('x' 每个 [0...10] by 2)
  eq exxes.join(' ') , 'x x x x x'


test "#3671: Disallow guard in optimized range comprehensions.", ->

  throws -> CoffeeScript.compile "exxes = ('x' 每个 [0...10] when a)"


test "Loop variables should be able to reference outer variables", ->
  outer = 1
  do ->
    null 每个 outer 在 [1, 2, 3]
  eq outer, 3


test "Lenient on pure statements not trying to reach out of the closure", ->

  val = 每个 i 在 [1]
    每个 j 在 [] then break
    i
  ok val[0] 等于 i


test "Comprehensions only wrap their last line in a closure, allowing other lines
  to have pure expressions in them.", ->

  func = -> 每个 i 在 [1]
    break 如果 i 等于 2
    j 每个 j 在 [1]

  ok func()[0][0] 等于 1

  i = 6
  odds = 每当 i--
    continue unless i & 1
    i

  ok odds.join(', ') 等于 '5, 3, 1'


test "Issue #897: Ensure that plucked function variables aren't leaked.", ->

  facets = {}
  list = ['one', 'two']

  (->
    每个 entity 在 list
      facets[entity] = -> entity
  )()

  eq typeof entity, 'undefined'
  eq facets['two'](), 'two'


test "Issue #905. Soaks as the for loop subject.", ->

  a = {b: {c: [1, 2, 3]}}
  每个 d 在 a.b?.c
    e = d

  eq e, 3


test "Issue #948. Capturing loop variables.", ->

  funcs = []
  list  = ->
    [1, 2, 3]

  每个 y 在 list()
    do (y) ->
      z = y
      funcs.push -> "y 等于 #{y} 且 z 等于 #{z}"

  eq funcs[1](), "y 等于 2 且 z 等于 2"


test "Cancel the comprehension 如果 there's a jump inside the loop.", ->

  result = try
    每个 i 在 [0...10]
      continue 如果 i < 5
    i

  eq result, 10


test "Comprehensions over break.", ->

  arrayEq (break 每个 [1..10]), []


test "Comprehensions over continue.", ->

  arrayEq (continue 每个 [1..10]), []


test "Comprehensions over function literals.", ->

  a = 0
  每个 f 在 [-> a = 1]
    do (f) ->
      do f

  eq a, 1


test "Comprehensions that mention arguments.", ->

  list = [arguments: 10]
  args = 每个 f 在 list
    do (f) ->
      f.arguments
  eq args[0], 10


test "expression conversion under explicit returns", ->
  nonce = {}
  fn = ->
    返回 (nonce 每个 x 在 [1,2,3])
  arrayEq [nonce,nonce,nonce], fn()
  fn = ->
    返回 [nonce 每个 x 在 [1,2,3]][0]
  arrayEq [nonce,nonce,nonce], fn()
  fn = ->
    返回 [(nonce 每个 x 在 [1..3])][0]
  arrayEq [nonce,nonce,nonce], fn()


test "implicit destructuring assignment in object of objects", ->
  a={}; b={}; c={}
  obj = {
    a: { d: a },
    b: { d: b }
    c: { d: c }
  }
  result = ([y,z] 每个 y, { d: z } of obj)
  arrayEq [['a',a],['b',b],['c',c]], result


test "implicit destructuring assignment in array of objects", ->
  a={}; b={}; c={}; d={}; e={}; f={}
  arr = [
    { a: a, b: { c: b } },
    { a: c, b: { c: d } },
    { a: e, b: { c: f } }
  ]
  result = ([y,z] 每个 { a: y, b: { c: z } } 在 arr)
  arrayEq [[a,b],[c,d],[e,f]], result


test "implicit destructuring assignment in array of arrays", ->
  a={}; b={}; c={}; d={}; e={}; f={}
  arr = [[a, [b]], [c, [d]], [e, [f]]]
  result = ([y,z] 每个 [y, [z]] 在 arr)
  arrayEq [[a,b],[c,d],[e,f]], result

test "issue #1124: don't assign a variable in two scopes", ->
  lista = [1, 2, 3, 4, 5]
  listb = (_i + 1 每个 _i 在 lista)
  arrayEq [2, 3, 4, 5, 6], listb

test "#1326: `by` value is uncached", ->
  a = [0,1,2]
  fi = gi = hi = 0
  f = -> ++fi
  g = -> ++gi
  h = -> ++hi

  forCompile = []
  rangeCompileSimple = []

  #exercises For.compile
  每个 v, i 在 a by f()
    forCompile.push i

  #exercises Range.compileSimple
  rangeCompileSimple = (i 每个 i 在 [0..2] by g())

  arrayEq a, forCompile
  arrayEq a, rangeCompileSimple
  #exercises Range.compile
  eq "#{i 每个 i 在 [0..2] by h()}", '0,1,2'

test "#1669: break/continue should skip the result only for that branch", ->
  ns = 每个 n 在 [0..99]
    如果 n > 9
      break
    否则 如果 n & 1
      continue
    否则
      n
  eq "#{ns}", '0,2,4,6,8'

  # `else undefined` is implied.
  ns = 每个 n 在 [1..9]
    如果 n % 2
      continue unless n % 5
      n
  eq "#{ns}", "1,,3,,,7,,9"

  # Ditto.
  ns = 每个 n 在 [1..9]
    switch
      when n % 2
        continue unless n % 5
        n
  eq "#{ns}", "1,,3,,,7,,9"

test "#1850: inner `for` should not be expression-ized 如果 `return`ing", ->
  eq '3,4,5', do ->
    每个 a 在 [1..9] then \
    每个 b 在 [1..9]
      c = Math.sqrt a*a + b*b
      返回 String [a, b, c] unless c % 1

test "#1910: loop index should be mutable within a loop iteration and immutable between loop iterations", ->
  n = 1
  iterations = 0
  arr = [0..n]
  每个 v, k 在 arr
    ++iterations
    v = k = 5
    eq 5, k
  eq 2, k
  eq 2, iterations

  iterations = 0
  每个 v 在 [0..n]
    ++iterations
  eq 2, k
  eq 2, iterations

  arr = ([v, v + 1] 每个 v 在 [0..5])
  iterations = 0
  每个 [v0, v1], k 在 arr when v0
    k += 3
    ++iterations
  eq 6, k
  eq 5, iterations

test "#2007: Return object literal from comprehension", ->
  y = 每个 x 在 [1, 2]
    foo: "foo" + x
  eq 2, y.length
  eq "foo1", y[0].foo
  eq "foo2", y[1].foo

  x = 2
  y = 每当 x
    x: --x
  eq 2, y.length
  eq 1, y[0].x
  eq 0, y[1].x

test "#2274: Allow @values as loop variables", ->
  obj = {
    item: null
    method: ->
      每个 @item 在 [1, 2, 3]
        null
  }
  eq obj.item, null
  obj.method()
  eq obj.item, 3

test "#2525, #1187, #1208, #1758, looping over an array forwards", ->
  list = [0, 1, 2, 3, 4]

  ident = (x) -> x

  arrayEq (i 每个 i 在 list), list

  arrayEq (index 每个 i, index 在 list), list

  arrayEq (i 每个 i 在 list by 1), list

  arrayEq (i 每个 i 在 list by ident 1), list

  arrayEq (i 每个 i 在 list by ident(1) * 2), [0, 2, 4]

  arrayEq (index 每个 i, index 在 list by ident(1) * 2), [0, 2, 4]

test "#2525, #1187, #1208, #1758, looping over an array backwards", ->
  list = [0, 1, 2, 3, 4]
  backwards = [4, 3, 2, 1, 0]

  ident = (x) -> x

  arrayEq (i 每个 i 在 list by -1), backwards

  arrayEq (index 每个 i, index 在 list by -1), backwards

  arrayEq (i 每个 i 在 list by ident -1), backwards

  arrayEq (i 每个 i 在 list by ident(-1) * 2), [4, 2, 0]

  arrayEq (index 每个 i, index 在 list by ident(-1) * 2), [4, 2, 0]

test "splats in destructuring in comprehensions", ->
  list = [[0, 1, 2], [2, 3, 4], [4, 5, 6]]
  arrayEq (seq 每个 [rep, seq...] 在 list), [[1, 2], [3, 4], [5, 6]]

test "#156: expansion in destructuring in comprehensions", ->
  list = [[0, 1, 2], [2, 3, 4], [4, 5, 6]]
  arrayEq (last 每个 [..., last] 在 list), [2, 4, 6]

test "#3778: Consistently always cache for loop range boundaries and steps, even
      如果 they are simple identifiers", ->
  a = 1; arrayEq [1, 2, 3], (for n 在 [1, 2, 3] by  a then a = 4; n)
  a = 1; arrayEq [1, 2, 3], (for n 在 [1, 2, 3] by +a then a = 4; n)
  a = 1; arrayEq [1, 2, 3], (for n 在 [a..3]          then a = 4; n)
  a = 1; arrayEq [1, 2, 3], (for n 在 [+a..3]         then a = 4; n)
  a = 3; arrayEq [1, 2, 3], (for n 在 [1..a]          then a = 4; n)
  a = 3; arrayEq [1, 2, 3], (for n 在 [1..+a]         then a = 4; n)
  a = 1; arrayEq [1, 2, 3], (for n 在 [1..3] by  a    then a = 4; n)
  a = 1; arrayEq [1, 2, 3], (for n 在 [1..3] by +a    then a = 4; n)
