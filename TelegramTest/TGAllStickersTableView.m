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
@end

@implementation TGAllStickersTableItem


-(id)initWithObject:(NSArray *)object {
    if(self = [super initWithObject:object]) {
        _stickers = [object mutableCopy];
        
        _objects = [[NSMutableArray alloc] init];
        
        [_stickers enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
            
            NSImage *placeholder = [[NSImage alloc] initWithData:obj.thumb.bytes];
                
            if(!placeholder)
                placeholder = [NSImage imageWithWebpData:obj.thumb.bytes error:nil];
                
            TGMessagesStickerImageObject *imgObj = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:placeholder];
                
            imgObj.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), 70);
                
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
    
    int width = round(NSWidth(self.bounds)/4);
    
    [item.stickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BTRButton *button = [[BTRButton alloc] initWithFrame:NSMakeRect(xOffset, 0, width, NSHeight(self.bounds))];
        
        [button setBackgroundImage:hoverImage() forControlState:BTRControlStateHover];
        [button setBackgroundImage:higlightedImage() forControlState:BTRControlStateHighlighted];
       
        TGStickerImageView *imageView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(xOffset, 0, width, NSHeight(self.bounds))];
        
        
        [imageView setTapBlock:^ {
            
            [[Telegram rightViewController].messagesViewController sendSticker:item.stickers[idx] addCompletionHandler:nil];
            
        }];
        
        [imageView setFrameSize:[item.objects[idx] imageSize]];
        
        imageView.object = item.objects[idx];
        
        [imageView setCenterByView:button];
        
        [button addSubview:imageView];
        
        [self addSubview:button];
        
        xOffset+=width;
        
        
    }];
    
    
}

@end



@interface TGAllStickersTableView ()<TMTableViewDelegate>
@property (nonatomic,strong) TMView *noEmojiView;
@property (nonatomic,strong) NSMutableArray *stickers;
@end

@implementation TGAllStickersTableView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _stickers = [[NSMutableArray alloc] init];
        self.tm_delegate = self;
    }
    
    return self;
}

-(void)load:(BOOL)force {
    
    if(_stickers.count == 0 || force) {
        __block NSString *hash = @"";
        
        __block NSArray *stickers;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            NSDictionary *info  = [transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION];
            
            hash = info[@"hash"];
            
            stickers = info[@"serialized"];
            
            NSMutableArray *row = [[NSMutableArray alloc] init];
            
            
            [stickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [row addObject:[TLClassStore deserialize:obj]];
            }];
            
            
            NSArray *localStickers = [transaction objectForKey:@"localStickers" inCollection:STICKERS_COLLECTION];
            
            [localStickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [row addObject:[TLClassStore deserialize:obj]];
            }];
            
            
            stickers = [row mutableCopy];
            
            [row removeAllObjects];
            
        }];
        
        _stickers = [stickers mutableCopy];
        
        if(!isRemoteStickersLoaded()) {
            [RPCRequest sendRequest:[TLAPI_messages_getAllStickers createWithN_hash:hash] successHandler:^(RPCRequest *request, TL_messages_allStickers *response) {
                
                
                if(![response isKindOfClass:[TL_messages_allStickersNotModified class]]) {
                    
                    _stickers = response.documents;
                    
                    [self reloadData];
                    
                    [StickersPanelView saveResponse:response];
                    
                }
                
                setRemoteStickersLoaded(YES);
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
            }];
            
            
        }
    } else {
        [self reloadData];
    }
        
    
    
    
    
}

-(void)reloadData {
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        NSMutableDictionary *sort = [transaction objectForKey:@"stickersUsed" inCollection:STICKERS_COLLECTION];
        
        NSArray *stickers = [_stickers sortedArrayUsingComparator:^NSComparisonResult(TL_document *obj1, TL_document *obj2) {
            
            NSNumber *c1 = sort[@(obj1.n_id)];
            NSNumber *c2 = sort[@(obj2.n_id)];
            
            if ([c1 longValue] > [c2 longValue])
                return NSOrderedAscending;
            else if ([c1 longValue] < [c2 longValue])
                return NSOrderedDescending;
            
            return NSOrderedSame;
        }];
        
        
        NSMutableArray *row = [[NSMutableArray alloc] init];
        
        
        [stickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [row addObject:obj];
            
            if(row.count == 4) {
                [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy]]];
                [row removeAllObjects];
            }
        }];
        
        
        if(row.count > 0) {
            [items addObject:[[TGAllStickersTableItem alloc] initWithObject:[row copy]]];
            [row removeAllObjects];
        }
        
    }];
    
    [self removeAllItems:NO];
    
    [self insert:items startIndex:0 tableRedraw:NO];
    
    [super reloadData];
    
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item
{
    return 80;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self cacheViewForClass:[TGAllStickerTableItemView class] identifier:@"stickerTableItemView" withSize:NSMakeSize(NSWidth(self.bounds), 80)];
}

- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    
    return YES;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

@end
