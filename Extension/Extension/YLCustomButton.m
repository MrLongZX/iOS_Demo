//
//  YLCustomButton.m
//  HSYG-SH
//
//  Created by 苏友龙 on 2017/12/20.
//  Copyright © 2017年 HSYG. All rights reserved.
//

#import "YLCustomButton.h"

@implementation YLCustomButton

//重写image位置
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    
    if (_buttonImageType == YLButtonImageTypeLeft) {
        
        CGFloat y = (CGRectGetHeight(contentRect) - self.imageSize.height) / 2;
        return CGRectMake(_margin, y, self.imageSize.width, self.imageSize.height);
    } else if (_buttonImageType == YLButtonImageTypeRight) {
        
        CGFloat x = CGRectGetWidth(contentRect) - _margin - self.imageSize.width;
        CGFloat y = (CGRectGetHeight(contentRect) - self.imageSize.height) / 2;
        return CGRectMake(x, y, self.imageSize.width, self.imageSize.height);
    } else if (_buttonImageType == YLButtonImageTypeUp) {
        
        CGFloat x = (CGRectGetWidth(contentRect) -  self.imageSize.width) / 2;
        return CGRectMake(x, _margin, self.imageSize.width, self.imageSize.height);
    } else if (_buttonImageType == YLButtonImageTypeBottom) {
        
        CGFloat y = CGRectGetHeight(contentRect) - _margin - self.imageSize.height;
        CGFloat x = (CGRectGetWidth(contentRect) -  self.imageSize.width) / 2;
        return CGRectMake(x, y, self.imageSize.width, self.imageSize.height);
    }
    return CGRectZero;
}

//重写title位置
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    
    if (_buttonImageType == YLButtonImageTypeLeft) {
        
        CGFloat x = _margin + self.imageSize.width + _interval;
        CGFloat w = CGRectGetWidth(contentRect) - self.imageSize.width - 2*_margin - _interval;
        return CGRectMake(x, 0, w, CGRectGetHeight(contentRect));
    } else if (_buttonImageType == YLButtonImageTypeRight) {
        
        CGFloat w = CGRectGetWidth(contentRect) - self.imageSize.width - 2*_margin - _interval;
        return CGRectMake(_margin, 0, w, CGRectGetHeight(contentRect));
    } else if (_buttonImageType == YLButtonImageTypeUp) {
        
        CGFloat y =  _margin + self.imageSize.height + _interval;
        CGFloat h = CGRectGetHeight(contentRect) - self.imageSize.height - 2 * _margin - _interval;
        return CGRectMake(0, y, CGRectGetWidth(contentRect), h);
    } else if (_buttonImageType == YLButtonImageTypeBottom) {
        
        CGFloat h = CGRectGetHeight(contentRect) - self.imageSize.height - 2 * _margin - _interval;
        return CGRectMake(0, _margin, CGRectGetWidth(contentRect), h);
    }
    return CGRectZero;
}

@end
