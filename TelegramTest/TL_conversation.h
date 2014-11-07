//
//  TL_conversation.h
//  Messenger for Telegram
//
//  Created by keepcoder on 11.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLRPC.h"
#import "TGDialog+Extensions.h"
#import "TL_broadcast.h"
@interface TL_conversation : TGDialog

typedef enum {
    DeliveryStateNormal = 1 << 1,
    DeliveryStatePending = 1 << 2,
    DeliveryStateError = 1 << 3
    
} DeliveryState;

@property (nonatomic) int last_message_date;
@property (nonatomic) int last_marked_message;
@property (nonatomic) int last_marked_date;
@property (nonatomic) int top_message_fake;
@property (nonatomic) int last_real_message_date;
@property (nonatomic) BOOL fake;
@property (nonatomic) DeliveryState dstate;
@property (nonatomic) int sync_message_id;

+ (TL_conversation *)createWithPeer:(TGPeer *)peer top_message:(int)top_message unread_count:(int)unread_count last_message_date:(int)last_message_date notify_settings:(TGPeerNotifySettings *)notify_settings last_marked_message:(int)last_marked_message top_message_fake:(int)top_message_fake last_marked_date:(int)last_marked_date;

- (void)save;
- (BOOL) isAddToList;
- (BOOL)canSendMessage;
- (NSString *)blockedText;

- (TL_broadcast *)broadcast;

- (BOOL)isMute;
- (void)muteOrUnmute:(dispatch_block_t)completeHandler;
- (void)unmute:(dispatch_block_t)completeHandler;
- (void)mute:(dispatch_block_t)completeHandler;

- (void)updateNotifySettings:(TGPeerNotifySettings *)notify_settings;

-(int)peer_id;

@end
