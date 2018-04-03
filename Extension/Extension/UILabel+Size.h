//
//  UILabel+Size.h
//  Extension
//
//  Created by 苏友龙 on 2018/3/16.
//  Copyright © 2018年 Pulian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Size)

/// 根据UILabel宽度,字符串,字体,计算UILabel高度
+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont*)font;

/// 根据UILabel高度,字符串,字体,计算UILabel宽度
+ (CGFloat)getWidthByHeight:(CGFloat)height title:(NSString *)title font:(UIFont *)font;

@end
