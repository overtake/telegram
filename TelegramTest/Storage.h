//
//  Storage.h
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "TGDcAuth.h"
#import "EncryptedParams.h"
#import "YapDatabase.h"
#import "Destructor.h"
#import "ITaskRequest.h"
#import "TGUpdateState.h"
#import "TGSecretInAction.h"

#import "TGSecretAction.h"
#import "ASQueue.h"
#import "SSignalKit.h"
#import "TGMessageHole.h"
#import "TGHistoryResponse.h"
@interface Storage : NSObject
{
 //   FMDatabase *db;
    FMDatabaseQueue *queue;
    FMDatabaseQueue *authQueue;
}

extern NSString *const ENCRYPTED_IMAGE_COLLECTION;
extern NSString *const ENCRYPTED_PARAMS_COLLECTION;
extern NSString *const STICKERS_COLLECTION;
extern NSString *const SOCIAL_DESC_COLLECTION;
extern NSString *const REPLAY_COLLECTION;
extern NSString *const FILE_NAMES;
extern NSString *const ATTACHMENTS;
extern NSString *const BOT_COMMANDS;
extern NSString *const RECENT_SEARCH;
-(void)drop:(void (^)())completeHandler;
+(void)drop;
+(void)open:(void (^)())completeHandler;

+(Storage *)manager;
+(void)initManagerWithCallback:(dispatch_block_t)callback;
+(YapDatabaseConnection *)yap;

+(NSString *)path;

+(BOOL)isInitialized;

// START MESSAGE AND DIALOGS PROCEDURES!!!


-(TGUpdateState *)updateState;
-(void)saveUpdateState:(TGUpdateState *)state;
-(void)messages:(void (^)(NSArray *))completeHandler forIds:(NSArray *)ids random:(BOOL)random queue:(ASQueue *)q;
-(void)messages:(void (^)(NSArray *))completeHandler forIds:(NSArray *)ids random:(BOOL)random sync:(BOOL)sync queue:(ASQueue *)q;
-(NSArray *)issetMessages:(NSArray *)ids;


-(void)insertMessages:(NSArray *)messages;
-(void)insertMessages:(NSArray *)messages completeHandler:(dispatch_block_t)completeHandler;
-(void)updateChannelMessageViews:(long)channelMsgId views:(int)views;

-(void)deleteMessages:(NSArray *)messages completeHandler:(void (^)(NSArray *peer_update_data))completeHandler;
-(void)deleteMessagesWithRandomIds:(NSArray *)messages isChannelMessages:(BOOL)isChannelMessages completeHandler:(void (^)(NSArray *peer_update_data))completeHandler;
-(void)deleteChannelMessages:(NSArray *)messages completeHandler:(void (^)(NSArray *peer_update_data, NSDictionary *readCount))completeHandler;
-(void)markMessagesAsRead:(NSArray *)messages useRandomIds:(NSArray *)randomIds;
-(void)lastMessageWithConversation:(TL_conversation *)conversation completeHandler:(void (^)(TL_localMessage *message, int importantMessage))completeHandler;

// end messages
-(void)deleteMessagesInDialog:(TL_conversation *)dialog completeHandler:(dispatch_block_t)completeHandler;


+ (NSMutableDictionary *)inputTextForPeers;
+ (void)saveInputTextForPeers:(NSMutableDictionary *)dictionary;


+ (NSMutableArray *)emoji;
+ (void)saveEmoji:(NSMutableArray *)emoji;

-(void)insertDialogs:(NSArray *)dialogs;


-(void)insertBroadcast:(TL_broadcast *)broadcast;
-(void)deleteBroadcast:(TL_broadcast *)broadcast;
-(void)broadcastList:(void (^)(NSArray *list))completeHandler;


-(void)deleteDialog:(TL_conversation *)dialog completeHandler:(void (^)(void))completeHandler;

-(void)loadChats:(void (^)(NSArray *chats))completeHandler;


- (void)searchDialogsByPeers:(NSArray *)peers needMessages:(BOOL)needMessages searchString:(NSString *)searchString completeHandler:(void (^)(NSArray *dialogs))completeHandler;


-(void)dialogsWithOffset:(int)offset limit:(int)limit completeHandler:(void (^)(NSArray *d))completeHandler;
;
-(void)updateTopMessage:(TL_conversation *)dialog completeHandler:(void (^)(BOOL result))completeHandler;

-(void)insertChats:(NSArray *)chats completeHandler:(void (^)(BOOL result))completeHandler;
-(void)insertChat:(TLChat *)chat completeHandler:(void (^)(BOOL result))completeHandler;


-(void)chats:(void (^)(NSArray *result))completeHandler;
// END MESSAGE AND DIALOGS PROCEDURES!!!


- (void)insertUser:(TLUser *)user completeHandler:(void (^)(BOOL result))completeHandler;
- (void)insertUsers:(NSArray *)users completeHandler:(void (^)(BOOL result))completeHandler;
- (void)users:(void (^)(NSArray *result))completeHandler;


-(void)insertContacst:(NSArray *)contacts;

-(void)contacts:(void (^)(NSArray *))completeHandler;
-(void)dropContacts;

-(void)insertSession:(NSData*)session completeHandler:(void (^)(void))completeHandler;

-(void)sessions:(void (^)(NSArray *result))completeHandler;
-(void)destroySessions;



-(void)fullChats:(void (^)(NSArray *chats))completeHandler;
-(void)insertFullChat:(TLChatFull *)fullChat completeHandler:(void (^)(void))completeHandler;
-(void)chatFull:(int)n_id completeHandler:(void (^)(TLChatFull *chat))completeHandler;



-(void)importedContacts:(void (^)(NSSet *imported))completeHandler;
-(void)insertImportedContacts:(NSSet *)result;
-(void)deleteImportedContacts:(NSSet *)result;


-(void)unreadCount:(void (^)(int count))completeHandler includeMuted:(BOOL)includeMuted;

-(void)markAllInConversation:(int)peer_id;

-(void)markAllInConversation:(int)peer_id max_id:(int)max_id out:(BOOL)n_out completeHandler:(void (^)(NSArray * ids))completeHandler;

-(void)insertEncryptedChat:(TLEncryptedChat *)chat;



-(TGHistoryResponse *)loadMessages:(int)conversationId min_id:(int)min_id max_id:(int)max_id minDate:(int)minDate maxDate:(int)maxDate limit:(int)limit next:(BOOL)next  filterMask:(int)mask isChannel:(BOOL)isChannel;

-(TGHistoryResponse *)loadChannelMessages:(int)conversationId min_id:(int)min_id max_id:(int)max_id minDate:(int)minDate maxDate:(int)maxDate limit:(int)limit filterMask:(int)mask important:(BOOL)important next:(BOOL)next;

-(void)invalidateChannelMessagesWithPts:(int)pts;
-(void)validateChannelMessages:(NSArray *)messages;

-(void)updateMessageViews:(int)views channelMsgId:(long)channelMsgId;

-(void)markChannelMessagesAsRead:(int)channel_id max_id:(int)max_id callback:(void (^)(int unread_count))callback;
-(void)updateTopMessagesWithMessages:(NSDictionary *)topMessages topImportantMessages:(NSDictionary *)topImportantMessages;

-(TL_localMessage *)lastImportantMessageAroundMinId:(long)channelMsgId;
-(TL_localMessage *)lastMessageAroundMinId:(long)channelMsgId important:(BOOL)important isTop:(BOOL)isTop;
-(TL_localMessage *)messageById:(int)msgId inChannel:(int)channel_id;


-(TL_localMessage *)messageById:(int)msgId;


-(void)updateUsersStatus:(NSArray *)users;

-(void)addUserPhoto:(int)user_id media:(TLUserProfilePhoto *)photo;
-(void)deleteUserPhoto:(int)user_id;
-(void)countOfUserPhotos:(int)user_id;

-(void)media:(void (^)(NSArray *))completeHandler max_id:(int)max_id filterMask:(int)filterMask peer:(TLPeer *)peer next:(BOOL)next limit:(int)limit;

-(int)countOfMedia:(int)peer_id;

-(void)pictures:(void (^)(NSArray *))completeHandler forUserId:(int)user_id;

- (void) removeContact:(TLContact *) contact ;
- (void) insertContact:(TLContact *) contact;

-(void)insertBlockedUsers:(NSArray *)users;
-(void)deleteBlockedUsers:(NSArray *)users;
-(void)blockedList:(void (^)(NSArray *users))completeHandler;




-(void)insertTask:(id<ITaskRequest>)task;
-(void)removeTask:(id<ITaskRequest>)task;
-(void)selectTasks:(void (^)(NSArray *tasks))completeHandler;

-(TL_conversation *)selectConversation:(TLPeer *)peer;


-(void)conversationsWithPeerIds:(NSArray *)peer_ids completeHandler:(void (^)(NSArray * result))completeHandler;

- (id)fileInfoByPathHash:(NSString *)pathHash;
- (void)findFileInfoByPathHash:(NSString *)pathHash completeHandler:(void (^)(BOOL result, id file))completeHandler;
- (void)setFileInfo:(id)file forPathHash:(NSString *)pathHash;
- (void)deleteFileHash:(NSString *)pathHash;

-(void)messagesWithWebpage:(TLMessageMedia *)mediaWebpage callback:(void (^)(NSDictionary *))callback;


-(void)insertSecretAction:(TGSecretAction *)action;
-(void)removeSecretAction:(TGSecretAction *)action;

-(void)selectAllActions:(void (^)(NSArray *list))completeHandler;


-(void)insertSecretInAction:(TGSecretInAction *)action;
-(void)removeSecretInAction:(TGSecretInAction *)action;

-(void)selectSecretInActions:(int)chat_id completeHandler:(void (^)(NSArray *list))completeHandler;


-(NSArray *)selectSupportMessages:(NSArray *)ids;
-(void)addSupportMessages:(NSArray *)messages;


-(void)updateMessageId:(long)random_id msg_id:(int)n_id;

+(void)addWebpage:(TLWebPage *)webpage forLink:(NSString *)link;
+(TLWebPage *)findWebpage:(NSString *)link;

-(void)readMessagesContent:(NSArray *)messages;


-(NSArray *)conversationsWithIds:(NSArray *)ids;

+(void)updateEncryptionKey:(NSString *)key;

+(void)updateOldEncryptionKey:(NSString *)key;



-(void)insertMessagesHole:(TGMessageHole *)hole;
-(void)removeHole:(TGMessageHole *)hole;
-(NSArray *)groupHoles:(int)peer_id min:(int)min max:(int)max;
-(void)addHolesAroundMessage:(TL_localMessage *)message;
-(int)syncedMessageIdWithPeerId:(int)peer_id important:(BOOL)important latest:(BOOL)latest isChannel:(BOOL)isChannel;
@end