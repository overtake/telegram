//
//  MessageSendItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageSenderItem.h"
#import "TLPeer+Extensions.h"
#import "MessageTableItem.h"
@interface MessageSenderItem ()
@property (nonatomic,assign) BOOL noWebpage;
@end

@implementation MessageSenderItem


-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation noWebpage:(BOOL)noWebpage additionFlags:(int)additionFlags {
    
    if(self = [super initWithConversation:conversation]) {
        
        self.message = [MessageSender createOutMessage:message media:[TL_messageMediaEmpty create] conversation:conversation];
        
        NSMutableArray *entities = [NSMutableArray array];
        
        self.message.message = [self parseEntities:self.message.message entities:entities backstrips:@"```"];
        
        self.message.message = [self parseEntities:self.message.message entities:entities backstrips:@"`"];
        
        self.message.entities = entities;
        
        if(additionFlags & (1 << 4))
            self.message.from_id = 0;
            
        
        if(noWebpage)
            self.message.media = [TL_messageMediaWebPage createWithWebpage:[TL_webPageEmpty createWithN_id:0]];
        
        [self.message save:YES];
    
    }

    return self;
}

-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    if(self = [self initWithMessage:message forConversation:conversation noWebpage:YES additionFlags:additionFlags]) {
        
    }
    
    return self;
}


-(SendingQueueType)sendingQueue {
    return SendingQueueMessage;
}

-(void)performRequest {
    
    id request;
    
    
    
    if(self.conversation.type != DialogTypeBroadcast) {
        
        request = [TLAPI_messages_sendMessage createWithFlags:[self senderFlags] peer:[self.conversation inputPeer] reply_to_msg_id:self.message.reply_to_msg_id message:[self.message message] random_id:[self.message randomId] reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:nil] entities:self.message.entities];
    } else {
        
        TL_broadcast *broadcast = self.conversation.broadcast;
        
        request = [TLAPI_messages_sendBroadcast createWithContacts:[broadcast inputContacts] random_id:[broadcast generateRandomIds] message:self.message.message media:[TL_inputMediaEmpty create]];
    }
    
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_updateShortSentMessage *response) {
        
        
        [self updateMessageId:response];

        if([response isKindOfClass:[TL_updates class]]) {
            
            response = (TL_updateShortSentMessage *)[[self updateNewMessageWithUpdates:response] message];
            
            
        }
        
        if(self.conversation.type != DialogTypeBroadcast)  {
             self.message.n_id = response.n_id;
             self.message.date = response.date;
             self.message.media = response.media;
             self.message.entities = response.entities;
        }
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;
        
        
        
        if([self.message.media isKindOfClass:[TL_messageMediaWebPage class]])
        {
            [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:@{@(self.message.peer_id):@[@(self.message.n_id)]},KEY_WEBPAGE:self.message.media.webpage}];
        }
        
        if(self.message.entities.count > 0) {
             [Notification perform:UPDATE_MESSAGE_ENTITIES data:@{KEY_MESSAGE:self.message}];
        }

        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    }];
    
}


-(NSString *)parseEntities:(NSString *)message entities:(NSMutableArray *)entities backstrips:(NSString *)backstrips {
    
    NSRange startRange = [message rangeOfString:backstrips];
    
    if(startRange.location != NSNotFound) {
        
        NSRange stopRange = [message rangeOfString:backstrips options:0 range:NSMakeRange(startRange.location + startRange.length, message.length - (startRange.location + startRange.length ))];
        
        if(stopRange.location != NSNotFound) {
            
            TLMessageEntity *entity;
            
            if(backstrips.length == 3) {
                entity = [TL_messageEntityPre createWithOffset:(int)startRange.location length:(int)(stopRange.location - startRange.location - startRange.length) language:@""];
            } else
                entity = [TL_messageEntityCode createWithOffset:(int)startRange.location length:(int)(stopRange.location - startRange.location - startRange.length)];
            
            [entities addObject:entity];
            
            
        
            message = [message stringByReplacingOccurrencesOfString:backstrips withString:@"" options:0 range:NSMakeRange(startRange.location, stopRange.location + stopRange.length  - startRange.location)];
            
            if(message.length > 0) {
                
                
                int others = 0;
                if([[message substringToIndex:1] isEqualToString:@"\n"]) {
                    message = [message substringFromIndex:1];
                    others = 1;
                }
                
                
                [entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if(obj.offset > stopRange.location + stopRange.length) {
                        obj.offset-=((int)stopRange.length*2);
                    }
                    
                    if(obj.offset > 0) {
                        obj.offset-=others;
                    }
                    
                }];
                
                if([message rangeOfString:backstrips].location != NSNotFound) {
                    return [self parseEntities:message entities:entities backstrips:backstrips];
                }
            }
            
            
            
        }
        
        
        
    }
    
    return message;
    
}


-(void)resend {
    
}

/*
 self.message.message = @"Hello, world!";
 
 NSMutableArray *items = [NSMutableArray array];
 
 [items addObject:[TL_messageEntityBold createWithOffset:0 length:5]];
 [items addObject:[TL_messageEntityItalic createWithOffset:7 length:6]];
 
 self.message.entities = items;
 */

@end
