//
//  SearchItem.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchItem.h"
#import "MessagesUtils.h"
#import "TMAttributedString.h"
#import "TGDateUtils.h"


#define SelectColorNormal NSColorFromRGB(0x57a4e2)
#define SelectColorSelected NSColorFromRGB(0x000000)

@implementation SearchItem

- (void)initialize {
    self.title = [[NSMutableAttributedString alloc] init];
    [self.title setSelectionColor:NSColorFromRGB(0xffffff) forColor:DARK_BLACK];
    [self.title setSelectionColor:NSColorFromRGB(0xfffffe) forColor:LINK_COLOR];
    [self.title setSelectionColor:NSColorFromRGB(0xfffffa) forColor:BLUE_UI_COLOR];

    
    self.status = [[NSMutableAttributedString alloc] init];
    [self.status setSelectionColor:NSColorFromRGB(0xffffff) forColor:BLUE_UI_COLOR];
    [self.status setSelectionColor:NSColorFromRGB(0xfffffd) forColor:NSColorFromRGB(0x333333)];
    [self.status setSelectionColor:NSColorFromRGB(0xfffffe) forColor:NSColorFromRGB(0x9b9b9b)];
}

- (id)initWithUserItem:(TLUser*)user searchString:(NSString*)searchString {
    self = [super init];
    if(self) {
        [self initialize];
        
        self.user = user;
        
        self.type = SearchItemUser;
        self.conversation = [[DialogsManager sharedManager] findByUserId:user.n_id];
        if(!self.conversation) {
            self.conversation = [[DialogsManager sharedManager] createDialogForUser:user];
        }
        
        [self.title appendString:user.fullName withColor:DARK_BLACK];
        [NSMutableAttributedString selectText:searchString fromAttributedString:(NSMutableAttributedString *)self.title selectionColor:BLUE_UI_COLOR];
    
    }
    return self;
}


- (id)initWithGlobalItem:(id)object searchString:(NSString *)searchString {
    self = [super init];
    if(self) {
        [self initialize];
        
        self.type = SearchItemGlobalUser;
        
        if([object isKindOfClass:[TLUser class]]) {
            
            TLUser *user = object;
        
            self.conversation = user.dialog;
            
            self.user = user;
            
            [self.title appendString:user.fullName withColor:DARK_BLACK];
            
            
            
            [self.status appendString:[NSString stringWithFormat:@"@%@",user.username] withColor:GRAY_TEXT_COLOR];
            
            [self.status setSelectionColor:NSColorFromRGB(0xfffffe) forColor:GRAY_TEXT_COLOR];
            
            [NSMutableAttributedString selectText:[NSString stringWithFormat:@"@%@",searchString] fromAttributedString:(NSMutableAttributedString *)self.status selectionColor:BLUE_UI_COLOR];
            
        } else if([object isKindOfClass:[TLChat class]]) {
            TLChat *chat = object;
            
            self.conversation = chat.dialog;
            
            self.chat = chat;
            
            [self.title appendString:chat.title withColor:DARK_BLACK];
            
            
            [self.status appendString:[NSString stringWithFormat:@"@%@",chat.username] withColor:GRAY_TEXT_COLOR];
            
            [self.status setSelectionColor:NSColorFromRGB(0xfffffe) forColor:GRAY_TEXT_COLOR];
            
            [NSMutableAttributedString selectText:[NSString stringWithFormat:@"@%@",searchString] fromAttributedString:(NSMutableAttributedString *)self.status selectionColor:BLUE_UI_COLOR];
        }
        
    }
    return self;
}

- (id)initWithChatItem:(TLChat *)chat searchString:(NSString *)searchString {
    self = [super init];
    if(self) {
        [self initialize];

        self.type = SearchItemChat;
        self.chat = [[ChatsManager sharedManager] find:chat.n_id];
        self.conversation = chat.dialog;
        
        [self.title appendString:chat.title withColor:DARK_BLACK];
        [NSMutableAttributedString selectText:searchString fromAttributedString:(NSMutableAttributedString *)self.title selectionColor:BLUE_UI_COLOR];
        
    }
    return self;
}

- (id)initWithDialogItem:(TL_conversation *)dialog searchString:(NSString*)searchString {
    self = [super init];
    if(self) {
        [self initialize];
        
        self.type = SearchItemConversation;
        
        self.conversation = dialog;
        
        
        if(self.conversation.type == DialogTypeChat || self.conversation.type == DialogTypeChannel) {
            self.chat = self.conversation.chat;
        } else if(self.conversation.type == DialogTypeSecretChat) {
            self.user = self.conversation.encryptedChat.peerUser;
        } else {
            self.user = self.conversation.user;
        }
        
        
        
        [self.title appendString:self.conversation.type == DialogTypeChat || self.conversation.type == DialogTypeChannel ? self.chat.title : dialog.user.fullName withColor:DARK_BLACK];
        
        [NSMutableAttributedString selectText:searchString fromAttributedString:(NSMutableAttributedString*)self.title selectionColor:BLUE_UI_COLOR];
        
    }
    return self;
}

- (id)initWithMessageItem:(TL_localMessage *)message searchString:(NSString *)searchString {
    self = [super init];
    if(self) {
        [self initialize];

        self.type = SearchItemMessage;
        self.message = message;
        
        self.conversation = message.conversation;
        
        
        
        
        self.user = [[UsersManager sharedManager] find:self.message.from_id == [UsersManager currentUserId] ? self.message.to_id.user_id : self.message.from_id];
        
        if(self.conversation.type == DialogTypeSecretChat) {
            self.user =  self.conversation.encryptedChat.peerUser;
        }

        if(self.conversation.type == DialogTypeChat || self.conversation.type == DialogTypeChannel) {
            self.chat = self.conversation.chat;
            [self.title appendString:self.chat.title withColor:DARK_BLACK];
        } else {
            [self.title appendString:self.user.fullName withColor:DARK_BLACK];
        }
        
        
        [self.status appendString:message.message withColor:NSColorFromRGB(0x9b9b9b)];
        
        NSRange range = [NSMutableAttributedString selectText:searchString fromAttributedString:(NSMutableAttributedString *)self.status selectionColor:BLUE_UI_COLOR];
        
        
        if(range.location > 8 && range.location != NSNotFound) {
            NSString *string = [[[self.status mutableString] substringFromIndex:range.location - 8] substringToIndex:8];
            NSRange searchRange = [string rangeOfString:@" "];
            
            int offset = 0;
            if(searchRange.location != NSNotFound) {
                offset = (int)searchRange.location;
            }
            
            [[self.status mutableString] replaceCharactersInRange:NSMakeRange(0, range.location - 8 + offset) withString:@"..."];
        }
        
        if(self.conversation.type == DialogTypeChannel || self.conversation.type == DialogTypeChat || self.user.n_id != self.message.from_id) {
            
            TLUser *user = [[UsersManager sharedManager] find:self.message.from_id];
            
            NSString *name = user.n_id == [UsersManager currentUserId] ? NSLocalizedString(@"Profile.You", nil) : user.dialogFullName;
            
            NSString *string = [NSString stringWithFormat:@"%@: ", name];
            [[self.status mutableString] insertString:string atIndex:0];
            [self.status addAttribute:NSForegroundColorAttributeName value:NSColorFromRGB(0x333333) range:NSMakeRange(0, string.length)];
        }
        
        //generate date
        self.dateSize = NSZeroSize;
        self.date = [[NSMutableAttributedString alloc] init];
        [self.date setSelectionColor:NSColorFromRGB(0xcbe1f0) forColor:NSColorFromRGB(0xaeaeae)];
        [self.date setSelectionColor:NSColorFromRGB(0xcbe1f1) forColor:NSColorFromRGB(0x333333)];
        [self.date setSelectionColor:NSColorFromRGB(0xcbe1f2) forColor:DARK_BLUE];
        
        
        NSString *dateStr = [TGDateUtils stringForMessageListDate:message.date];
        [self.date appendString:dateStr withColor:NSColorFromRGB(0xaeaeae)];
      
        self.dateSize = [self.date size];
        
    }
    return self;
}

- (NSObject *)itemForHash {
    return self;
}

+ (NSUInteger)hash:(SearchItem *)item {
    NSString *hashStr;
    
    if(item.type == SearchItemMessage) {
        hashStr = [NSString stringWithFormat:@"message_%d", item.message.n_id];
    } else if(item.type ==SearchItemGlobalUser) {
        hashStr = [NSString stringWithFormat:@"global_user_%d", item.user.n_id];
    } else {
        if(item.type == SearchItemConversation ) {
            hashStr = [Notification notificationNameByDialog:item.conversation action:@"hash"];
        } else if(item.type == SearchItemUser) {
            hashStr = [NSString stringWithFormat:@"user_%d", item.user.n_id];
        } else if(item.type == SearchItemChat) {
            hashStr = [NSString stringWithFormat:@"chat_%d", item.chat.n_id];
        }
    }
 
//    MTLog(@"hashStr %@", hashStr);

    return [hashStr hash];
}

@end
