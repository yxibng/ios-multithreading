//
//  DispatchQueueTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "DispatchQueueTest.h"

typedef struct {
    void *ref;
    char *task_name;
} QueueContext;



@implementation DispatchQueueTest


- (void)createQueue
{
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
}


- (void)createSerialQueue
{
    dispatch_queue_t queue = dispatch_queue_create("com.xxx.serial.queue", DISPATCH_QUEUE_SERIAL);
    for (int i =0; i< 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"index = %d", i);
        });
    }
}

- (void)createConcurrentQueue
{
    dispatch_queue_t queue = dispatch_queue_create("com.xxx.serial.queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i =0; i< 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"index = %d", i);
        });
    }
}


- (void)createQueueWithTask
{
    dispatch_queue_t queue = [self queueWithContext];
    //add tasks
    dispatch_async(queue, ^{
        
        printf("task1\n");
        QueueContext *context = dispatch_get_context(queue);
        DispatchQueueTest *ref = (__bridge DispatchQueueTest *)(context->ref);
        char *task_name = context->task_name;
        NSLog(@"ref = %@, task_name = %s",ref, task_name);
    });
    
    dispatch_async(queue, ^{
        printf("task2\n");
        QueueContext *context = dispatch_get_context(queue);
        DispatchQueueTest *ref = (__bridge DispatchQueueTest *)(context->ref);
        char *task_name = context->task_name;
        NSLog(@"ref = %@, task_name = %s",ref, task_name);
    });
    
}



- (dispatch_queue_t)queueWithContext {
    
    QueueContext *context = (QueueContext *)malloc(sizeof(QueueContext));
    context->ref = (__bridge void *)(self);
    context->task_name = "com.xxx.task";
    dispatch_queue_t queue = dispatch_queue_create("com.example.queue.withcontext", DISPATCH_QUEUE_SERIAL);
    dispatch_set_context(queue, context);
    dispatch_set_finalizer_f(queue, &myFinalizerFunction);
    return queue;
}



void myFinalizerFunction(void *context)
{
    QueueContext* theData = (QueueContext*)context;
    // Clean up the contents of the structure
    myCleanUpDataContextFunction(theData);
    // Now release the structure itself.
    free(theData);
}

void myCleanUpDataContextFunction(void *context)
{
    QueueContext* theData = (QueueContext*)context;
    printf("%s",__FUNCTION__);
    DispatchQueueTest *ref = (__bridge DispatchQueueTest *)(theData->ref);
    char *task_name = theData->task_name;
    NSLog(@"ref = %@, task_name = %s",ref, task_name);
}


- (void)testApply
{
    BOOL serial = YES;
    dispatch_queue_t queue;
    if (serial) {
        /*
         串行队列，按顺序执行, 不需要做线程同步
         */
        queue = dispatch_queue_create("com.xxx.serial.queue", DISPATCH_QUEUE_SERIAL);
    } else {
        /*
         如果是并发队列，线程并发执行，需要注意线程同步
         */
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    int count = 100;
    dispatch_apply(count, queue, ^(size_t i) {
        printf("%zu\n",i);
    });
}

- (void)testBarrier
{
    dispatch_queue_t queue = dispatch_queue_create("queue.concurrent", DISPATCH_QUEUE_CONCURRENT);

    __block int value = 1;

    dispatch_async(queue, ^{
        NSLog(@"task1,value = %d",value);
    });

    dispatch_async(queue, ^{
        NSLog(@"task2, value = %d",value);
    });

    dispatch_barrier_async(queue, ^{
        value = 2;
        NSLog(@"barrier, modify value to %d", value);
    });

    dispatch_async(queue, ^{
        NSLog(@"task3, value = %d",value);
    });
}


@end
