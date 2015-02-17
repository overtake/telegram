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


@interface MessageTableCellVideoView()
@property (nonatomic, strong) NSImageView *playImage;
@property (nonatomic,strong) BTRButton *downloadButton;
@property (nonatomic, strong) MessageCellDescriptionView *videoTimeView;

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
        
        self.videoTimeView = [[MessageCellDescriptionView alloc] initWithFrame:NSMakeRect(10, 10, 0, 0)];
        [self.imageView addSubview:self.videoTimeView];
                
        [self setProgressStyle:TMCircularProgressDarkStyle];
        
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        

    }
    return self;
}


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    const int borderOffset = self.imageView.borderWidth;
    const int borderSize = borderOffset*2;
    
    NSRect rect = NSMakeRect(self.containerView.frame.origin.x-borderOffset, self.containerView.frame.origin.y-borderOffset, NSWidth(self.imageView.frame)+borderSize, NSHeight(self.containerView.frame)+borderSize);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.imageView.roundSize yRadius:self.imageView.roundSize];
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
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    
    TMPreviewVideoItem *item = [[TMPreviewVideoItem alloc] initWithItem:previewObject];
    if(item) {
        [[TMMediaController controller] show:item];
    }
}

- (void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    [self.playImage setHidden:!(cellState == CellStateNormal)];
    
    [self.progressView setState:cellState];
    
    self.imageView.object = ((MessageTableItemVideo *)self.item).imageObject;
    
    [self.imageView setIsAlwaysBlur:self.item.message.media.video.thumb.w != 250];
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
   
    
     [self.imageView setFrameSize:item.blockSize];
    
    
    self.imageView.object = item.imageObject;
    
    [self updateVideoTimeView];
}




- (void)updateVideoTimeView {
    [self.videoTimeView setFrameSize:((MessageTableItemVideo *)self.item).videoTimeSize];
    [self.videoTimeView setString:((MessageTableItemVideo *)self.item).videoTimeAttributedString];
}

- (void)onStateChanged:(SenderItem *)item {
    [super onStateChanged:item];
    
    if(item == self.item.messageSender) {
        [(MessageTableItemVideo *)self.item rebuildTimeString];
        [self updateVideoTimeView];
    }
}



@end