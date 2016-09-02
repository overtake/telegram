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
#import <pop/POPCGUtils.h>
#import "TGCaptionView.h"
#import "TGExternalImageObject.h"

@interface MessageTableCellPhotoView()
@property (nonatomic,strong) NSImageView *secretImageView;

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
        
        self.imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        self.imageView.cornerRadius = 4;
        [self.imageView setContentMode:BTRViewContentModeScaleAspectFill];
        [self.imageView setTapBlock:^{
            PreviewObject *object = [[PreviewObject alloc] initWithMsdId:weakSelf.item.message.channelMsgId media:weakSelf.item.message peer_id:weakSelf.item.message.peer_id];
            
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
        
    }
    return self;
}


-(void)openInQuickLook:(id)sender {
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    
    if(!self.item.isset)
        return;
    
    TMPreviewPhotoItem *item = [[TMPreviewPhotoItem alloc] initWithItem:previewObject];
    if(item) {
        [[TMMediaController controller] show:item];
    }

}

- (NSMenu *)contextMenu {
    
    if([self.item.message isKindOfClass:[TL_destructMessage class]])
        return [super contextMenu];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Photo menu"];
    
    [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.OpenInQuickLook", nil) withBlock:^(id sender) {
        [self performSelector:@selector(openInQuickLook:) withObject:self];
    }]];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
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


- (void)initSecretImage {
    if(!_secretImageView) {
        _secretImageView = imageViewWithImage(fireImage());
        
        [_secretImageView setHidden:YES];
        
        [self.imageView addSubview:_secretImageView];

    }
}

- (void)deallocSecretImage {
    [_secretImageView removeFromSuperview];
    _secretImageView = nil;
}




-(void)setCellState:(CellState)cellState animated:(BOOL)animated {
    
    MessageTableItemPhoto *item = (MessageTableItemPhoto *)self.item;
    
     if(self.cellState == CellStateSending && cellState == CellStateNormal) {
        [super setCellState:cellState animated:animated];
        
        if([item.imageObject isKindOfClass:[TGExternalImageObject class]]) {
            [self.item doAfterDownload];
            [self.imageView setObject:item.imageObject];
            [self updateDownloadListeners];
        }
        
     }
    
    [self.progressView setImage:cellState == CellStateSending ? image_DownloadIconWhite() : nil forState:TMLoaderViewStateNeedDownload];
    [self.progressView setImage:cellState == CellStateSending ? image_LoadCancelWhiteIcon() : nil forState:TMLoaderViewStateDownloading];
    [self.progressView setImage:cellState == CellStateSending ? image_LoadCancelWhiteIcon() : nil forState:TMLoaderViewStateUploading];


    
    [self deallocSecretImage];
    
    if(cellState == CellStateNormal) {
        
        if(item.isSecretPhoto)
            [self initSecretImage];
        
        [_secretImageView setHidden:!item.isSecretPhoto];
        [_secretImageView setCenterByView:self.imageView];
    }
    
    
    [self.progressView setHidden:self.item.isset && cellState != CellStateSending];
    
    
    if(!self.progressView.isHidden)
    {
        if(item.imageObject.downloadItem) {
            [self.progressView setCurrentProgress:5 + MAX(( item.imageObject.downloadItem.progress - 5),0)];
            [self.progressView setProgress:self.progressView.currentProgress animated:YES];
        }
        
    }
    
    [self.progressView setCenterByView:self.imageView];
    
    [super setCellState:cellState animated:animated];
}

- (void) setItem:(MessageTableItemPhoto *)item {
    
    [super setItem:item];
    
    _startDragLocation = NSMakePoint(0, 0);
    
    
    self.imageView.object = item.imageObject;
    
    [self.imageView setFrameSize:item.contentSize];

    [self updateCellState:NO];
    
    
    [self updateDownloadListeners];
    
        
}

-(void)updateDownloadListeners {
    
    MessageTableItemPhoto *item = (MessageTableItemPhoto *)self.item;
    
    weak();
    
    [item.imageObject.supportDownloadListener setProgressHandler:^(DownloadItem *item) {
        
        strongWeak();
        
        if(strongSelf == weakSelf) {
            [ASQueue dispatchOnMainQueue:^{
                
                [strongSelf.progressView setProgress:5 + MAX(( item.progress - 5),0) animated:YES];
                
            }];
        }

    }];
    
    [item.imageObject.supportDownloadListener setCompleteHandler:^(DownloadItem *item) {
         strongWeak();
        
        if(strongSelf == weakSelf) {
            [ASQueue dispatchOnMainQueue:^{
                [strongSelf.progressView setProgress:100 animated:YES];
                
                [strongSelf updateCellState:YES];
            }];
        }
    }];
    
}


-(void)setEditable:(BOOL)editable animated:(BOOL)animated
{
    self.imageView.isNotNeedHackMouseUp = editable;
    [super setEditable:editable animated:animated];
}


-(void)mouseDown:(NSEvent *)theEvent {
    
    _startDragLocation = NSMakePoint(0, 0);
    
    if(!self.isEditable) {
        _startDragLocation = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
        
        if([_imageView mouse:_startDragLocation inRect:_imageView.frame])
            return;

    }
    
    [super mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
    
    if(![_imageView mouse:_startDragLocation inRect:_imageView.frame]) 
        return;
    
    if(_startDragLocation.x == 0 && _startDragLocation.y == 0) {
        [self mouseDown:theEvent];
        return;
    }
    
    
    NSPoint eventLocation = [self.imageView convertPoint: [theEvent locationInWindow] fromView: nil];
   
    if([self.imageView hitTest:eventLocation]) {
        NSPoint dragPosition = [self convertPoint:self.imageView.frame.origin fromView:self.imageView];
        
        NSString *path = locationFilePath(((MessageTableItemPhoto *)self.item).imageObject.location,@"jpg");
        
        
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





-(void)dealloc {
    MessageTableItemPhoto *item = (MessageTableItemPhoto *) self.item;
    
    [self.progressView pop_removeAllAnimations];
    
    [item.imageObject.supportDownloadListener setCompleteHandler:nil];
    [item.imageObject.supportDownloadListener setProgressHandler:nil];
}

@end
