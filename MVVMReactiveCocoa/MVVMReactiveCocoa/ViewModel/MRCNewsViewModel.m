//
//  MRCNewsViewModel.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 15/1/10.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//

#import "MRCNewsViewModel.h"
#import "MRCNewsItemViewModel.h"
#import "MRCUserDetailViewModel.h"
#import "MRCRepoDetailViewModel.h"
#import "MRCWebViewModel.h"

#define MRCReceivedEventsETag @"received_events_etag"
#define MRCEventsETag         @"events_etag"

@interface MRCNewsViewModel ()

@property (nonatomic, strong) OCTUser *user;

@property (nonatomic, copy, readwrite) NSArray *events;
@property (nonatomic, assign, readwrite) BOOL isCurrentUser;
@property (nonatomic, assign, readwrite) MRCNewsViewModelType type;
@property (nonatomic, strong, readwrite) RACCommand *didClickLinkCommand;

@end

@implementation MRCNewsViewModel

- (instancetype)initWithServices:(id<MRCViewModelServices>)services params:(NSDictionary *)params {
    self = [super initWithServices:services params:params];
    if (self) {
        self.type = [params[@"type"] unsignedIntegerValue];
        self.user = params[@"user"] ?: [OCTUser mrc_currentUser];
    }
    return self;
}

- (void)initialize {
    [super initialize];
    
    // 是否是当前用户
    self.isCurrentUser = [self.user.objectID isEqualToString:[OCTUser mrc_currentUserId]];

    // 判断类型
    if (self.type == MRCNewsViewModelTypeNews) {
        self.title = @"News";
    } else if (self.type == MRCNewsViewModelTypePublicActivity) {
        self.title = @"Public Activity";
    }
    
    // 可以下拉刷新
    self.shouldPullToRefresh = YES;
    
    @weakify(self)
    // 点击cell 进行界面跳转的命令
    self.didClickLinkCommand = [[RACCommand alloc] initWithSignalBlock:^(NSURL *URL) {
        @strongify(self)
        
        NSString *title = [[[[URL.absoluteString componentsSeparatedByString:@"?"].lastObject componentsSeparatedByString:@"="].lastObject stringByReplacingOccurrencesOfString:@"-" withString:@" "] stringByReplacingOccurrencesOfString:@"@" withString:@"#"];
        NSLog(@"didClickLinkCommand: %@, title: %@", URL, title);
        
        if (URL.type == MRCLinkTypeUser) {
            MRCUserDetailViewModel *viewModel = [[MRCUserDetailViewModel alloc] initWithServices:self.services params:URL.mrc_dictionary];
            [self.services pushViewModel:viewModel animated:YES];
        } else if (URL.type == MRCLinkTypeRepository) {
            MRCRepoDetailViewModel *viewModel = [[MRCRepoDetailViewModel alloc] initWithServices:self.services params:URL.mrc_dictionary];
            [self.services pushViewModel:viewModel animated:YES];
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            MRCWebViewModel *viewModel = [[MRCWebViewModel alloc] initWithServices:self.services
                                                                            params:@{ @"title": title ?: @"",
                                                                                      @"request": request ?: @"" }];
            [self.services pushViewModel:viewModel animated:YES];
        }
        
        return [RACSignal empty];
    }];
    
    // 点击了某cell 执行didSelectCommand命令
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^(NSIndexPath *indexPath) {
        @strongify(self)
        // 获取cell数据 进行界面跳转 执行界面跳转命令
        MRCNewsItemViewModel *viewModel = self.dataSource[indexPath.section][indexPath.row];
        return [self.didClickLinkCommand execute:viewModel.event.mrc_Link];
    }];
    
    // startWith: 先执行一次
    // 执行获取远程数据命令后 对数据进行映射处理
    RAC(self, events) = [[self.requestRemoteDataCommand.executionSignals.switchToLatest
        startWith:self.fetchLocalData]
        map:^(NSArray *events) {
            @strongify(self)
            if (self.dataSource == nil) {
                return events;
            } else {
                //takeUntilBlock：执行到block中的内容为YES停止
                return [events.rac_sequence takeUntilBlock:^(OCTEvent *event) {
                    @strongify(self)
                    MRCNewsItemViewModel *viewModel = [self.dataSource.firstObject firstObject];
                    return [event.objectID isEqualToString:viewModel.event.objectID];
                }].array;
            }
        }];

    // 保存获取的远程数据
    if (self.isCurrentUser) {
        [[[RACObserve(self, dataSource)
            ignore:nil]
            deliverOn:[RACScheduler scheduler]]
            subscribeNext:^(NSArray *dataSource) {
                @strongify(self)
                NSArray *events = [[dataSource.firstObject
                    rac_sequence]
                    map:^(MRCNewsItemViewModel *viewModel) {
                        return viewModel.event;
                    }].array;
                if (self.type == MRCNewsViewModelTypeNews) {
                    [OCTEvent mrc_saveUserReceivedEvents:events];
                } else if (self.type == MRCNewsViewModelTypePublicActivity) {
                    [OCTEvent mrc_saveUserPerformedEvents:events];
                }
            }];
    }
}

// 过滤获取请求远程数据的错误
- (BOOL (^)(NSError *))requestRemoteDataErrorsFilter {
    return ^(NSError *error) {
        if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorServiceRequestFailed) {
            MRCLogError(error);
            return NO;
        }
        return YES;
    };
}

// 获取本地数据
- (id)fetchLocalData {
    NSArray *events = nil;
    
    if (self.isCurrentUser) {
        if (self.type == MRCNewsViewModelTypeNews) {
            // Takes `500` items from local cache
            // 获取数组前 500 项
            events = [[OCTEvent mrc_fetchUserReceivedEvents].rac_sequence take:500].array;
        } else if (self.type == MRCNewsViewModelTypePublicActivity) {
            events = [OCTEvent mrc_fetchUserPerformedEvents];
        }
    }

    return events;
}

// 远程请求第几页数据
- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page {
    RACSignal *fetchSignal = [RACSignal empty];
    
    NSString *etag = nil;
    if (self.isCurrentUser) {
        if (self.type == MRCNewsViewModelTypeNews) {
            etag = [[NSUserDefaults standardUserDefaults] stringForKey:MRCReceivedEventsETag];
        } else if (self.type == MRCNewsViewModelTypePublicActivity) {
            etag = [[NSUserDefaults standardUserDefaults] stringForKey:MRCEventsETag];
        }
    }

    // 根据类型发送网络请求
    if (self.type == MRCNewsViewModelTypeNews) {
        fetchSignal = [[self.services client] fetchUserEventsNotMatchingEtag:etag];
    } else if (self.type == MRCNewsViewModelTypePublicActivity) {
        fetchSignal = [[self.services client] fetchPerformedEventsForUser:self.user notMatchingEtag:etag];
    }

    return [[[fetchSignal
        collect]
        doNext:^(NSArray *responses) {
            if (responses.count > 0) {
                if (self.isCurrentUser) {
                    if (self.type == MRCNewsViewModelTypeNews) {
                        [[NSUserDefaults standardUserDefaults] setValue:[responses.firstObject etag] forKey:MRCReceivedEventsETag];
                    } else if (self.type == MRCNewsViewModelTypePublicActivity) {
                        [[NSUserDefaults standardUserDefaults] setValue:[responses.firstObject etag] forKey:MRCEventsETag];
                    }
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }]
        map:^(NSArray *responses) {
            return [responses.rac_sequence map:^(OCTResponse *response) {
                return response.parsedResult;
            }].array;
        }];
}

- (NSArray *)dataSourceWithEvents:(NSArray *)events {
    if (events.count == 0) return nil;
    
    @weakify(self)
    NSArray *viewModels = [events.rac_sequence map:^(OCTEvent *event) {
        @strongify(self)
        MRCNewsItemViewModel *viewModel = [[MRCNewsItemViewModel alloc] initWithEvent:event];
        viewModel.didClickLinkCommand = self.didClickLinkCommand;
        return viewModel;
    }].array;
    
    return @[ viewModels ];
}

@end
