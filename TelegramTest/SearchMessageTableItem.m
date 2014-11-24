//
//  SearchMessageTableItem.m
//  Telegram
//
//  Created by keepcoder on 21.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchMessageTableItem.h"
#import "MessagesUtils.h"
#import "TGDateUtils.h"
@implementation SearchMessageTableItem


-(id)initWithMessage:(TL_localMessage *)message selectedText:(NSString *)selectedText {
    if(self = [super init]) {
        
        self.lastMessage = message;
        self.dialog = message.conversation;
        self.selectString = selectedText;
        
        [Notification addObserver:self selector:@selector(notificationChangeMute:) name:PUSHNOTIFICATION_UPDATE];
        [Notification addObserver:self selector:@selector(notificationChangedDeliveryState:) name:MESSAGE_CHANGED_DSTATE];
        
        self.type = self.dialog.type;
        
        switch (self.type) {
                
            case DialogTypeUser: {
                self.user = self.dialog.user;
                break;
            }
                
            case DialogTypeChat: {
                self.chat = self.dialog.chat;
                break;
            }
                
            case DialogTypeSecretChat: {
                TLEncryptedChat *chat = self.dialog.encryptedChat;
                self.user = [chat peerUser];
                break;
            }
                
            case DialogTypeBroadcast: {
                self.broadcast = self.dialog.broadcast;
                break;
            }
            default:
                break;
        }
        
        self.isMuted = self.dialog.isMute;
        
        NSMutableAttributedString *messageText = [[NSMutableAttributedString alloc] init];
        [messageText beginEditing];
        
        self.isOut = [UsersManager currentUserId] == self.lastMessage.from_id;
        self.isRead = !message.unread;
        
        
        self.messageText = [MessagesUtils conversationLastText:self.lastMessage conversation:self.dialog];
        
        int time = self.lastMessage.date;
        time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
        
        self.dateSize = NSZeroSize;
        self.date = [[NSMutableAttributedString alloc] init];
        [self.date setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x999999)];
        [self.date setSelectionColor:NSColorFromRGB(0x999999) forColor:NSColorFromRGB(0x333333)];
        [self.date setSelectionColor:NSColorFromRGB(0xcbe1f2) forColor:DARK_BLUE];
        
        if(self.messageText.length > 0) {
            NSString *dateStr = [TGDateUtils stringForMessageListDate:time];
            [self.date appendString:dateStr withColor:NSColorFromRGB(0x999999)];
        } else {
            [self.date appendString:@"" withColor:NSColorFromRGB(0xaeaeae)];
        }   
    }
    
    return self;
}

-(NSUInteger)hash {
    return[[NSString stringWithFormat:@"search_message_%d",self.lastMessage.n_id] hash];
}

@end
