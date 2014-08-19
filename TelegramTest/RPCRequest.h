//
//  RPCStelMessage.h
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLClassStore.h"
#import "TLObject.h"
#import "RpcError.h"
#import <MTProtoKit/MTRequest.h>

@interface RPCRequest : NSObject

typedef enum StelMessageStatus : NSUInteger {
    kQueue,
    kWrited,
    kConfirmed
} StelMessageStatus;

@property (nonatomic, strong) RpcError *error;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MTRequest *mtrequest;
@property (nonatomic, assign) dispatch_queue_t queue;

typedef void (^RPCSuccessHandler)(RPCRequest *request, id response);
typedef void (^RPCErrorHandler)(RPCRequest *request, RpcError *error);

@property (nonatomic, copy) RPCSuccessHandler successHandler;
@property (nonatomic, copy) RPCErrorHandler errorHandler;

- (void)completeHandler;
- (void)cancelRequest;

+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler;

+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler timeout:(int)timeout;
+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler timeout:(int)timeout queue:(dispatch_queue_t)queue;

+ (id)sendRequest:(id)object forDc:(int)dc_id successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler;

+ (id)sendPollRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler;

+ (id)sendPollRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler queue:(dispatch_queue_t)queue;

@end
