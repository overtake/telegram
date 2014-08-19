//
//  SenderItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGMessage+Extensions.h"
#import "TGPeer+Extensions.h"
#import "FileUtils.h"
#import "TGDialog+Extensions.h"
#import "SenderListener.h"
#import "TGMessageCategory.h"

@interface SenderItem : NSObject {
    
}

typedef enum {
    MessageStateWaitSend = 2,
    MessageStateSending = 4,
    MessageSendingStateSent = 8,
    MessageSendingStateCancelled = 16,
    MessageSendingStateError = 32
} MessageState;

@property (nonatomic,strong) RPCRequest *rpc_request;
@property (nonatomic,assign) float progress;
@property (atomic,assign) MessageState state;


@property (nonatomic,strong) TL_localMessage *message;


@property (nonatomic,strong) TL_conversation *dialog;
@property (nonatomic,strong) MessageTableItem *tableItem;

@property (nonatomic, strong) NSString *filePath;

- (id)initWithMessage:(NSString *)message forDialog:(TL_conversation *)dialog;
- (id)initWithPath:(NSString *)filePath forDialog:(TL_conversation *)dialog;

+ (id)senderForMessage:(TL_localMessage *)msg;

-(void)send;

-(void)addEventListener:(id<SenderListener>)listener;
-(void)removeEventListener:(id<SenderListener>)listener;

+(void)appTerminatedNeedSaveSenders;

+(BOOL)allSendersSaved;

-(void)performRequest;

-(void)cancel;
-(void)resend;
@end
