//
//  YLScaningView.h
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLScaningView : UIView

@property (nonatomic, strong)UIButton *light_button;

/**
 *  对象方法创建
 *
 *  @param frame     frame
 *  @param layer     父视图 layer
 */
- (instancetype)initWithFrame:(CGRect)frame layer:(CALayer *)layer;

/**
 *  类方法创建
 *
 *  @param frame     frame
 *  @param layer     父视图 layer
 */
+ (instancetype)scanningViewWithFrame:(CGRect )frame layer:(CALayer *)layer;

/** 添加定时器 */
- (void)addTimer;

/** 移除定时器(切记：一定要在Controller视图消失的时候，停止定时器) */
- (void)removeTimer;

- (void)lightBtnIsOpen:(BOOL)isOpen;

- (void)removeLayerFromSuperView;

@end
