//
//  TGConversationTableItem.m
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGConversationTableItem.h"
#import "MessagesUtils.h"
#import "TGDateUtils.h"
#import "NSNumber+NumberFormatter.h"
@interface TGConversationTableItem ()
@property (nonatomic,strong) TL_localMessage *checkMessage;
@end

@implementation TGConversationTableItem

-(id)initWithConversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        
        self.conversation = conversation;
        
        
        [Notification addObserver:self selector:@selector(needUpdateMessage:) name:[Notification notificationNameByDialog:conversation action:@"message"]];
        [Notification addObserver:self selector:@selector(needUpdateMessage:) name:[Notification notificationNameByDialog:conversation action:@"unread_count"]];
        [Notification addObserver:self selector:@selector(didChangeTyping:) name:[Notification notificationNameByDialog:conversation action:@"typing"]];
        
        [Notification addObserver:self selector:@selector(didChangeNotifications:) name:[Notification notificationNameByDialog:conversation action:@"notification"]];
       
        [self needUpdateMessage:[[NSNotification alloc] initWithName:@"" object:nil userInfo:@{KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:conversation],KEY_DIALOG:conversation,KEY_DIALOG:conversation}]];
    
    }
    
    return self;
}

-(void)didChangeNotifications:(NSNotification *)notification {
    [self performReload];
}


-(void)needUpdateMessage:(NSNotification *)notification {
    
    _conversation = notification.userInfo[KEY_DIALOG];
    
    assert(_conversation != nil);
    
    _checkMessage = self.conversation.lastMessage;
    
    
   _messageText = notification.userInfo[KEY_LAST_CONVRESATION_DATA][@"messageText"];
    _dateText = notification.userInfo[KEY_LAST_CONVRESATION_DATA][@"dateText"];
    _dateSize = [notification.userInfo[KEY_LAST_CONVRESATION_DATA][@"dateSize"] sizeValue];
    _unreadText = notification.userInfo[KEY_LAST_CONVRESATION_DATA][@"unreadText"];
    _unreadTextSize = [notification.userInfo[KEY_LAST_CONVRESATION_DATA][@"unreadTextSize"] sizeValue];
    
    
    if(self.conversation.type != DialogTypeSecretChat && self.conversation.chat)
        self.nameTextSize = [self.conversation.chat dialogTitleSize];
     else if(self.conversation.type == DialogTypeSecretChat)
         self.nameTextSize = [self.conversation.user dialogEncryptedTitleSize];
    else
        self.nameTextSize = [self.conversation.user dialogTitleSize];
    
    
    
    BOOL isNotForReload = [notification.userInfo[@"isNotForReload"] boolValue];
    if(!isNotForReload)
        [self performReload];
}

-(NSSize)nameTextSize {
    return NSMakeSize(_nameTextSize.width + (self.conversation.isMute ? 20 : 0), _nameTextSize.height);;
}

-(BOOL)itemIsUpdated {
    return _checkMessage == self.conversation.lastMessage;
}

-(void)didChangeTyping:(NSNotification *)notify {
    NSArray *actions;
    
    actions = notify.userInfo[@"users"];
    
    if(actions.count > 0) {
        
        NSString *string;
        
        if(actions.count == 1) {
            
            TGActionTyping *action = actions[0];
            
            if(action.user && _conversation.type != DialogTypeUser && _conversation.type != DialogTypeSecretChat) {
                string =[NSString stringWithFormat:NSLocalizedString(NSStringFromClass(action.action.class), nil),action.user.dialogFullName];
            } else {
                string = NSLocalizedString(@"Typing.Typing", nil);
            }
            
            
        } else {
            
            string = [NSString stringWithFormat:NSLocalizedString(@"Typing.PeopleTyping", nil), (int)actions.count];
        }
        
        _typing = string;
        
    } else {
        _typing = nil;
    }
    
    
    [self performReload];
}


-(void)performReload {
    [self redrawRow];
}

-(void)dealloc {

    [self clear];
 
    [Notification removeObserver:self];
    
}

-(void)clear {
    
}

-(void)setConversation:(TL_conversation *)conversation {
    
    if(_conversation) {
        [self clear];
    }
    
    _conversation = conversation;
}




-(TL_localMessage *)message {
    return _conversation.lastMessage;
}

-(NSUInteger)hash {
    return _conversation.peer_id;
}

@end
