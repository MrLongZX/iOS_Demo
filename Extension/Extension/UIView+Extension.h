//
//  UIView+Extension.h
//  BHBFreeBorder
//
//  Created by 苏友龙 on 2017/11/25.
//  Copyright © 2017年 bihongbo. All rights reserved.
//

#import <UIKit/UIKit.h>

///view边框类型
typedef enum : NSUInteger {
    BorderTypeTop,
    BorderTypeLeft,
    BorderTypeRight,
    BorderTypeBottom
} BorderType;

@interface UIView (Extension)

///view设置多个边框
- (void)addBorderWithColor:(UIColor *)color size:(CGFloat)size borderTypes:(NSArray *)types;

///view设置单个边框
- (void)addBorderLayerWithColor:(UIColor *)color size:(CGFloat)size borderType:(BorderType)boderType;

@end
