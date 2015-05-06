//
//  RpcErrorParser.h
//  TelegramTest
//
//  Created by keepcoder on 15.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RpcError.h"
#import <MTProtoKit/MTRpcError.h>
@interface RpcErrorParser : NSObject
+(RpcError *)parseRpcError:(MTRpcError *)error;
@end
