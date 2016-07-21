//
//  TGGifPreviewModalView.m
//  Telegram
//
//  Created by keepcoder on 09/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGGifPreviewModalView.h"
#import "TGVTVideoView.h"
@interface TGGifPreviewModalView ()
@property (nonatomic,strong) TGVTVideoView *player;
@end

@implementation TGGifPreviewModalView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _player = [[TGVTVideoView alloc] initWithFrame:NSMakeRect(0, 0, 500, 280)];
        
        [self addSubview:_player];

    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(NSSize)size {
    
    TL_documentAttributeVideo *vAttr = (TL_documentAttributeVideo *)[_gif.message.media.document attributeWithClass:[TL_documentAttributeVideo class]];
    
    NSSize max = NSMakeSize(vAttr.w, vAttr.h);
    
    return strongsize(max, MIN(NSWidth(appWindow().frame),NSHeight(appWindow().frame)) - 40);
    
}

-(void)setGif:(MessageTableItem *)gif {
    _gif = gif;
    
    [self setContainerFrameSize:self.size];
    
    [_player setFrameSize:self.size];
    [_player setPath:gif.path];
}

-(void)modalViewDidHide {
    [_player setPath:nil];
    _gif = nil;
}

@end
