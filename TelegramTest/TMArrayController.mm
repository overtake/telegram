//
//  TMArrayController.mm
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMArrayController.h"
#include <map>
#include <vector>

@interface TMArrayController()
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic) std::map<NSUInteger, id>* dictionaryObjects;

@end

@implementation TMArrayController

- (id)init {
    self = [super init];
    if(self) {
        self.list = [[NSMutableArray alloc] init];
        self.dictionaryObjects = new std::map<NSUInteger, id>();
        self.dictionaryObjects->clear();
    }
    return self;
}

- (void)dealloc {
    delete self.dictionaryObjects;
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.list objectAtIndex:index];
}

- (BOOL)insertObject:(id<TMArrayControllerObjectDelegate>)object {
    return [self insertObject:object atIndex:self.list.count];
}

- (BOOL)insertObject:(id<TMArrayControllerObjectDelegate>)object atIndex:(NSUInteger)atIndex {
    if(object == nil) {
        ELog(@"object is nil");
        return false;
    }
    
    return [self _insert:object atIndex:self.list.count tableRedraw:YES];
}

- (void)insertObjects:(NSArray*)objects {
    if(objects == nil)
        return ELog(@"objects is nil");
    
    NSUInteger location = self.list.count;
    NSUInteger count = objects.count;
    for(id<TMArrayControllerObjectDelegate> object in objects) {
        BOOL result = [self _insert:object atIndex:self.list.count tableRedraw:NO];
        if(!result)
            count--;
    }
    
    if(count) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, count)] withAnimation:NSTableViewAnimationEffectNone];
        [self.tableView endUpdates];
    }
    
}

- (BOOL)moveOrIsertToIndex:(id<TMArrayControllerObjectDelegate>)object newIndex:(NSUInteger)newIndex {
    std::map<NSUInteger, id>::iterator it = self.dictionaryObjects->find([object hash]);

    if(it == self.dictionaryObjects->end()) {
        return [self _insert:object atIndex:newIndex tableRedraw:YES];
    } else {
        id obj = it->second;
        NSUInteger pos = [self.list indexOfObject:obj];
        if(pos != NSNotFound && pos != newIndex) {
            [self.list removeObjectAtIndex:pos];
            [self.list insertObject:obj atIndex:newIndex];
            
            [self.tableView beginUpdates];
            [self.tableView moveRowAtIndex:pos toIndex:newIndex];
            [self.tableView endUpdates];
            return true;
        }
        return false;
    }
}

- (NSUInteger)count {
    return self.list.count;
}

- (void)dump {
    MTLog(@"arraycontroller  %@", self.list);
}

- (BOOL)_insert:(id<TMArrayControllerObjectDelegate>)object atIndex:(NSUInteger)atIndex tableRedraw:(BOOL)tableRedraw {
    
    NSUInteger hash = [object hash];
    std::map<NSUInteger, id>::iterator it = self.dictionaryObjects->find(hash);
    
    if(it != self.dictionaryObjects->end())
        return FALSE;
    
    self.dictionaryObjects->insert(std::pair<NSUInteger, id>([object hash], object));
    [self.list insertObject:object atIndex:atIndex];
    
    if(tableRedraw) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:atIndex] withAnimation:NSTableViewAnimationSlideUp];
        [self.tableView endUpdates];
    }
    
    return YES;
}

@end