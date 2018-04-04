//
//  NSArray+beyond.m
//  testArr
//
//  Created by 苏友龙 on 2018/4/4.
//  Copyright © 2018年 SF. All rights reserved.
//

#import "NSArray+beyond.h"

@implementation NSArray (beyond)

-(id)objectAtIndexCheck:(NSUInteger)index
{
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end
