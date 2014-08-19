
//
//  SenderItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"
#import "MessageTableItem.h"

@interface SenderItem ()
@property (nonatomic,strong) NSMutableArray *listeners;
@end

@implementation SenderItem

- (id)initWithTempPath:(NSData *)temp_path_to_file path_to_file:(NSString *)path_to_file forDialog:(TL_conversation *)dialog {    if(self = [super init]) {
        [NSException raise:@"Fatal error" format:@"Can't use (%@) this class for send message with data",NSStringFromClass([self class])];
    }
    return self;
}

- (id)initWithPath:(NSString *)path_for_file forDialog:(TL_conversation *)dialog {
    if(self = [super init]) {
        [NSException raise:@"Fatal sending error" format:@"Can't use (%@) this class class for send message with file path",NSStringFromClass([self class])];
    }
    return self;
}

- (id)initWithMessage:(NSString *)message forDialog:(TL_conversation *)dialog {
    if(self = [super init]) {
        [NSException raise:@"Fatal sending error" format:@"Can't use (%@) this class class for send message with file path",NSStringFromClass([self class])];
    }
    return self;
}

+ (id)senderForMessage:(TL_localMessage *)msg {
    
    SenderItem *item;
    
    if(![msg isKindOfClass:[TL_destructMessage class]]) {
        if([msg.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            item = [[MessageSenderItem alloc] init];
        } else if([msg.media isKindOfClass:[TL_messageMediaPhoto class]]) {
            item = [[ImageSenderItem alloc] init];
        } else if([msg.media isKindOfClass:[TL_messageMediaVideo class]]) {
            item = [[VideoSenderItem alloc] init];
        } else if([msg.media isKindOfClass:[TL_messageMediaDocument class]]) {
            item = [[DocumentSenderItem alloc] init];
        } else if([msg.media isKindOfClass:[TL_messageMediaAudio class]]) {
            item = [[AudioSenderItem alloc] init];
        } else if([msg.media isKindOfClass:[TL_messageMediaContact class]]) {
            item = [[ShareContactSenterItem alloc] init];
        }
        
        if([msg isKindOfClass:[TL_localMessageForwarded class]]) {
            item = [[ForwardSenterItem alloc] init];
            
            ((ForwardSenterItem *)item).fakes = @[msg];
            ((ForwardSenterItem *)item).msg_ids = [NSMutableArray arrayWithObject:@([(TL_localMessageForwarded *)msg fwd_n_id])];
        }
        
    } else {
        if([msg.media isKindOfClass:[TL_messageMediaEmpty class]])
            item = [[MessageSenderSecretItem alloc] init];
        else {
            item = [[FileSecretSenderItem alloc] init];
            
            if([msg.media isKindOfClass:[TL_messageMediaPhoto class]]) {
                [(FileSecretSenderItem *)item setUploaderType:UploadImageType];
            } else if([msg.media isKindOfClass:[TL_messageMediaVideo class]]) {
                 [(FileSecretSenderItem *)item setUploaderType:UploadVideoType];
            } else if([msg.media isKindOfClass:[TL_messageMediaDocument class]]) {
                 [(FileSecretSenderItem *)item setUploaderType:UploadDocumentType];
            } else if([msg.media isKindOfClass:[TL_messageMediaAudio class]]) {
                 [(FileSecretSenderItem *)item setUploaderType:UploadAudioType];
            }
        }
        
    }
    
    
    item.message = msg;
    item.dialog = msg.dialog;
    
    return item;
}


static NSMutableArray *waiting;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        waiting = [[NSMutableArray alloc] init];
    });
}

-(void)setState:(MessageState)state {
    self->_state = state;
    [LoopingUtils runOnMainQueueAsync:^{
        [self notifyAllListeners:@selector(onStateChanged:)];
        
        if(state == MessageSendingStateSent || state == MessageSendingStateError || state == MessageSendingStateCancelled) {
            [self removeAllListeners];
            self.rpc_request = nil;
            
            if(state == MessageSendingStateError) {
                if(self.message.dstate != DeliveryStateError) {
                    self.message.dstate = DeliveryStateError;
                    [self.message save:YES];
                }
                
                
                if([self isKindOfClass:[ForwardSenterItem class]]) {
                    ForwardSenterItem *sender = (ForwardSenterItem *) self;
                    [sender.fakes enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
                        if(obj.dstate != DeliveryStateError) {
                            obj.dstate = DeliveryStateError;
                            [obj save:idx == sender.fakes.count-1];
                        }
                    }];
                }
            }
            
            
            if(state == MessageSendingStateError && self.dialog.type == DialogTypeSecretChat) {
                if(self.rpc_request.error.error_code == 400) {
                    EncryptedParams *params = [EncryptedParams findAndCreate:self.dialog.peer.peer_id];
                    
                    [params setState:EncryptedDiscarted];
                    
                    [params save];
                }
            }
        }
        
        
        [ASQueue dispatchOnStageQueue:^{
            if(state == MessageStateSending) {
                [waiting addObject:self];
            }
            
            if(state == MessageSendingStateSent) {
                [waiting removeObject:self];
            }
        } synchronous:YES];
    }];
}



+(void)appTerminatedNeedSaveSenders {
    [ASQueue dispatchOnStageQueue:^{
        [waiting enumerateObjectsUsingBlock:^(SenderItem *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.state != MessageSendingStateCancelled) {
               
                if(![obj isKindOfClass:[ForwardSenterItem class]]) {
                    
                    obj.message.dstate = DeliveryStateError;
                    [obj.message save:NO];
                } else {
                    ForwardSenterItem *f = (ForwardSenterItem *)obj;
                    
                    [f.fakes enumerateObjectsUsingBlock:^(TL_localMessage *msg, NSUInteger idx, BOOL *stop) {
                        msg.dstate = DeliveryStateError;
                        [msg save:NO];
                    }];
                }
                
            }
        }];
        
        [waiting removeAllObjects];
    }];
    
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

+(BOOL)allSendersSaved {
    
    __block NSUInteger count = 0;
    
    [ASQueue dispatchOnStageQueue:^{
        count = waiting.count;
    } synchronous:YES];
    
    
    return count == 0;
}

-(void)setProgress:(float)progress {
    self->_progress = progress;
    [LoopingUtils runOnMainQueueAsync:^{
        [self notifyAllListeners:@selector(onProgressChanged:)];
    }];
    
}

-(void)notifyAllListeners:(SEL)selector {
    NSArray *copy = [self.listeners copy];
    for (id<SenderListener> current in copy) {
        if([current respondsToSelector:selector])
            [current performSelector:selector withObject:self];
    }
}

-(void)setTableItem:(MessageTableItem *)tableItem {
    self->_tableItem = tableItem;
    tableItem.messageSender = self;
}


-(void)addEventListener:(id<SenderListener>)listener {
     [LoopingUtils runOnMainQueueAsync:^{
         if(!self.listeners)
             self.listeners = [[NSMutableArray alloc] init];
         if([self.listeners indexOfObject:listener] == NSNotFound)
             [self.listeners addObject:listener];
         
         [self notifyAllListeners:@selector(onAddedListener:)];
     }];
}

-(void)removeAllListeners {
    [self notifyAllListeners:@selector(onRemovedListener:)];
    
    [self.listeners removeAllObjects];
}

-(void)removeEventListener:(id<SenderListener>)listener {
     [LoopingUtils runOnMainQueueAsync:^{
         [self.listeners removeObject:listener];
         
         [self notifyAllListeners:@selector(onRemovedListener:)];
         
     }];
}




-(void)dealloc {
    [self removeAllListeners];
}

-(void)send {
    if(self.state != MessageStateSending && self.state != MessageSendingStateSent) {
        self.state = MessageStateSending;
        self.message.dstate = DeliveryStatePending;
        [self performRequest];
    }
}


-(void)performRequest {
    [NSException raise:@"Fatal sending error" format:@"for send message use @selector@(send) method"];
}

-(void)cancel {
    self.progress = 0;
    [self.rpc_request cancelRequest];
    self.state = MessageSendingStateCancelled;
}
-(void)resend {
    
}
@end
