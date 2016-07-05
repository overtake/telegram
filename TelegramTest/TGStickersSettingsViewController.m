//
//  TGStickersSettingsViewController.m
//  Telegram
//
//  Created by keepcoder on 11.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGStickersSettingsViewController.h"
#import "GeneralSettingsDescriptionRowItem.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "TGImageView.h"
#import "TGMessagesStickerImageObject.h"
#import "TGStickerPackModalView.h"
#import "ComposeActionStickersBehavior.h"
#import "TGMovableTableView.h"
#import "TGModernESGViewController.h"
#import "GeneralSettingsRowItem.h"
#import "TGFeaturedStickersViewController.h"


#import "TGStickerPackRowItem.h"
#import "TGStickerPackRowView.h"

@interface TGStickersSettingsViewController ()<TGMovableTableDelegate>
@property (nonatomic,strong) TGMovableTableView *tableView;
@property (nonatomic,assign) BOOL needSaveOrder;



@end









@implementation TGStickersSettingsViewController


-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"Sticker.StickerSettings", nil)];
    
    _tableView = [[TGMovableTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView];
    
    _tableView.mdelegate = self;
    
    
    
}


-(void)stickersNeedFullReload:(NSNotification *)notification {
    
     [self reload];
   
}

-(void)stickersNeedReorder:(NSNotification *)notification {
    
    [self reload];
}

-(void)stickersNewPackAdded:(NSNotification *)notification {
    TL_messages_stickerSet *set = notification.userInfo[KEY_STICKERSET];
    
    TGStickerPackRowItem *item = [[TGStickerPackRowItem alloc] initWithObject:@{@"set":set.set,@"stickers":set.documents}];
    
    [_tableView insertItem:item atIndex:0];
    
}




-(void)didUpdatedEditableState {
    [super didUpdatedEditableState];
    
    [_tableView enumerateAvailableRowViewsUsingBlock:^(__kindof TMRowView *rowView, TMRowItem *rowItem, NSInteger row) {
        
        if([rowView isKindOfClass:[TGStickerPackRowView class]]) {
            TGStickerPackRowView *view = (TGStickerPackRowView *)rowView;
            
            [rowItem setEditable:self.action.isEditable];
            
            [view setEditable:rowItem.isEditable animated:YES];
        }
        
    }];
    
}

-(void)saveOrder {
    NSMutableArray *reoder = [NSMutableArray array];
    
    [_tableView enumerateAvailableRowViewsUsingBlock:^(__kindof TMRowView *rowView, TMRowItem *rowItem, NSInteger row) {
        
        if([rowView isKindOfClass:[TGStickerPackRowItem class]]) {
            TGStickerPackRowItem *item = (TGStickerPackRowItem *)rowItem;
            
            [reoder addObject:@(item.set.n_id)];
        }
        
        
    }];
    
    [Notification perform:STICKERS_REORDER data:@{KEY_ORDER:reoder}];
    
    [RPCRequest sendRequest:[TLAPI_messages_reorderStickerSets createWithOrder:reoder] successHandler:^(id request, id response) {
        
        
    } errorHandler:^(id request, RpcError *error) {
        
        
        
    }];
    
    _needSaveOrder = NO;

}

-(void)viewWillAppear:(BOOL)animated {
    
    if(!self.action)
        [self setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionStickersBehavior class]]];

    
    [super viewWillAppear:animated];
    
    _needSaveOrder = NO;
    
    [Notification addObserver:self selector:@selector(stickersNeedFullReload:) name:STICKERS_ALL_CHANGED];
    [Notification addObserver:self selector:@selector(stickersNeedReorder:) name:STICKERS_REORDER];
    [Notification addObserver:self selector:@selector(stickersNewPackAdded:) name:STICKERS_NEW_PACK];
    
    [self reload];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [Notification removeObserver:self];
    
    if(_needSaveOrder) {
        [self saveOrder];
    }
}

-(void)reload {
    NSMutableArray *packSets = [NSMutableArray array];
    
    NSArray *sets = [TGModernESGViewController allSets];
    
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSet *set, NSUInteger setIdx, BOOL * _Nonnull setStop) {
        
        NSArray *stickers = [TGModernESGViewController stickersWithId:set.n_id];
        if(stickers != nil) {
            NSDictionary *val = @{@"stickers":stickers,@"set":set};
            
            [packSets addObject:val];
        }
        
    }];
    
    
    
    [self reloadDataWithPacks:packSets];
}


-(void)reloadDataWithPacks:(NSArray *)packs {
    
    [_tableView removeAllItems];
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if(ACCEPT_FEATURE) {
        [items addObject:[[TGGeneralRowItem alloc] initWithHeight:20]];
        
        weak();
        
        __block NSUInteger nFeaturedSets = 0;
        
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            
            nFeaturedSets = [[transaction objectForKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION] count];
            
        }];
        
        [items addObject:[[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNextBadge callback:^(TGGeneralRowItem *item) {
            
            TGFeaturedStickersViewController *featured = [[TGFeaturedStickersViewController alloc] init];
            
            [weakSelf.navigationViewController pushViewController:featured animated:YES];
            
        } description:NSLocalizedString(@"Stickers.Featured", nil) subdesc:nFeaturedSets > 0 ? [NSString stringWithFormat:@"%ld",nFeaturedSets] : nil height:42 stateback:nil]];
        
        
        [items addObject:[[TGGeneralRowItem alloc] initWithHeight:20]];

    }
    
    
   
    
    
    [packs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TGStickerPackRowItem *item = [[TGStickerPackRowItem alloc] initWithObject:obj];
        item.editable = self.action.isEditable;
        [items addObject:item];
        
    }];
    
    [items addObject:[[TGGeneralRowItem alloc] initWithHeight:20]];
    [items addObject:[[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Stickers.ArtistDesc", nil) flipped:YES]];
    
    
    [_tableView addItems:items];
    
    
}

-(void)removeStickerPack:(TGStickerPackRowItem *)item {
    
    
    
    confirm(appName(), [NSString stringWithFormat:NSLocalizedString(@"Stickers.RemoveStickerAlert", nil),[item.pack[@"set"] title]], ^{
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_messages_uninstallStickerSet createWithStickerset:item.inputSet] successHandler:^(id request, id response) {
            
            
            [_tableView removeItemAtIndex:[_tableView indexOfObject:item] animated:YES];
            
            [TGModernESGViewController reloadStickers];
            
            [self hideModalProgress];
            
        } errorHandler:^(id request, RpcError *error) {
            [self hideModalProgress];
        } timeout:10];
        
    }, nil);
    
}


-(void)tableViewDidChangeOrder {
    
    
    _needSaveOrder = YES;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    

    
    TMRowView *view = [[item.viewClass alloc] initWithFrame:NSZeroRect];
    
    if([item respondsToSelector:@selector(updateItemHeightWithWidth:)]) {
        [(TGGeneralRowItem *)item updateItemHeightWithWidth:NSWidth(self.view.frame)];
    }
    
    if([view isKindOfClass:[TGStickerPackRowView class]]) {
        ((TGStickerPackRowView *)view).controller = self;
    }
    
    
    return view;
}

- (void)selectionDidChange:(NSInteger)row item:(TGStickerPackRowItem *) item {
    
    if([item isKindOfClass:[TGStickerPackRowItem class]]) {
        TGStickerPackModalView *modalView = [[TGStickerPackModalView alloc] init];
        [modalView setStickerPack:[TL_messages_stickerSet createWithSet:item.pack[@"set"] packs:nil documents:[item.pack[@"stickers"] mutableCopy]] forMessagesViewController:appWindow().navigationController.messagesViewController];
        [modalView show:self.view.window animated:YES];
    }
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

@end
