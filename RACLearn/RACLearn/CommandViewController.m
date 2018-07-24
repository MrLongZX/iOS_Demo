//
//  CommandViewController.m
//  RACLearn
//
//  Created by 苏友龙 on 2017/3/17.
//  Copyright © 2017年 Pulian. All rights reserved.
//

#import "CommandViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACReturnSignal.h>

@interface CommandViewController ()

@end

@implementation CommandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self arraySequence];
    
    [self test5];
}

- (void)test{
    // 创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        // 发送信号
        [subscriber sendNext:@"ws"];
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        
        // 取消信号，如果信号想要被取消，就必须返回一个RACDisposable
        // 信号什么时候被取消：1.自动取消，当一个信号的订阅者被销毁的时候机会自动取消订阅，2.手动取消，
        //block什么时候调用：一旦一个信号被取消订阅就会调用
        //block作用：当信号被取消时用于清空一些资源
        return [RACDisposable disposableWithBlock:^{
            
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            
            // 执行完Block后，当前信号就不在被订阅了。
            NSLog(@"取消订阅");
        }];
    }];
    
    // 2. 订阅信号
    //subscribeNext
    // 把nextBlock保存到订阅者里面
    // 只要订阅信号就会返回一个取消订阅信号的类
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];
    // 取消订阅
    [disposable dispose];
    
}

- (void)test1{
    RACCommand *commond = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"dispose");
            }];
        }];
    }];
    
    RACSignal *signal = [commond execute:@2];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)test2{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
    }];
    [command.executionSignals subscribeNext:^(RACSignal *x) {
        [x subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
    }];
    [command execute:@2];
}

// 高级做法
- (void)test3 {
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // block调用：执行命令的时候就会调用
        NSLog(@"%@", input);
        // 这里的返回值不允许为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"发送信号"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"dispose");
            }];
        }];
    }];
    
    // 方式三
    // switchToLatest获取最新发送的信号，只能用于信号中信号。
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 2.执行命令
    [command execute:@3];
    
}

- (void)testCommandExecuting{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"input:%@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"ext"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"dispose");
            }];
        }];
    }];
    
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"当前正在执行%@", x);
        } else {
            // 执行完成/没有执行
            NSLog(@"执行完成/没有执行");
        }
    }];
    
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"x :%@",x);
    }];
    
    [command execute:@"7890"];
}

// 普通写法, 这样的缺点是：没订阅一次信号就得重新创建并发送请求，这样很不友好
- (void)test4{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // didSubscribeblock中的代码都统称为副作用。
        // 发送请求---比如afn
        NSLog(@"发送请求啦");
        // 发送信号
        [subscriber sendNext:@"ws"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose");
        }];
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}

// 比较好的做法。 使用RACMulticastConnection，无论有多少个订阅者，无论订阅多少次，我只发送一个。
- (void)test5 {
    // 1.发送请求，用一个信号内包装，不管有多少个订阅者，只想发一次请求
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送请求啦");
        // 发送信号
        [subscriber sendNext:@"ws"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose");
        }];
    }];
    //2. 创建连接类
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    //3. 连接。只有连接了才会把信号源变为热信号
    [connection connect];

}

- (void)map {
    
    // Map使用步骤:
    // 1.传入一个block,类型是返回对象，参数是value
    // 2.value就是源信号的内容，直接拿到源信号的内容做处理
    // 3.把处理好的内容，直接返回就好了，不用包装成信号，返回的值，就是映射的值。
    
    // Map底层实现:
    // 0.Map底层其实是调用flatternMap,Map中block中的返回的值会作为flatternMap中block中的值。
    // 1.当订阅绑定信号，就会生成bindBlock。
    // 3.当源信号发送内容，就会调用bindBlock(value, *stop)
    // 4.调用bindBlock，内部就会调用flattenMap的block
    // 5.flattenMap的block内部会调用Map中的block，把Map中的block返回的内容包装成返回的信号。
    // 5.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
    // 6.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
    
    
    
    // Map作用:把源信号的值映射成一个新的值
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSignal = [subject map:^id(id value) {
        
        // 返回的类型就是你需要映射的值
        return [NSString stringWithFormat:@"ws:%@", value]; //这里将源信号发送的“123” 前面拼接了ws：
    }];
    // 订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@"123"];
}

- (void)flatMap1 {
    RACSubject *subject = [RACSubject subject];
    RACSignal *signal = [subject flattenMap:^RACStream *(id value) {
        return [RACReturnSignal return:value];
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x:%@",x);
    }];
    
    [subject sendNext:@"12345"];
}

- (void)flatMap {
    RACSubject *signalofSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    
    [[signalofSignals flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // 发送信号
    [signalofSignals sendNext:signal];
    [signal sendNext:@"123"];
}

// 跳跃 ： 如下，skip传入2 跳过前面两个值
// 实际用处： 在实际开发中比如 后台返回的数据前面几个没用，我们想跳跃过去，便可以用skip
- (void)skip {
    RACSubject *subject = [RACSubject subject];
    [[subject skip:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

//distinctUntilChanged:-- 如果当前的值跟上一次的值一样，就不会被订阅到
- (void)distinctUntilChanged {
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@2];
}

// take:可以屏蔽一些值,取前面几个值---这里take为2 则只拿到前两个值
- (void)take {
    RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];

}

//takeLast:和take的用法一样，不过他取的是最后的几个值，如下，则取的是最后两个值
//注意点:takeLast 一定要调用sendCompleted，告诉他发送完成了，这样才能取到最后的几个值
- (void)takeLast {
    RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendCompleted];
}

// takeUntil:---给takeUntil传的是哪个信号，那么当这个信号发送信号或sendCompleted，就不能再接受源信号的内容了。
- (void)takeUntil{
    RACSubject *subject = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject takeUntil:subject2] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
//    [subject2 sendNext:@3];
    [subject2 sendCompleted];
    [subject sendNext:@4];
}

//ignore:忽略一些值
//ignoreValues:表示忽略所有的值
- (void)ignore {
    RACSubject *subject = [RACSubject subject];
    RACSubject *ignoreSignal = [subject ignore:@2];
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@2];
    [subject sendNext:@1];
}

- (void)arraySequence
{
    NSArray *array = [@[@2,@5,@3,@8,@1].rac_sequence take:4].array;
    NSLog(@"array:%@",array);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
