//
//  DcAuthNew.m
//  Telegram
//
//  Created by keepcoder on 12.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGDcAuth.h"
#import "Crypto.h"
@implementation TGDcAuth
-(id)initWithDcId:(int)dc_id auth_key:(NSData *)auth_key server_salt:(NSData *)server_salt {
    if(self = [super init]) {
        self.dc_id = dc_id;
        self.auth_key = auth_key;
        self.auth_key_id = [[Crypto sha1:auth_key] subdataWithRange:NSMakeRange(12, 8)];
        self.imported = NO;
        self.server_salt = server_salt;
    }
    return self;
}
@end
