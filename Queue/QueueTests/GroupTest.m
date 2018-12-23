//
//  GroupTest.m
//  QueueTests
//
//  Created by 姚晓丙 on 2018/12/23.
//  Copyright © 2018 姚晓丙. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface GroupTest : XCTestCase

@end

@implementation GroupTest

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
    
    //    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    //        NSLog(@"all tasks are done");
    //    });
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
