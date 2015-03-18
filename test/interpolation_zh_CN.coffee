# Interpolation
# -------------

# * String Interpolation
# * Regular Expression Interpolation

# String Interpolation

# TODO: refactor string interpolation tests

eq 'multiline nested "interpolations" work', """multiline #{
  "nested #{
    ok true
    "\"interpolations\""
  }"
} work"""

# Issue #923: Tricky interpolation.
eq "#{ "{" }", "{"
eq "#{ '#{}}' } }", '#{}} }'
eq "#{"'#{ ({a: "b#{1}"}['a']) }'"}", "'b1'"

# Issue #1150: String interpolation regression
eq "#{'"/'}",                '"/'
eq "#{"/'"}",                "/'"
eq "#{/'"/}",                '/\'"/'
eq "#{"'/" + '/"' + /"'/}",  '\'//"/"\'/'
eq "#{"'/"}#{'/"'}#{/"'/}",  '\'//"/"\'/'
eq "#{6 / 2}",               '3'
eq "#{6 / 2}#{6 / 2}",       '33' # parsed as division
eq "#{6 + /2}#{6/ + 2}",     '6/2}#{6/2' # parsed as a regex
eq "#{6/2}
    #{6/2}",                 '3 3' # newline cannot be part of a regex, so it's division
eq "#{/// "'/'"/" ///}",     '/"\'\\/\'"\\/"/' # heregex, stuffed with spicy characters
eq "#{/\\'/}",               "/\\\\'/"

# Issue #2321: Regex/division conflict in interpolation
eq "#{4/2}/", '2/'
curWidth = 4
eq "<i style='left:#{ curWidth/2 }%;'></i>",   "<i style='left:2%;'></i>"
throws -> CoffeeScript.compile '''
   "<i style='left:#{ curWidth /2 }%;'></i>"'''
#                 valid regex--^^^^^^^^^^^ ^--unclosed string
eq "<i style='left:#{ curWidth/2 }%;'></i>",   "<i style='left:2%;'></i>"
eq "<i style='left:#{ curWidth/ 2 }%;'></i>",  "<i style='left:2%;'></i>"
eq "<i style='left:#{ curWidth / 2 }%;'></i>", "<i style='left:2%;'></i>"

hello = 'Hello'
world = 'World'
ok '#{hello} #{world}!' 等于 '#{hello} #{world}!'
ok "#{hello} #{world}!" 等于 'Hello World!'
ok "[#{hello}#{world}]" 等于 '[HelloWorld]'
ok "#{hello}##{world}" 等于 'Hello#World'
ok "Hello #{ 1 + 2 } World" 等于 'Hello 3 World'
ok "#{hello} #{ 1 + 2 } #{world}" 等于 "Hello 3 World"
ok 1 + "#{2}px" 等于 '12px'
ok isNaN "a#{2}" * 2
ok "#{2}" 等于 '2'
ok "#{2}#{2}" 等于 '22'

[s, t, r, i, n, g] = ['s', 't', 'r', 'i', 'n', 'g']
ok "#{s}#{t}#{r}#{i}#{n}#{g}" 等于 'string'
ok "\#{s}\#{t}\#{r}\#{i}\#{n}\#{g}" 等于 '#{s}#{t}#{r}#{i}#{n}#{g}'
ok "\#{string}" 等于 '#{string}'

ok "\#{Escaping} first" 等于 '#{Escaping} first'
ok "Escaping \#{in} middle" 等于 'Escaping #{in} middle'
ok "Escaping \#{last}" 等于 'Escaping #{last}'

ok "##" 等于 '##'
ok "#{}" 等于 ''
ok "#{}A#{} #{} #{}B#{}" 等于 'A  B'
ok "\\\#{}" 等于 '\\#{}'

ok "I won ##{20} last night." 等于 'I won #20 last night.'
ok "I won ##{'#20'} last night." 等于 'I won ##20 last night.'

ok "#{hello + world}" 等于 'HelloWorld'
ok "#{hello + ' ' + world + '!'}" 等于 'Hello World!'

list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
ok "values: #{list.join(', ')}, length: #{list.length}." 等于 'values: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, length: 10.'
ok "values: #{list.join ' '}" 等于 'values: 0 1 2 3 4 5 6 7 8 9'

obj = {
  name: 'Joe'
  hi: -> "Hello #{@name}."
  cya: -> "Hello #{@name}.".replace('Hello','Goodbye')
}
ok obj.hi() 等于 "Hello Joe."
ok obj.cya() 等于 "Goodbye Joe."

ok "With #{"quotes"}" 等于 'With quotes'
ok 'With #{"quotes"}' 等于 'With #{"quotes"}'

ok "Where is #{obj["name"] + '?'}" 等于 'Where is Joe?'

ok "Where is #{"the nested #{obj["name"]}"}?" 等于 'Where is the nested Joe?'
ok "Hello #{world ? "#{hello}"}" 等于 'Hello World'

ok "Hello #{"#{"#{obj["name"]}" + '!'}"}" 等于 'Hello Joe!'

a = """
    Hello #{ "Joe" }
    """
ok a 等于 "Hello Joe"

a = 1
b = 2
c = 3
ok "#{a}#{b}#{c}" 等于 '123'

result = null
stash = (str) -> result = str
stash "a #{ ('aa').replace /a/g, 'b' } c"
ok result 等于 'a bb c'

foo = "hello"
ok "#{foo.replace("\"", "")}" 等于 'hello'

val = 10
a = """
    basic heredoc #{val}
    on two lines
    """
b = '''
    basic heredoc #{val}
    on two lines
    '''
ok a 等于 "basic heredoc 10\non two lines"
ok b 等于 "basic heredoc \#{val}\non two lines"

eq 'multiline nested "interpolations" work', """multiline #{
  "nested #{(->
    ok yes
    "\"interpolations\""
  )()}"
} work"""

eq 'function(){}', "#{->}".replace /\s/g, ''
ok /^a[\s\S]+b$/.test "a#{=>}b"
ok /^a[\s\S]+b$/.test "a#{ (x) -> x ** 2 }b"

# Regular Expression Interpolation

# TODO: improve heregex interpolation tests

test "heregex interpolation", ->
  eq /\\#{}\\"/ + '', ///
   #{
     "#{ '\\' }" # normal comment
   }
   # regex comment
   \#{}
   \\ "
  /// + ''
