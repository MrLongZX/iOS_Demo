//
//  ViewController.m
//  GCDAsyncSocketDemo
//
//  Created by 苏友龙 on 2017/12/17.
//  Copyright © 2017年 YL. All rights reserved.
//

#import "ViewController.h"
#import "YLGCDAsyncSocket.h"

#define kScreenH [UIScreen mainScreen].bounds.size.height
#define kScreenW [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

/** connectSocket */
@property (nonatomic, strong) UIButton *connectSocketButton;

/** sendMessage */
@property (nonatomic, strong) UIButton *sendMessagebutton;

/** cutOff */
@property (nonatomic, strong) UIButton *cutOffbutton;

/** 从服务端接收的内容 */
@property (nonatomic, strong) UITextView *acceptContent;

/** socketManager */
@property (nonatomic, strong) YLGCDAsyncSocket *socketManager;

@end

@implementation ViewController

#pragma mark --- lazyLoad
- (UIButton *)connectSocketButton{
    if (!_connectSocketButton) {
        _connectSocketButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_connectSocketButton setBackgroundColor:[UIColor greenColor]];
        [_connectSocketButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_connectSocketButton setTitle:@"连接服务端socket" forState:UIControlStateNormal];
        [_connectSocketButton addTarget:self action:@selector(didClickConnectSocketButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectSocketButton;
}

- (UIButton *)sendMessagebutton{
    if (!_sendMessagebutton) {
        _sendMessagebutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendMessagebutton setBackgroundColor:[UIColor greenColor]];
        [_sendMessagebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sendMessagebutton setTitle:@"向服务端发送消息" forState:UIControlStateNormal];
        [_sendMessagebutton addTarget:self action:@selector(didClickSendMessageButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendMessagebutton;
}

- (UIButton *)cutOffbutton{
    if (!_cutOffbutton) {
        _cutOffbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cutOffbutton setBackgroundColor:[UIColor greenColor]];
        [_cutOffbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cutOffbutton setTitle:@"断开socket连接" forState:UIControlStateNormal];
        [_cutOffbutton addTarget:self action:@selector(didClickCutOffButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cutOffbutton;
}

- (UITextView *)acceptContent{
    if (!_acceptContent) {
        _acceptContent = [[UITextView alloc] init];
        _acceptContent.editable = NO;
        _acceptContent.backgroundColor = [UIColor greenColor];
    }
    return _acceptContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectSocketButton.frame = CGRectMake(50, 50, kScreenW-100, 50);
    [self.view addSubview:self.connectSocketButton];
    
    self.sendMessagebutton.frame = CGRectMake(50, 120, kScreenW-100, 50);
    [self.view addSubview:self.sendMessagebutton];
    
    self.cutOffbutton.frame = CGRectMake(50, 190, kScreenW-100, 50);
    [self.view addSubview:self.cutOffbutton];
    
    self.acceptContent.frame = CGRectMake(50, kScreenH-310, kScreenW-100, 300);
    [self.view addSubview:self.acceptContent];
    
    // 创建单例
    self.socketManager = [YLGCDAsyncSocket sharedSocketManager];
    // 处理从服务器接受的数据
    __weak typeof(self)weakSelf = self;
    self.socketManager.block = ^(id content) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *text = [[NSString alloc]initWithData:content encoding:NSUTF8StringEncoding];
            weakSelf.acceptContent.text = [weakSelf.acceptContent.text stringByAppendingFormat:@"%@\n", text];
            
        });
    };
}

// 连接socket
- (void)didClickConnectSocketButton {
    // 开始连接服务端
    [self.socketManager startConnectSocket];
}

// 发送消息
- (void)didClickSendMessageButton {
    NSString *message = @"你好";
    // 发送消息给服务端
    [self.socketManager sendMessage:message];
}

// 断开连接
- (void)didClickCutOffButton {
    [self.socketManager cutOffSocket];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
