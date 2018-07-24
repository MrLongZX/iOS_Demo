//
//  SignalCombineViewController.m
//  RACLearn
//
//  Created by 苏友龙 on 2018/4/18.
//  Copyright © 2018年 Pulian. All rights reserved.
//

#import "SignalCombineViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACReturnSignal.h>

@interface SignalCombineViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameTF;

@property (nonatomic, strong) UITextField *passTF;

@property (nonatomic, strong) UIButton *loginBtn;

@end

@implementation SignalCombineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.nameTF];
    [self.view addSubview:self.passTF];
    [self.view addSubview:self.loginBtn];
    
    
    // 文本过滤
    //[self filter];
    
    // 信号的合并
    //[self signalCombine];
    
    //[self zipWith];
    
    //[self merge];
    
    //[self then];
    
    //[self concat];
    
    [self doCombineLatest];
    
    //[self testCollectSignalsAndCombineLatestOrZip];
    
    // 绑定
    //[self bind];
    
    //[self subjectReplayLazily];
    
    // 序列
    //[self sequenec];
    
    // 秩序
    //[self doNextAndComplete];
    
    // 线程
    //[self doDeliverOn];
    
    //[self doSubscribeOn];
    
    // 时间
    //[self doInterval];
    
    //[self doTimeout];
    
    //[self doDelay];
    
    // 重复
    //[self doRetry];
    
    //[self doReplay];
    
    //[self doThrottle];
    
    // 验证登陆
    //[self verifyLogin];
}

// 一般和文本框一起用，添加过滤条件
- (void)filter
{
//    [[self.nameTF.rac_textSignal filter:^BOOL(NSString *value) {
//        return value.length > 2;
//    }] subscribeNext:^(id x) {
//        NSLog(@"x : %@",x);
//    }];
    
    [[[self.nameTF.rac_textSignal map:^id(NSString *value) {// 映射
        return @(value.length);
    }] filter:^BOOL(NSNumber *value) {// 过滤
        return [value integerValue] > 2;
    }] subscribeNext:^(id x) {
        NSLog(@"x : %@",x);
    }];
    
}

// 把多个信号聚合成你想要的信号,使用场景----：比如-当多个输入框都有值的时候按钮才可点击。
// 思路--- 就是把输入框输入值的信号都聚合成按钮是否能点击的信号。
- (void)signalCombine
{
    RACSignal *signal = [RACSignal combineLatest:@[_nameTF.rac_textSignal,_passTF.rac_textSignal] reduce:^id(NSString *name, NSString *pass){
        NSLog(@"name:%@, pass:%@",name,pass);
        return @(name.length && pass.length);
    }];
    
//    [signal subscribeNext:^(id x) {
//        _loginBtn.enabled = [x boolValue];
//    }];
    
    RAC(_loginBtn, enabled) = signal;
}


- (void)zipWith
{
    RACSubject *subjectA = [RACSubject subject];
    RACSubject *subjectB = [RACSubject subject];
    
    //zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元祖，才会触发压缩流的next事件。
    RACSubject *zipSubject = [subjectA zipWith:subjectB];
    [zipSubject subscribeNext:^(id x) {
        NSLog(@"zip x :%@",x);
    }];
    
     // 发送信号 交互顺序，元组内元素的顺序不会变，跟发送的顺序无关，而是跟压缩的顺序有关[signalA zipWith:signalB]---先是A后是B
    [subjectA sendNext:@"123"];
    [subjectB sendNext:@"456"];
}

// 任何一个信号请求完成都会被订阅到
// merge:多个信号合并成一个信号，任何一个信号有新值就会调用
- (void)merge
{
    RACSubject *subjectA = [RACSubject subject];
    RACSubject *subjectB = [RACSubject subject];
    // 合并
    RACSignal *signal = [subjectA merge:subjectB];
    [signal subscribeNext:^(id x) {
        NSLog(@"x:%@",x);
    }];
    
    [subjectA sendNext:@"a"];
    [subjectB sendNext:@"b"];
}

// then 使用需求：有两部分数据：想让上部分先进行网络请求但是过滤掉数据(上部分数据获取后，不需要给下部分)，然后进行下部分的，拿到下部分数据
- (void)then
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"----发送上部分请求---afn");
        [subscriber sendNext:@"A"];
        //[subscriber sendError:[NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil]];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose A");
        }];
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"----发送下部分请求---afn");
        //[subscriber sendNext:@"B"];
        [subscriber sendError:[NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil]];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispoase B");
        }];
    }];
    
    // 创建组合信号
    // then;忽略掉第一个信号的所有值
    RACSignal *thenSignal = [signalA then:^RACSignal *{
        return signalB;
    }];

    [thenSignal subscribeNext:^(id x) {
        NSLog(@"x:%@",x);
    } error:^(NSError *error) {
        NSLog(@"error:%@",error);
    }];
    
}

// concat----- 使用需求：有两部分数据：想让上部分先执行，完了之后再让下部分执行（都可获取值）
- (void)concat
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"----发送上部分请求---afn");
        [subscriber sendNext:@"A"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose A");
        }];
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"----发送下部分请求---afn");
        [subscriber sendNext:@"B"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispoase B");
        }];
    }];
    
    // concat:按顺序去链接
    //**-注意-**：concat，第一个信号必须要调用sendCompleted
    RACSignal *concatSignal = [signalA concat:signalB];
    
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"x:%@",x);
    }];
}

//
- (void)doCombineLatest
{
//    RACSignal *signal1 = [@[ @1, @2 ] rac_sequence].signal;
//    RACSignal *signal2 = [@[ @3, @4 ] rac_sequence].signal;
//
//    [[signal1 combineLatestWith:signal2] subscribeNext:^(RACTuple *value) {
//        NSLog(@"%@", value);
//    }];
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"A1"];
        [subscriber sendNext:@"A2"];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"B1"];
        [subscriber sendNext:@"B2"];
        [subscriber sendNext:@"B3"];
        
        return nil;
    }];
    
    RACSignal *combineSianal = [signalA combineLatestWith:signalB];
    
    [combineSianal subscribeNext:^(id x) {
        
        NSLog(@"combineLatest:%@", x);
    }];
}

- (void)testCollectSignalsAndCombineLatestOrZip
{
    RACSignal *numbers = @[@(0), @(1), @(2)].rac_sequence.signal;
    
    RACSignal *letters1 = @[@"A", @"B", @"C"].rac_sequence.signal;
    RACSignal *letters2 = @[@"X", @"Y", @"Z"].rac_sequence.signal;
    RACSignal *letters3 = @[@"M", @"N"].rac_sequence.signal;
    NSArray *arrayOfSignal = @[letters1, letters2, letters3];
    
    
    [[[numbers map:^id(NSNumber *n) {
        return arrayOfSignal[n.integerValue];
    }] collect] subscribeNext:^(NSArray *array) {
        NSLog(@"%@, %@", [array class], array);
    } completed:^{
        NSLog(@"completed");
    }];
}

- (void)testCollectSignalsAndCombineLatestOrZip2 {
    RACSignal *numbers = @[@(0), @(1), @(2)].rac_sequence.signal;
    
    RACSignal *letters1 = @[@"A", @"B", @"C"].rac_sequence.signal;
    RACSignal *letters2 = @[@"X", @"Y", @"Z"].rac_sequence.signal;
    RACSignal *letters3 = @[@"M", @"M"].rac_sequence.signal;
    NSArray *arrayOfSignal = @[letters1, letters2, letters3];
    
    [[[[numbers map:^id(NSNumber *n) {
        return arrayOfSignal[n.integerValue];
    }] collect] flattenMap:^RACStream *(NSArray *arrayOfSignal) {
        return [RACSignal combineLatest:arrayOfSignal reduce:^(NSString *first, NSString *second, NSString *thrid){
            return [NSString stringWithFormat:@"%@-%@-%@",first,second,thrid];
        }];
    }] subscribeNext:^(NSString  *x) {
        NSLog(@"%@,%@",[x class],x);
    } completed:^{
        NSLog(@"completed");
    }];
}

// 绑定
- (void)bind
{
    [[_nameTF.rac_textSignal bind:^RACStreamBindBlock{
        return ^RACStream *(id value, BOOL *stop) {
            return [RACReturnSignal return:[NSString stringWithFormat:@"sldk:%@",value]];
        };
    }] subscribeNext:^(id x) {
        NSLog(@"bind:%@",x);
    }];
    
}

// 第一次订阅者接受到sendnext的内容后，再次订阅都会接受到之前sendnext的内容，sendnext发送的内容，每个订阅者都会接受到
- (void)subjectReplayLazily {
    RACSubject *letters = [RACSubject subject];
    RACSignal *signal = [letters replayLazily];
    
    [letters sendNext:@"A"];
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    [letters sendNext:@"B"];
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    [letters sendNext:@"C"];
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
    [letters sendNext:@"D"];
}

// sequenec序列
- (void)sequenec
{
    // 遍历数组
    NSArray *numb = @[@1,@2,@3];
    [numb.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"x :%@",x);
    }];
    
    // 遍历字典
    NSDictionary *dic = @{@"name": @"BYqiu", @"age": @18};
    [dic.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"key : %@, value ： %@",key,value);
    }];
    
    // 字典转模型
    /*
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dicArray = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *items = [NSMutableArray array];
    // OC写法
    for (NSDictionary *dic in dicArray) {
        
        //FlagItem *item = [FlagItem flagWithDict:dict];
        //[items addObject:item];
    }
    
    // RAC写法
    [dicArray.rac_sequence.signal subscribeNext:^(id x) {
        // 利用RAC遍历， x：字典
        
        //FlagItem *item = [FlagItem flagWithDict:x];
        //[items addObject:item];
    }];
    
    // RAC高级用法（函数式编程）
    NSArray *flags = [[dicArray.rac_sequence map:^id(id value) {
        return  [FlagItem flagWithDict:value];
    }] array];
    */
   
}

// 秩序 doNext doCompleted
- (void)doNextAndComplete
{
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }] doNext:^(id x) {
        // 执行 [subscriber sendNext:@"hi"] 之前会调用这个 Block
        NSLog(@"donext");
    }] doCompleted:^{
        NSLog(@"docompleted");
    }] subscribeNext:^(id x) {
        NSLog(@"x : %@",x);
    }];
}

// 线程
- (void)doDeliverOn
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           
            NSLog(@"thread : %@",[NSThread currentThread]);
            [subscriber sendNext:@"1"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"dispose");
            }];
        }]
         deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(id x) {
             
             NSLog(@"x :%@",x);
             NSLog(@"thread : %@",[NSThread currentThread]);
        }];
    });
}

// 线程
- (void)doSubscribeOn
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            NSLog(@"thread : %@",[NSThread currentThread]);
            [subscriber sendNext:@"1"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"dispose");
            }];
        }]
          subscribeOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(id x) {
             
             NSLog(@"x :%@",x);
             NSLog(@"thread : %@",[NSThread currentThread]);
         }];
    });
}

// 定时
- (void)doInterval
{
    [[RACSignal interval:2 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(id x) {
        NSLog(@"x %@",x);
    }];
}

// 超时
- (void)doTimeout
{
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 不发送信号 模拟超时
        //[subscriber sendNext:@"1"];
        //[subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose");
        }];
    }]
      timeout:2 onScheduler:[RACScheduler currentScheduler]]
     subscribeNext:^(id x) {
         NSLog(@"x : %@",x);
     } error:^(NSError *error) {
         NSLog(@"error : %@",error);
     }];
}

// 延时
- (void)doDelay
{
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose");
        }];
    }] delay:2] subscribeNext:^(id x) {
        NSLog(@"x : %@",x);
    }];
}

// 重试
- (void)doRetry
{
    __block int i = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (i == 5) {
            [subscriber sendNext:@"1"];
            [subscriber sendCompleted];
        } else {
            // 发送错误
            NSLog(@"收到错误:%d", i);
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:2 userInfo:@{@"key":@"错误"}];
            [subscriber sendError:error];
        }
        i++;
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose");
        }];
    }] retry] subscribeNext:^(id x) {
        NSLog(@"x : %@",x);
    } error:^(NSError *error) {
        NSLog(@"error : %@",error);
    }];
}

// 重播
- (void)doReplay
{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispose");
        }];
    }] replay];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x1 : %@",x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"x2 : %@",x);
    }];
}

// 节流
- (void)doThrottle
{
    RACSubject *subject = [RACSubject subject];
    [[subject throttle:2] subscribeNext:^(id x) {
        NSLog(@"x : %@",x);
    }];
    
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
}

// 验证登陆的使用
- (void)verifyLogin
{
    RACSignal *vailName =  [self.nameTF.rac_textSignal map:^id(NSString *value) {
        return @([value isEqualToString:@"name"]);
    }];
    
    RACSignal *vailPass = [self.passTF.rac_textSignal map:^id(NSString *value) {
        return @([value isEqualToString:@"pass"]);
    }];
    
    RAC(self.nameTF, backgroundColor) = [vailName map:^id(NSNumber *value) {
        return [value boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    RAC(self.passTF, backgroundColor) = [vailPass map:^id(NSNumber *value) {
        return [value boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    RACSignal *vailBtn = [RACSignal combineLatest:@[vailName, vailPass] reduce:^id(NSNumber *nameBool, NSNumber *passBool){
        return @([nameBool boolValue] && [passBool boolValue]);
    }];
    
    [vailBtn subscribeNext:^(id x) {
        self.loginBtn.enabled = [x boolValue];
    }];
}

- (RACSignal *)signInsignal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"success"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"dispoasble");
        }];
    }];
}

#pragma mark - lazyload
- (UIButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.frame = CGRectMake(20, 190, 250, 30);
        [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundColor:[UIColor greenColor]];
        [_loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
        [[[[_loginBtn
            rac_signalForControlEvents:UIControlEventTouchUpInside]
           doNext:^(id x) {// 副作用
               _loginBtn.enabled = NO;
           }]
          flattenMap:^RACStream *(id value) {// 映射 返回信号
              return [self signInsignal];
          }]
         subscribeNext:^(id x) {
             _loginBtn.enabled = YES;
             if ([x isEqualToString:@"success"]) {
                 NSLog(@"x :%@",x);
             }
         }];
        
    }
    return _loginBtn;
}

- (UITextField *)nameTF{
    if (!_nameTF) {
        _nameTF = [[UITextField alloc] init];
        _nameTF.frame = CGRectMake(20, 100, 250, 30);
        _nameTF.delegate = self;
        _nameTF.borderStyle = UITextBorderStyleLine;
        _nameTF.placeholder = @"name";
    }
    return _nameTF;
}

- (UITextField *)passTF{
    if (!_passTF) {
        _passTF = [[UITextField alloc] init];
        _passTF.frame = CGRectMake(20, 150, 250, 30);
        _passTF.delegate = self;
        _passTF.borderStyle = UITextBorderStyleLine;
        _passTF.placeholder = @"password";
    }
    return _passTF;
}

// 异步获取图片
- (RACSignal *)signalForLoadingImage:(NSString *)imgUrl
{
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
