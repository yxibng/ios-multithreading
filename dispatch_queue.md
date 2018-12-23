# type
1. Serial (private dispatch queues)
    * 按顺序，每次执行一个任务
    * 会开辟新的线程（被当前的dispatch queue管理），队列任务会在这个线程中执行顺序执行，每个任务的线程可能不同
    * 可以创建任意多的串行队列，这些队列之间并发执行
2. Concurrent (a type of global dispatch queue)
    * 每次执行一个或多个任务，任务的开启是按添加到队列的顺序的
    * 当前正在执行的多个任务分布在不同的线程（被队列所管理）
    * 每次执行的任务数是变化的，依赖于操作系统的情况
3. Main dispatch queue (a globally available serial queue)
    * 一个全局的串行队列，任务在主线程执行
    * 跟程序的runloop配合，将队列任务插入到runloop的其他事件源之中去处理
    * 一般用于主线程同步

需要注意的点：

* 队列与队列之间是并发执行的
* 系统决定任意时刻执行的任务的总数。（100个任务分布在一百条队列里面，这些任务不会同时执行，除非有100个有效核心）
* 系统选择根据队列优先级考虑去开启哪个新的task
* 任务被添加到队列的时候必须是ready to excute状态
* 队列是一种引用计数的类型，要注意dispatch sources的情况（dispatch sources可以绑定一个队列，并且增加这个队列的引用计数。所以，要保证每个dispatch sources被canceled和retain是一对一的）


队列相关的技术：

1. Dispatch groups
    * 观测一组block类型的完成（一组同步或者异步任务的完成）
2. Dispatch semaphores
    * 信号量
3. Dispatch sources
    * 收到系统的事件，会发出通知
    * 根据这些通知可以监测系统事件：处理通知，信号等
    * 订阅了这些通知，在接到通知的时候，会在指定的队列异步处理提交的任务

使用Block来实现任务，需要注意的点

* 捕获标量（简单变量）是可以的， 不要试图捕获大型的struct或者指针类型变量（会在调用的上下文中被创建和删除）。在block执行的时候，这个指针指向的内存可能已经失效了。
* 队列会copy加入的block，在任务执行完的时候release他们。所以不用显示的去copy一个block到一个队列里
* 如果一个block执行非常少的任务，inline执行也许付出的代价会更少，可能没有加入队列的必要。
* 同一个队列共享数据的方法是使用context pointer
* 如果block里面创建了大量的objective-c 的对象，建议使用@autorelease block来进行内存管理。虽然GCD队列有自己的autorelease pools，但是不能确认什么时候会释放pool中的变量。创建自己的autorelease pool允许你更合理的释放pool中的autorelease变量，更好的管理内存。



# 创建和管理队列
1. 获取全局并发队列


    ```
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    ```

    优先级可选
    
    ```
    DISPATCH_QUEUE_PRIORITY_HIGH
    DISPATCH_QUEUE_PRIORITY_DEFAULT
    DISPATCH_QUEUE_PRIORITY_LOW
    DISPATCH_QUEUE_PRIORITY_BACKGROUND
    ```
    第二个参数是保留参数，暂时传0，留作以后扩展用
    
2. 创建串行队列
    
    ```
    dispatch_queue_t queue;
    queue = dispatch_queue_create("com.example.MyQueue", NULL);
    ```
    第一个参数传队列的名字
    第二个参数是队列的属性，传NULL，保留字段，留作扩展使用
3. 运行时获取队列

    * dispatch_get_current_queue
    * dispatch_get_main_queue
    * dispatch_get_global_queue
4. 内存管理
    * dispatch_retain
    * dispatch_release
5. 存储队列自定义的上下文信息
    * dispatch_set_context
    * dispatch_get_context
6. 提供给队里一个清理函数
    * 使用dispatch_set_finalizer_f来指定队列被销毁所执行的函数，一般用来清理上下文数据，只有在上下文指针不为NULL的时候才会被调用。

    ```
    void myFinalizerFunction(void *context)
    {
        MyDataContext* theData = (MyDataContext*)context;
    
        // Clean up the contents of the structure
        myCleanUpDataContextFunction(theData);
    
        // Now release the structure itself.
        free(theData);
    }
    
    dispatch_queue_t createMyQueue()
    {
        MyDataContext*  data = (MyDataContext*) malloc(sizeof(MyDataContext));
        myInitializeDataContextFunction(data);
    
        // Create the queue and set the context data.
        dispatch_queue_t serialQueue = dispatch_queue_create("com.example.CriticalTaskQueue", NULL);
        dispatch_set_context(serialQueue, data);
        dispatch_set_finalizer_f(serialQueue, &myFinalizerFunction);
    
        return serialQueue;
    }

    ```




