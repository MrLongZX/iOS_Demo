//
//  OilDetailsCollectionViewCell.m
//  CollectionViewDemo
//
//  Created by 苏友龙 on 2017/12/17.
//  Copyright © 2017年 YL. All rights reserved.
//

#import "OilDetailsCollectionViewCell.h"

#define myScreenWidth [UIScreen mainScreen].bounds.size.width
#define myScreenHeight [UIScreen mainScreen].bounds.size.height

@interface OilDetailsCollectionViewCell()

@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation OilDetailsCollectionViewCell

- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
        [self createSubView];
    }
    return self;
}

-(void)createSubView {
    self.detailLabel.frame = CGRectMake(0, 0, (myScreenWidth-30-10*2)/3, 55);
    [self.contentView addSubview:_detailLabel];
}

- (void)setDetailStr:(NSString *)detailStr {
    _detailStr = detailStr;
    _detailLabel.text = _detailStr;
}

@end
