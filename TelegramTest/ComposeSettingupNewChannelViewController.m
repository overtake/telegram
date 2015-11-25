//
//  ComposeSettingupNewChannelViewController.m
//  Telegram
//
//  Created by keepcoder on 20.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeSettingupNewChannelViewController.h"
#import "TGSettingsTableView.h"
#import "TGChangeUserNameContainerView.h"
#import "NSAttributedString+Hyperlink.h"
@interface TGUserNameContainerRowItem : TGGeneralRowItem
@property (nonatomic,strong) TGChangeUserObserver *observer;
@end

@interface TGUserNameContainerRowView : TMRowView
@property (nonatomic,strong) TGChangeUserNameContainerView *container;
@end

@implementation TGUserNameContainerRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self =[super initWithFrame:frameRect]) {
        _container = [[TGChangeUserNameContainerView alloc] initWithFrame:self.bounds observer:nil];
        
        [self addSubview:_container];
    }
    
    return self;
}

-(void)redrawRow {
    [super redrawRow];
        
    TGUserNameContainerRowItem *item = (TGUserNameContainerRowItem *) [self rowItem];
    
    [_container setOberser:item.observer];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_container setFrameSize:newSize];
}

@end




@implementation TGUserNameContainerRowItem

-(Class)viewClass {
    return [TGUserNameContainerRowView class];
}


@end


@interface ComposeSettingupNewChannelViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) TGUserNameContainerRowItem *userNameContainerItem;
@property (nonatomic,strong) GeneralSettingsBlockHeaderItem *joinLinkItem;
@end

@implementation ComposeSettingupNewChannelViewController


-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    
    
}


-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    self.action.result = [[ComposeResult alloc] init];
    
    self.action.result.singleObject = @(YES);
    
    _userNameContainerItem = [[TGUserNameContainerRowItem alloc] initWithHeight:120];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(@"Channel.NewChannelSettingUpUserNameDescription", nil)  withColor:GRAY_TEXT_COLOR];
    
    [attr setFont:TGSystemFont(12) forRange:attr.range];
    
    [attr detectBoldColorInStringWithFont:TGSystemMediumFont(12)];
    
    
    _userNameContainerItem.observer = [[TGChangeUserObserver alloc] initWithDescription:attr placeholder:@"" defaultUserName:@""];
    
    
    [_userNameContainerItem.observer setNeedDescriptionWithError:^NSString *(NSString *error) {
        
        if([error isEqualToString:@"USERNAME_CANT_FIRST_NUMBER"])  {
            return NSLocalizedString(@"Channel.Username.InvalidStartsWithNumber", nil);
        } else if([error isEqualToString:@"USERNAME_IS_ALREADY_TAKEN"]) {
            return NSLocalizedString(@"Channel.Username.InvalidTaken", nil);
        } else if([error isEqualToString:@"USERNAME_MIN_SYMBOLS_ERROR"]) {
            return NSLocalizedString(@"Channel.Username.InvalidTooShort", nil);
        } else if([error isEqualToString:@"USERNAME_INVALID"]) {
            return NSLocalizedString(@"Channel.Username.InvalidCharacters", nil);
        } else if([error isEqualToString:@"UserName.avaiable"]) {
            return NSLocalizedString(@"Channel.Username.UsernameIsAvailable", nil);
        }
        
        return NSLocalizedString(error, nil);
        
    }];

    
    TL_chatInviteExported *export = self.action.reservedObject1;
    
    _joinLinkItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:export.link height:34 flipped:NO];
    _joinLinkItem.xOffset = 30;
    [_joinLinkItem setTextColor:TEXT_COLOR];
    [_joinLinkItem setFont:TGSystemFont(14)];
    _joinLinkItem.drawsSeparator = YES;
    
    _joinLinkItem.type = SettingsRowItemTypeNone;
    [_joinLinkItem setCallback:^(TGGeneralRowItem *item) {
        
        GeneralSettingsBlockHeaderItem *header = (GeneralSettingsBlockHeaderItem *) item;
        
        [TMViewController showModalProgressWithDescription:NSLocalizedString(@"Conversation.CopyToClipboard", nil)];
        
        NSPasteboard* cb = [NSPasteboard generalPasteboard];
        
        [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:item];
        [cb setString:header.header.string forType:NSStringPboardType];
        
        dispatch_after_seconds(0.2, ^{
            [TMViewController hideModalProgressWithSuccess];
        });
        
    }];
    
    weak();
    
    [_userNameContainerItem.observer setWillNeedSaveUserName:^(NSString *username) {
        if(username.length >= 5) {
            
            weakSelf.action.reservedObject2 = username;
           
            [weakSelf.action.behavior composeDidDone];
            
        }
    }];
    
    [_userNameContainerItem.observer setDidChangedUserName:^(NSString *username, BOOL accept) {
        
        weakSelf.action.reservedObject2 = username;
        
        if(!accept) {
            weakSelf.action.reservedObject2 = nil;
        }
        
    }];
    
    [_userNameContainerItem.observer setNeedApiObjectWithUserName:^id(NSString *username) {
        
        return [TLAPI_channels_checkUsername createWithChannel:[weakSelf.action.object inputPeer] username:username];
    }];

    
    [self reload];
}





-(void)reload {
    
    [self.tableView removeAllItems:NO];
    
    
    GeneralSettingsBlockHeaderItem *headerItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.TypeHeader", nil) height:60 flipped:NO];
    headerItem.xOffset = 30;
    
    
    GeneralSettingsRowItem *publicSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        

        self.action.result.singleObject = @(YES);
        
        [self reload];
        
    } description:NSLocalizedString(@"Channel.Public", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return self.action.result.singleObject;
    }];
    
    GeneralSettingsRowItem *privateSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
         self.action.result.singleObject = @(NO);
        
         [self reload];
        
    } description:NSLocalizedString(@"Channel.Private", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(![self.action.result.singleObject boolValue]);
    }];

    
    

    GeneralSettingsBlockHeaderItem *selectorDesc = [[GeneralSettingsBlockHeaderItem alloc] initWithString:[self.action.result.singleObject boolValue] ? NSLocalizedString(@"Channel.ChoiceTypeDescriptionPublic", nil) : NSLocalizedString(@"Channel.ChoiceTypeDescriptionPrivate", nil) height:42 flipped:YES];
    
    
    selectorDesc.xOffset = privateSelector.xOffset = publicSelector.xOffset = 30;
    
    
    
    
    [self.tableView addItem:headerItem tableRedraw:NO];
    [self.tableView addItem:publicSelector tableRedraw:NO];
    [self.tableView addItem:privateSelector tableRedraw:NO];
    [self.tableView addItem:selectorDesc tableRedraw:NO];
    
    
    if([self.action.result.singleObject boolValue]) {
        [self.tableView addItem:_userNameContainerItem tableRedraw:NO];
    } else {
        [self.tableView addItem:_joinLinkItem tableRedraw:NO];
        

        
        GeneralSettingsBlockHeaderItem *joinDescription = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.NewChannelSettingUpJoinLinkDescription", nil) height:42 flipped:YES];
        
        [self.tableView addItem:joinDescription tableRedraw:NO];
        
        joinDescription.xOffset = 30;
    }
   
    
    
    
    
    [self.tableView reloadData];
}

-(void)performEnter {
    
}

@end
