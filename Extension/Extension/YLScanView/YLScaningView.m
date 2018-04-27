//
//  YLScaningView.h
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import "YLScaningView.h"
#import <AVFoundation/AVFoundation.h>

/** 扫描内容的Y值 */
#define scanContent_Y self.frame.size.height * 0.24
/** 扫描内容的Y值 */
#define scanContent_X self.frame.size.width * 0.15

@interface YLScaningView ()
{
    CALayer     *scanContent_layer;     // 扫描内容的创建
    UIImageView *left_imageView;        // 左上侧的image
    UIImageView *right_imageView;       // 右上侧的image
    UIImageView *left_imageView_down;   // 左下侧的image
    UIImageView *right_imageView_down;  // 右下侧的image
}

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) CALayer         *tempLayer;
@property (nonatomic, strong) UIImageView     *scanningline;
@property (nonatomic, strong) NSTimer         *timer;
@property (nonatomic, assign) BOOL            LightStatus;

@end

@implementation YLScaningView

/** 二维码冲击波动画时间 */
static CGFloat const scanningLineAnimation = 0.05;
/** 扫描动画线(冲击波) 的高度 */
static CGFloat const scanninglineHeight = 12;
/** 扫描内容外部View的alpha值 */
static CGFloat const scanBorderOutsideViewAlpha = 0.4;

+ (instancetype)scanningViewWithFrame:(CGRect )frame layer:(CALayer *)layer {
    return [[self alloc] initWithFrame:frame layer:layer];
}

- (instancetype)initWithFrame:(CGRect)frame layer:(CALayer *)layer {
    if (self = [super initWithFrame:frame]) {
        self.tempLayer = layer;
        [self setupSubviews];
    }
    return self;
}

#pragma mark - 布局扫描界面
- (void)setupSubviews {
    // 扫描内容的创建
    scanContent_layer = [[CALayer alloc] init];
    CGFloat scanContent_layerX = scanContent_X;
    CGFloat scanContent_layerY = scanContent_Y;
    CGFloat scanContent_layerW = self.frame.size.width - 2 * scanContent_X;
    CGFloat scanContent_layerH = scanContent_layerW;
    scanContent_layer.frame = CGRectMake(scanContent_layerX, scanContent_layerY, scanContent_layerW, scanContent_layerH);
    scanContent_layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    scanContent_layer.borderWidth = 0.7;
    scanContent_layer.backgroundColor = [UIColor clearColor].CGColor;
    [self.tempLayer addSublayer:scanContent_layer];
    
#pragma mark - 扫描外部View的创建
    // 顶部layer的创建
    CALayer *top_layer = [[CALayer alloc] init];
    CGFloat top_layerX = 0;
    CGFloat top_layerY = 0;
    CGFloat top_layerW = self.frame.size.width;
    CGFloat top_layerH = scanContent_layerY;
    top_layer.frame = CGRectMake(top_layerX, top_layerY, top_layerW, top_layerH);
    top_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:top_layer];
    
    // 左侧layer的创建
    CALayer *left_layer = [[CALayer alloc] init];
    CGFloat left_layerX = 0;
    CGFloat left_layerY = scanContent_layerY;
    CGFloat left_layerW = scanContent_X;
    CGFloat left_layerH = scanContent_layerH;
    left_layer.frame = CGRectMake(left_layerX, left_layerY, left_layerW, left_layerH);
    left_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:left_layer];
    
    // 右侧layer的创建
    CALayer *right_layer = [[CALayer alloc] init];
    CGFloat right_layerX = CGRectGetMaxX(scanContent_layer.frame);
    CGFloat right_layerY = scanContent_layerY;
    CGFloat right_layerW = scanContent_X;
    CGFloat right_layerH = scanContent_layerH;
    right_layer.frame = CGRectMake(right_layerX, right_layerY, right_layerW, right_layerH);
    right_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:right_layer];
    
    // 下面layer的创建
    CALayer *bottom_layer = [[CALayer alloc] init];
    CGFloat bottom_layerX = 0;
    CGFloat bottom_layerY = CGRectGetMaxY(scanContent_layer.frame);
    CGFloat bottom_layerW = self.frame.size.width;
    CGFloat bottom_layerH = self.frame.size.height - bottom_layerY;
    bottom_layer.frame = CGRectMake(bottom_layerX, bottom_layerY, bottom_layerW, bottom_layerH);
    bottom_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:bottom_layer];
    
    // 提示Label
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    CGFloat promptLabelX = 0;
    CGFloat promptLabelY = CGRectGetMaxY(scanContent_layer.frame) + 30;
    CGFloat promptLabelW = self.frame.size.width;
    CGFloat promptLabelH = 25;
    promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    [self addSubview:promptLabel];
    
    // 添加闪光灯按钮
    self.light_button = [[UIButton alloc] init];
    CGFloat light_buttonX = 0;
    CGFloat light_buttonY = CGRectGetMaxY(promptLabel.frame) + scanContent_X * 0.5;
    CGFloat light_buttonW = self.frame.size.width;
    CGFloat light_buttonH = 25;
    self.light_button.hidden = YES;
    self.light_button.frame = CGRectMake(light_buttonX, light_buttonY, light_buttonW, light_buttonH);
    [self.light_button setTitle:@"打开照明灯" forState:UIControlStateNormal];
    [self.light_button setTitle:@"关闭照明灯" forState:UIControlStateSelected];
    [self.light_button setTitleColor:promptLabel.textColor forState:(UIControlStateNormal)];
    self.light_button.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.light_button addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.light_button];
    
#pragma mark - 扫描边角imageView的创建
    // 左上侧的image
    CGFloat margin = 7;
    
    UIImage *left_image = [UIImage imageNamed:@"QRCodeLeftTop"];
    left_imageView = [[UIImageView alloc] init];
    CGFloat left_imageViewX = CGRectGetMinX(scanContent_layer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewY = CGRectGetMinY(scanContent_layer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewW = left_image.size.width;
    CGFloat left_imageViewH = left_image.size.height;
    left_imageView.frame = CGRectMake(left_imageViewX, left_imageViewY, left_imageViewW, left_imageViewH);
    left_imageView.image = left_image;
    [self.tempLayer addSublayer:left_imageView.layer];
    
    // 右上侧的image
    UIImage *right_image = [UIImage imageNamed:@"QRCodeRightTop"];
    right_imageView = [[UIImageView alloc] init];
    CGFloat right_imageViewX = CGRectGetMaxX(scanContent_layer.frame) - right_image.size.width * 0.5 - margin;
    CGFloat right_imageViewY = left_imageView.frame.origin.y;
    CGFloat right_imageViewW = left_image.size.width;
    CGFloat right_imageViewH = left_image.size.height;
    right_imageView.frame = CGRectMake(right_imageViewX, right_imageViewY, right_imageViewW, right_imageViewH);
    right_imageView.image = right_image;
    [self.tempLayer addSublayer:right_imageView.layer];
    
    // 左下侧的image
    UIImage *left_image_down = [UIImage imageNamed:@"QRCodeLeftBottom"];
    left_imageView_down = [[UIImageView alloc] init];
    CGFloat left_imageView_downX = left_imageView.frame.origin.x;
    CGFloat left_imageView_downY = CGRectGetMaxY(scanContent_layer.frame) - left_image_down.size.width * 0.5 - margin;
    CGFloat left_imageView_downW = left_image.size.width;
    CGFloat left_imageView_downH = left_image.size.height;
    left_imageView_down.frame = CGRectMake(left_imageView_downX, left_imageView_downY, left_imageView_downW, left_imageView_downH);
    left_imageView_down.image = left_image_down;
    [self.tempLayer addSublayer:left_imageView_down.layer];
    
    // 右下侧的image
    UIImage *right_image_down = [UIImage imageNamed:@"QRCodeRightBottom"];
    right_imageView_down = [[UIImageView alloc] init];
    CGFloat right_imageView_downX = right_imageView.frame.origin.x;
    CGFloat right_imageView_downY = left_imageView_down.frame.origin.y;
    CGFloat right_imageView_downW = left_image.size.width;
    CGFloat right_imageView_downH = left_image.size.height;
    right_imageView_down.frame = CGRectMake(right_imageView_downX, right_imageView_downY, right_imageView_downW, right_imageView_downH);
    right_imageView_down.image = right_image_down;
    [self.tempLayer addSublayer:right_imageView_down.layer];
}

#pragma mark - 照明灯按钮的显示、隐藏
- (void)lightBtnIsOpen:(BOOL)isOpen {
    if (isOpen && !self.LightStatus) {
        self.light_button.hidden = NO;
    }else if(self.LightStatus){
        
        self.light_button.hidden = NO;
    }else {
        self.light_button.hidden = YES;
    }
}

#pragma mark - 照明灯按钮点击事件
- (void)light_buttonAction:(UIButton *)button {
    if (button.selected == NO) {
        // 点击打开照明灯
        [self turnOnLight:YES];
        //button.selected = YES;
        self.LightStatus = YES;
    } else {
        // 点击关闭照明灯
        [self turnOnLight:NO];
        //button.selected = NO;
        self.LightStatus = NO;
    }
    button.selected = !button.selected;
}

#pragma mark - 设备打开、关闭照明灯
- (void)turnOnLight:(BOOL)on {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (on) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode: AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}

#pragma mark - 添加定时器
- (void)addTimer {
    [self addScanningline];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:scanningLineAnimation target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

#pragma mark - 扫描动画添加
- (void)addScanningline {
    [self.tempLayer addSublayer:self.scanningline.layer];
}

#pragma mark - 移除定时器
- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self.scanningline removeFromSuperview];
    self.scanningline = nil;
}

#pragma mark - 执行定时器方法
- (void)timeAction {
    __block CGRect frame = _scanningline.frame;
    
    static BOOL flag = YES;
    
    if (flag) {
        frame.origin.y = scanContent_Y;
        flag = NO;
        [UIView animateWithDuration:scanningLineAnimation animations:^{
            frame.origin.y += 5;
            _scanningline.frame = frame;
        } completion:nil];
    } else {
        if (_scanningline.frame.origin.y >= scanContent_Y) {
            CGFloat scanContent_MaxY = scanContent_Y + self.frame.size.width - 2 * scanContent_X;
            if (_scanningline.frame.origin.y >= scanContent_MaxY - 10) {
                frame.origin.y = scanContent_Y;
                _scanningline.frame = frame;
                flag = YES;
            } else {
                [UIView animateWithDuration:scanningLineAnimation animations:^{
                    frame.origin.y += 5;
                    _scanningline.frame = frame;
                } completion:nil];
            }
        } else {
            flag = !flag;
        }
    }
}

- (void)removeLayerFromSuperView {
    [scanContent_layer removeFromSuperlayer];
    [left_imageView.layer removeFromSuperlayer];
    [right_imageView.layer removeFromSuperlayer];
    [left_imageView_down.layer removeFromSuperlayer];
    [right_imageView_down.layer removeFromSuperlayer];
}

#pragma mark - lazyLoad
- (CALayer *)tempLayer {
    if (!_tempLayer) {
        _tempLayer = [[CALayer alloc] init];
    }
    return _tempLayer;
}

- (UIImageView *)scanningline {
    if (!_scanningline) {
        _scanningline = [[UIImageView alloc] init];
        _scanningline.image = [UIImage imageNamed:@"QRCodeScanningLine"];
        _scanningline.frame = CGRectMake(scanContent_X * 0.5, scanContent_Y, self.frame.size.width - scanContent_X , scanninglineHeight);
    }
    return _scanningline;
}

@end
