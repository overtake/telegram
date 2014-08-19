//
//  TMArrayController.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMTableView.h"

@protocol TMArrayControllerObjectDelegate <NSObject>
- (NSUInteger)hash;
@end

@interface TMArrayController : NSObject
@property (nonatomic, strong) TMTableView *tableView;

- (id)objectAtIndex:(NSUInteger)index;
- (BOOL)insertObject:(id<TMArrayControllerObjectDelegate>)object;
- (BOOL)insertObject:(id<TMArrayControllerObjectDelegate>)object atIndex:(NSUInteger)atIndex;
- (void)insertObjects:(NSArray*)objects;
- (BOOL)moveOrIsertToIndex:(id<TMArrayControllerObjectDelegate>)object newIndex:(NSUInteger)newIndex;
- (NSUInteger)count;
- (void)dump;
@end
