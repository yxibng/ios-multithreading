//
//  QueueTests.m
//  QueueTests
//
//  Created by 姚晓丙 on 2018/12/22.
//  Copyright © 2018 姚晓丙. All rights reserved.
//

#import <XCTest/XCTest.h>


typedef struct {
    char *name;
    int age;
    char *sex;
} MyDataContext;


@interface QueueTests : XCTestCase

@end

@implementation QueueTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testDeadlock {
    dispatch_queue_t myCustomQueue;
    myCustomQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
    
    dispatch_async(myCustomQueue, ^{
        printf("Do some work here.\n");
    });
    
    printf("The first block may or may not have run.\n");
    
    dispatch_sync(myCustomQueue, ^{
        printf("Do some more work here.\n");
    });
    printf("Both blocks have completed.\n");

    
}


- (void)testCreateQueue {
    /*
     #define DISPATCH_QUEUE_PRIORITY_HIGH 2
     #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
     #define DISPATCH_QUEUE_PRIORITY_LOW (-2)
     #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
     */
    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    /*
     DISPATCH_QUEUE_SERIAL
     DISPATCH_QUEUE_CONCURRENT
     */
    dispatch_queue_t serial = dispatch_queue_create("com.example.queue.serial", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrent = dispatch_queue_create("com.example.queue.concurrent", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"%@\n%@\n%@",global,serial,concurrent);
}


- (void)testCreateQueueWithContext {
    
    dispatch_queue_t queue = [self createQueueWithContext];
    //add tasks
    dispatch_async(queue, ^{
        
        printf("task1\n");
        MyDataContext *context = dispatch_get_context(queue);
        printf("name = %s, age = %d, sex = %s\n",context->name, context->age, context->sex);
        //modify the context
        context->age = 11;
        
    });
    
    dispatch_async(queue, ^{
        printf("task2\n");
        MyDataContext *context = dispatch_get_context(queue);
        printf("name = %s, age = %d, sex = %s\n",context->name, context->age, context->sex);
    });
}



- (dispatch_queue_t)createQueueWithContext {
    
    MyDataContext *data = (MyDataContext *)malloc(sizeof(MyDataContext));
    data->name = "context";
    data->age = 10;
    data->sex = "male";
    dispatch_queue_t queue = dispatch_queue_create("com.example.queue.withcontext", DISPATCH_QUEUE_SERIAL);
    dispatch_set_context(queue, data);
    
    dispatch_set_finalizer_f(queue, &myFinalizerFunction);
    return queue;
}



void myFinalizerFunction(void *context)
{
    MyDataContext* theData = (MyDataContext*)context;
    // Clean up the contents of the structure
    myCleanUpDataContextFunction(theData);
    // Now release the structure itself.
    free(theData);
}

void myCleanUpDataContextFunction(void *context)
{
    MyDataContext* theData = (MyDataContext*)context;
    printf("%s",__FUNCTION__);
    printf("name = %s, age = %d, sex = %s",theData->name, theData->age, theData->sex);
}


- (void)testPerformingCompletionBlockWhenTaskIsDone {
    
    dispatch_queue_t queue = dispatch_queue_create("com.example.queue.completion", DISPATCH_QUEUE_SERIAL);
    int a[5] = {1, 2, 3, 4, 5};
    average_async(a, 5, queue, ^(int average) {
        NSLog(@"done, average = %d", average);
    });
}


- (void)testApply {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    int count = 100;
    dispatch_apply(count, queue, ^(size_t i) {
        printf("%u\n",i);
    });
}


- (void)testSemaphores {
    
    // Create the semaphore, specifying the initial pool size
    dispatch_semaphore_t fd_sema = dispatch_semaphore_create(1);
    
    // Wait for a free file descriptor
    dispatch_semaphore_wait(fd_sema, DISPATCH_TIME_FOREVER);
    //处理耗时的工作
    
    for (int i = 0; i< 1000; i++) {
        
    }
    
    NSLog(@"do something in semaphores");
    
//    fd = open("/etc/services", O_RDONLY);
//    // Release the file descriptor when done
//    close(fd);
    dispatch_semaphore_signal(fd_sema);

}

- (void)testGroups
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        // Some asynchronous work
        NSLog(@"task1");
    });
    
    dispatch_group_async(group, queue, ^{
        // Some asynchronous work
        NSLog(@"task2");
    });
    
    
    for (int i = 0; i< 100000; i++) {
        
    }
    
    NSLog(@"do other work while the tasks execute");
    // Do some other work while the tasks execute.
    
    // When you cannot make any more forward progress,
    // wait on the group to block the current thread.
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"after group");
    
    // Release the group when it is no longer needed.
//    dispatch_release(group);

}




void average_async(int *data, size_t len,
                   dispatch_queue_t queue, void (^block)(int))
{
    // Retain the queue provided by the user to make
    // sure it does not disappear before the completion
    // block can be called.
//    dispatch_retain(queue);
    
    // Do the work on the default concurrent queue and then
    // call the user-provided block with the results.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int avg = average(data, len);
        dispatch_async(queue, ^{ block(avg);});
        
        // Release the user-provided queue when done
//        dispatch_release(queue);
    });
}




int average(int *data, size_t length) {
    
    int sum = 0;
    for (int i = 0; i< length; i++) {
        sum += data[i];
    }
    return sum/length;
}





@end
