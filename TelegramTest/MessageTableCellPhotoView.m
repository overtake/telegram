//
//  MessageTableCellPhotoView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellPhotoView.h"
#import "TMMediaController.h"
#import "AppDelegate.h"
#import "TMCircularProgress.h"
#import "ImageUtils.h"
#import "SelfDestructionController.h"
#import "TGPhotoViewer.h"
#import "TGCTextView.h"
#import "POPCGUtils.h"
#import "TGCaptionView.h"
@interface MessageTableCellPhotoView()<TGImageObjectDelegate>
@property (nonatomic,strong) NSImageView *fireImageView;
@property (nonatomic,strong) TGCaptionView *captionView;

@property (nonatomic,assign) NSPoint startDragLocation;

@end




NSImage *fireImage() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 42, 42);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, 42, 42) xRadius:21 yRadius:21];
        
        [NSColorFromRGBWithAlpha(0xffffff, 0.8) setFill];
        
        [path fill];
        
        [image_SecretPhotoFire() drawInRect:NSMakeRect(roundf((42 - image_SecretPhotoFire().size.width)/2), roundf((42 - image_SecretPhotoFire().size.height)/2), image_SecretPhotoFire().size.width, image_SecretPhotoFire().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        
        [image unlockFocus];
    });
    return image;
}

@implementation MessageTableCellPhotoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        self.containerView.isFlipped = YES;
        
        self.imageView = [[BluredPhotoImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [self.imageView setWantsLayer:YES];
        self.imageView.cornerRadius = 4;
        [self.imageView setBorderColor:NSColorFromRGB(0xf3f3f3)];
        [self.imageView setBorderWidth:1];

      //  [self.imageView setContentMode:BTRViewContentModeCenter];
        
        [self.imageView setTapBlock:^{
            PreviewObject *object = [[PreviewObject alloc] initWithMsdId:weakSelf.item.message.n_id media:weakSelf.item.message peer_id:weakSelf.item.message.peer_id];
            
            
            if(!weakSelf.item.isset)
                return;
            
            object.reservedObject = weakSelf.imageView.image;
            
            [[TGPhotoViewer viewer] show:object conversation:weakSelf.messagesViewController.conversation isReversed:YES];
            
            if([weakSelf.item.message isKindOfClass:[TL_destructMessage class]]) {
                
                TL_destructMessage *msg = (TL_destructMessage *) weakSelf.item.message;
                
                if(msg.ttl_seconds != 0 && msg.destruction_time == 0 && !msg.n_out) {
                    [SelfDestructionController addMessage:msg force:YES];
                }
                
            }
            
        }];
        

        
        [self setProgressToView:self.imageView];

        
        [self.containerView addSubview:self.imageView];
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
        
      //  [self.imageView setContentMode:BTRViewContentModeCenter];
        
        
        
    }
    return self;
}


- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Photo menu"];
    
    [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
        [self performSelector:@selector(saveAs:) withObject:self];
    }]];
    
    [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
        [self performSelector:@selector(copy:) withObject:self];
    }]];
    
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
}


- (void)initFireImage {
    if(!self.fireImageView) {
        self.fireImageView = imageViewWithImage(fireImage());
        
        [self.fireImageView setHidden:YES];
        
        [self.imageView addSubview:self.fireImageView];

    }
}

- (void)deallocFireImage {
    [self.fireImageView removeFromSuperview];
    self.fireImageView = nil;
}



-(void)initCaptionTextView {
    if(!_captionView) {
        _captionView = [[TGCaptionView alloc] initWithFrame:NSZeroRect];
        [self.containerView addSubview:_captionView];
    }
}


- (void)deallocCaptionTextView {
    [_captionView removeFromSuperview];
    _captionView = nil;
}


-(void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    
    MessageTableItemPhoto *item = (MessageTableItemPhoto *)self.item;
    
    [self.progressView setImage:cellState == CellStateSending ? image_DownloadIconWhite() : nil forState:TMLoaderViewStateNeedDownload];
    [self.progressView setImage:cellState == CellStateSending ? image_LoadCancelWhiteIcon() : nil forState:TMLoaderViewStateDownloading];
    [self.progressView setImage:cellState == CellStateSending ? image_LoadCancelWhiteIcon() : nil forState:TMLoaderViewStateUploading];

    
    
    BOOL isNeedSecretBlur = ([self.item.message isKindOfClass:[TL_destructMessage class]] && ((TL_destructMessage *)self.item.message).ttl_seconds < 60*60 && ((TL_destructMessage *)self.item.message).ttl_seconds > 0);

    
    [self deallocFireImage];
    
    if(cellState == CellStateNormal) {
        
        if(isNeedSecretBlur)
            [self initFireImage];
        
        [self.imageView setIsAlwaysBlur:isNeedSecretBlur];
        [self.fireImageView setHidden:!isNeedSecretBlur];
        [self.fireImageView setCenterByView:self.imageView];
    }
        
    
    [self.progressView setHidden:self.item.isset];
    
    
    if(!self.progressView.isHidden)
    {
        if(item.imageObject.downloadItem) {
            [self.progressView setCurrentProgress:5 + MAX(( item.imageObject.downloadItem.progress - 5),0)];
            [self.progressView setProgress:self.progressView.currentProgress animated:YES];
        }
        
    }
    
    [self.progressView setState:cellState];
    
    [self.progressView setCenterByView:self.imageView];
}

- (void) setItem:(MessageTableItemPhoto *)item {
    
    [super setItem:item];
    
    
    self.imageView.object = item.imageObject;
    
    [self.imageView setFrameSize:item.imageSize];

    [self updateCellState];

    [item.imageObject.supportDownloadListener setProgressHandler:^(DownloadItem *item) {
       
        [ASQueue dispatchOnMainQueue:^{
            
            [self.progressView setProgress:5 + MAX(( item.progress - 5),0) animated:YES];
            
        }];
        
    }];
    
    [item.imageObject.supportDownloadListener setCompleteHandler:^(DownloadItem *item) {
        
        [ASQueue dispatchOnMainQueue:^{
            [self.progressView setProgress:100 animated:YES];
            
            dispatch_after_seconds(0.2, ^{
                [self updateCellState];
            });
        }];
        
    }];
    
    
    if(item.caption) {
        [self initCaptionTextView];
        
        [_captionView setFrame:NSMakeRect(0, NSHeight(self.containerView.frame) - item.captionSize.height , item.imageSize.width, item.captionSize.height)];
        
        [_captionView setAttributedString:item.caption fieldSize:item.captionSize];
        
        [_captionView setItem:item];
        
    } else {
        [self deallocCaptionTextView];
    }
        
}

-(void)clearSelection {
    [super clearSelection];
    [_captionView.textView setSelectionRange:NSMakeRange(NSNotFound, 0)];
}

-(BOOL)mouseInText:(NSEvent *)theEvent {
    return [_captionView.textView mouseInText:theEvent] || [super mouseInText:theEvent];
}

-(void)setEditable:(BOOL)editable animation:(BOOL)animation
{
    [super setEditable:editable animation:animation];
    self.imageView.isNotNeedHackMouseUp = editable;
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

-(void)mouseDown:(NSEvent *)theEvent {
    
    _startDragLocation = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if([_imageView mouse:_startDragLocation inRect:_imageView.frame])
        return;
    
    [super mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
    
    if(![_imageView mouse:_startDragLocation inRect:_imageView.frame]) 
        return;
    
    
    NSPoint eventLocation = [self.imageView convertPoint: [theEvent locationInWindow] fromView: nil];
   
    if([self.imageView hitTest:eventLocation]) {
        NSPoint dragPosition = NSMakePoint(80, 8);
        
        NSString *path = locationFilePath(((MessageTableItemPhoto *)self.item).photoLocation,@"jpg");
        
        
        NSPasteboard *pasteBrd=[NSPasteboard pasteboardWithName:TGImagePType];
        
        
        [pasteBrd declareTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,nil] owner:self];
        
        
        NSImage *dragImage = [self.imageView.image copy];
        
        dragImage = [ImageUtils imageResize:dragImage newSize:self.imageView.frame.size];
        
        
        [pasteBrd setData:[self.imageView.image TIFFRepresentation] forType:NSTIFFPboardType];
        
        [pasteBrd setPropertyList:@[path] forType:NSFilenamesPboardType];
        
        [pasteBrd setString:path forType:NSStringPboardType];
        
        [self dragImage:dragImage at:dragPosition offset:NSZeroSize event:theEvent pasteboard:pasteBrd source:self slideBack:NO];
    }
    
}


-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!_captionView.textView) {
        return;
    }
    
    
    if(!anim) {
        _captionView.textView.backgroundColor = color;
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
    animation.removedOnCompletion = YES;
    [_captionView.textView pop_addAnimation:animation forKey:@"background"];
    
    
}



-(void)_colorAnimationEvent {
    
    if(!_captionView.textView)
        return;
    
    CALayer *currentLayer = (CALayer *)[_captionView.textView.layer presentationLayer];
    
    id value = [currentLayer valueForKeyPath:@"backgroundColor"];
    
    _captionView.textView.layer.backgroundColor = (__bridge CGColorRef)(value);
    [_captionView.textView setNeedsDisplay:YES];
}

-(void)dealloc {
    MessageTableItemPhoto *item = (MessageTableItemPhoto *) self.item;
    
    [self.progressView pop_removeAllAnimations];
    
    [item.imageObject.supportDownloadListener setCompleteHandler:nil];
    [item.imageObject.supportDownloadListener setProgressHandler:nil];
}

@end
