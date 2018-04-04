//
//  NSMutableArray+beyond.m
//  testArr
//
//  Created by 苏友龙 on 2018/4/4.
//  Copyright © 2018年 SF. All rights reserved.
//

#import "NSMutableArray+beyond.h"

@implementation NSMutableArray (beyond)

-(id)objectAtIndexCheck:(NSUInteger)index
{
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    NSLog(@"%@", [NSThread callStackSymbols]);
    return nil;
}

- (void)addObjectCheck:(id)anObject
{
    if (anObject != nil && [anObject isKindOfClass:[NSNull class]] == NO) {
        [self addObject:anObject];
    } else {
        NSLog(@"%@", [NSThread callStackSymbols]);
        
    }
}

- (void)insertObjectCheck:(id)anObject atIndex:(NSUInteger)index
{
    if (index <= self.count && anObject != nil && [anObject isKindOfClass:[NSNull class]] == NO) {
        [self insertObject:anObject atIndex:index];
    } else {
        NSLog(@"%@", [NSThread callStackSymbols]);
        
    }
}

- (void)removeObjectAtIndexCheck:(NSUInteger)index
{
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    } else {
        NSLog(@"%@", [NSThread callStackSymbols]);
        
    }
}

- (void)replaceObjectAtIndexCheck:(NSUInteger)index withObject:(id)anObject
{
    if (index < self.count && anObject != nil && [anObject isKindOfClass:[NSNull class]] == NO) {
        [self replaceObjectAtIndex:index withObject:anObject];
    } else {
        NSLog(@"%@", [NSThread callStackSymbols]);
        
    }
}

@end
