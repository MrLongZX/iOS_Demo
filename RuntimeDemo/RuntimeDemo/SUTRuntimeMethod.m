//
//  SUTRuntimeMethod.m
//  RuntimeDemo
//
//  Created by 苏友龙 on 2018/1/24.
//  Copyright © 2018年 YL. All rights reserved.
//

#import "SUTRuntimeMethod.h"
#import <objc/runtime.h>

@interface SUTRuntimeMethodHelper : NSObject

- (void)method2;

@end

@implementation SUTRuntimeMethodHelper

- (void)method2 {
    NSLog(@"%@,%p",self,_cmd);
}

@end

@interface SUTRuntimeMethod()
{
    SUTRuntimeMethodHelper *_helper;
}
@end

@implementation SUTRuntimeMethod

+ (instancetype)object {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _helper = [[SUTRuntimeMethodHelper alloc] init];
    }
    return self;
}

- (void)test {
    [self performSelector:@selector(method2)];
}

//消息转发：动态方法解析
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selectorString = NSStringFromSelector(sel);
    if ([selectorString isEqualToString:@"method3"]) {
        class_addMethod(self.class, @selector(method3), (IMP)functionForMethod3, "@:");
        
    }
    return [super resolveInstanceMethod:sel];
}

void functionForMethod3(id self, SEL _cmd) {
    NSLog(@"%@, %p", self, _cmd);
}

/*
//消息转发：备用接受者
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector");
    NSString *selectorString = NSStringFromSelector(aSelector);
    //将消息转发给_helper来处理
    if ([selectorString isEqualToString:@"method2"]) {
        return _helper;
    }
    return [super forwardingTargetForSelector:aSelector];
}
*/

/*
//消息转发：完整消息转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([SUTRuntimeMethodHelper instancesRespondToSelector:aSelector]) {
            signature = [SUTRuntimeMethodHelper instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([SUTRuntimeMethodHelper instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:_helper];
    }
}
*/

@end
