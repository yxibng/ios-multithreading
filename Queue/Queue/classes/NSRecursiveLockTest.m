//
//  NSRecursiveLockTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "NSRecursiveLockTest.h"

@implementation NSRecursiveLockTest

+ (void)startTest
{
    //也可以使用pthread_mutex来实现
    NSRecursiveLock *rLock = [NSRecursiveLock new];
    rLock.name = @"com.xxx.ns.resursive.lock";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            [rLock lock];
            if (value > 0) {
                NSLog(@"线程%d", value);
                RecursiveBlock(value - 1);
            }
            [rLock unlock];
        };
        RecursiveBlock(4);
    });
}

@end
