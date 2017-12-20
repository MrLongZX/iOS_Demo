//
//  YLTextField.m
//  HSYG-SH
//
//  Created by 苏友龙 on 2017/12/20.
//  Copyright © 2017年 HSYG. All rights reserved.
//

#import "YLTextField.h"

@implementation YLTextField

// 重写文字与输入框左边距离
- (CGRect)textRectForBounds:(CGRect)bounds {
    if (self.leftView) {
        bounds.origin.x += 10+self.leftView.frame.size.width+10;
        return bounds;
    }
    bounds.origin.x += 15;
    return bounds;
}

// 重写光标与输入框左边距离
- (CGRect)editingRectForBounds:(CGRect)bounds {
    if (self.leftView) {
        bounds.origin.x += 10+self.leftView.frame.size.width+10;
        return bounds;
    }
    bounds.origin.x += 15;
    return bounds;
}

// 重写左视图与输入框左边距离
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect leftViewRect = [super leftViewRectForBounds:bounds];
    leftViewRect.origin.x += 10;
    return leftViewRect;
}

// 重写右视图与输入框右边距离
- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rightViewRect = [super rightViewRectForBounds:bounds];
    rightViewRect.origin.x -= 15;
    return rightViewRect;
}

@end
