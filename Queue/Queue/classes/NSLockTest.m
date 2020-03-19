//
//  NSLockTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "NSLockTest.h"
@interface NSLockTest()
@property (nonatomic, strong) NSMutableArray<NSString *> *array;
@property (nonatomic, strong) NSLock *lock;
@end
@implementation NSLockTest
- (instancetype)init
{
    self = [super init];
    if (self) {
        _array = @[].mutableCopy;
        _lock = [[NSLock alloc] init];
        _lock.name = @"com.xxx.nslock";
    }
    return self;
}
- (void)startTest
{
    for (int i = 0; i< 10; i ++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.lock lock];
            [self.array addObject:@(i).stringValue];
            [self.lock unlock];
            NSLog(@"index = %d, array = %@", i, self.array);
        });
    }
}
@end
