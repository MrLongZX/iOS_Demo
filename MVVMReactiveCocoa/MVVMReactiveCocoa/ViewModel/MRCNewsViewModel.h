//
//  MRCNewsViewModel.h
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 15/1/10.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//

#import "MRCTableViewModel.h"

typedef NS_ENUM(NSUInteger, MRCNewsViewModelType) {
    MRCNewsViewModelTypeNews,
    MRCNewsViewModelTypePublicActivity
};

@interface MRCNewsViewModel : MRCTableViewModel

@property (nonatomic, copy, readonly) NSArray *events;
/// 是否是当前用户
@property (nonatomic, assign, readonly) BOOL isCurrentUser;
/// news? publicactivity? 
@property (nonatomic, assign, readonly) MRCNewsViewModelType type;
/// 点击cell,进行界面跳转的命令
@property (nonatomic, strong, readonly) RACCommand *didClickLinkCommand;

- (NSArray *)dataSourceWithEvents:(NSArray *)events;

@end
