//
//  YLScanManager.h
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class YLScanManager;

@protocol YLScanManagerDelegate <NSObject>

@required

/** 二维码扫描获取数据的回调方法 (metadataObjects: 扫描二维码数据信息) */
- (void)scanManager:(YLScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects;
/** 是否开启闪光灯 */
- (void)isOpenFloodlight:(BOOL)isOpen;

@end

@interface YLScanManager : NSObject

/** 快速创建单利方法 */
+ (instancetype)sharedManager;
/** SGQRCodeScanManagerDelegate */
@property (nonatomic, weak) id<YLScanManagerDelegate > delegate;

/**
 *  创建扫描二维码会话对象以及会话采集数据类型和扫码支持的编码格式的设置
 *
 *  @param sessionPreset    会话采集数据类型
 *  @param metadataObjectTypes    扫码支持的编码格式
 *  @param currentController      YLScanManager 所在控制器
 */
- (void)setupSessionPreset:(NSString *)sessionPreset metadataObjectTypes:(NSArray *)metadataObjectTypes currentController:(UIViewController *)currentController;

/** 开启会话对象扫描 */
- (void)startRunning;
/** 停止会话对象扫描 */
- (void)stopRunning;
/** 移除 videoPreviewLayer 对象 */
- (void)videoPreviewLayerRemoveFromSuperlayer;
/** 播放音效文件 */
- (void)palySoundName:(NSString *)name;

@end
