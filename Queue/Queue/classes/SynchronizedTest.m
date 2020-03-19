//
//  SynchronizedTest.m
//  Queue
//
//  Created by yxibng on 2020/3/19.
//  Copyright © 2020 姚晓丙. All rights reserved.
//

#import "SynchronizedTest.h"
@interface SynchronizedTest()
@property (nonatomic, assign) int count;
@end

@implementation SynchronizedTest


- (void)startTest
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (int i = 0; i< 5; i++) {
            @synchronized (self) {
                self.count++;
            }
            NSLog(@"task_1, count = %d",self.count);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
         for (int i = 0; i < 5; i++) {
             @synchronized (self) {
                 self.count--;
             }
             NSLog(@"task_2, count = %d",self.count);
          }
     });
}




@end
