//
//  YLScaningViewController.m
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import "YLScaningViewController.h"
#import "YLScaningView.h"
#import "YLScanManager.h"

@interface YLScaningViewController ()<YLScanManagerDelegate>

@property (nonatomic, strong) YLScaningView *scanView;
@property (nonatomic, strong) YLScanManager *stScanManager;
@property (nonatomic, assign) BOOL          isStopScanManager;

@end

@implementation YLScaningViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scanView removeTimer];
    [self.scanView removeLayerFromSuperView];
    [self.scanView removeFromSuperview];
    
    if (!self.isStopScanManager) {
        [self stopScanManager];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 初始化扫描边框视图
    [self setUpLayerView];
    // 检查权限 开启扫描功能
    [self checkAuthorization];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫一扫";
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

// 初始化扫描边框视图
- (void)setUpLayerView {
    self.scanView = [YLScaningView scanningViewWithFrame:self.view.bounds layer:self.view.layer];
    [self.view addSubview:self.scanView];
}

// 创建扫描功能单例 开始扫描
- (void)setUpCodeScaningView {
    self.stScanManager = [YLScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [self.stScanManager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
    self.stScanManager.delegate = self;
}

// 检查权限
- (void)checkAuthorization {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
         [self showAlertController:@"温馨提示" witMessage:@"相机访问权限被限制,请去-> [设置 - 隐私 - 相机 - 本应用)] 打开访问开关"];
        return;
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            // 创建扫描功能单例
            [self setUpCodeScaningView];
        }else {
            [self showAlertController:@"温馨提示" witMessage:@"未检测到您的相机"];
        }
    }
}

// 关闭扫描
- (void)stopScanManager {
    [self.stScanManager stopRunning];
    [self.stScanManager videoPreviewLayerRemoveFromSuperlayer];
}

#pragma mark - YLScanManagerDelegate
- (void)isOpenFloodlight:(BOOL)isOpen {
    [self.scanView lightBtnIsOpen:isOpen];
}

- (void)scanManager:(YLScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
    if (metadataObjects != nil && metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *result = [obj stringValue];
        NSLog(@"result:%@",result);
        //[scanManager palySoundName:@"sound.caf"];
        [self stopScanManager];
        self.isStopScanManager = YES;
    
    } else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}

#pragma mark - 展示UIAlertController
- (void)showAlertController:(NSString *)title witMessage:(NSString *)message {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}

@end

