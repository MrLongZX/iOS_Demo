//
//  XJClusterAnnotationView.m
//  taohuadao
//
//  Created by taohuadao on 2016/12/7.
//  Copyright © 2016年 诗颖. All rights reserved.
//

#import "YLClusterAnnotationView.h"
#import "YLCluster.h"
#define ScreenSize [UIScreen mainScreen].bounds.size

@interface YLClusterAnnotationView()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *pharmacyLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation YLClusterAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 60, 60)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:87/255.0 blue:138/255.0 alpha:0.9];
        _titleLabel.userInteractionEnabled = YES;
        [self addSubview:_titleLabel];
        
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick)];
        [_titleLabel addGestureRecognizer:labelTapGestureRecognizer];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.alpha = 0.9;
        [self addSubview:_imageView];
        
        _pharmacyLabel = [[UILabel alloc] init];
        _pharmacyLabel.textColor = [UIColor whiteColor];
        _pharmacyLabel.font = [UIFont systemFontOfSize:14];
        _pharmacyLabel.textAlignment = NSTextAlignmentCenter;
        _pharmacyLabel.numberOfLines = 0;
        [_imageView addSubview:_pharmacyLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize imageSize = [self contentSize];
    _imageView.frame = CGRectMake(0, 0, imageSize.width + 15,imageSize.height + 15 );
    _pharmacyLabel.frame = CGRectMake(5, 5, imageSize.width ,imageSize.height);
}

- (CGSize)contentSize {
    CGSize maxSize = CGSizeMake(ScreenSize.width *0.5, MAXFLOAT);
    // 计算文字的高度
    return  [_title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
}

- (void)labelClick {
    if ([self.delegate respondsToSelector:@selector(didAddreesWithClusterAnnotationView:clusterAnnotationView:)]) {
        [self.delegate didAddreesWithClusterAnnotationView:_cluster clusterAnnotationView:self];
    }
}

- (void)setSize:(NSInteger)size {
    _size = size;
    if (size > 3) {
        _imageView.hidden = YES;
        _pharmacyLabel.hidden = YES;
        _titleLabel.hidden = NO;
        _titleLabel.layer.cornerRadius = 30.0f;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.text = [NSString stringWithFormat:@"小吃:\n%ld家", size];
    } else {
        _titleLabel.hidden = YES;
        _pharmacyLabel.hidden = NO;
        _pharmacyLabel.text = _title;
        _imageView.hidden = NO;
        //设置图片的拉伸
        UIImage *image = [UIImage imageNamed:@"mapPopViewBGICon"];
        //UIEdgeInsets edge = UIEdgeInsetsMake(15, 20, 38, 20);
        //image = [image resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
        image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.9 topCapHeight:image.size.height * 0.5];
        _imageView.image = image;
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setCluster:(YLCluster *)cluster {
    _cluster = cluster;
}

@end
