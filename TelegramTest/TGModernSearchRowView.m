//
//  TGModernSearchRowView.m
//  Telegram
//
//  Created by keepcoder on 07/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernSearchRowView.h"
#import "TGModernSearchItem.h"
@interface TGModernSearchRowView ()
@property (nonatomic, strong) TMNameTextField *titleTextField;
@property (nonatomic, strong) TMStatusTextField *statusTextField;
@property (nonatomic, strong) TMAvatarImageView *photoImageView;
@end

@implementation TGModernSearchRowView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        
        _titleTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(68, 33, 200, 20)];
        
        [self addSubview:_titleTextField];
        
        _statusTextField = [[TMStatusTextField alloc] initWithFrame:NSMakeRect(68, 14, 200, 20)];
        [_statusTextField setSelector:@selector(statusForSearchTableView)];

        [self addSubview:_statusTextField];
        
         _photoImageView = [TMAvatarImageView standartTableAvatar];
        [self addSubview:_photoImageView];
    }
    
    return self;
}

-(void)redrawRow {
    [super redrawRow];
    
    TGModernSearchItem *item = (TGModernSearchItem *)self.rowItem;
    
    [_titleTextField updateWithConversation:item.conversation];
    [_statusTextField updateWithConversation:item.conversation];
    [_photoImageView updateWithConversation:item.conversation];
    
    [_titleTextField setSelected:self.isSelected];
    [_statusTextField setSelected:self.isSelected];
    
    [_titleTextField sizeToFit];
    
    if(item.status != nil) {
        [_statusTextField updateWithConversation:nil];
        [_statusTextField setAttributedString:item.status];
    }
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_statusTextField setFrameSize:NSMakeSize(NSWidth(self.bounds) - NSMaxX(_photoImageView.frame) - 20, NSHeight(_statusTextField.frame))];
    [_titleTextField setFrameSize:NSMakeSize(MIN(NSWidth(self.bounds) - NSMaxX(_photoImageView.frame) - 20,NSWidth(_titleTextField.frame)), NSHeight(_titleTextField.frame))];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    if(self.isSelected) {
        [BLUE_COLOR_SELECT set];
        NSRectFill(self.bounds);
    } else {
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(68, 0, self.bounds.size.width - DIALOG_BORDER_WIDTH - 68, 1));
        
    }
    
    TGModernSearchItem *item = (TGModernSearchItem *)self.rowItem;

    if(item.conversation.isVerified) {
        [self.isSelected ? image_VerifyWhite() : image_Verify() drawInRect:NSMakeRect(NSMaxX(self.titleTextField.frame),NSMinY(self.titleTextField.frame) , image_Verify().size.width, image_Verify().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
    }
    
}

@end
