+++
title = "深入理解 Rust - 异步编程内幕"
description = "Rust async in depth"
+++

异步编程主要是为了更好地利用 CPU 资源和 I/O 资源。

我们不希望因为一个线程等待 I/O 事件而卡住（block)，导致 CPU 也闲置下来。于是，假如一个线程因等待 I/O 事件而卡住，我们希望把它挂起，切换到执行另一个线程，不让 CPU 闲置。

但如果我们有很多 I/O 事件（比如服务上万个 client 的 web server），我们是不是要创建上万个线程，然后来回切换？

这样做的开销太大了。线程是一个比较"重"的单元，它的创建和切换，都需要消耗资源（如：创建线程需要为其开辟 stack，消耗内存，切换线程需要较大的时延）。所以当量级太大时，我们就需要考虑别的方案。

这个别的方案，就是用"函数"来代替"线程"。

创建成千上万的"函数"，然后来回切换。

我们把这里的"函数"，叫 Task (任务)。负责调度执行这些 Tasks 的逻辑单元，叫 Executor。

但是问题来了，这个 Executor 怎么知道哪些 Tasks 可以被继续执行，而哪些 Tasks 还没 ready 因为它还在等 I/O 事件？这些 I/O 事件怎么管理？

似乎缺失了一环。

这个缺失的一环，就是 Event Center (事件中心)。

Event Center 支持注册并监听某个事件源 (Event Source)，当这个事件源 (Event Source) 出现了预期的事件 (Event) 时，通知你。

有了事件中心，我们就不需要阻塞等待事件了。只需要把 Event Source 注册一下，然后等待事件中心的通知即可。

比如我有一个 socket (event source)，我不知道什么时候里边才有内容可读，于是我把这个 socket 注册到事件中心，希望在它可读的时候得到通知。形如：

```
event_center.register(my_socket, "Readable");
```
这种事件中心的实现，实际上是用到了所谓 I/O multiplexing 的技术。虽然本质上还是阻塞等待，但却是用一个专门的线程，去阻塞等待多个 event source; 而不是每个 event source 都分别使用一个线程去阻塞等待。
(可以参考 Linux 下的 [epoll](https://man7.org/linux/man-pages/man7/epoll.7.html), FreeBSD 下的 [kqueue](https://www.freebsd.org/cgi/man.cgi?query=kqueue&sektion=2) 等。
[Tokio](https://github.com/tokio-rs/tokio) 所开发和使用的跨平台事件中心实现 [Mio](https://github.com/tokio-rs/mio)，就是基于 epoll, kqueue, 和 IOCP 所做的抽象）。

总结一下：



