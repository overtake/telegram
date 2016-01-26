
//
//  SettingsArchiver.m
//  Messenger for Telegram
//
//  Created by keepcoder on 31.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SettingsArchiver.h"


@interface SettingsArchiver ()
@property (nonatomic,assign) SettingsMask mask;

@property (nonatomic,assign) int auto_download_limit_size;

@property (nonatomic,strong) NSString *documents_folder;
@property (nonatomic,strong) NSMutableArray *listeners;
@property (nonatomic,strong) NSString *defaultSoundNotification;
@property (nonatomic,assign) NSUInteger supportUserId;
@end

@implementation SettingsArchiver


static NSString *kArchivedSettings = @"kArchivedSettings";

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.documents_folder = [aDecoder decodeObjectForKey:@"documents_folder"];
        self.auto_download_limit_size = [aDecoder decodeInt32ForKey:@"auto_download_limit_size"];
        _mask = [aDecoder decodeInt32ForKey:@"settings_mask"];
        self.defaultSoundNotification = [aDecoder decodeObjectForKey:@"default_sound_notification"];
        self.supportUserId = [aDecoder decodeIntegerForKey:@"support_user_id"];
        
        if(!self.defaultSoundNotification) {
            self.defaultSoundNotification = @"DefaultSoundName";
        }
    }
    
    return self;
}

-(id)init {
    if(self = [super init]) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    self.auto_download_limit_size = DownloadLimitSize10;
    self.mask = SendEnter | OnlineFocused | SoundEffects | AutoGroupAudio | AutoPrivateAudio | AutoPrivatePhoto | AutoGroupPhoto | PushNotifications | iCloudSynch | StatusBarIcon | MessagesNotificationPreview | MarkedInputText | IncludeMutedUnreadCount;
    self.documents_folder = dp();
    self.defaultSoundNotification = @"DefaultSoundName";

    
}



-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:_mask forKey:@"settings_mask"];
    [aCoder encodeObject:self.documents_folder forKey:@"documents_folder"];
    [aCoder encodeInt32:self.auto_download_limit_size forKey:@"auto_download_limit_size"];
    [aCoder encodeObject:self.defaultSoundNotification forKey:@"default_sound_notification"];
    [aCoder encodeInteger:self.supportUserId forKey:@"support_user_id"];
    
}


-(void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:kArchivedSettings];
    [defaults synchronize];
}


+ (void)drop {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kArchivedSettings];
    [defaults synchronize];
    
    [[SettingsArchiver instance] initialize];
    
    [[SettingsArchiver instance] save];
}

+ (NSUInteger)supportUserId {
    return [[SettingsArchiver instance] supportUserId];
}

+ (BOOL)setSupportUserId:(NSUInteger)supportUserId {
    //if(supportUserId != 0) {
       
        [SettingsArchiver instance].supportUserId = supportUserId;
        [[SettingsArchiver instance] save];
        
        return YES;
   // }
    
    return NO;
}


+ (NSString *)soundNotification {
    return [[SettingsArchiver instance] defaultSoundNotification];
}
+ (BOOL)setSoundNotification:(NSString *)notificationName {
    
    NSArray *list = soundsList();
    
    if([list indexOfObject:notificationName] == NSNotFound) {
        return NO;
    }
    
    [[SettingsArchiver instance] setDefaultSoundNotification:notificationName];
    [[SettingsArchiver instance] save];
    
    [self didChangeMask];
    return YES;
}


+ (BOOL)checkMaskedSetting:(SettingsMask)mask {
    return ([SettingsArchiver instance].mask & mask) == mask;
}

+ (void)addOrRemoveSetting:(SettingsMask)mask {
    if ([self checkMaskedSetting:mask])
        [SettingsArchiver instance].mask &= ~mask;
    else
        [SettingsArchiver instance].mask |= mask;
    
    [self didChangeMask];
    
    [[SettingsArchiver instance] save];
}

+ (void)addSetting:(SettingsMask)mask {
    [SettingsArchiver instance].mask |= mask;
    [[SettingsArchiver instance] save];
}

+ (void)removeSetting:(SettingsMask)mask {
    [SettingsArchiver instance].mask &= ~mask;
    [[SettingsArchiver instance] save];
}

+ (int)contain:(int)mask {
    return [SettingsArchiver instance].mask & mask;
}

+ (void)addOrRemoveSetting:(SettingsMask)mask depends:(SettingsMask)depends {
    
    SettingsMask d = [self contain:depends];
    
    [SettingsArchiver instance].mask &= ~d;
    
    
    [self addOrRemoveSetting:mask];
}

+ (void)didChangeMask {

    [ASQueue dispatchOnMainQueue:^{
        for (id<SettingsListener> listener in [[self instance] listeners]) {
            if([listener respondsToSelector:@selector(didChangeSettingsMask:)]) {
                [listener didChangeSettingsMask:[SettingsArchiver instance].mask];
            }
        }
    }];
}

+ (NSString *)documentsFolder {
    return [SettingsArchiver instance].documents_folder;
}

+ (BOOL)setDocumentsFolder:(NSString *)folder {
   
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:folder
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    if(!error) {
        [[SettingsArchiver instance] setDocuments_folder:folder];
        
        [[SettingsArchiver instance] save];
    }
    
    return error == nil;
}

+ (NSUInteger)autoDownloadLimitSize {
    return [SettingsArchiver instance].auto_download_limit_size;
}


+ (void)setAutoDownloadLimitSize:(DownloadLimitSize)limit {
    [SettingsArchiver instance].auto_download_limit_size = limit;
    [[SettingsArchiver instance] save];
}

+ (void)addEventListener:(id<SettingsListener>)listener {
    [ASQueue dispatchOnMainQueue:^{
        [[SettingsArchiver instance].listeners addObject:listener];
    }];
    
}

+ (void)removeEventListener:(id<SettingsListener>)listener {
   [ASQueue dispatchOnMainQueue:^{
        [[SettingsArchiver instance].listeners removeObject:listener];
   }];
}

+(void)notifyOfLaunch {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL saved = [[defaults objectForKey:@"startAtLaunchNotified"] boolValue];
    
    if(!saved) {
        if(![self isLaunchAtStartup]) {
            confirm(NSLocalizedString(@"App.startupAtLaunch", nil), NSLocalizedString(@"App.startupAtLaunchDesc", nil), ^{
                if(![self isLaunchAtStartup])
                    [self toggleLaunchAtStartup];
            },nil);
        }
        
        [defaults setBool:YES forKey:@"startAtLaunchNotified"];
        
        [defaults synchronize];
        
    }
    
}


+ (BOOL)isLaunchAtStartup {
    LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
    BOOL isInList = itemRef != nil;
    if (itemRef != nil) CFRelease(itemRef);
    
    return isInList;
}

+ (void)toggleLaunchAtStartup {
    BOOL shouldBeToggled = ![self isLaunchAtStartup];
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return;
    if (shouldBeToggled) {
        CFURLRef appUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL, NULL, appUrl, NULL, NULL);
        if (itemRef) CFRelease(itemRef);
    }
    else {
        LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
        LSSharedFileListItemRemove(loginItemsRef,itemRef);
        if (itemRef != nil) CFRelease(itemRef);
    }
    CFRelease(loginItemsRef);
}

+ (LSSharedFileListItemRef)itemRefInLoginItems {
    LSSharedFileListItemRef itemRef = nil;
    CFURLRef itemUrl = nil;
    
    NSURL *appUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return nil;
    NSArray *loginItems = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItemsRef, nil);
    for (int currentIndex = 0; currentIndex < [loginItems count]; currentIndex++) {
        LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItems objectAtIndex:currentIndex];
        if (LSSharedFileListItemResolve(currentItemRef, 0, (CFURLRef *) &itemUrl, NULL) == noErr) {
            
            NSString *itemPath = CFBridgingRelease(CFURLCopyPath(itemUrl));
            
            
            if ([itemPath hasPrefix:[appUrl path]]) {
                itemRef = currentItemRef;
            }
        }
    }
    if (itemRef != nil) CFRetain(itemRef);
    CFRelease(loginItemsRef);
    
    return itemRef;
}



+ (instancetype)instance {
    static SettingsArchiver *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *archivedData = [defaults dataForKey:kArchivedSettings];
        instance = archivedData ? [NSKeyedUnarchiver unarchiveObjectWithData:archivedData] : [[SettingsArchiver alloc] init];
        instance.listeners = [[NSMutableArray alloc] init];
        
        dispatch_async(dispatch_get_current_queue(), ^{
            
                // HARD CHECK FOR NEW ON SETTINGS
                
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if (![defaults objectForKey:@"check_push_once"]) {
                [defaults setObject:@"once" forKey:@"check_push_once"];
                
                [SettingsArchiver addSetting:PushNotifications];
            }
            
            
            if(![defaults objectForKey:@"icloud_sync_once"]) {
                [defaults setObject:@"once" forKey:@"icloud_sync_once"];
                
                [SettingsArchiver addSetting:iCloudSynch];

            }
            
            if(![defaults objectForKey:@"status_bar_sync_once"]) {
                [defaults setObject:@"once" forKey:@"status_bar_sync_once"];
                
                [SettingsArchiver addSetting:StatusBarIcon];
                
            }
            
            if(![defaults objectForKey:@"SmartNotifications"]) {
                [defaults setObject:@"once" forKey:@"SmartNotifications"];
                
                [SettingsArchiver addSetting:SmartNotifications];
                
            }
            if(![defaults objectForKey:@"MarkedInputText"]) {
                [defaults setObject:@"once" forKey:@"MarkedInputText"];
                
                [SettingsArchiver addSetting:MarkedInputText];    
            }
            
            if(![defaults objectForKey:@"MessagesPreview"]) {
                [defaults setObject:@"once" forKey:@"MessagesPreview"];
                
                [SettingsArchiver addSetting:MessagesNotificationPreview];
            }
            
            if(![defaults objectForKey:@"IncludeMutedUnreadCount"]) {
                [defaults setObject:@"once" forKey:@"IncludeMutedUnreadCount"];
                
                [SettingsArchiver addSetting:IncludeMutedUnreadCount];
            }
            
        });
        
    });
    
    return instance;
}

@end
