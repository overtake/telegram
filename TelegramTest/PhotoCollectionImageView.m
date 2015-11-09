//
//  PhotoCollectionImageView.m
//  Telegram
//
//  Created by keepcoder on 05.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoCollectionImageView.h"
#import "TMMediaController.h"
#import "TGPhotoViewer.h"
#import "TGCache.h"
#import "TMLoaderView.h"
#import "DownloadVideoItem.h"
#import "TMPreviewVideoItem.h"
@interface PhotoCollectionImageView ()
@property (nonatomic,strong) TMLoaderView *loaderView;
@property (nonatomic,strong) DownloadEventListener *listener;
@property (nonatomic, strong) NSImageView *playImage;
@property (nonatomic, strong) BTRButton *selectButton;

@end

@implementation PhotoCollectionImageView

- (void)drawRect:(NSRect)dirtyRect
{
    // [super drawRect:dirtyRect];
    
    if(!self.image)
        return;
    
    NSPoint point = NSMakePoint(0, 0);
    
    if(self.image.size.width > self.bounds.size.width)
        point.x = roundf((self.image.size.width - self.bounds.size.width)/2);
    
    if(self.image.size.height > self.bounds.size.height)
        point.y = roundf((self.image.size.height - self.bounds.size.height)/2);
    
    [self.image drawInRect:self.bounds fromRect:NSMakeRect(point.x, point.y, self.bounds.size.width, self.bounds.size.height) operation:NSCompositeHighlight fraction:1];
    
}



-(void)mouseUp:(NSEvent *)theEvent {
    
   
    
    PhotoCollectionImageObject *obj = (PhotoCollectionImageObject *) self.object;
    
    
    if([_controller isEditable]) {
        
        [_controller setSelected:![_controller isSelectedItem:obj] forItem:obj];
        
        [self setObject:obj];
        
        return;
    }
    
    if([[(TL_localMessage *)obj.previewObject.media media] isKindOfClass:[TL_messageMediaPhoto class]]) {
        obj.previewObject.reservedObject = imageFromFile(locationFilePath(self.object.location, @"jpg"));
        
        [[TGPhotoViewer viewer] show:obj.previewObject conversation:self.controller.conversation];
    } else if([[(TL_localMessage *)obj.previewObject.media media] isKindOfClass:[TL_messageMediaVideo class]]) {
        [self checkAction];
    }
    
    
}

static NSImage *playVideoImage() {
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

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        
        [self.loaderView setStyle:TMCircularProgressDarkStyle];
        
        [self.loaderView addTarget:self selector:@selector(checkAction)];
        
        [self.loaderView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        [self addSubview:self.loaderView];
        
        [self.loaderView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        
        [self.loaderView setCenterByView:self];
        
        [self.loaderView setState:TMLoaderViewStateNeedDownload];
        
        
        self.playImage = imageViewWithImage(playVideoImage());
        
        [self addSubview:self.playImage];
        
        [self.playImage setCenterByView:self];
        [self.playImage setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        
        
        self.selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ComposeCheckActive().size.width, image_ComposeCheckActive().size.height)];
        
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHighlighted];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateSelected];
        
        [self.selectButton setUserInteractionEnabled:NO];
        
        [self.selectButton setSelected:YES];
        
        [self addSubview:self.selectButton];
    }
    
    return self;
}

-(void)setObject:(PhotoCollectionImageObject *)object {
    [super setObject:object];
    
    TL_localMessage *msg = object.previewObject.media;
    
    
    [self.selectButton setHidden:![_controller isEditable]];
    
    [self.selectButton setSelected:[_controller isSelectedItem:object]];
    
    [self.loaderView setHidden:YES];
    [self.playImage setHidden:YES];
    
    if([msg.media isKindOfClass:[TL_messageMediaVideo class]]) {
        
        [self.loaderView setCenterByView:self];
        
        [self checkState:object];
    }
    
}

-(void)checkState:(PhotoCollectionImageObject *)object {
    
    if(!object.previewObject.reservedObject || ![object.previewObject.reservedObject isKindOfClass:[DownloadVideoItem class]]) {
        object.previewObject.reservedObject = [[DownloadVideoItem alloc] initWithObject:object.previewObject.media];
    }
    
    DownloadVideoItem *downloadItem = object.previewObject.reservedObject;
    
    TMLoaderViewState state = TMLoaderViewStateNeedDownload;
    
    if(downloadItem && (downloadItem.downloadState != DownloadStateWaitingStart && downloadItem.downloadState != DownloadStateCompleted)) {
        
        state = downloadItem.downloadState == DownloadStateCanceled ? TMLoaderViewStateNeedDownload : TMLoaderViewStateDownloading;
        
    }  else if(![self isset:object]) {
        
        state = TMLoaderViewStateNeedDownload;
        
    }
    
    [downloadItem removeAllEvents];
    
    
    self.listener = [[DownloadEventListener alloc] init];
    
    weak();
    
    [self.listener setCompleteHandler:^(DownloadItem * item) {
        
        [ASQueue dispatchOnMainQueue:^{
            object.previewObject.reservedObject = nil;
            [weakSelf checkState:object];
        }];
        
    }];
    
    
    [self.listener setProgressHandler:^(DownloadItem * item) {
        
        [ASQueue dispatchOnMainQueue:^{
            [weakSelf.loaderView setProgress:item.progress animated:YES];
        }];

    }];
    
    
    [downloadItem addEvent:self.listener];
    
    [self.loaderView setState:state];
    
    [self.loaderView setProgress:state == TMLoaderViewStateNeedDownload ? 0 : downloadItem.progress animated:NO];
    
    [self.loaderView setHidden:[self isset:object]];
    
    [self.playImage setHidden:![self isset:object]];
}

-(void)checkAction {
    
    PhotoCollectionImageObject *object = (PhotoCollectionImageObject *)self.object;

    if([self isset:object]) {
        TMPreviewVideoItem *item = [[TMPreviewVideoItem alloc] initWithItem:object.previewObject];
        
        object.previewObject.reservedObject = self;
        
        if(item) {
            [[TMMediaController controller] show:item];
        }
        return;
    } else {
        DownloadVideoItem *downloadItem = object.previewObject.reservedObject;
        
        if(downloadItem.downloadState == DownloadStateDownloading) {
            [downloadItem cancel];
        } else if(downloadItem.downloadState == DownloadStateWaitingStart || downloadItem.downloadState == DownloadStateCanceled) {
            [downloadItem start];
        }
        
        [self checkState:object];
        
        return;
    }
}


-(BOOL)isset:(PhotoCollectionImageObject *)object {
    NSString *path = mediaFilePath([(TL_localMessage *)object.previewObject.media media]);
    return isPathExists(path) && [FileUtils checkNormalizedSize:path checksize:[(TL_localMessage *)object.previewObject.media media].video.size];
}

-(NSImage *)cachedImage:(NSString *)key {
    return [TGCache cachedImage:key group:@[PCCACHE]];
}

-(NSImage *)cachedThumb:(NSString *)key {
    return self.object.placeholder;
}

-(void)dealloc {
    
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self.selectButton setFrameOrigin:NSMakePoint(NSWidth(frame) - 30, NSHeight(frame) - 30)];
}

@end
