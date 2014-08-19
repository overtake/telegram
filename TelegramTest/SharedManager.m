//
//  SharedManager.m
//  TelegramTest
//
//  Created by keepcoder on 21.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SharedManager.h"
#import "RPCRequest.h"
#import "TLRPCApi.h"
#import "MessagesUtils.h"
@interface SharedManager ()

@end


@implementation SharedManager

static NSMutableArray *managers;


//clear manager
-(void)drop {
    [ASQueue dispatchOnStageQueue:^{
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
        self->list = [[NSMutableArray alloc]init];
        self->keys = [[NSMutableDictionary alloc] init];
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
    [ASQueue dispatchOnStageQueue:^{
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
    [ASQueue dispatchOnStageQueue:^{
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
    
    [ASQueue dispatchOnStageQueue:^{
        object = [self->keys objectForKey:[NSNumber numberWithInteger:_id]];
    } synchronous:YES];

    
    return object;
    
}

-(NSArray*)all {
    __block NSArray *object;
    
    [ASQueue dispatchOnStageQueue:^{
        object = self->list;
    } synchronous:YES];
    
    return object;
}


+(void)proccessGlobalResponse:(id)response {
    
    if([response respondsToSelector:@selector(messages)] &&  [response messages].count > 0) {
        
        [TL_localMessage convertReceivedMessages:[response messages]];
        
        
        [[MessagesManager sharedManager] add:[response messages]];
        [[Storage manager] insertMessages:[response messages]  completeHandler:nil];
    }
   
    if([response respondsToSelector:@selector(n_messages)] && [response n_messages].count > 0) {
        
        [TL_localMessage convertReceivedMessages:[response n_messages]];
        
        [[MessagesManager sharedManager] add:[response n_messages]];
        [[Storage manager] insertMessages:[response n_messages]  completeHandler:nil];
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
        
        instance = [[[self class] alloc] init];
        managers = [[NSMutableArray alloc] init];
    });
    return instance;
}

@end
