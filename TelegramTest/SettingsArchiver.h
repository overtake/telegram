//
//  SettingsArchiver.h
//  Messenger for Telegram
//
//  Created by keepcoder on 31.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AutoGroupVideo =  1 << 1,
    AutoPrivateVideo = 1 << 2,
    AutoGroupAudio = 1 << 3,
    AutoPrivateAudio = 1 << 4,
    AutoGroupDocuments = 1 << 5,
    AutoPrivateDocuments = 1 << 6,
    
    SendEnter = 1 << 7,
    SendCmdEnter = 1 << 8,
    
    OnlineFocused = 1 << 9,
    OnlineForever = 1 << 10,
    
    AutoOpenDocuments = 1 << 11,
    OpenLinksInBackground = 1 << 12,
    SoundEffects = 1 << 13,
    
    
    BlockedContactsSynchronized = 1 << 14,
    
    AutoGroupPhoto = 1 << 15,
    AutoPrivatePhoto = 1 << 16,
    PushNotifications = 1 << 17,
    EmojiReplaces = 1 << 18,
    iCloudSynch = 1 << 19,
    BigFontSetting = 1 << 20,
    StatusBarIcon = 1 << 21,
    SmartNotifications = 1 << 22,
    MarkedInputText = 1 << 23,
    MessagesNotificationPreview = 1 << 24,
    IncludeMutedUnreadCount = 1 << 25
} SettingsMask;


typedef enum {
    DownloadLimitSize10 = 10*1024*1024,
    DownloadLimitSize50 = 50*1024*1024,
    DownloadLimitSize100 = 100*1024*1024,
    DownloadLimitSize1000 = 1000*1024*1024
} DownloadLimitSize;

@protocol SettingsListener <NSObject>

@optional
-(void)didChangeSettingsMask:(SettingsMask)mask;

@end


@interface SettingsArchiver : NSObject<NSCoding>


/*
 binary settings mask
*/

+ (void)drop;

+ (BOOL)checkMaskedSetting:(SettingsMask)mask;
+ (void)addSetting:(SettingsMask)mask;
+ (void)removeSetting:(SettingsMask)mask;
+ (void)addOrRemoveSetting:(SettingsMask)mask;
+ (void)addOrRemoveSetting:(SettingsMask)mask depends:(SettingsMask)depends;

+ (int)contain:(int)mask;



+ (void)addEventListener:(id<SettingsListener>)listener;
+ (void)removeEventListener:(id<SettingsListener>)listener;

+ (NSString *)documentsFolder;
+ (BOOL)setDocumentsFolder:(NSString *)folder;


+ (NSString *)soundNotification;
+ (BOOL)setSoundNotification:(NSString *)notificationName;


+ (NSUInteger)supportUserId;
+ (BOOL)setSupportUserId:(NSUInteger)supportUserId;

+ (NSUInteger)autoDownloadLimitSize;
+ (void)setAutoDownloadLimitSize:(DownloadLimitSize)limit;

+ (void)notifyOfLaunch;
+ (BOOL)isLaunchAtStartup;
+ (void)toggleLaunchAtStartup;
@end
