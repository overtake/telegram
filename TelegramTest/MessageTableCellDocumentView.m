
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
#import "TGPeer+Extensions.h"
#import "TMPreviewDocumentItem.h"
#import "DownloadAudioItem.h"
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"
#import "TGOpusAudioPlayerAU.h"


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

- (void)drawRect:(NSRect)dirtyRect {
    //    [super drawRect:dirtyRect];
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
        [self removeAnimationForKey:@"contents"];
        [super setImage:image];
        return;
    }
    
    
    BOOL needAnimation = self.image && (self.image.size.width != 100 || self.image.size.height != 100);
    BOOL isBlur = NO;
    
//    if(image.size.width != 100 || image.size.height != 100) {
//       
//        isBlur = YES;
//        needAnimation = NO;
////        
////        [ASQueue dispatchOnStageQueue:^{
////            NSImage *blured = [self blur:image];
////            [[ASQueue mainQueue] dispatchOnQueue:^{
////                [super setImage:blured];
////            }];
////        }];
////        
////        return;
//       
//    }
    
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
        [self addAnimation:ani() forKey:@"contents"];
    } else {
        [self removeAnimationForKey:@"contents"];
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


@end

#define TEXT_Y 32.0f

#define MIN_TEXT_X 120.0f-38

@implementation MessageTableCellDocumentView

static NSImage *attachBackground() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 50, 50);
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
        [self setProgressFrameSize:NSMakeSize(42, 42)];
        
        self.attachButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        [self.attachButton addBlock:^(BTRControlEvents events) {
            
            switch (weakSelf.item.state) {
                case DocumentStateDownloaded:
                    if(weakSelf.item.isset) {
                        [weakSelf open];
                        return;
                    }
                    
                    if([weakSelf.item canDownload]) {
                        [weakSelf startDownload:NO downloadItemClass:[DownloadDocumentItem class]];
                    }
                    
                    break;
                    
                case DocumentStateWaitingDownload:
                    if([weakSelf.item canDownload])
                        [weakSelf startDownload:NO downloadItemClass:[DownloadDocumentItem class]];
                    break;
                    
                case DocumentStateDownloading:
                    [weakSelf cancelDownload];
                    break;
                    
                case DocumentStateUploading:
                    [weakSelf deleteAndCancel];
                    break;
                    
                default:
                    break;
            }
            
        } forControlEvents:BTRControlEventLeftClick];
        [self.containerView addSubview:self.attachButton];
        
        self.fileNameTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
        [self.fileNameTextField setBordered:NO];
        [self.fileNameTextField setEditable:NO];
        [self.fileNameTextField setSelectable:NO];
        [self.fileNameTextField setTextColor:NSColorFromRGB(0x333333)];
        [self.fileNameTextField setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13]];
        [self.fileNameTextField setDrawsBackground:NO];
//        [self.fileNameTextField setBackgroundColor:[NSColor redColor]];
        
        [[self.fileNameTextField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.fileNameTextField cell] setTruncatesLastVisibleLine:YES];
        
        [self.containerView addSubview:self.fileNameTextField];
        
        self.fileSizeTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
        [self.fileSizeTextField setBordered:NO];
        [self.fileSizeTextField setEditable:NO];
        [self.fileSizeTextField setSelectable:NO];
        [self.fileSizeTextField setTextColor:NSColorFromRGB(0x9b9b9b)];
        [self.fileSizeTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
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
        [self.thumbView setCornerRadius:4];

        
        
        
        NSMutableArray *subviews = [self.attachButton.subviews mutableCopy];
        [subviews insertObject:self.thumbView atIndex:1];
        [self.attachButton setSubviews:subviews];
        
        [self setProgressToView:self.attachButton];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
    

    return;
    
//    if([self.item.message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
//        
//        NSImage *image = [self.item isset] ? image_MessageFile() : image_MessageFileDownload();
//        
//        NSPoint point = NSMakePoint(rect.origin.x + roundf(((rect.size.width - image.size.width) / 2.f)), rect.origin.y + roundf(((rect.size.height - image.size.height) / 2.f)));
//        
//        
//        [image drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
//    }
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
    
    NSString *downloadString = [NSString stringWithFormat:format, progress];
    
    [self.actionsTextField setAttributedStringValue:[[NSAttributedString alloc] initWithString:downloadString attributes:@{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:13], NSForegroundColorAttributeName: NSColorFromRGB(0x9b9b9b)}]];
}

- (void)startDownload:(BOOL)cancel downloadItemClass:(Class)itemClass {
    if(!self.item.downloadItem || self.item.downloadItem.downloadState == DownloadStateCanceled) {
        [self setProgressStringValue:0 format:NSLocalizedString(@"Document.Downloading", nil)];
    }
    
    [super startDownload:cancel downloadItemClass:itemClass];
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
            [self.attachButton setImage:self.item.isHasThumb ? nil : image_MessageFile() forControlState:BTRControlStateNormal];
            [self.thumbView setIsAlwaysBlur:NO];
            self.thumbView.object = self.item.thumbObject;
            break;
            
        case DocumentStateDownloading:
            [self.attachButton setImage:nil forControlState:BTRControlStateNormal];
            [self.thumbView setIsAlwaysBlur:YES];
            [self setProgressStringValue:self.progressView.currentProgress format:NSLocalizedString(@"Document.Downloading", nil)];
            break;
            
        case DocumentStateUploading:
            [self.attachButton setImage:nil forControlState:BTRControlStateNormal];
            [self.thumbView setIsAlwaysBlur:YES];
            break;
            
        case DocumentStateWaitingDownload:
            [self.attachButton setImage:self.item.isHasThumb ? image_Download() : image_MessageFileDownload() forControlState:BTRControlStateNormal];
            [self.thumbView setIsAlwaysBlur:YES];
            break;
            
        default:
            break;
    }
}


- (void)setItem:(MessageTableItemDocument *)item {
    [super setItem:item];
    
    item.cell = self;
    
    [self.attachButton setFrameSize:item.thumbSize];
    
    [self.thumbView setIsAlwaysBlur:NO];
    
    if(item.isHasThumb) {
        [self.attachButton setBackgroundImage:attachBackgroundThumb() forControlState:BTRControlStateNormal];
        self.thumbView.image = nil;
        if(item.cachedThumb) {
            
            self.thumbView.image = item.cachedThumb;
            
        } else {
            
            self.thumbView.object = item.thumbObject;
        
        }
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
        [self setProgressFrameSize:self.progressView.cancelImage.size];
    } else {
        [self.attachButton setBackgroundImage:attachBackground() forControlState:BTRControlStateNormal];
        self.thumbView.image = nil;
        [self setProgressStyle:TMCircularProgressLightStyle];
        [self.progressView setCancelImage:image_MessageFileCancel()];
        
        [self setProgressFrameSize:NSMakeSize(42, 42)];
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
    
    if(self.cellState != CellStateNormal && self.cellState != CellStateNeedDownload) {
        
        return;
    }
    
    if([url isEqualToString:@"download"]) {
        
        if([self.item canDownload])
            [self startDownload:NO downloadItemClass:[DownloadDocumentItem class]];
    } else if ([url isEqualToString:@"finder"]){
        if(self.item.isset) {
           [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:self.item.path]]];
            
        } else {
            if([self.item canDownload])
                [self startDownload:NO downloadItemClass:[DownloadDocumentItem class]];
        }
    } else if([url isEqualToString:@"show"])  {
        if(self.item.isset)
            [self open];
        else if([self.item canDownload]) [self startDownload:NO downloadItemClass:[DownloadDocumentItem class]];
    }
}

- (void)redrawThumb:(NSImage *)image {
    [self.thumbView setImage:image];
}

- (void)open {
    if([self.item isKindOfClass:[MessageTableItemAudio class]]) {
        NSString *path = mediaFilePath(self.item.message.media);
        if([TGOpusAudioPlayerAU canPlayFile:path]) {
            self.player = [[TGOpusAudioPlayerAU alloc] initWithPath:path];
            [self.player play];
        }
        
        return;
    }
    
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    
    TMPreviewDocumentItem *item = [[TMPreviewDocumentItem alloc] initWithItem:previewObject];
    [[TMMediaController controller] show:item];
}


static NSAttributedString *docStateDownload() {
    static NSAttributedString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Message.File.Download", nil) attributes:@{NSForegroundColorAttributeName:LINK_COLOR, NSLinkAttributeName: @"download", NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Medium" size:13]}];
    });
    return instance;
}

static NSAttributedString *docStateLoaded() {
    static NSAttributedString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        
        NSRange range = [mutableAttributedString appendString:NSLocalizedString(@"Message.File.Open", nil) withColor:BLUE_UI_COLOR];
        [mutableAttributedString setLink:@"show" forRange:range];
        
        [mutableAttributedString appendString:@"   "];
        
        range = [mutableAttributedString appendString:NSLocalizedString(@"Message.File.ShowInFinder", nil) withColor:BLUE_UI_COLOR];
        [mutableAttributedString setLink:@"finder" forRange:range];
        
        
        [mutableAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:mutableAttributedString.range];

        instance = mutableAttributedString;
    });
    return instance;
}


@end
