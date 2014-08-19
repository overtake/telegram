//
//  DcAuthNew.h
//  Telegram
//
//  Created by keepcoder on 12.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGDcAuth : NSObject

@property (nonatomic, strong) NSData * auth_key;
@property (nonatomic, strong) NSData * auth_key_id;
@property (nonatomic, assign) int dc_id;
@property (nonatomic, assign) int expired;
@property (nonatomic, assign) BOOL imported;
@property (nonatomic, strong) NSData * server_salt;
@property (nonatomic, assign) int user_id;


-(id)initWithDcId:(int)dc_id auth_key:(NSData *)auth_key server_salt:(NSData *)server_salt;
@end
