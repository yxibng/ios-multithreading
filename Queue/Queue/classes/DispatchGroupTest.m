//
//  DispatchGroupTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "DispatchGroupTest.h"

@implementation DispatchGroupTest

- (void)waitGroup
{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_async(group, global, ^{
        //模仿耗时操作
        for (int i = 0; i< 900000; i++) {
        }
        NSLog(@"task1 is done");
    });
    
    
    dispatch_group_async(group, global, ^{
        //模仿耗时操作
        for (int i = 0; i< 100000; i++) {
        }
        NSLog(@"task2 is done");
    });
    
    /*
     dispatch_group_wait会造成阻塞，任务完成之后会继续往下执行
     */
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"all tasks are done");
}

- (void)notifyGroup
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self fetchDataDone_1:^{
        NSLog(@"task1 is done");
        dispatch_group_leave(group);
    }];
    dispatch_group_enter(group);
    [self fetchDataDone_2:^{
        NSLog(@"task2 is done");
        dispatch_group_leave(group);
    }];
    
    /*
     dispatch_group_notify不会造成阻塞
     */
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"all tasks are done");
    });
    
}

- (void)fetchDataDone_1:(void(^)(void))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模仿耗时操作
        for (int i = 0; i< 900000; i++) {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback();
            }
        });
    });
    
}

- (void)fetchDataDone_2:(void(^)(void))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模仿耗时操作
        
        for (int i = 0; i< 100000; i++) {
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback();
            }
        });
    });
}



@end
