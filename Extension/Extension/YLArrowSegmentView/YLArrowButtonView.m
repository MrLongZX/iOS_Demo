//
//  YLButtonArrowsView.m
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import "YLArrowButtonView.h"

@implementation YLArrowButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    [self addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)setIsShow:(BOOL)isShow
{
    _isShow = isShow;
    if (isShow) {
        [self addSubview:self.upImage];
        [self addSubview:self.downImage];
        
        CGFloat kImageWH = 8;
        CGFloat kInterval = 4;
        
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.centerX.equalTo(self.mas_centerX).offset(-(kImageWH + kInterval)/2);
        }];
        
        [_upImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel.mas_right).offset(kInterval);
            make.bottom.equalTo(_titleLabel.mas_centerY).offset(-1);
            make.size.mas_equalTo(CGSizeMake(kImageWH, kImageWH));
        }];
        
        [_downImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_upImage);
            make.top.equalTo(_titleLabel.mas_centerY).offset(1);
            make.size.mas_equalTo(CGSizeMake(kImageWH, kImageWH));
        }];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_touchBlock) {
        _touchBlock(self.tag);
    }
}

#pragma mark - lazyload
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kSystemFont(16);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = kCOLOR(0, 0, 0, 0.8);
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UIImageView *)upImage
{
    if (!_upImage) {
        _upImage = [[UIImageView alloc] init];
        _upImage.image = kImage(@"upGray");
    }
    return _upImage;
}

- (UIImageView *)downImage
{
    if (!_downImage) {
        _downImage = [[UIImageView alloc] init];
        _downImage.image = kImage(@"downGray");
    }
    return _downImage;
}

@end
