//
//  YLGCDAsyncSocket.h
//  GCDAsyncSocketDemo
//
//  Created by 苏友龙 on 2017/12/17.
//  Copyright © 2017年 YL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger) {
    SocketIsOnLine,             //在线状态
    SocketOfflineByUser,        //用户主动断开socket
    SocketOfflineByNetwork,     //断网导致断开socket
    SocketOfflineByOther,       //其他原因导致断开socket
}SocketConnectStatus;

// 返回从服务器接受的数据
typedef void(^returnAcceptContent)(id content);

@interface YLGCDAsyncSocket : NSObject

/** block */
@property (nonatomic, copy) returnAcceptContent block;

// 创建socketManger单例
+ (instancetype)sharedSocketManager;

//  开始连接socket
- (void)startConnectSocket;

// 断开socket连接
- (void)cutOffSocket;

// 发送消息
- (void)sendMessage:(id)message;

@end
