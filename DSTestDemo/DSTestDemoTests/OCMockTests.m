//
//  OCMockTests.m
//  DSTestDemo
//
//  Created by dasheng on 16/5/6.
//  Copyright © 2016年 dasheng. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "TwitterViewController.h"
#import "TwitterConnection.h"
#import "TweetView.h"
#import "Tweet.h"
#import "Person.h"
#import "Son.h"

//欺骗编译器 调用私有方法
@interface Person()
- (void)getPrivate;
@end

@interface OCMockTests : XCTestCase
@property (nonatomic, strong) Person *person;
@end

/*
 
 学习链接：
 官网：
 http://ocmock.org/reference/#partial-mocks
 其他:
 http://www.jianshu.com/p/44ea034ac755
 
 http://blog.oneinbest.com/2017/07/27/iOS%E6%B5%8B%E8%AF%95%E7%B3%BB%E5%88%97-%E4%B8%89-OCMock%E7%9A%84%E4%BD%BF%E7%94%A8/
 
 http://blog.devgsk.com/2016/04/06/ios-dan-yuan-ce-shi-zhi-ocmock-er/
 
 http://blog.csdn.net/jymn_chen/article/details/21562869
 
 OCMock主要内容：
 * **模拟对象（mock object:类实例模拟、协议模拟、部分模拟、观察者模拟、严格模拟）**
 * **stub方法(调用方法返回预先设置的值)**
 * **交互验证**
 * **参数约束**
 * **模拟类方法**
 * **部分模拟**
 * **严格模拟与期望**
 * **观察者模拟**
 
*/

@implementation OCMockTests

- (void)setUp {
    self.person = [[Person alloc] init];
    [super setUp];
}

- (void)tearDown {
    self.person = nil;
    [super tearDown];
}

//最简单的一个使用OCMock的例子
- (void)testPersonNameEqual{
    
    //创建一个mock对象
    id mockClass = OCMClassMock([Person class]);
    
    //stub掉getPersonName方法并设置返回值
    OCMStub([mockClass getPersonName]).andReturn(@"齐滇大圣");
    
    //预设返回值和实际的值进行比较是否相等
    XCTAssertEqualObjects([mockClass getPersonName], [self.person getPersonName] , @"值相等");
}

//交互验证 OCMVerify 实例方法
- (void)testDisplaysTweetsRetrievedFromConnection{
    
    TwitterViewController *controller = [[TwitterViewController alloc] init];
    //模拟一个view类
    id mockView = OCMClassMock([TweetView class]);
    controller.tweetView = mockView;
    
    //模拟一个网络连接请求数据的对象
    id mockConnection = OCMClassMock([TwitterConnection class]);
    controller.connection = mockConnection;
    
    //模拟fetchTweets方法返回预设值
    Tweet *testTweet = [[Tweet alloc] init];
    testTweet.userName = @"齐滇大圣";
    Tweet *testTweet2 = [[Tweet alloc] init];
    testTweet2.userName = @"美猴王";
    NSArray *tweetArray = @[testTweet,testTweet2];
    //stub掉mockConnection类模拟对象的fetchTweets方法 设置返回值为数组tweetArray
    OCMStub([mockConnection fetchTweets]).andReturn(tweetArray);
    
    //这里执行updateTweetView之后，[mockView addTweet:]加入了testTweet和testTweet2
    [controller updateTweetView];
    
    //验证使用对应参数的方法是否被调用 成功
    OCMVerify([mockView addTweet:testTweet]);
    OCMVerify([mockView addTweet:testTweet2]);
    ///[OCMArg any]匹配所有的参数值，既testTweet和testTweet2
    OCMVerify([mockView addTweet:[OCMArg any]]);

    //失败，因为执行[controller updateTweetView];的时候，mockView没有添加testTweet3，所以验证不通过
    //Tweet *testTweet3 = [[Tweet alloc] init];
    //testTweet3.userName = @"斗战胜佛";
    //OCMVerify([mockView addTweet:testTweet3]);
}

////交互验证 OCMVerify 类模拟方法
- (void)testDisplaysTweetsRetrievedFromConnection2{
    
    TwitterViewController *controller = [[TwitterViewController alloc] init];
    //模拟一个view类
    id mockView = OCMClassMock([TweetView class]);
    controller.tweetView = mockView;
    //模拟一个网络连接请求数据的类
    id mockConnection = OCMClassMock([TwitterConnection class]);
    controller.connection = mockConnection;
    
    //模拟fetchTweets2方法返回预设值
    Tweet *testTweet = [[Tweet alloc] init];
    testTweet.userName = @"齐滇大圣";
    Tweet *testTweet2 = [[Tweet alloc] init];
    testTweet2.userName = @"美猴王";
    NSArray *tweetArray = @[testTweet,testTweet2];
    //mockConnection mock对象，没有找到相同名字的实例方法的时候去找同名的类方法。
    //在名字相同的情况下（类方法和实例方法同名）用classMethod来指定类方法
    OCMStub(ClassMethod([mockConnection fetchTweets2])).andReturn(tweetArray);
    
    //这里执行updateTweetView2之后，[mockView addTweet:]加入了testTweet和testTweet2
    [controller updateTweetView2];
    
    //验证使用对应参数的方法是否被调用 成功
    OCMVerify([mockView addTweet:testTweet]);
    OCMVerify([mockView addTweet:testTweet2]);
    //[OCMArg any]匹配所有的参数值，既testTweet和testTweet2
    OCMVerify([mockView addTweet:[OCMArg any]]);
    
    //失败，因为执行[controller updateTweetView];的时候，mockView没有添加testTweet3，所以验证不通过
    //Tweet *testTweet3 = [[Tweet alloc] init];
    //testTweet3.userName = @"斗战胜佛";
    //OCMVerify([mockView addTweet:testTweet3]);
}

//交互验证 严格模拟
- (void)testStrictMock{
    
    //严格模拟对象
    id classMock = OCMStrictClassMock([TweetView class]);
    
    OCMExpect([classMock addTweet:[OCMArg isNotNil]]);
    //OCMStub([classMock addTweet:[OCMArg isNotNil]]);
    
    Tweet *testTweet = [[Tweet alloc] init];
    testTweet.userName = @"齐滇大圣";
    //如果没有expect 或 stub addTweet方法 这里将会崩溃
    [classMock addTweet:testTweet];
    
    //验证被期望的方法是否全部执行
    OCMVerifyAll(classMock);
    
//    //类模拟对象
//    id classMock = OCMClassMock([TweetView class]);
//
//    //没有stub或expext 类模拟对象classMock的addTweet方法 就执行addTweet方法
//    Tweet *testTweet = [[Tweet alloc] init];
//    testTweet.userName = @"齐滇大圣";
//    [classMock addTweet:testTweet];
//
//    //验证被期望的方法是否全部执行
//    OCMVerifyAll(classMock);
}

//交互验证 方法没有参数
- (void)testClassMockValidation {
    id classMockP = OCMClassMock([Person class]);
    OCMStub([classMockP getPersonName]).andReturn(@"123");
    
    [classMockP getPersonName];
    
    //验证getPersonName方法是否被classMockP对象调用
    OCMVerify([classMockP getPersonName]);
}

//stub方法 让某个方法返回指定对象或非对象值
- (void)testGetBoolValue {
    id mockP = OCMClassMock([Person class]);
    OCMStub([mockP getBoolValue]).andReturn(YES);
    
    XCTAssertTrue([mockP getBoolValue]);
    XCTAssertFalse([self.person getBoolValue]);
}

//stub方法 让某个方法交由代理对象实现
- (void)testStubCall {
    id mockP = OCMClassMock([Person class]);
    Son *son = [[Son alloc] init];
    //当调用getPersonName时，实际调用的是son的@selector(dealWithPersonMethod)
    //参数和返回值都作用和来自于dealWithPersonMethod方法
    OCMStub([mockP getPersonName]).andCall(son,@selector(dealWithPersonMethod));
    XCTAssertEqualObjects([mockP getPersonName], @"23");
}

//stub方法 委托block实现某个方法
//NSInvocation学习链接：http://www.jianshu.com/p/e24b3420f1b4
- (void)testStubAndDo {
    id mockP = OCMClassMock([Person class]);
    
    __block NSString *result;
    OCMStub([mockP getPersonName]).andDo(^(NSInvocation *invocation) {
        //创建一个方法签名
        Son *son = [[Son alloc] init];
        SEL selector = NSSelectorFromString(@"dealWithPersonMethod");
        NSMethodSignature *signature = [son methodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        //要执行谁的（target）的哪个方法（selector）
        invocation.target = son;
        invocation.selector = selector;
        //执行方法
        [invocation invoke];
        //获取返回值
        if (signature.methodReturnLength > 0) {
            [invocation getReturnValue:&result];
            NSLog(@"syl:%@",result);
        }
    });
    [mockP getPersonName];
    XCTAssertEqualObjects(result, @"23");
}

//参数约束 参数都是NSString对象
- (void)testGetAge {
    Person *person = [[Person alloc] init];
    
    id mockP = OCMClassMock([Person class]);
    //stub掉getAgeWithName:withSex: 并设置参数约束 第一次参数可以为任何值 第二个参数必须为M
    OCMStub([mockP getAgeWithName:[OCMArg any] withSex:@"M"]).andReturn(@"16");
    
    XCTAssertEqualObjects([mockP getAgeWithName:@"2" withSex:@"M"], @"16");
    
    //this will throw an exception
    //XCTAssertEqualObjects([mockP getAgeWithName:@"2" withSex:@"W"], @"18");
    
    XCTAssertEqualObjects([person getAgeWithName:@"2" withSex:@"M"], @"18");
}

//参数约束 参数有基础类型 忽略非对象约束
- (void)testIntArgument {
    id mockP = OCMClassMock([Person class]);

    //只有单个基础类型 参数
    OCMStub([[mockP ignoringNonObjectArgs] getIntegerArgument:0]).andReturn(@"12");

    XCTAssertEqualObjects([mockP getIntegerArgument:12], @"12");

    XCTAssertEqualObjects([mockP getIntegerArgument:10], @"12");

    //有基础类型参数 有对象NSString类型参数
    OCMStub([[mockP ignoringNonObjectArgs] getIntArgument:0 withName:@"123"]).andReturn(@"ttt");
    //int 随便
    XCTAssertEqualObjects([mockP getIntArgument:12 withName:@"123" ], @"ttt");

    XCTAssertEqualObjects([mockP getIntArgument:10 withName:@"123" ], @"ttt");
    //改变 string参数
    XCTAssertNotEqualObjects([mockP getIntArgument:12 withName:@"111" ], @"ttt");
    
}

//模仿模拟 调用私有方法
- (void)testPersonPrivateMethod{
    id mockP = OCMPartialMock(self.person);
    [mockP getPrivate];
}

//部分模拟
- (void)testPartial {
    id mockP = OCMPartialMock(self.person);
    //部分模拟 在方法没有stub之前 会调用方法
    NSLog(@"%@",[mockP getPersonName]);

    OCMStub([mockP getPersonName]).andReturn(@"12");

    XCTAssertEqualObjects([mockP getPersonName], @"12");
    //部分模拟 在方法stub之后 不会在调用方法 直接返回andReturn的值
    NSLog(@"%@",[mockP getPersonName]);

    OCMVerify([mockP getPersonName]);

    [mockP stopMocking];
    
    id classMockP = OCMClassMock([Person class]);
    //类模拟 不管方法有没有stub都不会调用方法
    NSLog(@"%@",[classMockP getPersonName]);
}

//期望-运行-验证
- (void)testExpect {
    id classMockP = OCMClassMock([Person class]);
    
    //设置期望的方法
    OCMExpect([classMockP getPersonName]);
    //设置期望的同时stub该方法 并指定该方法返回值
    OCMExpect([classMockP getAgeWithName:[OCMArg any] withSex:@"M"]).andReturn(@"123");
    
    //调用被期望的俩方法
    [classMockP getPersonName];
    XCTAssertEqualObjects([classMockP getAgeWithName:@"tom" withSex:@"M"], @"123");
    
    //验证expect的方法是否全部被调用
    OCMVerifyAll(classMockP);
}

//期望-运行-验证 设置顺序验证
- (void)testExpectWithOrder {
    id classMockP = OCMClassMock([Person class]);
    
    //设置顺序验证开启，如果方法调用没有按照期望方法设置的顺序进行，那么会报错
    [classMockP setExpectationOrderMatters:YES];
    
    //设置期望的方法
    OCMExpect([classMockP getPersonName]);
    //设置期望的同时stub该方法 并指定该方法返回值
    OCMExpect([classMockP getAgeWithName:[OCMArg any] withSex:@"M"]).andReturn(@"123");
    
    //调用被期望的俩方法
    [classMockP getPersonName];
    XCTAssertEqualObjects([classMockP getAgeWithName:@"tom" withSex:@"M"], @"123");
    
    //验证expect的方法是否全部被调用
    OCMVerifyAll(classMockP);
}

//期望-运行-延时验证（用于等待异步操作会比较多）
- (void)testExpectWithDelay {
    id classMockP = OCMClassMock([Person class]);
    
    //设置期望的方法
    OCMExpect([classMockP getPersonName]);
    //设置期望的同时stub该方法 并指定该方法返回值
    OCMExpect([classMockP getAgeWithName:[OCMArg any] withSex:@"M"]).andReturn(@"123");
    
    //模拟异步延时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //调用被期望的俩方法
        [classMockP getPersonName];
        XCTAssertEqualObjects([classMockP getAgeWithName:@"tom" withSex:@"M"], @"123");
    });
    
    //验证expect的方法是否在3秒钟内全部被调用
    OCMVerifyAllWithDelay(classMockP, 3);
}

//严格模拟
- (void)testStrict {
    id strictMockP = OCMStrictClassMock([Person class]);
    
    //stub该方法
    OCMStub([strictMockP getPersonName]).andReturn(@"12");
    
    //调用方法 (严格模拟下 如果没有stub该方法 就调用 会崩溃)
    NSLog(@"%@",[strictMockP getPersonName]);
}

//观察者模拟
- (void)testObserver {
    //创建观察者模拟对象
    id observerMock = OCMObserverMock();
    //创建通知中心
    NSNotificationCenter *notificatonCenter = [NSNotificationCenter defaultCenter];
    //对通知中心 注册添加观察者模拟对象为mockObrever通知的接受者
    [notificatonCenter addMockObserver:observerMock name:@"mockObrever" object:nil];
    //观察者为严格模拟 需要被期望，如果收到未期望的通知，会报错
    [[observerMock expect] notificationWithName:@"mockObrever" object:[OCMArg any]];
    
    //执行发送通知
    [self.person performPostNotificationAction];
    
    //验证观察者模拟对象是否收到通知
    OCMVerifyAll(observerMock);
}

@end
