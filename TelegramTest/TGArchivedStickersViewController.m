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
    NSArray<TL_stickerSetCovered *> *sets = notification.userInfo[KEY_STICKERSET];
    
    [sets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TL_stickerSetCovered *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TGFeaturedStickerPackRowItem *item = [[TGFeaturedStickerPackRowItem alloc] initWithObject:@{@"set":obj.set,@"stickers":@[obj.cover],@"added":@(NO),@"unread":@(NO)} ];
        
        BOOL insert = [_tableView insert:item atIndex:3 tableRedraw:YES];
        
        if(!insert) {
            
            item = [_tableView itemByHash:item.hash];
            item.isAdded = NO;
            
            [_tableView removeItem:item tableRedraw:YES];
            
        }
        
    }];

}



-(void)addSets:(NSArray *)sets  {
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSetCovered *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TGFeaturedStickerPackRowItem *item = [[TGFeaturedStickerPackRowItem alloc] initWithObject:@{@"set":obj.set,@"stickers":@[obj.cover],@"added":@(NO),@"unread":@(NO)}];
        
        [_tableView addItem:item tableRedraw:NO];
        
    }];
    
    [_tableView reloadData];
    
}


-(SSignal *)loadNext:(long)offsetId {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        SSignal *signal = [[MTNetwork instance] requestSignal:[TLAPI_messages_getArchivedStickers createWithFlags:0 offset_id:offsetId limit:1000]];
        
        return [[signal map:^id(id response) {
            return [response isKindOfClass:[TL_messages_archivedStickers class]] ? response : nil;
        }] startWithNext:^(TL_messages_archivedStickers *next) {
            
            _totalCount = next.n_count;
            
            [subscriber putNext:next];
        }];
        
    }] ;
}


-(void)_didStackRemoved {
    [Notification removeObserver:self];
    [_tableView clear];
}

@end
