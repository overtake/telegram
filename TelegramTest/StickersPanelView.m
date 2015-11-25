//
//  SteckersPanelView.m
//  Telegram
//
//  Created by keepcoder on 19.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "StickersPanelView.h"
#import "TGImageObject.h"
#import "TGStickerImageView.h"
#import "TGMessagesStickerImageObject.h"
#import "SenderHeader.h"
#import "EmojiViewController.h"
#import "TGTransformScrollView.h"
@interface StickersPanelView ()
@property (nonatomic,strong) TGTransformScrollView *scrollView;

@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TMView *background;
@end


@implementation StickersPanelView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.background = [[TMView alloc] initWithFrame:self.bounds];
        self.background.wantsLayer = YES;
        self.background.layer.backgroundColor = NSColorFromRGB(0xffffff).CGColor;
        self.background.layer.opacity = 0.9;
        [self addSubview:self.background];
        
        TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect) - 1, NSWidth(frameRect), 1)];
        
        separator.backgroundColor = GRAY_BORDER_COLOR;
        
        [self addSubview:separator];
        
        self.scrollView = [[TGTransformScrollView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), NSHeight(self.bounds) - 1)];
       
        
        self.containerView = [[TMView alloc] initWithFrame:self.scrollView.bounds];
        
        
        self.scrollView.documentView = self.containerView;
     
        
        [self addSubview:self.scrollView];
        
        self.autoresizingMask = NSViewWidthSizable;
        
        self.scrollView.autoresizingMask = NSViewWidthSizable;
        self.background.autoresizingMask = NSViewWidthSizable;
        separator.autoresizingMask = NSViewWidthSizable;
        
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


-(void)rebuild:(NSArray *)stickers {
    [self.containerView removeAllSubviews];
    
    
    __block NSUInteger xOffset = 0;
    
    [stickers enumerateObjectsUsingBlock:^(TL_document  *obj, NSUInteger idx, BOOL *stop) {
        
        if(![obj.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
            
            NSImage *placeholder = [[NSImage alloc] initWithData:obj.thumb.bytes];
            
            if(!placeholder)
                placeholder = [NSImage imageWithWebpData:obj.thumb.bytes error:nil];
            
            TGMessagesStickerImageObject *imgObj = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:placeholder];
            
            imgObj.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), NSHeight(self.frame) - 10);
                        
            TGStickerImageView *imgView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(0, 0, imgObj.imageSize.width, imgObj.imageSize.height)];
            
            
            [imgView setTapBlock:^{
                
                [_messagesViewController sendSticker:obj forConversation:[Telegram conversation] addCompletionHandler:nil];
                
                [_messagesViewController setStringValueToTextField:@""];
            }];
            
            imgView.object = imgObj;
            
            
            BTRButton *button = [[BTRButton alloc] initWithFrame:NSMakeRect(xOffset + 3, 2, hoverImage().size.width, NSHeight(self.bounds) - 6)];
            [button setBackgroundImage:hoverImage() forControlState:BTRControlStateHover];
            [button setBackgroundImage:higlightedImage() forControlState:BTRControlStateHighlighted];
            
            [imgView setCenterByView:button];
            [button addSubview:imgView];
            
            [self.containerView addSubview:button];
            
            xOffset += NSWidth(button.frame) + 3;
        }
        
    }];
    
    [self.containerView setBackgroundColor:NSColorFromRGBWithAlpha(0xffffff, 0.9)];
    
    [self.containerView setFrameSize:NSMakeSize(xOffset, NSHeight(self.containerView.frame))];
}



-(void)show:(BOOL)animated stickers:(NSArray *)stickers {
    
    [self rebuild:stickers];
    
    if(self.alphaValue == 1.0f && !self.isHidden)
        return;
    
    self.hidden = NO;
    
    if(animated) {
        self.alphaValue = 0.f;
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [[self animator] setAlphaValue:1.0f];
            
        } completionHandler:^{
            
        }];
    } else {
        self.alphaValue = 1.0f;
    }
}

static BOOL isRemoteLoaded = NO;

void setRemoteStickersLoaded(BOOL loaded) {
    isRemoteLoaded = loaded;
}


bool isRemoteStickersLoaded() {
    return isRemoteLoaded;
}

-(void)showAndSearch:(NSString *)emotion animated:(BOOL)animated {

    __block NSMutableArray *stickers = [[NSMutableArray alloc] init];
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        
         NSDictionary *data = [transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION];
        
        stickers = [[data[@"serialized"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TL_document *evaluatedObject, NSDictionary *bindings) {
            
            TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [evaluatedObject attributeWithClass:[TL_documentAttributeSticker class]];
            
            return [attr.alt isEqualToString:emotion];
            
        }]] mutableCopy];
        
        NSMutableDictionary *sort = [transaction objectForKey:@"stickersUsed" inCollection:STICKERS_COLLECTION];
        
        [stickers sortUsingComparator:^NSComparisonResult(TL_document *obj1, TL_document *obj2) {
            
            NSNumber *c1 = sort[@(obj1.n_id)];
            NSNumber *c2 = sort[@(obj2.n_id)];
            
            if ([c1 longValue] > [c2 longValue])
                return NSOrderedAscending;
            else if ([c1 longValue] < [c2 longValue])
                return NSOrderedDescending;
            
            return NSOrderedSame;
        }];
        
    }];
    
    
    if(stickers.count > 0) {
        [self show:YES stickers:stickers];
    }
    
}


-(void)hide:(BOOL)animated {
    
    if(self.alphaValue == 0.f || self.isHidden)
        return;
    
    if(animated) {
       
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [[self animator] setAlphaValue:0.f];
            
        } completionHandler:^{
            self.hidden = YES;
        }];
    } else {
        self.alphaValue = 0;
        self.hidden = YES;
    }
    
}



+(BOOL)hasSticker:(TLDocument *)document {
    
    __block BOOL has = NO;
    
    
    TL_documentAttributeSticker *attribute = (TL_documentAttributeSticker *) [document attributeWithClass:[TL_documentAttributeSticker class]];
    
    if(attribute && attribute.alt.length > 0)
    {
        return YES;
    }
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        
        NSArray *serialized = [transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION][@"serialized"];
        
        [serialized enumerateObjectsUsingBlock:^(TL_document *ds, NSUInteger idx, BOOL *stop) {
            
            
            if(ds.n_id == document.n_id)
            {
                has = YES;
                *stop = YES;
            }
            
        }];
        
        if(!has) {
            serialized = [transaction objectForKey:@"localStickers" inCollection:STICKERS_COLLECTION];
            
            [serialized enumerateObjectsUsingBlock:^(TL_document *ds, NSUInteger idx, BOOL *stop) {
                
                
                if(ds.n_id == document.n_id)
                {
                    has = YES;
                    *stop = YES;
                }
            }];
        }
        
        
    }];
    
    return has;
}



+(void)addLocalSticker:(TLDocument *)document {
    
    if(![self hasSticker:document]) {
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            
            NSArray *stickers = [transaction objectForKey:@"localStickers" inCollection:STICKERS_COLLECTION];
            
            if(!stickers)
                stickers = @[];
            
            stickers = [stickers arrayByAddingObject:document];
            
            [transaction setObject:stickers forKey:@"localStickers" inCollection:STICKERS_COLLECTION];
        }];
        
        [EmojiViewController reloadStickers];
    }
}

@end



/*
 +(void)saveResponse:(NSArray *)packs allSets:(NSArray *)sets currentSet:(TL_stickerSet *)set documents:(NSArray *)documents n_hash:(NSString *)n_hash {
 
 [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
 
 [packs enumerateObjectsUsingBlock:^(TL_stickerPack *pack, NSUInteger idx, BOOL *stop) {
 
 NSArray *emoticonStickers = [transaction objectForKey:pack.emoticon inCollection:STICKERS_COLLECTION];
 
 NSMutableArray *packDocuments = [[NSMutableArray alloc] init];
 
 [emoticonStickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
 @try {
 TL_document *document = [TLClassStore deserialize:obj];
 
 [packDocuments addObject:document];
 
 }
 @catch (NSException *exception) {
 
 }
 
 }];
 
 [pack.documents enumerateObjectsUsingBlock:^(NSNumber *n_id, NSUInteger idx, BOOL *stop) {
 
 if([packDocuments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",[n_id longValue]]].count == 0) {
 
 @try {
 TL_document *document = [documents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",[n_id longValue]]][0];
 
 [packDocuments addObject:document];
 }
 @catch (NSException *exception) {
 
 }
 
 }
 
 }];
 
 NSMutableArray *serialized = [[NSMutableArray alloc] init];
 
 [packDocuments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 [serialized addObject:[TLClassStore serialize:obj]];
 }];
 
 [transaction setObject:serialized forKey:pack.emoticon inCollection:STICKERS_COLLECTION];
 
 }];
 
 
 NSArray *serializedStickers = [transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION][@"serialized"];
 NSArray *serializedSets = [transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION][@"sets"];
 
 
 NSMutableArray *allStickers = [[NSMutableArray alloc] init];
 NSMutableArray *allSets = [[NSMutableArray alloc] init];
 
 
 
 [serializedStickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
 [allStickers addObject:[TLClassStore deserialize:obj]];
 
 }];
 
 
 [serializedSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
 [allSets addObject:[TLClassStore deserialize:obj]];
 
 }];
 
 
 NSMutableArray *changedSets = [[NSMutableArray alloc] init];
 NSMutableArray *removedSets = [[NSMutableArray alloc] init];
 
 [allSets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
 NSArray *current = [sets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]];
 
 if(current.count == 0)
 {
 [removedSets addObject:current];
 }
 }];
 
 [sets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
 
 NSArray *current = [allSets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]];
 
 if(current.count == 0 || [(TL_stickerSet *)current[0] n_hash] != obj.n_hash) {
 
 [changedSets addObject:obj];
 }
 
 }];
 
 NSMutableArray *toremove = [[NSMutableArray alloc] init];
 
 [allStickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
 TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [obj attributeWithClass:[TL_documentAttributeSticker class]];
 
 BOOL res = [changedSets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",attr.stickerset.n_id]].count == 0 && [removedSets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",attr.stickerset.n_id]].count == 0;
 
 if(!res)
 {
 [toremove addObject:obj];
 }
 
 }];
 
 [allStickers removeObjectsInArray:toremove];
 
 [documents enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
 
 if([allStickers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]].count == 0) {
 [allStickers addObject:obj];
 }
 
 }];
 
 
 
 NSMutableArray *ser = [[NSMutableArray alloc] init];
 
 [allStickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
 [ser addObject:[TLClassStore serialize:obj]];
 
 }];
 
 
 serializedStickers = ser;
 
 ser = [[NSMutableArray alloc] init];
 
 [sets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 [ser addObject:[TLClassStore serialize:obj]];
 }];
 
 serializedSets = ser;
 
 [transaction setObject:@{@"hash":n_hash,@"serialized":serializedStickers,@"sets":serializedSets} forKey:@"allstickers" inCollection:STICKERS_COLLECTION];
 
 }];
 
 [ASQueue dispatchOnStageQueue:^{
 dispatch_after_seconds(60*60, ^{
 setRemoteStickersLoaded(NO);
 });
 }];
 
 
 }

 
 
 }
*/