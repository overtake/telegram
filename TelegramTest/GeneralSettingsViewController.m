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
    
    
    
    GeneralSettingsBlockHeaderItem *autoPhotoHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"GeneralSettings.AutoVideoDownloadHeader", nil)];
    
    autoPhotoHeader.height = 61;
    
     [self.tableView insert:autoPhotoHeader atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    GeneralSettingsRowItem *autoPhotoDownloadGroup = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(GeneralSettingsRowItem *item) {
        
        [SettingsArchiver addOrRemoveSetting:AutoGroupVideo];
        
    } description:NSLocalizedString(@"Settings.Groups", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:AutoGroupVideo]);
    }];
    
    [self.tableView insert:autoPhotoDownloadGroup atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *autoPhotoDownloadPrivate = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(GeneralSettingsRowItem *item) {
        
        [SettingsArchiver addOrRemoveSetting:AutoPrivateVideo];
        
    } description:NSLocalizedString(@"Settings.PrivateChats", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:AutoPrivateVideo]);
    }];
    
    [self.tableView insert:autoPhotoDownloadPrivate atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    //photo end
    
    
    
    //audio
    
    GeneralSettingsBlockHeaderItem *autoAudioHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"GeneralSettings.AutoAudioDownloadHeader", nil)];
    
     autoAudioHeader.height = 51;
    
    [self.tableView insert:autoAudioHeader atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    
    GeneralSettingsRowItem *autoAudioDownloadGroup = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(GeneralSettingsRowItem *item) {
        
        [SettingsArchiver addOrRemoveSetting:AutoGroupAudio];
        
    } description:NSLocalizedString(@"Settings.Groups", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:AutoGroupAudio]);
    }];
    
    [self.tableView insert:autoAudioDownloadGroup atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *autoAudioDownloadPrivate = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(GeneralSettingsRowItem *item) {
        
        [SettingsArchiver addOrRemoveSetting:AutoPrivateAudio];
        
    } description:NSLocalizedString(@"Settings.PrivateChats", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:AutoPrivateAudio]);
    }];
    
    [self.tableView insert:autoAudioDownloadPrivate atIndex:self.tableView.list.count tableRedraw:NO];

    
    //audio end
    
    GeneralSettingsRowItem *emojiReplaces = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(GeneralSettingsRowItem *item) {
        [SettingsArchiver addOrRemoveSetting:EmojiReplaces];
    } description:NSLocalizedString(@"Settings.EmojiReplaces", nil) height:80 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:EmojiReplaces]);
    }];
    
    [self.tableView insert:emojiReplaces atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    GeneralSettingsRowItem *bigFong = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(GeneralSettingsRowItem *item) {
        [SettingsArchiver addOrRemoveSetting:BigFontSetting];
        [[Telegram rightViewController].messagesViewController reloadData];
    } description:NSLocalizedString(@"Settings.BigFont", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:BigFontSetting]);
    }];
    
    [self.tableView insert:bigFong atIndex:self.tableView.list.count tableRedraw:NO];
    
//    
//    GeneralSettingsRowItem *smartNotifications = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(GeneralSettingsRowItem *item) {
//        [SettingsArchiver addOrRemoveSetting:SmartNotifications];
//        [[Telegram rightViewController].messagesViewController reloadData];
//    } description:NSLocalizedString(@"Settings.SmartNotifications", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:SmartNotifications]);
//    }];
//    
//    [self.tableView insert:smartNotifications atIndex:self.tableView.list.count tableRedraw:NO];
//    
    
    
    GeneralSettingsRowItem *soundEffects = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(GeneralSettingsRowItem *item) {
        
        [SettingsArchiver addOrRemoveSetting:PushNotifications];
        
        
    } description:NSLocalizedString(@"Settings.MessageNotifications", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:PushNotifications]);
    }];
    
    [self.tableView insert:soundEffects atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *soundNotification = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeChoice callback:^(GeneralSettingsRowItem *item) {
        
    } description:NSLocalizedString(@"Settings.NotificationTone", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return NSLocalizedString([SettingsArchiver soundNotification], nil);
    }];
    
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    
    NSArray *list = soundsList();
    
    for (int i = 0; i < list.count; i++) {
        
        NSMenuItem *item = [NSMenuItem menuItemWithTitle:NSLocalizedString(list[i], nil) withBlock:^(NSMenuItem *sender) {
            
            if([sender.title isEqualToString:NSLocalizedString(@"DefaultSoundName", nil)])
                [SettingsArchiver setSoundNotification:@"DefaultSoundName"];
            else
                [SettingsArchiver setSoundNotification:sender.title];
            
            [self.tableView reloadData];
            
        }];
        
        
        
        [menu addItem:item];
        if(i == 0) {
            [menu addItem:[NSMenuItem separatorItem]];
        }
    }
    
    soundNotification.menu = menu;
    
    [self.tableView insert:soundNotification atIndex:self.tableView.list.count tableRedraw:NO];
    

    
//    GeneralSettingsRowItem *securitySettings = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
//        
//        [[Telegram rightViewController] showSecuritySettings];
//        
//    } description:NSLocalizedString(@"Settings.SecuritySettings", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
//        return nil;
//    }];
//    
//    [self.tableView insert:securitySettings atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    GeneralSettingsRowItem *advancedSettings = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
        
        [[Telegram mainViewController].settingsWindowController showWindowWithAction:SettingsWindowActionChatSettings];
        
    } description:NSLocalizedString(@"Settings.AdvancedSettings", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return nil;
    }];
    
    [self.tableView insert:advancedSettings atIndex:self.tableView.list.count tableRedraw:NO];
    
    
#ifdef TGDEBUG
    
    GeneralSettingsRowItem *sendLogs = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
        
        
         __block TLUser *user = [UsersManager findUserByName:@"vihor"];
        
        dispatch_block_t performBlock = ^ {
          
            [[Telegram rightViewController] showByDialog:user.dialog sender:self];
            
            NSArray *files = TGGetLogFilePaths();
            
            [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [[Telegram rightViewController].messagesViewController sendDocument:obj];
            }];
           
        };
        
        if(user) {
            performBlock();
        } else {
            
            [self showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_contacts_search createWithQ:@"vihor" limit:1] successHandler:^(RPCRequest *request, TL_contacts_contacts *response) {
                
                if(response.users.count == 1) {
                    
                    [[UsersManager sharedManager] add:response.users withCustomKey:@"n_id" update:YES];
                    
                    user = response.users[0];
                    
                    performBlock();
                }
                
                [self hideModalProgress];
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                [self hideModalProgress];
            }];
        }
        
       
        
        
        
    } description:@"Send logs" height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return nil;
    }];
    
    [self.tableView insert:sendLogs atIndex:self.tableView.list.count tableRedraw:NO];
    
    
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
