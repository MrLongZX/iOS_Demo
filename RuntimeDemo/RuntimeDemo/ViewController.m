//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 苏友龙 on 2018/1/10.
//  Copyright © 2018年 YL. All rights reserved.
//

#import "ViewController.h"
#import "TestClass.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TestClass *testClass = [TestClass new];
    [testClass ex_registerClassPair];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end


















