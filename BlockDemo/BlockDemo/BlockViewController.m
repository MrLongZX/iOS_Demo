//
//  BlockViewController.m
//  BlockDemo
//
//  Created by 苏友龙 on 2017/12/31.
//  Copyright © 2017年 YL. All rights reserved.
//

#import "BlockViewController.h"
#import "Student.h"

/*
 Block：带有自动变量（局部变量）的匿名函数。
 
 block用clang转换的源码
 几个重要的结构体和函数简介:
 __block_impl：这是一个结构体，也是C面向对象的体现，可以理解为block的基类;
 __main_block_impl_0: 可以理解为block变量;
 __main_block_func_0: 可以理解为匿名函数；
 __main_block_desc_0:block的描述, Block_size;
 
 参考链接：
 http://zhoulingyu.com/2015/11/20/iOS%E5%AD%A6%E4%B9%A0%E2%80%94%E2%80%94block%E6%B7%B1%E5%85%A5%E6%B5%85%E5%87%BA/
 
 block访问普通外部变量时，会将变量的值以const方式copy一份到block的所在内存空间
 所以block内部访问的并不是真正的外部变量
 const是指以常量方式，所以编译器不允许修改copy的变量
 
 对于声明为__block类型的变量在block中访问时，仍然会copy一份到block的所在内存空间，但不是以const方式
 所以你可以对变量进行写操作
 在block中访问__block类型的变量后，该变量的地址将会更改为block中的copy的地址
 
 http://zhoulingyu.com/2017/02/08/iOS%E8%BF%9B%E9%98%B6%E2%80%94%E2%80%94iOS-Memory-Block/
 Block 中，Block 表达式截获所使用的自动变量的值，即保存该自动变量的瞬间值。
 修饰为 __block 的变量，在捕获时，获取的不再是瞬间值。
 
 
 Block 内部只是对局部变量只读，但是 Block 能读写以下几种变量：
 静态变量
 静态全局变量
 全局变量
 如果想在 Block 内部写局部变量，需要对访问的局部变量增加 __block 修饰。
 __block 修饰符其实类似于 C 语言中 static、auto、register 修饰符。用于指定将变量值设置到哪个存储域中。
 
 https://halfrost.com/ios_block/
 自动变量(即局部变量)是以值传递方式传递到Block的构造函数里面去的。Block只捕获Block中会用到的变量。由于只捕获了
 自动变量的值，并非内存地址，所以Block内部不能改变自动变量的值。Block捕获的外表变量可以改变值的是静态变量，静
 态全局变量，全局变量
 */

@interface BlockViewController ()
{
    NSInteger a;
    NSMutableArray *array;
}
@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self interceptAutomaticvariables];
    
    [self defaultFormat];
    
    [self hasReturnValue];
    
    [self notHasParameter];
    
    [self notHasParameterAndBracket];
    
    [self userTypedef];
    
    [self asParameterNoHasValue:^{
        NSLog(@"作为参数 不传值,2");
    }];
    
    [self asParameterHasValue:^(NSString *string) {
        NSLog(@"作为参数 传值,2");
        NSLog(@"%@",string);
    }];
    
    a = 1;
    array = [NSMutableArray arrayWithObject:@"2"];
    [self readExternalVariable];
    
    [self writeExternalVariable];
    
    [self blcokQuestionOne];
    
    [self blcokQuestionTwo];
    
    [self blcokQuestionThree];
    
    [self blockBasicValueAndObject];
}

#pragma mark - 截获自定变量
- (void)interceptAutomaticvariables
{
    __block int intVal = 10;
    __block const char *fmt = "val = %d\n";
    
    __block NSInteger integerVal = 10;
    __block NSString *fmtString = @"integer";
    
    void (^blk) (void) = ^{

        intVal = 8;
        integerVal = 8;
        
        fmt = "block changed. intVal = %d\n";
        fmtString = @"block changed";
        
        printf(fmt,intVal);
        NSLog(@"integerVal = %ld, fmtString = %@",integerVal,fmtString);
    };
    
    intVal = 2;
    fmt = "these values were changed. intVal = %d\n";
    
    integerVal = 2;
    fmtString = @"these values were changed";
    
    blk();
    
    printf(fmt,intVal);
    NSLog(@"integer = %ld",integerVal);//8
    NSLog(@"fmtString = %@",fmtString);
    
}

// 默认格式
- (void)defaultFormat {
    NSInteger (^sum)(NSInteger a,NSInteger b) = ^NSInteger(NSInteger a,NSInteger b) {
        return a+b;
    };
    NSInteger sumCount = sum(3,4);
    NSLog(@"sumCount1:%ld",sumCount);
}

// 返回值 省略返回值类型
- (void)hasReturnValue {
    NSInteger (^sum)(NSInteger a,NSInteger b) = ^(NSInteger a,NSInteger b) {
        return a+b;
    };
    NSInteger sumCount = sum(3,4);
    NSLog(@"sumCount2:%ld",sumCount);
}

// 没有参数
- (void)notHasParameter {
    void (^logger)(void) = ^() {
        NSLog(@"无参数");
    };
    
    logger();
}

// 没有参数 和 括号
- (void)notHasParameterAndBracket {
    void (^logger)(void) = ^ {
        NSLog(@"无参数，去掉括号");
        
    };
    logger();
}

// 使用typedef定义
- (void)userTypedef {
    self.sum = ^NSInteger(NSInteger a, NSInteger b) {
        return a+b;
    };
    NSInteger sumCount = self.sum(3,4);
    NSLog(@"sumCount3:%ld",sumCount);
}

// 作为参数 不传值
- (void)asParameterNoHasValue:(void(^)(void))block {
    NSLog(@"作为参数 不传值,1");
    block();
}

// 作为参数 传值
- (void)asParameterHasValue:(void(^)(NSString *))block {
    NSLog(@"作为参数 传值,1");
    block(@"block");
}

// 外部变量
- (void)readExternalVariable {
    NSLog(@"========================= 内存与读访问 =========================");
    // 局部变量
    int externalVariable = 0;
    NSLog(@"外部访问：externalVariable = %d", externalVariable);
    NSLog(@"外部访问：externalVariable的地址是：%p", &externalVariable);
    // 全局变量
    NSLog(@"外部访问：a = %ld", a);
    NSLog(@"外部访问：a的地址是：%p", &a);
    NSLog(@"外部访问：array = %@", array);
    NSLog(@"外部访问：array的地址是：%p", &array);
    NSLog(@"\n");
    
    void (^myBlock)(void) = ^{
        NSLog(@"内部访问：externalVariable = %d", externalVariable);
        NSLog(@"内部访问：externalVariable的地址是：%p", &externalVariable);
        NSLog(@"内部访问：当block访问局部变量时，会将变量的值以const方式copy一份到block的所在内存空间");
        NSLog(@"内部访问：所以在block中对局部变量操作对局部变量不会产生影响，编译器也不允许在block内对局部变量修改");
        NSLog(@"\n");
        NSLog(@"内部访问：a = %ld", a);
        NSLog(@"内部访问：a的地址是：%p", &a);
        NSLog(@"内部访问：array = %@", array);
        NSLog(@"内部访问：array的地址是：%p", &array);
        NSLog(@"\n");
    };
    myBlock();
    
    NSLog(@"回到外部访问：externalVariable的地址是：%p", &externalVariable);
}

- (void)writeExternalVariable {
    NSLog(@"========================= 写访问 ==========================");
    // 外部变量
    __block int externalVariable2 = 0;
    // __block NSInteger externalVariable2 = 0;
    NSLog(@"外部访问：externalVariable2 = %d", externalVariable2);
    NSLog(@"外部访问：externalVariable2的地址是：%p", &externalVariable2);
    NSLog(@"\n");
    
    void (^myBlock2)(void) = ^{
        externalVariable2 = 100;
        NSLog(@"内部访问：externalVariable2 = %d", externalVariable2);
        NSLog(@"内部访问：externalVariable2的地址是：%p", &externalVariable2);
        NSLog(@"内部访问：仍然会copy一份到block的所在内存空间，但不是以const方式");
        NSLog(@"\n");
    };
    myBlock2();
    
    NSLog(@"回到外部访问：externalVariable2 = %d", externalVariable2);
    NSLog(@"回到外部访问：externalVariable2的地址是：%p", &externalVariable2);
}

// 全局变量？？？
- (void)blcokQuestionOne {
    int val = 0;
    void (^blk)(void) = ^{
        printf("in block val = %d\n",val);
    };
    val = 1;
    blk();
}

- (void)blcokQuestionTwo {
    __block int val = 0;
    void (^blk)(void) = ^{
        printf("in block val = %d\n",val);
    };
    val = 1;
    blk();
}

- (void)blcokQuestionThree {
    __block int val = 0;
    void (^blk)(void) = ^{
        printf("in block val = %d\n",val);
        val = 2;
    };
    val = 1;
    blk();
    printf("after block val = %d\n",val);
}

- (void)blockBasicValueAndObject {
    __block int val = 0;
    __block NSInteger i = 0;
    NSMutableString *str = [NSMutableString stringWithFormat:@"hello"];
    void(^blk)(void) = ^{
        //局部变量
        val++;
        i++;
        [str appendString:@" tom"];
        
        //全局变量
        a ++;
        [array addObject:@"33"];
        NSLog(@"blk中：val:%d i:%ld str:%@ a:%ld array:%@",val,i,str,a,array);
    };
    
    val = 2;
    i = 2;
    [str appendString:@" world"];
    NSLog(@"blk外：val:%d i:%ld str:%@ a:%ld array:%@",val,i,str,a,array);
    blk();
}

- (void)testStudentBlockWithBlock {
    Student *student = [[Student alloc] init];
    student.name = @"tom";
    
    __block Student *stu = student;
    student.study = ^{
        NSLog(@"name：%@",stu.name);
        stu = nil;
    };
    
    student.study();
}

- (void)testStudentBlockWithWeak {
    Student *student = [[Student alloc] init];
    student.name = @"tom";
    
    __weak typeof(student)weakStudent = student;
    student.study = ^{
        NSLog(@"name：%@",weakStudent.name);
    };
    
    student.study();
}

- (void)dealloc {
    NSLog(@"BlockViewController dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
