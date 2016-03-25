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
        
        [Notification addObserver:self selector:@selector(messagTableEditedMessageUpdate:) name:UPDATE_EDITED_MESSAGE];
        
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



-(void)messagTableEditedMessageUpdate:(NSNotification *)notification {
    TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
    
    if(message.n_id == self.message.replyMessage.n_id) {
        self.message.replyMessage = message;
        
        [self update];
        
        [Notification perform:UPDATE_MESSAGE_ITEM data:@{@"item":self}];
    }
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(BOOL)makeSizeByWidth:(int)width {
    
    NSSize size = [self.messageAttributedString coreTextSizeForTextFieldForWidth:width];
    
    self.textSize = size;
    
    size.width = width;
    size.height += self.defaultContentOffset*2;
    self.blockSize = size;
    
    return [super makeSizeByWidth:width];
}

-(void)update
{
    self.messageAttributedString = [[MessagesUtils serviceAttributedMessage:self.message forAction:self.message.action] mutableCopy];
    [self.messageAttributedString addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:self.messageAttributedString.range];
    [self.messageAttributedString setFont:TGSystemFont(12) forRange:self.messageAttributedString.range];
    [self.messageAttributedString setLink:[NSString stringWithFormat:@"chat://showreplymessage/?peer_class=%@&peer_id=%d&msg_id=%d&from_msg_id=%d",NSStringFromClass(self.message.to_id.class),self.message.peer_id,self.message.reply_to_msg_id,self.message.n_id] forRange:self.messageAttributedString.range];
}

-(Class)viewClass {
    return [MessageTableCellServiceMessage class];
}

@end
