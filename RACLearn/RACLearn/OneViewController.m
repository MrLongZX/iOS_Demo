//
//  OneViewController.m
//  RACLearn
//
//  Created by 苏友龙 on 2017/3/17.
//  Copyright © 2017年 Pulian. All rights reserved.
//

#import "OneViewController.h"
#import "TwoViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface OneViewController ()

@property(nonatomic,strong)UIButton *button;

@end

@implementation OneViewController

//RACSubject 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildUI];
}

- (void)buildUI {
    self.button.frame = CGRectMake(100, 100, 80, 30);
    [self.view addSubview:self.button];
}

#pragma mark---lazy loading
- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setBackgroundColor:[UIColor redColor]];
        [_button setTitle:@"push" forState:UIControlStateNormal];
        @weakify(self);
        [[_button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            TwoViewController *two = [TwoViewController new];
            two.subject = [RACSubject subject];
            [two.subject subscribeNext:^(id x) {
                [_button setTitle:x forState:UIControlStateNormal];
            }];
            
            [self.navigationController pushViewController:two animated:YES];
        }];
    }
    return _button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
