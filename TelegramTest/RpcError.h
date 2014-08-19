//
//  RpcError.h
//  TelegramTest
//
//  Created by keepcoder on 15.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RpcError : NSObject

typedef enum {
  PHONE_MIGRATE_X = 303,
} RPC_ERROR_CODE;

@property (nonatomic,strong) NSString *error_msg;
@property (nonatomic,assign) int error_code;
@property (nonatomic,assign) int resultId;
@end
