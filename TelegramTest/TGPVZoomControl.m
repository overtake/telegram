
//
//  TGPVZoomControl.m
//  Telegram
//
//  Created by keepcoder on 07.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPVZoomControl.h"
#import "TGPhotoViewer.h"
@interface TGPVZoomControl ()
@property (nonatomic,strong) BTRButton *increaseZoomButton;
@property (nonatomic,strong) BTRButton *decreaseZoomButton;
@end

@implementation TGPVZoomControl

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.6);
        self.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        
        self.wantsLayer = YES;
        self.layer.cornerRadius = 8;
        
        
        _increaseZoomButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(frameRect)/2, 0, NSWidth(frameRect)/2, NSHeight(frameRect))];
        [_increaseZoomButton setImage:image_ZoomIn() forControlState:BTRControlStateNormal];
        
        [_increaseZoomButton addBlock:^(BTRControlEvents events) {
            
            [TGPhotoViewer increaseZoom];
            
        } forControlEvents:BTRControlEventClick];
        
        
        
        _decreaseZoomButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect)/2, NSHeight(frameRect))];
        [_decreaseZoomButton setImage:image_ZoomOut() forControlState:BTRControlStateNormal];
        
        [_decreaseZoomButton addBlock:^(BTRControlEvents events) {
            
            [TGPhotoViewer decreaseZoom];
            
        } forControlEvents:BTRControlEventClick];
        
        
        weak();
        
        [_increaseZoomButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf.decreaseZoomButton setAlphaValue:0.7];
            [weakSelf.increaseZoomButton setAlphaValue:1.0];
            
        } forControlEvents:BTRControlEventMouseEntered];
        
        [_increaseZoomButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf.decreaseZoomButton setAlphaValue:0.7];
            [weakSelf.increaseZoomButton setAlphaValue:0.7];
            
        } forControlEvents:BTRControlEventMouseExited];
        
        
        [_decreaseZoomButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf.decreaseZoomButton setAlphaValue:1.0];
            [weakSelf.increaseZoomButton setAlphaValue:0.7];
            
        } forControlEvents:BTRControlEventMouseEntered];
        
        [_decreaseZoomButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf.decreaseZoomButton setAlphaValue:0.7];
            [weakSelf.increaseZoomButton setAlphaValue:0.7];
            
        } forControlEvents:BTRControlEventMouseExited];

        
        
        [self addSubview:_increaseZoomButton];
        [self addSubview:_decreaseZoomButton];
    }
    
    return self;
}

@end
