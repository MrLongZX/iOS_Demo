//
//  UILabel+Size.m
//  Extension
//
//  Created by 苏友龙 on 2018/3/16.
//  Copyright © 2018年 Pulian. All rights reserved.
//

#import "UILabel+Size.h"

@implementation UILabel (Size)

// 根据UILabel宽度,字符串,字体,计算UILabel高度
+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont*)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    return label.frame.size.height;
}

// 根据UILabel高度,字符串,字体,计算UILabel宽度
+ (CGFloat)getWidthByHeight:(CGFloat)height title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, height, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width;
}

@end
