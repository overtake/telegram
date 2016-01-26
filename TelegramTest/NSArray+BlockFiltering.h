//
//  NSArray+BlockFiltering.h
//  whatever
//
//  Created by Gabriele Petronella on 1/2/13.
//  Copyright (c) 2013 GG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (BlockFiltering)

- (NSArray *)filteredArrayUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

- (NSArray *)reversedArray;
-(NSArray *)findElementsWithRecursion:(NSString *)q;
@end