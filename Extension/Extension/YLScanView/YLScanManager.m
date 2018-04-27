//
//  YLScanManager.m
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import "YLScanManager.h"
#import <ImageIO/ImageIO.h>

@interface YLScanManager ()  <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation YLScanManager

static YLScanManager *_instance;

#pragma mark - 创建单例
+ (instancetype)sharedManager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

-(id)copyWithZone:(NSZone *)zone {
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

#pragma mark - 创建扫描二维码会话对象以及会话采集数据类型和扫码支持的编码格式的设置
- (void)setupSessionPreset:(NSString *)sessionPreset metadataObjectTypes:(NSArray *)metadataObjectTypes currentController:(UIViewController *)currentController {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 1、获取摄像设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

        // 2、创建设备输入流
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        // 3、创建数据输出流
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        
        // 3、创建设备输出流
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        
        // 4、设置代理：在主线程里刷新
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        
        // 设置扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
        // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
        metadataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
        
        // 5、创建会话对象
        _session = [[AVCaptureSession alloc] init];
        // 会话采集率: AVCaptureSessionPresetHigh
        _session.sessionPreset = sessionPreset;
        
        // 6、添加设备输入流到会话对象
        [_session addInput:deviceInput];
        
        // 7、添加设备输入流到会话对象
        [_session addOutput:metadataOutput];
        [_session addOutput:output];
        
        // 8、设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
        // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        // @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        metadataOutput.metadataObjectTypes = metadataObjectTypes;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 9、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
            _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
            // 保持纵横比；填充层边界
            _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _videoPreviewLayer.frame = currentController.view.layer.bounds;
            [currentController.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
            
            // 10、启动会话
            [_session startRunning];
            
        });
    });
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] doubleValue];
    
    // 根据brightnessValue的值来打开和关闭闪光灯
    BOOL result = YES;
    if ((brightnessValue < 0)) {
        // 打开闪光灯
        result = YES;
    } else if((brightnessValue > 0)) {
        // 关闭闪光灯
        result = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(isOpenFloodlight:)]) {
        [self.delegate isOpenFloodlight:result];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanManager:didOutputMetadataObjects:)]) {
        [self.delegate scanManager:self didOutputMetadataObjects:metadataObjects];
    }
}

#pragma mark - 开启会话对象扫描
- (void)startRunning {
    [_session startRunning];
}

#pragma mark - 停止会话对象扫描
- (void)stopRunning {
    [_session stopRunning];
    //_session = nil;
}

#pragma mark - 移除 videoPreviewLayer 对象
- (void)videoPreviewLayerRemoveFromSuperlayer {
    [_videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - 播放音效文件
- (void)palySoundName:(NSString *)name {
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundID);
}

void soundCompleteCallback(SystemSoundID soundID, void *clientData){
    
}

@end
