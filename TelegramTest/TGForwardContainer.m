//
//  TGForwardContainer.m
//  Telegram
//
//  Created by keepcoder on 17.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGForwardContainer.h"
#import "TGTextLabel.h"

@interface TGForwardContainer ()

@property (nonatomic,strong) TGTextLabel *nameLabel;
@property (nonatomic,strong) TGTextLabel *descLabel;
@property (nonatomic,strong) NSImageView *deleteImageView;


@end

@implementation TGForwardContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [LINK_COLOR setFill];
    
    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _descLabel = [[TGTextLabel alloc] init];
        _nameLabel = [[TGTextLabel alloc] init];
        
        
        [self addSubview:_descLabel];
        [self addSubview:_nameLabel];
        
        
        _deleteImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_CancelReply().size.width , NSHeight(self.frame) - image_CancelReply().size.height , image_CancelReply().size.width , image_CancelReply().size.height)];
        
        _deleteImageView.image = image_CancelReply();
        
        weak();
        
        [_deleteImageView setCallback:^{
            
            weakSelf.deleteHandler();
            
        }];
        
        [_deleteImageView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        
        [self addSubview:_deleteImageView];
        
    }
    
    return self;
}


-(void)setFwdObject:(TGForwardObject *)fwdObject {
    _fwdObject = fwdObject;
    [self setFrameSize:self.frame.size];
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_nameLabel setText:_fwdObject.names maxWidth:NSWidth(self.frame) - image_CancelReply().size.width - 15];
    [_nameLabel setFrameOrigin:NSMakePoint(9, NSHeight(self.frame) - NSHeight(_nameLabel.frame))];
    
    [_descLabel setText:_fwdObject.fwd_desc maxWidth:NSWidth(self.frame) - image_CancelReply().size.width - 15];
    [_descLabel setFrameOrigin:NSMakePoint(9, 0)];
}




@end
