//
//  ViewController.m
//  Extension
//
//  Created by 苏友龙 on 2017/11/25.
//  Copyright © 2017年 Pulian. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extension.h"
#import "UIImage+Extension.h"

@interface ViewController ()

/** image */
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"images"];
        _imageView.image = [image imageAddCornerWithRadius:8 andSize:CGSizeMake(60, 60)];
    }
    return _imageView;
}

- (void)initViews {
    //多个边框
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(50.0f, 50.0f, 100.0f, 50.0f)];
    [self.view addSubview:view];
    [view addBorderWithColor:[UIColor redColor] size:1.5f borderTypes:@[@(BorderTypeBottom),@(BorderTypeTop),@(BorderTypeLeft)]];
    
    //单个边框
    UIView *viewT = [[UIView alloc] initWithFrame:CGRectMake(50.0f, 150.0f, 100.0f, 50.0f)];
    [self.view addSubview:viewT];
    [viewT addBorderLayerWithColor:[UIColor greenColor] size:1.5f borderType:BorderTypeRight];
 
    //image圆角
    self.imageView.frame = CGRectMake(50.0f, 250.0f, 60.0f, 60.0f);
    [self.view addSubview:self.imageView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
