//
//  TGFeaturedStickerPackRowView.m
//  Telegram
//
//  Created by keepcoder on 24/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGFeaturedStickerPackRowView.h"
#import "TGFeaturedStickerPackRowItem.h"
#import "BTRButton.h"
#import "TGModernESGViewController.h"
#import "TGStickerPackModalView.h"
@interface TGFeaturedStickerPackRowView ()
@property (nonatomic,strong) BTRButton * button;
@property (nonatomic,strong) TMView *unreadCircle;
@property (nonatomic,strong) NSProgressIndicator *progress;
@end

@implementation TGFeaturedStickerPackRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _button = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        [_button setTitleFont:TGSystemMediumFont(14) forControlState:BTRControlStateNormal];
        [_button setTitleColor:BLUE_UI_COLOR forControlState:BTRControlStateNormal];
        
        [_button setTitle:NSLocalizedString(@"Stickers.AddFeatured", nil) forControlState:BTRControlStateNormal];
        [_button.titleLabel sizeToFit];
        [_button setFrameSize:NSMakeSize(NSWidth(_button.titleLabel.frame), NSHeight(_button.frame))];
        [self addSubview:_button];
        
        
        weak();
        
        [_button addBlock:^(BTRControlEvents events) {
            
            [weakSelf performAddRequest];
            
        } forControlEvents:BTRControlEventClick];
        
        
        _unreadCircle = [[TMView alloc] initWithFrame:NSMakeRect(NSMaxX(self.imageView.frame) + 5, NSMinY(self.titleField.frame), 10, 10)];
        
        [_unreadCircle setDrawBlock:^{
           
            [BLUE_COLOR set];
            NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, 10, 10) xRadius:5 yRadius:5];
            [path fill];
            
        }];
        
        [self addSubview:_unreadCircle];
        
        _progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [_progress setStyle:NSProgressIndicatorSpinningStyle];
        
        [_progress setHidden:YES];
        
        [self addSubview:_progress];
    }
    
    return self;
}

-(void)performAddRequest {
    
    weak();
    
    [weakSelf.button setHidden:YES];
    [weakSelf.progress setHidden:NO];
    [weakSelf.progress startAnimation:weakSelf];
    
    TGFeaturedStickerPackRowItem *item = (TGFeaturedStickerPackRowItem *) weakSelf.rowItem;
    
    
    void (^complete)(BOOL success)  = ^(BOOL success) {
        
        [weakSelf.button setHidden:NO];
        [weakSelf.progress setHidden:YES];
        [weakSelf.progress stopAnimation:weakSelf];
        
        item.isAdded = success;
        
        [weakSelf redrawRow];
        [weakSelf setFrameSize:weakSelf.frame.size];
    };
    
    [TMViewController showModalProgress];
    
    [[TGModernESGViewController stickersSignal:item.set] startWithNext:^(id next) {
        
        [[MessageSender addStickerPack:[TL_messages_stickerSet createWithSet:item.set packs:nil documents:next]] startWithNext:^(id next) {
            
            complete([next boolValue]);
            
        }];
        
    }];
    
    
    

}

-(void)mouseDown:(NSEvent *)theEvent {
    if([self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:self.imageContainerView.frame]) {
        
        
        if(![TMViewController isModalActive])
        {
            TGFeaturedStickerPackRowItem *item = (TGFeaturedStickerPackRowItem *) self.rowItem;
            
            TGStickerPackModalView *modalView = [[TGStickerPackModalView alloc] init];
            
            
            weak();
            
            [modalView setAddcallback:^{
                
                
                [weakSelf performAddRequest];
                
            }];

            
            [[TGModernESGViewController stickersSignal:item.set] startWithNext:^(id next) {
                [modalView show:self.window animated:YES stickerPack:[TL_messages_stickerSet createWithSet:item.set packs:nil documents:next] messagesController:appWindow().navigationController.messagesViewController];
            }];
            
            
        }
        
        
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    TGFeaturedStickerPackRowItem *item = (TGFeaturedStickerPackRowItem *) self.rowItem;

    
    [_button setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_button.frame) - item.xOffset, NSMinY(_button.frame))];
    [_button setCenteredYByView:self];
    
    [_unreadCircle setFrameOrigin:NSMakePoint(NSMinX(self.titleField.frame) , NSMaxY(self.imageView.frame) - 8)];
    [_progress setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_progress.frame) - item.xOffset, NSMinY(_progress.frame))];
    [_progress setCenteredYByView:self];
}


-(void)redrawRow {
    [super redrawRow];
    
    TGFeaturedStickerPackRowItem *item = (TGFeaturedStickerPackRowItem *) self.rowItem;
    
    [_unreadCircle setHidden:!item.isUnread];
    
    if(item.isAdded) {
        [_button setImage:image_UsernameCheck() forControlState:BTRControlStateNormal];
        [_button setTitle:@"" forControlState:BTRControlStateNormal];
    } else {
        [_button setImage:nil forControlState:BTRControlStateNormal];
        [_button setTitle:NSLocalizedString(@"Stickers.AddFeatured", nil) forControlState:BTRControlStateNormal];
    }
    
    

}

@end
