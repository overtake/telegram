//
//  ComposeChannelParticipantsViewController.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeChannelParticipantsViewController.h"
#import "SelectUsersTableView.h"
#import "ComposeActionChannelMembersBehavior.h"
#import "TGSettingsTableView.h"
#import "TGUserContainerRowItem.h"
#import "ComposeActionAddGroupMembersBehavior.h"
#import "TGObjectContainerView.h"
#import "TGModernUserViewController.h"

@interface ComposeChannelParticipantsViewControllerView : TMView
@property (nonatomic,strong) TMTextField *textField;
@end

@implementation ComposeChannelParticipantsViewControllerView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textField = [TMTextField defaultTextField];
        
        [_textField setFont:TGSystemFont(14)];
        [_textField setAlignment:NSCenterTextAlignment];
        [_textField setTextColor:GRAY_TEXT_COLOR];
        [[_textField cell] setLineBreakMode:NSLineBreakByWordWrapping];
        [self addSubview:_textField];
        
        
        [_textField setHidden:YES];
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    NSSize size = [_textField.attributedStringValue sizeForTextFieldForWidth:newSize.width - 60];
    
    [_textField setFrame:NSMakeRect(30, 0, size.width, size.height)];
    
    [_textField setCenteredYByView:self];
    
}

@end

@interface ComposeChannelParticipantsViewController ()<ComposeBehaviorDelegate>
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) RPCRequest *request;



@property (nonatomic,assign) int offset;
@end

@implementation ComposeChannelParticipantsViewController

-(void)loadView {
   
    ComposeChannelParticipantsViewControllerView *mview = [[ComposeChannelParticipantsViewControllerView alloc] initWithFrame:self.frameInit];
    
    self.view = mview;
    
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    [mview.textField setStringValue:NSLocalizedString(@"Compose.ChannelEmptyBlackList", nil)];
    
}

-(void)didUpdatedEditableState {
    
    weak();
    
    [_tableView.list enumerateObjectsUsingBlock:^(TMRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[TMRowItem class]]) {
            [obj setEditable:weakSelf.action.isEditable];
        }
        
    }];
    
    [_tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        
        TMRowView *view = [rowView.subviews firstObject];
        
        TMRowItem *item = weakSelf.tableView.list[row];
        
        if([view isKindOfClass:[TGObjectContainerView class]]) {
            
            TGObjectContainerView *v = (TGObjectContainerView *) view;
            
            [v setEditable:item.isEditable animated:YES];
            
        }
        
    }];
}

-(void)behaviorDidEndRequest:(id)response {
    
    [self hideModalProgress];
 
}

-(void)behaviorDidStartRequest {
    [self showModalProgress];
}

-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
}


-(void)setLoading:(BOOL)isLoading {
    [super setLoading:isLoading];
    
    [self.doneButton setDisable:isLoading];
}

-(void)loadNext {
    TLChat *channel = self.action.object;
    
    
    
    weak();
    
    _request = [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:channel.inputPeer filter:self.action.reservedObject1 offset:_offset limit:100] successHandler:^(id request, TL_channels_channelParticipants *response) {
        
        if(request != weakSelf.request) {
            
            [ASQueue dispatchOnMainQueue:^{
                [weakSelf setLoading:NO];
            }];
            [weakSelf updateText];
            return;
        }
        
        
        weakSelf.request = nil;
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *users = [[NSMutableDictionary alloc] init];
        
        [response.users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            users[@(obj.n_id)] = obj;
        }];
        
        
        [response.participants enumerateObjectsUsingBlock:^(TLChannelParticipant *obj, NSUInteger idx, BOOL *stop) {
            TLUser *user = users[@(obj.user_id)];
            
            TGUserContainerRowItem *item = [[TGUserContainerRowItem alloc] initWithUser:user];
            item.type = SettingsRowItemTypeNone;
            item.editable = weakSelf.action.isEditable;
            [item setStateback:^id(TGGeneralRowItem *item) {
                
                TGUserContainerRowItem *userItem = (TGUserContainerRowItem *) item;
                
                return @(userItem.user.n_id != [UsersManager currentUserId] && (channel.isCreator  || (channel.isManager && (![obj isKindOfClass:[TL_channelParticipantCreator class]]  && ![obj isKindOfClass:[TL_channelParticipantModerator class]] && ![obj isKindOfClass:[TL_channelParticipantEditor class]])) ));
                
            }];
            
            __weak TGUserContainerRowItem *weakItem = item;
            
            [item setStateCallback:^ {
                
                if(weakSelf.action.isEditable) {
                    if([weakItem.stateback(weakItem) boolValue])
                        [weakSelf kickParticipant:weakItem];
                } else {
                    TGModernUserViewController *viewController = [[TGModernUserViewController alloc] initWithFrame:NSZeroRect];
                    
                    [viewController setUser:weakItem.user conversation:weakItem.user.dialog];
                    
                    [weakSelf.isDisclosureController ? weakSelf.rightNavigationController : weakSelf.navigationViewController pushViewController:viewController animated:YES];
                }

            }];
            
            item.height = 50;
            [items addObject:item];
        }];
        
        
        
        [ASQueue dispatchOnMainQueue:^{
            
            [weakSelf.tableView insert:items startIndex:weakSelf.tableView.count tableRedraw:NO];
            [weakSelf.tableView reloadData];
            
            [weakSelf setLoading:NO];
            
            [weakSelf updateText];
        }];
        
        
    } errorHandler:^(id request, RpcError *error) {
        [ASQueue dispatchOnMainQueue:^{
             [weakSelf setLoading:NO];
        }];
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    

}

-(void)updateText {
    ComposeChannelParticipantsViewControllerView *view = (ComposeChannelParticipantsViewControllerView *) self.view;
    
    [_tableView.containerView setHidden:_tableView.count == 1];
    [view.textField setHidden:_tableView.count > 1];
    
    [self.doneButton setHidden:_tableView.count == 1];
}

-(void)kickParticipant:(TGUserContainerRowItem *)participant {
        
    _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    [_tableView removeItem:participant];
    
    _tableView.defaultAnimation  = NSTableViewAnimationEffectNone;
    
    TLChat *chat = self.action.object;
    
    
    [self updateText];
    
    BOOL kick = [self.action.behavior isKindOfClass:[ComposeActionChannelMembersBehavior class]];
    
    
    
    [RPCRequest sendRequest:[TLAPI_channels_kickFromChannel createWithChannel:chat.inputPeer user_id:participant.user.inputUser kicked:kick] successHandler:^(id request, id response) {
        
        chat.chatFull.participants_count+= kick ? -1 : 1;
        chat.chatFull.kicked_count+= !kick ? -1 : 1;
        
        [[ChatFullManager sharedManager] requestChatFull:[chat n_id] force:YES];
        
        [[Storage manager] insertFullChat:chat.chatFull completeHandler:nil];
        
        
    } errorHandler:^(id request, RpcError *error) {
        
    }];
    
  
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    TLChat *chat = self.action.object;
    
    weak();
    
    [[ChatFullManager sharedManager] requestChatFull:[chat n_id] force:YES];
    
    self.action.behavior.delegate = self;
    
    [_request cancelRequest];
    _request = nil;
    
    [_tableView removeAllItems:YES];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    if([self.action.behavior isKindOfClass:[ComposeActionChannelMembersBehavior class]] && (chat.isManager)) {
        
        if(chat.chatFull.participants_count < maxChatUsers()) {
            GeneralSettingsRowItem *addMembersItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                NSMutableArray *filter = [[NSMutableArray alloc] init];
                
                [weakSelf.tableView.list enumerateObjectsUsingBlock:^(TGUserContainerRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if([obj isKindOfClass:[TGUserContainerRowItem class]]) {
                        [filter addObject:@(obj.user.n_id)];
                    }
                    
                    ComposePickerViewController *viewController = [[ComposePickerViewController alloc] initWithFrame:NSZeroRect];
                    
                    [viewController setAction:[[ComposeAction alloc]initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:filter object:chat.chatFull reservedObjects:@[chat]]];
                    
                    [weakSelf.navigationViewController pushViewController:viewController animated:YES];
                    
                }];
                
            } description:NSLocalizedString(@"Group.AddMembers", nil) height:42 stateback:nil];
            addMembersItem.textColor = BLUE_UI_COLOR;
            [_tableView addItem:addMembersItem tableRedraw:YES];
            
        }
        
        
        if(chat.username.length == 0 && chat.isCreator) {
            GeneralSettingsRowItem *inviteViaLink = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                ChatExportLinkViewController *export = [[ChatExportLinkViewController alloc] initWithFrame:NSZeroRect];
                
                [export setChat:chat.chatFull];
                
                [weakSelf.navigationViewController pushViewController:export animated:YES];
                
                
            } description:NSLocalizedString(@"Modern.Channel.InviteViaLink", nil) height:42 stateback:nil];
            inviteViaLink.textColor = BLUE_UI_COLOR;
            [_tableView addItem:inviteViaLink tableRedraw:YES];
            
        }
        
        if(!chat.isMegagroup) {
            GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Modern.Channel.ChannelMembersDescription", nil) height:42 flipped:YES];
            
            description.autoHeight = YES;
            
            [_tableView addItem:description tableRedraw:YES];
        }
        
         [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
    }
    

    
    [self setLoading:YES];
    
    _offset = 0;
    
    [self loadNext];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_request cancelRequest];
    _request = nil;
    
}

-(void)dealloc {
    [_tableView clear];
}

@end
