//
//  TGContextRowView.m
//  Telegram
//
//  Created by keepcoder on 23/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGContextRowView.h"
#import "TGImageView.h"
#import "TGCTextView.h"
#import "TGTextLabel.h"
#import "TMLoaderView.h"
#import "TMMediaController.h"
#import "TMPreviewDocumentItem.h"
#import "TGPhotoViewer.h"
#import "TGAudioController.h"
@interface TGContextRowView () <TGAudioControllerDelegate>
@property (nonatomic, strong) TGImageView *imageView;
@property (nonatomic, strong) TMTextField *textField;
@property (nonatomic, strong) TMTextField *domainSymbolView;
@property (nonatomic, strong) TMLoaderView *loaderView;
@property (nonatomic,strong) BTRButton *contentAssociationImageView;
@property (nonatomic,strong) TGAudioController *audioController;
@end

@implementation TGContextRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
   if(self.isSelected) {
        
        [BLUE_COLOR_SELECT set];
        
        NSRectFill(NSMakeRect(0, 0, NSWidth(dirtyRect) , NSHeight(dirtyRect)));
       
       
    } else {
        
        TMTableView *table = self.item.table;
        
        [DIALOG_BORDER_COLOR set];
        
        if([table indexOfItem:self.item] != table.count - 1) {
            NSRectFill(NSMakeRect(self.xTextOffset, 0, NSWidth(dirtyRect) - self.xTextOffset, DIALOG_BORDER_WIDTH));
        }
    }
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(10, 5, 50, 50)];
        _imageView.cornerRadius = 4;
        [self addSubview:_imageView];
        
        _textField = [TMTextField defaultTextField];
        [[_textField cell] setTruncatesLastVisibleLine:YES];
        
        [self addSubview:_textField];
        
        _domainSymbolView = [TMTextField defaultTextField];
        [_domainSymbolView setFont:TGSystemFont(18)];
        [_domainSymbolView setFrameSize:NSMakeSize(15, 22)];
        [_domainSymbolView setTextColor:[NSColor whiteColor]];
        [_imageView addSubview:_domainSymbolView];
        
        _contentAssociationImageView = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        [_contentAssociationImageView setUserInteractionEnabled:NO];

        [_imageView addSubview:_contentAssociationImageView];
        [_contentAssociationImageView setCenterByView:_imageView];
        
        
        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        
        [_loaderView setHidden:YES];
        
        [_loaderView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [_loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [_loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        [_loaderView setStyle:TMCircularProgressDarkStyle];
        
        [_imageView addSubview:_loaderView];
        [_loaderView setCenterByView:_loaderView.superview];
        
        
    }
    
    return self;
}

-(void)checkOperation {
    
    if([self.item.botResult.send_message isKindOfClass:[TL_botInlineMessageMediaAuto class]]) {
        if(!self.item.isset) {
            [self.item startDownload:!self.item.isset];
        } else {
            [self open];
        }
        
        [self updateDownloadState];
    }
    
}

-(void)audioControllerUpdateProgress:(int)progress {
    [self.loaderView setProgress:progress animated:YES];
}
-(void)audioControllerSetNeedDisplay {
    
    switch (self.item.audioController.state) {
        case AudioStatePlaying:
            [self.loaderView setState:TMLoaderViewStateDownloading];
            break;
        case AudioStatePaused:
            [self.loaderView setState:TMLoaderViewStateUploading];
            break;
        case AudioStateWaitPlaying:
            [self updateDownloadState];
            break;
        default:
            break;
    }
    
}


-(void)open {
    if(self.item.isset) {
        if([self.item.botResult.type isEqualToString:kBotInlineTypeVideo]) {
            
            PreviewObject *previewObject;
            
            if(self.item.botResult.document) {
                previewObject = [[PreviewObject alloc] initWithMsdId:self.item.fakeMessage.n_id media:self.item.fakeMessage peer_id:self.item.fakeMessage.peer_id];
            } else {
                previewObject = [[PreviewObject alloc] initWithMsdId:rand_long() media:self.item.fakeMessage peer_id:0];
                
                
                NSURL *url = [NSURL fileURLWithPath:self.item.path];
                
                NSSize videoSize = NSMakeSize(self.item.botResult.w, self.item.botResult.h);
                videoSize.width = videoSize.width == 0 ? 640 : videoSize.width;
                videoSize.height = videoSize.height == 0 ? 480 : videoSize.height;
                
                previewObject.reservedObject = @{@"url":url,@"size":[NSValue valueWithSize:videoSize]};
                
            }
            
            
            if(previewObject) {
                [[TGPhotoViewer viewer] show:previewObject];
            }
            
            
        } else if([self.item.botResult.type isEqualToString:kBotInlineTypeAudio] || [self.item.botResult.type isEqualToString:kBotInlineTypeVoice]) {
            [self.item.audioController playOrPause];
        }
        
    }
    
    [self updateDownloadState];
    
}



-(void)openInQuickLook:(id)sender {
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.fakeMessage.n_id media:self.item.fakeMessage peer_id:self.item.fakeMessage.peer_id];
    
    TMPreviewDocumentItem *item = [[TMPreviewDocumentItem alloc] initWithItem:previewObject];
    [[TMMediaController controller] show:item];
}


-(void)updateDownloadState {
    
    weak();
    
    
    
    if(self.item.audioController && self.item.isset) {
        [_loaderView setImage:voice_play_image() forState:TMLoaderViewStateNeedDownload];
        [_loaderView setImage:image_VoicePause() forState:TMLoaderViewStateDownloading];
        [_loaderView setImage:voice_play_image() forState:TMLoaderViewStateUploading];
    } else {
        [_loaderView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [_loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [_loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
    }
    
    
    
    if(self.item.audioController && self.item.isset) {
        [_loaderView setProgress:self.item.audioController.progress animated:NO];
    }
    
    [_loaderView setDisableRotating:self.item.downloadItem == nil];
    
    [_loaderView setHidden:self.item.downloadItem == nil && (!self.item.audioController || self.item.audioController.state == AudioStateWaitPlaying) animated:NO];
    [_contentAssociationImageView setImage:!_loaderView.isHidden ? nil : [self contentAssociationImage:self.item] forControlState:BTRControlStateNormal];
    
    if(self.item.downloadItem) {
    
        [_loaderView setProgress:self.item.downloadItem.progress animated:NO];
        
        [self.item.downloadEventListener setCompleteHandler:^(DownloadItem * item) {
            
            __strong TGContextRowView *strongSelf = weakSelf;
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                [strongSelf.loaderView setProgress:item.progress animated:YES];
                
                dispatch_after_seconds(0.2, ^{
                    [strongSelf redrawRow];
                    if(NSSizeNotZero(self.visibleRect.size) && self.window.isKeyWindow) {
                        [strongSelf open];
                    }
                });
            }];
            
        }];
        
        [self.item.downloadEventListener setProgressHandler:^(DownloadItem * item) {
            
            __strong TGContextRowView *strongSelf = weakSelf;
            
            [ASQueue dispatchOnMainQueue:^{
                [strongSelf.loaderView setProgress:item.progress animated:YES];
            }];
        }];
    }
    
    [self updateCellState];

}

- (void)updateCellState {
    
    TGContextRowItem *item = self.item;
    
    if(item.downloadItem) {
        if(item.downloadItem && (item.downloadItem.downloadState != DownloadStateWaitingStart && item.downloadItem.downloadState != DownloadStateCompleted)) {
            [self.loaderView setState:item.downloadItem.downloadState == DownloadStateCanceled ? TMLoaderViewStateNeedDownload : TMLoaderViewStateDownloading];
        }  else if(![self.item isset]) {
            [self.loaderView setState:TMLoaderViewStateNeedDownload];
        } else {
            [self.loaderView setState:0];
        }
    }
    
    
}


-(int)xTextOffset  {
    return 70;
}



-(TGContextRowItem *)item {
    return (TGContextRowItem *)[self rowItem];
}

-(void)redrawRow {
    [super redrawRow];
    
    self.item.audioController.delegate = self;
    
    [_loaderView setStyle:[self.item.botResult.type isEqualToString:kBotInlineTypeVoice] || [self.item.botResult.type isEqualToString:kBotInlineTypeAudio] ? TMCircularProgressLightStyle : TMCircularProgressDarkStyle];
    
    
    [_imageView setObject:self.item.imageObject];
    
    if(_imageView.object == nil)
    {
        [_imageView setImage:gray_resizable_placeholder()];
    }
    
    [_textField setFrame:NSMakeRect(self.xTextOffset, 0, NSWidth(self.frame) - self.xTextOffset, self.item.descSize.height)];
    
    [_textField setCenteredYByView:_textField.superview];
    
    [self.item.desc setSelected:self.isSelected];
    
    [_textField setAttributedStringValue:self.item.desc];
    
    [_domainSymbolView setStringValue:self.item.domainSymbol];
    [_domainSymbolView setCenterByView:_imageView];
    [_domainSymbolView setHidden:self.item.imageObject != nil];
    
    NSImage *backImage = [self contentAssociationImage:self.item];
    
    [_contentAssociationImageView setImage:backImage forControlState:BTRControlStateNormal];
    [_contentAssociationImageView setBackgroundImage:nil forControlState:BTRControlStateNormal];
    
    [_domainSymbolView setHidden:_domainSymbolView.isHidden || backImage];
    
    if([self.item.botResult.type isEqualToString:kBotInlineTypeVoice] || [self.item.botResult.type isEqualToString:kBotInlineTypeAudio]) {
        [_imageView setObject:nil];
        [_contentAssociationImageView setBackgroundImage:blue_circle_background_image() forControlState:BTRControlStateNormal];
    }
    
    
    [self updateDownloadState];
    
}



-(void)mouseDown:(NSEvent *)theEvent {
    
    if( ![self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_imageView.frame])
        [super mouseDown:theEvent];
    else {
         if([self.item.botResult.send_message isKindOfClass:[TL_botInlineMessageMediaAuto class]]) {
             [self checkOperation];
         } else {
            [super mouseDown:theEvent];
         }
    }
}

-(NSImage *)contentAssociationImage:(TGContextRowItem *)item {
    
    if([self.item.botResult.send_message isKindOfClass:[TL_botInlineMessageMediaAuto class]]) {
        if([item.botResult.type isEqualToString:kBotInlineTypeGeo] || [item.botResult.type isEqualToString:kBotInlineTypeVenue]) {
            return image_MessageMapPin();
        }
        
        if([item.botResult.type isEqualToString:kBotInlineTypeVideo]) {
            return video_play_image();
        }
        
        if([self.item.botResult.type isEqualToString:kBotInlineTypeVoice] || [self.item.botResult.type isEqualToString:kBotInlineTypeAudio]) {
            return voice_play_image();
        }
    }
    
    return nil;
    
}



@end
