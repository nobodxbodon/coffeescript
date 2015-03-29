示例代码：
```shell
斐波那契 = (数) ->
    如果 数 < 2
        1
    否则
        斐波那契(数 - 2) + 斐波那契(数 - 1)

每个 索引 在 [1..16]
    console.log 斐波那契(索引)
```
运行示例：

```shell
bin/coffee test/demo/fibonacci.coffee
```

最简单的汉化方法：

从关键词开始

1） 在lexer.coffee中添加一个'if'的alias: “如果”
（适用于部分关键词。in->在 较复杂：https://github.com/nobodxbodon/coffeescript/commit/1e3d7bb871cb87762521a456aab5eea3bb4e64f5）

2） 重编译咖啡：
```shell
bin/cake build
```
in->在 需要生成parser:
```shell
bin/cake build:parser
```

3） 通过测试（添加汉化版测试 ..._zh_CN.coffee）：

```shell
bin/cake test
```

注：开发时所有含有 中文 字符 的源码文件都改成了utf-8

            {
         }   }   {
        {   {  }  }
         }   }{  {
        {  }{  }  }                    _____       __  __
       { }{ }{  { }                   / ____|     / _|/ _|
     .- { { }  { }} -.               | |     ___ | |_| |_ ___  ___
    (  { } { } { } }  )              | |    / _ \|  _|  _/ _ \/ _ \
    |`-..________ ..-'|              | |___| (_) | | | ||  __/  __/
    |                 |               \_____\___/|_| |_| \___|\___|
    |                 ;--.
    |                (__  \            _____           _       _
    |                 | )  )          / ____|         (_)     | |
    |                 |/  /          | (___   ___ _ __ _ _ __ | |_
    |                 (  /            \___ \ / __| '__| | '_ \| __|
    |                 |/              ____) | (__| |  | | |_) | |_
    |                 |              |_____/ \___|_|  |_| .__/ \__|
     `-.._________..-'                                  | |
                                                        |_|

CoffeeScript is a little language that compiles into JavaScript.

## Installation

If you have the node package manager, npm, installed:

```shell
npm install -g coffee-script
```

Leave off the `-g` if you don't wish to install globally. If you don't wish to use npm:

```shell
git clone https://github.com/jashkenas/coffeescript.git
sudo coffeescript/bin/cake install
```

## Getting Started

Execute a script:

```shell
coffee /path/to/script.coffee
```

Compile a script:

```shell
coffee -c /path/to/script.coffee
```

For documentation, usage, and examples, see: http://coffeescript.org/

To suggest a feature or report a bug: http://github.com/jashkenas/coffeescript/issues

If you'd like to chat, drop by #coffeescript on Freenode IRC.

The source repository: https://github.com/jashkenas/coffeescript.git

Changelog: http://coffeescript.org/#changelog

Our lovely and talented contributors are listed here: http://github.com/jashkenas/coffeescript/contributors
