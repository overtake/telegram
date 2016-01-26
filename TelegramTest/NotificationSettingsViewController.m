//
//  NotificationSettingsViewController.m
//  Telegram
//
//  Created by keepcoder on 29.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//


@interface NotificationSettingsHeaderItem : TMRowItem

@end


@implementation NotificationSettingsHeaderItem

-(NSUInteger)hash {
    return 0;
}

@end

#import "NotificationSettingsViewController.h"
#import "NotificationConversationRowView.h"
#import "GeneralSettingsRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "TGSearchRowView.h"
@interface NotificationSettingsViewController ()<TMTableViewDelegate,SettingsListener,TMSearchTextFieldDelegate>
@property (nonatomic,strong) TMTableView *tableView;

@property (nonatomic,strong) TGSearchRowView *searchView;
@property (nonatomic,strong) TGSearchRowItem *searchItem;

@property (nonatomic,strong) NSArray *items;

@end

@implementation NotificationSettingsViewController


-(void)loadView {
    [super loadView];
    
    
    [self setCenterBarViewText:NSLocalizedString(@"Notifications", nil)];
    
    self.searchItem = [[TGSearchRowItem alloc] init];
    
    self.searchView = [[TGSearchRowView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.frame), 50)];
    
    [self.searchView setXOffset:30];
    
    self.searchItem.height = 40;
    
    [self.searchView setDelegate:self];
    
    _tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    _tableView.tm_delegate = self;
    [self.view addSubview:_tableView.containerView];
    
}

-(void)searchFieldTextChange:(NSString *)searchString {
    
    NSArray *sorted = self.items;
    
    
    if(self.tableView.count < 6)
    {
        return;
    }
    
    if(searchString.length > 0) {
        sorted = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NotificationConversationRowItem *evaluatedObject, NSDictionary *bindings) {
            
            return evaluatedObject.class == [NotificationConversationRowItem class] && (evaluatedObject.conversation.type == DialogTypeChat ? [evaluatedObject.conversation.chat.title searchInStringByWordsSeparated:searchString] : [evaluatedObject.conversation.user.fullName searchInStringByWordsSeparated:searchString]);
            
        }]];
    }
    
    
    
    
    NSRange range = NSMakeRange(6, self.tableView.list.count-6);
    
    NSArray *list = [self.tableView.list subarrayWithRange:range];
    
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.tableView removeItem:obj tableRedraw:NO];
    }];
    
    [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:self.tableView.defaultAnimation];
    
    
    [self.tableView insert:sorted startIndex:6 tableRedraw:YES];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.searchView.searchField setStringValue:@""];
    
    [self configure];
    
}


-(void)configure {
    
    [_tableView removeAllItems:YES];
    
    
    GeneralSettingsRowItem *resetAllNotifications = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        confirm(appName(), NSLocalizedString(@"NotificationSettings.ResetAllNotificationsConfirm", nil), ^{
            
            [self showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_account_resetNotifySettings create] successHandler:^(id request, id response) {
                
                [SettingsArchiver addSetting:PushNotifications];
                
                [self.items enumerateObjectsUsingBlock:^(NotificationConversationRowItem *obj, NSUInteger idx, BOOL *stop) {
                    
                    if([obj isKindOfClass:[NotificationConversationRowItem class]]) {
                        [obj.conversation updateNotifySettings:[TL_peerNotifySettings createWithMute_until:0 sound:obj.conversation.notify_settings.sound show_previews:obj.conversation.notify_settings.show_previews events_mask:obj.conversation.notify_settings.events_mask]];
                        
                        TL_conversation *original = [[DialogsManager sharedManager] find:obj.conversation.peer_id];
                        
                        
                        [original updateNotifySettings:[TL_peerNotifySettings createWithMute_until:0 sound:obj.conversation.notify_settings.sound show_previews:obj.conversation.notify_settings.show_previews events_mask:obj.conversation.notify_settings.events_mask]];
                    }

                }];
                
                
                [self hideModalProgressWithSuccess];
                
            } errorHandler:^(id request, RpcError *error) {
                
                [self hideModalProgress];
                
            } timeout:10];
            
            
        }, nil);
        
    } description:NSLocalizedString(@"NotificationSettings.ResetAllNotifications", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        
        
        return @"";
    }];
    
    
    GeneralSettingsRowItem *messagePreview = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        
        [SettingsArchiver addOrRemoveSetting:MessagesNotificationPreview];
        
    } description:NSLocalizedString(@"NotificationSettings.MessagePreview", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        
        
        return @([SettingsArchiver checkMaskedSetting:MessagesNotificationPreview] && [SettingsArchiver checkMaskedSetting:PushNotifications]);
    }];
    
    
    [messagePreview setEnabled:[SettingsArchiver checkMaskedSetting:PushNotifications]];
    
    
    GeneralSettingsRowItem *soundEffects = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        
        [SettingsArchiver addOrRemoveSetting:PushNotifications];
        
        [messagePreview setEnabled:[SettingsArchiver checkMaskedSetting:PushNotifications]];
        
        [self.tableView reloadData];
        
    } description:NSLocalizedString(@"Notifications", nil) height:82 stateback:^id(TGGeneralRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:PushNotifications]);
    }];
    
    
    
    
    GeneralSettingsRowItem *soundNotification = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeChoice callback:^(TGGeneralRowItem *item) {
        
    } description:NSLocalizedString(@"Settings.NotificationTone", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
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
    }
    
    soundNotification.menu = menu;

    
    GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"NotificationSettings.Description", nil) height:82 flipped:YES];
    
    
    
    
    
    [self.tableView addItem:soundEffects tableRedraw:NO];

    [self.tableView addItem:messagePreview tableRedraw:NO];
    [self.tableView addItem:soundNotification tableRedraw:NO];
    
    
    [self.tableView addItem:resetAllNotifications tableRedraw:NO];
    [self.tableView addItem:description tableRedraw:NO];
    
    [self.tableView addItem:self.searchItem tableRedraw:NO];
    
    [self.tableView reloadData];
    
    
    [[Storage manager] dialogsWithOffset:0 limit:1000 completeHandler:^(NSArray *d) {
        
        
        [ASQueue dispatchOnMainQueue:^{
            [self insertAll:d];
        }];
        
        
    }];

}

-(void)didChangeSettingsMask:(SettingsMask)mask {
    [self.tableView reloadData];
}


-(void)insertAll:(NSArray *)all {
    
    all = [all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type != 2 && self.type != 3"]];
    
    [all enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
        if(!obj.isInvisibleChannel)
            [self.tableView addItem:[[NotificationConversationRowItem alloc] initWithObject:obj] tableRedraw:NO];
        
    }];
    
    if(all.count > 6)
        _items = [self.tableView.list subarrayWithRange:NSMakeRange(5, self.tableView.list.count - 6)];
    
    [self.tableView reloadData];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.tableView removeAllItems:NO];
    
    [self.tableView reloadData];
    
    _items = nil;
}





- (void)addScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

- (void)removeScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return  [item respondsToSelector:@selector(height)] ? [[item valueForKey:@"height"] intValue] : 40;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(NotificationConversationRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[NotificationConversationRowItem class]]) {
        return [self.tableView cacheViewForClass:[NotificationConversationRowView class] identifier:@"NotificationConversationRowItem"];
    }
    
    if([item isKindOfClass:[GeneralSettingsRowItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsRowView class] identifier:@"GeneralSettingsDescriptionRowView"];
    }
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
    if([item isKindOfClass:[TGSearchRowItem class]]) {
        return self.searchView;
    }
    
    return nil;
    
}

- (void)selectionDidChange:(NSInteger)row item:(NotificationConversationRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(NotificationConversationRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(NotificationConversationRowItem *) item {
    return NO;
}

@end
