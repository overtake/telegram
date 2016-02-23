//
//  TGModernMessageCellContainerView.m
//  Telegram
//
//  Created by keepcoder on 21/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernMessageCellContainerView.h"
#import "TGModernForwardCellContainer.h"

@interface TGModernMessageCellContainerView ()

@property (nonatomic,strong) TMAvatarImageView *photoView;
@property (nonatomic,strong) TMTextField *nameView;
@property (nonatomic,strong) TMView *rightView;
@property (nonatomic,strong) TMView *contentView;

//containers

@property (nonatomic,strong) TMView *contentContainerView;
@property (nonatomic,strong) TGModernForwardCellContainer *forwardContainerView;

@end

@implementation TGModernMessageCellContainerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(BOOL)isFlipped {
    return YES;
}

static const int defaultContentOffset = 6;
static const int defaultOffset = 10;

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.wantsLayer = YES;

        
        //tests main container
        {
            _photoView = [TMAvatarImageView standartMessageTableAvatar];
            _nameView = [TMHyperlinkTextField defaultTextField];
            
            
            _nameView.drawsBackground = YES;
            _nameView.backgroundColor = [NSColor blackColor];
            
            
            [_photoView setFrameOrigin:NSMakePoint(defaultOffset, defaultContentOffset)];
            
            [_nameView setFrameOrigin:NSMakePoint(NSMaxX(_photoView.frame) + defaultOffset, 0)];
            
            [self addSubview:_photoView];
            [self addSubview:_nameView];
        }
        
        
        //container
        {
            _contentContainerView = [[TMView alloc] initWithFrame:NSZeroRect];
            _contentContainerView.backgroundColor = [NSColor redColor];
            _contentContainerView.isFlipped = YES;
            
            _contentView = [[TMView alloc] initWithFrame:NSZeroRect];
            _contentView.backgroundColor = [NSColor yellowColor];
            
            [_contentContainerView addSubview:_contentView];
            [self addSubview:_contentContainerView];
        }
        
    }
    return self;
}

-(void)chekAndMakeForwardContainer:(MessageTableItem *)item {
    
    
    if(item.isForwadedMessage) {
        
        if(!_forwardContainerView) {
            _forwardContainerView = [[TGModernForwardCellContainer alloc] initWithFrame:NSZeroRect];
            _forwardContainerView.backgroundColor = [NSColor whiteColor];
            [_contentContainerView addSubview:_forwardContainerView];
            [_contentView removeFromSuperview];
            [_forwardContainerView addSubview:_contentView];
        }
        
        [_forwardContainerView setFrameSize:_contentContainerView.frame.size];
        
        [_forwardContainerView setTableItem:item contentView:_contentView containerView:self];
        
        
    } else {
        if(_forwardContainerView) {
            [_forwardContainerView removeFromSuperview];
            [_contentView removeFromSuperview];
            [_contentContainerView addSubview:_contentView];
            _forwardContainerView = nil;
        }
    }
    
    
    
}


-(void)setItem:(MessageTableItem *)item {
    [super setItem:item];
    
    [_photoView setUser:item.user];
    
    [_nameView setFrameSize:item.headerSize];
    [_nameView setAttributedString:item.headerName];
    
    // update;
    
    self.layer.backgroundColor = item.rowId % 2 == 0 ? [NSColor blueColor].CGColor : [NSColor greenColor].CGColor;
    
    [_contentContainerView setFrame:NSMakeRect(NSMinX(_nameView.frame),NSMaxY(_nameView.frame) + defaultContentOffset, item.blockSize.width, item.viewSize.height - NSMaxY(_nameView.frame) - defaultContentOffset)];
    
    [_contentView setFrame:NSMakeRect(0, 0, item.blockSize.width, item.blockSize.height)];
    
    
    [self chekAndMakeForwardContainer:item];
}


-(int)defaultContentOffset {
    return defaultContentOffset;
}

-(int)defaultOffset {
    return defaultOffset;
}

-(TMView *)containerView {
    return _contentView;
}


@end
