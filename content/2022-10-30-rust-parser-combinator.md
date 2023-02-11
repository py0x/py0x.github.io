+++
title = "实战 Rust - 从零编写 JSON Parser"
description = "Writing a JSON parser from scratch"
+++

### Show you the code
古语有云，Talk is cheap. 在进行 cheap talk 之前，先放上代码。

实现分两层，1. 通用 Parser Combinator 库 parcomb，2. 基于 parcomb 实现的 JSON parser。

- [JSON Parser 实现 (基于 parcomb)](https://github.com/py0x/parcomb/blob/main/examples/json.rs)
- [parcomb 完整代码](https://github.com/py0x/parcomb)


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

### 实现和设计

我们先来定义 Parser。

函数式的想法是最自然的：**一个 Parser 就是一个函数**。

而 Parser Combinator，所谓的胶水，无非就是一种高阶函数：**接受 Parser 作为输入，返回 Parser 作为输出（接受函数，返回函数）**。

下一步，我们只需要把 Parser 的函数签名(function signature) 固定下来，不同类型的 Parsers 就可以通过胶水自由组合，最终组合成一个具有特定业务目的的 Parser。

而在 Rust 的语境下，我们不首先考虑函数作为抽象单元。我们用 [Traits(接口)](https://doc.rust-lang.org/book/ch10-02-traits.html) 做高层抽象。也就是说：

**Parser 就是一个 Trait**

然后定义这个 Parser Trait 的行为和输入输出，如下：

```rust
pub type ParseResult<I, O, E> = Result<(O, I), E>;

pub trait Parser<I, O, E>
where
    I: ?Sized,
{
    fn parse<'a>(&self, input: &'a I) -> ParseResult<&'a I, O, E>;
}

```

`parse` 方法接受一个输入 `&I`，若成功，则返回结果 `O` 及剩下未用完的 `&I`，若出错，返回 `E`。

值得注意的是，这几个 `I`, `O`, `E` 都是泛型 (Generic Types)。这意味着我们可以为这个 Parser Trait 提供各种各样的具体实现，去支持 str，bytes 等各种各样的 parse 需求。

中间接口层一定，剩下的事情就好办了：
1. 往上走，**使用这个接口**, 实现高层逻辑，即：基于这个 Parser 接口去实现各种 Parser Combinators；
2. 往下走，**实现这个接口**, 提供底层逻辑，即：为各种各样的具体的类型去实现这个 Parser 接口。

也就是[依赖反转原则 Dependency inversion principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle) 的应用。


### 向上实现：Parser Combinator

对 Parser Combinator 的实现，我们首要考虑的是提供哪些胶水操作 (primitives)。


正则表达式其实已经提供了很好的思路，`and`, `or`, `*`, `+` `!`, `?` ...

- `and` 操作: `p1 and p2`，就是先使用 `p1` 来 parse，若成功，则使用 `p2` 来 parse，然后返回结果 `(o1, o2)` ;
- `or` 操作：`p1 or p1`，就是先尝试使用 `p1` 来 parse，若失败，则继续尝试 `p2` ;
- `*` 操作：`p1*`, 就是连续使用 `p1` 来 parse 0 次到多次，直到失败。
- ...

剩下的我就不一一列举了，可以参考 [PEG(Parsing Expression Grammar)](https://en.wikipedia.org/wiki/Parsing_expression_grammar)。

`PEG` 和 `Regex` 很像，区别在于 `Regex` 的基本元素是字符，组合的是字符，不能递归，而 `PEG` 的基本元素是 Parser，组合的是 Parser，可以递归。

我们实现的话，不用太照本宣科，抓住关键，然后实现一些自己需要的操作即可。

`parcomb` 的这些胶水操作，每个操作我都选择了用一个特定的类型 `Struct` 去表示和实现，然后为每个 `Struct`  都实现 Parser 这个 Trait，这样所有操作就满足了[闭包性质](https://en.wikipedia.org/wiki/Closure_(mathematics))，可以自由组合了。

代码见: [这里](https://github.com/py0x/parcomb/blob/main/src/parser.rs)

这个实现过程其实有不少有意思地方。比如：

- Parser Combinator 是选择静态地组合 Parser (impl Trait)，还是动态地组合 Parser (dyn Trait)？
- Rust 支持为所有符合条件的函数/闭包自动实现 Parser Trait，方便使用。[参考这里](https://github.com/py0x/parcomb/blob/main/src/parser.rs#L111)
- **Accept interfaces, return structs** 原则的再体会 (其实这个是当初写 Go 语言时学习到的一个原则)。因为 Rust 的类型系统和抽象特性更强大，这个原则对 Rust 甚至更加实用：This suggests that it makes sense to make the argument types of a function as general as possible and the return types as specific as possible。[参考这里](https://www.reddit.com/r/golang/comments/dfe1qr/who_first_said_accept_interfaces_and_return/)

- ...

实现一次 Parser Combinator，即可对 Rust 的核心语言特性 (Trait, Generic Type) 有很好的感觉。


### 向下实现：String Parser

我们的 Parser Trait 接口并没有规定输入类型是什么，这意味着可以按需实现接受各种各样输入的 Parser。如接受：`str`, `[u8]`, ... 的 Parser。

因为我的目标是一个 JSON Parser，所以我优先实现接受 `str` 为输入的 basic parsers。代码见: [这里](https://github.com/py0x/parcomb/blob/main/src/string_parser.rs)

所谓的 basic parsers，其实就是方便用户构造 parser 的一些函数，有了这些构造函数，用户就无需从头开始裸写 parser。

比如 literal parser `lit`:

``` rust
let par = lit("hello"); // 生成一个 parse "hello" 的 parser
let inp = "hello world";
let res = par.parse(inp).unwrap();
assert_eq!((format!("hello"), " world"), res);
```

甚至可以更通用一些，正则表达式 parser `reg`:

``` rust

let par = reg(r"\d{2}\w+");  // 生成一个 parse r"\d{2}\w+" 这个正则表达式的 parser
let inp = "19abcd$$";
let res = par.parse(inp).unwrap();
assert_eq!((format!("19abcd"), "$$"), res);
```

这里有意思的是，我们只要用 Parser Combinator 把这些 reg parsers 组合起来，就得到了一个支持递归的正则表达式引擎。


### JSON Parser

对着 JSON 的 [Schema](https://www.json.org/json-en.html)，使用我们预设好的 String Parser 和 Parser Combinator，就可以描述性地定义出一个 JSON Parser。代码参见：[这里](https://github.com/py0x/parcomb/blob/main/examples/json.rs)

这个 JSON Parser 的定义，其实也就 100 行代码左右。


### 结语

能够熟练地使用 Traits 和 Generic Data Types 进行程序设计和实现，应该就能够 Thinking in Rust 了吧。



