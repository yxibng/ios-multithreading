//
//  ViewController.m
//  Queue
//
//  Created by 姚晓丙 on 2018/12/22.
//  Copyright © 2018 姚晓丙. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self createNSTimerAndFire];
//    [self createNSTimerAndAddToRunloop];
//    [self createDispatchTimer];
    [self createDisplayLink];
    
}


-(void)createNSTimerAndFire
{
    NSMutableDictionary *dic = @{@"count":@10}.mutableCopy;
    NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runTimer:) userInfo:dic repeats:YES];
    [timer fire];
}

-(void)createNSTimerAndAddToRunloop
{
    NSMutableDictionary *dic = @{@"count":@10}.mutableCopy;
    NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runTimer:) userInfo:dic repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


- (void)dispatch_delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //do stomething after 3.0secs
    });
}

- (void)createDispatchTimer
{
    __block int count = 10;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        count--;
        NSLog(@"count--%d",count);
        
        if (count <= 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //do something in the main thread
            });
            
            // time out, cancel timer
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
}


- (void)createDisplayLink {
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkHandler:)];
    link.frameInterval = 1;
    //ios10.0以后使用 preferredFramesPerSecond
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkHandler:(CADisplayLink *)sender
{
    NSLog(@"sender = %@",sender);
    
    [sender invalidate];
}

- (void)runTimer:(NSTimer *)timer
{
    NSLog(@"timer = %@, userInfo = %@",timer,timer.userInfo);

    NSMutableDictionary *dic = timer.userInfo;
    
    NSNumber *count = dic[@"count"];
    
    if (count.integerValue <= 0) {
        [timer invalidate];
        return;
    }
    dic[@"count"] = @(count.integerValue-1);
}

@end
