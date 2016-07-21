//
//  TGArchivedStickersViewController.m
//  Telegram
//
//  Created by keepcoder on 21/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGArchivedStickersViewController.h"
#import "TGSettingsTableView.h"
#import "TGFeaturedStickerPackRowItem.h"
#import "TGModernESGViewController.h"
@interface TGArchivedStickersViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,assign) int totalCount;
@end

@implementation TGArchivedStickersViewController


-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"Stickers.Archived", nil)];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    [self.view addSubview:_tableView.containerView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Notification addObserver:self selector:@selector(changedArchivedStickers:) name:ARCHIVE_STICKERS_CHANGED];
    
    [_tableView removeAllItems:NO];
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:NO];
    
    GeneralSettingsBlockHeaderItem *header = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Stickers.ArchivedDesc", nil) flipped:NO] ;
    [header setAligment:NSCenterTextAlignment];
    
    [_tableView addItem:header tableRedraw:NO];
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:NO];
    
    
    [_tableView reloadData];
    
    weak();
    
    [_tableView.scrollView setScrollWheelBlock:^{
       
        if(weakSelf.tableView.scrollView.isNeedUpdateBottom) {
            
        }
        
    }];


}


-(void)changedArchivedStickers:(NSNotification *)notification {
    NSArray *sets = notification.userInfo[KEY_STICKERSET];
    NSDictionary *stickers = notification.userInfo[KEY_DATA];
    
    [sets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TGFeaturedStickerPackRowItem *item = [[TGFeaturedStickerPackRowItem alloc] initWithObject:@{@"set":obj,@"stickers":stickers[@(obj.n_id)],@"added":@(NO),@"unread":@(NO)} ];
        
        BOOL insert = [_tableView insert:item atIndex:3 tableRedraw:YES];
        
        if(!insert) {
            
            item = [_tableView itemByHash:item.hash];
            item.isAdded = NO;
            NSUInteger index = [_tableView positionOfItem:[_tableView itemByHash:item.hash]];
            
            [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        
    }];

}



-(void)addSets:(NSArray *)sets  {
    
    NSMutableArray *signals = [NSMutableArray array];
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSet *set, NSUInteger idx, BOOL * _Nonnull stop) {
        [signals addObject:[[MTNetwork instance] requestSignal:[TLAPI_messages_getStickerSet createWithStickerset:[TL_inputStickerSetID createWithN_id:set.n_id access_hash:set.access_hash]]]];
    }];
    
    
    [[SSignal combineSignals:signals] startWithNext:^(NSArray *next) {
        
        [next enumerateObjectsUsingBlock:^(TL_messages_stickerSet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TGFeaturedStickerPackRowItem *item = [[TGFeaturedStickerPackRowItem alloc] initWithObject:@{@"set":obj.set,@"stickers":obj.documents,@"added":@(NO),@"unread":@(NO)} ];
            
            [_tableView addItem:item tableRedraw:NO];
            
        }];
        
        [_tableView reloadData];
        
    }];
   
    
}


-(SSignal *)loadNext:(long)offsetId {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        SSignal *signal = [[MTNetwork instance] requestSignal:[TLAPI_messages_getArchivedStickers createWithOffset_id:offsetId limit:1000]];
        
        return [signal startWithNext:^(TL_messages_archivedStickers *next) {
            
            _totalCount = next.n_count;
            
            [subscriber putNext:next];
        }];
        
    }];
}


-(void)_didStackRemoved {
    [Notification removeObserver:self];
    [_tableView clear];
}

@end
