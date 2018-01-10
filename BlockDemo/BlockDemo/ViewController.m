//
//  ViewController.m
//  BlockDemo
//
//  Created by 苏友龙 on 2017/12/27.
//  Copyright © 2017年 YL. All rights reserved.
//

#import "ViewController.h"
#import "BlockViewController.h"
#import "EOCClass.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *name;

@property (nonatomic, strong) UIButton *EOCBtn;

@end

@implementation ViewController

- (UIButton *)name{
    if (!_name) {
        _name = [UIButton buttonWithType:UIButtonTypeCustom];
        [_name setBackgroundColor:[UIColor orangeColor]];
        [_name setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_name setTitle:@"跳转" forState:UIControlStateNormal];
        [_name addTarget:self action:@selector(didClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _name;
}

- (UIButton *)EOCBtn{
    if (!_EOCBtn) {
        _EOCBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_EOCBtn setBackgroundColor:[UIColor orangeColor]];
        [_EOCBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_EOCBtn setTitle:@"EOCClass" forState:UIControlStateNormal];
        [_EOCBtn addTarget:self action:@selector(didClickEOCAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _EOCBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"block";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.name.frame = CGRectMake(100, 100, 150, 60);
    [self.view addSubview:_name];
    
    self.EOCBtn.frame = CGRectMake(100, 200, 150, 60);
    [self.view addSubview:_EOCBtn];
}

- (void)didClickAction {
    BlockViewController *block = [[BlockViewController alloc] init];
    [self.navigationController pushViewController:block animated:YES];
}

- (void)didClickEOCAction {
    EOCClass *block = [[EOCClass alloc] init];
    [self.navigationController pushViewController:block animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
