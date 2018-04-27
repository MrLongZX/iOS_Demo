//
//  MRCTableViewModel.h
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 14/12/27.
//  Copyright (c) 2014年 leichunfeng. All rights reserved.
//

#import "MRCViewModel.h"

@interface MRCTableViewModel : MRCViewModel

/// The data source of table view. 
@property (nonatomic, copy) NSArray *dataSource;

/// The list of section titles to display in section index view. 右侧索引标题数据数组
@property (nonatomic, copy) NSArray *sectionIndexTitles;

/// 第几页
@property (nonatomic, assign) NSUInteger page;
/// 每页多少条
@property (nonatomic, assign) NSUInteger perPage;

/// 是否可以下拉刷新
@property (nonatomic, assign) BOOL shouldPullToRefresh;
/// 是否是无限滚动
@property (nonatomic, assign) BOOL shouldInfiniteScrolling;
/// searchBar输入的内容
@property (nonatomic, copy) NSString *keyword;
/// 点击某cell的命令
@property (nonatomic, strong) RACCommand *didSelectCommand;
/// 请求远程数据命令
@property (nonatomic, strong, readonly) RACCommand *requestRemoteDataCommand;

/// 获取本地数据
- (id)fetchLocalData;

/// 过滤获取请求远程数据的错误
- (BOOL (^)(NSError *error))requestRemoteDataErrorsFilter;

/// 第几页一共多少条数据
- (NSUInteger)offsetForPage:(NSUInteger)page;

/// 远程请求第几页数据
- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page;

@end
