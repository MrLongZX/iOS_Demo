//
//  Person.m
//  DSTestDemo
//
//  Created by dasheng on 16/5/6.
//  Copyright © 2016年 dasheng. All rights reserved.
//

#import "Person.h"

@implementation Person

- (NSString *)getPersonName{
    return @"齐滇大圣";
}

- (NSString *)getAgeWithName:(NSString *)name withSex:(NSString *)sex{
    return @"18";
}

- (void)downloadWeatherDataForZip:(NSString *)zip
                         callback:(void (^)(NSDictionary *response))callback{
    NSDictionary *dic = @{@"key":@"value"};
    callback(dic);
}

- (void)getPrivate{
    NSLog(@"123");
}

- (BOOL)getBoolValue{
    return NO;
}

- (NSString *)getIntegerArgument:(NSInteger)age {
    return @"age";
}

- (NSString *)getIntArgument:(int)age withName:(NSString *)name {
    return @"int";
}

- (void)performPostNotificationAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mockObrever" object:self userInfo:nil];
}

@end
