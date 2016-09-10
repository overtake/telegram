//
//  TGFeaturedStickersViewController.m
//  Telegram
//
//  Created by keepcoder on 24/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGFeaturedStickersViewController.h"
#import "TGSettingsTableView.h"
#import "TGFeaturedStickerPackRowItem.h"
#import "TGFeaturedStickerPackRowView.h"
@interface TGFeaturedStickersViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@end

@implementation TGFeaturedStickersViewController

-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"Stickers.Featured", nil)];
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __block NSArray<TL_stickerSetCovered *> *sets;
    
    __block NSArray *unread = [NSArray array];
    
    __block NSArray<TL_stickerSet *> *localSets = [NSArray array];
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        
        sets = [transaction objectForKey:@"featuredSets" inCollection:STICKERS_COLLECTION];
        
        NSDictionary *info  = [transaction objectForKey:@"modern_stickers" inCollection:STICKERS_COLLECTION];
        
        unread = [transaction objectForKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION];

        localSets = info[@"sets"];
        
    }];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:NO];
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSetCovered *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL isUnread = [unread indexOfObject:@(obj.set.n_id)] != NSNotFound;
        
        BOOL isAdded = [localSets indexOfObjectPassingTest:^BOOL(TL_stickerSet *s, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(s.n_id == obj.set.n_id) {
                 *stop = YES;
                
                return YES;
            }
           
            return  NO;
            
        }] != NSNotFound;
        
       TGFeaturedStickerPackRowItem *item = [[TGFeaturedStickerPackRowItem alloc] initWithObject: @{@"set":obj.set,@"stickers":@[obj.cover],@"added":@(isAdded),@"unread":@(isUnread)}];
        
        [_tableView addItem:item tableRedraw:NO];
        
    }];
    
    [_tableView reloadData];
    
    
    if(unread.count > 0) {
        [RPCRequest sendRequest:[TLAPI_messages_readFeaturedStickers createWithN_id:unread.mutableCopy] successHandler:^(id request, id response) {
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                [transaction removeObjectForKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION];
            }];
            
        } errorHandler:^(id request, RpcError *error) {
            
            
        }];
    }
    
}

-(void)dealloc {
    [_tableView clear];
}

@end
