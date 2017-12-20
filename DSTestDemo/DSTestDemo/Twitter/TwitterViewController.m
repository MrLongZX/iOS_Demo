//
//  TwitterViewController.m
//  DSTestDemo
//
//  Created by dasheng on 16/5/7.
//  Copyright © 2016年 dasheng. All rights reserved.
//

#import "TwitterViewController.h"

@interface TwitterViewController ()

@end

@implementation TwitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)updateTweetView{
    
    NSArray *tweets = [_connection fetchTweets];
    if (tweets != nil) {
        for (Tweet *t in tweets){
            [_tweetView addTweet:t];
        }
    } else {
        /* handle error cases */
    }
}

- (void)updateTweetView2{
    
    NSArray *tweets = [TwitterConnection fetchTweets2];
    if (tweets != nil) {
        for (Tweet *t in tweets){
            [_tweetView addTweet:t];
        }
    } else {
        /* handle error cases */
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
