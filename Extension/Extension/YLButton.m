//
//  YLButtonBothEnd.m
//  HSYG-SH
//
//  Created by 苏友龙 on 2017/12/20.
//  Copyright © 2017年 HSYG. All rights reserved.
//

#import "YLButton.h"

@implementation YLButton

//重写title位置
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    
    if (_ylButtonType == YLButtonTypeLeft) {
        
        CGFloat w = CGRectGetWidth(contentRect) - self.imageSize.width - 2*_offset;
        return CGRectMake(_offset, 0, w, CGRectGetHeight(contentRect));
    } else if (_ylButtonType == YLButtonTypeRight) {
        
        CGFloat x = _offset + self.imageSize.width + _offset/2;
        CGFloat w = CGRectGetWidth(contentRect) - self.imageSize.width - 2*_offset;
        return CGRectMake(x, 0, w, CGRectGetHeight(contentRect));
    }
    
    CGFloat y =  _offset + self.imageSize.height + _offset/2;
    CGFloat h = CGRectGetHeight(contentRect) - self.imageSize.height - _offset*2;
    return CGRectMake(0, y, CGRectGetWidth(contentRect), h);
}

//重写image位置
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    
    if (_ylButtonType == YLButtonTypeLeft) {
        
        CGFloat x = CGRectGetWidth(contentRect) - self.imageSize.width - _offset;
        CGFloat y = (CGRectGetHeight(contentRect) -  self.imageSize.height)/2;
        return CGRectMake(x, y, self.imageSize.width, self.imageSize.height);
    } else if (_ylButtonType == YLButtonTypeRight) {
        
        return CGRectMake(_offset, 0, self.imageSize.width, self.imageSize.height);
    }
    
    CGFloat x = (CGRectGetWidth(contentRect) -  self.imageSize.width)/2;
    return CGRectMake(x, _offset, self.imageSize.width, self.imageSize.height);
}

@end
