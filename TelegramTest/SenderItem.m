
//
//  SenderItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"
#import "MessageTableItem.h"
#import "StickerSenderItem.h"
#import "WeakReference.h"
#import "MessageTableCell.h"
@interface SenderItem ()
@property (nonatomic,strong) NSMutableArray *listeners;
@end

@implementation SenderItem


static NSMutableDictionary *senders;

- (id)initWithTempPath:(NSData *)temp_path_to_file path_to_file:(NSString *)path_to_file forConversation:(TL_conversation *)conversation {    if(self = [super init]) {
        [NSException raise:@"Fatal error" format:@"Can't use (%@) this class for send message with data",NSStringFromClass([self class])];
    }
    return self;
}

- (id)initWithPath:(NSString *)path_for_file forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    if(self = [super init]) {
        [NSException raise:@"Fatal sending error" format:@"Can't use (%@) this class class for send message with file path",NSStringFromClass([self class])];
    }
    return self;
}

- (id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags  {
    if(self = [super init]) {
        [NSException raise:@"Fatal sending error" format:@"Can't use (%@) this class class for send message with file path",NSStringFromClass([self class])];
    }
    return self;
}




-(id)initWithConversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        self.conversation = conversation;
    }
    
    return self;
}

-(id)init {
    if(self = [super init]) {
        self.state = MessageStateWaitSend;
        self.listeners = [[NSMutableArray alloc] init];
        
        
        
    }
    
    return self;
}

-(void)setMessage:(TL_localMessage *)message {
    _message = message;
    
    [ASQueue dispatchOnStageQueue:^{
        
        senders[@(_message.randomId)] = self;
        
    }];
}

+ (id)senderForMessage:(TL_localMessage *)msg {
    
     __block SenderItem *item;
    
    [ASQueue dispatchOnStageQueue:^{
        
        item = senders[@(msg.randomId)];
        
        if(!item) {
            if(![msg isKindOfClass:[TL_destructMessage class]]) {
                if([msg.media isKindOfClass:[TL_messageMediaEmpty class]] || msg.media == nil) {
                    item = [[MessageSenderItem alloc] init];
                } else if([msg.media isKindOfClass:[TL_messageMediaPhoto class]]) {
                    item = [[ImageSenderItem alloc] init];
                } else if([msg.media isKindOfClass:[TL_messageMediaVideo class]]) {
                    item = [[VideoSenderItem alloc] init];
                } else if([msg.media isKindOfClass:[TL_messageMediaDocument class]]) {
                    
                    item = [[DocumentSenderItem alloc] init];
                    
                    if([msg.media.document isSticker] && [msg.media.document isExist]) {
                        item = [[StickerSenderItem alloc] init];
                    }
                    
                    
                    
                } else if([msg.media isKindOfClass:[TL_messageMediaAudio class]]) {
                    item = [[AudioSenderItem alloc] init];
                } else if([msg.media isKindOfClass:[TL_messageMediaContact class]]) {
                    item = [[ShareContactSenterItem alloc] init];
                }
                
                if(msg.fwd_from_id != 0) {
                    item = [[ForwardSenterItem alloc] init];
                    
                    ((ForwardSenterItem *)item).fakes = @[msg];
                    ((ForwardSenterItem *)item).msg_ids = [NSMutableArray arrayWithObject:@([msg n_id])];
                }
                
            } else {
                if(msg.class == [TL_destructMessage class]) {
                    if([msg.media isKindOfClass:[TL_messageMediaEmpty class]] || msg.media == nil)
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
                
            }
            
            
            item.conversation = msg.conversation;
            item.message = msg;
            
            item.state = msg.dstate == DeliveryStateError ? MessageSendingStateError : MessageStateWaitSend;
        }
        
    } synchronous:YES];
    
    
    
    return item;
}

static NSMutableArray *queue;
static NSMutableArray *waiting;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        waiting = [[NSMutableArray alloc] init];
        queue = [[NSMutableArray alloc] init];
        senders = [[NSMutableDictionary alloc] init];
    });
}

-(void)setState:(MessageState)state {
    self->_state = state;
    
    
    [ASQueue dispatchOnMainQueue:^{
        [self notifyAllListeners:@selector(onStateChanged:)];
        
        if(state == MessageSendingStateSent || state == MessageSendingStateError || state == MessageSendingStateCancelled) {
            [self removeAllListeners];
            
            [ASQueue dispatchOnStageQueue:^{
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
                
                
                if(state == MessageSendingStateError && self.conversation.type == DialogTypeSecretChat) {
                    if(self.rpc_request.error.error_code == 400) {
                        EncryptedParams *params = [EncryptedParams findAndCreate:self.conversation.peer.peer_id];
                        
                        [params setState:EncryptedDiscarted];
                        
                        [params save];
                    }
                }
            }];
        }
        
        
        [ASQueue dispatchOnStageQueue:^{
            if(state == MessageStateSending) {
                [waiting addObject:self];
            }
            
            if(state == MessageSendingStateSent || state == MessageSendingStateCancelled) {
                [waiting removeObject:self];
                [senders removeObjectForKey:@(_message.randomId)];
            }

        }];
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
                        if(msg.class != [TL_secretServiceMessage class]) {
                            msg.dstate = DeliveryStateError;
                            [msg save:NO];
                        }
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
    [ASQueue dispatchOnMainQueue:^{
        [self notifyAllListeners:@selector(onProgressChanged:)];
    }];
    
}

-(void)notifyAllListeners:(SEL)selector {
    
    assert([NSThread isMainThread]);
    
    [_listeners enumerateObjectsUsingBlock:^(WeakReference *current, NSUInteger idx, BOOL * _Nonnull stop) {
        id<SenderListener>listener = current.nonretainedObjectValue;
        
        if([listener respondsToSelector:selector])
            [listener performSelector:selector withObject:self];
    }];
    
}

-(void)setTableItem:(MessageTableItem *)tableItem {
    self->_tableItem = tableItem;
    tableItem.messageSender = self;
}

-(NSUInteger)indexOfListener:(id<SenderListener>)listener {
    
    
    assert([NSThread isMainThread]);
    __block NSUInteger index = NSNotFound;
    
    [_listeners enumerateObjectsUsingBlock:^(WeakReference *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.nonretainedObjectValue == (__bridge void *)(listener)) {
            index = idx;
            *stop = YES;
        }
        
    }];
    
    return index;
}


-(void)addEventListener:(id<SenderListener>)listener {
     [ASQueue dispatchOnMainQueue:^{
         if(!self.listeners)
             self.listeners = [[NSMutableArray alloc] init];
         if([self indexOfListener:listener] == NSNotFound)
             [self.listeners addObject:[WeakReference weakReferenceWithObject:listener]];
         
         [self notifyAllListeners:@selector(onAddedListener:)];
     }];
}

-(void)enumerateEventListeners:(void (^)(id<SenderListener> listener, NSUInteger idx, BOOL *stop))enumerator {
    [ASQueue dispatchOnMainQueue:^{
        NSArray *copy = [self.listeners copy];
        
        [copy enumerateObjectsUsingBlock:^(WeakReference *obj, NSUInteger idx, BOOL *stop) {
            enumerator(obj.nonretainedObjectValue,idx,stop);
        }];
    }];
}

-(void)removeAllListeners {
    
    assert([NSThread isMainThread]);
    
    NSArray *copy = [_listeners copy];
    
    [_listeners removeAllObjects];
    
    [copy enumerateObjectsUsingBlock:^(WeakReference *current, NSUInteger idx, BOOL * _Nonnull stop) {
        id<SenderListener>listener = current.nonretainedObjectValue;
        
        if([listener respondsToSelector:@selector(onRemovedListener:)])
            [listener performSelector:@selector(onRemovedListener:) withObject:self];
    }]; 
    
}

-(void)removeEventListener:(id<SenderListener>)listener {
     [ASQueue dispatchOnMainQueue:^{
         
         NSUInteger idx = [self indexOfListener:listener];
         
         if(idx != NSNotFound)
             [self.listeners removeObjectAtIndex:idx];
         
         [self notifyAllListeners:@selector(onRemovedListener:)];
         
     }];
}

-(BOOL)checkErrorAndReUploadFile:(RpcError *)error path:(NSString *)path {
    
    [[Storage manager] deleteFileHash:fileMD5(path)];
    
    if([error.error_msg isEqualToString:[NSString stringWithFormat:@"FILE_PART_%d_MISSING",error.resultId]]) {
        
        self.state = MessageStateWaitSend;
        
        [self send];
        
        return YES;
    }

    return NO;
}





-(void)perform {
    self.state = MessageStateSending;
    self.message.dstate = DeliveryStatePending;
    
    [self performRequest];
}

-(void)send {
    
    [ASQueue dispatchOnStageQueue:^{
        
        if(self.state != MessageStateSending && self.state != MessageSendingStateSent) {
            [self perform];
        }
        
    }];
    
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

-(void)updateMessageId:(TLUpdates *)updates {
    
    if([updates isKindOfClass:[TL_updates class]]) {
        NSArray *updateMessageIdUpdate = [[updates updates] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.className == %@",NSStringFromClass([TL_updateMessageID class])]];
        
        if(updateMessageIdUpdate.count > 0) {
            self.message.n_id = [(TL_updateMessageID *)updateMessageIdUpdate[0] n_id];
        }
    }
    
}

-(int)senderFlags {
    int flags = 0;
    
    flags|= self.message.reply_to_msg_id != 0 ? 1 : 0;
    
    flags|=[self.message.media.webpage isKindOfClass:[TL_webPageEmpty class]] ? 2 : 0;
    
    flags|=self.message.from_id == 0 ? 1 << 4 : 0;
    
    if(self.message.entities.count > 0)
        flags|= 1 << 3;
    
    return flags;
}

-(TL_updateNewMessage *)updateNewMessageWithUpdates:(TLUpdates *)updates {
    
    __block id update;
    
    [updates.updates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[TL_updateNewMessage class]] || [obj isKindOfClass:[TL_updateNewChannelMessage class]]) {
            update = obj;
            *stop = YES;
        } 
        
    }];
    
    return update;
    
}

-(BOOL)canRelease {
    
    __block BOOL c = YES;
    
    [ASQueue dispatchOnMainQueue:^{
        
        [_listeners enumerateObjectsUsingBlock:^(WeakReference *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.nonretainedObjectValue isKindOfClass:[MessageTableCell class]]) {
                c = NO;
                *stop = YES;
            }
        }];
        
        c = _listeners.count == 0;
    } synchronous:YES];
    
    return c;
}

@end
