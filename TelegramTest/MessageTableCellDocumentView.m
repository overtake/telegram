
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
#import "DownloadAudioItem.h"
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"
#import "TGOpusAudioPlayerAU.h"
#import "StickersPanelView.h"
#import "NSMenuItemCategory.h"
#import "TGPhotoViewer.h"

@interface DocumentThumbImageView()
@property (nonatomic, strong) NSImage *originImage;
@property (nonatomic) BOOL isAlwaysBlur;
@end

@implementation DocumentThumbImageView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        self.isNotNeedHackMouseUp = YES;
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
}


static CAAnimation *ani() {
    static CAAnimation *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.duration = .2;
    });
    return animation;
}

- (void)setIsAlwaysBlur:(BOOL)isAlwaysBlur {
    if(self->_isAlwaysBlur == isAlwaysBlur)
        return;
    
    self->_isAlwaysBlur = isAlwaysBlur;
    [self setImage:self.originImage];
}

- (void)setImage:(NSImage *)image {
    
    self.originImage = image;

    if(image == nil) {
  //      [self removeAnimationForKey:@"contents"];
        [super setImage:image];
        return;
    }
    
    
    BOOL needAnimation = self.image && (self.image.size.width != 100 || self.image.size.height != 100);
    
    if(self.isAlwaysBlur) {
        
        [ASQueue dispatchOnStageQueue:^{
            NSImage *blured = [self blur:image];
            [[ASQueue mainQueue] dispatchOnQueue:^{
                [super setImage:blured];
            }];
            
        }];

        return;
    }
    
    
    if(needAnimation) {
       // [self addAnimation:ani() forKey:@"contents"];
    } else {
      //  [self removeAnimationForKey:@"contents"];
    }
    
    [super setImage:image];
}

- (NSImage *)blur:(NSImage *)image {
    NSSize size = self.frame.size;
    CGFloat displayScale = [[NSScreen mainScreen] backingScaleFactor];
    
    size.width *= displayScale;
    size.height *= displayScale;
    
    image = [ImageUtils blurImage:image blurRadius:self.frame.size.width / 2 frameSize:size];
    return image;
}

@end


@interface MessageTableCellDocumentView()

@property (nonatomic, strong) BTRButton *attachButton;

@property (nonatomic, strong) TMTextField *fileNameTextField;
@property (nonatomic, strong) TMTextField *fileSizeTextField;
@property (nonatomic, strong) TMHyperlinkTextField *actionsTextField;

@property (nonatomic, strong) MessageTableItemDocument *item;

@property (nonatomic, strong) TGAudioPlayer *player;

@property (nonatomic,assign) NSPoint startDragLocation;



@end

#define TEXT_Y 32.0f

#define MIN_TEXT_X 120.0f-38

@implementation MessageTableCellDocumentView

static NSImage *attachBackground() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 48, 48);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0xf2f2f2) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        [image unlockFocus];
    });
    return image;
}


static NSImage *attachDownloadedBackground() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 48, 48);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0x4ba3e2) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        [image_DocumentThumbIcon() drawInRect:NSMakeRect(roundf((48 - image_DocumentThumbIcon().size.width)/2), roundf((48 - image_DocumentThumbIcon().size.height)/2), image_DocumentThumbIcon().size.width, image_DocumentThumbIcon().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return image;
}

static NSImage *attachBackgroundThumb() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 100, 100);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0xf4f4f4) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:4 yRadius:4];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        [self setProgressStyle:TMCircularProgressLightStyle];
        [self setProgressFrameSize:NSMakeSize(48, 48)];
        
        self.attachButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        [self.attachButton addBlock:^(BTRControlEvents events) {
            
            
            [weakSelf mouseDown:[NSApp currentEvent]];
            
            if(weakSelf.isEditable) {
                return;
            }
            if(weakSelf.item.state == DocumentStateDownloaded) {
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
        
        self.fileNameTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
        [self.fileNameTextField setBordered:NO];
        [self.fileNameTextField setEditable:NO];
        [self.fileNameTextField setSelectable:NO];
        [self.fileNameTextField setTextColor:NSColorFromRGB(0x333333)];
        [self.fileNameTextField setFont:TGSystemMediumFont(13)];
        [self.fileNameTextField setDrawsBackground:NO];
//        [self.fileNameTextField setBackgroundColor:[NSColor redColor]];
        
        [[self.fileNameTextField cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [[self.fileNameTextField cell] setTruncatesLastVisibleLine:YES];
        
        [self.containerView addSubview:self.fileNameTextField];
        
        self.fileSizeTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
        [self.fileSizeTextField setBordered:NO];
        [self.fileSizeTextField setEditable:NO];
        [self.fileSizeTextField setSelectable:NO];
        [self.fileSizeTextField setTextColor:NSColorFromRGB(0x9b9b9b)];
        [self.fileSizeTextField setFont:TGSystemFont(12)];
        [self.fileSizeTextField setDrawsBackground:NO];
        [self.fileSizeTextField setBackgroundColor:[NSColor grayColor]];
        [self.containerView addSubview:self.fileSizeTextField];
        
        self.actionsTextField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(0, 14, 200, 20)];
        [self.actionsTextField setBordered:NO];
        [self.actionsTextField setDrawsBackground:NO];
        [self.actionsTextField setUrl_delegate:self];
        [self.containerView addSubview:self.actionsTextField];
        
        
        self.thumbView = [[DocumentThumbImageView alloc] initWithFrame:NSMakeRect(1, 1, 48, 48)];
        [self.thumbView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
       // [self.thumbView setCornerRadius:4];
        
        [self.thumbView setCornerRadius:4];
        
        

        [self.thumbView setContentMode:BTRViewContentModeCenter];
        
        NSMutableArray *subviews = [self.attachButton.subviews mutableCopy];
        [subviews insertObject:self.thumbView atIndex:1];
        [self.attachButton setSubviews:subviews];
        
        [self setProgressToView:self.attachButton];
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
    
    [CATransaction begin];
    
    [CATransaction setDisableActions:YES];
    
    NSString *downloadString = [NSString stringWithFormat:format, progress];
    
    [self.actionsTextField setAttributedStringValue:[[NSAttributedString alloc] initWithString:downloadString attributes:@{NSFontAttributeName: TGSystemFont(14), NSForegroundColorAttributeName: NSColorFromRGB(0x9b9b9b)}]];
    
    [CATransaction commit];
}

- (void)startDownload:(BOOL)cancel {
    if(!self.item.downloadItem || self.item.downloadItem.downloadState == DownloadStateCanceled) {
        [self setProgressStringValue:0 format:NSLocalizedString(@"Document.Downloading", nil)];
    }
    
    [super startDownload:cancel];
}



- (void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    if(cellState == CellStateNormal) {
        [self.actionsTextField setAttributedStringValue:docStateLoaded()];
    }
    
    if(cellState == CellStateSending) {
        [self.actionsTextField setAttributedStringValue:nil];
    }
    
    if(cellState == CellStateNeedDownload) {
        [self.actionsTextField setAttributedStringValue:docStateDownload()];
    }
    
   
    switch (self.cellState) {
        case CellStateNormal:
            self.item.state = DocumentStateDownloaded;
            break;
            
        case CellStateSending:
            self.item.state = DocumentStateUploading;
            [self setProgressStringValue:self.item.messageSender.progress format:NSLocalizedString(@"Document.Uploading", nil)];
            break;
            
        case CellStateNeedDownload:
            self.item.state = DocumentStateWaitingDownload;
            break;
            
        case CellStateDownloading:
            self.item.state = DocumentStateDownloading;
            break;
            
        case CellStateCancelled:
            self.item.state = DocumentStateWaitingDownload;
            break;
            
        default:
            break;
    }
    
    
    
    switch (self.item.state) {
        case DocumentStateDownloaded:
            //[self.thumbView setIsAlwaysBlur:NO];
            self.thumbView.object = self.item.thumbObject;
            
            [self.attachButton setBackgroundImage:self.item.isHasThumb ? attachBackgroundThumb() : attachDownloadedBackground() forControlState:BTRControlStateNormal];
            
           break;
            
        case DocumentStateDownloading:
          //  [self.thumbView setIsAlwaysBlur:self.item.isHasThumb];
            [self setProgressStringValue:self.item.downloadItem.progress format:NSLocalizedString(@"Document.Downloading", nil)];
            [self.attachButton setBackgroundImage:self.item.isHasThumb ? attachBackgroundThumb() : attachBackground() forControlState:BTRControlStateNormal];
            [self.progressView setState:TMLoaderViewStateDownloading];
            break;
            
        case DocumentStateUploading:
           // [self.thumbView setIsAlwaysBlur:self.item.isHasThumb];
            [self.attachButton setBackgroundImage:self.item.isHasThumb ? attachBackgroundThumb() : attachBackground() forControlState:BTRControlStateNormal];
            [self.progressView setState:TMLoaderViewStateUploading];
            break;
            
        case DocumentStateWaitingDownload:
          //  [self.thumbView setIsAlwaysBlur:self.item.isHasThumb];
            [self.attachButton setBackgroundImage:self.item.isHasThumb ? attachBackgroundThumb() : attachBackground() forControlState:BTRControlStateNormal];
            [self.progressView setState:TMLoaderViewStateNeedDownload];
            [self.progressView setProgress:0 animated:NO];
            break;
            
        default:
            break;
    }
}

- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Documents menu"];
    
   
    
    
    if([self.item isset]) {
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Message.File.ShowInFinder", nil) withBlock:^(id sender) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:self.item.path]]];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [self performSelector:@selector(saveAs:) withObject:self];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [self performSelector:@selector(copy:) withObject:self];
        }]];
        
        
        NSArray *apps = [FileUtils appsForFileUrl:((MessageTableItemDocument *)self.item).path];
        
        NSMenuItem *openWithItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.OpenWith", nil) withBlock:nil];
        
        NSMenu *openWithMenu = [[NSMenu alloc] initWithTitle:@"Open"];
        
        [openWithItem setSubmenu:openWithMenu];
        
        if(apps.count > 0) {
            
            
            
            for (OpenWithObject *a in apps) {
                NSMenuItem *item = [NSMenuItem menuItemWithTitle:[a fullname] withBlock:^(id sender) {
                    
                    [[NSWorkspace sharedWorkspace] openFile:((MessageTableItemDocument *)self.item).path withApplication:[a.app path]];
                    
                    
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
                        
                        [[NSWorkspace sharedWorkspace] openFile:((MessageTableItemDocument *)self.item).path withApplication:path];
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
    
    item.cell = self;
    
    [self.attachButton setFrameSize:item.thumbSize];
    
    [self setProgressFrameSize:NSMakeSize(48, 48)];
    
    
    if(item.isHasThumb) {
        [self.attachButton setBackgroundImage:attachBackgroundThumb() forControlState:BTRControlStateNormal];
        self.thumbView.image = nil;
        
        NSImage *thumb = [TGCache cachedImage:item.thumbObject.location.cacheKey group:@[IMGCACHE,THUMBCACHE]];
        
        if(thumb)
            self.thumbView.image = thumb;
         else
            self.thumbView.object = item.thumbObject;
        
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
       
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
    } else {
        
        [self.progressView setImage:image_DownloadIconGrey() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelGrayIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelGrayIcon() forState:TMLoaderViewStateUploading];
        
        self.thumbView.image = nil;
        [self setProgressStyle:TMCircularProgressLightStyle];
    }
    
    
   [self updateDownloadState];
    
    [self.fileNameTextField setStringValue:item.fileName];
    if(!item.fileNameSize.width) {
        [self.fileNameTextField sizeToFit];
        NSSize size = self.fileNameTextField.bounds.size;
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
        item.fileNameSize = size;
    }
    
    [self.fileSizeTextField setStringValue:item.fileSize];
    if(!item.fileSizeSize.width) {
        [self.fileSizeTextField sizeToFit];
        NSSize size = self.fileSizeTextField.bounds.size;
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
        item.fileSizeSize = size;
    }
    
    float offset = floorf( (item.thumbSize.height - 38) / 2.f);
    
    [self.actionsTextField setFrameOrigin:NSMakePoint(item.thumbSize.width + 14, offset)];
    [self.fileNameTextField setFrameOrigin:NSMakePoint(item.thumbSize.width + 14, offset + 22)];
    [self.fileSizeTextField setFrameOrigin:NSMakePoint(item.thumbSize.width + 14, offset + 22)];
    
    [self buildSizes];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self buildSizes];
}

- (void)buildSizes {
    
    NSSize fileNameSize = self.item.fileNameSize;
    NSSize fileSizeSize = self.item.fileSizeSize;
    
    float offsetX = self.fileNameTextField.frame.origin.x;

    float maxWidth = self.bounds.size.width - offsetX - self.item.dateSize.width - 150;
    
    if(self.item.isForwadedMessage)
        maxWidth -= 54;
    
    
    if(fileNameSize.width + fileSizeSize.width + 1 <= maxWidth) {
        [self.fileNameTextField setFrame:NSMakeRect(offsetX, self.fileNameTextField.frame.origin.y, fileNameSize.width, fileNameSize.height)];
        [self.fileSizeTextField setFrame:NSMakeRect(self.fileNameTextField.frame.origin.x + self.fileNameTextField.bounds.size.width + 1, self.fileSizeTextField.frame.origin.y, fileSizeSize.width, fileSizeSize.height)];
    } else {
        [self.fileSizeTextField setFrame:NSMakeRect(offsetX + maxWidth - fileSizeSize.width, self.fileSizeTextField.frame.origin.y, fileSizeSize.width, fileSizeSize.height)];
        
        [self.fileNameTextField setFrame:NSMakeRect(offsetX, self.fileNameTextField.frame.origin.y, self.fileSizeTextField.frame.origin.x - offsetX + 2, fileNameSize.height)];
    }
    
}

- (void)textField:(id)textField handleURLClick:(NSString *)url {
    
    if(self.isEditable)
    {
        [self mouseDown:[NSApp currentEvent]];
        return;
    }
    
    if(self.cellState != CellStateNormal && self.cellState != CellStateNeedDownload) {
        
        return;
    }
    
    if([url isEqualToString:@"download"]) {
        
        if([self.item canDownload])
            [self startDownload:NO];
    } else if ([url isEqualToString:@"finder"]){
        if(self.item.isset) {
           [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:self.item.path]]];
            
        } else {
            if([self.item canDownload])
                [self startDownload:NO];
        }
    } else if([url isEqualToString:@"show"])  {
        if(self.item.isset)
            [self open];
        else if([self.item canDownload]) [self startDownload:NO];
    }
}

- (void)redrawThumb:(NSImage *)image {
    [self.thumbView setImage:image];
}

- (void)open {
    
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    
    if([self.item.message.media.document.mime_type hasPrefix:@"image"]) {
        [[TGPhotoViewer viewer] showDocuments:previewObject conversation:self.item.message.conversation];
    } else {
        TMPreviewDocumentItem *item = [[TMPreviewDocumentItem alloc] initWithItem:previewObject];
        [[TMMediaController controller] show:item];
    }
    
}


-(void)mouseDown:(NSEvent *)theEvent {
    
    _startDragLocation = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if([_attachButton mouse:_startDragLocation inRect:_attachButton.frame])
        return;
    
    [super mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
    
    if(![_attachButton mouse:_startDragLocation inRect:_attachButton.frame])
        return;
    
    NSPoint eventLocation = [_attachButton convertPoint: [theEvent locationInWindow] fromView: nil];
    
    if([_attachButton hitTest:eventLocation]) {
        NSPoint dragPosition = NSMakePoint(80, 8);
        
        NSString *path = mediaFilePath(self.item.message.media);
        
        
        NSPasteboard *pasteBrd=[NSPasteboard pasteboardWithName:TGImagePType];
        
        
        [pasteBrd declareTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,nil] owner:self];
        
        
        NSImage *dragImage = self.item.isHasThumb ? [self.thumbView.image copy] : _attachButton.backgroundImageView.image;
        
        dragImage = cropCenterWithSize(dragImage,self.thumbView.frame.size);
        
        dragImage = imageWithRoundCorners(dragImage,4,dragImage.size);
        
        [pasteBrd setPropertyList:@[path] forType:NSFilenamesPboardType];
        
        [pasteBrd setString:path forType:NSStringPboardType];
        
        [self dragImage:dragImage at:dragPosition offset:NSZeroSize event:theEvent pasteboard:pasteBrd source:self slideBack:NO];
    }
    
}


static NSAttributedString *docStateDownload() {
    static NSAttributedString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Message.File.Download", nil) attributes:@{NSForegroundColorAttributeName:LINK_COLOR, NSLinkAttributeName: @"download", NSFontAttributeName: TGSystemFont(13)}];
    });
    return instance;
}

static NSAttributedString *docStateLoaded() {
    static NSAttributedString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        
        
        NSRange range = [mutableAttributedString appendString:NSLocalizedString(@"Message.File.ShowInFinder", nil) withColor:BLUE_UI_COLOR];
        [mutableAttributedString setLink:@"finder" forRange:range];
        
        
        [mutableAttributedString setFont:TGSystemFont(13) forRange:mutableAttributedString.range];

        instance = mutableAttributedString;
    });
    return instance;
}


@end
