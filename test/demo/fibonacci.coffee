斐波那契 = (n) ->
    如果 n < 2
        1
    否则
        斐波那契(n - 2) + 斐波那契(n - 1);

for i in [1..16]
    console.log 斐波那契(i)