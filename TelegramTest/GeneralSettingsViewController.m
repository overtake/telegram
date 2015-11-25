//
//  GeneralSettingsViewController.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "GeneralSettingsViewController.h"
#import "GeneralSettingsRowItem.h"
#import "GeneralSettingsRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "ASCommon.h"
@interface GeneralSettingsViewController () <TMTableViewDelegate,SettingsListener>
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation GeneralSettingsViewController

-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"GeneralSettings.General", nil)];
    
   
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];
    
    
    
    //photo
    
    
    [SettingsArchiver addEventListener:self];
    
    
//    
//    GeneralSettingsBlockHeaderItem *autoPhotoHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"GeneralSettings.AutoVideoDownloadHeader", nil)];
//    
//    autoPhotoHeader.height = 61;
//    
//     [self.tableView insert:autoPhotoHeader atIndex:self.tableView.list.count tableRedraw:NO];
//    
//    
//    
//    GeneralSettingsRowItem *autoPhotoDownloadGroup = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
//        
//        [SettingsArchiver addOrRemoveSetting:AutoGroupVideo];
//        
//    } description:NSLocalizedString(@"Settings.Groups", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:AutoGroupVideo]);
//    }];
//    
//    [self.tableView insert:autoPhotoDownloadGroup atIndex:self.tableView.list.count tableRedraw:NO];
//    
//    
//    GeneralSettingsRowItem *autoPhotoDownloadPrivate = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
//        
//        [SettingsArchiver addOrRemoveSetting:AutoPrivateVideo];
//        
//    } description:NSLocalizedString(@"Settings.PrivateChats", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:AutoPrivateVideo]);
//    }];
//    
//    [self.tableView insert:autoPhotoDownloadPrivate atIndex:self.tableView.list.count tableRedraw:NO];
//    
//    
//    //photo end
//    
//    
//    
//    //audio
//    
//    GeneralSettingsBlockHeaderItem *autoAudioHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"GeneralSettings.AutoAudioDownloadHeader", nil)];
//    
//     autoAudioHeader.height = 51;
//    
//    [self.tableView insert:autoAudioHeader atIndex:self.tableView.list.count tableRedraw:NO];
//    
//    
//    
//    
//    GeneralSettingsRowItem *autoAudioDownloadGroup = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
//        
//        [SettingsArchiver addOrRemoveSetting:AutoGroupAudio];
//        
//    } description:NSLocalizedString(@"Settings.Groups", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:AutoGroupAudio]);
//    }];
//    
//    [self.tableView insert:autoAudioDownloadGroup atIndex:self.tableView.list.count tableRedraw:NO];
//    
//    
//    GeneralSettingsRowItem *autoAudioDownloadPrivate = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
//        
//        [SettingsArchiver addOrRemoveSetting:AutoPrivateAudio];
//        
//    } description:NSLocalizedString(@"Settings.PrivateChats", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:AutoPrivateAudio]);
//    }];
//    
//    [self.tableView insert:autoAudioDownloadPrivate atIndex:self.tableView.list.count tableRedraw:NO];

    
//    GeneralSettingsBlockHeaderItem *notificationsHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"Settings.MessageNotificationsHeader", nil)];
//    
//    notificationsHeader.height = 61;
//    
//    [self.tableView insert:notificationsHeader atIndex:self.tableView.list.count tableRedraw:NO];
//

//    
    
    
    
    GeneralSettingsBlockHeaderItem *chatSettingsHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"Settings.ChatSettingsHeader", nil)];
    
    chatSettingsHeader.height = 42;
    
    [self.tableView insert:chatSettingsHeader atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    
    
    
    GeneralSettingsRowItem *soundNotification = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        
        
        [SettingsArchiver addOrRemoveSetting:SoundEffects];
        
    } description:NSLocalizedString(@"Settings.SoundEffects", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:SoundEffects]);
    }];
    
    
    

    
    [self.tableView insert:soundNotification atIndex:self.tableView.list.count tableRedraw:NO];
    
    //audio end
//    
//    GeneralSettingsRowItem *emojiReplaces = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
//        [SettingsArchiver addOrRemoveSetting:EmojiReplaces];
//    } description:NSLocalizedString(@"Settings.EmojiReplaces", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:EmojiReplaces]);
//    }];
//    
//    [self.tableView insert:emojiReplaces atIndex:self.tableView.list.count tableRedraw:NO];
//    
    
    
    GeneralSettingsRowItem *bigFong = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        [SettingsArchiver addOrRemoveSetting:BigFontSetting];
        [[Telegram rightViewController].messagesViewController reloadData];
    } description:NSLocalizedString(@"Settings.BigFont", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:BigFontSetting]);
    }];
    
    [self.tableView insert:bigFong atIndex:self.tableView.list.count tableRedraw:NO];
    

 
    
    
    GeneralSettingsRowItem *stickers = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        [[Telegram rightViewController] showStickerSettingsController];
        
        //   [[Telegram mainViewController].settingsWindowController showWindowWithAction:SettingsWindowActionChatSettings];
        
    } description:NSLocalizedString(@"Settings.Stickers", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return nil;
    }];
    
    [self.tableView insert:stickers atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    GeneralSettingsBlockHeaderItem *advancedHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"Settings.AdvancedSettingsHeader", nil)];
    
    advancedHeader.height = 61;
    
    [self.tableView insert:advancedHeader atIndex:self.tableView.list.count tableRedraw:NO];
   
    
    

    
    
    GeneralSettingsRowItem *advancedSettings = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        [[Telegram mainViewController].settingsWindowController showWindowWithAction:SettingsWindowActionChatSettings];
        
    } description:NSLocalizedString(@"Settings.AdvancedSettings", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return nil;
    }];
    
    [self.tableView insert:advancedSettings atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *cache = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        [[Telegram rightViewController] showCacheSettingsViewController];
        
    } description:NSLocalizedString(@"Settings.Cache", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return nil;
    }];
    
    [self.tableView insert:cache atIndex:self.tableView.list.count tableRedraw:NO];

    
    
    GeneralSettingsRowItem *mutedChatsInUnreadCount = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        
        [SettingsArchiver addOrRemoveSetting:IncludeMutedUnreadCount];
        
        [MessagesManager updateUnreadBadge];
        
    } description:NSLocalizedString(@"Settings.IncludeMutedUnread", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:IncludeMutedUnreadCount]);
    }];
    
    [self.tableView insert:mutedChatsInUnreadCount atIndex:self.tableView.list.count tableRedraw:NO];
    
    
#ifdef TGDEBUG
    
    GeneralSettingsRowItem *sendLogs = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        
        confirm(appName(), @"Are you sure you want to send your logs to the developer? Please do this only if you have a problem with the application and a support volunteer asked you to send logs.", ^{
            
            [Telegram sendLogs];

        }, ^{
            
        });
        
    } description:@"Send logs" height:42 stateback:^id(TGGeneralRowItem *item) {
        return nil;
    }];
    
    [self.tableView insert:sendLogs atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    if(ACCEPT_FEATURE) {
        
        GeneralSettingsRowItem *switchBackend = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
            
            
            confirm(appName(), @"Are You sure to switch backend?", ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:@"test-backend"];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:!value forKey:@"test-backend"];
                    
                    NSMutableArray *array = [NSMutableArray array];
                    
                    array[1] = array[2];
                });
                
                
            }, ^{
                
            });
            
        } description:@"Switch backend" height:42 stateback:^id(TGGeneralRowItem *item) {
            return nil;
        }];
        
        [self.tableView insert:switchBackend atIndex:self.tableView.list.count tableRedraw:NO];

        
    }
    
    
#endif
    
    [self.tableView reloadData];
    
}


-(void)didChangeSettingsMask:(SettingsMask)mask {
    [self.tableView reloadData];
}

- (CGFloat)rowHeight:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
    if([item isKindOfClass:[GeneralSettingsRowItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsRowView class] identifier:@"GeneralSettingsRowViewClass"];
    }
    
    return nil;
    
}

- (void)selectionDidChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}


@end
