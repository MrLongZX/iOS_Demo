//
//  Person.h
//  DSTestDemo
//
//  Created by dasheng on 16/5/6.
//  Copyright © 2016年 dasheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

- (NSString *)getPersonName;

- (NSString *)getAgeWithName:(NSString *)name withSex:(NSString *)sex;

- (void)downloadWeatherDataForZip:(NSString *)zip
                         callback:(void (^)(NSDictionary *response))callback;


- (BOOL)getBoolValue;

- (NSString *)getIntegerArgument:(NSInteger)age;

- (NSString *)getIntArgument:(int)age withName:(NSString *)name;

- (void)performPostNotificationAction;

@end
