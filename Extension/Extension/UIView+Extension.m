//
//  UIView+Extension.m
//  BHBFreeBorder
//
//  Created by 苏友龙 on 2017/11/25.
//  Copyright © 2017年 bihongbo. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

//view设置多个边框
- (void)addBorderWithColor:(UIColor *)color size:(CGFloat)size borderTypes:(NSArray *)types{
    for (int i = 0 ; i < types.count; i ++) {
        [self addBorderLayerWithColor:color size:size borderType:[types[i] integerValue]];
    }
}

//view设置单个边框
- (void)addBorderLayerWithColor:(UIColor *)color size:(CGFloat)size borderType:(BorderType)boderType{
    CALayer * layer = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    switch (boderType) {
        case BorderTypeTop:
            layer.frame = CGRectMake(0, 0, self.frame.size.width, size);
            break;
        case BorderTypeLeft:
            layer.frame = CGRectMake(0, 0, size, self.frame.size.height);
            break;
        case BorderTypeBottom:
            layer.frame = CGRectMake(0, self.frame.size.height - size, self.frame.size.width, size);
            break;
        case BorderTypeRight:
            layer.frame = CGRectMake(self.frame.size.width - size, 0, size, self.frame.size.height);
            break;
        default:
            break;
    }
    [self.layer addSublayer:layer];
}


@end
