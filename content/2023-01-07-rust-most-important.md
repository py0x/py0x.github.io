+++
title = "深入 Rust - Rust 中最重要的事"
description = "The most important thing in Rust"
+++

### 前言

编程时，我们实际上需要同时关注 "内存" 和 "数据" 两个概念。

大部分高级语言因为有 "垃圾回收"，所以可以不关注 "内存"，只关心 "数据"。

Rust 没有 "垃圾回收" ，但是它又不希望用户**显式**地去管理内存，它把内存的生命周期和数据的生命周期紧密地结合在一起 (参考: [RAII](https://tourofrust.com/44_en.html))。

于是，在编写 Rust 代码的时候，我们看似在操作 "数据"，事实上我们在同时操作 "内存" 和 "数据"。

于是，变量(variable)， 不再是其它语言里的变量。

于是，赋值(`a = b`)，也不再是其它语言里的赋值。

每一句 Rust 代码(expression/statement)，都有着更加丰富的语义。

我们带着别的高级语言的经验和直觉，来编写 Rust 代码的时候，就等同于和编译器搏斗。

[The Rust Programming Language](https://doc.rust-lang.org/book/) 为了方便大家入门，使用了一些如 owner/borrowing 的隐喻性概念。

但我们最终还是得抛弃掉这些隐喻，去如实地，结合每一个 expression/statement 去理解，Rust 编译器的工作原理是什么。
(所有的秘密都藏在 [The Rust Reference](https://doc.rust-lang.org/reference/introduction.html) 里)

下面，我要开始讲述最基础，最重要，又最容易被大家忽略的部分。


### 内存和数据表示: Place & Value

Rust 中最重要的两个概念，分别是 **Place** 和 **Value**，分别和上文提到的 "内存" 和 "数据" 相关。

- **Place** : 表示内存 __位置__ (memory location)。
- **Value** : 表示 Place (内存位置) 里的 __值__ 。

其中， **Value** 是很简单的，代表实际的值。如:

  ```1, true, "aaa", String::new("hi"), Struct{...}, ...```

**Place** 是重点中的重点，却又往往被大家忽略。

我们先来问一个问题:

> 一个变量 (variable), 表达的是一个 Place, 还是一个 Value？

考察下面这两行代码:

```rust
let a = 1;
let b = a;
```

注意变量 `a`，
- 当它出现在等号左边的时候，它表示一个 **Place**，可以存入 1 这个 Value；
- 当它出现在等号右边的时候，它表示这个 **Place 里的 Value**。

也就是说，一个变量，表示的是一个 Place (place expression)。

但它的**具体表达要结合它的上下文 (context) 来进行**。
在等号左边 (place context)，它就表达为一个 Place；在等号右边 (value context)，它则表达为 Place 里的 Value。

官方说法：
> Expressions are divided into two main categories: place expressions and value expressions;
> Within each expression, operands may likewise occur in either place context or value context.
> The evaluation of an expression depends both on its own category and the context it occurs within.

具体细节请参考: [这里](https://doc.rust-lang.org/reference/expressions.html#place-expressions-and-value-expressions)


### Place 的引用: Reference

Place 的使用一般有两种方式：直接表示 和 间接引用。

直接表示，即硬编码，比如变量 (`a`)，字段 (`expr.f`), 数组索引 (`expr[i]`) 和解引用 (`*expr`)，它们都是 Place。

间接引用，即 Reference，
- 通过 ref(`&`) 获取一个 Place 的 Reference，作为 Value 使用:
    + `&place -> reference`

- 通过 deref(`*`) 解引用一个 Reference，得到一个 Place:
    + `*reference -> place`

(特别注意：受其它语言影响，(`*`)操作经常被误解，它并**不表示取出** Place 里的值，它表示的是 Place 本身 (Reference 所指向的 Place)，和其它的 Place (如变量）完全等价。
这个 Place 到底表达为 Place, 还是 Place 里的值，则取决于 Context。但是无论如何，它都不表示**取出**。
如果报了 move 有关的错误，那一定是因为用了表达移动/取出的操作 (`= *p`) 或者 (`return *p`) 等。
(`*p`) 本身不会报错，因为可以这样 (`= &*p`)： 先(`*`)定位 Place，再(`&`)变成 Reference，再移动(`=`) Reference，而不报错。


### Place 的动态引用: Smart Pointer

Place 的引用分两种，静态引用 Reference 和 动态引用 Smart Pointer。

所谓动态引用，意思是：

真实的 Place 可能不是固定的，可能一直在变，因此它的 Reference 也一直在变。为了使用这个动态的 Place，我们需要一个静态的 Place 作为入口代理。
Rust 提供一种机制，[暗中](https://web.mit.edu/rust-lang_v1.25/arch/amd64_ubuntu1404/share/doc/rust/html/book/first-edition/deref-coercions.html)
给我们的两个 Place 进行 [动态映射](https://doc.rust-lang.org/std/ops/trait.Deref.html)。于是我们使用这个代理 Place 的时候，就像使用真正的 Place 一样。

由于存在一层代理封装，我们便可以封装额外的功能，因此变得 Smart 了起来。因为动态，所以 Smart。

但我们为什么需要动态的内存(Place)映射？

因为我们需要封装动态的内存管理。如 `String`, `Vec<T>` 可以随着数据增多动态扩展内存。尽管在它们的内部，内存(Place)是变化的，但在外部我们感知不到，因为代理入口是不变的。

要实现一个 Smart Pointer, 需要实现两个 Traits: [Deref](https://doc.rust-lang.org/std/ops/trait.Deref.html) 和 [Drop](https://doc.rust-lang.org/std/ops/trait.Drop.html)。

- Deref 用来实现动态内存映射: `fn(&p) -> &p_x`。

- (注：Place 的动态映射只能通过其 Reference 映射来表示: &a -> &b, 因为 Place 在函数签名里(value context)会表达为 Place 里的值）

- Drop 用来销毁内部动态申请的内存

著名的 Smart Pointer 如: `Box<T>`, `Rc<T>` 其实是做了 Stack Place 到 Heap Place 的动态映射。在 Stack Place 退出作用域时，通过 Drop 销毁 Heap Place。


### Value 在 Place 之间的流动: 移动(Move), 复制(Copy, Clone), 引用(Reference)

这里要重点说一下 Rust 的赋值 (`=`) 符号。和其它语言建立起来的直觉不同，它不是数学意义上的等于。**它意味着 Value 在 Place 之间流动**。

广义地，有 4 种基本流动方式 (以 `let a = b` 为例):
1. [Copy](https://doc.rust-lang.org/std/marker/trait.Copy.html):
复制 b 的 Value 到 a。复制的方式是 bitwise copy，只对一些基本的简单类型生效。Copy 之后 `a` 和 `b` 里都有一份数据。无需显式调用。

2. [Clone](https://doc.rust-lang.org/std/clone/index.html):
复制 b 的 Value 到 a。复制的方式是定制化的复制。需要 b 的类型实现 Clone trait，通过 `let a = b.clone()` 来使用。`.clone()` 之后 `a` 和 `b` 里都有一份数据。

3. [Move](https://doc.rust-lang.org/rust-by-example/scope/move.html):
移动 b 的 Value 到 a。移动之后 b 没有数据，不能再使用。

4. [Reference](https://doc.rust-lang.org/std/primitive.reference.html):
`let a = &b`。有些时候不能 Copy，不能/不需要 Clone，也没办法 Move，这时候往往可以取引用。（比如遍历一个链表，`node = &node.next`)

除了赋值 (`let a = b`), **Value 在 Place 之间流动** 还会发生在函数调用 (`foo(x)`) ，返回 (`return x`), 创建 struct (`Struct{a: b}`) 等场景。

我们要考虑这 4 种基本流动方式。


### Place 的访问与安全

基本原则就是**读写锁访问原则**。

> Place 的共享性与可变性互斥。共享不可变，可变不共享。

另外值得注意的是，这个原则是需要递归成立的。

比如 a 是共享的 (&)，a 里边的 b 是可变的 (&mut)，通过 a 入口去访问 b (`a.b`)，那么 `a.b` 实际上是共享的，所以不可变。
但如果 a 是独享的(owner本身或者 &mut), 那么 `a.b` 则可变。

更多参考：
1. [深入 Rust - References and Borrowing](/rust-borrow)
2. [深入 Rust - 共享可变性](/rust-shared-mutability)


### Place 的生命周期

1. Place 退出作用域时，会（递归地）调用 [Drop](https://doc.rust-lang.org/std/ops/trait.Drop.html) 释放所有关联资源。
2. Place 的引用 (Reference) 的生命周期不能大于 Place 的生命周期。