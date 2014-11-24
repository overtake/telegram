//
//  DialogTableObject.m
//  Telegram
//
//  Created by keepcoder on 13.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//
#import "MessagesUtils.h"
#import "DialogTableObject.h"

@implementation DialogTableObject
-(id)initWithDialog:(TL_conversation *)dialog {
    if(self = [super init]) {
        self.dialog = dialog;
        
        self.lastMessage = [[MessagesManager sharedManager] find:dialog.top_message];
        NSString *msg = self.lastMessage.message;
        if(self.lastMessage.action) {
            msg = [MessagesUtils serviceMessage:self.lastMessage forAction:self.lastMessage.action];
        } else if(![self.lastMessage.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            msg = [MessagesUtils mediaMessage:self.lastMessage];
        }
        
        NSRange range  = NSMakeRange(0, 0);
        if([dialog peer].chat_id == 0) {
            TLUser *user = [[UsersManager sharedManager] find:[dialog peer].user_id];
            self.n_id = user.n_id;
            self.title = [user fullName];
            self.location = user.photo.photo_small;
        } else {
            TLUser *user = [[UsersManager sharedManager] find:self.lastMessage.from_id];
            TLChat *chat =  [[ChatsManager sharedManager] find:dialog.peer.chat_id];
            self.n_id = chat.n_id;
            self.title = chat.title;
            self.location = chat.photo.photo_small;
            if(self.lastMessage.n_out) {
                msg = [@"You\n" stringByAppendingString:msg];
                range = NSMakeRange(0, 3);
            } else {
                msg = [NSString stringWithFormat:@"%@\n%@",[user fullName],msg];
                range = NSMakeRange(0, [user fullName].length);
            }
            
        }
        if(!msg)
            msg = @"";
        NSColor *color = [MessagesUtils colorForUserId:self.lastMessage.from_id];
        NSMutableAttributedString *msgString = [[NSMutableAttributedString alloc] initWithString:msg attributes:nil];
        [msgString setAttributes:@{NSForegroundColorAttributeName:color} range:range];
        self.message = msgString;

    }
    return self;
}
@end
