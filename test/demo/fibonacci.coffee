斐波那契 = (数) ->
    如果 数 < 2
        1
    否则
        斐波那契(数 - 2) + 斐波那契(数 - 1)

每个 索引 在 [1..16]
    console.log 斐波那契(索引)