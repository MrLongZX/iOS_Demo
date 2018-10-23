//
//  YLCustomButton.h
//  HSYG-SH
//
//  Created by 苏友龙 on 2017/12/20.
//  Copyright © 2017年 HSYG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,YLButtonImageType) {
    
    YLButtonImageTypeLeft   = 0, // 图片在左 标题在右
    YLButtonImageTypeRight  = 1, // 图片在右 标题在做
    YLButtonImageTypeUp     = 2, // 图片在上 标题在下
    YLButtonImageTypeBottom = 3, // 图片在下 标题在上
};

@interface YLCustomButton : UIButton

/// 图片大小
@property (nonatomic, assign) CGSize imageSize;
/// 图片、标题 水平排列 左右边距
/// 图片、标题 垂直排列 上下边距
@property (nonatomic, assign) CGFloat margin;
/// 图片、标题间的距离
@property (nonatomic, assign) CGFloat interval;
/// button类型
@property (nonatomic, assign) YLButtonImageType buttonImageType;

@end
