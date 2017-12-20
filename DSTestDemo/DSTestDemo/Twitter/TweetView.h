//
//  TweetView.h
//  DSTestDemo
//
//  Created by dasheng on 16/5/7.
//  Copyright © 2016年 dasheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface TweetView : UIView

/**  */
@property (nonatomic, strong) NSString *label;

- (void)addTweet:(Tweet *)aTweet;

@end
