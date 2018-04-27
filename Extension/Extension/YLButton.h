//
//  YLButtonBothEnd.h
//  HSYG-SH
//
//  Created by 苏友龙 on 2017/12/20.
//  Copyright © 2017年 HSYG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,YLButtonType) {
    YLButtonTypeLeft   = 0,// 标题在左 图片在右
    YLButtonTypeRight  = 1,// 标题在右 图片在左
    YLButtonTypeBottom = 2,// 标题在下 图片在上
};

@interface YLButton : UIButton

/// 图片大小
@property (nonatomic, assign) CGSize imageSize;
/// 图片、标题 距离左右 或 上下边界的距离
@property (nonatomic, assign) CGFloat offset;
/// button类型
@property (nonatomic, assign) YLButtonType ylButtonType;

@end
