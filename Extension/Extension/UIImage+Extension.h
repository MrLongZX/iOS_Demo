//
//  UIImage+Extension.h
//  BHBFreeBorder
//
//  Created by 苏友龙 on 2017/11/25.
//  Copyright © 2017年 bihongbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

///图片设置圆角
- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size;

///根据颜色 大小 生成image
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
@end
