/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */


#import "TGKeychain.h"
#import <pthread.h>
#import "NSData+Extensions.h"
#import "NSMutableData+Extension.h"
#define TG_SYNCHRONIZED_DEFINE(lock) pthread_mutex_t _TG_SYNCHRONIZED_##lock
#define TG_SYNCHRONIZED_INIT(lock) pthread_mutex_init(&_TG_SYNCHRONIZED_##lock, NULL)
#define TG_SYNCHRONIZED_BEGIN(lock) pthread_mutex_lock(&_TG_SYNCHRONIZED_##lock);
#define TG_SYNCHRONIZED_END(lock) pthread_mutex_unlock(&_TG_SYNCHRONIZED_##lock);

#import <CommonCrypto/CommonCrypto.h>
#import <MTProtoKit/MTEncryption.h>

static TG_SYNCHRONIZED_DEFINE(_keychains) = PTHREAD_MUTEX_INITIALIZER;
static NSMutableDictionary *keychains()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      TG_SYNCHRONIZED_INIT(_keychains);
                      dict = [[NSMutableDictionary alloc] init];
                  });
    return dict;
}

@interface TGKeychain ()
{
    NSString *_name;
    bool _encrypted;
    NSData *_aesKey;
    NSData *_aesIv;
    NSData *_passcodeHash;
    dispatch_semaphore_t _semaphore;
    TG_SYNCHRONIZED_DEFINE(_dictByGroup);
    NSMutableDictionary *_dictByGroup;
}

@end

@implementation TGKeychain

+ (instancetype)unencryptedKeychainWithName:(NSString *)name
{
    if (name == nil)
        return nil;
    
    TG_SYNCHRONIZED_BEGIN(_keychains);
    TGKeychain *keychain = [keychains() objectForKey:name];
    if (keychain == nil)
    {
        keychain = [[TGKeychain alloc] initWithName:name encrypted:false];
        [keychains() setObject:keychain forKey:name];
    }
    TG_SYNCHRONIZED_END(_keychains);
    
    return keychain;
}


+ (instancetype)keychainWithName:(NSString *)name
{
    if (name == nil)
        return nil;
    
    TG_SYNCHRONIZED_BEGIN(_keychains);
    TGKeychain *keychain = [keychains() objectForKey:name];
    if (keychain == nil)
    {
        keychain = [[TGKeychain alloc] initWithName:name encrypted:true];
        [keychains() setObject:keychain forKey:name];
    }
    TG_SYNCHRONIZED_END(_keychains);
    
    return keychain;
}

- (instancetype)initWithName:(NSString *)name encrypted:(bool)encrypted
{
    self = [super init];
    if (self != nil)
    {
        TG_SYNCHRONIZED_INIT(_dictByGroup);
        _dictByGroup = [[NSMutableDictionary alloc] init];
        _passcodeHash = [[NSData alloc] initWithEmptyBytes:64];
        _name = name;
        _encrypted = encrypted;
        
        if (name != nil)
        {
            if (_encrypted)
            {
                NSMutableDictionary *keychainReadQuery = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                           (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                                                                           (__bridge id)kSecAttrService: @"org.mtproto.MTKeychain",
                                                                                                           (__bridge id)kSecAttrAccount: [[NSString alloc] initWithFormat:@"MTKeychain:%@", name],
#if TARGET_OS_IPHONE
                                                                                                           (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly,
#endif
                                                                                                           (__bridge id)kSecReturnData: (id)kCFBooleanTrue,
                                                                                                           (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
                                                                                                           }];
                
                bool upgradeEncryption = false;
                
                CFDataRef keyData = NULL;
                if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainReadQuery, (CFTypeRef *)&keyData) == noErr && keyData != NULL)
                {
                    NSData *data = (__bridge_transfer NSData *)keyData;
                    if (data.length == 64)
                    {
                        _aesKey = [data subdataWithRange:NSMakeRange(0, 32)];
                        _aesIv = [data subdataWithRange:NSMakeRange(32, 32)];
                    }
                }
                else
                {
                    keychainReadQuery[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
                    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainReadQuery, (CFTypeRef *)&keyData) == noErr && keyData != NULL)
                    {
                        NSData *data = (__bridge_transfer NSData *)keyData;
                        if (data.length == 64)
                        {
                            upgradeEncryption = true;
                            
                            _aesKey = [data subdataWithRange:NSMakeRange(0, 32)];
                            _aesIv = [data subdataWithRange:NSMakeRange(32, 32)];
                        }
                    }
                }
                
                bool storeKey = upgradeEncryption || _aesKey == nil || _aesIv == nil;
                
                if (_aesKey == nil || _aesIv == nil)
                {
                    uint8_t buf[32];
                    
                    SecRandomCopyBytes(kSecRandomDefault, 32, buf);
                    _aesKey = [[NSData alloc] initWithBytes:buf length:32];
                    
                    SecRandomCopyBytes(kSecRandomDefault, 32, buf);
                    _aesIv = [[NSData alloc] initWithBytes:buf length:32];
                }
                
                NSMutableData *newKeyData = [[NSMutableData alloc] init];
                [newKeyData appendData:_aesKey];
                [newKeyData appendData:_aesIv];
                
                if (storeKey)
                {
                    SecItemDelete((__bridge CFDictionaryRef)@{
                                                              (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                              (__bridge id)kSecAttrService: @"org.mtproto.MTKeychain",
                                                              (__bridge id)kSecAttrAccount: [[NSString alloc] initWithFormat:@"MTKeychain:%@", name],
#if TARGET_OS_IPHONE
                                                              (__bridge id)kSecAttrAccessible: upgradeEncryption ? (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly : (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly
#endif
                                                              });
                    
                    SecItemAdd((__bridge CFDictionaryRef)@{
                                                           (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                           (__bridge id)kSecAttrService: @"org.mtproto.MTKeychain",
                                                           (__bridge id)kSecAttrAccount: [[NSString alloc] initWithFormat:@"MTKeychain:%@", name],
#if TARGET_OS_IPHONE
                                                           (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly,
#endif
                                                           (__bridge id)kSecValueData: newKeyData
                                                           }, NULL);
                }
            }
        }
    }
    return self;
}

- (NSString *)filePathForName:(NSString *)name group:(NSString *)group
{
    static NSString *dataDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
                      
        NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
                      NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        dataDirectory = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:_notEncryptedKeychain ? @"mtkeychain" : @"encrypt-mtkeychain"];
                  });
    
    [[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
        return [dataDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@_%@.bin", name, group]];
}

-(void)loadIfNeeded {
    
    NSArray *groups = @[@"persistent",@"primes",@"temp"];
    
    [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self _loadKeychainIfNeeded:obj];
        
    }];
}

-(void)cleanup {
    
    NSArray *groups = @[@"persistent",@"primes",@"temp"];
    
    [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [_dictByGroup removeObjectForKey:obj];
        
    }];
}

-(BOOL)updatePasscodeHash:(NSData *)md5Hash save:(BOOL)save {
    
    if(!md5Hash)
        md5Hash = [[NSData alloc] initWithEmptyBytes:32];
    
    NSArray *groups = @[@"persistent",@"primes",@"temp"];
    
    NSData *part1 = [md5Hash subdataWithRange:NSMakeRange(0, 16)];
    
    NSData *part2 = [md5Hash subdataWithRange:NSMakeRange(16, 16)];
    
    
    NSData *empty = [[NSData alloc] initWithEmptyBytes:16];
    
    part1 = [part1 dataWithData:empty];
    part2 = [part2 dataWithData:empty];
    
    _passcodeHash = [part1 dataWithData:part2];
    
    
    if(save) {
        [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [self _storeKeychain:obj];
            
        }];
    }

    [self cleanup];
    
    [self loadIfNeeded];
    
    
    return !_isNeedPasscode;
    
    
}

-(NSData *)md5PasscodeHash  {

    NSData *part1 = [_passcodeHash subdataWithRange:NSMakeRange(0, 16)];
    
    NSData *part2 = [_passcodeHash subdataWithRange:NSMakeRange(32, 16)];
    
    return [part1 dataWithData:part2];
    
}

- (void)_loadKeychainIfNeeded:(NSString *)group
{
    
    if (_dictByGroup[group] == nil)
    {
        if (_name != nil)
        {
            NSMutableData *data = [[[NSData alloc] initWithContentsOfFile:[self filePathForName:_name group:group]] mutableCopy];
            
            
            
            if (data != nil && data.length >= 8)
            {
                
                
                NSMutableData *decrypt = [[data subdataWithRange:NSMakeRange(4, data.length - 8)] mutableCopy];
                
                
                if(!_notEncryptedKeychain) {
                    MTAesDecryptInplace(decrypt, [_passcodeHash subdataWithRange:NSMakeRange(0, 32)], [_passcodeHash subdataWithRange:NSMakeRange(32, 32)]);
                }
                
                
                
                int32_t hash;
                
                [data getBytes:&hash range:NSMakeRange(data.length - 4, 4)];
                
                uint32_t length = 0;
                [data getBytes:&length range:NSMakeRange(0, 4)];
                
                
                int32_t decryptedHash = MTMurMurHash32(decrypt.bytes, length);
                
                _isNeedPasscode = hash != decryptedHash;
                
                
                data = [[[[data subdataWithRange:NSMakeRange(0, 4)] dataWithData:decrypt] dataWithData:[data subdataWithRange:NSMakeRange(data.length - 4, 4)]] mutableCopy];
                
                
                
                
                uint32_t paddedLength = length;
                while (paddedLength % 16 != 0)
                {
                    paddedLength++;
                }
                
                if (data.length == 4 + paddedLength || data.length == 4 + paddedLength + 4)
                {
                    NSMutableData *decryptedData = [[NSMutableData alloc] init];
                    [decryptedData appendData:[data subdataWithRange:NSMakeRange(4, paddedLength)]];
                    if (_encrypted)
                        MTAesDecryptInplace(decryptedData, _aesKey, _aesIv);
                    [decryptedData setLength:length];
                    
                    bool hashVerified = true;
                    
                    if (data.length == 4 + paddedLength + 4)
                    {
                        int32_t hash = 0;
                        [data getBytes:&hash range:NSMakeRange(4 + paddedLength, 4)];
                        
                        int32_t decryptedHash = MTMurMurHash32(decryptedData.bytes, (int)decryptedData.length);
                        if (hash != decryptedHash)
                        {
                            DLog(@"[MTKeychain invalid decrypted hash]");
                            hashVerified = false;
                        }
                    }
                    
                    if (hashVerified)
                    {
                        @try
                        {
                            id object = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                            if ([object respondsToSelector:@selector(objectForKey:)] && [object respondsToSelector:@selector(setObject:forKey:)])
                                _dictByGroup[group] = object;
                            else
                                DLog(@"[MTKeychain invalid root object %@]", object);
                        }
                        @catch (NSException *e)
                        {
                            DLog(@"[MTKeychain error parsing keychain: %@]", e);
                        }
                    }
                }
                else
                    DLog(@"[MTKeychain error loading keychain: expected data length %d, got %d]", 4 + (int)paddedLength, (int)data.length);
            }
        }
        
        if (_dictByGroup[group] == nil)
            _dictByGroup[group] = [[NSMutableDictionary alloc] init];
    }
}

- (void)_storeKeychain:(NSString *)group
{
    if (_dictByGroup[group] != nil && _name != nil)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_dictByGroup[group]];
        if (data != nil)
        {
            NSMutableData *encryptedData = [[NSMutableData alloc] initWithData:data];
            int32_t hash = MTMurMurHash32(encryptedData.bytes, (int)encryptedData.length);
            
            
            
            
            [encryptedData addPadding:16];
            
            if(!_notEncryptedKeychain) {
                MTAesEncryptInplace(encryptedData, [_passcodeHash subdataWithRange:NSMakeRange(0, 32)], [_passcodeHash subdataWithRange:NSMakeRange(32, 32)]);
            }
            
            
            
            
            uint32_t length = (uint32_t)data.length;
            [encryptedData replaceBytesInRange:NSMakeRange(0, 0) withBytes:&length length:4];
            [encryptedData appendBytes:&hash length:4];
            
            
            
            NSString *filePath = [self filePathForName:_name group:group];
            if (![encryptedData writeToFile:filePath atomically:true])
                DLog(@"[MTKeychain error writing keychain to file]");
        }
        else
            DLog(@"[MTKeychain error serializing keychain]");
    }
}

- (void)setObject:(id)object forKey:(id<NSCopying>)aKey group:(NSString *)group
{
    if (object == nil || aKey == nil)
        return;
    
    TG_SYNCHRONIZED_BEGIN(_dictByGroup);
    [self _loadKeychainIfNeeded:group];
    
    _dictByGroup[group][aKey] = object;
    [self _storeKeychain:group];
    TG_SYNCHRONIZED_END(_dictByGroup);
}

- (id)objectForKey:(id<NSCopying>)aKey group:(NSString *)group
{
    if (aKey == nil)
        return nil;
    
    TG_SYNCHRONIZED_BEGIN(_dictByGroup);
    [self _loadKeychainIfNeeded:group];
    
    id result = _dictByGroup[group][aKey];
    TG_SYNCHRONIZED_END(_dictByGroup);
    
    return result;
}

- (void)removeObjectForKey:(id<NSCopying>)aKey group:(NSString *)group
{
    if (aKey == nil)
        return;
    
    TG_SYNCHRONIZED_BEGIN(_dictByGroup);
    [self _loadKeychainIfNeeded:group];
    
    [_dictByGroup[group] removeObjectForKey:aKey];
    [self _storeKeychain:group];
    TG_SYNCHRONIZED_END(_dictByGroup);
}


-(BOOL)passcodeIsEnabled {
    
    return ![_passcodeHash isEqualToData:[[NSData alloc] initWithEmptyBytes:64]];
}


@end
