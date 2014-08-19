//
//  RpcErrorParser.h
//  TelegramTest
//
//  Created by keepcoder on 15.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RpcError.h"
@interface RpcErrorParser : NSObject
+(RpcError *)parseRpcError:(TL_rpc_error *)error;
@end
