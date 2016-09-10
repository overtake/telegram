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
#import "TGArchivedStickersViewController.h"

#import "TGStickerPackRowItem.h"
#import "TGStickerPackRowView.h"

@interface TGStickersSettingsViewController ()<TGMovableTableDelegate>
{
     NSMutableArray *_archivedSets;
     int _archivedCount;
}
@property (nonatomic,strong) TGMovableTableView *tableView;
@property (nonatomic,assign) BOOL needSaveOrder;

@property (nonatomic,strong) GeneralSettingsRowItem *archivedItem;

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
    
    [RPCRequest sendRequest:[TLAPI_messages_reorderStickerSets createWithFlags:0 order:reoder] successHandler:^(id request, id response) {
        
        
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
    
    [items addObject:[[TGGeneralRowItem alloc] initWithHeight:20]];
    
    
    weak();
    
    __block NSUInteger nFeaturedSets = 0;
    __block NSArray *fsets = nil;
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        
        nFeaturedSets = [[transaction objectForKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION] count];
        fsets = [transaction objectForKey:@"featuredSets" inCollection:STICKERS_COLLECTION];
    }];
    
    if(fsets.count > 0) {
        [items addObject:[[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNextBadge callback:^(TGGeneralRowItem *item) {
            
            TGFeaturedStickersViewController *featured = [[TGFeaturedStickersViewController alloc] init];
            
            [weakSelf.navigationViewController pushViewController:featured animated:YES];
            
        } description:NSLocalizedString(@"Stickers.Featured", nil) subdesc:nFeaturedSets > 0 ? [NSString stringWithFormat:@"%ld",nFeaturedSets] : nil height:42 stateback:nil]];
    }
    
    
    
    TGArchivedStickersViewController *featured = [[TGArchivedStickersViewController alloc] init];
    
    _archivedItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        [weakSelf.navigationViewController pushViewController:featured animated:YES];
        
        [featured addSets:_archivedSets];
        
    } description:NSLocalizedString(@"Stickers.Archived", nil) subdesc:@"" height:42 stateback:nil];
    
    _archivedItem.locked = YES;
    
    [[featured loadNext:0]  startWithNext:^(TL_messages_archivedStickers *next) {
        
        _archivedCount = next.n_count;
        _archivedSets = next.sets;
        _archivedItem.locked = NO;
        [_archivedItem setSubdescString:_archivedCount > 0 ? [NSString stringWithFormat:@"%d",_archivedCount] : @""];
        [_tableView reloadItem:_archivedItem];
        
    }];
    
    [items addObject:_archivedItem];
    
    [items addObject:[[TGGeneralRowItem alloc] initWithHeight:20]];

    
    
   
    
    
    [packs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TGStickerPackRowItem *item = [[TGStickerPackRowItem alloc] initWithObject:obj];
        item.editable = self.action.isEditable;
        [items addObject:item];
        
    }];
    
    [self insertPart:items];
    
    
}

-(void)insertPart:(NSMutableArray *)packs {
    
    NSArray *current = [packs subarrayWithRange:NSMakeRange(0, MIN(20,packs.count))];
                                                        
    [packs removeObjectsInArray:current];
    
    [current enumerateObjectsUsingBlock:^(TGStickerPackRowItem *obj, NSUInteger idx, BOOL *stop) {
        
        obj.editable = self.action.isEditable;
        
    }];
    
    [_tableView addItems:current];
    
    if(packs.count == 0) {
        [_tableView addItems:@[[[TGGeneralRowItem alloc] initWithHeight:20]]];
        [_tableView addItems:@[[[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Stickers.ArtistDesc", nil) flipped:YES]]];

    }
    
    if(packs.count > 0) {
        dispatch_after_seconds(0.2, ^{
            [self insertPart:packs];
        });
    }
    
}

-(void)removeStickerPack:(TGStickerPackRowItem *)item {
    
    BOOL isDefPack = (item.set.flags & (1 << 2)) == (1 << 2);
    
    NSAlert *alert = [NSAlert alertWithMessageText:appName() informativeText:[NSString stringWithFormat:NSLocalizedString(isDefPack ? @"Stickers.ArchiveAlert" : @"Stickers.RemoveOrArchive", nil),item.set.title] block:^(id result) {
        if([result intValue] == 1000 && !isDefPack)
        {
            [self showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_messages_uninstallStickerSet createWithStickerset:item.inputSet] successHandler:^(id request, id response) {
                
                [_tableView removeItemAtIndex:[_tableView indexOfObject:item] animated:YES];
                
                [TGModernESGViewController reloadStickers];
                
                [self hideModalProgress];
                
            } errorHandler:^(id request, RpcError *error) {
                [self hideModalProgress];
            } timeout:10];
        }
        else if(([result intValue] == 1001 && !isDefPack) || ([result intValue] == 1000 && isDefPack)) {
            [self showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_messages_installStickerSet createWithStickerset:item.inputSet archived:YES] successHandler:^(id request, id response) {
                
                [_tableView removeItemAtIndex:[_tableView indexOfObject:item] animated:YES];
                
                [TGModernESGViewController reloadStickers];
                
                
                [_archivedSets insertObject:[TL_stickerSetCovered createWithSet:item.set cover:[item.stickers firstObject]] atIndex:0];
                
                [_archivedItem setSubdescString:++_archivedCount > 0 ? [NSString stringWithFormat:@"%d",_archivedCount] : @""];
                [_tableView reloadItem:_archivedItem];
                
                [self hideModalProgress];
                
            } errorHandler:^(id request, RpcError *error) {
                [self hideModalProgress];
            } timeout:10];
        } else {
            
        }
        
    }];
    
    if(isDefPack) {
        [alert addButtonWithTitle:NSLocalizedString(@"Stickers.Archive", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    } else {
        [alert addButtonWithTitle:NSLocalizedString(@"Stickers.Remove", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Stickers.Archive", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    }
    
    [alert show];
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
        
        [[TGModernESGViewController stickersSignal:item.set] startWithNext:^(id next) {
            TGStickerPackModalView *modalView = [[TGStickerPackModalView alloc] init];

            [modalView show:self.view.window animated:YES stickerPack:[TL_messages_stickerSet createWithSet:item.pack[@"set"] packs:nil documents:next] messagesController:appWindow().navigationController.messagesViewController];
        }];
    }
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

@end
