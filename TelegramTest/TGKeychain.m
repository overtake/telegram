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
#import <MTProtoKit/MTLogging.h>
#import "SSKeychain.h"
#import <AppKit/AppKit.h>

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
    
    NSData *_aesKey;
    NSData *_aesIv;
    NSData *_passcodeHash;
    dispatch_semaphore_t _semaphore;
    TG_SYNCHRONIZED_DEFINE(_dictByGroup);
    NSMutableDictionary *_dictByGroup;
    
    NSMutableDictionary *_readKeychainData;
    NSMutableDictionary *_saveKeychainData;
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
    
    keychain->_encrypted = false;
    [keychain cleanup];
    [keychain loadIfNeeded];
    
    TG_SYNCHRONIZED_END(_keychains);
    
    return keychain;
}


NSString * serviceName() {
    return [[NSProcessInfo processInfo].environment[@"test_server"] boolValue] || [[NSUserDefaults standardUserDefaults] boolForKey:@"test-backend"] ? @"telegram-test-server" : @"Telegram";
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
    
    keychain->_encrypted = true;
    [keychain cleanup];
    [keychain loadIfNeeded];
    
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
        _saveKeychainData = [[NSMutableDictionary alloc] init];
        _readKeychainData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)filePathForName:(NSString *)name group:(NSString *)group
{
    static NSString *dataDirectory = nil;
                      
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = serviceName();
    dataDirectory = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:_notEncryptedKeychain ? @"mtkeychain" : @"encrypt-mtkeychain"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [dataDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@_%@.bin", name, group]];
}

-(void)loadIfNeeded {
    
    [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self _loadKeychainIfNeeded:obj];
        
    }];
}

-(void)cleanup {
    
    
    [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [_dictByGroup removeObjectForKey:obj];
        
    }];
}

+(void)initialize {
    groups = @[@"persistent",@"primes",@"temp"];
}

static NSArray *groups;

-(BOOL)updatePasscodeHash:(NSData *)md5Hash save:(BOOL)save {
    
    if(!md5Hash)
        md5Hash = [[NSData alloc] initWithEmptyBytes:32];
    
    
    NSData *part1 = [md5Hash subdataWithRange:NSMakeRange(0, 16)];
    
    NSData *part2 = [md5Hash subdataWithRange:NSMakeRange(16, 16)];
    
    
    NSData *empty = [[NSData alloc] initWithEmptyBytes:16];
    
    part1 = [part1 dataWithData:empty];
    part2 = [part2 dataWithData:empty];
    
    _passcodeHash = [part1 dataWithData:part2];
    
    
    if(save) {
        [self storeAllKeychain];
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
    
    if(_encrypted) {
        _readKeychainData = [NSKeyedUnarchiver unarchiveObjectWithData:[SSKeychain passwordDataForService:serviceName() account:@"authkeys"]];
    }
    
    
    
    if (_dictByGroup[group] == nil)
    {
        if (_name != nil)
        {
            NSMutableData *data;
            
            NSString *path = [self filePathForName:_name group:group];
            
            if(_encrypted) {
                
                NSData *fileData = [[NSData alloc] initWithContentsOfFile:path];
                
                if(fileData.length > 0) {
                    
                    _saveKeychainData[group] = fileData;
                    
                    [self saveKeychain];
                    
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    
                    data = [fileData mutableCopy];
                } else {
                    data = [_readKeychainData[group] mutableCopy];
                }
                
            } else {
                data = [[[NSData alloc] initWithContentsOfFile:path] mutableCopy];
            }
            
           
            
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

                    [decryptedData setLength:length];
                    
                    bool hashVerified = true;
                    
                    if (data.length == 4 + paddedLength + 4)
                    {
                        int32_t hash = 0;
                        [data getBytes:&hash range:NSMakeRange(4 + paddedLength, 4)];
                        
                        int32_t decryptedHash = MTMurMurHash32(decryptedData.bytes, (int)decryptedData.length);
                        if (hash != decryptedHash)
                        {
                            MTLog(@"[MTKeychain invalid decrypted hash]");
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
                                MTLog(@"[MTKeychain invalid root object %@]", object);
                        }
                        @catch (NSException *e)
                        {
                            MTLog(@"[MTKeychain error parsing keychain: %@]", e);
                        }
                    }
                }
                else
                    MTLog(@"[MTKeychain error loading keychain: expected data length %d, got %d]", 4 + (int)paddedLength, (int)data.length);
            }
        }
        
        if (_dictByGroup[group] == nil)
            _dictByGroup[group] = [[NSMutableDictionary alloc] init];
    }
}

-(void)storeAllKeychain {
    [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self _storeKeychain:obj];
        
    }];
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
            
            
            
            if(_encrypted) {
                _saveKeychainData[group] = encryptedData;
                
                [self saveKeychain];
                
            } else {
                if (![encryptedData writeToFile:filePath atomically:true])
                    MTLog(@"[MTKeychain error writing keychain to file]");
            }
            
            
        }
        else
            MTLog(@"[MTKeychain error serializing keychain]");
    }
}

-(void)saveKeychain {
    [SSKeychain setPasswordData:[NSKeyedArchiver archivedDataWithRootObject:_saveKeychainData] forService:serviceName() account:@"authkeys"];
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
