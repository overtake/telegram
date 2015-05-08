//
//  TMRowItem.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"
#import "TMTableView.h"

@interface TMRowItem()
@property (nonatomic) NSUInteger hashCache;
@end
@implementation TMRowItem

- (void) redrawRow {
   // if(!self.rowDelegate) {
        TMTableView *table = (TMTableView *)self.table;
        if(table) {
            NSUInteger pos = [table positionOfItem:self];
            if(pos != NSNotFound && pos != -1) {
                NSTableRowView *cellView = [table rowViewAtRow:pos makeIfNecessary:NO];
                if(cellView && cellView.subviews.count) {
                    [cellView.subviews enumerateObjectsUsingBlock:^(NSObject *obj, NSUInteger idx, BOOL *stop) {
                        
                        if(obj.class != NSView.class) {
                            if([obj respondsToSelector:@selector(redrawRow)])
                                [(TMRowView *)obj redrawRow];
                            *stop = YES;
                        }
                        
                    }];
                }
            }
        }
   // }
    
//    MTLog(@"redraw rows");
    
}

-(id)initWithObject:(id)object {
    if(self = [super init]) {
        
    }
    return self;
}

- (void) dealloc {
    [NSClassFromString(@"Notification") removeObserver:self];
}

- (NSUInteger)hash {
    if(!self.hashCache) {
        self.hashCache = [[self class] hash:[self itemForHash]];
    }
    return self.hashCache;
}

- (NSObject *)itemForHash {
    [NSException raise:@"Not implemented" format:@""];
    return nil;
}

+ (NSUInteger)hash:(NSObject *)object {
    [NSException raise:@"Not implemented" format:@""];
    return 0;
}

@end
