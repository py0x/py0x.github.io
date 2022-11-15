+++
title = "深入理解 Rust - References and Borrowing"
description = "Understanding references and borrowing in Rust"
+++

指针是万恶之源。

你不拥有这块数据，你只是有一个指向这块数据的地址（数据引用）。如果数据被删了，被改了，你根本就不知道。换言之，你所依赖的这块数据并不安全。因为你担心别的代码对它动手脚。很多 bug 就是这么出现的，data race, dangling pointer，等等等等。

细想一下，数据的安全性主要由两个因素控制：
1. 共享性：数据是否共享，是否存在多个引用？
2. 可变性：数据是否允许被修改？

换言之，一块数据之所以会不安全，是因为它同时满足了共享性和可变性。有这块数据引用的可能不止一个地方，而且都能修改这块数据，我们就开始担心别的引用会修改这块数据，破坏我的这块代码的假设。

于是，要想得到数据安全，只需要：
1. 禁止数据共享: 不允许共享数据 (unsharable)
2. 禁止数据可变：不允许修改数据 (immutable)

禁止数据共享。这个好理解，如果这块数据是你独享的，只有你一个引用，那么别的代码不可能对它动手脚，数据是安全的。

禁止数据可变。是函数式的思路，比如 Haskell，不允许有副作用，要想改就基于旧的创建一个新的，数据手递手传递。这样你依赖一个数据，就可以放心地假设它不会被别人悄悄地修改。比如依赖一个字典，可以肯定这个字典的 key-values 不会被悄悄地改掉。

Rust 保护数据安全的机制就是这两个思路的组合：**如果你要允许一个引用修改数据，那么就不允许创建多个引用 (共享数据）。如果你要创建多个引用 (共享数据)，那么就不允许这些引用修改数据。**

[官方文档](https://doc.rust-lang.org/book/ch04-02-references-and-borrowing.html)对这个理念的表达是：
> At any given time, you can have either one mutable reference or any number of immutable references.

（值得注意的是，这是一个静态约束，即编译期就可以检查的保证）

但凡事总有例外。

有些场景下，这个规则是必须得破坏掉的，否则便实现不了所需要的功能。

比如要实现一个共享 `cache`，程序的多个地方通过引用指向同一个 `cache` 对象来使用这个 `cache`。也就是说，共享 `cache` 的引用可能有多个（否则就称不上共享了）。

而对一个 `cache` 的主要使用方式，其实就是读和写。先读一下，如果发现 cache miss，那么就去获取这个 miss 的数据，然后写回 cache。也就是说，`cache` 的引用必须支持修改数据（缓存需要：存）。

在共享 `cache` 这个场景下，我们既要能共享数据，又要能修改数据。既要共享性，也要可变性。上文提到的规则不适用了。

Rust 提供了另一个机制来处理这种场景。官方说法叫[内部可变性(interior-mutability)](https://doc.rust-lang.org/book/ch15-05-interior-mutability.html)。其实它的真正意思是：共享可变性(shared-mutability)。

共享可变性在运行期，而不是编译期来保证数据安全。核心做法是使用 [`Cell` 类型](https://doc.rust-lang.org/reference/interior-mutability.html)。

总结一下：
1. Rust 引用有两种：共享性引用(`&`)和可变性引用(`&mut`)
2. 共享性引用和可变性引用在编译期互斥。要么有一个可变性引用(`&mut`)，要么有任意数量的共享性引用(`&`)，而不能同时有二者存在。
3. 共享性引用可以使用 [`Cell` 类型](https://doc.rust-lang.org/reference/interior-mutability.html) 使其在运行时可变，以满足共享且可变的场景。

---
后记：

为了加深理解，可变性引用(`&mut`) 可以理解成互斥性引用。它的 `mut` 其实可以理解为互斥锁 `mutex` 的 `mut`，而不是 `mutable` 的 `mut`。

慢慢就会发现，Rust 中的 `mut` 关键字，基本上就是互斥的意思。










