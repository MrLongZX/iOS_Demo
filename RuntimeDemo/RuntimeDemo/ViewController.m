//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 苏友龙 on 2018/1/10.
//  Copyright © 2018年 YL. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "MyClass.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self ex_registerClassPair];
    
    [self myClassRuntime];
}

//创建类、对象、添加方法
- (void)ex_registerClassPair {
    Class newClass = objc_allocateClassPair([NSError class], "YLTestClass", 0);
    class_addMethod(newClass, @selector(testMetaClass), (IMP)TestMetaClass, "v@:");
    objc_registerClassPair(newClass);
    
    id instance = [[newClass alloc] initWithDomain:@"some domain" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
}

//执行方法
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

- (void)myClassRuntime {
    MyClass *myClass = [[MyClass alloc] init];
    unsigned int outCount = 0;
    Class cls = myClass.class;
    
    NSLog(@"类名 class name:%s",class_getName(cls));
    
    NSLog(@"父类名 super class name:%s", class_getName(class_getSuperclass(cls)));
    
    NSLog(@"是否是元类 myclass is %@ a meta-class", class_isMetaClass(cls)? @"":@"not");
    
    //获取元类
    Class meta_class = objc_getMetaClass(class_getName(cls));
    NSLog(@"%s is meta-class is %s", class_getName(cls), class_getName(meta_class));
    
    NSLog(@"实例变量大小 instance size is:%zu", class_getInstanceSize(cls));
    
    //成员变量
    Ivar *ivars = class_copyIvarList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"成员变量 instance variable's name:%s at index:%d", ivar_getName(ivar), i);
    }
    free(ivars);
    
    Ivar string = class_getInstanceVariable(cls, "_string");
    if (string != NULL) {
        NSLog(@"instance variable %s", ivar_getName(string));
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
