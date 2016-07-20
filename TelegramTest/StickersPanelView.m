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
#import "TGTransformScrollView.h"
#import "TGStickerPreviewModalView.h"
@interface StickersPanelView ()
@property (nonatomic,strong) TGTransformScrollView *scrollView;

@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TMView *background;

@property (nonatomic,strong) TGStickerPreviewModalView *previewModal;
@property (nonatomic,assign) BOOL notSendUpSticker;
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
            
            if(!placeholder)
                placeholder = white_background_color();
            
            TGMessagesStickerImageObject *imgObj = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:placeholder];
            imgObj.reserved1 = obj;
            imgObj.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), NSHeight(self.frame) - 10);
                        
            TGStickerImageView *imgView = [[TGStickerImageView alloc] initWithFrame:NSMakeRect(0, 0, imgObj.imageSize.width, imgObj.imageSize.height)];
            
            
            imgView.object = imgObj;
            
            
            BTRButton *button = [[BTRButton alloc] initWithFrame:NSMakeRect(xOffset + 3, 2, hoverImage().size.width, NSHeight(self.bounds) - 6)];
            
            weak();
            
            [button addBlock:^(BTRControlEvents events) {
                
                if(weakSelf.previewModal.isShown) {
                    [weakSelf.previewModal close:YES];
                    weakSelf.previewModal = nil;
                    
                    return;
                }
                
                if(weakSelf.notSendUpSticker)
                {
                    weakSelf.notSendUpSticker = NO;
                    return;
                }
                
                [weakSelf.messagesViewController sendSticker:obj forConversation:self.messagesViewController.conversation addCompletionHandler:nil];
                
                TGInputMessageTemplate *template = self.messagesViewController.conversation.inputTemplate;
                [template updateTextAndSave:@""];
                [template performNotification];
                                
                
            } forControlEvents:BTRControlEventMouseUpInside];
            
            [button addBlock:^(BTRControlEvents events) {
                
                TGStickerPreviewModalView *preview = [[TGStickerPreviewModalView alloc] init];
                
                [preview setSticker:obj];
                
                [preview show:appWindow() animated:YES];
                
                weakSelf.previewModal = preview;
                
            } forControlEvents:BTRControlEventLongLeftClick];
            
            
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
    
    [self.scrollView.clipView scrollRectToVisible:NSMakeRect(0, 0, 1, 1) animated:NO];
    
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
    
    if(self.messagesViewController.templateType == TGInputMessageTemplateTypeEditMessage)
        return;
    
    [[Storage yap] asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        
        NSDictionary *data = [transaction objectForKey:@"modern_stickers" inCollection:STICKERS_COLLECTION];
        
        NSDictionary *stickers = data[@"serialized"];
        
        
        NSArray *sets = data[@"sets"];

        
        NSMutableArray *s = [NSMutableArray array];
                              
        [sets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [stickers[@(obj.n_id)] enumerateObjectsUsingBlock:^(TL_document *evaluatedObject, NSUInteger idx, BOOL * _Nonnull stop) {
                
                TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [evaluatedObject attributeWithClass:[TL_documentAttributeSticker class]];
                
                if([[attr.alt fixEmoji] isEqualToString:emotion]) {
                    [s addObject:evaluatedObject];
                }
                
            }];
            
        }];
        
        if(s.count > 0) {
            [ASQueue dispatchOnMainQueue:^{
               [self show:YES stickers:s];
            }];
        }
        
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



+(BOOL)hasSticker:(TLDocument *)document {
    
    __block BOOL has = NO;
    
    
    TL_documentAttributeSticker *attribute = (TL_documentAttributeSticker *) [document attributeWithClass:[TL_documentAttributeSticker class]];
    
    if(attribute && attribute.stickerset)
    {
        return YES;
    }
    
    
    
    return has;
}





-(void)mouseDragged:(NSEvent *)theEvent {
    if(_previewModal != nil) {
        TGStickerImageView *sticker = (TGStickerImageView *) [self.containerView hitTest:[self.containerView convertPoint:[theEvent locationInWindow] fromView:nil]];
        
        if(sticker && [sticker isKindOfClass:[TGStickerImageView class]]) {
            [_previewModal setSticker:sticker.object.reserved1];
        }
        
        
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

@end

