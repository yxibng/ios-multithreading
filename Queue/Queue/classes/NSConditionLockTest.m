//
//  NSConditionLockTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "NSConditionLockTest.h"
#define IDLE 0
#define START 1
#define TASK_1_FINISHED 2
#define TASK_2_FINISHED 3
#define CLEANUP_FINISHED 4

#define SHARED_DATA_LENGTH 1024 * 1024 * 1024

@implementation NSConditionLockTest

+ (void)startTest
{
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:IDLE];
    char *shared_data = calloc(SHARED_DATA_LENGTH, sizeof(char));
    
    [NSThread detachNewThreadWithBlock:^{
        [lock lockWhenCondition:START];
        
        NSLog(@"[Thread-1]: Task 1 started...");
        for (size_t i = 0; i < SHARED_DATA_LENGTH; i++) {
            shared_data[i] = 0x00;
        }
        [lock unlockWithCondition:TASK_1_FINISHED];
    }];
    
    [NSThread detachNewThreadWithBlock:^{
        [lock lockWhenCondition:TASK_1_FINISHED];
        NSLog(@"[Thread-2]: Task 2 started...");
        for (size_t i = 0; i < SHARED_DATA_LENGTH; i++) {
            char c = shared_data[i];
            shared_data[i] = ~c;
        }
        [lock unlockWithCondition:TASK_2_FINISHED];
    }];
    
    [NSThread detachNewThreadWithBlock:^{
        [lock lockWhenCondition:TASK_2_FINISHED];
        
        NSLog(@"[Thread-3]: Cleaning up...");
        free(shared_data);
        [lock unlockWithCondition:CLEANUP_FINISHED];
    }];
    
    NSLog(@"[Thread-main]: Threads set up. Waiting for 2 task to finish");
    [lock unlockWithCondition:START];
    [lock lockWhenCondition:CLEANUP_FINISHED];
    NSLog(@"[Thread-main]: Completed");
    
    
}
@end
