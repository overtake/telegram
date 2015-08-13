//
//  TGKeychain.h
//  Telegram
//
//  Created by keepcoder on 06.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <MTProtoKit/MTKeychain.h>

@interface TGKeychain : NSObject<MTKeychain>
{
    @public
    bool _encrypted;
}
+ (instancetype)unencryptedKeychainWithName:(NSString *)name;
+ (instancetype)keychainWithName:(NSString *)name;
@property (nonatomic,assign) BOOL notEncryptedKeychain;

@property (nonatomic,assign,readonly) BOOL isNeedPasscode;

-(BOOL)updatePasscodeHash:(NSData *)md5Hash save:(BOOL)save;

-(NSData *)md5PasscodeHash;

-(void)storeAllKeychain;
-(void)loadIfNeeded;
-(void)cleanup;

-(BOOL)passcodeIsEnabled;

@end
