//
//  MRCViewModel.h
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 14/12/27.
//  Copyright (c) 2014年 leichunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRCViewModelServices;

/// The type of the title view.
typedef NS_ENUM(NSUInteger, MRCTitleViewType) {
    /// System title view(系统标题)
    MRCTitleViewTypeDefault,
    /// Double title view(双标题)
    MRCTitleViewTypeDoubleTitle,
    /// Loading title view(加载中标题)
    MRCTitleViewTypeLoadingTitle
};

/// An abstract class representing a view model.
@interface MRCViewModel : NSObject

/// Initialization method. This is the preferred way to create a new view model.
///
/// services - The service bus of the `Model` layer.
/// params   - The parameters to be passed to view model.
///
/// Returns a new view model.
- (instancetype)initWithServices:(id<MRCViewModelServices>)services params:(NSDictionary *)params;

/// The `services` parameter in `-initWithServices:params:` method.
@property (nonatomic, strong, readonly) id<MRCViewModelServices> services;

/// The `params` parameter in `-initWithServices:params:` method.
@property (nonatomic, copy, readonly) NSDictionary *params;

@property (nonatomic, assign) MRCTitleViewType titleViewType;
/// 标题
@property (nonatomic, copy) NSString *title;
/// 副标题
@property (nonatomic, copy) NSString *subtitle;

/// The callback block.
@property (nonatomic, copy) VoidBlock_id callback;

/// A RACSubject object, which representing all errors occurred in view model. 表示界面发生的错误
@property (nonatomic, strong, readonly) RACSubject *errors;

/// 是否在VM初始化时获取本地数据
@property (nonatomic, assign) BOOL shouldFetchLocalDataOnViewModelInitialize;
/// 是否在ViewDidLoad时请求远程数据
@property (nonatomic, assign) BOOL shouldRequestRemoteDataOnViewDidLoad;
/// 界面将要消失的信号
@property (nonatomic, strong, readonly) RACSubject *willDisappearSignal;

/// An additional method, in which you can initialize data, RACCommand etc.
///
/// This method will be execute after the execution of `-initWithServices:params:` method. But
/// the premise is that you need to inherit `MRCViewModel`.
- (void)initialize;

@end
