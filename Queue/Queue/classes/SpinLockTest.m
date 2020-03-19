//
//  SpinLockTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "SpinLockTest.h"
#import <os/lock.h>
#import <libkern/OSAtomic.h>

@implementation SpinLockTest

- (void)startTest
{
    BOOL useSpinLock = YES;
    if (useSpinLock) {
        //iOS10 以后被废弃了。 因为不再安全
        OSSpinLock lock = OS_SPINLOCK_INIT;
        OSSpinLockLock(&lock);
        OSSpinLockUnlock(&lock);
    } else {
        //iOS 10 以后才可以使用，为了替代OSSpinLock，因为OSSpinLock某些情况下会造成优先级反转，形成死锁。
        os_unfair_lock_t unfairLock;
        unfairLock = &(OS_UNFAIR_LOCK_INIT);
        os_unfair_lock_lock(unfairLock);
        os_unfair_lock_unlock(unfairLock);
    } 
}


@end
