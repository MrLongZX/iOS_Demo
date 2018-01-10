//
//  EOCNetworkFetcher.m
//  BlockDemo
//
//  Created by 苏友龙 on 2018/1/10.
//  Copyright © 2018年 YL. All rights reserved.
//

#import "EOCNetworkFetcher.h"

@interface EOCNetworkFetcher()

@property (nonatomic, strong, readwrite) NSURL *url;

@property (nonatomic, copy) EOCNetworkFetcherCompletionHandler completionHandler;

@property (nonatomic, strong) NSData *downloadData;

@end

@implementation EOCNetworkFetcher

- (id)initWithURL:(NSURL *)url {
    if(self = [super init]) {
        _url = url;
    }
    return self;
}

- (void)startWithCompletionHandler:(EOCNetworkFetcherCompletionHandler)completion {
    self.completionHandler = completion;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _downloadData = [[NSData alloc] initWithContentsOfURL:_url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self p_requestCompleted];
        });
    });
}

- (void)p_requestCompleted {
    if (_completionHandler) {
        _completionHandler(_downloadData);
    }
}

//=============== block = nil 解决循环引用===========
- (void)blockStartWithCompletionHandler:(EOCNetworkFetcherCompletionHandler)completion {
    self.completionHandler = completion;
    NSLog(@"33");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _downloadData = [[NSData alloc] initWithContentsOfURL:_url];
       
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self blockP_requestCompleted];
        });
    });
}

- (void)blockP_requestCompleted {
    if (_completionHandler) {
        NSLog(@"44");
        _completionHandler(_downloadData);
    }
    NSLog(@"55");
    self.completionHandler = nil;
}

@end
