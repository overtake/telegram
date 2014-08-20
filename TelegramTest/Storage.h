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
@interface Storage : NSObject
{
 //   FMDatabase *db;
    FMDatabaseQueue *queue;
    FMDatabaseQueue *authQueue;
}

extern NSString *const ENCRYPTED_IMAGE_COLLECTION;
extern NSString *const ENCRYPTED_PARAMS_COLLECTION;
extern NSString *const FILE_NAMES;
-(void)drop:(void (^)())completeHandler;

+(Storage *)manager;
+(YapDatabaseConnection *)yap;

+(NSString *)path;

// START MESSAGE AND DIALOGS PROCEDURES!!!


- (void)searchMessagesBySearchString:(NSString *)searchString offset:(int)offset completeHandler:(void (^)(NSInteger count, NSArray *messages))completeHandler;

-(TGUpdateState *)updateState;
-(void)saveUpdateState:(TGUpdateState *)state;
-(void)messages:(void (^)(NSArray *))completeHandler forIds:(NSArray *)ids random:(BOOL)random;
-(void)messages:(void (^)(NSArray *))completeHandler forIds:(NSArray *)ids random:(BOOL)random sync:(BOOL)sync;
-(void)insertMessage:(TGMessage *)message completeHandler:(dispatch_block_t)completeHandler;


-(void)insertMessages:(NSArray *)messages completeHandler:(dispatch_block_t)completeHandler;

-(void)deleteMessages:(NSArray *)messages completeHandler:(void (^)(BOOL result))completeHandler;
-(void)deleteMessagesWithRandomIds:(NSArray *)messages completeHandler:(void (^)(BOOL result))completeHandler;

-(void)markMessagesAsRead:(NSArray *)messages completeHandler:(void (^)(BOOL result))completeHandler;
-(void)lastMessageForPeer:(TGPeer *)peer completeHandler:(void (^)(TL_localMessage *message))completeHandler;
// end messages
-(void)deleteMessagesInDialog:(TL_conversation *)dialog completeHandler:(dispatch_block_t)completeHandler;


- (NSMutableDictionary *)inputTextForPeers;
- (void)saveInputTextForPeers:(NSMutableDictionary *)dictionary;


- (NSMutableArray *)emoji;
- (void)saveEmoji:(NSMutableArray *)emoji;


- (void)updateDialog:(TL_conversation *)dialog;

-(void)insertDialogs:(NSArray *)dialogs completeHandler:(void (^)(BOOL result))completeHandler;


-(void)insertBroadcast:(TL_broadcast *)broadcast;
-(void)deleteBroadcast:(TL_broadcast *)broadcast;
-(NSArray *)broadcastList;


-(void)deleteDialog:(TL_conversation *)dialog completeHandler:(void (^)(void))completeHandler;

-(void)loadChats:(void (^)(NSArray *chats))completeHandler;


- (void)dialogByPeer:(int)peer completeHandler:(void (^)(TGDialog *dialog, TGMessage *message))completeHandler;

- (void)searchDialogsByPeers:(NSArray *)peers needMessages:(BOOL)needMessages searchString:(NSString *)searchString completeHandler:(void (^)(NSArray *dialogs, NSArray *messages, NSArray *searchMessages))completeHandler;


-(void)dialogsWithOffset:(int)offset limit:(int)limit completeHandler:(void (^)(NSArray *d, NSArray *m))completeHandler;
;
-(void)updateTopMessage:(TL_conversation *)dialog completeHandler:(void (^)(BOOL result))completeHandler;

-(void)insertChats:(NSArray *)chats completeHandler:(void (^)(BOOL result))completeHandler;
-(void)insertChat:(TGChat *)chat completeHandler:(void (^)(BOOL result))completeHandler;


-(void)chats:(void (^)(NSArray *result))completeHandler;
// END MESSAGE AND DIALOGS PROCEDURES!!!


- (void)insertUser:(TGUser *)user completeHandler:(void (^)(BOOL result))completeHandler;
- (void)insertUsers:(NSArray *)users completeHandler:(void (^)(BOOL result))completeHandler;
- (void)users:(void (^)(NSArray *result))completeHandler;
- (void)updateLastSeen:(TGUser *)user;

-(void)insertContacst:(NSArray *)contacts completeHandler:(void (^)(void))completeHandler;

-(void)contacts:(void (^)(NSArray *))completeHandler;
-(void)dropContacts:(void (^)(void))completeHandler;

-(void)insertSession:(NSData*)session completeHandler:(void (^)(void))completeHandler;

-(void)sessions:(void (^)(NSArray *result))completeHandler;
-(void)destroySessions;



-(void)fullChats:(void (^)(NSArray *chats))completeHandler;
-(void)insertFullChat:(TGChatFull *)fullChat completeHandler:(void (^)(void))completeHandler;
-(void)chatFull:(int)n_id completeHandler:(void (^)(TGChatFull *chat))completeHandler;



-(void)importedContacts:(void (^)(NSDictionary *imported))completeHandler;
-(void)insertImportedContacts:(NSArray *)result completeHandler:(void (^)(void))completeHandler;



-(void)unreadCount:(void (^)(int count))completeHandler;

-(void)markAllInDialog:(TL_conversation *)dialog;

-(void)insertEncryptedChat:(TGEncryptedChat *)chat;


-(void)messages:(TGPeer *)peer max_id:(int)max_id limit:(int)limit next:(BOOL)next filterMask:(int)mask completeHandler:(void (^)(NSArray *))completeHandler;

-(void)loadMessages:(int)conversationId localMaxId:(int)localMaxId limit:(int)limit next:(BOOL)next maxDate:(int)maxDate filterMask:(int)mask completeHandler:(void (^)(NSArray *))completeHandler;
-(TGMessage *)messageById:(int)msgId;
-(void)insertMedia:(TL_localMessage *)message;
-(void)insertUserProfilePhoto:(int)user_id media:(TGUserProfilePhoto *)photo;
-(void)deleteLastUserProfilePhoto:(int)user_id;
-(void)media:(void (^)(NSArray *))completeHandler forPeer:(TGPeer *)peer;
-(void)pictures:(void (^)(NSArray *))completeHandler forUserId:(int)user_id;

- (void) removeContact:(TGContact *) contact completeHandler:(void (^)(void))completeHandler;
- (void) replaceContacts:(NSArray *) contacts completeHandler:(void (^)(void))completeHandler;
- (void) insertContact:(TGContact *) contact completeHandler:(void (^)(void))completeHandler;

//-(void)notifySettings:(void (^)(NSDictionary *))completeHandler;
//-(void)addNotifySetting:(int)peer_id mute_until:(int)mute_until;

-(void)selfDestructorFor:(int)chat_id max_id:(int)max_id completeHandler:(void (^)(Destructor *destructor))completeHandler;

-(void)selfDestructors:(int)chat_id completeHandler:(void (^)(NSArray *destructors))completeHandler;
-(void)selfDestructors:(void (^)(NSArray *destructors))completeHandler;

-(void)insertDestructor:(Destructor *)destructor;
-(void)updateDestructTime:(int)time forMessages:(NSArray *)msgIds;

-(void)insertBlockedUsers:(NSArray *)users;
-(void)deleteBlockedUsers:(NSArray *)users;
-(void)blockedList:(void (^)(NSArray *users))completeHandler;




-(void)insertTask:(id<ITaskRequest>)task;
-(void)removeTask:(id<ITaskRequest>)task;
-(void)selectTasks:(void (^)(NSArray *tasks))completeHandler;

-(TL_conversation *)selectConversation:(TGPeer *)peer;
- (id)fileInfoByPathHash:(NSString *)pathHash;
- (void)findFileInfoByPathHash:(NSString *)pathHash completeHandler:(void (^)(BOOL result, id file))completeHandler;
- (void)setFileInfo:(id)file forPathHash:(NSString *)pathHash;

-(void)updateMessages:(NSArray *)messages;

@end