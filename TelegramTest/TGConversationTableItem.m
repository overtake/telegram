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
@property (nonatomic,strong) TL_localMessage *message;
@end

@implementation TGConversationTableItem

-(id)initWithConversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        _conversation = conversation;
        
        
        [Notification addObserver:self selector:@selector(needUpdateItem:) name:[Notification notificationNameByDialog:conversation action:@"message"]];
        [Notification addObserver:self selector:@selector(needUpdateItem:) name:[Notification notificationNameByDialog:conversation action:@"unread_count"]];
        [Notification addObserver:self selector:@selector(needUpdateItem:) name:[Notification notificationNameByDialog:self.conversation action:@"typing"]];

        [conversation addObserver:self forKeyPath:@"dstate" options:0 context:NULL];
        [conversation addObserver:self forKeyPath:@"notify_settings" options:0 context:NULL];
        
        
        [Notification addObserver:self selector:@selector(didChangeTyping:) name:[Notification notificationNameByDialog:conversation action:@"typing"]];
       
        [self update];
        
        [self didChangeTyping:nil];

    }
    
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    int i = 0;
    
    [ASQueue dispatchOnStageQueue:^{
        
        [self update];
        
        [self performReload];
        
    }];
    
}

-(void)didChangeTyping:(NSNotification *)notify {
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSArray *actions;
        
        if(!notify) {
            actions = [[TGModernTypingManager typingForConversation:_conversation] currentActions];
        } else {
            actions = notify.userInfo[@"users"];
        }
        
        if(actions.count > 0) {
            
            NSString *string;
            
            if(actions.count == 1) {
                
                TGActionTyping *action = actions[0];
                
                TLUser *user = [[UsersManager sharedManager] find:action.user_id];
                if(user)
                    string =[NSString stringWithFormat:NSLocalizedString(NSStringFromClass(action.action.class), nil),user.first_name];

            } else {
                
                string = [NSString stringWithFormat:NSLocalizedString(@"Typing.PeopleTyping", nil), (int)actions.count];
            }
            
            _typing = string;
            
        } else {
            _typing = nil;
        }
        
        
        [self performReload];
    }];
    
}


-(void)needUpdateItem:(NSNotification *)notification {
    
    [ASQueue dispatchOnStageQueue:^{
        [self update];
        
        [self performReload];
    }];

}

-(void)performReload {
    
    [ASQueue dispatchOnMainQueue:^{
        [self redrawRow];
    }];
    
}

-(void)dealloc {
//    [_conversation removeObserver:self forKeyPath:@"lastMessage" context:NULL];
//    [_conversation removeObserver:self forKeyPath:@"lastMessage.flags" context:NULL];
    [_conversation removeObserver:self forKeyPath:@"dstate" context:NULL];
    [_conversation removeObserver:self forKeyPath:@"notify_settings" context:NULL];
//    [_conversation removeObserver:self forKeyPath:@"unread_count" context:NULL];
    
    
    [Notification removeObserver:self];
}

-(void)update {
    _messageText = [MessagesUtils conversationLastText:_conversation.lastMessage conversation:_conversation];
    
    int time = self.conversation.last_message_date;
    time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    
    _dateText = [[NSMutableAttributedString alloc] init];
    [_dateText setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x999999)];
    [_dateText setSelectionColor:NSColorFromRGB(0x999999) forColor:NSColorFromRGB(0x333333)];
    [_dateText setSelectionColor:NSColorFromRGB(0xcbe1f2) forColor:DARK_BLUE];
    
    if(self.messageText.length > 0) {
        NSString *dateStr = [TGDateUtils stringForMessageListDate:time];
        [_dateText appendString:dateStr withColor:NSColorFromRGB(0x999999)];
    } else {
        [_dateText appendString:@"" withColor:NSColorFromRGB(0xaeaeae)];
    }
    
    _dateSize = [_dateText size];
    _dateSize.width+=5;
    _dateSize.width = ceil(_dateSize.width);
    _dateSize.height = ceil(_dateSize.height);
    
    
    if(_conversation.unread_count) {
        NSString *unreadTextCount;
        
        if(self.conversation.unread_count < 1000)
            unreadTextCount = [NSString stringWithFormat:@"%d", self.conversation.unread_count];
        else
            unreadTextCount = [@(self.conversation.unread_count) prettyNumber];
        
        NSDictionary *attributes =@{
                                    NSForegroundColorAttributeName: [NSColor whiteColor],
                                    NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Bold" size:10]
                                    };
        _unreadText = unreadTextCount;
        NSSize size = [unreadTextCount sizeWithAttributes:attributes];
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        _unreadTextSize = size;
        
    } else {
        _unreadText = nil;
    }
    
}






-(TL_localMessage *)message {
    return _conversation.lastMessage;
}

-(NSUInteger)hash {
    return _conversation.peer_id;
}

@end
