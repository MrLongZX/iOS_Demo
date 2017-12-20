//
//  YMAnnotationView.m
//  BaiduMapDemo
//
//  Created by 杨蒙 on 16/6/19.
//  Copyright © 2016年 hrscy. All rights reserved.
//

#import "YLIconTitleAnnotaView.h"

@interface YLIconTitleAnnotaView()

///标题label
@property(nonatomic, strong)UILabel *titleLabel;

@end

@implementation YLIconTitleAnnotaView

- (instancetype)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    //设置大头针属性
    [self setBounds:CGRectMake(0.f, 0.f, 35.f, 35.f)];
    [self setBackgroundColor:[UIColor clearColor]];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 0;
    [self addSubview:_titleLabel];
}

#pragma mark --- setter
- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    _titleLabel.text = _titleStr;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(0.f,7.5f, 35.f, 15.f);
}

@end

