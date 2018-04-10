//
//  YLFixLineHeightView.h
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/7.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 固定行高
@interface YLFixLineHeightView : UIView

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIFont *font;

+ (CGFloat)textHeightWithText:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont;

@end
