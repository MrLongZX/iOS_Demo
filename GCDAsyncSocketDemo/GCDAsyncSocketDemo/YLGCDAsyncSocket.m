//
//  YLGCDAsyncSocket.m
//  GCDAsyncSocketDemo
//
//  Created by 苏友龙 on 2017/12/17.
//  Copyright © 2017年 YL. All rights reserved.
//

#import "YLGCDAsyncSocket.h"
#import "GCDAsyncSocket.h"
#import "AFNetworkReachabilityManager.h"

// 服务端IP
#define HOST @"192.168.0.100"

// 服务端开放的端口
#define PORT 8080

// 设置连接超时
#define TIME_OUT 60

// 自动重连次数
#define AUTOCONNECT 3

// 设置读取超时 -1 表示不会使用超时
#define READ_TIME_OUT -1

// 设置写入超时 -1 表示不会使用超时
#define WRITE_TIME_OUT -1

// 每次最多读取多少
#define MAX_BUFFER 1024

static YLGCDAsyncSocket *socketManager;

@interface YLGCDAsyncSocket()<GCDAsyncSocketDelegate>

/** socket */
@property (nonatomic, strong) GCDAsyncSocket *socket;

/** 定时器 */
@property (nonatomic, strong) NSTimer        *timer;

/** 检查网络 */
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

/** 连接状态 */
@property (nonatomic, assign) SocketConnectStatus connectStatus;

/** 自动重连次数 */
@property (nonatomic, assign) NSInteger autoConnectCount;

@end

@implementation YLGCDAsyncSocket

// 创建socketManger单例
+ (instancetype)sharedSocketManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketManager = [[self alloc] init];
    });
    return socketManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 创建socket对象
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // 设置自动重连次数
        _autoConnectCount = AUTOCONNECT;
    }
    return self;
}

// 开始连接socket
- (void)startConnectSocket {
     // 检测网络状态
    if (!_reachabilityManager) {
        [self checkNetWorkStatus];
    }
    
    // socket连接服务端
    if (![self.socket isConnected]) {
        NSError *error = nil;
        BOOL isConnect = [self.socket connectToHost:HOST onPort:PORT viaInterface:nil withTimeout:TIME_OUT error:&error];
        
        if (isConnect && !error) {
            NSLog(@"客户端开始尝试连接");
        } else {
            NSLog(@"客户端尝试连接出现错误：%@",error);
        }
    }
}

// 用户主动断开socket连接
- (void)cutOffSocket {
    _connectStatus = SocketOfflineByUser;
    [self disConnected];
}

// 失去网络导致断开连接
- (void)cutOffSocketBuyNotReachable {
    _connectStatus = SocketOfflineByNetwork;
    [self disConnected];
}

- (void)disConnected {
    //重新设置重连次数
    _autoConnectCount = AUTOCONNECT;
    
    [self.socket disconnect];
    [self.timer invalidate];
}

// 发送消息
- (void)sendMessage:(id)message {
    //连接状态才发送消息
    if ([self.socket isConnected]) {
        NSLog(@"向服务器端发送数据：%@",message);
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        [self.socket writeData:data withTimeout:READ_TIME_OUT tag:0];
    }
}

#pragma mark --- GCDAsyncSocketDelegate
// socket连接上服务器端
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"客户端socket：%@,连接服务器: %@,端口: %d，成功", sock,host,port);
    
    // 状态：在线
    _connectStatus = SocketIsOnLine;
    // 设置自动重连次数
    _autoConnectCount = AUTOCONNECT;
    
    //创建定时器 通过定时器不断发送消息，来检测长连接
    [self createTimer];
    // 设置可读取服务器端数据
    [self.socket readDataWithTimeout:READ_TIME_OUT tag:0];
}

// 从服务器端读取接受的数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // 返回数据
    if (self.block) {
        self.block(data);
    }
    // 设置能再次读取数据
    [self.socket readDataWithTimeout:- 1 tag:0];
}

// 客户端socket断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"断开的socket:%@",sock);
    
    // 用户主动断开连接 或 断网 不再自动连接
    if (_connectStatus == SocketOfflineByUser || _connectStatus == SocketOfflineByNetwork) {
        [self.timer invalidate];
        return;
    }
    _connectStatus = SocketOfflineByOther;
    
    // 不是用户主动断开连接 自动重连 AUTOCONNECT 次
    if (_autoConnectCount) {
        [self startConnectSocket];
        _autoConnectCount --;
    } else {
        [self.timer invalidate];
    }
}

#pragma mark --- myPrivateMethod
// 创建定时器
- (void)createTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    // 把定时器添加到当前运行循环,并且调为通用模式
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

// 心跳连接 发送固定格式的数据
- (void)longConnectToSocket {
    NSString *longConnect = [NSString stringWithFormat:@"自定义内容"];
    NSData *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    // 向服务器端发送数据
    [self.socket writeData:data withTimeout:WRITE_TIME_OUT tag:0];
}

#pragma mark - 检测网络状态
- (void)checkNetWorkStatus{
    _reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    __weak typeof(self)weakSelf = self;
    [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变时调用
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                // 断开socket连接
                [weakSelf cutOffSocketBuyNotReachable];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机自带网络");
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                // 恢复网络 不是由于用户主动断开连接 就再次连接socket
                if (_connectStatus != SocketOfflineByUser) {
                    [weakSelf startConnectSocket];
                }
                break;
        }
    }];
    // 开始监控
    [_reachabilityManager startMonitoring];
}

- (void)dealloc{
    [_reachabilityManager stopMonitoring];
    _reachabilityManager = nil;
}

@end
