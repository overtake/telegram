//
//  SenderItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLPeer+Extensions.h"
#import "FileUtils.h"
#import "SenderListener.h"

@interface SenderItem : NSObject {
    
}

typedef enum {
    MessageStateWaitSend = 2,
    MessageStateSending = 4,
    MessageSendingStateSent = 8,
    MessageSendingStateCancelled = 16,
    MessageSendingStateError = 32
} MessageState;


typedef enum {
    SendingQueueNone,
    SendingQueueMessage
} SendingQueueType;

@property (nonatomic,strong) RPCRequest *rpc_request;
@property (nonatomic,assign) float progress;
@property (atomic,assign) MessageState state;



@property (nonatomic,strong) TL_localMessage *message;


@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) MessageTableItem *tableItem;

@property (nonatomic, strong) NSString *filePath;

- (id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags;


- (id)initWithPath:(NSString *)filePath forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags;

-(id)initWithConversation:(TL_conversation *)conversation;

+ (id)senderForMessage:(TL_localMessage *)msg;

-(void)send;


-(void)enumerateEventListeners:(void (^)(id<SenderListener> listener, NSUInteger idx, BOOL *stop))enumerator;
-(void)addEventListener:(id<SenderListener>)listener;
-(void)removeEventListener:(id<SenderListener>)listener;

+(void)appTerminatedNeedSaveSenders;

+(BOOL)allSendersSaved;

-(BOOL)checkErrorAndReUploadFile:(RpcError *)error path:(NSString *)path;

-(void)cancel;
-(void)resend;


-(BOOL)canRelease;

-(int)senderFlags;

-(void)updateMessageId:(TLUpdates *)updates;
-(TL_updateNewMessage *)updateNewMessageWithUpdates:(TLUpdates *)updates;

@end
