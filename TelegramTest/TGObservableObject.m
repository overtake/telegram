//
//  TGObservableObject.m
//  Telegram
//
//  Created by keepcoder on 24.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGObservableObject.h"

@interface TGObservableObject ()
@property (nonatomic,strong) NSMutableArray *observers;
@end

@implementation TGObservableObject


-(instancetype)init {
    if(self = [super init]) {
        _observers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addEventListener:(id <TGObservableDelegate>)listener {
    if([_observers indexOfObject:listener] == NSNotFound && [listener conformsToProtocol:@protocol(TGObservableDelegate)]) {
        [_observers addObject:listener];
    }
        
}

-(void)removeEventListener:(id)listener {
    [_observers removeObject:listener];
}


-(void)addWeakEventListener:(id <TGObservableDelegate>)listener {
    if([_observers indexOfObject:listener] == NSNotFound && [listener conformsToProtocol:@protocol(TGObservableDelegate)]) {
        NSValue *value = [NSValue valueWithNonretainedObject:listener];
        
        [_observers addObject:value];
        
                
    }
}

-(void)notifyListenersWithObject:(id)object {
    [_observers enumerateObjectsUsingBlock:^(id <TGObservableDelegate> observer, NSUInteger idx, BOOL *stop) {
        
        [observer didChangedEventStateWithObject:object];
        
    }];
}


@end
