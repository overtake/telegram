//
//  TGCirclularCounter.m
//  Telegram
//
//  Created by keepcoder on 12/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGCirclularCounter.h"
#import "POPLayerExtras.h"
#import "SpacemanBlocks.h"
@interface TGCirclularCounter () {
    SMDelayedBlockHandle handle;
}
@property (nonatomic,strong) CALayer *circluarLayer;
@property (nonatomic,strong) TMTextField *textLayer;
@end

@implementation TGCirclularCounter


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _circluarLayer = [CALayer layer];
        _textLayer = [TMTextField defaultTextField];
        _stringValue = @"0";
        _textLayer.font = _textFont = TGSystemFont(15);
        _textLayer.textColor = _textColor = [NSColor whiteColor];
        _animated = YES;
        
        [self updateWithoutAnimation];
        
        self.backgroundColor = BLUE_UI_COLOR;
        self.wantsLayer = YES;
        
        [self.layer addSublayer:_circluarLayer];
        [self addSubview:_textLayer];
    }
    
    return self;
}

-(void)setStringValue:(NSString *)stringValue {
    _stringValue = stringValue;
    
    if(_animated) {
        [self updateWithAnimation];
    } else {
        [self updateWithoutAnimation];
    }
}

-(void)setTextColor:(NSColor *)textColor {
    _textColor = textColor;
    _textLayer.textColor = textColor;
    [self updateWithoutAnimation];
}

-(void)setTextFont:(NSFont *)textFont {
    _textFont = textFont;
    _textLayer.font = textFont;
    [self updateWithoutAnimation];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    _circluarLayer.cornerRadius = roundf(newSize.width/2);
}

-(void)setBackgroundColor:(NSColor *)backgroundColor {
    _circluarLayer.backgroundColor = backgroundColor.CGColor;
}

-(void)updateWithoutAnimation {
    [_textLayer setStringValue:self.stringValue];
    [_textLayer sizeToFit];
    
    
    
    int max = MAX(NSWidth(_textLayer.frame),NSHeight(_textLayer.frame));
    
    int add = max % 2 == 0 ? 6 : 7;
    
    [_circluarLayer setFrameSize:NSMakeSize(max + add, max + add)];
    _circluarLayer.cornerRadius = roundf(NSWidth(_circluarLayer.frame)/2);
    
    [_circluarLayer setFrameOrigin:NSMakePoint(roundf((NSWidth(self.frame) - NSWidth(_circluarLayer.frame))/2), roundf((NSHeight(self.frame) - NSHeight(_circluarLayer.frame))/2))];
    
    [_textLayer setFrameOrigin:NSMakePoint(roundf((NSWidth(self.frame) - NSWidth(_textLayer.frame))/2), roundf((NSHeight(self.frame) - NSHeight(_textLayer.frame))/2))];
}


-(void)updateWithAnimation {
    
    [_circluarLayer pop_removeAllAnimations];
    
    POPLayerSetScaleXY(_circluarLayer, CGPointMake(1.2, 1.2));
    
    handle = perform_block_after_delay(0.2, ^{
        POPLayerSetScaleXY(_circluarLayer, CGPointMake(1.0, 1.0));
        handle = nil;
        [self updateWithoutAnimation];
    });
    
}


-(void)drawRect:(NSRect)dirtyRect {
    
}

@end
