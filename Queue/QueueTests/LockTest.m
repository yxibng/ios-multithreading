//
//  LockTest.m
//  QueueTests
//
//  Created by 姚晓丙 on 2018/12/23.
//  Copyright © 2018 姚晓丙. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <pthread.h>
//#import <libkern/OSAtomic.h>
#import <os/lock.h>

@interface LockTest : XCTestCase
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation LockTest
{
    pthread_mutex_t mutex;
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.array = @[].mutableCopy;
    self.lock = [[NSLock alloc] init];
    self.lock.name = @"com.example.lock.nslock";
    pthread_mutex_init(&mutex,NULL);
}

- (void)addObjectWithSynchronized:(NSNumber *)number
{
    if (number == nil) {
        return;
    }

    @synchronized (self) {
        [self.array addObject:number];
    }
}


- (void)addObjectWithNSLock:(NSNumber *)number {
    
    if (number == nil) {
        return;
    }

    [self.lock lock];
    [self.array addObject:number];
    [self.lock unlock];
}


- (void)addObjectWithPThreadMutex:(NSNumber *)number
{
    if (number == nil) {
        return;
    }
    pthread_mutex_lock(&mutex);
    [self.array addObject:number];
    pthread_mutex_unlock(&mutex);
    
}




- (void)testNSLock {

    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_apply(10, global, ^(size_t index) {
        dispatch_group_async(group, global, ^{
            [self addObjectWithNSLock:@(index)];
        });
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"arrry = %@",self.array);
    });
}

- (void)testSynchronized {
    
    
    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_apply(10, global, ^(size_t index) {
        dispatch_group_async(group, global, ^{
            [self addObjectWithSynchronized:@(index)];
        });
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"arrry = %@",self.array);
    });
}


- (void)testPThreadMutex {
    
    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_apply(10, global, ^(size_t index) {
        dispatch_group_async(group, global, ^{
            [self addObjectWithPThreadMutex:@(index)];
        });
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"arrry = %@",self.array);
    });
}

- (void)testCondition
{
    
    NSMutableArray *products = [NSMutableArray array];
    NSCondition *lock = [[NSCondition alloc] init];
    //Son 线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lock lock];
        
        if (products.count < 10) {
            NSLog(@"wait for product");
            [lock wait];
            NSLog(@"after wait");
        }
//        while (products.count <= 10) {
//
//        }
        [products removeObjectAtIndex:0];
        NSLog(@"consume a product");
        [lock unlock];
    });
    
    //Father线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (products.count < 10) {
            [lock lock];
            [products addObject:@1];
            NSLog(@"produce a product");
            [lock signal];
            NSLog(@"after signal");
            [lock unlock];
        }

    });
    
}

- (void)testSpinLock
{
//    OSSpinLock lock = OS_SPINLOCK_INIT;
//    OSSpinLockLock(&lock);
//    OSSpinLockUnlock(&lock);
os_unfair_lock_t unfairLock;
unfairLock = &(OS_UNFAIR_LOCK_INIT);
os_unfair_lock_lock(unfairLock);
os_unfair_lock_unlock(unfairLock);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    pthread_mutex_destroy(&mutex);
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
