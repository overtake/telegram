//
//  TGAllStickersTableView.m
//  Telegram
//
//  Created by keepcoder on 25.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGAllStickersTableView.h"
#import "TGStickerImageView.h"
#import "TGMessagesStickerImageObject.h"
#import "EmojiViewController.h"
#import "StickersPanelView.h"
#import "TGStickerPreviewModalView.h"




@interface TGAllStickersTableView ()<TMTableViewDelegate>
@property (nonatomic,strong) TMView *noEmojiView;
@property (nonatomic,strong) NSMutableDictionary *stickers;
@property (nonatomic,strong) NSMutableArray *sets;
@property (nonatomic,assign) BOOL isCustomStickerPack;
@property (nonatomic,strong) TGStickerPreviewModalView *previewModal;
@property (nonatomic,assign) BOOL notSendUpSticker;
@end



@interface TGAllStickersTableItem : TMRowItem
@property (nonatomic,strong) NSMutableArray *stickers;
@property (nonatomic,strong) NSMutableArray *objects;

@property (nonatomic,assign) long packId;
@end

@implementation TGAllStickersTableItem


-(id)initWithObject:(NSArray *)object packId:(long)packId {
    if(self = [super initWithObject:object]) {
        _stickers = [object mutableCopy];
        _packId = packId;
        
        _objects = [[NSMutableArray alloc] init];
        
        [_stickers enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
            
            NSImage *placeholder = [[NSImage alloc] initWithData:obj.thumb.bytes];
                
            if(!placeholder)
                placeholder = [NSImage imageWithWebpData:obj.thumb.bytes error:nil];
                
            TGMessagesStickerImageObject *imgObj = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:placeholder];
                
            imgObj.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), 65);
                
            [_objects addObject:imgObj];
            
        }];
    }
    
    return self;
}
 

-(NSUInteger)hash {
    
    __block NSString *hashString = @"";
    
    [_stickers enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
        hashString = [hashString stringByAppendingFormat:@"%ld - ",obj.n_id];
    }];
    
    return [hashString hash];
}

@end



@interface TGAllStickerTableItemView : TMRowView
@property (nonatomic,strong) TGStickerImageView *imageView;
@property (nonatomic,weak) TGAllStickersTableView *tableView;

@end


@implementation TGAllStickerTableItemView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
    
    }
    
    return self;
}


static NSImage *hoverImage() {
    static NSImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[NSImage alloc] initWithSize:NSMakeSize(67, 67)];
        [image lockFocus];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, 67, 67) xRadius:3 yRadius:3];
        [NSColorFromRGB(0xf4f4f4) set];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

static NSImage *higlightedImage() {
    static NSImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[NSImage alloc] initWithSize:NSMakeSize(67, 67)];
        [image lockFocus];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, 67, 67) xRadius:3 yRadius:3];
        [NSColorFromRGB(0xdedede) set];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

-(void)redrawRow {
    
    
    [self removeAllSubviews];
    
    TGAllStickersTableItem *item = (TGAllStickersTableItem *)[self rowItem];
    
    __block int xOffset = 0;
    
    int width = round(NSWidth(self.bounds)/5);
    
    weak();
    
    [item.stickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BTRButton *button = [[BTRButton alloc] initWithFrame:NSMakeRect(xOffset, 0, width, NSHeight(self.bounds))];
        
        
        if(!_tableView.isCustomStickerPack) {
            [button setBackgroundImage:hoverImage() forControlState:BTRControlStateHover];
            [button setBackgroundImage:higlightedImage() forControlState:BTRControlStateHover];
        }
        
        TGStickerImageView *imageView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(xOffset, 0, width, NSHeight(self.bounds))];
        
        
        [button addBlock:^(BTRControlEvents events) {
            
            if(weakSelf.tableView.previewModal != nil) {
                [weakSelf.tableView.previewModal close:YES];
                weakSelf.tableView.previewModal = nil;
                
                return;
            }
            
            if(weakSelf.tableView.notSendUpSticker)
            {
                weakSelf.tableView.notSendUpSticker = NO;
                return;
            }
            
            if(!weakSelf.tableView.isCustomStickerPack || weakSelf.tableView.canSendStickerAlways)
                [appWindow().navigationController.messagesViewController sendSticker:item.stickers[idx] forConversation:appWindow().navigationController.messagesViewController.conversation addCompletionHandler:nil];
            
            if(weakSelf.tableView.canSendStickerAlways) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TMViewController closeAllModals];
                });
                
            }
            
            
        } forControlEvents:weakSelf.tableView.isCustomStickerPack ? BTRControlEventMouseUpOutside : BTRControlEventMouseUpInside];

        if(!weakSelf.tableView.isCustomStickerPack) {
            
            [button addBlock:^(BTRControlEvents events) {
                
                TGStickerPreviewModalView *preview = [[TGStickerPreviewModalView alloc] init];
                
                [preview setSticker:item.stickers[idx]];
                
                [preview show:appWindow() animated:YES];
                
                weakSelf.tableView.previewModal = preview;
                
            } forControlEvents:BTRControlEventLongLeftClick];
        }
        
        
        
        [imageView setFrameSize:[item.objects[idx] imageSize]];
        
        imageView.object = item.objects[idx];
        
        [imageView setCenterByView:button];
        
        [button addSubview:imageView];
            
        
        
        if([obj isKindOfClass:[TL_outDocument class]]) {
            BTRButton *removeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(width - image_RemoveSticker().size.width - 3, NSHeight(self.bounds) - image_RemoveSticker().size.height - 3, image_RemoveSticker().size.width, image_RemoveSticker().size.height)];
            
            [removeButton setBackgroundImage:image_RemoveSticker() forControlState:BTRControlStateNormal];
            [removeButton setBackgroundImage:image_RemoveStickerActive() forControlState:BTRControlStateHighlighted];
            
            
            [removeButton addBlock:^(BTRControlEvents events) {
                
                [weakSelf.tableView removeSticker:obj];
                
            } forControlEvents:BTRControlEventClick];
            
             [button addSubview:removeButton];

        }
        
        [self addSubview:button];
        
        xOffset+=width;
        
        
    }];
    
    
}

-(void)dealloc {
    
}

@end





@implementation TGAllStickersTableView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _stickers = [[NSMutableDictionary alloc] init];
        self.tm_delegate = self;
        
        [Notification addObserver:self selector:@selector(stickersNeedFullReload:) name:STICKERS_ALL_CHANGED];
        [Notification addObserver:self selector:@selector(stickersNeedReorder:) name:STICKERS_REORDER];
        [Notification addObserver:self selector:@selector(stickersNewPackAdded:) name:STICKERS_NEW_PACK];
        
    }
    
    return self;
}


-(void)stickersNeedFullReload:(NSNotification *)notification {
    [self load:YES];
}

-(void)stickersNeedReorder:(NSNotification *)notification {
    NSArray *order = notification.userInfo[KEY_ORDER];
    
    [_sets sortUsingComparator:^NSComparisonResult(TL_stickerSet *obj1, TL_stickerSet *obj2) {
        
        NSNumber *idx1 = @([order indexOfObject:@(obj1.n_id)]);
        NSNumber *idx2 = @([order indexOfObject:@(obj2.n_id)]);
        
        return [idx1 compare:idx2];
    }];
    
    [self reloadData];
}

-(void)stickersNewPackAdded:(NSNotification *)notification {
    TL_messages_stickerSet *set = notification.userInfo[KEY_STICKERSET];
    
    [_sets insertObject:set.set atIndex:0];
    
    _stickers[@(set.set.n_id)] = set.documents;
    
    
    [self save:_sets stickers:_stickers n_hash:[self stickersHash:_sets] saveSets:YES];
    
    [self reloadData];
}



-(NSScrollView *)containerView {
    return [super containerView];
}

-(void)load:(BOOL)force {
    
    if(_stickers.count == 0 || force) {
        
        _isCustomStickerPack = NO;
        
        weak();
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            NSDictionary *info  = [transaction objectForKey:@"modern_stickers" inCollection:STICKERS_COLLECTION];
            
            weakSelf.stickers = info[@"serialized"];
            
            if(!weakSelf.stickers)
                weakSelf.stickers = [NSMutableDictionary dictionary];
            
            weakSelf.sets = info[@"sets"];
            
        }];
        
        if(!isRemoteStickersLoaded() || force) {
            [RPCRequest sendRequest:[TLAPI_messages_getAllStickers createWithN_hash:[self stickersHash:_sets]] successHandler:^(RPCRequest *request, TL_messages_allStickers *response) {
                
                if(![response isKindOfClass:[TL_messages_allStickersNotModified class]]) {
                    
                    [self loadSetsIfNeeded:response.sets n_hash:response.n_hash];
               
                } else {
                    [self reloadData];
                }
                
                setRemoteStickersLoaded(YES);
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
            }];
            
            
        } else {
            [self reloadData];
        }
    } else {
        [self reloadData];
    }
    
}


-(void)save:(NSArray *)sets stickers:(NSDictionary *)stickers n_hash:(int)n_hash saveSets:(BOOL)saveSets {
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        
        NSMutableDictionary *serializedStickers = [_stickers mutableCopy];
        
        NSMutableDictionary *data = [[transaction objectForKey:@"modern_stickers" inCollection:STICKERS_COLLECTION] mutableCopy];
        
        if(!data)
        {
            data = [[NSMutableDictionary alloc] init];
            data[@"sets"] = [[NSMutableArray alloc] init];
        }
        
        data[@"serialized"] = serializedStickers;
        
        if(saveSets) {
            
            data[@"sets"] = sets;
        }
        
        [transaction setObject:data forKey:@"modern_stickers" inCollection:STICKERS_COLLECTION];
        
    }];

}

-(void)loadSetsIfNeeded:(NSArray *)sets n_hash:(int)n_hash {
    
    
    NSMutableArray *removed = [[NSMutableArray alloc] init];
    NSMutableArray *changed = [[NSMutableArray alloc] init];
    
    [_sets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
        NSArray *current = [sets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]];
        
        if(current.count == 0)
        {
            [removed addObject:obj];
        }
    }];
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *current = [_sets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]];
        
        if(current.count == 0 || [(TL_stickerSet *)current[0] n_hash] != obj.n_hash || [self.stickers[@(obj.n_id)] count] == 0) {
            
            [changed addObject:obj];
        }
        
    }];
    
     _sets = [sets mutableCopy];
    
    
    [changed enumerateObjectsUsingBlock:^(TL_stickerSet *set, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [_stickers[@(set.n_id)] removeAllObjects];
        [self performLoadSet:set allSets:sets hash:n_hash save:idx == changed.count-1];
    }];
    
    [self save:sets stickers:_stickers n_hash:n_hash saveSets:changed.count == 0];
   
    
    [self reloadData];

    
}


-(void)performLoadSet:(TL_stickerSet *)set allSets:(NSArray *)allSets hash:(int)n_hash save:(BOOL)save {
    
    
    [RPCRequest sendRequest:[TLAPI_messages_getStickerSet createWithStickerset:[TL_inputStickerSetID createWithN_id:set.n_id access_hash:set.access_hash]] successHandler:^(id request, TL_messages_stickerSet *response) {
        
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
            
            NSMutableDictionary *data = [[transaction objectForKey:@"modern_stickers" inCollection:STICKERS_COLLECTION] mutableCopy];
            
            
            if(!data) {
                data = [[NSMutableDictionary alloc] init];
                data[@"serialized"] = [[NSMutableArray alloc] init];
                data[@"sets"] = [[NSMutableArray alloc] init];
            }
            
            _stickers[@(response.set.n_id)] = response.documents;
            
        }];
        
        [self save:_sets stickers:_stickers n_hash:n_hash saveSets:YES];
        
        
        [ASQueue dispatchOnMainQueue:^{
            [self reloadData];
        }];
        
    } errorHandler:^(id request, RpcError *error) {
        
    } timeout:60 queue:[ASQueue globalQueue].nativeQueue];
    
    
}

-(NSDictionary *)allStickers {
    return _stickers;
}



-(NSArray *)sets {
    return _sets;
}

-(void)updateSets:(NSArray *)sets {
    _sets = [sets mutableCopy];
}

-(void)removeSticker:(TL_outDocument *)document {
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        NSMutableArray *localStickers = [[transaction objectForKey:@"localStickers" inCollection:STICKERS_COLLECTION] mutableCopy];
        
        __block id toDelete;
        
        [localStickers enumerateObjectsUsingBlock:^(TL_outDocument *obj, NSUInteger idx, BOOL *stop) {
            
            
            if(obj.n_id == document.n_id) {
                
                toDelete = obj;
                
                *stop = YES;
            }
            
        }];
        
        [localStickers removeObject:toDelete];
        
        [transaction setObject:localStickers forKey:@"localStickers" inCollection:STICKERS_COLLECTION];
        
    }];
    
    [self load:YES];
    
}

-(void)reloadData {
    

    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    weak();
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        NSMutableDictionary *sort = [transaction objectForKey:@"recentStickers" inCollection:STICKERS_COLLECTION];
        
        NSMutableArray *s = [NSMutableArray array];
        
        [sort enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull set_id, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            [obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull n_id, id  _Nonnull count, BOOL * _Nonnull stop) {
                
                [s addObject:@{@"count":count,@"n_id":n_id,@"set_id":set_id}];
                
            }];
            
        }];
        
        [s sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self.count" ascending:NO]]];
        
        
        
       __block NSArray *recent = [NSArray array];
        
       [s enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
           NSArray *setStickers = weakSelf.stickers[obj[@"set_id"]];
           
           TL_document *recentSticker = [[setStickers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id = %@",obj[@"n_id"]]] firstObject];
           
           if(recentSticker) {
               recent = [recent arrayByAddingObject:recentSticker];
           }
           
       }];
        
        
        if(!weakSelf.isCustomStickerPack) {
            recent = [recent subarrayWithRange:NSMakeRange(0, MIN(20,recent.count))];
            
        } else {
            recent = @[];
        }
        
        weakSelf.hasRecentStickers = recent.count > 0;
        
        
        NSMutableArray *row = [[NSMutableArray alloc] init];
        
        
        [recent enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [row addObject:obj];
            
            if(row.count == 5) {
                [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:-1]];
                [row removeAllObjects];
            }
            
        }];
        
        
        if(row.count > 0) {
            [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:-1]];
            [row removeAllObjects];
        }
        
    
        [weakSelf.sets enumerateObjectsUsingBlock:^(TL_stickerSet *set, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [weakSelf.stickers[@(set.n_id)] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [row addObject:obj];
                
                if(row.count == 5) {
                    [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:set.n_id]];
                    [row removeAllObjects];
                }
            }];
            
            if(row.count > 0) {
                [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:set.n_id]];
                [row removeAllObjects];
            }
            
            
        }];
        
        
    }];
    
    [self removeAllItems:NO];

    
    [self insert:items startIndex:0 tableRedraw:NO];
    
    [super reloadData];
  //
    if(_didNeedReload) {
        _didNeedReload();
    }
    
   
    
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item
{
    return 80;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    TGAllStickerTableItemView *view = (TGAllStickerTableItemView *) [self cacheViewForClass:[TGAllStickerTableItemView class] identifier:@"stickerTableItemView" withSize:NSMakeSize(NSWidth(self.bounds), 80)];;
    view.tableView = self;
    return view;
}

- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    
    return YES;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

-(void)showWithStickerPack:(TL_messages_stickerSet *)stickerPack {
    
    [_stickers removeAllObjects];
    _sets = [NSMutableArray array];
    
    [_sets addObject:stickerPack.set];
    _stickers[@(stickerPack.set.n_id)] = [stickerPack documents];
    
    _isCustomStickerPack = YES;
    
    [self reloadData];
    
}

-(int)stickersHash:(NSArray *)stickersets {
    
    __block int acc = 0;
    
    [stickersets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        acc = (acc * 20261) + obj.n_hash;
    }];
    
    return (int)(acc % 0x7FFFFFFF);
    
}


-(void)scrollToStickerPack:(long)packId {
    
    __block TGAllStickersTableItem *item;
    
    [self.list enumerateObjectsUsingBlock:^(TGAllStickersTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.packId == packId) {
            item = obj;
            *stop = YES;
        }
        
    }];
    
    [self.scrollView scrollToPoint:[self rectOfRow:[self indexOfItem:item]].origin animation:YES];
    
}



-(void)mouseDragged:(NSEvent *)theEvent {
    if(_previewModal != nil) {
        NSUInteger index = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
        
        TGAllStickerTableItemView *view = [self viewAtColumn:0 row:index makeIfNecessary:NO];
        
        TGAllStickersTableItem *item = [self itemAtPosition:index];
        
        NSPoint point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
        
        [view.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(NSMinX(obj.frame) < point.x && NSMaxX(obj.frame) > point.x) {
                
                [_previewModal setSticker:item.stickers[idx]];
            }
            
        }];
        
    } else {
        [super mouseDragged:theEvent];
    }
}

-(void)hideStickerPreview {
    
    if(_previewModal) {
        
        NSEvent *event = [NSApp currentEvent];
        
        if(![event.window isKindOfClass:[RBLPopoverWindow class]]) {
            _notSendUpSticker = YES;
        }
    }
    
    [_previewModal close:YES];
    _previewModal = nil;
    
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)clear {
    [super clear];

}



@end
