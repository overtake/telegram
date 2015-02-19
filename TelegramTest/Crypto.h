//
//  Crypto.h
//  TelegramTest
//
//  Created by keepcoder on 08.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crypto : NSObject
+(NSData *)encryptRSA:(NSData *)data;
+(NSData *)sha1:(NSData *)from;
+(NSData *)aesDecrypt:(NSData *)data tmp_aes_key:(NSData *)tmp_aes_key tmp_aes_iv:(NSData *)tmp_aes_iv;
+(NSData *)aesEncrypt:(NSData *)data tmp_aes_key:(NSData *)tmp_aes_key tmp_aes_iv:(NSData *)tmp_aes_iv;
+(NSData *)aesEncryptModify:(NSData *)data key:(NSData *)key iv:(NSMutableData *)iv encrypt:(BOOL)encrypt;
+(NSData *)shaL1:(NSData *)from, ...;
+(NSData *)exp:(NSData *)g b:(NSData *)b dhPrime:(NSData *)dhPrime;
+(NSData *)authKey:(NSData *)gA b:(NSData *)b dhPrime:(NSData *)dhPrime;
+(NSData *)xorAB:(NSData *)a b:(NSData *)b;
+(NSData *)encrypt:(int)x data:(NSData *)data auth_key:(NSData *)auth_key msg_key:(NSData *)msg_key encrypt:(BOOL)encrypt;
+(NSData *)md5:(NSData *)data;

NSData *computeSHA1ForSubdata(NSData *data, int offset, int length);

@end
