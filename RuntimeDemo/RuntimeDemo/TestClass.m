//
//  TestClass.m
//  RuntimeDemo
//
//  Created by 苏友龙 on 2018/1/11.
//  Copyright © 2018年 YL. All rights reserved.
//

#import "TestClass.h"
#import <objc/runtime.h>

@implementation TestClass


- (void)ex_registerClassPair {
    Class newClass = objc_allocateClassPair([NSError class], "YLTestClass", 0);
    class_addMethod(newClass, @selector(testMetaClass), (IMP)TestMetaClass, "v@:");
    objc_registerClassPair(newClass);

    id instance = [[newClass alloc] initWithDomain:@"some domain" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
}

void TestMetaClass(id self, SEL _cdm) {

    NSLog(@"this object is %p",self);
    //获取本类 父类
    NSLog(@"class is %@, super class is %@",[self class], [self superclass]);

    Class currrentClass = [self class];
    for (int i = 0; i < 4; i++) {
        NSLog(@"Following the isa pointer %d times gives %p",i, currrentClass);
        currrentClass = objc_getClass((__bridge void *)currrentClass);
    }
    NSLog(@"NSObject's class is %p",[NSObject class]);
    //获取NSObject元类
    NSLog(@"NSObject's meta class is %p",objc_getClass((__bridge void *)[NSObject class]));
}

@end


















