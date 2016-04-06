//
//  TGContextMessagesvViewController.m
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGContextMessagesvViewController.h"

@interface TGContextMessagesvViewController ()
@property (nonatomic,strong) TMTextButton *doneButton;
@property (nonatomic,strong) TMView *container;
@end

@implementation TGContextMessagesvViewController

-(TMView *)standartLeftBarView {
    
    return nil;
}

-(TMView *)standartRightBarView {
    
    
    if(!_doneButton) {
        
        _doneButton = [[TMTextButton alloc] initWithFrame:NSMakeRect(0, 0, 45, 20)];
        
        [_doneButton setStringValue:NSLocalizedString(@"Compose.Done", nil)];
        [_doneButton setFont:TGSystemFont(13)];
        [_doneButton setTextColor:BLUE_UI_COLOR];
        [_doneButton sizeToFit];
        weak();
        
        
        [_doneButton setTapBlock:^{
            
            [weakSelf close];
            
        }];

    }
    
    
    return (TMView *)_doneButton;
}

-(void)close {
    
}

-(BOOL)contextAbility {
    return NO;
}


-(void)setState:(MessagesViewControllerState)state {
    [super setState:MessagesViewControllerStateNone];
}


- (void)setCellsEditButtonShow:(BOOL)show animated:(BOOL)animated {
    
    
}

- (void)showForwardMessagesModalView {
    
}

@end
