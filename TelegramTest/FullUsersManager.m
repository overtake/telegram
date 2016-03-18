//
//  FullUsersManager.m
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "FullUsersManager.h"
#import "TGMultipleRequestCallback.h"
@interface FullUsersManager ()
@property (nonatomic,strong) NSMutableDictionary *requests;
@property (nonatomic,strong) NSMutableDictionary *lastTimeCalled;
@end


@implementation TL_userFull (fullUser)

-(int)n_id {
    return self.user.n_id;
}

@end

@implementation FullUsersManager


-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super initWithQueue:queue]) {
        _requests = [[NSMutableDictionary alloc] init];
        _lastTimeCalled = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)requestUserFull:(TLUser *)user withCallback:(void (^) (TLUserFull *userFull))callback {
    
    
    int time = [_lastTimeCalled[@(user.n_id)] intValue];
    
    if(time > [[MTNetwork instance] getTime]) {
        TLUserFull *userFull = [self find:user.n_id];
        
        if(userFull && user.bot_info_version == userFull.user.bot_info_version)
        {
            if(callback) {
                callback(userFull);
            }
            return;
        }
        
    }
    
    TGMultipleRequestCallback *multiRequest = _requests[@(user.n_id)];
    
    if(!multiRequest) {
        RPCRequest *q = [RPCRequest sendRequest:[TLAPI_users_getFullUser createWithN_id:user.inputUser] successHandler:^(id request, TLUserFull *response) {
            
            if(![response isKindOfClass:[TL_userEmpty class]]) {
                
                [[UsersManager sharedManager] add:@[response.user]];
                
                [self add:@[response] withCustomKey:@"n_id"];
                
                if(user.dialog && user.dialog.notify_settings.mute_until != response.notify_settings.mute_until)  {
                    user.dialog.notify_settings = response.notify_settings;
                    [user.dialog save];
                }
            }
            
            [ASQueue dispatchOnMainQueue:^{
                [multiRequest.callbacks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    void (^callback) (TLUserFull *userFull) = obj;
                    callback(response);
                }];
                
                [_requests removeObjectForKey:@(user.n_id)];
                _lastTimeCalled[@(user.n_id)] = @([[MTNetwork instance] getTime] + 60*5);
            }];
            
            
        } errorHandler:^(id request, RpcError *error) {
            
        } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
        
        multiRequest = [[TGMultipleRequestCallback alloc] initWithRequest:q];
        
        _requests[@(user.n_id)] = multiRequest;
    }
    
    if(callback != nil) {
        [ASQueue dispatchOnMainQueue:^{
            [multiRequest.callbacks addObject:callback];
        }];
    }
    
    
}



+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}

-(void)drop {
    [super drop];
    [_lastTimeCalled removeAllObjects];
    [_requests removeAllObjects];
}


@end
