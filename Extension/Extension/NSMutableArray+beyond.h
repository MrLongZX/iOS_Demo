//
//  NSMutableArray+beyond.h
//  testArr
//
//  Created by 苏友龙 on 2018/4/4.
//  Copyright © 2018年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (beyond)

-(id)objectAtIndexCheck:(NSUInteger)index;

- (void)addObjectCheck:(id)anObject;

- (void)insertObjectCheck:(id)anObject atIndex:(NSUInteger)index;

- (void)removeObjectAtIndexCheck:(NSUInteger)index;

- (void)replaceObjectAtIndexCheck:(NSUInteger)index withObject:(id)anObject;

@end
