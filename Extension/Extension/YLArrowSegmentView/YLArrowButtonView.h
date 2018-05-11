//
//  YLButtonArrowsView.h
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^YLArrowButtonBlock)(NSInteger tag);

@interface YLArrowButtonView : UIView

/** 标题 */
@property (nonatomic, strong) UILabel *titleLabel;
/** 是否被选中 */
@property (nonatomic, assign) BOOL isSelected;
/** 是否显示向上、向下图片 */
@property (nonatomic, assign) BOOL isShow;
/** 向上箭头图片 */
@property (nonatomic, strong) UIImageView *upImage;
/** 向下箭头图片 */
@property (nonatomic, strong) UIImageView *downImage;
/** block 点击view */
@property (nonatomic, copy) YLArrowButtonBlock touchBlock;

@end
