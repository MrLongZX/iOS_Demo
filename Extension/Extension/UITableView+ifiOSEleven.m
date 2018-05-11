//
//  UITableView+ifiOSEleven.m
//  HSYG-SH
//
//  Created by 苏友龙 on 2017/10/18.
//  Copyright © 2017年 HSYG. All rights reserved.
//

#import "UITableView+ifiOSEleven.h"
#import <objc/message.h>
@implementation UITableView (ifiOSEleven)

+(void)load
{
    if (@available(iOS 11.0, *)) {
        Method tableViewmethod = class_getInstanceMethod([UITableView class], @selector(setDelegate:));
        Method contentInsetAdjustmentBehavior = class_getInstanceMethod([UITableView class], @selector(tableViewiOS:));
        method_exchangeImplementations(tableViewmethod, contentInsetAdjustmentBehavior);
    }
}

-(void)tableViewiOS:(id<UITableViewDelegate>)delegate
{
    if (@available(iOS 11.0, *)) {
        [self tableViewiOS:delegate];
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        return;
    }
}
@end

