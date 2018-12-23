//
//  SourceTest.m
//  QueueTests
//
//  Created by 姚晓丙 on 2018/12/22.
//  Copyright © 2018 姚晓丙. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SourceTest : XCTestCase

@end

@implementation SourceTest

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


- (void)testTimerSource {
    
//    dispatch_queue_t queue = dispatch_queue_create("com.example.queue.source.timer", NULL);
    
    __block int count = 10;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        count--;
        NSLog(@"count--%d",count);

        if (count <= 0) {
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
}



@end
