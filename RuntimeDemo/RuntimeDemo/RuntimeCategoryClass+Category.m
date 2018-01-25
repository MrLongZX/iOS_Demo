//
//  RuntimeCategoryClass+Category.m
//  RuntimeDemo
//
//  Created by 苏友龙 on 2018/1/25.
//  Copyright © 2018年 YL. All rights reserved.
//

#import "RuntimeCategoryClass+Category.h"
#import <objc/runtime.h>

@implementation RuntimeCategoryClass (Category)

- (void)method2 {
    unsigned int outCount = 0;
    Method *methodList = class_copyMethodList(self.class, &outCount);
    for (int i = 0; i < outCount; i++) {
        Method method = methodList[i];
        const char *name = sel_getName(method_getName(method));
        NSLog(@"RuntimeCategoryClass's method: %s", name);
        if (strcmp(name, sel_getName(@selector(method2)))) {
            NSLog(@"分类方法method2在objc_class的方法列表中");
        }
    }
}

@end
