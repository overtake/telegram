//
//  DialogTableItem.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ConversationTableItem.h"
#import "NS(Attributed)String+Geometrics.h"
#import "MessagesUtils.h"
#import "TLPeer+Extensions.h"
#import "NSNumber+NumberFormatter.h"
#import "TMElements.h"
#import "NSDate-Utilities.h"
#import "RMPhoneFormat.h"
#import "DownloadOperation.h"
#import "NSString+Extended.h"
#import "TGDateUtils.h"
#import "TMTypingObject.h"
@interface ConversationTableItem()
@property (nonatomic) BOOL isNotRead;
@end

@implementation ConversationTableItem

- (id)initWithConversationItem:(TL_conversation *)conversation {
    self = [super init];
    
    self.conversation = [[DialogsManager sharedManager] find:conversation.peer.peer_id];
    
    [Notification addObserver:self selector:@selector(notificationChangeMessage:) name:[Notification notificationNameByDialog:conversation action:@"message"]];
    [Notification addObserver:self selector:@selector(notificationChangeUnreadCount:) name:[Notification notificationNameByDialog:conversation action:@"unread_count"]];
    [Notification addObserver:self selector:@selector(notificationTyping:) name:[Notification notificationNameByDialog:self.conversation action:@"typing"]];
    [Notification addObserver:self selector:@selector(notificationChangeMute:) name:PUSHNOTIFICATION_UPDATE];
    [Notification addObserver:self selector:@selector(notificationChangedDeliveryState:) name:MESSAGE_CHANGED_DSTATE];
    
    self.type = conversation.type;
    
    switch (self.type) {
            
        case DialogTypeUser: {
            self.user = conversation.user;
            break;
        }
            
        case DialogTypeChat: {
            self.chat = conversation.chat;
            break;
        }
        
        case DialogTypeSecretChat: {
            TLEncryptedChat *chat = conversation.encryptedChat;
            self.user = [chat peerUser];
            break;
        }
            
        case DialogTypeBroadcast: {
            self.broadcast = conversation.broadcast;
            break;
        }
        default:
            break;
    }
    
    self.isMuted = self.conversation.isMute;
    
    self.writeAttributedString = [[NSMutableAttributedString alloc] init];
    [self.writeAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x808080)];
    [self notificationChangeMessage:nil];
    return self;
}

- (id)initWithConversationItem:(TL_conversation *)conversation selectString:(NSString *)selectString {
    if(self = [self initWithConversationItem:conversation]) {
        self.selectString = selectString;
    }
    return self;
}

- (void)notificationChangeMute:(NSNotification *)notify {
    int peer_id = [[notify.userInfo objectForKey:KEY_PEER_ID] intValue];
    if(peer_id == self.conversation.peer.peer_id) {
        BOOL isMuted = [[notify.userInfo objectForKey:KEY_IS_MUTE] boolValue];
        if(self.isMuted != isMuted) {
            self.isMuted = isMuted;
            [self redrawRow];
        }
    }
}

- (void)notificationTyping:(NSNotification *)notify {
    NSArray *array = [[notify.userInfo objectForKey:@"users"] mutableCopy];

    if(array.count) {
        [[self.writeAttributedString mutableString] setString:@""];
        [self.writeAttributedString setSelected:NO];

        NSString *string;
        if(self.conversation.type == DialogTypeChat) {
            int maxSize = 15;
            
            if(array.count == 1) {
                
                TGActionTyping *action = [array objectAtIndex:0];
                
                TLUser *user = [[UsersManager sharedManager] find:[action user_id]];
                string = user.dialogFullName;
                
                if(string.length > maxSize)
                    string = [NSString stringWithFormat:@"%@...", [string substringToIndex:maxSize - 3]];
                
                string = [NSString stringWithFormat:NSLocalizedString(@"Typing.IsTyping", nil), string];
                
            } else if(array.count == 2) {
                
                TGActionTyping *action1 = array[0];
                TGActionTyping *action2 = array[1];
                
                TLUser *user1 = [[UsersManager sharedManager] find:[action1 user_id]];
                TLUser *user2 = [[UsersManager sharedManager] find:[action2 user_id]];
                
                string = [NSString stringWithFormat:@"%@, %@", user1.dialogFullName, user2.dialogFullName];
                if(string.length > maxSize) {
                    string = [NSString stringWithFormat:NSLocalizedString(@"Typing.PeopleTyping", nil), (int)array.count];
                } else {
                    string = [NSString stringWithFormat:NSLocalizedString(@"Typing.AreTyping", nil), string];
                }
                
            } else {
                string = [NSString stringWithFormat:NSLocalizedString(@"Typing.PeopleTyping", nil), (int)array.count];
            }
            
        } else {
            string = NSLocalizedString(@"Typing.Typing", nil);
        }
        [self.writeAttributedString appendString:string withColor:NSColorFromRGB(0x808080)];
        [self.writeAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:12.5] forRange:self.writeAttributedString.range];
        self.isTyping = YES;
    } else {
        self.isTyping = NO;
    }
    
    static NSMutableParagraphStyle *paragraph;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paragraph = [[NSMutableParagraphStyle alloc] init];
        [paragraph setLineSpacing:0];
        [paragraph setMinimumLineHeight:5];
        [paragraph setMaximumLineHeight:15];
    });
    
    [self.writeAttributedString setAlignment:NSLeftTextAlignment range:NSMakeRange(0, self.writeAttributedString.length)];
    
    [self.writeAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:self.writeAttributedString.range];
    
    [self redrawRow];
}

- (void)notificationChangedDeliveryState:(NSNotification *)notify {
    TL_localMessage *msg = notify.userInfo[KEY_MESSAGE];
    
    if(msg.n_id == self.lastMessage.n_id) {
        self.lastMessage = msg;
        [self redrawRow];
    }
}

-(TL_conversation *)conversation {
    return [[DialogsManager sharedManager] find:_conversation.peer_id];
}

- (void)notificationChangeMessage:(NSNotification *)notify {
    
    
        
    [self updateLastMessage];
    
    //Date
    [self generateDate];
    [self notificationChangeUnreadCount:nil];
    
    if(notify)
        [self redrawRow];
}

-(void)updateLastMessage {
    self.lastMessage = [[MessagesManager sharedManager] find:self.conversation.top_message];
    
    
    NSMutableAttributedString *messageText = [[NSMutableAttributedString alloc] init];
    [messageText beginEditing];
    
    self.isOut = [UsersManager currentUserId] == self.lastMessage.from_id;
    self.isRead = !self.lastMessage.unread;
    self.isNotRead = self.lastMessage.unread && !self.isOut;
    
    self.messageText = [MessagesUtils conversationLastText:self.lastMessage conversation:self.conversation];
}



- (void)generateDate {
    
    int time = self.conversation.last_message_date;
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

- (void)notificationChangeUnreadCount:(NSNotification *)notify {
    if(notify && !self.conversation.unread_count) {
        [self notificationChangeMessage:nil];
        [self redrawRow];
        return;
    }
    
    [self updateLastMessage];
    
    if(self.conversation.unread_count) {
        NSString *unreadTextCount;
        
        if(self.conversation.unread_count < 1000)
            unreadTextCount = [NSString stringWithFormat:@"%d", self.conversation.unread_count];
        else
            unreadTextCount = [[NSNumber numberWithInt:self.conversation.unread_count] prettyNumber];
        
    NSDictionary *attributes =@{
                                NSForegroundColorAttributeName: [NSColor whiteColor],
                                NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Bold" size:10]
    };
        self.unreadTextCount = unreadTextCount;
        NSSize size = [unreadTextCount sizeWithAttributes:attributes];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        self.unreadTextSize = size;

    } else {
        self.unreadTextCount = nil;
    }
    
    if(notify)
        [self redrawRow];
}

- (NSObject *)itemForHash {
    return self.conversation;
}

+ (NSUInteger)hash:(TL_conversation *)object {
    NSString *hashStr = [Notification notificationNameByDialog:object action:@"hash"];
    return [hashStr hash];
}
@end
