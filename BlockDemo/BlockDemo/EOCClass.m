//
//  EOCClass.m
//  BlockDemo
//
//  Created by 苏友龙 on 2018/1/10.
//  Copyright © 2018年 YL. All rights reserved.
//

#import "EOCClass.h"
#import "EOCNetworkFetcher.h"

@interface EOCClass() {
    EOCNetworkFetcher *_networkFetcher;
    NSData *_fetchedData;
}

@property (nonatomic, strong) NSData *weakFetchedData;

@end

@implementation EOCClass

- (void)viewDidLoad {
    self.title = @"EOC";
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self downloadData];
    
//    [self blockDownloadData];
    
    [self weakDownloadData];
}

//_networkFetcher返回数据后设为nil，解决循环引用
- (void)downloadData {
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    _networkFetcher = [[EOCNetworkFetcher alloc] initWithURL:url];
    [_networkFetcher startWithCompletionHandler:^(NSData *data) {
        _fetchedData = data;
        _networkFetcher = nil;
    }];
}

//block返回数据后设为nil，解决循环引用
- (void)blockDownloadData {
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    _networkFetcher = [[EOCNetworkFetcher alloc] initWithURL:url];
    
    [_networkFetcher blockStartWithCompletionHandler:^(NSData *data) {
        _fetchedData = data;
        NSLog(@"11");
    }];
    //等上面代码执行完成后，可以再次获取数据，条件是上面代码必须执行完毕
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_networkFetcher blockStartWithCompletionHandler:^(NSData *data) {
            _fetchedData = data;
            NSLog(@"22");
        }];
    });
}

//用weak 解决循环引用
- (void)weakDownloadData {
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    _networkFetcher = [[EOCNetworkFetcher alloc] initWithURL:url];
    
    __weak typeof(self)weakSelf = self;
    [_networkFetcher startWithCompletionHandler:^(NSData *data) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.weakFetchedData = data;
        }
    }];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
