//
//  TGContextMessagesvViewController.m
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGContextMessagesvViewController.h"
#import "MessageTableItem.h"
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
    [_contextModalView close:YES];
}

-(BOOL)contextAbility {
    return NO;
}

-(void)receivedMessageList:(NSArray *)list inRange:(NSRange)range itsSelf:(BOOL)force {
    [super receivedMessageList:list inRange:range itsSelf:force];
    
   [list enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       if([obj.message.reply_markup isKindOfClass:[TL_replyInlineMarkup class]]) {
           [obj.message.reply_markup.rows enumerateObjectsUsingBlock:^(TL_keyboardButtonRow *keyboard, NSUInteger idx, BOOL * _Nonnull stop) {
               [keyboard.buttons enumerateObjectsUsingBlock:^(TLKeyboardButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
                   if([button isKindOfClass:[TL_keyboardButtonSwitchInline class]]) {
                       
                       dispatch_after_seconds(0.2, ^{
                           [MessageSender proccessInlineKeyboardButton:button messagesViewController:self conversation:self.conversation messageId:0 handler:^(TGInlineKeyboardProccessType type) {
                               
                           }];
                       });
                       
                       
                       
                       *stop = YES;
                   }
               }];
           }];
       }
   }];
    
}


-(void)setState:(MessagesViewControllerState)state {
    [super setState:MessagesViewControllerStateNone];
}


- (void)setCellsEditButtonShow:(BOOL)show animated:(BOOL)animated {
    
    
}

- (void)showForwardMessagesModalView {
    
}

@end
