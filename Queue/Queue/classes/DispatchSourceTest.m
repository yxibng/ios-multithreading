//
//  DispatchSourceTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "DispatchSourceTest.h"

@implementation DispatchSourceTest

- (void)startTest
{
    dispatch_queue_t queue = dispatch_queue_create("com.example.queue.source.timer", NULL);
    __block int count = 10;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
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
