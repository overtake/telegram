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





@interface TGAllStickersTableView ()<TMTableViewDelegate>
@property (nonatomic,strong) TMView *noEmojiView;
@property (nonatomic,strong) NSMutableArray *stickers;
@property (nonatomic,strong) NSMutableArray *sets;
@property (nonatomic,assign) BOOL isCustomStickerPack;
@end


@interface TGSticker : NSObject<NSCoding>
@property (nonatomic,strong) TL_document *document;
@property (nonatomic,strong) NSString *emoji;

-(id)initWithDocument:(TL_document *)document emoji:(NSString *)emoji;

@end

@implementation TGSticker

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _document = [TLClassStore deserialize:[aDecoder decodeObjectForKey:@"document"]];
        _emoji = [aDecoder decodeObjectForKey:@"emoji"];
    }
    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[TLClassStore serialize:_document] forKey:@"document"];
    [aCoder encodeObject:_emoji forKey:@"emoji"];
}

-(id)initWithDocument:(TL_document *)document emoji:(NSString *)emoji {
    if(self = [super init]) {
        _document = document;
        _emoji = emoji;
    }
    
    return self;
}

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
@property (nonatomic,strong) TGAllStickersTableView *tableView;

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
    
    [item.stickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BTRButton *button = [[BTRButton alloc] initWithFrame:NSMakeRect(xOffset, 0, width, NSHeight(self.bounds))];
        
        
        if(!_tableView.isCustomStickerPack) {
            [button setBackgroundImage:hoverImage() forControlState:BTRControlStateHover];
            [button setBackgroundImage:higlightedImage() forControlState:BTRControlStateHover];
       
        }
        
        TGStickerImageView *imageView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(xOffset, 0, width, NSHeight(self.bounds))];
        
        
        [imageView setTapBlock:^ {
            
            if(!_tableView.isCustomStickerPack)
                [[EmojiViewController instance].messagesViewController sendSticker:item.stickers[idx] forConversation:[Telegram conversation] addCompletionHandler:nil];
            
        }];
        
        [imageView setFrameSize:[item.objects[idx] imageSize]];
        
        imageView.object = item.objects[idx];
        
        [imageView setCenterByView:button];
        
        [button addSubview:imageView];
            
        
        
        if([obj isKindOfClass:[TL_outDocument class]]) {
            BTRButton *removeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(width - image_RemoveSticker().size.width - 3, NSHeight(self.bounds) - image_RemoveSticker().size.height - 3, image_RemoveSticker().size.width, image_RemoveSticker().size.height)];
            
            [removeButton setBackgroundImage:image_RemoveSticker() forControlState:BTRControlStateNormal];
            [removeButton setBackgroundImage:image_RemoveStickerActive() forControlState:BTRControlStateHighlighted];
            
            
            [removeButton addBlock:^(BTRControlEvents events) {
                
                [self.tableView removeSticker:obj];
                
            } forControlEvents:BTRControlEventClick];
            
             [button addSubview:removeButton];

        }
        
        [self addSubview:button];
        
        xOffset+=width;
        
        
    }];
    
    
}

@end





@implementation TGAllStickersTableView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _stickers = [[NSMutableArray alloc] init];
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
    
    [_stickers addObjectsFromArray:set.documents];
    
    [self save:_sets stickers:_stickers n_hash:[self stickersHash:_sets] saveSets:YES];
    
    [self reloadData];
}



-(NSScrollView *)containerView {
    return [super containerView];
}

-(void)load:(BOOL)force {
    
    if(_stickers.count == 0 || force) {
        
        _isCustomStickerPack = NO;
        
        __block NSString *hash = @"";
        
        __block NSArray *stickers;
        
        __block NSArray *sets;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            NSDictionary *info  = [transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION];
            
            
            stickers = info[@"serialized"];
            
            sets = info[@"sets"];
            
            NSMutableArray *row = [[NSMutableArray alloc] init];
                        
            NSMutableArray *rowSet = [[NSMutableArray alloc] init];
            
            
            [row addObjectsFromArray:stickers];
            
            [row addObjectsFromArray:[transaction objectForKey:@"localStickers" inCollection:STICKERS_COLLECTION]];
            
            [rowSet addObjectsFromArray:sets];
            
            
            _sets = rowSet;
            
            stickers = [row mutableCopy];
            
            [row removeAllObjects];
            
        }];
        
        _stickers = [stickers mutableCopy];
        
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


-(void)save:(NSArray *)sets stickers:(NSArray *)stickers n_hash:(int)n_hash saveSets:(BOOL)saveSets {
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        
        NSMutableArray *serializedStickers = [_stickers mutableCopy];
        
        NSMutableDictionary *data = [[transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION] mutableCopy];
        
        if(!data)
        {
            data = [[NSMutableDictionary alloc] init];
            data[@"sets"] = [[NSMutableArray alloc] init];
        }
        
        data[@"serialized"] = serializedStickers;
        
        if(saveSets) {
            
            data[@"sets"] = sets;
        }
        
        [transaction setObject:data forKey:@"allstickers" inCollection:STICKERS_COLLECTION];
        
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
        
        if(current.count == 0 || [(TL_stickerSet *)current[0] n_hash] != obj.n_hash) {
            
            [changed addObject:obj];
        }
        
    }];
    
     _sets = [sets mutableCopy];
    
    NSMutableArray *toremove = [[NSMutableArray alloc] init];
    
    [_stickers enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
        
        TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [obj attributeWithClass:[TL_documentAttributeSticker class]];
        
        
        if([removed filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",attr.stickerset.n_id]].count != 0 || [changed filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",attr.stickerset.n_id]].count != 0)
        {
            [toremove addObject:obj];
        }
        
    }];
    
    [_stickers removeObjectsInArray:toremove];
    
    [self save:sets stickers:_stickers n_hash:n_hash saveSets:changed.count == 0];
   
    
    [self reloadData];
    
    [changed enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
        
        [_stickers removeObjectsInArray:[_stickers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TL_document *evaluatedObject, NSDictionary *bindings) {
            
            TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [evaluatedObject attributeWithClass:[TL_documentAttributeSticker class]];
            
            return attr.stickerset.n_id == obj.n_id;
            
        }]]];
        
        [self performLoadSet:obj allSets:sets hash:n_hash save:idx == changed.count-1];
        
    }];
    
    
    
}


-(void)performLoadSet:(TL_stickerSet *)set allSets:(NSArray *)allSets hash:(int)n_hash save:(BOOL)save {
    
    
    [RPCRequest sendRequest:[TLAPI_messages_getStickerSet createWithStickerset:[TL_inputStickerSetID createWithN_id:set.n_id access_hash:set.access_hash]] successHandler:^(id request, TL_messages_stickerSet *response) {
        
        
        NSMutableArray *stickers = [[NSMutableArray alloc] init];
 
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
            
            NSMutableDictionary *data = [[transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION] mutableCopy];
            
            [stickers addObjectsFromArray:data[@"serialized"]];
            
            if(!data) {
                data = [[NSMutableDictionary alloc] init];
                data[@"serialized"] = [[NSMutableArray alloc] init];
                data[@"sets"] = [[NSMutableArray alloc] init];
            }
            
            [stickers addObjectsFromArray:response.documents];
            
            if(save) {
                data[@"sets"] = allSets == nil ? [NSMutableArray array] : allSets;
            }
            
            if(!data[@"sets"]) {
                data[@"sets"] = [[NSMutableArray alloc] init];
            }
            
            [transaction setObject:@{@"serialized":stickers,@"sets":data[@"sets"]} forKey:@"allstickers" inCollection:STICKERS_COLLECTION];
            
        }];
        
        
        [ASQueue dispatchOnMainQueue:^{
             _stickers = stickers;
            [self reloadData];
        }];
        
    } errorHandler:^(id request, RpcError *error) {
        
    } timeout:60 queue:[ASQueue globalQueue].nativeQueue];
    
    
}

-(NSArray *)allStickers {
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
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        NSMutableDictionary *sort = [transaction objectForKey:@"stickersUsed" inCollection:STICKERS_COLLECTION];
        

        NSArray *recent = [_stickers sortedArrayUsingComparator:^NSComparisonResult(TL_document *obj1, TL_document *obj2) {
            
            NSNumber *c1 = sort[@(obj1.n_id)];
            NSNumber *c2 = sort[@(obj2.n_id)];
            
            if ([c1 longValue] > [c2 longValue])
                return NSOrderedAscending;
            else if ([c1 longValue] < [c2 longValue])
                return NSOrderedDescending;
            
            return NSOrderedSame;
        }];
        
        
        if(!_isCustomStickerPack) {
            recent = [recent subarrayWithRange:NSMakeRange(0, MIN(20,recent.count))];
            
            recent = [recent filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TL_document *evaluatedObject, NSDictionary *bindings) {
                
                return sort[@(evaluatedObject.n_id)] > 0;
                
            }]];
            
        } else {
            recent = @[];
        }
        
        
        
        _hasRecentStickers = recent.count > 0;
        
        NSArray *stickers = _stickers;
        
        
        NSMutableArray *row = [[NSMutableArray alloc] init];
        
        __block long packId = -1;
        
        
        [recent enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [row addObject:obj];
            
            if(row.count == 5) {
                [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:packId]];
                [row removeAllObjects];
            }
            
        }];
        
        
        if(row.count > 0) {
            [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:packId]];
            [row removeAllObjects];
        }
        
        packId = 0;
        
        NSArray *sets = self.sets;
        
        
        stickers = [stickers sortedArrayUsingComparator:^NSComparisonResult(TL_document *obj1, TL_document *obj2) {
            
            NSNumber *sidx = @([sets indexOfObjectPassingTest:^BOOL(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
                
                TL_documentAttributeSticker *sticker = (TL_documentAttributeSticker *) [obj1 attributeWithClass:[TL_documentAttributeSticker class]];
                
                 return sticker.stickerset.n_id == obj.n_id;
                
            }]);
            NSNumber *oidx = @([sets indexOfObjectPassingTest:^BOOL(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
                
                TL_documentAttributeSticker *sticker = (TL_documentAttributeSticker *) [obj2 attributeWithClass:[TL_documentAttributeSticker class]];
                
                return sticker.stickerset.n_id == obj.n_id;
                
            }]);
            
            return [sidx compare:oidx];

            
        }];
        
        [stickers enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
            
            TL_documentAttributeSticker *sticker = (TL_documentAttributeSticker *) [obj attributeWithClass:[TL_documentAttributeSticker class]];
            
            if(packId != sticker.stickerset.n_id) {
                
                if(row.count > 0) {
                    [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:packId]];
                    [row removeAllObjects];
                }
                
                [row addObject:obj];
                
                packId = sticker.stickerset.n_id;
                return;
            }
            
            [row addObject:obj];
            
            if(row.count == 5) {
                [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:packId]];
                [row removeAllObjects];
            }
        }];
        
        
        if(row.count > 0) {
            [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy] packId:packId]];
            [row removeAllObjects];
        }
        
    }];
    
    [self removeAllItems:NO];
    
    [self insert:items startIndex:0 tableRedraw:NO];
    
    [super reloadData];
    
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
    
    [_stickers addObjectsFromArray:[stickerPack documents]];
    
    _isCustomStickerPack = YES;
    
    [self reloadData];
    
}

-(int)stickersHash:(NSArray *)stickersets {
    
    __block long acc = 0;
    
    [stickersets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        acc = (acc + obj.n_hash) * 20261;
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



@end
