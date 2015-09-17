//
//  ComposeChannelMembers.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeChannelMembersViewController.h"
#import "SelectUsersTableView.h"
@interface ComposeChannelMembersViewController ()<SelectTableDelegate>
@property (nonatomic,strong) SelectUsersTableView *tableView;
@property (nonatomic,strong) RPCRequest *request;

@property (nonatomic,assign) int offset;
@end

@implementation ComposeChannelMembersViewController
-(void)loadView {
    [super loadView];
    
    _tableView = [[SelectUsersTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    
}

- (void) addScrollEvent {
    id clipView = [[_tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

- (void) removeScrollEvent {
    id clipView = [[_tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
}

-(void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)notification {
    
    if([_tableView.scrollView isNeedUpdateBottom]) {
        [self loadNext];
    }
}


-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    
    [_tableView removeAllItems:YES];
    
    
    [_tableView setSelectLimit:0];
    _tableView.selectDelegate = self;
    
    [self setLoading:YES];
    
    _offset = 0;
    
    [self loadNext];
    
    [self addScrollEvent];
    
}

-(void)selectTableDidChangedItem:(SelectUserItem *)item {
    
    [[Telegram rightViewController] showUserInfoPage:item.user];
    
}



-(void)loadNext {
    TLChat *channel = self.action.object;
    
    if(!_request) {
        _request = [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:channel.inputPeer filter:[TL_channelParticipantsRecent create] offset:_offset limit:100] successHandler:^(id request, TL_channels_channelParticipants *response) {
            
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
                if(_offset == 0) {
                    [self.tableView readyCommon:items];
                    [self setLoading:NO];
                } else
                    [self.tableView addItems:items];
                
                
                
                _offset+= items.count;
                
                if(_offset >= response.n_count) {
                    [self removeScrollEvent];
                }
                
                _request = nil;
            }];
            
            
        } errorHandler:^(id request, RpcError *error) {
            
            [self setLoading:NO];
            _request = nil;
            
        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    }
    
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_request cancelRequest];
    _request = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setCenterBarViewText:NSLocalizedString(@"Channel.Members", nil)];
    [self.doneButton setStringValue:@""];
}
@end
