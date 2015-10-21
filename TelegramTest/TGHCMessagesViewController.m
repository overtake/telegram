//
//  TGHCMessagesViewController.m
//  Telegram
//
//  Created by keepcoder on 19.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGHCMessagesViewController.h"

@interface TGHCMessagesViewController ()
@property (nonatomic,strong) TMTextButton *pinButton;
@property (nonatomic,strong) TMView *container;
@property (nonatomic,strong) NSImageView *imageView;
@end

@implementation TGHCMessagesViewController

-(void)loadView {
    [super loadView];
}

-(TMView *)standartLeftBarView {
   
    
    if(!_container) {
        
        _pinButton = [[TMTextButton alloc] initWithFrame:NSMakeRect(14, 6, 60, 20)];
        
        [_pinButton setStringValue:NSLocalizedString(@"Conversation.Pin", nil)];
        [_pinButton setFont:TGSystemFont(13)];
        [_pinButton setTextColor:BLUE_UI_COLOR];
        
        weak();
        
        
        [_pinButton setTapBlock:^{
            
            [weakSelf pinOrUnpin];
            
        }];
        
        _container = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 80, 30)];
        
        _imageView = imageViewWithImage(image_PinConversation());
        
        [_imageView setCenteredYByView:_container];
        
        
        [_container addSubview:_pinButton];
        [_container addSubview:_imageView];
        
    }
    
    
    return (TMView *)_container;
}

-(void)pinOrUnpin {
    [self.view.window setLevel:self.view.window.level == NSNormalWindowLevel ? NSScreenSaverWindowLevel : NSNormalWindowLevel];
    
    [_pinButton setStringValue:self.view.window.level == NSNormalWindowLevel ? NSLocalizedString(@"Conversation.Pin", nil) : NSLocalizedString(@"Conversation.Pinned", nil)];
    [_imageView setImage:self.view.window.level == NSNormalWindowLevel ? image_PinConversation() : image_PinnedConversation()];
}

@end
