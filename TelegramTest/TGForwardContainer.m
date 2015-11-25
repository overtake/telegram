//
//  TGForwardContainer.m
//  Telegram
//
//  Created by keepcoder on 17.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGForwardContainer.h"


@interface TGForwardContainer ()

@property (nonatomic,strong) TMTextField *namesField;
@property (nonatomic,strong) TMTextField *descriptionField;
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
        
        self.descriptionField = [TMTextField defaultTextField];
        self.namesField = [TMTextField defaultTextField];
        
        
        [self.descriptionField setStringValue:@"test"];
        
        
        [self.namesField setStringValue:@"super test"];
        
        
        [self.namesField setFrame:NSMakeRect(5, NSHeight(frameRect) - 13, NSWidth(frameRect), 20)];
        
        [self.descriptionField setFrame:NSMakeRect(5, 0, NSWidth(frameRect), 17)];
        
        [self addSubview:self.descriptionField];
        [self addSubview:self.namesField];
        
        
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
    
    [self updateLayout];
}


-(void)updateLayout {
    
    [self.descriptionField setAttributedStringValue:_fwdObject.fwd_desc];
    [self.namesField setAttributedStringValue:_fwdObject.names];
    
    [self setNeedsDisplay:YES];
}


@end
