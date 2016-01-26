//
//  RPC.h
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLObject.h"
#import "RpcError.h"
#import <MTProtoKit/MTRequest.h>
@interface RPC : NSObject


@property (nonatomic, strong) RpcError *error;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MTRequest *mtrequest;
@property (nonatomic, assign) dispatch_queue_t queue;

@property (nonatomic, assign) BOOL alwayContinueWithErrorContext;

typedef void (^RPCSuccessHandler)(id request, id response);
typedef void (^RPCErrorHandler)(id request, RpcError *error);

@property (nonatomic, strong) RPCSuccessHandler successHandler;
@property (nonatomic, strong) RPCErrorHandler errorHandler;

- (void)completeHandler;
- (void)cancelRequest;

+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler;
+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler alwayContinueWithErrorContext:(BOOL)alwayContinueWithErrorContext;
+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler timeout:(int)timeout;
+ (id)sendRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler timeout:(int)timeout queue:(dispatch_queue_t)queue;

+ (id)sendRequest:(id)object forDc:(int)dc_id successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler;
+ (id)sendRequest:(id)object forDc:(int)dc_id successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler queue:(dispatch_queue_t)queue;

+ (id)sendPollRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler;

+ (id)sendPollRequest:(id)object successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler queue:(dispatch_queue_t)queue;

@end
