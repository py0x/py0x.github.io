+++
title = "简明机器学习 - 可微分编程"
description = "Understanding differentiable Programming"
+++

得到一个程序有两种方式，其一是由程序员来编写它，其二是通过大量数据来拟合它。也就是所谓的编程和机器学习。

当我们在编程的时候，我们是在编写整个程序。当我们在机器学习的时候，我们在编写半个程序，剩下的部分，通过数据来拟合而得。

数据拟合，即通过数据，来反推这个产生这批数据的规律，这个规律相当于代码。

人脑的规则，和数据的规律，融合成一起，成为最终的程序。

现在问题来了，如何通过数据反推规律？

答案就在 “学习” 二字之中。

所谓学习，就是不断尝试，不断犯错，不断调整，直至不出错。

所谓机器学习，就是机器通过不断尝试，不断犯错，不断调整，直至不出错。

这个尝试，反馈，调整的回路，怎么搭建？

对于一个程序，哪些部分需要学习，哪些部分需要硬编码？

让我们从一个常量开始。

比如说，数字 `5`。

显然，常量没有任何变化可言，是个硬编码。

现在，我们来让这个常量产生变化的可能性，让它乘以一个变量 `w`。

```
w * 5
```

大功告成，世界上最简单的机器学习程序写好了。`5` 是人编写的，`w` 是未知的，需要通过机器学习而得到。

下一步，我们需要发明一种机制，来不断调整这个 `w`：

```
w = w - dw
```

`dw` 就是 `delta w`，也就是 `w 的变化` 的意思。 `w = w - dw` 就是调整 `w`。

下一步，我们需要确定这个  `dw` 。

观察我们的程序 `w * 5`，它的意思是 `w` 的任何变化，都会被放大 `5` 倍。

假如我们把输出记为 `y`，那么 `dy = 5 * dw`。即：`dw = dy / 5`。

有了这个关系，当我们知道了 `dy`, 就等于知道了 `dw`，就等于知道了新的 `w`。

那么，如何知道 `dy`？

既然 `y` 是我们的输出，那么输出的误差，就是 `y` 需要调整的变化，即 `dy`：

```
dy = y_guess - y_true
```

其中 `y_true` 就是我们的数据（学习源），`y_guess` 是一次尝试的输出。`y_guess = w * 5` ，随 `w` 的变化而变化。

现在只差最后一步，我们就可以跑通这个流程了。这个最后一步是，`w` 的初始值怎么设置？

答案很简单，给个随机数就好了，反正它会被自动调节。

现在，我们用真实数据测试一下这个流程：

```
# --- test 1 ---
y = 15  # 正确答案, 即 w = 3
w = w0 = 2  # 随机初始化 w 为 2
y_guess = w * 5  # 2 * 5 = 10
dy = y_guess - y  # 10 - 15 = -5
dw = 1/5 * dy  # 1/5 * -5 = -1
w = w - dw  # 2 - (-1) = 3  <-- w = 3, y = 15 成功学习到 w = 3


# --- test 2 ---
y = 40  # 正确答案, 即 w = 8
w = w0 = 12  # 随机初始化 w 为 12
y_guess = w * 5  # 12 * 5 = 60
dy = y_guess - y  # 60 - 40 = 20
dw = 1/5 * dy  # 1/5 * 20 = 4
w = w - dw  # 12 - 4 = 8  <-- w = 8, y = 40 成功学习到 w = 8
```

我们从一个特例常量 `5` 开始，通过 `w * 5` 来推演这个机器学习的过程。其实把常量换成变量 `x`，上述的推演同样成立，也就是 `y = w * x`,  因为 `w` 的微小变化会被放大 `x`倍，所以  `dy = dw * x`,  `dw = 1/x * d*y`。通过特定的的 `(x, y)` 数据作为学习源，重复上述步骤，可得到正确的 `w`。

现在，我们研究出了怎么把变量和常量参数化，并且通过数据学习这个参数的技术。接下来我们更进一步：既然常量和变量都可以参数化，那么函数可不可以参数化？如果这个函数也是一个需要学习的函数呢？

```
h(x) = w1 * f(x)  # 参数化函数
f(x) = w2 * x  # 参数化变量
```

我们能同时学习得到 `w1` 和 `w2` 吗？

照着刚才的思路，我们需要先考察 `dw1` 和 `dw2` 。

对 `dw1`, 由 `w1 * f(x)` 可知 `w1` 的微小变化会被放大 `f(x)` 倍，所以 `d_h(x) =  dw1 * f(x)`。

对 `dw2`, 由 `w2 * x` 可知 `w2` 的微小变化会被放大 `x` 倍，所以 `d_f(x) = dw2 * x`； 又由 `w1 * f(x)` 可知，`f(x)` 的微小变化会被放大 `w1` 倍，所以 `d_h(x)  = d_f(x) * w1`。合并起来就是: `d_h(x) = d_f(x) * w1 = (dw2 * x) * w1` ，所以：

```
dw1 = d_h(x) / f(x) = d_h(x) / (w2 * x)
dw2 = d_h(x) / w1 / x  # 先除以 w1，再除以 x
```

我们按刚才的思路试一下：

```
--- 数据
设 w1 = 3, w2 = 6, x = 2, 则 f(x) = 6x, h(x) = 3f(x) = 18x
f(2) = 12, h(2) = 36

--- 随机初始化 w1, w2
w1 = 1, w2 = 4

--- 调整 10 个循环，结果如下：---
d_hx = -28, dw1:-3.5, dw2: -14.0, new w1: 4.5, new w2: 18.0
d_hx = 126.0, dw1:3.5, dw2: 14.0, new w1: 1.0, new w2: 4.0
d_hx = -28.0, dw1:-3.5, dw2: -14.0, new w1: 4.5, new w2: 18.0
d_hx = 126.0, dw1:3.5, dw2: 14.0, new w1: 1.0, new w2: 4.0
d_hx = -28.0, dw1:-3.5, dw2: -14.0, new w1: 4.5, new w2: 18.0
d_hx = 126.0, dw1:3.5, dw2: 14.0, new w1: 1.0, new w2: 4.0
d_hx = -28.0, dw1:-3.5, dw2: -14.0, new w1: 4.5, new w2: 18.0
d_hx = 126.0, dw1:3.5, dw2: 14.0, new w1: 1.0, new w2: 4.0
d_hx = -28.0, dw1:-3.5, dw2: -14.0, new w1: 4.5, new w2: 18.0
d_hx = 126.0, dw1:3.5, dw2: 14.0, new w1: 1.0, new w2: 4.0
```

显然，我们遇到了新问题：无论如何调整， `w1` 和 `w2` 只是在不停地来回震荡，无法学习到正确的值。

问题出在哪里？

问题不在于来回震荡，问题在于震荡幅度每次都一样大，使得这个震荡停不下来。一个钟摆来回摇摆，只要摆动幅度逐渐变小，那么它最终就会停下来。

所以灵感来了，让我们把震荡幅度每次都变小一点。从数学上表达：

```
w = w - dw * learning_rate
```

这个 `learning_rate` 原本是 `1` 被我们忽略掉了，当我们取一个`大于 0 小于 1 `的值时，震荡的幅度就会越来越小。

现在，取 `learning_rate = 0.6` 试试：

```
--- 数据
设 w1 = 3, w2 = 6, x = 2, 则 f(x) = 6x, h(x) = 3f(x) = 18x
f(2) = 12, h(2) = 36

--- 随机初始化 w1, w2
w1 = 1, w2 = 4

--- 调整 10 个循环，结果如下：---
h(x) =  8.0000, d_hx = -28.0000, dw1:-3.5000, dw2: -14.0000, new w1:  3.1000, new w2:  12.4000
h(x) =  76.8800, d_hx =  40.8800, dw1: 1.6484, dw2:  6.5935, new w1:  2.1110, new w2:  8.4439
h(x) =  35.6495, d_hx = -0.3505, dw1:-0.0208, dw2: -0.0830, new w1:  2.1234, new w2:  8.4937
h(x) =  36.0713, d_hx =  0.0713, dw1: 0.0042, dw2:  0.0168, new w1:  2.1209, new w2:  8.4836
h(x) =  35.9858, d_hx = -0.0142, dw1:-0.0008, dw2: -0.0034, new w1:  2.1214, new w2:  8.4856
h(x) =  36.0028, d_hx =  0.0028, dw1: 0.0002, dw2:  0.0007, new w1:  2.1213, new w2:  8.4852
h(x) =  35.9994, d_hx = -0.0006, dw1:-0.0000, dw2: -0.0001, new w1:  2.1213, new w2:  8.4853
h(x) =  36.0001, d_hx =  0.0001, dw1: 0.0000, dw2:  0.0000, new w1:  2.1213, new w2:  8.4853
h(x) =  36.0000, d_hx = -0.0000, dw1:-0.0000, dw2: -0.0000, new w1:  2.1213, new w2:  8.4853
h(x) =  36.0000, d_hx =  0.0000, dw1: 0.0000, dw2:  0.0000, new w1:  2.1213, new w2:  8.4853
```

成功了吗？

`d_hx` 也就是误差的确逐步降低到 0，可是学到的 `w1 = 2.1213, w2 = 8.4853` ，而我们正确答案是 `w1 = 3, w2 = 6`。怎么对不上呢？

细心分析下发现， `h(x) = w1 * f(x) = w1 * w2 * x  = (w1 * w2) * x` ，我们通过 `h(x)` 的误差来学习整个函数的表示，学到的是一个整体的结果，也就是 `w1 * w2`，在正确答案中，`w1 * w2  = 3 * 6 = 18`， 我们的实验结果：

`w1 * w2 = 2.1213 * 8.4853 = 17.9999 ~= 18` 也是对的。

也就是说，我们无意中得到了一个因式分解器，因 `w1, w2` 的初始值不同，我们学习得到不同的参数，这些参数结果对 `h(x)` 来说，效果都是一样的。有兴趣可以试试。

现在来总结一下机器学习程序的几个要素：

1. 参数化，使得学习成为可能
2. 计算输出误差，并且根据输出误差反推参数误差
3. 根据参数误差更新参数
4. 重复 1-3 步

目前为止我们的探索集中在第一步参数化。其实对于一个机器学习程序来说，哪些部分需要学习（参数化），哪些部分不需要学习（单纯进行数据变换）应该是很自由的事情，否则就编写不出灵活的程序。对于不需要学习，只是单纯做数据变换的部分，我们只需要保证在反推参数误差时，正确地传递这些误差信息就可以了。

说得有些抽象，下面举个例子。比方说：

```
h(x) = f(x) ^ 2
f(x) = w * x
```
`h(x)` 是 `f(x)` 的平方。在这里 `h(x)` 只是针对 `f(x)` 的结果做了一个变换（平方），没有任何需要学习的参数。但是，`f(x)` 是一个需要学习的函数，里边有参数 `w`。

要学习 `w`，我们需要知道 `dw`；要知道 `dw`，我们需要知道 `d_h(x)` 和 `dw` 的关系。

我们先不着急找这个关系，先来分析一个更加基本的问题。假如有一个函数 `y = a * b`，`a` 和 `b` 均为变量。那么 `dy` （y 的变化）其实是由 `a` 的变化 `da` ，以及 `b` 的变化 `db`所组成。因为 `y = a * b`，所以 `da` 会被放大 `b` 倍贡献到 `dy`，而 `db` 会被放大 `a` 倍贡献到 `dy`，综合起来就是 `dy = a * db + b * da`。假如 `a = b = x`，也就是 `y = x * x = x ^ 2`， 则有 `dy = x * dx + x * dx = 2 * x * dx`

把 `x` 替换成 `f(x)`, 所以：

```
d_h(x) = 2 * f(x) * d_f(x)
d_f(x) = dw * x
-->
dw = d_h(x) / (2 * f(x)) / x
```
有了这个关系，代入某个用例验证一下：

```
待学习：
h(x) = f(x) ^ 2
f(x) = w * x
w = 8
---
初始化：
w = 2  # 随机
learning_rate = 0.4
---
10 个循环结果：
out_true: 64.0000, out_guess:  4.0000, d_h_x: -60.0000, d_w: -15.0000, w: 17.0000
out_true: 256.0000, out_guess:  1156.0000, d_h_x: 900.0000, d_w: 6.6176, w: 10.3824
out_true: 576.0000, out_guess:  970.1393, d_h_x: 394.1393, d_w: 2.1090, w: 8.2733
out_true: 1024.0000, out_guess:  1095.1677, d_h_x: 71.1677, d_w: 0.2688, w: 8.0045
out_true: 1600.0000, out_guess:  1601.8065, d_h_x: 1.8065, d_w: 0.0045, w: 8.0000
out_true: 2304.0000, out_guess:  2304.0007, d_h_x: 0.0007, d_w: 0.0000, w: 8.0000
out_true: 3136.0000, out_guess:  3136.0000, d_h_x: 0.0000, d_w: 0.0000, w: 8.0000
out_true: 4096.0000, out_guess:  4096.0000, d_h_x: 0.0000, d_w: 0.0000, w: 8.0000
out_true: 5184.0000, out_guess:  5184.0000, d_h_x: 0.0000, d_w: 0.0000, w: 8.0000
```

Python 代码在[这里](https://gist.github.com/py0x/1083a81285505af6775a54ef5c5188f0)

最终成功学习到 `w = 8`。

我们可以总结一下，机器学习的函数和普通编程下的函数有两个不同点：

1. **可能**带有待学习的参数 w
2. 除了能够正向计算结果，还需要反向计算误差（为了调整参数）

只要我们的函数都满足这两点，并且能够这些函数组合起来，就能得到一个能够学习的程序。

下面，我们来研究函数组合的问题。

最简单的组合方式是：一个函数的输出是另一个函数的输入。这种情况我们已经通过上文的 `h(x)`  和 `f(x)` 无意中研究过。

在编程视角下，更基本的组合方式是 `if ... else ...`。

问题是这种逻辑控制语句，怎么计算和传播误差？

首先，我们需要把它表示出来。

```
if p(x):
    return f(x)
else:
    return h(x)
```

然后进行数学化。

非此即彼的 `if else`，在数学上，其实是 1 和 0.

`1 * f(x) + 0 * h(x)` 就是 `f(x)`。

`0 * f(x) + 1 * h(x)` 就是 `h(x)`。

这个 `1` 和 `0` 的逻辑关系需要学习出来，其实就是变成参数：

```
w1 * f(x) + w2 * h(x)
```

接下来的问题是，`p(x)` 怎么和它们关联起来？

其实细细想一下，这个 `w1` 和 `w2` 正是 `p(x)` 的输出结果。而且 `w2 = 1 - w1`

于是我们只要保证 `p(x)` 的输出范围在 `0 ~ 1`，那么有：

```
w = p(x)
output = w * f(x) + (1 - w) * h(x)
```

这里需要注意的是，`w` 并不是直接学习得到的参数，而是 `p(x)` 的输出结果，我们并不是直接学习 `w`，而是学习一个 `p(x)` ，也就是学习 `p(x)` 内部的参数。为了不容易混淆，我把它换成 `k`:

```
k = p(x)
output = k * f(x) + (1 - k) * h(x)
```

大功接近告成。剩下的问题是怎么保证 `p(x)` 的输出落在 0 至 1 之间。

很简单，套上一个值域在 0 至 1 之间的变换函数即可。

这种函数有很多，比如可以自己构造一个 `1 / (1 + f(x) ^ 2)`。(这个函数的误差怎么反向传播，可以自己试试）

至此，我们有了可以学习的 `if ... else ...` 控制语句。

有了这个思路，其实查字典也可以数学化表示。

一个字典，其实是 `{k, v}` 容器，查字典就是有一个 `q`, 当 `q == k` 时，返回对应的 `v`。

在机器学习的世界里，`(q, k, v)` 都是数字。

判断 `q == k` 的操作，表达为 `q` 和 `k` 的差别，比如说 `q - k` 的大小。于是有：

```
d1 = q - k1
d2 = q - k2
d3 = q - k3
...
```

然后把 `d1, d2, d3 ...` 进行归一化操作。再把归一化后的结果作为权重 `w`，去提取 `v`，也就是 `(1-w) * v` (需要用 `1 - w` 是因为差异越小，提取权重越大）。

归一化比较简单的方式是: 

```
w1 = d1 / (d1 + d2 + d3 + ... + dn)
w2 = d2 / (d1 + d2 + d3 + ... + dn)
w3 = d3 / (d1 + d2 + d3 + ... + dn)
...
```

我们现在可以总结一下：

要使得一个程序能够变成机器学习程序，思路是把所有的操作变成数学公式表达，这个数学公式需要能够反向计算出误差是怎么传播的。

范式如下：

1. 输入输出数据转换成数字
2. 控制操作转换成数学公式
3. 正向计算结果和误差
4. 反向根据误差更新参数

在机器学习的世界中，一个操作既能正向计算结果，也能反向传播误差并更新参数。当我们把常用的操作封装起来，然后提供一些能组合这些操作的胶水操作，用户就可以像搭积木一样利用我们提供的操作原语 (primitive) 来搭建一个可以学习的程序，这个程序因为参数是未知的，而架构是已知的，所以叫模型。这个行为就是所谓的机器学习建模。

搭建好的模型，通过大量灌入数据，调整模型参数，就是所谓机器学习训练。

而本文提到的这种编程范式，有一个正式的名字，叫可微分编程。可微分，指的是这个数学操作可微，使得误差可以反向传播，从而使程序可以自我学习。

---
后记：

关于机器学习，网上有大量优秀的文章和教程。我尝试补充一个更基础且具有启发性的角度。

