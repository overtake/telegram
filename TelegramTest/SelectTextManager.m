//
//  SelectTextManager.m
//  Telegram
//
//  Created by keepcoder on 03.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectTextManager.h"


@interface SelectTextManager ()
@property (nonatomic,strong) NSMutableDictionary *keys;
@property (nonatomic,strong) NSMutableArray *list;
@property (nonatomic,strong) NSMutableArray *delegates;
@end

@implementation SelectTextManager


+(void)addSelectManagerDelegate:(id<SelectTextManagerDelegate>)delegate {
    [[[self instance] delegates] addObject:delegate];
}

+(void)removeSelectManagerDelegate:(id<SelectTextManagerDelegate>)delegate {
    [[[self instance] delegates] removeObject:delegate];
}

+(void)addRange:(NSRange)range forItem:(id<SelectTextDelegate>)item {
    
    if(item != nil) {
        [[[self instance] list] removeObject:item];
        
        [[[self instance] keys] removeObjectForKey:[item identifier]];
        
        if(range.location != NSNotFound) {
            [[[self instance] list] addObject:item];
            
            [[self instance] keys][[item identifier]] = [NSValue valueWithRange:range];
        }
    }
    
}

+(void)removeRangeForItem:(id<SelectTextDelegate>)item {
    
    [[[self instance] list] removeObject:item];
    [[[self instance] keys] removeObjectForKey:[item identifier]];
    
}

+(NSUInteger)count {
    return [[[self instance] list] count];
}


+(void)clear {
    [[[self instance] keys] removeAllObjects];
    [[[self instance] list] removeAllObjects];
    
    [[[self instance] delegates] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         [obj clearSelection];
    }];
}

+(NSRange)rangeForItem:(id<SelectTextDelegate>)item {
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    if([[self instance] keys][[item identifier]]) {
        range = [[[self instance] keys][[item identifier]] rangeValue];
    }
    
    return range;
}

+(void)enumerateItems:(void (^)(id obj, NSRange range))block {
    
    
    [[[self instance] list] sortUsingComparator:^NSComparisonResult(id<SelectTextDelegate> obj1, id<SelectTextDelegate> obj2) {
        return [[obj1 identifier] compare:[obj2 identifier]];
    }];
    
    
    [[[self instance] list] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        block(obj, [SelectTextManager rangeForItem:obj]);
        
    }];
    
}


+(NSString *)fullString {
    
    __block NSString *result = @"";
    
    [self enumerateItems:^(id obj, NSRange range) {
        result = [result stringByAppendingFormat:@"%@\n",[[obj string] substringWithRange:range]];
    }];
    
    result = [result substringToIndex:result.length -1];
    
    return result;
}


+(void)becomeFirstResponder {
   [[NSApp mainWindow] makeFirstResponder:[self instance]];
}


-(BOOL)respondsToSelector:(SEL)aSelector {
    
    
    if(aSelector == @selector(copy:)) {
        return [SelectTextManager count] > 0;
    }
    
    return [super respondsToSelector:aSelector];
}

-(void)copy:(id)sender {
    
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
        
    [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
        
        
    NSString *result = [SelectTextManager fullString];
        
    [cb setString:result forType:NSStringPboardType];
    
}

-(BOOL)resignFirstResponder {
    [SelectTextManager clear];
    
    return [super resignFirstResponder];
}


-(void)mouseDragged:(NSEvent *)theEvent {
    
}

+(id)instance {
    static const SelectTextManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SelectTextManager alloc] init];
        manager.keys = [[NSMutableDictionary alloc] init];
        manager.list = [[NSMutableArray alloc] init];
        manager.delegates = [[NSMutableArray alloc] init];
    });
    
    return manager;
}

@end
