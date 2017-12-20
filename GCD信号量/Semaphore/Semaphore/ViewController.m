//
//  ViewController.m
//  Semaphore
//
//  Created by 合商云购 on 2017/11/3.
//  Copyright © 2017年 合商云购. All rights reserved.
//

#import "ViewController.h"
#import "Engine.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self semaphore];
}

- (void)semaphore{
    //信号量 总量为0
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(globalQueue, ^{
        Engine *engine = [[Engine alloc] init];
        [engine queryCompletionLongTime:^(BOOL isOpen) {
            NSLog(@"1请求结果");
            //信号量 加一 变为1 不再堵塞线程
            dispatch_semaphore_signal(sema);
        }];
    });
    //信号量sema总量为0 堵塞线程
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    dispatch_async(globalQueue, ^{
        Engine *eng = [[Engine alloc] init];
        [eng queryCompletionShortTime:^(BOOL isOpen) {
            NSLog(@"2请求结果");
            //信号量 加一 变为1 不再堵塞线程
            dispatch_semaphore_signal(sema);
        }];
    });
    //信号量sema总量为1 减一 变为0 堵塞线程
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    NSLog(@"3333");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
