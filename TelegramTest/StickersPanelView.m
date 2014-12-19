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
@interface StickersPanelView ()
@property (nonatomic,strong) NSArray *stickers;
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
        self.background.layer.opacity = 0.7;
        [self addSubview:self.background];
        
        self.scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
       
        [self.scrollView setHasVerticalScroller:NO];
        self.scrollView.verticalScrollElasticity = NO;
        [self.scrollView setDrawsBackground:NO];
        
        self.containerView = [[TMView alloc] initWithFrame:self.bounds];
        
        self.scrollView.documentView = self.containerView;
        
        [self addSubview:self.scrollView];
        
        
        
    }
    
    return self;
}


-(void)rebuild {
    [self.containerView removeAllSubviews];
    
    
    __block NSUInteger xOffset = 0;
    
    [self.stickers enumerateObjectsUsingBlock:^(TL_document  *obj, NSUInteger idx, BOOL *stop) {
        
        if(![obj.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
            NSImage *placeholder = [[NSImage alloc] initWithData:obj.thumb.bytes];
            
            
            
            TGMessagesStickerImageObject *imgObj = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:placeholder];
            
            imgObj.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), 54);
            
            TGStickerImageView *imgView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(xOffset + 5, 3, imgObj.imageSize.width, imgObj.imageSize.height)];
            
            
            imgView.object = imgObj;
            
            [self.containerView addSubview:imgView];
            
            xOffset += imgObj.imageSize.width + 10;
        }
        
    }];
    
    [self.containerView setFrameSize:NSMakeSize(xOffset, NSHeight(self.containerView.frame))];
}

-(void)show:(BOOL)animated {
    
    [self rebuild];
    
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
    
    [RPCRequest sendRequest:[TLAPI_messages_getStickers createWithEmoticon:emotion n_hash:@""] successHandler:^(RPCRequest *request, TL_messages_stickers * response) {
        
        if(response.strickers.count > 0) {
            self.stickers = response.strickers;
            
            for (int i = 0; i < 20; i++) {
                self.stickers = [self.stickers arrayByAddingObjectsFromArray:response.strickers];
            }
            
            [self show:animated];
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
