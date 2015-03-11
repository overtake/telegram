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
@interface StickersPanelView ()
@property (nonatomic,strong) NSScrollView *scrollView;

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
        
        self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), NSHeight(self.bounds) - 1)];
       
       
        
        self.containerView = [[TMView alloc] initWithFrame:self.scrollView.bounds];
        
        self.scrollView.documentView = self.containerView;
        
        [self.scrollView setHasVerticalScroller:NO];
        self.scrollView.verticalScrollElasticity = NO;
        [self.scrollView setDrawsBackground:NO];
        
        
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
            
            imgObj.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), NSHeight(self.frame) - 6);
                        
            TGStickerImageView *imgView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(0, 0, imgObj.imageSize.width, imgObj.imageSize.height)];
            
            
            [imgView setTapBlock:^{
                
                [[Telegram rightViewController].messagesViewController sendSticker:obj addCompletionHandler:nil];
                
                [[Telegram rightViewController].messagesViewController setStringValueToTextField:@""];
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

    __block NSString *hash = @"";
    __block NSMutableArray *stickers = [[NSMutableArray alloc] init];
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSDictionary *dictionary = [transaction objectForKey:emotion inCollection:STICKERS_COLLECTION];
        
        NSArray *serialized = dictionary[@"serialized"];
        hash = [transaction objectForKey:@"allstickers" inCollection:STICKERS_COLLECTION][@"hash"];
        
        [serialized enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [stickers addObject:[TLClassStore deserialize:obj]];
        }];
        
        
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
    
    if(!isRemoteStickersLoaded()) {
        [RPCRequest sendRequest:[TLAPI_messages_getAllStickers createWithN_hash:hash] successHandler:^(RPCRequest *request, TL_messages_allStickers * response) {
            
            if(![response isKindOfClass:[TL_messages_allStickersNotModified class]]) {
                
                TL_stickerPack *pack = [[response.packs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.emoticon = %@",emotion]] lastObject];
                
                NSArray *documents = [response.documents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id IN %@",pack.documents]];
                
                
                if(documents.count > 0) {
                    if(stickers.count > 0) {
                        [self rebuild:documents];
                    } else {
                        [self show:animated stickers:documents];
                    }
                } else {
                    [self hide:YES];
                }
                
                stickers = [documents mutableCopy];
                
                [StickersPanelView saveResponse:response];
                
            }
            
            setRemoteStickersLoaded(YES);
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
        
        
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

+(void)saveResponse:(TL_messages_allStickers *)response {
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        
        [response.packs enumerateObjectsUsingBlock:^(TL_stickerPack *pack, NSUInteger idx, BOOL *stop) {
            
            NSMutableArray *docs = [[NSMutableArray alloc] init];
            
            [pack.documents enumerateObjectsUsingBlock:^(NSNumber *d_id, NSUInteger idx, BOOL *stop) {
                
                TL_document *document = [[response.documents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id = %ld",[d_id longValue]]] lastObject];
                
                if(document) {
                    [docs addObject:[TLClassStore serialize:document]];
                }
                
            }];
            
            
            [transaction setObject:@{@"serialized":docs} forKey:pack.emoticon inCollection:STICKERS_COLLECTION];
            
        }];
        
         NSMutableArray *serialized = [[NSMutableArray alloc] init];
        
        [response.documents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [serialized addObject:[TLClassStore serialize:obj]];
            
        }];
        [transaction setObject:@{@"hash":response.n_hash,@"serialized":serialized} forKey:@"allstickers" inCollection:STICKERS_COLLECTION];
        
    }];
    
    [ASQueue dispatchOnStageQueue:^{
        dispatch_after_seconds(60*60, ^{
            setRemoteStickersLoaded(NO);
        });
    }];
    
    
}

@end
