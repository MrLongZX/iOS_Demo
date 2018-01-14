//
//  MyClass.h
//  RuntimeDemo
//
//  Created by 苏友龙 on 2018/1/14.
//  Copyright © 2018年 YL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyClass : NSObject<NSCopying,NSCoding>

@property (nonatomic, strong) NSArray *array;

@property (nonatomic, copy) NSString *string;

- (void)method1;

- (void)method2;

+ (void)classMethod1;

@end
