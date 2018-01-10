//
//  Student.h
//  BlockDemo
//
//  Created by 苏友龙 on 2018/1/9.
//  Copyright © 2018年 YL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Study)();

@interface Student : NSObject

@property (copy , nonatomic) NSString *name;
@property (copy , nonatomic) Study study;

@end
