//
//  ComposeChannelBlackListViewController.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeChannelBlackListViewController.h"
#import "SelectUsersTableView.h"

@interface ComposeChannelBlackListViewController ()
@property (nonatomic,strong) SelectUsersTableView *tableView;
@property (nonatomic,strong) RPCRequest *request;

@property (nonatomic,assign) int offset;
@end

@implementation ComposeChannelBlackListViewController

-(void)loadView {
    [super loadView];
    
    _tableView = [[SelectUsersTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    
    
}


-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    
    [_tableView removeAllItems:NO];
    
    
    [self setLoading:YES];
    
    _offset = 0;
    
    [self loadNext];
    
}

-(void)loadNext {
    TLChat *channel = self.action.object;
    
    [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:channel.inputPeer filter:[TL_channelParticipantsKicked create] offset:_offset limit:100] successHandler:^(id request, TL_channels_channelParticipants *response) {
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *users = [[NSMutableDictionary alloc] init];
        
        [response.users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            users[@(obj.n_id)] = obj;
        }];
        
        [response.participants enumerateObjectsUsingBlock:^(TLChannelParticipant *obj, NSUInteger idx, BOOL *stop) {
            
            TLUser *user = users[@(obj.user_id)];
            
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
