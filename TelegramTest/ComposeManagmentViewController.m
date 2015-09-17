//
//  ComposeManagmentViewController.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeManagmentViewController.h"

#include "TGSettingsTableView.h"
#import "TGUserContainerRowItem.h"
#import "ComposeActionAddChannelModeratorBehavior.h"
#import "SelectUserItem.h"
#import "ComposeActionAddChannelModeratorBehavior.h"
@interface ComposeManagmentViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@end

@implementation ComposeManagmentViewController


-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView.containerView];
    
    
}

-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    [_tableView removeAllItems:NO];
    
    
    TLChat *chat = action.object;
    
    if(chat.isAdmin) {
        GeneralSettingsRowItem *addModerator = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
            
            [[Telegram rightViewController] showComposeWithAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddChannelModeratorBehavior class] filter:@[] object:chat]];
            
        } description:NSLocalizedString(@"Channel.AddModerator", nil) height:62 stateback:^id(GeneralSettingsRowItem *item) {
            return nil;
        }];
        
        [_tableView addItem:addModerator tableRedraw:NO];
        
        GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.AddModeratorDescription", nil) height:62 flipped:YES];
        
        [_tableView addItem:description tableRedraw:NO];
        
        addModerator.xOffset = 30;
        description.xOffset = 30;
    }
    
   
    NSArray *sort = @[NSStringFromClass([TL_channelParticipantCreator class]),NSStringFromClass([TL_channelParticipantEditor class]),NSStringFromClass([TL_channelParticipantModerator class])];
    
    NSArray *admins = [self.action.result.multiObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [@([sort indexOfObject:[obj1 className]]) compare:@([sort indexOfObject:[obj2 className]])];
        
    }];
    
    
     [admins enumerateObjectsWithOptions:0 usingBlock:^(TL_channelParticipant *obj, NSUInteger idx, BOOL *stop) {
        
        TGUserContainerRowItem *item = [[TGUserContainerRowItem alloc] initWithUser:[[UsersManager sharedManager] find:obj.user_id]];
        
        item.height = 42;
        item.avatarHeight = 30;
        item.status = [obj isKindOfClass:[TL_channelParticipantCreator class]] ? NSLocalizedString(@"Channel.Creator", nil) : [obj isKindOfClass:[TL_channelParticipantModerator class]] ? NSLocalizedString(@"Channel.Moderator", nil) : [TL_channelParticipantEditor class] ? NSLocalizedString(@"Channel.Editor", nil) : @"";
        
        [_tableView addItem:item tableRedraw:NO];
        
        TLUser *user = item.user;
        
        item.stateCallback = ^{
          
            if(![obj isKindOfClass:[TL_channelParticipantCreator class]]) {
                ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddChannelModeratorBehavior class] filter:@[] object:chat reservedObjects:@[@(YES),obj]];
                
                action.result = [[ComposeResult alloc] initWithMultiObjects:@[user]];
                
                [[Telegram rightViewController] showComposeAddModerator:action];
            }
            
        };
        
    }];
    
    
    
    [_tableView reloadData];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setCenterBarViewText:NSLocalizedString(@"Channel.Managment", nil)];
    
    [self.doneButton setStringValue:@""];
}

@end
