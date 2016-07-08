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

-(SSignal *)add:(NSArray *)all autoStart:(BOOL)autoStart {
    return [self add:all withCustomKey:@"n_id" autoStart:autoStart];
}

-(SSignal *)add:(NSArray *)all {
    return [self add:all withCustomKey:@"n_id" autoStart:YES];
}

-(SSignal *)add:(NSArray *)all withCustomKey:(NSString*)key {
    return [self add:all withCustomKey:key autoStart:YES];
}

-(SSignal *)add:(NSArray *)all withCustomKey:(NSString*)key autoStart:(BOOL)autoStart {
    
    SSignal *signal = [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        __block BOOL dispose = NO;
        
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
            
            if(dispose)
                break;
        }
        
        [subscriber putNext:nil];
        
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            dispose = YES;
        }];
    }] startOn:self.queue];
    
    
    if(autoStart)
        [signal startWithNext:^(id next) {
            
        }];
    
    
    return signal;
}

-(SSignal *)search:(NSString *)query {
    return [SSignal single:nil];
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
        [[[UsersManager sharedManager] add:[response users] autoStart:NO] startWithNext:^(id next) {
            [[Storage manager] insertUsers:next];
        }];
    }
   
    if([response respondsToSelector:@selector(chats)] && [response chats].count > 0) {
        [[[ChatsManager sharedManager] add:[response chats] autoStart:NO] startWithNext:^(id next) {
            [[Storage manager] insertChats:next];
        }];
        
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
    return [self searchWithString:search selector:selector checker:nil];
}

-(NSArray *)searchWithString:(NSString *)search selector:(NSString *)selector checker:(BOOL (^)(id object))checker {
    
   return [self->list filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
       
       NSArray *selectors = [selector componentsSeparatedByString:@" "];
       
       
       __block BOOL match = NO;
       if(!checker || checker(evaluatedObject)) {
           [selectors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               if([evaluatedObject respondsToSelector:NSSelectorFromString(obj)]) {
                   
                   id value = [evaluatedObject valueForKey:obj];
                   
                   if([value isKindOfClass:NSString.class]) {
                       
                       match = [value searchInStringByWordsSeparated:search];
                       
                       if(match) {
                           *stop = YES;
                       }
                       
                   }
               }
            }];
        }
       
       return match;
       
       
   }]];
    
}

@end
