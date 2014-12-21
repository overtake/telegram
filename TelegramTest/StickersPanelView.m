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
        
        
    }
    
    return self;
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
            
            int y = roundf((NSHeight(self.frame)-1 - imgObj.imageSize.height) / 2);
            
            TGStickerImageView *imgView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(xOffset + 5, y, imgObj.imageSize.width, imgObj.imageSize.height)];
            
            
            [imgView setTapBlock:^{
                
                [[Telegram rightViewController].messagesViewController sendSticker:obj addCompletionHandler:nil];
                
       
            }];
            
            imgView.object = imgObj;
            
            [self.containerView addSubview:imgView];
            
            xOffset += imgObj.imageSize.width + 10;
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


-(void)showAndSearch:(NSString *)emotion animated:(BOOL)animated {
    
    ACCEPT_FEATURE
    
    __block NSString *hash = @"";
    
    __block NSMutableArray *stickers = [[NSMutableArray alloc] init];
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSDictionary *dictionary = [transaction objectForKey:emotion inCollection:STICKERS_COLLECTION];
        
        NSArray *serialized = dictionary[@"serialized"];
        hash = dictionary[@"hash"];
        
        [serialized enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [stickers addObject:[TLClassStore deserialize:obj]];
        }];
        
    }];
    
    if(stickers.count > 0) {
        [self show:YES stickers:stickers];
    }
    
    [RPCRequest sendRequest:[TLAPI_messages_getStickers createWithEmoticon:emotion n_hash:hash] successHandler:^(RPCRequest *request, TL_messages_stickers * response) {
        
        if(![response isKindOfClass:[TL_messages_stickersNotModified class]]) {
            
            
            if(response.strickers.count > 0) {
                if(stickers.count > 0) {
                    [self rebuild:response.strickers];
                } else {
                    [self show:animated stickers:response.strickers];
                }
            } else {
                [self hide:YES];
            }
           
             stickers = response.strickers;
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                
                NSMutableArray *serialized = [[NSMutableArray alloc] init];
                
                [stickers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    [serialized addObject:[TLClassStore serialize:obj]];
                    
                }];
                
                [transaction setObject:@{@"serialized":serialized,@"hash":response.n_hash} forKey:emotion inCollection:STICKERS_COLLECTION];
            }];
            
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
    
    
    
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

@end
