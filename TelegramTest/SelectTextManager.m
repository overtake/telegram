//
//  SelectTextManager.m
//  Telegram
//
//  Created by keepcoder on 03.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectTextManager.h"
#import "MessageTableItem.h"

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
    
    __block int sliceCount = 1;
    
    __block BOOL needSelectMessages = [[self instance] list].count > 1;
    
    
    [self enumerateItems:^(id obj, NSRange range) {
        
        if(needSelectMessages)
            needSelectMessages = [obj isKindOfClass:[MessageTableItem class]];
        
        result = [result stringByAppendingFormat:@"%@\n",[[obj string] substringWithRange:range]];
    }];
    
    if(needSelectMessages)
        return [self selectMessagesText];
    
    result = [result substringToIndex:result.length - sliceCount];
    
    return result;
}

+(NSString *)selectMessagesText {
    
    __block NSString *result = @"";
    
    __block MessageTableItem *lastItem;
    
    __block int lastUserId = 0;
    __block BOOL header = YES;
    
    [self enumerateItems:^(MessageTableItem *item, NSRange range) {
        
        if(!lastItem)
            lastItem = item;
        
        header = item.user.n_id != lastUserId || item.isHeaderMessage;
        
        if(header)
            result = [result stringByAppendingFormat:@"%@, [%@]: \n",item.user.fullName,item.fullDate];
        
        lastUserId = item.user.n_id;
        
        
        result = [result stringByAppendingFormat:@"%@%@%@\n\n",range.location != 0 ? @"..." : @"", [[item string] substringWithRange:range],range.location + range.length != item.string.length ? @"..." : @""];
    }];
    
    result = [result substringToIndex:result.length - 2];
    
    
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
