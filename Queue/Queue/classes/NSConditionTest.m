//
//  NSConditionTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "NSConditionTest.h"

@implementation NSConditionTest
{
    NSCondition *_myCondition;
    BOOL _someCheckIsTrue;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _someCheckIsTrue = NO;
        _myCondition = [[NSCondition alloc] init];
    }
    return self;
}

#pragma mark Public Methods

- (void)startTest
{
    [self performSelectorInBackground:@selector(_method1) withObject:nil];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(5);
        [self performSelectorInBackground:@selector(_method2) withObject:nil];
    });
}

#pragma mark Private Methods

- (void)_method1
{
    NSLog(@"STARTING METHOD 1");

    NSLog(@"WILL LOCK METHOD 1");
    [_myCondition lock];
    NSLog(@"DID LOCK METHOD 1");

    while (!_someCheckIsTrue)
    {
        NSLog(@"WILL WAIT METHOD 1");
        [_myCondition wait];
        NSLog(@"DID WAIT METHOD 1");
    }

    NSLog(@"WILL UNLOCK METHOD 1");
    [_myCondition unlock];
    NSLog(@"DID UNLOCK METHOD 1");

    NSLog(@"ENDING METHOD 1");
}

- (void)_method2
{
    NSLog(@"STARTING METHOD 2");

    NSLog(@"WILL LOCK METHOD 2");
    [_myCondition lock];
    NSLog(@"DID LOCK METHOD 2");

    _someCheckIsTrue = YES;

    NSLog(@"WILL SIGNAL METHOD 2");
    [_myCondition signal];
    NSLog(@"DID SIGNAL METHOD 2");

    NSLog(@"WILL UNLOCK METHOD 2");
    [_myCondition unlock];
    NSLog(@"DID UNLOCK METHOD 2");
}

@end
