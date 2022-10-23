+++
title = "函数式编程入门 - Monad 和 Future"
description = "Functional programming: Monad and Future"
+++

`Monad`在函数式编程中是个很有意思的概念，有意思之处在于你无法从概念性定义去理解它。如果你问出 `What is a Monad` 这种问题，那么大概率会越搞越糊涂。更有趣的是，当你终于理解了 Monad 之后，就会失去向别人解释明白它的能力。



> Once you understand monads, you lose the ability to explain them to others. Hence the number of monads tutorials grows at an exponential rate as every new understander tries to explain them and fails.



佛教有个说法叫"缘起性空"，意思是事情没有本质（空），只是条件性地（缘起）存在着的一个现象。这实际上提供了一个理解万事万物的思路，也就是说要搞清楚促使 Monad 出现的起缘就可以了。



大部分人接触 `Monad` 都是因为 `Haskell` 。`Haskell` 是所谓的纯函数式编程语言。函数式编程最基本的抽象单元是函数，且函数可以像其它的值一样被传递 (first-class function)。


