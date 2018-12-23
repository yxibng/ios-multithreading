# about dispatch sources
> A dispatch source is a fundamental data type that coordinates the processing of specific low-level system events.

* 一种基本的数据类型
* 用来协调处理底层系统的事件

支持的类型

1. timer dispatch sources generate periodic notifications
	时间源，会产生周期性的通知
2. signal dispatch sources notify you when a UNIX signal arrives
	信号源，当一个UNIX信号到达的时候
3. Descriptor sources notify you of various file- and socket-based operations，such as:
	* When data is available for reading
	* When it is possible to write data
	* When files are deleted, moved, or renamed in the file system
	* When file meta information changes
	
	文件描述源，主要是文件和基于socket的操作的状态有变更的时候给出通知，例如：
	
	* 数据已经准备好被读取了
	* 数据可以写入了
	* 在文件系统中，文件被删除，移动，重命名
	* 文件的元数据被修改的时候
4. Process dispatch sources notify you of process-related events, such as:
	* When a process exits
	* When a process issues a fork or exec type of call
	* When a signal is delivered to the process
	
	事件源被处理的通知，例如：
	
	* 进程退出
	* 当进程发出fork或exec类型的调用时
	* 信号被发送到了进程
	
5. Mach port dispatch sources notify you of Mach-related events.

	Mach 端口源， 发出端口事件通知
	
6.	Custom dispatch sources are ones you define and trigger yourself.

	自己定义的源，自己触发调用

# Creating Dispatch Sources
1. 使用`dispatch_source_create`创建
2. 配置
	* 指定 event handler 
	* 对timer sources， 使用`dispatch_source_set_timer` 设置定时器信息
3. 指定一个 cancellation handler
4. 调用` dispatch_resume` 开始处理事件

## Event Handler
* `dispatch_source_set_event_handler`
*  `dispatch_source_set_event_handler_f`

	```
	// Block-based event handler
	void (^dispatch_block_t)(void)
	 
	// Function-based event handler
	void (*dispatch_function_t)(void *)
	```
	在handler内部，可以获取source发出的事件信息。
	
	```
	dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
	                             myDescriptor, 0, myQueue);
	dispatch_source_set_event_handler(source, ^{
	// Get some data from the source variable, which is captured
	// from the parent context.
	size_t estimated = dispatch_source_get_data(source);
	 
	// Continue reading the descriptor...
	});
	dispatch_resume(source);
	```
	
### 从source里面获取数据的方法
* `dispatch_source_get_handle`
	
	This function returns the underlying system `data type` that the dispatch source manages.		
	
	返回的，主要是管理的数据的类型， 文件描述符， 信号，进程，Mach端口 等。
	
* `dispatch_source_get_data`
	
	This function returns any pending data associated with the event.
	
	返回的主要是关联到事件的数据，从文件读入的字节数，可以写入的空间，文件系统变化的信息，端口事件信息。
	
* `dispatch_source_get_mask`
	
	This function returns the event flags that were used to create the dispatch source
	
### 指定取消的handler
* `dispatch_source_set_cancel_handler`
* `dispatch_source_set_cancel_handler_f`

```
dispatch_source_set_cancel_handler(mySource, ^{
   close(fd); // Close a file descriptor opened earlier.
});
```

# example

1. Timer Source

	```
	dispatch_source_t CreateDispatchTimer(uint64_t interval,
	              uint64_t leeway,
	              dispatch_queue_t queue,
	              dispatch_block_t block)
	{
	   dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
	                                                     0, 0, queue);
	   if (timer)
	   {
	      dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
	      dispatch_source_set_event_handler(timer, block);
	      dispatch_resume(timer);
	   }
	   return timer;
	}
	 
	void MyCreateTimer()
	{
	   dispatch_source_t aTimer = CreateDispatchTimer(30ull * NSEC_PER_SEC,
	                               1ull * NSEC_PER_SEC,
	                               dispatch_get_main_queue(),
	                               ^{ MyPeriodicTask(); });
	 
	   // Store it somewhere for later use.
	    if (aTimer)
	    {
	        MyStoreTimer(aTimer);
	    }
	}dispatch_source_t CreateDispatchTimer(uint64_t interval,
	              uint64_t leeway,
	              dispatch_queue_t queue,
	              dispatch_block_t block)
	{
	   dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
	                                                     0, 0, queue);
	   if (timer)
	   {
	      dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
	      dispatch_source_set_event_handler(timer, block);
	      dispatch_resume(timer);
	   }
	   return timer;
	}
	 
	void MyCreateTimer()
	{
	   dispatch_source_t aTimer = CreateDispatchTimer(30ull * NSEC_PER_SEC,
	                               1ull * NSEC_PER_SEC,
	                               dispatch_get_main_queue(),
	                               ^{ MyPeriodicTask(); });
	 
	   // Store it somewhere for later use.
	    if (aTimer)
	    {
	        MyStoreTimer(aTimer);
	    }
	}
	```

2. Reading Data from a Descriptor
	从文件描述符里读数据
	
	```
	dispatch_source_t ProcessContentsOfFile(const char* filename)
	{
	   // Prepare the file for reading.
	   int fd = open(filename, O_RDONLY);
	   if (fd == -1)
	      return NULL;
	   fcntl(fd, F_SETFL, O_NONBLOCK);  // Avoid blocking the read operation
	 
	   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	   dispatch_source_t readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
	                                   fd, 0, queue);
	   if (!readSource)
	   {
	      close(fd);
	      return NULL;
	   }
	 
	   // Install the event handler
	   dispatch_source_set_event_handler(readSource, ^{
	      size_t estimated = dispatch_source_get_data(readSource) + 1;
	      // Read the data into a text buffer.
	      char* buffer = (char*)malloc(estimated);
	      if (buffer)
	      {
	         ssize_t actual = read(fd, buffer, (estimated));
	         Boolean done = MyProcessFileData(buffer, actual);  // Process the data.
	 
	         // Release the buffer when done.
	         free(buffer);
	 
	         // If there is no more data, cancel the source.
	         if (done)
	            dispatch_source_cancel(readSource);
	      }
	    });
	 
	   // Install the cancellation handler
	   dispatch_source_set_cancel_handler(readSource, ^{close(fd);});
	 
	   // Start reading the file.
	   dispatch_resume(readSource);
	   return readSource;
	}
	```
3. Writing Data to a Descriptor
	向文件描述符里面写数据
	
	```
	dispatch_source_t WriteDataToFile(const char* filename)
	{
	    int fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC,
	                      (S_IRUSR | S_IWUSR | S_ISUID | S_ISGID));
	    if (fd == -1)
	        return NULL;
	    fcntl(fd, F_SETFL); // Block during the write.
	 
	    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	    dispatch_source_t writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE,
	                            fd, 0, queue);
	    if (!writeSource)
	    {
	        close(fd);
	        return NULL;
	    }
	 
	    dispatch_source_set_event_handler(writeSource, ^{
	        size_t bufferSize = MyGetDataSize();
	        void* buffer = malloc(bufferSize);
	 
	        size_t actual = MyGetData(buffer, bufferSize);
	        write(fd, buffer, actual);
	 
	        free(buffer);
	 
	        // Cancel and release the dispatch source when done.
	        dispatch_source_cancel(writeSource);
	    });
	 
	    dispatch_source_set_cancel_handler(writeSource, ^{close(fd);});
	    dispatch_resume(writeSource);
	    return (writeSource);
	}
	
	```	
4. Monitoring a File-System Object 观测文件系统的变化

	```
	dispatch_source_t MonitorNameChangesToFile(const char* filename)
	{
	   int fd = open(filename, O_EVTONLY);
	   if (fd == -1)
	      return NULL;
	 
	   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	   dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
	                fd, DISPATCH_VNODE_RENAME, queue);
	   if (source)
	   {
	      // Copy the filename for later use.
	      int length = strlen(filename);
	      char* newString = (char*)malloc(length + 1);
	      newString = strcpy(newString, filename);
	      dispatch_set_context(source, newString);
	 
	      // Install the event handler to process the name change
	      dispatch_source_set_event_handler(source, ^{
	            const char*  oldFilename = (char*)dispatch_get_context(source);
	            MyUpdateFileName(oldFilename, fd);
	      });
	 
	      // Install a cancellation handler to free the descriptor
	      // and the stored string.
	      dispatch_source_set_cancel_handler(source, ^{
	          char* fileStr = (char*)dispatch_get_context(source);
	          free(fileStr);
	          close(fd);
	      });
	 
	      // Start processing events.
	      dispatch_resume(source);
	   }
	   else
	      close(fd);
	 
	   return source;
	}
	
	```
5. Monitoring Signals 观测系统信号
	
	```
	void InstallSignalHandler()
	{
	   // Make sure the signal does not terminate the application.
	   signal(SIGHUP, SIG_IGN);
	 
	   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	   dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGHUP, 0, queue);
	 
	   if (source)
	   {
	      dispatch_source_set_event_handler(source, ^{
	         MyProcessSIGHUP();
	      });
	 
	      // Start processing signals
	      dispatch_resume(source);
	   }
	}
	```
6. Monitoring a Process 监测一个进程事件
	
	```
	void MonitorParentProcess()
	{
	   pid_t parentPID = getppid();
	 
	   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	   dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_PROC,
	                                                      parentPID, DISPATCH_PROC_EXIT, queue);
	   if (source)
	   {
	      dispatch_source_set_event_handler(source, ^{
	         MySetAppExitFlag();
	         dispatch_source_cancel(source);
	         dispatch_release(source);
	      });
	      dispatch_resume(source);
	   }
	}
	
	```
7. Canceling a Dispatch Source 取消一个源
	```
	void RemoveDispatchSource(dispatch_source_t mySource)
	{
	   dispatch_source_cancel(mySource);
	   dispatch_release(mySource);
	}
	```

	
	




