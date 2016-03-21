
//
//  MessageTableCellDocumentView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellDocumentView.h"
#import <Quartz/Quartz.h>
#import "TMMediaController.h"
#import "TLPeer+Extensions.h"
#import "TMPreviewDocumentItem.h"
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"
#import "TGOpusAudioPlayerAU.h"
#import "StickersPanelView.h"
#import "NSMenuItemCategory.h"
#import "TGPhotoViewer.h"
#import "TGTextLabel.h"
#import "TGCTextView.h"
@interface MessageTableCellDocumentView()

@property (nonatomic, strong) BTRButton *attachButton;

@property (nonatomic, strong) TGCTextView *fileNameTextField;
@property (nonatomic, strong) TGTextLabel *actionsTextField;

@property (nonatomic,assign) NSPoint startDragLocation;



@end


@implementation MessageTableCellDocumentView




- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        self.attachButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        self.attachButton.wantsLayer = YES;
        [self.attachButton addBlock:^(BTRControlEvents events) {
            
            
            [weakSelf mouseDown:[NSApp currentEvent]];
            
            if(weakSelf.isEditable) {
                return;
            }
            if(weakSelf.cellState == CellStateNormal) {
                if(weakSelf.item.isset) {
                    [weakSelf open];
                    return;
                }
            }
            
        } forControlEvents:BTRControlEventLeftClick];
        
        [self.attachButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf mouseDown:[NSApp currentEvent]];
            
        } forControlEvents:BTRControlEventMouseDownInside];

        
        
        [self.containerView addSubview:self.attachButton];
        
        self.fileNameTextField = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        
        [self.containerView addSubview:self.fileNameTextField];
        
        self.actionsTextField = [[TGTextLabel alloc] initWithFrame:NSZeroRect];
       
        self.fileNameTextField.linkCallback = self.actionsTextField.linkCallback = ^(NSString *link) {
            MessageTableItemDocument *item = (MessageTableItemDocument *)weakSelf.item;
            
            if(weakSelf.isEditable)
            {
                [weakSelf mouseDown:[NSApp currentEvent]];
                return;
            }
            
            if(weakSelf.cellState != CellStateNormal && weakSelf.cellState != CellStateNeedDownload)
                return;
            
            if([link isEqualToString:@"chat://download"]) {
                
                if([item canDownload])
                    [weakSelf startDownload:NO];
            } else  if([link isEqualToString:@"chat://finder"]){
                if(weakSelf.item.isset) {
                    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:item.path]]];
                    
                } else {
                    if([weakSelf.item canDownload])
                        [weakSelf startDownload:NO];
                }
            }

        };
        
        [self.containerView addSubview:self.actionsTextField];
        
        self.thumbView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        [self.thumbView setCornerRadius:4];
        

        [self.thumbView setContentMode:BTRViewContentModeScaleAspectFill];
        
        NSMutableArray *subviews = [self.attachButton.subviews mutableCopy];
        [subviews insertObject:self.thumbView atIndex:1];
        [self.attachButton setSubviews:subviews];
        
        [self setProgressToView:self.attachButton];
        
        [self setProgressFrameSize:NSMakeSize(40,40)];

    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];

}

- (void)downloadProgressHandler:(DownloadItem *)item {
    [super downloadProgressHandler:item];
    [self setProgressStringValue:item.progress format:NSLocalizedString(@"Document.Downloading", nil)];
}

- (void)uploadProgressHandler:(SenderItem *)item animated:(BOOL)animation {
    [super uploadProgressHandler:item animated:animation];
    [self setProgressStringValue:item.progress format:NSLocalizedString(@"Document.Uploading", nil)];
}

- (void)setProgressStringValue:(float)progress format:(NSString *)format {
    
    if(self.cellState == CellStateSending || self.cellState == CellStateDownloading) {
        
        MessageTableItemDocument *item = (MessageTableItemDocument *)self.item;
        
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        
        NSRange range = [attributedString appendString:item.message.media.document.file_name withColor:TEXT_COLOR];
        
        [attributedString setFont:TGSystemMediumFont(13) forRange:range];
        
        [attributedString appendString:@"\n"];
        
        range = [attributedString appendString:[NSString stringWithFormat:format,progress] withColor:GRAY_TEXT_COLOR];
        
        [attributedString setFont:TGSystemFont(13) forRange:range];
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:[item.fileNameAttrubutedString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL] range:attributedString.range];
        

        
        [self.fileNameTextField setAttributedString:attributedString];
    }
    
}

-(int)maxFieldWidth {
    return self.item.blockSize.width - NSWidth(self.attachButton.frame) - self.item.defaultOffset;
}

- (void)startDownload:(BOOL)cancel {
    if(!self.item.downloadItem || self.item.downloadItem.downloadState == DownloadStateCanceled) {
        [self setProgressStringValue:0 format:NSLocalizedString(@"Document.Downloading", nil)];
    }
    
    [super startDownload:cancel];
}



- (void)setCellState:(CellState)cellState animated:(BOOL)animated {
    
    CellState oldState = self.cellState;
    
    [super setCellState:cellState animated:animated];
    
    MessageTableItemDocument *item = (MessageTableItemDocument *) self.item;
    
    if(oldState != CellStateNormal && cellState == CellStateNormal) {
        [item makeSizeByWidth:item.makeSize];
        [super setItem:item];
    }
    
    if(cellState == CellStateNormal) {
        if([self.item.message isKindOfClass:[TL_destructMessage class]])
            [self.actionsTextField setText:nil maxWidth:0];
         else
            [self.actionsTextField setText:docStateLoaded() maxWidth:self.maxFieldWidth];
    }
    
    
    
    if(cellState == CellStateSending) {
        [self.actionsTextField setText:nil maxWidth:0];
    }
    
    
    [self.attachButton.layer pop_removeAllAnimations];
    
    if(animated && !item.isHasThumb) {
        POPBasicAnimation *opacity = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
        
        opacity.fromValue = @(0.8f);
        opacity.toValue = @(1.0f);
        opacity.removedOnCompletion = YES;
        [self.attachButton.layer pop_addAnimation:opacity forKey:@"opacity"];
    }
    
    [self.attachButton setBackgroundImage:item.isHasThumb ? gray_resizable_placeholder() : blue_circle_background_image() forControlState:BTRControlStateNormal];
   
    switch (self.cellState) {
        case CellStateNormal:
            self.thumbView.object = item.thumbObject;
            [self.attachButton setBackgroundImage:item.isHasThumb ? gray_resizable_placeholder() : attach_downloaded_background() forControlState:BTRControlStateNormal];
            [self.fileNameTextField setAttributedString:item.fileNameAttrubutedString];
            break;
            
        case CellStateSending:
            [self setProgressStringValue:self.item.messageSender.progress format:NSLocalizedString(@"Document.Uploading", nil)];
            break;

        case CellStateDownloading:
            [self setProgressStringValue:self.item.downloadItem.progress format:NSLocalizedString(@"Document.Downloading", nil)];
        
            break;
        case CellStateNeedDownload:
            [self.fileNameTextField setAttributedString:item.fileNameAttrubutedString];
            
            break;

        default:
            break;
    }
    
    [self.fileNameTextField setFrameSize:NSMakeSize(self.maxFieldWidth, item.fileNameSize.height)];
    
    [self.actionsTextField setHidden:self.cellState != CellStateNormal || !item.isHasThumb];
}


-(void)openInQuickLook:(id)sender {
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    TMPreviewDocumentItem *item = [[TMPreviewDocumentItem alloc] initWithItem:previewObject];
    [[TMMediaController controller] show:item];

}

- (NSMenu *)contextMenu {
    
    
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Documents menu"];
    
    weak();
    
    
    if([self.item isset]) {
        
        if([self.item.message.media.document.mime_type hasPrefix:@"image"]) {
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.OpenInQuickLook", nil) withBlock:^(id sender) {
                [weakSelf performSelector:@selector(openInQuickLook:) withObject:weakSelf];
            }]];
        }
        
        MessageTableItemDocument *item = (MessageTableItemDocument *)self.item;
        
        if([self.item.message isKindOfClass:[TL_destructMessage class]])
            return menu;
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        if(![self.item.message isKindOfClass:[TL_destructMessage class]]) {
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Message.File.ShowInFinder", nil) withBlock:^(id sender) {
                [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:item.path]]];
            }]];
        }
        
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [weakSelf performSelector:@selector(saveAs:) withObject:weakSelf];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [weakSelf performSelector:@selector(copy:) withObject:weakSelf];
        }]];
        
        
        NSArray *apps = [FileUtils appsForFileUrl:((MessageTableItemDocument *)self.item).path];
        
        NSMenuItem *openWithItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.OpenWith", nil) withBlock:nil];
        
        NSMenu *openWithMenu = [[NSMenu alloc] initWithTitle:@"Open"];
        
        [openWithItem setSubmenu:openWithMenu];
        
        if(apps.count > 0) {
            
            
            
            for (OpenWithObject *a in apps) {
                NSMenuItem *item = [NSMenuItem menuItemWithTitle:[a fullname] withBlock:^(id sender) {
                    
                    [[NSWorkspace sharedWorkspace] openFile:((MessageTableItemDocument *)weakSelf.item).path withApplication:[a.app path]];
                    
                    
                }];
                
                [item setImage:[a icon]];
                
                [openWithMenu addItem:item];
                
            }
            
            [openWithMenu addItem:[NSMenuItem separatorItem]];
            
            
        }
        
        [openWithMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Other", nil) withBlock:^(id sender) {
            
            NSOpenPanel *openPanel = [NSOpenPanel openPanel];
            
            
            NSArray *appsPaths = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory inDomains:NSLocalDomainMask];
            if ([appsPaths count]) [openPanel setDirectoryURL:[appsPaths firstObject]];
            
            [openPanel setCanChooseDirectories:NO];
            [openPanel setCanChooseFiles:YES];
            [openPanel setAllowsMultipleSelection:NO];
            [openPanel setResolvesAliases:YES];
            
            [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
                if (result == NSFileHandlingPanelOKButton) {
                    if ([[openPanel URLs] count] > 0) {
                        NSURL *app = [[openPanel URLs] objectAtIndex:0];
                        NSString *path = [app path];
                        
                        [[NSWorkspace sharedWorkspace] openFile:((MessageTableItemDocument *)weakSelf.item).path withApplication:path];
                    }
                }
            }];
            
            
        }]];
        
        
        [menu addItem:openWithItem];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
    }
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];

    return menu;
}




- (void)setItem:(MessageTableItemDocument *)item {
    [super setItem:item];
        
    [self.attachButton setFrameSize:item.thumbSize];
    
    [self.thumbView setFrameSize:item.thumbSize];
    
    if(item.isHasThumb) {
        [self.attachButton setBackgroundImage:gray_resizable_placeholder() forControlState:BTRControlStateNormal];
        self.thumbView.image = nil;
        
        NSImage *thumb = [TGCache cachedImage:item.thumbObject.location.cacheKey group:@[IMGCACHE,THUMBCACHE]];
        
        if(thumb)
            self.thumbView.image = thumb;
         else
            self.thumbView.object = item.thumbObject;
        
        [self setProgressStyle:TMCircularProgressDarkStyle];

    } else {
        self.thumbView.image = nil;
        [self setProgressStyle:TMCircularProgressLightStyle];
        [self.progressView setProgressColor:[NSColor whiteColor]];
    }
    
    
    [self updateDownloadState];
    
    
    
    
    [self updateFrames];

}

-(void)updateFrames {
    
    MessageTableItemDocument *item = (MessageTableItemDocument *)self.item;
    
    
    [self.fileNameTextField setFrameOrigin:NSMakePoint(item.isHasThumb ? NSMaxX(self.thumbView.frame) + self.item.defaultOffset : NSMaxX(self.attachButton.frame) + self.item.defaultOffset, item.isHasThumb ? item.defaultContentOffset : roundf(((item.blockSize.height - item.captionSize.height) - NSHeight(self.fileNameTextField.frame))/2))];
    [self.actionsTextField setFrameOrigin:NSMakePoint(item.isHasThumb ? NSMaxX(self.thumbView.frame) + self.item.defaultOffset : NSMaxX(self.attachButton.frame) + self.item.defaultOffset, NSMaxY(self.fileNameTextField.frame) + 2)];
}



- (void)open {
    
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    
    if([document_preview_mime_types() indexOfObject:self.item.message.media.document.mime_type] != NSNotFound) {
        if(!self.item.message.isFake)
            [[TGPhotoViewer viewer] showDocuments:previewObject conversation:self.item.message.conversation];
        else
            [[TGPhotoViewer viewer] show:previewObject];
    } else {
        [self openInQuickLook:nil];
    }
    
}


-(void)mouseDown:(NSEvent *)theEvent {
    
    _startDragLocation = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if([_attachButton mouse:_startDragLocation inRect:_attachButton.frame])
        return;
    
    [super mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
    
    MessageTableItemDocument *item = (MessageTableItemDocument *)self.item;
    
    if(![_attachButton mouse:_startDragLocation inRect:_attachButton.frame])
        return;
    
    NSPoint eventLocation = [_attachButton convertPoint: [theEvent locationInWindow] fromView: nil];
    
    if([_attachButton hitTest:eventLocation]) {
        NSPoint dragPosition = NSMakePoint(80, 8);
        
        NSString *path = mediaFilePath(self.item.message);
        
        
        NSPasteboard *pasteBrd=[NSPasteboard pasteboardWithName:TGImagePType];
        
        
        [pasteBrd declareTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,nil] owner:self];
        
        
        NSImage *dragImage = item.isHasThumb ? [self.thumbView.image copy] : _attachButton.backgroundImageView.image;
        
        dragImage = cropCenterWithSize(dragImage,self.thumbView.frame.size);
        
        dragImage = imageWithRoundCorners(dragImage,4,dragImage.size);
        
        [pasteBrd setPropertyList:@[path] forType:NSFilenamesPboardType];
        
        [pasteBrd setString:path forType:NSStringPboardType];
        
        [self dragImage:dragImage at:dragPosition offset:NSZeroSize event:theEvent pasteboard:pasteBrd source:self slideBack:NO];
    }
    
}



static NSAttributedString *docStateLoaded() {
    static NSAttributedString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        
        
        NSRange range = [mutableAttributedString appendString:NSLocalizedString(@"Message.File.ShowInFinder", nil) withColor:BLUE_UI_COLOR];
        [mutableAttributedString setLink:@"chat://finder" forRange:range];
        
        
        [mutableAttributedString setFont:TGSystemFont(13) forRange:mutableAttributedString.range];

        instance = mutableAttributedString;
    });
    return instance;
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!anim) {
        _fileNameTextField.backgroundColor = color;
        _actionsTextField.backgroundColor = color;
    } else {
        [_fileNameTextField pop_addAnimation:anim forKey:@"background"];
        [_actionsTextField pop_addAnimation:anim forKey:@"background"];
    }
    
    
}


@end
