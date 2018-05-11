//
//  YLSegmentView.m
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import "YLArrowSegmentView.h"
#import "YLArrowButtonView.h"

static const CGFloat kTitleHeight  = 49;
#define kTitleWidth (kScreenW - 2*kOffset)/_titlesArray.count
#define kTitlebackColor [UIColor colorWithWhite:0.300 alpha:1.000]
#define kTitleSeletedColor UIColorFromRGBValue(0xFF4545)

@interface YLArrowSegmentView ()

/** 选中的button */
@property (nonatomic, assign) YLArrowButtonView *selectedView;
/** 底线 */
@property (nonatomic, strong) UIView *sliderView;
/** 存放创建的buttonView */
@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation YLArrowSegmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowOpacity = 0.2f;
        self.layer.shadowOffset = CGSizeMake(2, 0);
        
        _buttonArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - 设置显示按钮
- (void)setTitlesArray:(NSArray *)titlesArray
{
    _titlesArray = titlesArray;
    [self initViews];
}

#pragma mark - 设置那个按钮展示向上、向下箭头图片
- (void)setShowArrowIndexArray:(NSArray *)showArrowIndexArray
{
    _showArrowIndexArray = showArrowIndexArray;
    for (NSNumber *index in showArrowIndexArray) {
        YLArrowButtonView *btnView = self.buttonArray[[index integerValue]];
        btnView.isShow = YES;
        
        if ([btnView isEqual:_selectedView]) {
            btnView.upImage.image = kImage(@"upRed");
        }
    }
}

#pragma mark - 创建buttonView和底线
- (void)initViews
{
    for (NSInteger i = 0; i < _titlesArray.count; i ++) {
        YLArrowButtonView *buttonView = [[YLArrowButtonView alloc] initWithFrame:CGRectMake(kTitleWidth*i+16, 0, kTitleWidth, kTitleHeight-3)];
        buttonView.tag = 100 + i;
        buttonView.titleLabel.text = _titlesArray[i];
        __weak typeof(self)weakSelf = self;
        buttonView.touchBlock = ^(NSInteger tag) {
            __strong typeof(self)strongSelf = weakSelf;
            [strongSelf selectArrowButtonAtIndex:tag-100];
        };
        [self addSubview:buttonView];
        if ([_showArrowIndexArray containsObject:@(i)]) {
            buttonView.isShow = YES;
        }
        if (i == 0) {
            buttonView.titleLabel.textColor = kTitleSeletedColor;
            _selectedView = buttonView;
            _selectedView.isSelected = YES;
        }
        [self.buttonArray addObject:buttonView];
    }
    
    _sliderView = [[UIView alloc]initWithFrame:CGRectMake(16, kTitleHeight-3, kTitleWidth,3)];
    _sliderView.backgroundColor = kTitleSeletedColor;
    [self addSubview:_sliderView];
}

#pragma mark - 点击buttonView
- (void)selectArrowButtonAtIndex:(NSInteger)index {
    [self changeArrowButtonViewStyle:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentViewSelectedIndex:)]) {
        [self.delegate segmentViewSelectedIndex:index];
    }
}

#pragma mark - 修改之前、现在选中button样式，移动底线
- (void)changeArrowButtonViewStyle:(NSInteger)index {
    NSInteger beforeIndex = _selectedView.tag - 100;
    
    if (beforeIndex == index && _selectedView.isShow) {
        // 点击相同的按钮
        _selectedView.isSelected = !_selectedView.isSelected;
        if (_selectedView.isSelected) {
            _selectedView.upImage.image = kImage(@"upRed");
            _selectedView.downImage.image = kImage(@"downGray");
        } else {
            _selectedView.upImage.image = kImage(@"upGray");
            _selectedView.downImage.image = kImage(@"downRed");
        }
    } else {
        // 点击不同的按钮
        // 修改之前选中
        _selectedView.isSelected = NO;
        _selectedView.titleLabel.textColor = kTitlebackColor;
        if (_selectedView.isShow) {
            _selectedView.upImage.image = kImage(@"upGray");
            _selectedView.downImage.image = kImage(@"downGray");
        }
        
        // 修改现在选中
        _selectedView = self.buttonArray[index];
        _selectedView.isSelected = YES;
        _selectedView.titleLabel.textColor = kTitleSeletedColor;

        if (_selectedView.isShow) {
            _selectedView.upImage.image = kImage(@"upRed");
            _selectedView.downImage.image = kImage(@"downGray");
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            _sliderView.frame = CGRectMake(kTitleWidth*index+16, kTitleHeight-3, kTitleWidth, 3);
        }];
    }
}

#pragma mark - 设置默认选中button
- (void)setDefaultSelectedIndex:(NSInteger)defaultSelectedIndex
{
    if (defaultSelectedIndex <= self.buttonArray.count - 1) {
        YLArrowButtonView *btnView = self.buttonArray[defaultSelectedIndex];
        [self selectArrowButtonAtIndex:btnView.tag - 100];
    }
}

@end
