//
//  Engine.m
//  testGCD
//
//  Created by 合商云购 on 2017/11/3.
//  Copyright © 2017年 合商云购. All rights reserved.
//

#import "Engine.h"

@implementation Engine

-(void)queryCompletionLongTime:(void (^)(BOOL value))success{
    NSLog(@"1发送网络请求");
    sleep(4);
    NSLog(@"1请求完成");
    success(YES);
}

-(void)queryCompletionShortTime:(void (^)(BOOL value))success{
    NSLog(@"2发送网络请求");
    sleep(1);
    NSLog(@"2请求完成");
    success(YES);
}

@end

