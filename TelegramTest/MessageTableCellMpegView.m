//
//  MessageTableCellMpegView.m
//  Telegram
//
//  Created by keepcoder on 10/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "MessageTableCellMpegView.h"
#import "TGVTAcceleratedVideoView.h"
#import "MessageTableItemMpeg.h"
#import "VideoView.h"
@interface MessageTableCellMpegView ()
@property (nonatomic,strong) TGVTAcceleratedVideoView *player;
@end

@implementation MessageTableCellMpegView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _player = [[TGVTAcceleratedVideoView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
        
        
        
        
        [self.containerView addSubview:_player];
        
        

    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(void)setItem:(MessageTableItemMpeg *)item {
    [super setItem:item];
    
    [_player setPath:item.path];
    [_player prepareForRecycle];
    
    [_player setFrameSize:item.blockSize];
    
}


@end
