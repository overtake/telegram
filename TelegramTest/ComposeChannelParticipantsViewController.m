//
//  ComposeChannelParticipantsViewController.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeChannelParticipantsViewController.h"
#import "SelectUsersTableView.h"

@interface ComposeChannelParticipantsViewController ()<SelectTableDelegate,ComposeBehaviorDelegate>
@property (nonatomic,strong) SelectUsersTableView *tableView;
@property (nonatomic,strong) RPCRequest *request;

@property (nonatomic,assign) int offset;
@end

@implementation ComposeChannelParticipantsViewController

-(void)loadView {
    [super loadView];
    
    _tableView = [[SelectUsersTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    
    
}

-(void)behaviorDidEndRequest:(id)response {
    
    [self.tableView removeSelectedItems];
    [self selectTableDidChangedItem:nil];
    [self hideModalProgress];
    
    [[FullChatManager sharedManager] loadIfNeed:[(TLChat *)self.action.object n_id] force:YES];
    
}

-(void)behaviorDidStartRequest {
    [self showModalProgress];
}

-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    self.action.behavior.delegate = self;
    
    [_tableView removeAllItems:YES];
    
    [self.doneButton setDisable:YES];
    
    [_tableView setSelectLimit:action.behavior.limit];
    _tableView.selectDelegate = self;
    
    [self setLoading:YES];
    
    _offset = 0;
    
    [self loadNext];
    
}

-(void)selectTableDidChangedItem:(id)item {
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    [self.tableView.selectedItems enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL *stop) {
        
        [users addObject:obj.user];
        
    }];
    
    if(!self.action.result)
        self.action.result = [[ComposeResult alloc] initWithMultiObjects:users];
    else
        self.action.result.multiObjects = users;
    
    
    [self setCenterBarViewTextAttributed:self.action.behavior.centerTitle];
    
    [self.action.behavior composeDidChangeSelected];
    
    [self.doneButton setDisable:(self.action.result.multiObjects.count == 0 || [(TLUser *)self.action.result.multiObjects[0] n_id] == [UsersManager currentUserId]) || self.action.behavior.doneTitle.length == 0];
}



-(void)loadNext {
    TLChat *channel = self.action.object;
    
    [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:channel.inputPeer filter:self.action.reservedObject1 offset:_offset limit:100] successHandler:^(id request, TL_channels_channelParticipants *response) {
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *users = [[NSMutableDictionary alloc] init];
        
        [response.users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            users[@(obj.n_id)] = obj;
        }];
        
        [response.participants enumerateObjectsUsingBlock:^(TLChannelParticipant *obj, NSUInteger idx, BOOL *stop) {
            TLUser *user = users[@(obj.user_id)];
            
            [user rebuildNames];
            
            SelectUserItem *item = [[SelectUserItem alloc] initWithObject:user];
            
            [items addObject:item];
        }];
        
        [ASQueue dispatchOnMainQueue:^{
            [self.tableView readyCommon:items];
            
            [self setLoading:NO];
        }];
        
        
    } errorHandler:^(id request, RpcError *error) {
        
        
        [self setLoading:NO];
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_request cancelRequest];
    _request = nil;
    
}

@end
