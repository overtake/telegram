//
//  NSArrayCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSArrayCategory.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

-(id)firstObject {
    return self.count > 0 ? self[0] : nil;
}

@end

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

-(id)firstObject {
    return self.count > 0 ? self[0] : nil;
}

@end
