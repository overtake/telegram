//
//  MessageTablePinnedItem.m
//  Telegram
//
//  Created by keepcoder on 07/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "MessageTableItemPinned.h"
#import "MessageTableCellServiceMessage.h"
#import "TGReplyObject.h"
#import "MessagesUtils.h"
@implementation MessageTableItemPinned

-(id)initWithObject:(TL_localMessageService *)object {
    if(self = [super initWithObject:object]) {
        
        
        
        if(object.replyMessage || object.reply_to_msg_id == 0) {
            [self update];
        } else {
            static NSMutableAttributedString *attr;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                attr = [[NSMutableAttributedString alloc] init];
                [attr appendString:NSLocalizedString(@"Reply.Loading", nil) withColor:GRAY_TEXT_COLOR];
                [attr setFont:TGSystemFont(13) forRange:attr.range];
            });
            
            self.messageAttributedString = attr;
            
           [TGReplyObject loadReplyMessage:object completionHandler:^(TL_localMessage *message) {
               self.message.replyMessage = message;
               [self update];
               
               [Notification perform:UPDATE_MESSAGE_ITEM data:@{@"item":self}];
           }];
        }
        
    }
    
    return self;
}


-(void)update
{
    self.messageAttributedString = [[MessagesUtils serviceAttributedMessage:self.message forAction:self.message.action] mutableCopy];
}

-(Class)viewClass {
    return [MessageTableCellServiceMessage class];
}

@end
