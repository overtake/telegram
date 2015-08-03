//
//  TGPasslock.m
//  Telegram
//
//  Created by keepcoder on 23.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPasslock.h"
#import "HackUtils.h"
#import "TGTimer.h"
@interface TGPasslock ()
@property (nonatomic,strong) TGTimer *lockTimer;
@property (nonatomic,assign) int saveTime;
@property (nonatomic,assign) BOOL visibility;
@end

@implementation TGPasslock


-(instancetype)init {
    if(self = [super init]) {
        
    }
    
    return self;
}

+(NSString *)path {
    return [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:appName()] stringByAppendingPathComponent:@"mtkeychain/passlock"];
}



+(BOOL)isEnabled {
    return [[MTNetwork instance] passcodeIsEnabled];
}

+(BOOL)checkHash:(NSString *)md5Hash {
    
    return [md5Hash isEqualToString:[NSString stringWithContentsOfFile:[TGPasslock path] encoding:NSUTF8StringEncoding error:nil]];
}

+(BOOL)enableWithHash:(NSString *)md5Hash {
    
    
    if(![TGPasslock isEnabled]) {
        
        
        [md5Hash writeToFile:[self path] atomically:YES];
        
        return YES;
    }
    
    return NO;
    
}

+(BOOL)disableWithHash:(NSString *)md5Hash {
    
    if([TGPasslock isEnabled] && [TGPasslock checkHash:md5Hash]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:[TGPasslock path] error:nil];
        
        return YES;
        
    }
    
    return NO;
}

+(BOOL)changeWithHash:(NSString *)md5Hash {
    
    [[NSFileManager defaultManager] removeItemAtPath:[TGPasslock path] error:nil];
    
    return [self enableWithHash:md5Hash];
    
}


+(void)forceDisable {
    [[NSFileManager defaultManager] removeItemAtPath:[TGPasslock path] error:nil];
}

-(void)updateTimer {
    
    [self invalidateTimer];
    
    if([self autoLockTime] == 0 || ![TGPasslock isEnabled] || _lockTimer)
        return;
    
    _saveTime = [[MTNetwork instance] getTime];
    
    _lockTimer = [[TGTimer alloc] initWithTimeout:5 repeat:YES completion:^{
        
        
        
        [self checkLocker];
        
        
    } queue:[ASQueue globalQueue].nativeQueue];
    
    
    [_lockTimer start];
    
}

-(void)checkLocker {
    
    MTLog(@"!!!!!check locker!!!!!");
    
    if([NSApp isActive]) {
        _saveTime = [[MTNetwork instance] getTime];
    }
    
    if(_saveTime != 0  && [TGPasslock isEnabled]) {
        int differenceTime = [[MTNetwork instance] getTime] - _saveTime;
        
        if(differenceTime > [self autoLockTime] || [self autoLockTime] < SystemIdleTime()) {
            [ASQueue dispatchOnMainQueue:^{
                [TMViewController showBlockPasslock:^BOOL(BOOL result, NSString *md5Hash) {
                    
                    BOOL res = [[MTNetwork instance] checkPasscode:[md5Hash dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    if(res) {
                         _saveTime = [[MTNetwork instance] getTime];
                        [TMViewController hidePasslock];
                        [[Telegram rightViewController] becomeFirstResponder];
                    }
                    
                    return res;
                    
                }];
            }];
        }
    }
    
}

-(void)invalidateTimer {
    
    [self checkLocker];
    
    _saveTime = [[MTNetwork instance] getTime];
    
}

+(void)updateTimer {
    [[self instance] updateTimer];
}

-(NSUInteger)autoLockTime {
        
    id time = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto-passlock"];
    
    if(!time) {
        [TGPasslock setAutoLockTime:3600];
    }
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"auto-passlock"];
}

+(void)setAutoLockTime:(int)time {
    [[NSUserDefaults standardUserDefaults] setInteger:time forKey:@"auto-passlock"];
    
    [self updateTimer];
}

+(void)appIncomeActive {
    [[self instance] invalidateTimer];
}

+(void)appResignActive {
    [[self instance] updateTimer];
}

+(NSString *)autoLockDescription {
    NSUInteger time = [[NSUserDefaults standardUserDefaults] integerForKey:@"auto-passlock"];
    
    NSString *key = [NSString stringWithFormat:@"Passcode.AutoLockTime%lu",time];
    
    return NSLocalizedString(key, nil);
}

+(void)setVisibility:(BOOL)visibility {
    [[self instance] setVisibility:visibility];
}

+(BOOL)isVisibility {
    return [[self instance] visibility];
}

+(BOOL)isLocked {
    return YES;
}

+(TGPasslock *)instance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end
