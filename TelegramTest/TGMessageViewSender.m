//
//  TGMessageViewSender.m
//  Telegram
//
//  Created by keepcoder on 18.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGMessageViewSender.h"
#import "TGTimer.h"
#import "TGTLSerialization.h"

@interface TGViewSender : NSObject
{
    TGTimer *timer;
    MTRequest *request;
    NSMutableArray *waitingItems;
}

@end


@implementation TGViewSender

-(instancetype)init {
    if(self = [super init]) {
        waitingItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addItem:(MessageTableItem *)item {
    
    [ASQueue dispatchOnMainQueue:^{
        [waitingItems addObject:item];
        
        [timer invalidate];
        
        [[MTNetwork instance] cancelRequestWithInternalId:request.internalId];
        
        [request setCompleted:nil];
        
        timer = [[TGTimer alloc] initWithTimeout:2 repeat:NO completion:^{
            
            NSArray *items = [waitingItems copy];
            
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            
            TL_conversation *conversation = [(MessageTableItem *)items[0] message].conversation;
            
            [waitingItems enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
                [ids addObject:@(obj.message.n_id)];
            }];
            
            
            request = [[MTRequest alloc] init];
            
            id body = [TLAPI_messages_getMessagesViews createWithPeer:conversation.inputPeer n_id:ids increment:YES];
            
            request.body = body;
            
            
            
            [request setPayload:[TGTLSerialization serializeMessage:body] metadata:body responseParser:^id(NSData *data) {
                
                NSMutableArray *vector = [[NSMutableArray alloc] init];
                
                SerializedData *stream = [[SerializedData alloc] init];
                NSInputStream *inputStream = [[NSInputStream alloc] initWithData:data];
                [inputStream open];
                [stream setInput:inputStream];
                
                int constructor = [stream readInt];
                
                if(constructor  == 481674261) {
                    int count = [stream readInt];
                    for(int i = 0; i < count; i++) {
                        int views = [stream readInt];
                        [vector addObject:@(views)];
                        
                    }
                }
                
                return vector;
                
            }];
            
            weakify();
            
            [request setCompleted:^(NSArray *result, NSTimeInterval t, id error) {
                
                
                [ASQueue dispatchOnMainQueue:^{
                                        
                    [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
                        BOOL needUpdate = obj.message.views != [result[idx] intValue];
                        
                        if([result[idx] intValue] != 0) {
                            obj.message.views = [result[idx] intValue];
                            
                            if(needUpdate) {
                                [obj.message saveViews];
                                [Notification perform:UPDATE_MESSAGE_ITEM data:@{@"item":obj}];
                            }
                        }
                        
                       

                    }];
                    
                    [strongSelf->waitingItems removeObjectsInArray:items];
                    
                }];
                
            }];
            
            [[MTNetwork instance] addRequest:request];
            
            
        } queue:dispatch_get_main_queue()];
        
        [timer start];
    }];
    
    
    
}

@end

@implementation TGMessageViewSender


static NSMutableDictionary *viewChannels;

+(void)initialize {
    viewChannels = [[NSMutableDictionary alloc] init];
}

+(void)addItem:(MessageTableItem *)item {
    
    TGViewSender *sender = viewChannels[@(item.message.peer_id)];
    
    if(!sender) {
        sender = [[TGViewSender alloc] init];
        viewChannels[@(item.message.peer_id)] = sender;
    }
    
    [sender addItem:item];
    
    
    
}

@end
