//
//  TGBottomMessageActionsView.m
//  Telegram
//
//  Created by keepcoder on 19/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomMessageActionsView.h"
#import "TMTextButton.h"
#import "TGTextLabel.h"
@interface TGBottomMessageActionsView ()
@property (nonatomic,strong) TMTextButton *deleteView;
@property (nonatomic,strong) TMTextButton *forwardView;

@property (nonatomic,strong) TGTextLabel *countLabel;
@end

@implementation TGBottomMessageActionsView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController {
    if(self = [super initWithFrame:frameRect]) {
        
        self.backgroundColor = [NSColor whiteColor];
        
        _deleteView = [TMTextButton standartButtonWithTitle:NSLocalizedString(@"Messages.Selected.Delete", nil) standartImage:image_MessageActionDeleteActive() disabledImage:image_MessageActionDelete()];
        
        [_deleteView setAutoresizingMask:NSViewMaxXMargin ];
        [_deleteView setTapBlock:^{
            [messagesController deleteSelectedMessages];
        }];
        _deleteView.disableColor = NSColorFromRGB(0xa1a1a1);
        [self addSubview:_deleteView];
        
        
        _countLabel = [[TGTextLabel alloc] init];
        [_countLabel setTruncateInTheMiddle:YES];
        
        [self addSubview:_countLabel];
        
        _forwardView = [TMTextButton standartButtonWithTitle:NSLocalizedString(@"Messages.Selected.Forward", nil) standartImage:image_MessageActionForwardActive() disabledImage:image_MessageActionForward()];
        
        [_forwardView setAutoresizingMask:NSViewMinXMargin];
        _forwardView.disableColor = NSColorFromRGB(0xa1a1a1);
        
        
        [_forwardView setTapBlock:^{
            [messagesController showForwardMessagesModalView];
        }];

        
        
        [self addSubview:_forwardView];
        
        [self setFrameSize:frameRect.size];

    }
    
    return self;
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

- (void)setSectedMessagesCount:(NSUInteger)count deleteEnable:(BOOL)deleteEnable forwardEnable:(BOOL)forwardEnable {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    [attr appendString:[NSString stringWithFormat:NSLocalizedString(count == 1 ? @"Edit.selectMessage" : @"Edit.selectMessages", nil), count] withColor:TEXT_COLOR];
    [attr setFont:TGSystemFont(14) forRange:attr.range];
        
    [_countLabel setText:attr maxWidth:NSWidth(self.frame) - NSWidth(_forwardView.frame) - NSWidth(_deleteView.frame) - 40];
    
    [_countLabel setCenterByView:self];
    
    [_forwardView setDisable:count < 1 || !forwardEnable];
    [_deleteView setDisable:count < 1 || !deleteEnable];
    
    if(count > 0)
        [_countLabel performCAShow:YES];
    else
        [_countLabel.layer setOpacity:0.0f];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_countLabel setText:_countLabel.text maxWidth:NSWidth(self.frame) - NSWidth(_forwardView.frame) - NSWidth(_deleteView.frame) - 40];
    [_forwardView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_forwardView.frame) - 22, roundf((NSHeight(self.frame) - NSHeight(_forwardView.frame)) / 2))];
    [_deleteView setFrameOrigin:NSMakePoint(22, roundf((NSHeight(self.frame) - NSHeight(_deleteView.frame)) / 2) )];
    [_countLabel setCenterByView:self];

}

@end
