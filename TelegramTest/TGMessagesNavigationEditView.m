//
//  TGMessagesNavigationEditView.m
//  Telegram
//
//  Created by keepcoder on 28/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGMessagesNavigationEditView.h"
#import "TGContextMessagesvViewController.h"
@interface TGMessagesNavigationEditView ()
@property (nonatomic,strong) TMTextButton *editView;
@property (nonatomic,strong) BTRButton *searchButton;
@end

@implementation TGMessagesNavigationEditView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.editView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];
        
        weak();
        
        [self.editView setTapBlock:^{
            [weakSelf.controller setCellsEditButtonShow:YES animated:YES];
        }];
        [self.editView setDisableColor:NSColorFromRGB(0xa0a0a0)];
        
        [self addSubview:_editView];
        
        
        
        _searchButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_SearchMessages().size.width +10, image_SearchMessages().size.height+10)];
        
        [_searchButton addBlock:^(BTRControlEvents events) {
            
            if(![weakSelf.controller searchBoxIsVisible]) {
                [weakSelf.controller showSearchBox];
            }
            
        } forControlEvents:BTRControlEventClick];
        
        [_searchButton setImage:image_SearchMessages() forControlState:BTRControlStateNormal];
        
        [_searchButton setToolTip:@"CMD + F"];
        
        
        
        [self addSubview:_searchButton];
        
        [self setFrameSize:NSMakeSize(NSWidth(_searchButton.frame) + NSWidth(_editView.frame) + 20, MAX(NSHeight(_editView.frame),NSHeight(_searchButton.frame)))];
        [_editView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_editView.frame), 0)];
        
        [_editView setCenteredYByView:self];
    }
    
    return self;
}

-(void)setController:(MessagesViewController *)controller {
    _controller = controller;
    [_searchButton setHidden:controller.class == [TGContextMessagesvViewController class]];
    
    if(!_searchButton.isHidden)
        [self setFrameSize:NSMakeSize(NSWidth(_searchButton.frame) + NSWidth(_editView.frame) + 20, MAX(NSHeight(_editView.frame),NSHeight(_searchButton.frame)))];
    else
        [self setFrameSize:NSMakeSize(NSWidth(_editView.frame), NSHeight(_editView.frame))];
    
    [_editView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_editView.frame), 0)];
    [_editView setCenteredYByView:self];

}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
