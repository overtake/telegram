//
//  DialogTableItem.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "DialogTableItem.h"
#import "NS(Attributed)String+Geometrics.h"
#import "MessagesUtils.h"
#import "TGPeer+Extensions.h"
#import "NSNumber+NumberFormatter.h"
#import "TMElements.h"
#import "NSDate-Utilities.h"
#import "TGDialog+Extensions.h"
#import "RMPhoneFormat.h"
#import "DownloadOperation.h"
#import "NSString+Extended.h"
#import "TGDateUtils.h"
@interface DialogTableItem()
@property (nonatomic) BOOL isNotRead;
@end

@implementation DialogTableItem

- (id)initWithDialogItem:(TL_conversation *)dialog {
    self = [super init];
    
    self.dialog = [[DialogsManager sharedManager] find:dialog.peer.peer_id];
    
    
  //  assert(dialog == [[DialogsManager sharedManager] find:dialog.peer.peer_id]);
    
    
    [Notification addObserver:self selector:@selector(notificationChangeMessage:) name:[Notification notificationNameByDialog:dialog action:@"message"]];
    [Notification addObserver:self selector:@selector(notificationChangeUnreadCount:) name:[Notification notificationNameByDialog:dialog action:@"unread_count"]];
    [Notification addObserver:self selector:@selector(notificationTyping:) name:[Notification notificationNameByDialog:self.dialog action:@"typing"]];
    [Notification addObserver:self selector:@selector(notificationChangeMute:) name:PUSHNOTIFICATION_UPDATE];
    [Notification addObserver:self selector:@selector(notificationChangedDeliveryState:) name:MESSAGE_CHANGED_DSTATE];
    
    self.type = dialog.type;
    
    switch (self.type) {
            
        case DialogTypeUser: {
            self.user = dialog.user;
            break;
        }
            
        case DialogTypeChat: {
            self.chat = dialog.chat;
            break;
        }
        
        case DialogTypeSecretChat: {
            TGEncryptedChat *chat = dialog.encryptedChat;
            self.user = [chat peerUser];
            break;
        }
            
        case DialogTypeBroadcast: {
            self.broadcast = dialog.broadcast;
            break;
        }
        default:
            break;
    }
    
    self.isMuted = self.dialog.isMute;
    
    self.writeAttributedString = [[NSMutableAttributedString alloc] init];
    [self.writeAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
    [self notificationChangeMessage:nil];
    return self;
}

- (id)initWithDialogItem:(TL_conversation *)dialog selectString:(NSString *)selectString {
    if(self = [self initWithDialogItem:dialog]) {
        self.selectString = selectString;
    }
    return self;
}

- (void)notificationChangeMute:(NSNotification *)notify {
    int peer_id = [[notify.userInfo objectForKey:KEY_PEER_ID] intValue];
    if(peer_id == self.dialog.peer.peer_id) {
        BOOL isMuted = [[notify.userInfo objectForKey:KEY_IS_MUTE] boolValue];
        if(self.isMuted != isMuted) {
            self.isMuted = isMuted;
            [self redrawRow];
        }
    }
}

- (void)notificationTyping:(NSNotification *)notify {
    NSArray *array2 = [notify.userInfo objectForKey:@"users"];

    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:array2];
    
    if(array.count) {
        [[self.writeAttributedString mutableString] setString:@""];
        [self.writeAttributedString setSelected:NO];

        NSString *string;
        if(self.dialog.type == DialogTypeChat) {
            int maxSize = 15;
            
            if(array.count == 1) {
                TGUser *user = [[UsersManager sharedManager] find:[[array objectAtIndex:0] intValue]];
                string = user.dialogFullName;
                
                if(string.length > maxSize)
                    string = [NSString stringWithFormat:@"%@...", [string substringToIndex:maxSize - 3]];
                
                string = [NSString stringWithFormat:NSLocalizedString(@"Typing.IsTyping", nil), string];
            } else if(array.count == 2) {
                TGUser *user1 = [[UsersManager sharedManager] find:[[array objectAtIndex:0] intValue]];
                TGUser *user2 = [[UsersManager sharedManager] find:[[array objectAtIndex:1] intValue]];
                
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
        
        [self.writeAttributedString appendString:string withColor:NSColorFromRGB(0x333333)];
        self.isTyping = YES;
    } else {
        self.isTyping = NO;
    }
    
    [self redrawRow];
}

- (void)notificationChangedDeliveryState:(NSNotification *)notify {
    TL_localMessage *msg = notify.userInfo[KEY_MESSAGE];
    
    if(msg.n_id == self.lastMessage.n_id) {
        self.lastMessage = msg;
        [self redrawRow];
    }
}

- (void)notificationChangeMessage:(NSNotification *)notify {
    
    self.lastMessage = [[MessagesManager sharedManager] find:self.dialog.top_message];
    
    if(!self.lastMessage && self.dialog.top_message != -1) {
        NSLog(@"no message %@", self.dialog);
    }
    
    NSMutableAttributedString *messageText = [[NSMutableAttributedString alloc] init];
    [messageText beginEditing];
    
    self.isOut = [UsersManager currentUserId] == self.lastMessage.from_id;
    self.isRead = !self.lastMessage.unread;
    self.isNotRead = self.lastMessage.unread && !self.isOut;
    
    
    self.messageText = [MessagesUtils conversationLastText:self.lastMessage conversation:self.dialog];
        
    
    
    //Date
    [self generateDate];
    [self notificationChangeUnreadCount:nil];
    
    if(notify)
        [self redrawRow];
}

- (void)generateDate {
    
    int time = self.dialog.last_message_date;
    time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    self.dateSize = NSZeroSize;
    self.date = [[NSMutableAttributedString alloc] init];
    [self.date setSelectionColor:NSColorFromRGB(0xcbe1f0) forColor:NSColorFromRGB(0xaeaeae)];
    [self.date setSelectionColor:NSColorFromRGB(0x999999) forColor:NSColorFromRGB(0x333333)];
    [self.date setSelectionColor:NSColorFromRGB(0xcbe1f2) forColor:DARK_BLUE];

    if(self.messageText.length > 0) {
        NSString *dateStr = [TGDateUtils stringForMessageListDate:time];
        [self.date appendString:dateStr withColor:NSColorFromRGB(0xaeaeae)];
    } else {
        [self.date appendString:@"" withColor:NSColorFromRGB(0xaeaeae)];
    }
}

- (void)notificationChangeUnreadCount:(NSNotification *)notify {
    if(notify && !self.dialog.unread_count) {
        [self notificationChangeMessage:nil];
        [self redrawRow];
        return;
    }
    
    if(self.dialog.unread_count) {
        NSString *unreadTextCount;
        
        if(self.dialog.unread_count < 1000)
            unreadTextCount = [NSString stringWithFormat:@"%d", self.dialog.unread_count];
        else
            unreadTextCount = [[NSNumber numberWithInt:self.dialog.unread_count] prettyNumber];
        
//  unreadTextCount = 1000;
        
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
    return self.dialog;
}

+ (NSUInteger)hash:(TL_conversation *)object {
    NSString *hashStr = [Notification notificationNameByDialog:object action:@"hash"];
    return [hashStr hash];
}
@end
