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

@interface SearchMessageTableItem ()
@property (nonatomic,strong) TL_localMessage *message;
@end

@implementation SearchMessageTableItem


@synthesize conversation = _conversation;
@synthesize messageText = _messageText;
@synthesize dateSize = _dateSize;
@synthesize dateText = _dateText;
@synthesize selectText = _selectText;


-(id)initWithMessage:(TL_localMessage *)message selectedText:(NSString *)selectedText {
    if(self = [super init]) {
        
        _conversation = message.conversation;
        
        if(message.chat.migrated_to.channel_id != 0) {
            
            TLChat *chat = [[ChatsManager sharedManager] find:message.chat.migrated_to.channel_id];
            
            _conversation = [chat dialog];
            
            /*
             27.04.15, 18:47:02: Dmitry Moskovsky: Оро
             
             */
        }
        
        _message = message;
        
        _selectText = selectedText;
        
                
        [self update];
        
    }
    
    return self;
}

-(void)dealloc {
    
}


-(void)update {
    
    
    _messageText = [MessagesUtils conversationLastText:_message conversation:_conversation];
    
    int time = _message.date;
    time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    _dateText = [[NSMutableAttributedString alloc] init];
    [_dateText setSelectionColor:NSColorFromRGB(0xffffff) forColor:GRAY_TEXT_COLOR];
    [_dateText setSelectionColor:GRAY_TEXT_COLOR forColor:NSColorFromRGB(0x333333)];
    [_dateText setSelectionColor:NSColorFromRGB(0xcbe1f2) forColor:DARK_BLUE];
    
    if(self.messageText.length > 0) {
        NSString *dateStr = [TGDateUtils stringForMessageListDate:time];
        [_dateText appendString:dateStr withColor:GRAY_TEXT_COLOR];
    } else {
        [_dateText appendString:@"" withColor:NSColorFromRGB(0xaeaeae)];
    }
    
    if(self.conversation.type != DialogTypeSecretChat && self.conversation.chat)
        self.nameTextSize = [self.conversation.chat dialogTitleSize];
    else if(self.conversation.type == DialogTypeSecretChat)
        self.nameTextSize = [self.conversation.user dialogEncryptedTitleSize];
    else
        self.nameTextSize = [self.conversation.user dialogTitleSize];
    
    self.nameTextSize = NSMakeSize(self.nameTextSize.width + (self.conversation.isMute ? 20 : 0), self.nameTextSize.height);
    
    _dateSize = [_dateText size];
    _dateSize.width+=5;
    _dateSize.width = ceil(_dateSize.width);
    _dateSize.height = ceil(_dateSize.height);
    
}

-(TL_localMessage *)message {
    return _message;
}

-(NSUInteger)hash {
    return[[NSString stringWithFormat:@"search_message_%d",_message.n_id] hash];
}


@end
