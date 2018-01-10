//
//  BlockViewController.h
//  BlockDemo
//
//  Created by 苏友龙 on 2017/12/31.
//  Copyright © 2017年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSInteger(^Sum)(NSInteger a,NSInteger b);

@interface BlockViewController : UIViewController

/** Sum */
@property (nonatomic, copy) Sum sum;

@end
