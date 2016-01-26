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

-(NSArray *)findElementsWithRecursion:(NSString *)q {
    return [self findElementsWithRecursion:[NSMutableArray array] inside:self q:q];
}

-(NSArray *)findElementsWithRecursion:(NSMutableArray *)result inside:(NSArray *)inside q:(NSString *)q {
    
    [inside enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj class] == [NSString class]) {
            if([obj rangeOfString:q].location != NSNotFound) {
                [result addObject:obj];
            }
        } else if([obj isKindOfClass:[NSArray class]]) {
            [result addObjectsFromArray:[self findElementsWithRecursion:[NSMutableArray array] inside:obj q:q]];
        }
        
        
    }];
    
    
    return result;
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
