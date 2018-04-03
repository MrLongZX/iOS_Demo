//
//  StudyTableViewCell.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/1.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "StudyTableViewCell.h"
#import "NSString+Additions.h"
#import "VVeboLabel.h"

@implementation StudyTableViewCell
{
    BOOL drawed;
    VVeboLabel  *label;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    label = [[VVeboLabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1];
    label.font = FontWithSize(SIZE_FONT_SUBCONTENT);
    [self.contentView addSubview:label];
}

- (void)setData:(NSDictionary *)data
{
    _data = data;
    [self drawText];
}

- (void)drawText
{
    if (drawed) {
        return;
    }
    drawed = YES;
    label.frame = [_data[@"textRect"] CGRectValue];
    [label setText:_data[@"text"]];
}

- (void)clear
{
    if (!drawed) {
        return;
    }
    [label clear];
    drawed = NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

/*
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 
 CGRect rect = [_data[@"frame"] CGRectValue];
 UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
 CGContextRef context = UIGraphicsGetCurrentContext();
 [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
 CGContextFillRect(context, rect);
 
 [_data[@"text"] drawInContext:context withPosition:CGPointMake(SIZE_GAP_LEFT, SIZE_GAP_BIG) andFont:FontWithSize(SIZE_FONT_SUBCONTENT)
 andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
 andHeight:rect.size.height
 andWidth:(rect.size.width-SIZE_GAP_LEFT*2)];
 
 UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 dispatch_async(dispatch_get_main_queue(), ^{
 postBGView.frame = rect;
 postBGView.image = nil;
 postBGView.image = temp;
 });
 });
 */
