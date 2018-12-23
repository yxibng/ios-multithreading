//
//  TestLock.m
//  Queue
//
//  Created by 姚晓丙 on 2018/12/23.
//  Copyright © 2018 姚晓丙. All rights reserved.
//

#import "TestLock.h"

@interface TestLock()

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) NSLock *lock;


@end

@implementation TestLock

- (instancetype)init
{
    if (self = [super init]) {
        self.array = @[].mutableCopy;
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"com.example.lock.nslock";
    }
    return self;
}


- (void)addObjectWithSynchronized
{
    @synchronized (self.array) {
        [self.array addObject:@1];
    }
}


- (void)addObjectWithNSLock {
    
    [self.lock lock];
    [self.array addObject:@2];
    [self.lock unlock];
    
}









@end
