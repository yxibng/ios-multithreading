//
//  PThreadTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "PThreadTest.h"
#import <pthread.h>

@interface PThreadTest()
@property (nonatomic, strong) NSMutableArray<NSString *> *array;
@property (nonatomic) pthread_mutex_t mutex;
@property (nonatomic) pthread_mutex_t recursiveMutex;
@end


@implementation PThreadTest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _array = @[].mutableCopy;
        //normal
        pthread_mutex_init(&_mutex,NULL);
        
        //recursive lock
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr); //初始化attr并且给它赋予默认
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); //设置锁类型，这边是设置为递归锁
        pthread_mutex_init(&_recursiveMutex, &attr);
        pthread_mutexattr_destroy(&attr); //销毁一个属性对象，在重新进行初始化之前该结构不能重新使用
    }
    return self;
}

- (void)startTest
{
    for (int i = 0; i< 10; i ++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            pthread_mutex_lock(&self->_mutex);
            [self.array addObject:@(i).stringValue];
            pthread_mutex_unlock(&self->_mutex);
            NSLog(@"index = %d, array = %@", i, self.array);
        });
    }
}


- (void)recursiveLockTest
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            pthread_mutex_lock(&self->_recursiveMutex);
            if (value > 0) {
                NSLog(@"value: %d", value);
                RecursiveBlock(value - 1);
            }
            pthread_mutex_unlock(&self->_recursiveMutex);
        };
        RecursiveBlock(5);
    });
}



@end
