//
//  MRCTableViewModel.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 14/12/27.
//  Copyright (c) 2014年 leichunfeng. All rights reserved.
//

#import "MRCTableViewModel.h"

@interface MRCTableViewModel ()

@property (nonatomic, strong, readwrite) RACCommand *requestRemoteDataCommand;

@end

@implementation MRCTableViewModel

- (void)initialize {
    [super initialize];
    // 设置请求页数
    self.page = 1;
    // 设置每页多少条数据
    self.perPage = 100;
    
    @weakify(self)
    // 创建请求远程数据命令
    self.requestRemoteDataCommand = [[RACCommand alloc] initWithSignalBlock:^(NSNumber *page) {
        @strongify(self)
        // 返回空信号
        return [[self requestRemoteDataSignalWithPage:page.unsignedIntegerValue] takeUntil:self.rac_willDeallocSignal];
    }];
    
    // 过滤远程请求命令错误
    [[self.requestRemoteDataCommand.errors
        filter:[self requestRemoteDataErrorsFilter]]
        subscribe:self.errors];
}

// 过滤获取请求远程数据的错误
- (BOOL (^)(NSError *error))requestRemoteDataErrorsFilter {
    return ^(NSError *error) {
        return YES;
    };
}

// 获取本地数据
- (id)fetchLocalData {
    return nil;
}

// 第几页一共多少条数据
- (NSUInteger)offsetForPage:(NSUInteger)page {
    return (page - 1) * self.perPage;
}

// 远程请求第几页数据
- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page {
    return [RACSignal empty];
}

@end
