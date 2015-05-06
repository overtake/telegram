//
//  Crypto.m
//  TelegramTest
//
//  Created by keepcoder on 08.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "Crypto.h"
#include <openssl/opensslv.h>
#include <openssl/crypto.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/sha.h>
//#import <CommonCrypto/CommonCrypto.h>
#import <openssl/aes.h>
#import "NSMutableData+Extension.h"
#import <CommonCrypto/CommonDigest.h>
#import <openssl/md5.h>
#ifndef CC_SHA1_DIGEST_LENGTH
#define CC_SHA1_DIGEST_LENGTH   20 
#endif
#define MD5(data, len, md)      CC_MD5(data, len, md)
@implementation Crypto


+(NSData *)encryptRSA:(NSData *)data {
//    NSString * path = [[NSBundle mainBundle] pathForResource:  @"public" ofType: @"pem"];
//    FILE *f = fopen([path cStringUsingEncoding:1],"r");
    
//    RSA *rsa = PEM_read_RSAPublicKey(f, NULL, NULL, NULL);
    
//    fclose(f);
    
    
    BIGNUM *rsaData = BN_new();
    //BN_init(rsaData);
    
    
    
    BN_bin2bn(data.bytes, (int) data.length, rsaData);
    
    BN_CTX *ctx = BN_CTX_new();
    BN_CTX_start(ctx);
    
    //r=a^p % m
    
    
    BIGNUM *n = BN_new();
    //BN_init(n);
//    BN_ULONG d1 = *rsa->n->d;
//    n->d = &d1;
    n->top = 32;
    n->dmax = 33;
    n->neg = 0;
    n->flags = 1;
    
    BN_ULONG *d3 = malloc(sizeof(BN_ULONG)*n->dmax);
    d3[0] = 10395111211086193951ULL;
    d3[1] = 6662319611841024783;
    d3[2] = 6628333346495617466;
    d3[3] = 6524491590466922314;
    d3[4] = 6269885011800246993;
    d3[5] = 18234425716843375146ULL;
    d3[6] = 10508904865630789108ULL;
    d3[7] = 7649418252262812007;
    d3[8] = 1685804625966146911;
    d3[9] = 9294047210043899634ULL;
    d3[10] = 7309953827389464054;
    d3[11] = 9300014802072883830ULL;
    d3[12] = 10943106110983555679ULL;
    d3[13] = 11123625291085217462ULL;
    d3[14] = 18222927717086533998ULL;
    d3[15] = 17255574435431510033ULL;
    d3[16] = 10875286308575865140ULL;
    d3[17] = 6470245153086005100;
    d3[18] = 18369357421989564864ULL;
    d3[19] = 11432417909540706047ULL;
    d3[20] = 9182183291283654015;
    d3[21] = 17682046848821793386ULL;
    d3[22] = 10023117398171324632ULL;
    d3[23] = 6341684979735976284;
    d3[24] = 206615053260332878;
    d3[25] = 1151868498183751241;
    d3[26] = 2363885330344887656;
    d3[27] = 2274189349598378647;
    d3[28] = 15487909163991148281ULL;
    d3[29] = 789019330615565044;
    d3[30] = 9646376581762711247ULL;
    d3[31] = 13929636113564097401ULL;
    d3[32] = 0;
    n->d = d3;
   
    
    
    BIGNUM *e = BN_new();
    //BN_init(e);
    e->top = 1;
    e->dmax = 1;
    e->neg = 0;
    e->flags = 1;
    BN_ULONG *de = malloc(sizeof(BN_ULONG)*n->dmax);
    de[0] = 65537;
    e->d = de;

    
    BN_mod_exp(rsaData, rsaData, e, n, ctx);
    
//    MTLog(@"ros %llu %d %d %d %d", *n->d, n->dmax, n->flags, n->neg, n->top);

    
    BN_CTX_free(ctx);
    
//    BN_free(e);
    BN_clear_free(e);
    BN_clear_free(n);
    
//    BIGNUM *rsaDataNew = BN_new();
//    //BN_init(rsaDataNew);
//    unsigned long long d3 = 3905792911502590708;
//    *rsaData->d = 3905792911502590708;
//    rsaData->top = 32;
//    rsaData->dmax = 32;
//    rsaData->neg = 0;
//    rsaData->flags = 0;
    
//    MTLog(@"ros %llu %d %d %d %d", *rsaData->d, rsaData->dmax, rsaData->flags, rsaData->neg, rsaData->top);

    return [self getBytes:rsaData];
}


+(NSData *)aesDecrypt:(NSData *)data tmp_aes_key:(NSData *)tmp_aes_key tmp_aes_iv:(NSData *)tmp_aes_iv  {
    
    AES_KEY aes;
    AES_set_decrypt_key(tmp_aes_key.bytes, 256, &aes);
    
    int length = (int)data.length;
    
  //  unsigned char result[length];
    
    uint8_t *result = malloc(data.length);
    

    
   
    uint8_t iv[32];
    [tmp_aes_iv getBytes:iv length:32];
    
    
    
    
    AES_ige_encrypt(data.bytes, result, length, &aes,  iv, AES_DECRYPT);
    return [[NSData alloc] initWithBytesNoCopy:result length:data.length freeWhenDone:true];
}



+(NSData *)aesEncrypt:(NSData *)data tmp_aes_key:(NSData *)tmp_aes_key tmp_aes_iv:(NSData *)tmp_aes_iv  {
    AES_KEY aes;
    AES_set_encrypt_key(tmp_aes_key.bytes, 256, &aes);
    
    uint8_t *result = malloc(data.length);
    uint8_t iv[32];
    [tmp_aes_iv getBytes:iv length:32];
    
    AES_ige_encrypt(data.bytes, result, data.length, &aes, iv, AES_ENCRYPT);
    return [[NSData alloc] initWithBytesNoCopy:result length:data.length freeWhenDone:true];
}

+(NSData *)aesEncryptModify:(NSData *)data key:(NSData *)key iv:(NSMutableData *)iv encrypt:(BOOL)encrypt {
    
    AES_KEY aes;
    if (encrypt)
        AES_set_encrypt_key(key.bytes, 256, &aes);
    else
        AES_set_decrypt_key(key.bytes, 256, &aes);
    
    uint8_t *result = malloc(data.length);
    
    AES_ige_encrypt(data.bytes, result, data.length, &aes,iv.mutableBytes,encrypt ? AES_ENCRYPT : AES_DECRYPT);
    return [[NSData alloc] initWithBytesNoCopy:result length:data.length freeWhenDone:true];

}



+(NSData *)sha1:(NSData *)from {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    SHA1(from.bytes, from.length, digest);
    
    NSMutableData *unencrypted = [NSMutableData dataWithBytes:digest length:sizeof(digest)];
    return unencrypted;
}


+(NSData *)shaL1:(NSData *)from, ... {
    va_list args;
    va_start(args, from);
    
    NSMutableData *sha = [[NSMutableData alloc] init];
    
    for (NSData *arg = from; arg != nil; arg = va_arg(args, NSData*))
    {
        [sha appendData:arg];
    }
    va_end(args);
    
    return [self sha1:sha];
}


+(NSData *)getBytes:(BIGNUM *)n {
    unsigned char bytes[BN_num_bytes(n)];
    BN_bn2bin(n, bytes);
    
    NSData *result = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    //fee
    BN_clear_free(n);
    return result;
}

+(NSData *)authKey:(NSData *)gA b:(NSData *)b dhPrime:(NSData *)dhPrime {
    BIGNUM *bn_auth_key = BN_new();
    //BN_init(bn_auth_key);
    
    BIGNUM *bn_gA = BN_new();
    //BN_init(bn_gA);
    
    BIGNUM *bn_b = BN_new();
    //BN_init(bn_b);
    
    BIGNUM *bn_dhPrime = BN_new();
    //BN_init(bn_dhPrime);
    
    BN_bin2bn(dhPrime.bytes, (int) dhPrime.length, bn_dhPrime);

    
    BN_bin2bn(gA.bytes, (int) gA.length, bn_gA);
    
    
    BN_bin2bn(b.bytes, (int) b.length, bn_b);
    
    
    BN_CTX *ctx = BN_CTX_new();
    BN_CTX_start(ctx);
    
    //r=a^p % m
    //(g_a)^b mod dh_prime.
    BN_mod_exp(bn_auth_key, bn_gA, bn_b, bn_dhPrime, ctx);
    
    BN_CTX_free(ctx);
    
    BN_clear_free(bn_gA);
    BN_clear_free(bn_b);
    BN_clear_free(bn_dhPrime);
    
    return [self getBytes:bn_auth_key];

}

+(NSData *)xorAB:(NSData *)a b:(NSData *)b {
    NSMutableData *copy = [a mutableCopy];
    
    for (int i = 0; i < (int)copy.length && i < (int)b.length; i++)
    {
        ((uint8_t *)copy.mutableBytes)[i] ^= ((uint8_t *)b.bytes)[i];
    }
    
    return copy;
    
}

+(NSData *)exp:(NSData *)g b:(NSData *)b dhPrime:(NSData *)dhPrime {
    BIGNUM *bn_gb = BN_new();
    //BN_init(bn_gb);
    
    BIGNUM *bn_g = BN_new();
    //BN_init(bn_g);
    
    BIGNUM *bn_b = BN_new();
    //BN_init(bn_b);
    
    BIGNUM *bn_dhPrime = BN_new();
    //BN_init(bn_dhPrime);
    

    
    BN_bin2bn(dhPrime.bytes, (int) dhPrime.length, bn_dhPrime);
    BN_bin2bn(g.bytes, (int) g.length, bn_g);
    BN_bin2bn(b.bytes, (int) b.length, bn_b);
    
    
    BN_CTX *ctx = BN_CTX_new();
    BN_CTX_start(ctx);
    
    //r=a^p % m
    //g_b := pow(g, b) mod dh_prime;
    BN_mod_exp(bn_gb, bn_g, bn_b, bn_dhPrime, ctx);

    BN_CTX_free(ctx);
    
    BN_clear_free(bn_g);
    BN_clear_free(bn_b);
    BN_clear_free(bn_dhPrime);
    
    
    return [self getBytes:bn_gb];
}


+(NSData *)md5:(NSData *)data
{
    unsigned char digest[MD5_DIGEST_LENGTH];
    
    MD5([data bytes], (int)[data length], digest);
    
    return [NSData dataWithBytes:&digest length:MD5_DIGEST_LENGTH];
}


+(NSData *)encrypt:(int)x data:(NSData *)data auth_key:(NSData *)auth_key msg_key:(NSData *)msg_key encrypt:(BOOL)encrypt {
    
    
   NSData *sha1_a = [Crypto shaL1:msg_key,[auth_key subdataWithRange:NSMakeRange(x, 32)],nil];
    NSData *sha1_b = [Crypto shaL1:[auth_key subdataWithRange:NSMakeRange(32+x, 16)],msg_key,[auth_key subdataWithRange:NSMakeRange(48+x, 16)],nil];
    NSData *sha1_c = [Crypto shaL1:[auth_key subdataWithRange:NSMakeRange(64+x, 32)],msg_key,nil];
    NSData *sha1_d = [Crypto shaL1:msg_key,[auth_key subdataWithRange:NSMakeRange(96+x, 32)],nil];
    
    NSMutableData *aes_key = [[NSMutableData alloc] init];
    [aes_key appendData:[sha1_a subdataWithRange:NSMakeRange(0, 8)]];
    [aes_key appendData:[sha1_b subdataWithRange:NSMakeRange(8, 12)]];
    [aes_key appendData:[sha1_c subdataWithRange:NSMakeRange(4, 12)]];
    
    NSMutableData *aes_iv = [[NSMutableData alloc] init];
    [aes_iv appendData:[sha1_a subdataWithRange:NSMakeRange(8, 12)]];
    [aes_iv appendData:[sha1_b subdataWithRange:NSMakeRange(0,8)]];
    [aes_iv appendData:[sha1_c subdataWithRange:NSMakeRange(16, 4)]];
    [aes_iv appendData:[sha1_d subdataWithRange:NSMakeRange(0, 8)]];
    
    NSData *encrypted_data;
    if(encrypt) {
        encrypted_data = [Crypto aesEncrypt:[[data mutableCopy] addPadding:16] tmp_aes_key:aes_key tmp_aes_iv:aes_iv];
    } else {
        encrypted_data = [Crypto aesDecrypt:[data mutableCopy] tmp_aes_key:aes_key tmp_aes_iv:aes_iv];

    }
    return encrypted_data;
}

NSData *computeSHA1ForSubdata(NSData *data, int offset, int length)
{
    uint8_t digest[20];
    SHA1(data.bytes + offset, length, digest);
    
    NSData *result = [[NSData alloc] initWithBytes:digest length:20];
    return result;
}


@end
