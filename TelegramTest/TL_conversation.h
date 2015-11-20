//
//  TL_conversation.h
//  Messenger for Telegram
//
//  Created by keepcoder on 11.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"
#import "TL_broadcast.h"


@protocol TLConversationDelegate <NSObject>

@required
-(void)willChangeValue;
-(void)didChangeValue;

@end

@class TL_localMessage;

@interface TL_conversation : TLDialog

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

-(int)universalTopMessage;


@property (nonatomic,assign,getter=isInvisibleChannel) BOOL invisibleChannel;

@property (nonatomic,strong) TL_localMessage *lastMessage;

+ (TL_conversation *)createWithPeer:(TLPeer *)peer top_message:(int)top_message unread_count:(int)unread_count last_message_date:(int)last_message_date notify_settings:(TLPeerNotifySettings *)notify_settings last_marked_message:(int)last_marked_message top_message_fake:(int)top_message_fake last_marked_date:(int)last_marked_date sync_message_id:(int)sync_message_id read_inbox_max_id:(int)read_inbox_max_id unread_important_count:(int)unread_important_count lastMessage:(TL_localMessage *)lastMessage;

+ (TL_conversation *)createWithPeer:(TLPeer *)peer top_message:(int)top_message unread_count:(int)unread_count last_message_date:(int)last_message_date notify_settings:(TLPeerNotifySettings *)notify_settings last_marked_message:(int)last_marked_message top_message_fake:(int)top_message_fake last_marked_date:(int)last_marked_date sync_message_id:(int)sync_message_id read_inbox_max_id:(int)read_inbox_max_id unread_important_count:(int)unread_important_count lastMessage:(TL_localMessage *)lastMessage pts:(int)pts isInvisibleChannel:(BOOL)invisibleChannel top_important_message:(int)top_important_message;

- (void)save;
- (BOOL) isAddToList;
- (BOOL)canSendMessage;
- (NSString *)blockedText;

- (TL_broadcast *)broadcast;

- (BOOL)isMute;
- (void)muteOrUnmute:(dispatch_block_t)completeHandler until:(int)until;
- (void)unmute:(dispatch_block_t)completeHandler;
- (void)mute:(dispatch_block_t)completeHandler;

- (void)updateNotifySettings:(TLPeerNotifySettings *)notify_settings;

-(int)peer_id;

typedef enum {
    DialogTypeUser = 0,
    DialogTypeChat = 1,
    DialogTypeSecretChat = 2,
    DialogTypeBroadcast = 3,
    DialogTypeChannel = 4
} DialogType;

-(id)inputPeer;
-(void)setUnreadCount:(int)unread_count;
-(NSPredicate *)predicateForPeer;
-(void)addUnread;
-(void)subUnread;

- (TLChat *) chat;
- (TL_encryptedChat *) encryptedChat;
- (TLUser *) user;
- (TLChatFull *)fullChat;

- (NSUInteger)cacheHash;
- (NSString *)cacheKey;

-(BOOL)canEditConversation;

-(long)channel_top_message_id;
-(long)channel_top_important_message_id;
- (DialogType) type;

-(BOOL)isVerified;

//channel methods
-(BOOL)canSendChannelMessageAsAdmin;
-(BOOL)canSendChannelMessageAsUser;
@end
