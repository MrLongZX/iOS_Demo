//
//  StudyTableViewCell.h
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/1.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SIZE_GAP_LEFT 15
#define SIZE_GAP_TOP 13
#define SIZE_AVATAR 40
#define SIZE_GAP_BIG 10
#define SIZE_GAP_IMG 5
#define SIZE_GAP_SMALL 5
#define SIZE_IMAGE 80
#define SIZE_FONT 17
#define SIZE_FONT_NAME (SIZE_FONT-3)
#define SIZE_FONT_SUBTITLE (SIZE_FONT-8)
#define FontWithSize(s) [UIFont fontWithName:@"HelveticaNeue-Light" size:s]
#define SIZE_FONT_CONTENT 17
#define SIZE_FONT_SUBCONTENT (SIZE_FONT_CONTENT-1)

@interface StudyTableViewCell : UITableViewCell

@property (nonatomic, weak) NSDictionary *data;

- (void)drawText;
- (void)clear;

@end
