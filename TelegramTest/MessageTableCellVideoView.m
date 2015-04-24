//
//  MessageTableCellVideoView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/13/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellVideoView.h"
#import "TMCircularProgress.h"
#import "TGTimer.h"
#import "TLPeer+Extensions.h"
#import "TMMediaController.h"
#import "TMPreviewVideoItem.h"
#import "FileUtils.h"
#import "MessageCellDescriptionView.h"

#import "TGPhotoViewer.h"
#import "TGCTextView.h"
#import "POPCGUtils.h"
@interface MessageTableCellVideoView()
@property (nonatomic, strong) NSImageView *playImage;
@property (nonatomic,strong) BTRButton *downloadButton;
@property (nonatomic, strong) MessageCellDescriptionView *videoTimeView;
@property (nonatomic,strong) TGCTextView *captionTextView;
@end

@implementation MessageTableCellVideoView



static NSImage *playImage() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 48, 48);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGBWithAlpha(0x000000, 0.5) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        [image_PlayIconWhite() drawInRect:NSMakeRect(roundf((48 - image_PlayIconWhite().size.width)/2) + 2, roundf((48 - image_PlayIconWhite().size.height)/2) , image_PlayIconWhite().size.width, image_PlayIconWhite().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return image;//image_VideoPlay();
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        weak();
        
        self.imageView = [[BluredPhotoImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
       // [self.imageView setIsAlwaysBlur:YES];
        [self.imageView setCornerRadius:4];
        
        [self.imageView setTapBlock:^{
           
            [weakSelf checkOperation];
            
        }];
        
        [self setProgressToView:self.imageView];
        [self.containerView addSubview:self.imageView];
        
        self.playImage = imageViewWithImage(playImage());
        
        [self.imageView addSubview:self.playImage];
        
        self.imageView.borderWidth = 1;
        self.imageView.borderColor = NSColorFromRGB(0xf3f3f3);
        
        
        [self.playImage setCenterByView:self.imageView];
        [self.playImage setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        
        self.videoTimeView = [[MessageCellDescriptionView alloc] initWithFrame:NSMakeRect(5, 5, 0, 0)];
        [self.imageView addSubview:self.videoTimeView];
                
        [self setProgressStyle:TMCircularProgressDarkStyle];
        
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        [self.containerView setIsFlipped:YES];
        

    }
    return self;
}


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    const int borderOffset = self.imageView.borderWidth;
    const int borderSize = borderOffset*2;
    
    NSRect rect = NSMakeRect(self.containerView.frame.origin.x-borderOffset, NSMinY(self.containerView.frame) + NSHeight(self.containerView.frame) - NSHeight(self.imageView.frame) - borderOffset, NSWidth(self.imageView.frame)+borderSize, NSHeight(self.imageView.frame)+borderSize);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.imageView.cornerRadius yRadius:self.imageView.cornerRadius];
    [path addClip];
    
    
    [self.imageView.borderColor set];
    NSRectFill(rect);
}

-(void)setEditable:(BOOL)editable animation:(BOOL)animation
{
    [super setEditable:editable animation:animation];
    self.imageView.isNotNeedHackMouseUp = editable;
}

- (void)open {
    
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message.media.video.thumb peer_id:self.item.message.peer_id];
    
    if (floor(NSAppKitVersionNumber) > 1187)  {
        
        NSURL *url = [NSURL fileURLWithPath:mediaFilePath(self.item.message.media)];
        
        NSSize size = NSMakeSize(self.item.message.media.video.w, self.item.message.media.video.h);
        
        previewObject.reservedObject = @{@"url":url,@"size":[NSValue valueWithSize:size]};
        [[TGPhotoViewer viewer] show:previewObject];
    } else {
        
        TMPreviewVideoItem *item = [[TMPreviewVideoItem alloc] initWithItem:previewObject];
        if(item) {
            [[TMMediaController controller] show:item];
        }
    }
    
    
    
    
//    

}


-(void)initCaptionTextView {
    if(!_captionTextView) {
        _captionTextView = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        [_captionTextView setEditable:YES];
        [self.containerView addSubview:_captionTextView];
    }
}


- (void)deallocCaptionTextView {
    [_captionTextView removeFromSuperview];
    _captionTextView = nil;
}

- (void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    [self.playImage setHidden:!(cellState == CellStateNormal)];
    
    [self.progressView setState:cellState];
    
    [self.playImage setCenterByView:self.imageView];
    
    BOOL needBlur = self.item.message.media.video.thumb.w != 250;
    
    if(self.imageView.isAlwaysBlur != needBlur)
        [self.imageView setIsAlwaysBlur:needBlur];
    
    self.imageView.object = ((MessageTableItemVideo *)self.item).imageObject;

}

- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Video menu"];
    
    if([self.item isset]) {
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [self performSelector:@selector(saveAs:) withObject:self];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [self performSelector:@selector(copy:) withObject:self];
        }]];
        
        
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
}


- (void) setItem:(MessageTableItemVideo *)item {
    [super setItem:item];
    
    [self updateDownloadState];
   
    
    [self.imageView setFrameSize:item.videoSize];
    
    [self updateVideoTimeView];
    
    
    if(item.caption) {
        [self initCaptionTextView];
        
        [_captionTextView setFrame:NSMakeRect(0, NSMaxY(_imageView.frame), item.captionSize.width, item.captionSize.height)];
        
        [_captionTextView setAttributedString:item.caption];
        
    } else {
        [self deallocCaptionTextView];
    }

}




- (void)updateVideoTimeView {
    [self.videoTimeView setFrameSize:((MessageTableItemVideo *)self.item).videoTimeSize];
    [self.videoTimeView setString:((MessageTableItemVideo *)self.item).videoTimeAttributedString];
}

- (void)onStateChanged:(SenderItem *)item {
    
    
    [ASQueue dispatchOnMainQueue:^{
        if(item == self.item.messageSender) {
            [(MessageTableItemVideo *)self.item rebuildTimeString];
            [self updateVideoTimeView];
            
            if(item.state == MessageSendingStateSent) {
                [self.item doAfterDownload];
            }
        }
        
    }];
    
    [super onStateChanged:item];
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!_captionTextView) {
        return;
    }
    
    
    if(!anim) {
        _captionTextView.backgroundColor = color;
        return;
    }
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    
    animation.property = [POPAnimatableProperty propertyWithName:@"background" initializer:^(POPMutableAnimatableProperty *prop) {
        
        [prop setReadBlock:^(TGCTextView *textView, CGFloat values[]) {
            POPCGColorGetRGBAComponents(textView.backgroundColor.CGColor, values);
        }];
        
        [prop setWriteBlock:^(TGCTextView *textView, const CGFloat values[]) {
            CGColorRef color = POPCGColorRGBACreate(values);
            textView.backgroundColor = [NSColor colorWithCGColor:color];
        }];
        
    }];
    
    animation.toValue = anim.toValue;
    animation.fromValue = anim.fromValue;
    animation.duration = anim.duration;
    [_captionTextView pop_addAnimation:animation forKey:@"background"];
    
    
}



-(void)_colorAnimationEvent {
    
    if(!_captionTextView)
        return;
    
    CALayer *currentLayer = (CALayer *)[_captionTextView.layer presentationLayer];
    
    id value = [currentLayer valueForKeyPath:@"backgroundColor"];
    
    _captionTextView.layer.backgroundColor = (__bridge CGColorRef)(value);
    [_captionTextView setNeedsDisplay:YES];
}

@end