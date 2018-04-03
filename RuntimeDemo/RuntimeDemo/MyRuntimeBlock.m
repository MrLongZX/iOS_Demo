//
//  MyRuntimeBlock.m
//  RuntimeDemo
//
//  Created by 苏友龙 on 2018/1/27.
//  Copyright © 2018年 YL. All rights reserved.
//

#import "MyRuntimeBlock.h"
#import <objc/runtime.h>

@implementation MyRuntimeBlock

- (void)runtimeBlock {
    IMP imp = imp_implementationWithBlock(^NSString *(id obj, NSString *str){
        NSLog(@"str:%@",str);
        return @"56789";
    });
    
    class_addMethod(self.class, @selector(testBlock:), imp, "v@:@");
    NSString *result = [self performSelector:@selector(testBlock:) withObject:@"goooooooogle"];
    NSLog(@"rusult:%@",result);
}

@end
