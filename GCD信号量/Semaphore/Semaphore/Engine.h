//
//  Engine.h
//  testGCD
//
//  Created by 合商云购 on 2017/11/3.
//  Copyright © 2017年 合商云购. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Engine : NSObject

-(void)queryCompletionLongTime:(void (^)(BOOL value))success;

-(void)queryCompletionShortTime:(void (^)(BOOL value))success;

@end
