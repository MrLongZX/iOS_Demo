//
//  MRCViewController.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 14/12/27.
//  Copyright (c) 2014年 leichunfeng. All rights reserved.
//

#import "MRCViewController.h"
#import "MRCViewModel.h"
#import "MRCLoginViewModel.h"
#import "MRCDoubleTitleView.h"
#import "MRCLoadingTitleView.h"

@interface MRCViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) MRCViewModel *viewModel;
@property (nonatomic, strong, readwrite) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@end

@implementation MRCViewController

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    MRCViewController *viewController = [super allocWithZone:zone];

    @weakify(viewController)
    [[viewController
        rac_signalForSelector:@selector(viewDidLoad)]
        subscribeNext:^(id x) {
            @strongify(viewController)
            [viewController bindViewModel];
        }];

    return viewController;
}

- (MRCViewController *)initWithViewModel:(id)viewModel {
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    // 添加返回手势
    if (self.navigationController != nil && self != self.navigationController.viewControllers.firstObject) {
        UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
        [self.view addGestureRecognizer:popRecognizer];
        popRecognizer.delegate = self;
    }
}

// 设置titleView 订阅错误信号
- (void)bindViewModel {
	// System title view 系统标题view
    RAC(self, title) = RACObserve(self.viewModel, title);

    UIView *titleView = self.navigationItem.titleView;

	// Double title view 双标题view
    MRCDoubleTitleView *doubleTitleView = [[MRCDoubleTitleView alloc] init];

    RAC(doubleTitleView.titleLabel, text)    = RACObserve(self.viewModel, title);
    RAC(doubleTitleView.subtitleLabel, text) = RACObserve(self.viewModel, subtitle);

    @weakify(self)
    // 通知容器其视图大小即将更改时调用
    [[self
    	rac_signalForSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]
    	subscribeNext:^(id x) {
        	@strongify(self)
            doubleTitleView.titleLabel.text    = self.viewModel.title;
            doubleTitleView.subtitleLabel.text = self.viewModel.subtitle;
    	}];

	// Loading title view 加载中view
    MRCLoadingTitleView *loadingTitleView = [[NSBundle mainBundle] loadNibNamed:@"MRCLoadingTitleView" owner:nil options:nil].firstObject;
    loadingTitleView.frame = CGRectMake((SCREEN_WIDTH - CGRectGetWidth(loadingTitleView.frame)) / 2.0, 0, CGRectGetWidth(loadingTitleView.frame), CGRectGetHeight(loadingTitleView.frame));

    // 根据titleViewType设置titleView
    RAC(self.navigationItem, titleView) = [RACObserve(self.viewModel, titleViewType).distinctUntilChanged map:^(NSNumber *value) {
        MRCTitleViewType titleViewType = value.unsignedIntegerValue;
        switch (titleViewType) {
            case MRCTitleViewTypeDefault:
                return titleView;
            case MRCTitleViewTypeDoubleTitle:
                return (UIView *)doubleTitleView;
            case MRCTitleViewTypeLoadingTitle:
                return (UIView *)loadingTitleView;
        }
    }];

    // 订阅界面的错误信号
    [self.viewModel.errors subscribeNext:^(NSError *error) {
        @strongify(self)

        MRCLogError(error);

        if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorAuthenticationFailed) {
            // 您的授权已过期，请再次登录
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:MRC_ALERT_TITLE
                                                                                     message:@"Your authorization has expired, please login again"
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                @strongify(self)
                [SSKeychain deleteAccessToken];

                MRCLoginViewModel *loginViewModel = [[MRCLoginViewModel alloc] initWithServices:self.viewModel.services params:nil];
                [self.viewModel.services resetRootViewModel:loginViewModel];
            }]];

            [self presentViewController:alertController animated:YES completion:NULL];
        } else if (error.code != OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired && error.code != OCTClientErrorConnectionFailed) {
            // 展示系统级别错误通知
            MRCError(error.localizedDescription);
        }
    }];
}

// 界面将要消失 发送界面将要消失信号、拍摄快照
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.viewModel.willDisappearSignal sendNext:nil];
    
    // Being popped, take a snapshot 返回时 拍摄快照
    if ([self isMovingFromParentViewController]) {
        self.snapshot = [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
    }
}

// 屏幕是否可以旋转
- (BOOL)shouldAutorotate {
    return YES;
}

// 屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [UIDevice currentDevice].isPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIPanGestureRecognizer handlers
// 实现全屏侧滑
- (void)handlePopRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:self.view].x / CGRectGetWidth(self.view.frame);
    progress = MIN(1.0, MAX(0.0, progress));

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Create a interactive transition and pop the view controller
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Update the interactive transition's progress
        [self.interactivePopTransition updateInteractiveTransition:progress];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        // Finish or cancel the interactive transition
        if (progress > 0.2) {
            [self.interactivePopTransition finishInteractiveTransition];
        } else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }

        self.interactivePopTransition = nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer {
    return [recognizer velocityInView:self.view].x > 0;
}

@end
