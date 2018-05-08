//
//  TwoViewController.m
//  RACLearn
//
//  Created by 苏友龙 on 2017/3/17.
//  Copyright © 2017年 Pulian. All rights reserved.
//

#import "TwoViewController.h"

@interface TwoViewController ()

@property(nonatomic,strong)UIButton *button;

@end

@implementation TwoViewController

//RACSubject

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildUI];
}

- (void)buildUI {
    self.button.frame = CGRectMake(50, 100, 50, 30);
    self.view.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.button];
}

#pragma mark---lazy loading
- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setBackgroundColor:[UIColor grayColor]];
        [_button setTitle:@"pop" forState:UIControlStateNormal];
        @weakify(self);
        [[_button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.subject sendNext:@"589"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
