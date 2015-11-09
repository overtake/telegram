//
//  ChannelFilter.m
//  Telegram
//
//  Created by keepcoder on 25.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelFilter.h"
#import "ChatHistoryController.h"

@interface ChannelFilter()

@end

@implementation ChannelFilter


-(int)type {
    return HistoryFilterChannelMessage;
}

+(int)type {
    return HistoryFilterChannelMessage;
}





-(void)fillGroupHoles:(NSArray *)messages bottom:(BOOL)bottom {
    
    if(messages.count == 0)
        return;
    
    // max to min
    [messages enumerateObjectsWithOptions:0  usingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
        
        
        if(![obj isImportantMessage]) {
            
            TL_localMessage *lastImportantMessage = [[Storage manager] lastMessageAroundMinId:obj.channelMsgId important:YES isTop:!bottom];
            
            
            
            int lastImportantMessageId = [lastImportantMessage n_id] == 0 ? (bottom ? 1 : self.controller.conversation.top_message) : [lastImportantMessage n_id];
                        
            NSArray *holes = [[Storage manager] groupHoles:obj.peer_id min:!bottom?obj.n_id:lastImportantMessageId max:bottom?obj.n_id:lastImportantMessageId];
            
            __block TGMessageGroupHole *hole;
            
            [holes enumerateObjectsUsingBlock:^(TGMessageGroupHole *gh, NSUInteger idx, BOOL *stop) {
                if(gh.min_id <= obj.n_id && gh.max_id >= obj.n_id) {
                    hole = gh;
                    *stop = YES;
                }
            }];
            
            
            if(hole) {
                
                if(!hole.isImploded) {
                    if(bottom) {
                        if(hole.max_id >= obj.n_id) {
                            hole.max_id = obj.n_id+1;
                            
                            hole.messagesCount++;
                            
                            [hole save];
                        }
                    } else if(hole.min_id <= obj.n_id) {
                        hole.min_id = obj.n_id-1;
                        hole.messagesCount++;
                        
                        [hole save];
                    }
                }
    
            } else {
                TGMessageGroupHole *groupHole = [[TGMessageGroupHole alloc] initWithUniqueId:-rand_int() peer_id:obj.peer_id min_id:obj.n_id-1 max_id:obj.n_id+1 date:!bottom?lastImportantMessage.date:obj.date-1 count:1];
                [groupHole save];
            }
            
            
        }
        
     
        
   }];
    
   
    
}

-(int)additionSenderFlags {
    return (1 << 4);
}


@end
