//
//  SharedManager.m
//  TelegramTest
//
//  Created by keepcoder on 21.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SharedManager.h"
#import "RPCRequest.h"
#import "TLApi.h"
#import "MessagesUtils.h"
@interface SharedManager ()

@end


@implementation SharedManager

static NSMutableArray *managers;


//clear manager
-(void)drop {
    [_queue dispatchOnQueue:^{
        [self->list removeAllObjects];
        [self->keys removeAllObjects];

    }];
}


+(void)drop {
    [ASQueue dispatchOnStageQueue:^{
        for (SharedManager *manager in managers) {
            [manager drop];
        }
    }];
}

-(id)init {
    if(self = [super init]) {
        
        [NSException raise:@"user initWithQueue" format:@""];
        
    }
    return self;
}

-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super init]) {
        self->list = [[NSMutableArray alloc]init];
        self->keys = [[NSMutableDictionary alloc] init];
        self->_queue = queue;
        
        [ASQueue dispatchOnStageQueue:^{
            
            [managers addObject:self];
            
        }];
    }
    return self;
}



-(void)add:(NSArray *)all {
    [self add:all withCustomKey:@"n_id"];
}

-(void)add:(NSArray *)all withCustomKey:(NSString*)key {
    [_queue dispatchOnQueue:^{
        for (id obj in all) {
            id current = [keys objectForKey:[obj valueForKey:key]];
            if(current == nil) {
                [self->list addObject:obj];
                [self->keys setObject:obj forKey:[obj valueForKey:key]];
            } else {
                [self->list removeObject:current];
                [self->list addObject:obj];
            }
            [self save:obj];
        }
    }];
}

-(void)remove:(NSArray*)all {
    [self remove:all withCustomKey:@"n_id"];
}

-(void)remove:(NSArray*)all withCustomKey:(NSString*)key {
    [_queue dispatchOnQueue:^{
        for (id obj in all) {
            [self removeObjectWithKey:[obj valueForKey:key]];
        }
    }];
}

-(void)removeObjectWithKey:(id)key {
    id current = [keys objectForKey:key];
    if(current != nil) {
        [self->list removeObject:current];
        [self->keys removeObjectForKey:key];
    }

}




-(void)save:(id)object {
    
}

-(id)find:(NSInteger)_id{
     return [self find:_id withCustomKey:@"n_id"];
}

-(id)find:(NSInteger)_id withCustomKey:(NSString*)key {
    __block id object;
    
    [_queue dispatchOnQueue:^{
        object = [self->keys objectForKey:[NSNumber numberWithInteger:_id]];
    } synchronous:YES];

    
    return object;
    
}

-(id)lastItem {
    __block id object;
    
    [_queue dispatchOnQueue:^{
        object = [self->list lastObject];
    } synchronous:YES];
    
    
    return object;
}

-(NSArray*)all {
    __block NSArray *object;
    
    [_queue dispatchOnQueue:^{
        object = self->list;
    } synchronous:YES];
    
    return object;
}


+(void)proccessGlobalResponse:(id)response {
    
    if([response respondsToSelector:@selector(messages)] &&  [response messages].count > 0) {
        
        [TL_localMessage convertReceivedMessages:[response messages]];
        
        [[Storage manager] insertMessages:[response messages]];
    }
   
    if([response respondsToSelector:@selector(n_messages)] && [response n_messages].count > 0) {
        
        [TL_localMessage convertReceivedMessages:[response n_messages]];
        
        [[Storage manager] insertMessages:[response n_messages]];
    }
    
    if([response respondsToSelector:@selector(users)] && [response users].count > 0) {
        [[UsersManager sharedManager] add:[response users]];
    }
   
    if([response respondsToSelector:@selector(chats)] && [response chats].count > 0) {
        [[ChatsManager sharedManager] add:[response chats]];
        [[Storage manager] insertChats:[response chats] completeHandler:nil];
    } 
}

+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
        managers = [[NSMutableArray alloc] init];
    });
    return instance;
}

-(NSArray *)searchWithString:(NSString *)search selector:(NSString *)selector {
    
   return [self->list filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
       
       if([evaluatedObject respondsToSelector:NSSelectorFromString(selector)]) {
           id value = [evaluatedObject valueForKey:selector];
           
           if([value isKindOfClass:NSString.class]) {
               
               return [value searchInStringByWordsSeparated:search];
               
           }
       }
       
       return NO;
       
   }]];
    
}

@end
