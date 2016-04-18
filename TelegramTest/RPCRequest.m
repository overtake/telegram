//
//  RPCStelMessage.m
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "RPCRequest.h"
#import "CMath.h"
#import "MTNetwork.h"
#import "RpcErrorParser.h"
@implementation RPCRequest

- (id)init {
    self = [super init];
    if(self) {

    }
    return self;
}

+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler timeout:(int)timeout {
    
    RPCRequest *request = [self sendRequest:object successHandler:successHandler errorHandler:errorHandler];

    if(timeout > 0) {
        request.timer = [NSTimer timerWithTimeInterval:timeout target:request selector:@selector(timeoutInterval:) userInfo:request repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:request.timer forMode:NSRunLoopCommonModes];
    }
   
    
    return request;
}

+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler timeout:(int)timeout queue:(dispatch_queue_t)queue {
    RPCRequest *request = [self sendRequest:object successHandler:successHandler errorHandler:errorHandler timeout:timeout];
    request.queue = queue;
    
    return request;
}

+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler timeout:(int)timeout queue:(dispatch_queue_t)queue alwayContinueWithErrorContext:(BOOL)alwayContinueWithErrorContext {
    RPCRequest *request = [self sendRequest:object successHandler:successHandler errorHandler:errorHandler timeout:timeout];
    request.queue = queue;
    request.alwayContinueWithErrorContext = alwayContinueWithErrorContext;
    return request;
}

- (void)timeoutInterval:(NSTimer *)timer {
    RPCRequest *request = [timer userInfo];
    request.error = [[RpcError alloc] init];
    request.error.error_msg = @"Error, request timeout, try again";
    request.error.error_code = 502;
    [[MTNetwork instance] cancelRequest:request];
    [self completeHandler];
}

- (void)cancelRequest {
    self.successHandler = nil;
    self.errorHandler = nil;
    [self.timer invalidate];
    self.timer = nil;
    self.response = nil;
     [[MTNetwork instance] cancelRequest:self];
}

+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler {
    
    RPCRequest *message = [[RPCRequest alloc] init];
    message.object = object;
    message.successHandler = successHandler;
    message.errorHandler = errorHandler;
    
    [[MTNetwork instance] sendRequest:message];
    
    return message;
    
}

+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler alwayContinueWithErrorContext:(BOOL)alwayContinueWithErrorContext {
    RPCRequest *message = [[RPCRequest alloc] init];
    message.object = object;
    message.alwayContinueWithErrorContext = alwayContinueWithErrorContext;
    message.successHandler = successHandler;
    message.errorHandler = errorHandler;
    
    [[MTNetwork instance] sendRequest:message];
    
    return message;
}


+(id)sendRequest:(id)object forDc:(int)dc_id successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler {
        
    
    RPCRequest *message = [[RPCRequest alloc] init];
    message.object = object;
    message.successHandler = successHandler;
    message.errorHandler = errorHandler;
    
    [[MTNetwork instance] sendRequest:message forDatacenter:dc_id];
    
    return message;
}


+ (id)sendRequest:(id)object forDc:(int)dc_id successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler queue:(dispatch_queue_t)queue {
    
    RPCRequest *request = [self sendRequest:object forDc:dc_id successHandler:successHandler errorHandler:errorHandler];
    
    request.queue = queue;
    
    return request;
}



+ (id)sendPollRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler {
    return [self sendPollRequest:object successHandler:successHandler errorHandler:errorHandler queue:dispatch_get_main_queue()];
}

+ (id)sendPollRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler queue:(dispatch_queue_t)queue {
    
    RPCRequest *message = [[RPCRequest alloc] init];
    message.object = object;
    message.successHandler = successHandler;
    message.errorHandler = errorHandler;
    message.queue = queue;
    
    [[MTNetwork instance] sendRandomRequest:message];

    return message;
}

- (void)dealloc {
    self.mtrequest = nil;
    self.object = nil;
    self.successHandler = nil;
    self.errorHandler = nil;
}

- (void)completeHandler {
    
    if(!self.queue) {
        self.queue = dispatch_get_main_queue();
    }
    
    
    dispatch_block_t block = ^{
        if([self.response isKindOfClass:[RpcError class]]) {
            self.error = self.response;
            self.response = nil;
        }
        
        if(self.response) {
            if(self.successHandler != nil) {
                self.successHandler(self, self.response);
                
            }
        } else {
            if(self.errorHandler != nil) {
                
                if( self.error.error_code == 401)
                {
                    if(![self.error.error_msg isEqualToString:@"SESSION_PASSWORD_NEEDED"]) {
                        
                        [[Telegram delegate] logoutWithForce:YES];
                        
                    }
                } else if( self.error.error_code == 303 && ([self.error.error_msg hasPrefix:@"PHONE_MIGRATE"] || [self.error.error_msg hasPrefix:@"NETWORK_MIGRATE"] || [self.error.error_msg hasPrefix:@"USER_MIGRATE"])) {
                    
                    [[MTNetwork instance] setDatacenter:self.error.resultId];
                    [[MTNetwork instance] initConnectionWithId:self.error.resultId];
                } else if([self.error.error_msg isEqualToString:@"PEER_FLOOD"]) {
                    
                    
                    NSString *localizedKey = nil;
                    
                    static NSDictionary *keys;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        keys = @{NSStringFromClass([TLAPI_messages_sendMessage class]):NSLocalizedString(@"PEER_FLOOD_MESSAGES", nil),NSStringFromClass([TLAPI_messages_sendMedia class]):NSLocalizedString(@"PEER_FLOOD_MESSAGES", nil),NSStringFromClass([TLAPI_messages_sendMedia class]):NSLocalizedString(@"PEER_FLOOD_MESSAGES", nil)};
                    });
                    
                    localizedKey = keys[NSStringFromClass([self.object class])];
                    
                    if(localizedKey) {
                        [ASQueue dispatchOnMainQueue:^{
                            
                            NSAlert *alert = [NSAlert alertWithMessageText:appName() informativeText:localizedKey block:^(id result) {
                                if([result intValue] != 1000) {
                                    
                                    open_user_by_name(@{@"domain":@"spambot"});
                                }
                            }];
                            [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
                            [alert addButtonWithTitle:NSLocalizedString(@"Alert.MoreInfo", nil)];
                            [alert show];
                        }];
                    }
                    
                   
                    
                    
                } else {
                    MTLog(@"%@",self.error.error_msg);
                }
                
                self.errorHandler(self, self.error);
                
                
                if(self.error.error_code == 502) {
                   // alert(NSLocalizedString(@"App.ConnectionError", nil), NSLocalizedString(@"App.ConnectionErrorDesc", nil));
                }
                
            }
        }
    };
    
    
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.timer invalidate];
        self.timer = nil;
    }];
   
    if(self.queue != dispatch_get_current_queue()) {
        dispatch_async(self.queue, block);
    } else {
        block();
    }
}



@end
