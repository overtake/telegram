//
//  NSArray+BlockFiltering.m
//  whatever
//
//  Created by Gabriele Petronella on 1/2/13.
//  Copyright (c) 2013 GG. All rights reserved.
//

#import "NSArray+BlockFiltering.h"

@implementation NSArray (BlockFiltering)

- (NSArray *)filteredArrayUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    NSIndexSet * filteredIndexes = [self indexesOfObjectsPassingTest:predicate];
    return [self objectsAtIndexes:filteredIndexes];
}

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}


@end