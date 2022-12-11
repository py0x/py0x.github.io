+++
title = "Rust 实战 - 从零编写 JSON Parser"
description = "Writing a JSON parser from scratch"
+++

### Show you the code
Talk is cheap. 在进行 cheap talk 之前，先把代码放上：

- [JSON Parser 实现 (基于 parcomb)](https://github.com/py0x/parcomb/blob/main/examples/json.rs)
- [parcomb 完整代码](https://github.com/py0x/parcomb)

其实 JSON 的部分只需要 100 行。

### 思路
写 Parser 是熟悉一门编程语言很好的方式。虽说 Parsing 的技术林林总总，其实不需要太在意，我们可以从简单开始。

一个 Parser 实则上是一个模式识别器 (Pattern Matching), 通过匹配输入数据中的模式，若匹配成功，返回一个值。

最常见的 Parser 莫过于正则表达式 (Regex)。正则表达式的问题在于它只能识别线性的模式，换言之，它无法递归地进行模式识别。

所以正则表达式一般用来匹配一些非结构化的字符串。一旦遇到结构化的字符串，比如 JSON 或程序语言，就无能为力了。

JSON 是个递归嵌套结构，意思是它允许字典套字典，字典套数组，数组又套字典，等等。

要识别这种递归结构的字符串，我们需要一个支持递归地识别的 Parser。这种 Parser 叫递归下降 (recursive descent) Parser。

Parser 叫什么并不重要。我们的重点在于 **递归** 二字。

### 递归
递归，是一种自然界的规则。它的意思有两层，1. 循环，2. 相似。自然界中大部分东西都符合递归法则，也就是分形，比如树和叶，山和石。

有了递归，我们完全不需要 for/while 这种循环控制语句，就可以构造循环。只需要函数反复调用自己并更新调用参数即可。

如果我们把 Parser 表达为一个函数，那么只要在 Parser 里调用其它的 Parser，就能实现支持递归地识别的 Parser。

这意味着，我们的 Parser 完全可以通过组合其它的 Parser 得到。形如：

```
ParserA = ParserB + ParserC
ParserD = ParserE - ParserF
...
```

这也意味着，我们会有：1. 基本的 Parser,  2. Parser 胶水（基于基本 Parser 组合出复杂 Parser）

这个 2. Parser 胶水， 正式名字叫 [Parser Combinator](https://en.wikipedia.org/wiki/Parser_combinator)

理论就是这么简单，有意思的是用 Rust 去实现这些理论。

因为 Rust 独特的语言特性，使得这个实现有了更多的乐趣。

### 实现



