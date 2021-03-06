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
#import "SUTRuntimeMethod.h"
#import "RuntimeCategoryClass+Category.h"
#import "MyRuntimeBlock.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self ex_registerClassPair];
    //
    //    [self myClassRuntime];
    //
    //    [self runtimeCreateClass];
    //
    //    [self runtimeCreateObject];
    //
    //    [self getClassDefine];
    
    //    [self getMethodAddress];
    
    //    [self runtimeAnalysis];
    
    //    [self runtimeReserveReceive];
    
    //    [self runtimeCategory];
    
//    [self libraryAction];
    
    [self runtimeBlock];
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
    
    //属性操作
    objc_property_t *propertier = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertier[i];
        NSLog(@"属性 property's name:%s",property_getName(property));
    }
    free(propertier);
    
    objc_property_t array = class_getProperty(cls, "array");
    if (array != NULL) {
        NSLog(@"property %s",property_getName(array));
    }
    
    //方法操作
    Method *methods = class_copyMethodList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        Method method = methods[i];
        NSLog(@"方法 method's signature:%s",method_getName(method));
    }
    free(methods);
    
    Method method1 = class_getInstanceMethod(cls, @selector(method1));
    if (method1 != NULL) {
        NSLog(@"method %s",method_getName(method1));
    }
    
    Method classMethod = class_getClassMethod(cls, @selector(classMethod1));
    if (classMethod != NULL) {
        NSLog(@"class method %s",method_getName(classMethod));
    }
    
    NSLog(@"MyClass is%@ responsd to selector: method3WithArg1:arg2:", class_respondsToSelector(cls, @selector(method3WithArg1:arg2:)) ? @"" : @" not");
    
    IMP imp = class_getMethodImplementation(cls, @selector(method1));
    imp();
    
    //协议
    Protocol *__unsafe_unretained *protocols = class_copyProtocolList(cls, &outCount);
    Protocol *protocol;
    for (int i = 0; i < outCount; i++) {
        protocol = protocols[i];
        NSLog(@"protocol name :%s",protocol_getName(protocol));
    }
    
    NSLog(@"MyClass is%@ responsed to protocol %s", class_conformsToProtocol(cls, protocol) ? @"" : @" not", protocol_getName(protocol));
}

//动态创建类
- (void)runtimeCreateClass {
    Class cls = objc_allocateClassPair(MyClass.class, "MySubClass", 0);
    class_addMethod(cls, @selector(submethod1), (IMP)imp_submethod1, "v@:");
    class_replaceMethod(cls, @selector(method1), (IMP)imp_submethod1, "v@:");
    
    objc_property_attribute_t type = {"T","@\"NSString\""};
    objc_property_attribute_t ownership = {"C",""};
    objc_property_attribute_t backingivar = { "V", "_ivar1"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    
    class_addProperty(cls, "property2", attrs, 3);
    objc_registerClassPair(cls);
    
    id instance = [[cls alloc] init];
    [instance performSelector:@selector(submethod1)];
    [instance performSelector:@selector(method1)];
    
}

void imp_submethod1(id self, SEL _cdm) {
    NSLog(@"run sub method 1");
}

//动态创建对象
- (void)runtimeCreateObject {
    id theObject = class_createInstance(NSString.class, sizeof(unsigned));
    id str1 = [theObject init];
    
    NSLog(@"%@",[str1 class]);
    
    id str2 = [[NSString alloc] initWithString:@"test"];
    NSLog(@"%@",[str2 class]);
}

//实例操作函数
- (void)objectOperation {
    //针对整个对象进行操作的函数 ARC下不能使用
    NSObject *a = [[NSObject alloc] init];
    id newB = object_copy(a, class_getInstanceSize(MyClass.class));
    object_setClass(newB, MyClass.class);
    object_dispose(a);
}

//获取类定义
- (void)getClassDefine {
    int numClasses;
    Class *classes = NULL;
    
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        classes = malloc(sizeof(Class)* numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        NSLog(@"number of classes:%d",numClasses);
        
        for (int i = 0; i<numClasses; i++) {
            Class cls = classes[i];
            NSLog(@"class name:%s",class_getName(cls));
        }
        free(classes);
    }
}

//获取方法地址，避开动态绑定，直接执行方法
- (void)getMethodAddress {
    void (*setter)(id, SEL);
    MyClass *class = [[MyClass alloc] init];
    setter = (void (*)(id,SEL))[class methodForSelector:@selector(method1)];
    for (int i = 0; i < 10; i++) {
        setter(class,@selector(method1));
    }
}

//消息转发：动态解析、
- (void)runtimeAnalysis {
    SUTRuntimeMethod *sut = [[SUTRuntimeMethod alloc] init];
    [sut performSelector:@selector(method3)];
}

//消息转发：备用接受者、完整消息转发
- (void)runtimeReserveReceive {
    SUTRuntimeMethod *sut = [[SUTRuntimeMethod alloc] init];
    [sut test];
}

//分类
- (void)runtimeCategory {
    RuntimeCategoryClass *obj = [[RuntimeCategoryClass alloc] init];
    [obj method2];
}

//库操作
- (void)libraryAction {
    NSLog(@"获取指定类所在动态库");
    NSLog(@"UIView framework:%s",class_getImageName(NSClassFromString(@"UIView")));
    
    NSLog(@"获取指定库或框架中所有类的类名");
    int outCount;
    const char ** classes = objc_copyClassNamesForImage(class_getImageName(NSClassFromString(@"UIView")), &outCount);
    for (int i = 0 ; i < outCount; i++) {
        NSLog(@"class name:%s",classes[i]);
    }
}

//块操作
- (void)runtimeBlock {
    MyRuntimeBlock *block = [[MyRuntimeBlock alloc] init];
    [block runtimeBlock];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
