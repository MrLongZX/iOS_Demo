//
//  MRCAvatarHeaderViewModel.h
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 15/1/10.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRCAvatarHeaderViewModel : NSObject

@property (nonatomic, strong, readonly) OCTUser *user;

/// The contentOffset of the scroll view. 头视图内容偏移
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, strong) RACCommand *operationCommand;
/// 跟随者命令
@property (nonatomic, strong) RACCommand *followersCommand;
/// 仓库命令
@property (nonatomic, strong) RACCommand *repositoriesCommand;
/// 跟随命令
@property (nonatomic, strong) RACCommand *followingCommand;

- (instancetype)initWithUser:(OCTUser *)user;

@end
