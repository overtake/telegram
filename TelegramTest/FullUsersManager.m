//
//  FullUsersManager.m
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "FullUsersManager.h"


@implementation TL_userFull (fullUser)

-(int)n_id {
    return self.user.n_id;
}

@end

@implementation FullUsersManager


-(void)loadUserFull:(TL_user *)user callback:(void (^)(TL_userFull *userFull))callback  {
    
    
    TL_userFull *userFull = [self find:user.n_id];
    
    if(userFull) {
       // [ASQueue dispatchOnMainQueue:^{
            callback(userFull);
      //  }];
        
        return;
    }
    
    [ASQueue dispatchOnStageQueue:^{
        
          [RPCRequest sendRequest:[TLAPI_users_getFullUser createWithN_id:user.inputUser] successHandler:^(id request, id response) {
                
                
              if(![response isKindOfClass:[TL_userEmpty class]])
                  [self add:@[response] withCustomKey:@"n_id"];
                
              [ASQueue dispatchOnMainQueue:^{
                  callback(response);
              }];
                
        } errorHandler:^(id request, RpcError *error) {
                
        } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
        
    }];
    
}




+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}


@end
