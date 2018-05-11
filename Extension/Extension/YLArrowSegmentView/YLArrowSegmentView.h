//
//  YLSegmentView.h
//  shopTest
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 moral. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLArrowSegmentViewDelegate <NSObject>

- (void)segmentViewSelectedIndex:(NSInteger)index;

@end

@interface YLArrowSegmentView : UIView

/** 标题内容 */
@property (nonatomic, copy)NSArray *titlesArray;
/** 默认选中位置 从0开始 */
@property (nonatomic , assign)NSInteger defaultSelectedIndex;
/** 显示上下箭头图片的位置 从0开始 例：@[@0,@2] */
@property (nonatomic , copy)NSArray *showArrowIndexArray;
/** 代理 */
@property (nonatomic, weak) id<YLArrowSegmentViewDelegate> delegate;

@end

