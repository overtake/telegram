
//
//  TGWebpageDocumentContainer.m
//  Telegram
//
//  Created by keepcoder on 12/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGWebpageDocumentContainer.h"
#import "TGWebpageDocumentObject.h"
#import "TMMediaController.h"
#import "TMPreviewDocumentItem.h"
@interface TGWebpageDocumentContainer ()
@property (nonatomic,strong) DownloadEventListener *downloadEventListener;
@end

@implementation TGWebpageDocumentContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@synthesize loaderView = _loaderView;

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.imageView.cornerRadius = 0;
        
        
        
        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        
        [self.imageView addSubview:_loaderView];
        
        [_loaderView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [_loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [_loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        [_loaderView setStyle:TMCircularProgressLightStyle];
        [_loaderView setProgressColor:[NSColor whiteColor]];
        [_loaderView addTarget:self selector:@selector(checkOperation)];
        
        
        dispatch_block_t block = ^{
            [self checkOperation];
        };
        
        [self.imageView setTapBlock:block];
        
        weak();
        
        [self.descriptionField setLinkCallback:^(NSString *link) {
            strongWeak();
            
            if(strongSelf != nil) {
                TGWebpageDocumentObject *webpage = (TGWebpageDocumentObject *) strongSelf.webpage;
                
                if(webpage.isset) {
                    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:strongSelf.webpage.webpage.document.path_with_cache]]];
                } else {
                    block();
                }
            }
            
            
        }];
    }
    
    return self;
}



-(void)checkOperation {
    TGWebpageDocumentObject *webpage = (TGWebpageDocumentObject *) self.webpage;
    
    if(webpage.isset) {
        PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:webpage.fakeMessage.n_id media:webpage.fakeMessage peer_id:self.item.message.peer_id];
        
        TMPreviewDocumentItem *item = [[TMPreviewDocumentItem alloc] initWithItem:previewObject];
        [[TMMediaController controller] show:item];
    } else {
        [webpage startDownload:YES force:YES];
        [self updateDownloadState];
    }
}



-(void)setWebpage:(TGWebpageObject *)webpage {
    [super setWebpage:webpage];
    
    
    [self.siteName setHidden:YES];
    [self.author setHidden:YES];
    
    [self.imageView setFrameOrigin:NSMakePoint(self.textX, 0)];
    [self.imageView setFrameSize:attach_downloaded_background().size];
    self.imageView.image = blue_circle_background_image();
    
    [self.descriptionField setAttributedString:webpage.desc];
    [self.descriptionField setFrameSize:webpage.descSize];
    [self.descriptionField setFrameOrigin:NSMakePoint(self.textX + self.imageView.image.size.width + self.item.defaultOffset, 0)];
    
    [self.descriptionField setCenteredYByView:self.descriptionField.superview];
    
    [self updateDownloadState];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)updateState:(TMLoaderViewState)state {
    
    
    
}

-(void)updateDownloadState {
    
    
    TGWebpageDocumentObject *webpage = (TGWebpageDocumentObject *) self.webpage;
    if(webpage.downloadItem && (webpage.downloadItem.downloadState != DownloadStateWaitingStart && webpage.downloadItem.downloadState != DownloadStateCompleted)) {
        [_loaderView setState:webpage.downloadItem.downloadState == DownloadStateCanceled ? TMLoaderViewStateNeedDownload : TMLoaderViewStateDownloading];
    } else {
        [_loaderView setHidden:webpage.isset];
        
        if(webpage.isset) {
            [_loaderView setProgress:0 animated:NO];
            self.imageView.image = attach_downloaded_background();
        } else {
            [_loaderView setState:TMLoaderViewStateNeedDownload];
        }
        
    }
    
     [self.descriptionField setAttributedString:webpage.desc];
    
    weak();
    

    
    if(webpage.downloadItem) {
        [_loaderView setProgress:webpage.downloadItem.progress animated:NO];
        
        [webpage.downloadItem removeEvent:self.downloadEventListener];
        
        [_downloadEventListener clear];
        
        _downloadEventListener = [[DownloadEventListener alloc] init];
        
        [webpage.downloadItem addEvent:_downloadEventListener];
        
        [_downloadEventListener setCompleteHandler:^(DownloadItem * item) {
            
            __strong TGWebpageDocumentContainer *strongSelf = weakSelf;
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                if(strongSelf != nil) {
                   dispatch_after_seconds(0.2, ^{
                         [strongSelf updateDownloadState];
                    });
                }
                
                
            }];
            
        }];
        
        [_downloadEventListener setProgressHandler:^(DownloadItem * item) {
            __strong TGWebpageDocumentContainer *strongSelf = weakSelf;
            [ASQueue dispatchOnMainQueue:^{
                if(strongSelf != nil) {
                    [strongSelf.loaderView setProgress:webpage.downloadItem.progress animated:YES];
                }
                
            }];
        }];
        
    }
    
}


@end
