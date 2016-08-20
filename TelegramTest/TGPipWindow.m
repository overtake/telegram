//
//  TGPipWindow.m
//  Telegram
//
//  Created by keepcoder on 18/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGPipWindow.h"
#import "BTRButton.h"
#import "TGPhotoViewerItem.h"
#import "TGPhotoViewer.h"
@interface TGPipWindow ()
@property (nonatomic,strong) BTRButton *closeView;
@property (nonatomic,strong) BTRButton *exitPipView;
@property (nonatomic,strong) BTRControl *overlay;

@property (nonatomic,weak) AVPlayerView *player;
@property (nonatomic,strong) PreviewObject *previewObject;
@property (nonatomic,assign) NSRect originalRect;
@property (nonatomic,strong) TL_conversation *conversation;
@end

@implementation TGPipWindow

static TGPipWindow *sWindow;

-(id)initWithPlayer:(AVPlayerView *)player origin:(NSPoint)origin currentItem:(TGPhotoViewerItem *)item {
    if(self = [super initWithContentRect:NSMakeRect(origin.x, origin.y, NSWidth(player.frame), NSHeight(player.frame)) styleMask:NSClosableWindowMask | NSBorderlessWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:YES]) {
        
        
        _originalRect = NSMakeRect(origin.x, origin.y, NSWidth(player.frame), NSHeight(player.frame));
        
        _previewObject = item.previewObject;
        _previewObject.reservedObject2 = player;
        if([_previewObject.media isKindOfClass:[TL_localMessage class]]) {
            _conversation = [[DialogsManager sharedManager] find:_previewObject.peerId];
        }
        
        self.contentView.wantsLayer = YES;
        self.contentView.layer.cornerRadius = 4;
        
        _player = player;
        
        self.contentView.layer.backgroundColor = [NSColor clearColor].CGColor;
        self.backgroundColor = [NSColor clearColor];
        
        player.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        [player setFrameOrigin:NSMakePoint(0, 0)];
        [player setControlsStyle:AVPlayerViewControlsStyleMinimal];
        [self.contentView addSubview:player];
        
        [self setLevel:NSScreenSaverWindowLevel];
        
        _closeView = [[BTRButton alloc] initWithFrame:NSMakeRect(10, NSHeight(player.frame) - 40, 30, 30)];
        [_closeView setBackgroundColor:NSColorFromRGBWithAlpha(0x000000, 0.7)];
        

        
        [_closeView setImage:[image_AudioPlayerClose() imageTintedWithColor:[NSColor whiteColor]] forControlState:BTRControlStateNormal];

        
        _exitPipView = [[BTRButton alloc] initWithFrame:NSMakeRect(NSMaxX(_closeView.frame) + 10, NSHeight(player.frame) - 40, 30, 30)];
        [_exitPipView setBackgroundColor:NSColorFromRGBWithAlpha(0x000000, 0.7)];
        
        [_exitPipView setImage:image_pip_off() forControlState:BTRControlStateNormal];
        
        _closeView.wantsLayer = _exitPipView.wantsLayer =  YES;
        _closeView.layer.cornerRadius = _exitPipView.layer.cornerRadius = NSWidth(_closeView.frame)/2.0;

        
        
        _closeView.autoresizingMask = _exitPipView.autoresizingMask = NSViewMinYMargin | NSViewMaxXMargin;
        
        _overlay = [[BTRControl alloc] initWithFrame:player.bounds];
        _overlay.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        

        weak();
        
        [_closeView addBlock:^(BTRControlEvents events) {
            
            [weakSelf.player.player pause];
            weakSelf.player.player = nil;
            
            [TGPipWindow close];
            
        } forControlEvents:BTRControlEventClick];
        
        
        [_exitPipView addBlock:^(BTRControlEvents events) {
            
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:weakSelf.previewObject.msg_id media:weakSelf.previewObject.media peer_id:weakSelf.previewObject.peerId];
            previewObject.reservedObject = weakSelf.previewObject.reservedObject;
            previewObject.reservedObject2 = weakSelf.previewObject.reservedObject2;
            
            [weakSelf.player.contentOverlayView removeAllSubviews];
            [weakSelf.player setControlsStyle:AVPlayerViewControlsStyleFloating];
            [weakSelf setAspectRatio:NSMakeSize(0, 0)];
            [weakSelf setFrame:weakSelf.originalRect display:YES animate:YES];
            
            if(weakSelf.conversation) {
                [[TGPhotoViewer viewer] show:previewObject conversation:weakSelf.conversation isReversed:YES];

            } else {
                [[TGPhotoViewer viewer] show:previewObject];
            }
            
        } forControlEvents:BTRControlEventClick];
        
        [player.contentOverlayView addSubview:_closeView];
        [player.contentOverlayView addSubview:_exitPipView];
        
        
        [[_closeView animator] setAlphaValue:0.0];
        [[_exitPipView animator] setAlphaValue:0.0];
        
        sWindow = self;

        
    }
    
    return self;
}

+(void)close {
    [sWindow orderOut:nil];
    sWindow = nil;
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
    [[_closeView animator] setAlphaValue:1.0];
    [[_exitPipView animator] setAlphaValue:1.0];
    
    [super mouseEntered:theEvent];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    [super mouseDown:theEvent];
    

}

-(void)mouseExited:(NSEvent *)theEvent {
    
    [[_closeView animator] setAlphaValue:0.0];
    [[_exitPipView animator] setAlphaValue:0.0];
    
    [super mouseExited:theEvent];
}

-(void)makeKeyAndOrderFront:(id)sender {
    [super makeKeyAndOrderFront:sender];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSScreen *screen = [NSScreen deepestScreen];
        
        NSSize convert_s = strongsize(_player.videoBounds.size, 480);

        [self setMinSize:convert_s];
        [self setAspectRatio:convert_s];
        
        [self setFrame:NSMakeRect(NSMaxX(screen.frame) - convert_s.width - 30, NSMaxY(screen.frame) - convert_s.height - 50, convert_s.width, convert_s.height) display:YES animate:YES];
    });
    
}

-(void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animateFlag {
    [super setFrame:frameRect display:displayFlag animate:animateFlag];
    
    [animateFlag ? [_closeView animator] : _closeView setFrameOrigin:NSMakePoint(10, NSHeight(frameRect) - 40)];
    [animateFlag ? [_exitPipView animator] : _exitPipView setFrameOrigin:NSMakePoint(NSMaxX(_closeView.frame) + 10, NSHeight(frameRect) - 40)];
}

- (BOOL)isMovableByWindowBackground {
    return YES;
}

-(void)dealloc {
    
}

-(void)close {
    sWindow = nil;
}


@end
