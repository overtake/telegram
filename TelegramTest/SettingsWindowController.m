//
//  SettingsWindowController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 25.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SettingsWindowController.h"
#import "NSStringCategory.h"
#import "TMClickTextFieldView.h"
#import "ImageStorage.h"

#import <AddressBook/AddressBookUI.h>
#import <AddressBook/AddressBook.h>


#import "BlockedTableController.h"

@interface SettingsWindowController ()<SettingsListener>

@property (weak) IBOutlet NSButton *open_links_in_background;
@property (weak) IBOutlet NSButton *convertEmoji;

@property (weak) IBOutlet NSButton *auto_downlod_video_group;
@property (weak) IBOutlet NSButton *auto_downlod_video_private;
@property (weak) IBOutlet NSButton *auto_downlod_audio_group;
@property (weak) IBOutlet NSButton *auto_downlod_audio_private;
@property (weak) IBOutlet NSButton *auto_downlod_documents_group;
@property (weak) IBOutlet NSButton *auto_downlod_documents_private;

@property (weak) IBOutlet NSMatrix *send_message_as;
@property (weak) IBOutlet NSMatrix *online_settings;

@property (weak) IBOutlet NSPopUpButton *auto_download_limit;

@property (weak) IBOutlet NSPopUpButton *documents_folder_button;
@property (weak) IBOutlet NSPopUpButton *sound_notifications_button;
@property (weak) IBOutlet NSButton *sound_effects_checkbox;
@property (weak) IBOutlet NSTextField *sound_notification_title;
@property (weak) IBOutlet NSView *chat_settings_view;
@property (weak) IBOutlet NSView *security_settings_view;
@property (weak) IBOutlet NSToolbar *tool_bar;
@property (weak) IBOutlet NSButton *add_to_blocks;

@property (weak) IBOutlet BlockedTableController *blocked_table_view;
@property (weak) IBOutlet NSButton *remove_from_block_button;

@property (nonatomic,strong) ABPeoplePickerView *peoplePickerView;

@property (weak) IBOutlet NSButton *statusBarIcon;
@property (weak) IBOutlet NSButton *markedInputText;

@property (weak) IBOutlet NSTabView *tabView;

@property (weak) IBOutlet NSButton *launch_on_startup;

// description text fields outlets

@property (weak) IBOutlet NSTextField *online_when_desc;
@property (weak) IBOutlet NSTextField *auto_download_desc;
@property (weak) IBOutlet NSTextField *video_desc;
@property (weak) IBOutlet NSTextField *documents_desc;
@property (weak) IBOutlet NSTextField *voice_messages_desc;
@property (weak) IBOutlet NSTextField *file_size_limit_desc;
@property (weak) IBOutlet NSTextField *send_message_desc;
@property (weak) IBOutlet NSTextField *save_documents_to_desc;
@property (weak) IBOutlet NSTextField *sound_notifications_desc;
@property (weak) IBOutlet NSTextField *other_desc;


@property (weak) IBOutlet NSTextField *cache_desc;
@property (weak) IBOutlet NSTextField *sessions_desc;
@property (weak) IBOutlet NSTextField *cache_sub_desc;
@property (weak) IBOutlet NSTextField *sessions_sub_desc;
@property (weak) IBOutlet NSTextField *account_desc;
@property (weak) IBOutlet NSMenuItem *choose_desc;


@property (weak) IBOutlet NSButton *clear_all_the_cache_button;
@property (weak) IBOutlet NSButton *terminate_all_other_sessions_button;
@property (weak) IBOutlet NSButton *log_out_button;

@property (weak) IBOutlet NSToolbarItem *generalToolItem;
@property (weak) IBOutlet NSToolbarItem *accountToolItem;

@end

@implementation SettingsWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {

    }
    return self;
}



- (void)awakeFromNib
{
    
 
    [self.open_links_in_background setTitle:NSLocalizedString(@"Settings.OpenLinksBackground", nil)];
    
    [self.convertEmoji setTitle:NSLocalizedString(@"Settings.EmojiReplaces", nil)];
    
    [self.auto_downlod_video_private setTitle:NSLocalizedString(@"Settings.PrivateChats", nil)];
    [self.auto_downlod_video_group setTitle:NSLocalizedString(@"Settings.Groups", nil)];
    
    [self.auto_downlod_documents_private setTitle:NSLocalizedString(@"Settings.PrivateChats", nil)];
    [self.auto_downlod_documents_group setTitle:NSLocalizedString(@"Settings.Groups", nil)];
    
    [self.auto_downlod_audio_private setTitle:NSLocalizedString(@"Settings.PrivateChats", nil)];
    [self.auto_downlod_audio_group setTitle:NSLocalizedString(@"Settings.Groups", nil)];
    
    
     NSButtonCell *localizable = [self.send_message_as cellAtRow:0 column:0];
    [localizable setTitle:NSLocalizedString(@"Settings.SendAsEnter", nil)];
    
    localizable = [self.send_message_as cellAtRow:1 column:0];
    [localizable setTitle:NSLocalizedString(@"Settings.SendAsCmdEnter", nil)];
    
    
    
    localizable = [self.online_settings cellAtRow:0 column:0];
    [localizable setTitle:NSLocalizedString(@"Settings.OnlineFocused", nil)];
    
    localizable = [self.online_settings cellAtRow:1 column:0];
    [localizable setTitle:NSLocalizedString(@"Settings.OnlineLaunch", nil)];
    
   
    
    [self.sound_effects_checkbox setTitle:NSLocalizedString(@"Settings.SoundEffects", nil)];
    [self.launch_on_startup setTitle:NSLocalizedString(@"Settings.iCloudSynch", nil)];
    [self.statusBarIcon setTitle:NSLocalizedString(@"Settings.StatusBarIcon", nil)];
    
    [self.online_when_desc setStringValue:NSLocalizedString(@"Settings.online_when_desc", nil)];
    [self.auto_download_desc setStringValue:NSLocalizedString(@"Settings.auto_download_desc", nil)];
    [self.video_desc setStringValue:NSLocalizedString(@"Settings.video_desc", nil)];
    [self.documents_desc setStringValue:NSLocalizedString(@"Settings.documents_desc", nil)];
    [self.voice_messages_desc setStringValue:NSLocalizedString(@"Settings.voice_messages_desc", nil)];
    [self.file_size_limit_desc setStringValue:NSLocalizedString(@"Settings.file_size_limit_desc", nil)];
    [self.send_message_desc setStringValue:NSLocalizedString(@"Settings.send_message_desc", nil)];
    [self.save_documents_to_desc setStringValue:NSLocalizedString(@"Settings.save_documents_to_desc", nil)];
    [self.sound_notifications_desc setStringValue:NSLocalizedString(@"Settings.sound_notifications_desc", nil)];
    [self.other_desc setStringValue:NSLocalizedString(@"Settings.other_desc", nil)];
    
    
    
     [self.cache_desc setStringValue:NSLocalizedString(@"Settings.cache_desc", nil)];
     [self.sessions_desc setStringValue:NSLocalizedString(@"Settings.sessions_desc", nil)];
     [self.cache_sub_desc setStringValue:NSLocalizedString(@"Settings.cache_sub_desc", nil)];
     [self.sessions_sub_desc setStringValue:NSLocalizedString(@"Settings.sessions_sub_desc", nil)];
     [self.account_desc setStringValue:NSLocalizedString(@"Settings.account_desc", nil)];
    
    
    [self.choose_desc setTitle:NSLocalizedString(@"Settings.chooseFolder", nil)];
    
    
    [self.clear_all_the_cache_button setTitle:NSLocalizedString(@"Settings.clear_all_the_cache_button", nil)];
    [self.terminate_all_other_sessions_button setTitle:NSLocalizedString(@"Settings.terminate_all_other_sessions_button", nil)];
    [self.log_out_button setTitle:NSLocalizedString(@"Settings.log_out_button", nil)];
    
    
    NSTabViewItem *item = [self.tabView tabViewItemAtIndex:0];
    [item setLabel:NSLocalizedString(@"Settings.Settings", nil)];
    
    item = [self.tabView tabViewItemAtIndex:1];
    [item setLabel:NSLocalizedString(@"Settings.BlackList", nil)];
    
    
    [self.generalToolItem setLabel:NSLocalizedString(@"Settings.General", nil)];
    [self.accountToolItem setLabel:NSLocalizedString(@"Settings.Account", nil)];
    
    
    self.blocked_table_view.removeButton = self.remove_from_block_button;
    
    [self.chat_settings_view setFrameOrigin:NSMakePoint(0, 30)];
    
    [self.security_settings_view setFrameOrigin:NSMakePoint(-5, self.security_settings_view.frame.size.height-70)];
    
    
    [self.window.contentView addSubview:self.chat_settings_view];
    [self.window.contentView addSubview:self.security_settings_view];
    
    
    [self updateUI];
    
    [self updateAction];

    
    
    [self.tool_bar setSelectedItemIdentifier:@"general"];

    
    // [self.window.contentView setHidden:NO];
    
    [super windowDidLoad];
    

    
    LSSharedFileListAddObserver(LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL),
                                CFRunLoopGetMain(),
                                kCFRunLoopDefaultMode,
                                ListChanged,
                                (__bridge void *)(self));
    
    
    self.window.title = NSLocalizedString(@"Preferences", nil);
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [SettingsArchiver addEventListener:self];
}

-(void)didChangeSettingsMask:(SettingsMask)mask {
    [self updateUI];
}

static void ListChanged(LSSharedFileListRef inList, void *context) {
    [(__bridge SettingsWindowController *)context updateUI];
}


-(void)updateUI {
    
    
    [self.sound_notification_title setHidden:!([NSUserNotification class] && [NSUserNotificationCenter class])];
    [self.sound_notifications_button setHidden:!([NSUserNotification class] && [NSUserNotificationCenter class])];
    
    [self.open_links_in_background setState:[SettingsArchiver checkMaskedSetting:OpenLinksInBackground]];
    
    [self.convertEmoji setState:[SettingsArchiver checkMaskedSetting:EmojiReplaces]];
    
    [self.auto_downlod_video_group setState:[SettingsArchiver checkMaskedSetting:AutoGroupVideo]];
    [self.auto_downlod_video_private setState:[SettingsArchiver checkMaskedSetting:AutoPrivateVideo]];
    
    [self.auto_downlod_audio_group setState:[SettingsArchiver checkMaskedSetting:AutoGroupAudio]];
    [self.auto_downlod_audio_private setState:[SettingsArchiver checkMaskedSetting:AutoPrivateAudio]];
    
    [self.auto_downlod_documents_group setState:[SettingsArchiver checkMaskedSetting:AutoGroupDocuments]];
    [self.auto_downlod_documents_private setState:[SettingsArchiver checkMaskedSetting:AutoPrivateDocuments]];
    
    
    [self.sound_effects_checkbox setState:[SettingsArchiver checkMaskedSetting:SoundEffects]];
    
    [self.send_message_as selectCellWithTag:[SettingsArchiver contain:SendEnter | SendCmdEnter]];
    [self.online_settings selectCellWithTag:[SettingsArchiver contain:OnlineForever | OnlineFocused]];
    
    [self.launch_on_startup setState:[SettingsArchiver checkMaskedSetting:iCloudSynch]];
    
    [self.statusBarIcon setState:[SettingsArchiver checkMaskedSetting:StatusBarIcon]];
    
    [self.auto_download_limit selectItemAtIndex:[self indexForAutoDowloadSize]];
    
    [self.markedInputText setState:[SettingsArchiver checkMaskedSetting:MarkedInputText]];
    
    NSMenuItem *item = [self.documents_folder_button itemAtIndex:0];
    
    NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[SettingsArchiver documentsFolder]];
    [iconImage setSize:NSMakeSize(16,16)];
    
    item.title = [[SettingsArchiver documentsFolder] lastPathComponent];
    
    item.image = iconImage;
    
    [self.sound_notifications_button removeAllItems];
    
    [self.documents_folder_button selectItemAtIndex:0];
    
    NSArray *list = soundsList();
    
      
    for (int i = 0; i < list.count; i++) {
        [self.sound_notifications_button addItemWithTitle:NSLocalizedString(list[i], nil)];
        if(i == 0) {
            [[self.sound_notifications_button menu] addItem:[NSMenuItem separatorItem]];
        }
    }

}

-(void)showWindowWithAction:(SettingsWindowAction)action {
    
    self.action = action;
    
    [self showWindow:self];
    
    [self updateAction];

}

-(void)updateAction {
    if(self.action == SettingsWindowActionChatSettings) {
        [self chatSettingAction:nil];
    } else if(self.action == SettingsWindowActionSecuritySettings) {
        [self securityAction:nil];
        
        [self.tabView selectTabViewItemAtIndex:0];
    } else {
        [self securityAction:nil];
        
        [self.tabView selectTabViewItemAtIndex:1];
    }
}

-(void)showWindow:(id)sender {
    [super showWindow:sender];
}

-(int)indexForAutoDowloadSize {
    NSUInteger current_limit = [SettingsArchiver autoDownloadLimitSize];
    
    int index = 0;
    
    switch (current_limit) {
        case DownloadLimitSize50:
            index = 1;
            break;
        case DownloadLimitSize100:
            index = 2;
            break;
        case DownloadLimitSize1000:
            index = 3;
            break;
        default:
            break;
    }
    
    return index;
}

-(DownloadLimitSize)downloadSizeForIndex:(NSInteger)index {
    DownloadLimitSize limit = DownloadLimitSize10;
    
    switch (index) {
        case 1:
            limit = DownloadLimitSize50;
            break;
        case 2:
            limit = DownloadLimitSize100;
            break;
        case 3:
            limit = DownloadLimitSize1000;
            break;
        default:
            break;
    }

    
    return limit;
}
- (IBAction)launchOnStartup:(id)sender {
    [SettingsArchiver addOrRemoveSetting:iCloudSynch];
    
    [self updateUI];
}

- (IBAction)changeStatusBarIcon:(id)sender {
    [SettingsArchiver addOrRemoveSetting:StatusBarIcon];
    
    [self updateUI];
}


- (IBAction)autoDownloadGroupVideo:(id)sender {
    [SettingsArchiver addOrRemoveSetting:AutoGroupVideo];
}

- (IBAction)autoDownloadPrivateVideo:(id)sender {
    [SettingsArchiver addOrRemoveSetting:AutoPrivateVideo];
}
- (IBAction)autoDownloadGroupAudio:(id)sender {
    [SettingsArchiver addOrRemoveSetting:AutoGroupAudio];
}
- (IBAction)autoDownloadPrivateAudio:(id)sender {
    [SettingsArchiver addOrRemoveSetting:AutoPrivateAudio];
}
- (IBAction)autoDownloadGroupDocuments:(id)sender {
    [SettingsArchiver addOrRemoveSetting:AutoGroupDocuments];
}
- (IBAction)autoDownloadPrivateDocuments:(id)sender {
    [SettingsArchiver addOrRemoveSetting:AutoPrivateDocuments];
}
- (IBAction)checkMarkedInputtext:(id)sender {
    [SettingsArchiver addOrRemoveSetting:MarkedInputText];
}

- (IBAction)soundEffectCheckbox:(id)sender {
[SettingsArchiver addOrRemoveSetting:SoundEffects];
}
- (IBAction)convertEmoji:(id)sender {
    [SettingsArchiver addOrRemoveSetting:EmojiReplaces];
}

- (IBAction)openLinksInBackground:(id)sender {
    [SettingsArchiver addOrRemoveSetting:OpenLinksInBackground];
}
- (IBAction)sendMessageAs:(NSMatrix *)sender {
    [SettingsArchiver addOrRemoveSetting:(SettingsMask)sender.selectedTag depends:SendEnter | SendCmdEnter];
}
- (IBAction)onlineSettings:(NSMatrix *)sender {
    [SettingsArchiver addOrRemoveSetting:(SettingsMask)sender.selectedTag depends:OnlineForever | OnlineFocused];
}
- (IBAction)autoOpenDocuments:(id)sender {
   [SettingsArchiver addOrRemoveSetting:AutoOpenDocuments];
}
- (IBAction)downloadLimitChanged:(NSPopUpButton *)sender {
    [SettingsArchiver setAutoDownloadLimitSize:[self downloadSizeForIndex:[sender indexOfSelectedItem]]];
}
- (IBAction)clearCache:(id)sender {
    [Storage saveEmoji:[NSMutableArray array]];
    [Storage saveInputTextForPeers:[NSMutableDictionary dictionary]];
    [ImageStorage clearCache];
}
- (IBAction)terminateSessions:(id)sender {
    
    confirm(NSLocalizedString(@"Confirm", nil), NSLocalizedString(@"Confirm.TerminateSessions", nil), ^ {
        [RPCRequest sendRequest:[TLAPI_auth_resetAuthorizations create] successHandler:^(RPCRequest *request, id response) {
            
            alert(NSLocalizedString(@"Success", nil), NSLocalizedString(@"Confirm.SuccessResetSessions", nil));
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            alert(NSLocalizedString(@"Alert.Error", nil), NSLocalizedString(@"Auth.CheckConnection", nil));
            
        } timeout:5];
    },nil);
    
    
}
- (IBAction)logOut:(id)sender {
    confirm(NSLocalizedString(@"Confirm", nil),NSLocalizedString(@"Confirm.ConfirmLogout", nil), ^ {
        [self.window close];
        [[Telegram delegate] logoutWithForce:NO];
    },nil);
    
}
- (IBAction)editDocumentsFolder:(NSPopUpButton *)sender {
    
    if(sender.selectedTag == 1000) {
        [FileUtils showChooseFolderPanel:^(NSString *result) {
            
            [sender selectItemAtIndex:0];
            
            if(!result)
                return;
            
            if( [SettingsArchiver setDocumentsFolder:result]) {
                
                [self updateUI];
                
            } else {
                alert(NSLocalizedString(@"Settings.CantUpdateFolder", nil), NSLocalizedString(@"Settings.ChooseAnotherFolder", nil));
            }
            
            MTLog(@"%@",result);
            
        } forWindow:self.window];
    }
}

- (IBAction)didChangedSoundNotification:(NSPopUpButton *)sender {
    NSUInteger index = [sender indexOfItem:sender.selectedItem];
    
    if(index > 1) --index;
 
    NSArray *list = soundsList();
    
    if(index < list.count && (list.count == sender.itemArray.count-1)) {
        if([SettingsArchiver setSoundNotification:list[index]]) {
            
            [[NSSound soundNamed:[SettingsArchiver soundNotification]] play];
            
            [self updateUI];
        }
        
        
    }
}
- (IBAction)securityAction:(id)sender {
    
    [self.chat_settings_view setHidden:YES];
    
    
    float height = self.security_settings_view.frame.size.height+80;
    
    [self updateWindowWithHeight:height animate:sender != nil];
    
    [self.security_settings_view setHidden:NO];

    
}
- (IBAction)chatSettingAction:(id)sender {
   
    
    float height = self.chat_settings_view.frame.size.height+40;
    
    [self.security_settings_view setHidden:YES];
    
    [self updateWindowWithHeight:height animate:sender != nil];
    
    
    [self.chat_settings_view setHidden:NO];
    
    
}



- (IBAction)addBlockedUser:(id)sender {
    
    NSMutableArray *filter = [[NSMutableArray alloc] init];
    
    for (TL_contactBlocked *contact in self.blocked_table_view.blockedList) {
        [filter addObject:@(contact.user_id)];
    }
    
}


- (IBAction)removeBlockedUsers:(id)sender {
    [self.blocked_table_view unblockSelected];
}

-(void)updateWindowWithHeight:(float)height animate:(BOOL)animate {
    
     NSRect frame = [self.window frame];
    
    float dif = abs(frame.size.height - height);
    
    if(frame.size.height > height) {
        frame.origin.y+=dif;
    } else {
        frame.origin.y-=dif;
    }
    
    frame.size.height = height;
    
    [self.window setFrame:frame display:YES animate:animate];
}

@end
