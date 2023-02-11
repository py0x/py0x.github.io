+++
title = "深入 Rust - 共享可变性"
description = "Understanding shared mutability in Rust"
+++

Rust 的 reference 存在一条铁律：
> At any given time, you can have either one mutable reference or any number of immutable references.

翻译成中文就是：
> 共享不可变，可变不共享。共享与可变性互斥。

这条铁律带给了我们安全，同时也给我们带来了限制。

试想，要实现 Graph 这种数据结构怎么办呢？一个 Node 可能被多个其它的 Node 所引用（共享），难道就不能修改这个 Node 的数据了吗（可变）？

站在其他语言的角度，这是很荒谬的。

值得注意的是，这个安全性约束是编译期的限制，当我们需要共享可变性时，需要放弃编译期的限制，而改用运行期的检查来保证数据安全。

基本思路有 3 个：
1. 内部可变性: `Rc<RefCell<T>>`

2. 自建索引: `HashMap<K, V>`

3. 野生指针: Raw pointers

### 1. 内部可变性: `Rc<RefCell<T>>`

这个思路是标准答案，参考官方文档: [Interior Mutability 内部可变性](https://doc.rust-lang.org/reference/interior-mutability.html)。

原理就是内层使用 [UnsafeCell 类型](https://doc.rust-lang.org/std/cell/struct.UnsafeCell.html) 来封装数据, 而 `UnsafeCell` 使用 `raw pointers` 和 `unsafe` 来绕过编译器限制。

基于 UnsafeCell 类型，标准库封装出一系列的 [Cell 类型](https://doc.rust-lang.org/std/cell/index.html)，用户不需要直接和 `unsafe` 及 `raw pointers` 打交道，而改为调用 `Cell 类型` 的 API。

`Rc<RefCell<T>>` 是内部可变性的一个典型例子。用引用计数 `Rc<T>` 来实现共享，用 Cell 类型 `RefCell<T>` 来实现可变。

之所以说这个例子典型，是因为共享的时候，ownership 往往也是很模糊的，所以使用 Rc 计数。(注：`Rc<RefCell<T>>` 的线程安全版本是 `Arc<Mutex<T>>`)

[Interior Mutability](https://doc.rust-lang.org/reference/interior-mutability.html) 的核心在于使用 `Cell 类型`。我们可以使用各种各样的 wrapper 封装 [Cell 类型](https://doc.rust-lang.org/std/cell/index.html) 实现共享可变。

### 2. 自建索引: `HashMap<K, V>`

这个思路其实更自然, 但没那么直接。

试想，共享不可变其实是 Rust 针对 references 的限制。那么我们不用 references 就好了。

潜台词是：要引用一个对象，不是一定要用 `reference(&)` 的。`key-value` 的 `key` 不也是一种引用么？共享 `key` 可是没有限制。

原理就是让一个可以索引的容器来存放(own)这些数据，然后用索引来访问它们。

所以不仅仅是 `HashMap`, `Vector` 也是可以的，有索引 (index) 的都可以。

而且 Ownership 的问题也通过中心化的容器解决了，容器 own 所有数据。

这种方式，在实现 Graph 这种数据结构的时候是很舒服的。把节点和边都存放到容器，然后通过 index 来互相指向。避免了在有环的情况下，使用引用计数会出现内存泄露的问题。

### 3. 野生指针: Raw pointers

这不算一个思路了。强行绕开，注意安全便是。


### 总结

1. 基本原则：共享不可变，可变不共享
2. 要想共享且可变，可以 `Rc<RefCell<T>>` 或 `HashMap<K, V>`。


