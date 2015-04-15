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
        
        
        [conversation addObserver:self
               forKeyPath:@"lastMessage"
                  options:0
                  context:NULL];
        
        [conversation addObserver:self
                       forKeyPath:@"lastMessage.flags"
                          options:0
                          context:NULL];
        
        [conversation addObserver:self forKeyPath:@"dstate" options:0 context:NULL];
        [conversation addObserver:self forKeyPath:@"unread_count" options:0 context:NULL];
        [conversation addObserver:self forKeyPath:@"notify_settings" options:0 context:NULL];
        [self update];

    }
    
    return self;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
        
    [self update];
    
    [ASQueue dispatchOnMainQueue:^{
        [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self.table indexOfItem:self]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }];
    
    
}

-(void)dealloc {
    [_conversation removeObserver:self forKeyPath:@"lastMessage" context:NULL];
    [_conversation removeObserver:self forKeyPath:@"lastMessage.flags" context:NULL];
    [_conversation removeObserver:self forKeyPath:@"dstate" context:NULL];
    [_conversation removeObserver:self forKeyPath:@"unread_count" context:NULL];
    [_conversation removeObserver:self forKeyPath:@"notify_settings" context:NULL];
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
