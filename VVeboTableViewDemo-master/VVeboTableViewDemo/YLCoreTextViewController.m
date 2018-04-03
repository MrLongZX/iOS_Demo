//
//  YLCoreTextViewController.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/2.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "YLCoreTextViewController.h"
#import "YLCoreTextView.h"

@interface YLCoreTextViewController ()

@property (nonatomic, strong) YLCoreTextView *redView;

@end

@implementation YLCoreTextViewController

- (YLCoreTextView *)redView{
    if (!_redView) {
        _redView = [[YLCoreTextView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 200)];
        _redView.backgroundColor = [UIColor whiteColor];
    }
    return _redView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CoreText";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.redView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
