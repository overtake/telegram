
//
//  Storage.m
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "Storage.h"
#import "TLPeer+Extensions.h"
#import "SSKeychain.h"
#import "SSKeychainQuery.h"
#import "Crypto.h"
#import "LoopingUtils.h"
#import "PreviewObject.h"
#import "HistoryFilter.h"
#import "FMDatabaseAdditions.h"
#import "TGHashContact.h"
#import "NSString+FindURLs.h"
#import "NSData+Extensions.h"
#import "YapDatabase.h"
#import "YapDatabaseManager.h"
@implementation Storage


NSString *const ENCRYPTED_IMAGE_COLLECTION = @"encrypted_image_collection";
NSString *const ENCRYPTED_PARAMS_COLLECTION = @"encrypted_params_collection";
NSString *const STICKERS_COLLECTION = @"stickers_collection_v28";
NSString *const SOCIAL_DESC_COLLECTION = @"social_desc_collection";
NSString *const REPLAY_COLLECTION = @"replay_collection_v2";
NSString *const FILE_NAMES = @"file_names";
NSString *const ATTACHMENTS = @"attachments";
NSString *const BOT_COMMANDS = @"bot_commands_v2";
NSString *const RECENT_SEARCH = @"recent_search";
-(id)init {
    if(self = [super init]) {
        [self open:nil queue:nil];
    }
    return self;
}


static ASQueue *keyQueue;
static Storage *instance;


+(void)initialize {
    keyQueue = [[ASQueue alloc] initWithName:"dbKeyQueue"];
}

+(Storage *)manager {
   
    [keyQueue dispatchOnQueue:^{
        
        if(!instance)
            instance = [[[self class] alloc] init];
        
    } synchronous:YES];
    
    return instance;

}

+(BOOL)isInitialized {
    
    __block BOOL inited = NO;
    
    [keyQueue dispatchOnQueue:^{
        
        inited = instance != nil;
        
    } synchronous:YES];
    
    return inited;
}

+(void)initManagerWithCallback:(dispatch_block_t)callback {
    [keyQueue dispatchOnQueue:^{
        if(!instance)
            instance = [[self alloc] initWithCallback:callback];
    }];
}

-(id)initWithCallback:(dispatch_block_t)callback {
    if(self = [super init]) {
        [self open:callback queue:dispatch_get_current_queue()];
    }
    
    return self;
}

static YapDatabaseConnection *y_connection;
static YapDatabase *y_db;
static NSString *yap_path;
+(YapDatabaseConnection *)yap {
    
    static dispatch_once_t yapToken;
    
    dispatch_once(&yapToken, ^{
        
        yap_path = [NSString stringWithFormat:@"%@/yap_store-%@",[self path], @"t143.sqlite"];
        
        y_db = [[YapDatabase alloc] initWithPath:yap_path];
        y_connection = [y_db newConnection];
    });
    
    return y_connection;
}
+(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = appName();
    NSString *path = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"database"];
    
    if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
    
    }
    return path;
}



static NSString *kEmoji = @"kEmojiNew";


+ (NSMutableArray *)emoji {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:kEmoji];
    return array ? [NSMutableArray arrayWithArray:array] : [NSMutableArray array];
}

+ (void)saveEmoji:(NSMutableArray *)emoji {
    if(!emoji)
        return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:emoji forKey:kEmoji];
    [defaults synchronize];
}

static NSString *kInputTextForPeers = @"kInputTextForPeers";

+ (NSMutableDictionary *)inputTextForPeers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [defaults objectForKey:kInputTextForPeers];
    return dictionary ? [NSMutableDictionary dictionaryWithDictionary:dictionary] : [NSMutableDictionary dictionary];
}

+ (void)saveInputTextForPeers:(NSMutableDictionary *)dictionary {
    if(!dictionary)
        return;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dictionary forKey:kInputTextForPeers];
    [defaults synchronize];
}


NSString *const tableMessages = @"messages";
NSString *const tableChannelMessages = @"channel_messages_v1";
NSString *const tableChats = @"chats";
NSString *const tableUpdateState = @"update_state2";
NSString *const tableUsers = @"users";
NSString *const tableContacts = @"contacts";
NSString *const tableChatsFull = @"chats_full_new";
NSString *const tableImportedContacts = @"imported_contacts";
NSString *const tableEncryptedChats = @"encrypted_chats";
NSString *const tableSelfDestruction = @"self_destruction";
NSString *const tableUserPhotos = @"user_photos";
NSString *const tableBlockedUsers = @"blocked_users";
NSString *const tableTasks = @"tasks";
NSString *const tableFiles = @"files";
NSString *const tableBroadcasts = @"broadcasts";
NSString *const tableOutSecretActions = @"out_secret_actions";
NSString *const tableInSecretActions = @"in_secret_actions";
NSString *const tableSupportMessages = @"support_messages2";
NSString *const tableMessageHoles = @"message_holes_v1";
NSString *const tableMessagesMedia = @"messages_media_v1";
NSString *const tableModernDialogs = @"modern_dialogs";





-(void)open:(void (^)())completeHandler queue:(dispatch_queue_t)dqueue {
    
    if(!dqueue)
        dqueue = dispatch_get_current_queue();
    
    
    NSString *dbPath = [[Storage path] stringByAppendingPathComponent:@"encrypted.sqlite"];
    
    if(!encryptionKey) {
        return;
    }
    
    self->queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];

    
    __block BOOL res = NO;
    
    
    [[Storage yap] flushMemoryWithFlags:YapDatabaseConnectionFlushMemoryFlags_All];

    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db close];
        
        [self createAndCheckDatabase:@"t143.sqlite"];
        
        [db open];
        
                
        res = [db setKey:encryptionKey];
        
        char* errorMessage;

        
        sqlite3_exec(db.sqliteHandle, "PRAGMA synchronous=OFF", NULL, NULL, &errorMessage);
        sqlite3_exec(db.sqliteHandle, "PRAGMA count_changes=OFF", NULL, NULL, &errorMessage);
        sqlite3_exec(db.sqliteHandle, "PRAGMA journal_mode=MEMORY", NULL, NULL, &errorMessage);
        sqlite3_exec(db.sqliteHandle, "PRAGMA temp_store=MEMORY", NULL, NULL, &errorMessage);
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (n_id INTEGER PRIMARY KEY,message_text TEXT, flags integer, from_id integer, peer_id integer, date integer, serialized blob, random_id, destruct_time, filter_mask integer, fake_id integer, dstate integer, webpage_id blob)",tableMessages]];

        
        //messages indexes
        {
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists select_messages_idx ON %@(peer_id,date)",tableMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists peer_idx ON %@(peer_id)",tableMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists date_idx ON %@(date)",tableMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists random_idx ON %@(random_id)",tableMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists peer_flags_idx ON %@(peer_id,flags)",tableMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists fake_id_idx ON %@(fake_id)",tableMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists webpage_idx ON %@(webpage_id)",tableMessages]];
        }
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (n_id blob, flags integer, from_id integer,  peer_id integer, date integer, serialized blob, random_id, filter_mask integer, fake_id integer, dstate integer, pts integer, invalidate integer, views integer, is_viewed integer, webpage_id blob)",tableChannelMessages]];
        
        
        if (![db columnExists:@"webpage_id" inTableWithName:tableChannelMessages])
            [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN webpage_id integer",tableChannelMessages]];
        
        
        // channel messages indexes
        {
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists cm_n_id_idx ON %@(n_id)",tableChannelMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists cm_select_messages_idx ON %@(peer_id,date)",tableChannelMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists cm_peer_idx ON %@(peer_id)",tableChannelMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists cm_date_idx ON %@(date)",tableChannelMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists cm_random_idx ON %@(random_id)",tableChannelMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists cm_peer_flags_idx ON %@(peer_id,flags)",tableChannelMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists cm_fake_idx ON %@(fake_id)",tableChannelMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists cm_pts_idx ON %@(pts)",tableChannelMessages]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists web_page_idx ON %@(webpage_id)",tableChannelMessages]];
        }
        
        
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (n_id INTEGER PRIMARY KEY, serialized blob)",tableChats]];
        
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (n_id INTEGER PRIMARY KEY, seq integer, pts integer, date integer, qts integer, pts_count integer)",tableUpdateState]];
        
        
        
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (n_id INTEGER PRIMARY KEY, serialized blob, lastseen_update integer,last_seen integer)",tableUsers]];
        
        if (![db columnExists:@"last_seen" inTableWithName:tableUsers])
        {
            [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN last_seen integer",tableUsers]];
        }
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (user_id INTEGER PRIMARY KEY,mutual integer)",tableContacts]];
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (n_id INTEGER PRIMARY KEY, last_update_time integer, serialized blob)",tableChatsFull]];
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (hash blob primary key, hashObject string, user_id integer)",tableImportedContacts]];
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (chat_id integer primary key,serialized blob)",tableEncryptedChats]];
        

        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement, chat_id integer, max_id integer, ttl integer)",tableSelfDestruction]];
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (id blob primary key, user_id integer, serialized blob,date integer)",tableUserPhotos]];
        
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (user_id integer primary key, date integer)",tableBlockedUsers]];
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (task_id integer primary key, params blob, extender blob)",tableTasks]];
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (hash string PRIMARY KEY, serialized blob)",tableFiles]];
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (n_id integer PRIMARY KEY, serialized blob, title string, date integer)",tableBroadcasts]];
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (action_id integer primary key, message_data blob, chat_id integer, senderClass string, out_seq_no integer, layer integer)",tableOutSecretActions]];
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (action_id integer primary key, message_data blob, file_data blob, chat_id integer, date integer, in_seq_no integer, layer integer)",tableInSecretActions]];
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (n_id blob, serialized blob)",tableSupportMessages]];
        [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists sp_n_id_idx ON %@(n_id)",tableSupportMessages]];
        
        
        
        [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (unique_id integer primary key, peer_id integer, min_id integer, max_id integer, date integer,count integer, type integer, imploded integer)",tableMessageHoles]];
        
        [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists mh_min_id_idx ON %@(min_id)",tableMessageHoles]];
        [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists mh_min_id_idx ON %@(max_id)",tableMessageHoles]];
        [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists mh_peer_min_idx ON %@(peer_id,min_id)",tableMessageHoles]];
        [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists mh_peer_type_idx ON %@(peer_id,type)",tableMessageHoles]];
        
        
        // modern dialogs
        {
            [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (peer_id INTEGER PRIMARY KEY, top_message blob, unread_count integer,last_message_date integer, type integer, last_marked_message integer,last_marked_date integer,last_real_message_date integer, read_inbox_max_id integer, mute_until integer,unread_important_count integer, pts integer, is_invisible integer, top_important_message blob)",tableModernDialogs]];
            
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists c_l_idx ON %@(last_real_message_date)",tableModernDialogs]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists c_t_idx ON %@(top_message)",tableModernDialogs]];
            [db executeUpdate:[NSString stringWithFormat:@"CREATE INDEX if not exists c_ti_idx ON %@(top_important_message)",tableModernDialogs]];
            
        }

        
        [self upgradeDialogsTo42Layer:db];
        
       
        
        
        if([db hadError]) {
            [self drop:^{
                dispatch_async(dqueue, ^{
                    [self open:completeHandler queue:dqueue];
                });
                
            }];
            return;
        }
        
        
        
        
        dispatch_async(dqueue, ^{
            if(completeHandler) completeHandler();
        });
        
        
    }];
    
    
   
}

-(BOOL)upgradeDialogsTo42Layer:(FMDatabase *)db {
    
    NSString *oTable = @"dialogs";
    NSString *ocTable = @"channel_dialogs";
   
    BOOL exist = [db tableExists:oTable];
    
    if(exist) {
        
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where type = %d",oTable,DialogTypeSecretChat]];
        
        NSMutableArray *secretChats = [NSMutableArray array];
        
        while ([result next]) {
            
            TL_conversation *conversation = [[TL_conversation alloc] init];
            conversation.peer = [self peerWithType:[result intForColumn:@"type"] peer_id:[result intForColumn:@"peer_id"]];
            conversation.unread_count = [result intForColumn:@"unread_count"];
            conversation.top_message = [result intForColumn:@"top_message"];
            conversation.last_message_date = [result intForColumn:@"last_message_date"];
            conversation.last_marked_message = [result intForColumn:@"last_marked_message"];
            conversation.last_marked_date = [result intForColumn:@"last_marked_date"];
            conversation.read_inbox_max_id = [result intForColumn:@"read_inbox_max_id"];
            conversation.notify_settings = [TLClassStore deserialize:[result dataForColumn:@"notify_settings"]];
            
            [secretChats addObject:conversation];
        }
        
        [self insertDialogs:secretChats];
        
        [db executeUpdate:[NSString stringWithFormat:@"drop table if exists %@",oTable]];
        [db executeUpdate:[NSString stringWithFormat:@"drop table if exists %@",ocTable]];
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where 1=1",tableChats]];
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where 1=1",tableChatsFull]];
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where 1=1",tableSupportMessages]];
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where n_id < ?",tableMessages],@(TGMINSECRETID)];
        
        TGUpdateState *state = [self updateState];
        state.checkMinimum = NO;
        state.pts = 0;
        state.date = 0;
        state.seq = 0;
        state.checkMinimum = YES;
        [self saveUpdateState:state];
        
        [result close];
        
    }
    
    return exist;

}


static NSString *oldEncryptionKey;
static NSString *encryptionKey;

+(void)updateEncryptionKey:(NSString *)key {
    encryptionKey = key;
}

+(void)updateOldEncryptionKey:(NSString *)key {
    oldEncryptionKey = key;
}

//
-(void) createAndCheckDatabase:(NSString *)dbName
{
    NSString *encryptedDatabasePath = [[Storage path] stringByAppendingPathComponent:@"encrypted.sqlite"];

    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@",[Storage path],dbName];
    NSString *copyDbPath = [NSString stringWithFormat:@"%@/%@",[Storage path],@"cp_db_p"];
    
    BOOL success = [fileManager fileExistsAtPath:encryptedDatabasePath] && fileSize(encryptedDatabasePath) > 0 && ![fileManager fileExistsAtPath:copyDbPath];
    
    if (success) {
        [fileManager removeItemAtPath:dbPath error:nil];
        return;
    } else {
        [fileManager removeItemAtPath:encryptedDatabasePath error:nil];
    }
    
    if([fileManager fileExistsAtPath:dbPath])
        [fileManager copyItemAtPath:dbPath toPath:copyDbPath error:nil];

    
    const char* sqlQ = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", encryptedDatabasePath, encryptionKey] UTF8String];
    
    sqlite3 *unencrypted_DB;
    
    int rc = sqlite3_open([copyDbPath UTF8String], &unencrypted_DB);
    
    
    if (rc == SQLITE_OK) {

        if(fileSize(dbPath) > 0) {
            [ASQueue dispatchOnMainQueue:^{
                [TMViewController showModalProgressWithDescription:NSLocalizedString(@"DatabaseOptimizing",nil)];
            }];
        }
        
        
       int res = sqlite3_exec(unencrypted_DB, sqlQ, NULL, NULL, NULL);
        
        // export database
        res = sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
        
        
        // Detach encrypted database
        res = sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
        
        
        res = sqlite3_close(unencrypted_DB);
        
        
        if(fileSize(dbPath) > 0) {
            [ASQueue dispatchOnMainQueue:^{
                [TMViewController hideModalProgress];
            }];
        }
        
    }
    else {
        sqlite3_close(unencrypted_DB);
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
    }
    
    [fileManager removeItemAtPath:copyDbPath error:nil];
    [fileManager removeItemAtPath:dbPath error:nil];
    
}
//

+(void)open:(void (^)())completeHandler {
    [[self manager] open:completeHandler queue:dispatch_get_current_queue()];
}

-(void)drop:(void (^)())completeHandler {
    [self drop:completeHandler queue:dispatch_get_current_queue()];
}


+(void)drop {
    [[NSFileManager defaultManager] removeItemAtPath:[[Storage path] stringByAppendingPathComponent:@"encrypted.sqlite"] error:nil];
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        [transaction removeAllObjectsInAllCollections];
    }];
}

-(void)drop:(void (^)())completeHandler queue:(dispatch_queue_t)dqueue {
    
    dispatch_async(dqueue, ^{
        [self->queue inDatabase:^(FMDatabase *db) {
            [[NSFileManager defaultManager] removeItemAtPath:self->queue.path error:nil];
            
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
                [transaction removeAllObjectsInAllCollections];
            }];
            
            [self open:completeHandler queue:dqueue];
        }];
    });
     
   
}

-(TGUpdateState *)updateState {
    
    __block TGUpdateState *state;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
    
        
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where n_id = 1",tableUpdateState]];
        
        dispatch_block_t proccessResult = ^{
             state = [[TGUpdateState alloc] initWithPts:[result intForColumn:@"pts"] qts:[result intForColumn:@"qts"] date:[result intForColumn:@"date"] seq:[result intForColumn:@"seq"] pts_count:[result intForColumn:@"pts_count"]];
        };
        
        if([result next]) {
            proccessResult();
        } else {
            [result close];
            
            result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ limit 1",@"update_state"]];
           
            if([result next]) {
                proccessResult();
                
                [db executeUpdate:@"delete from update_state where 1=1"];
                
                [self saveUpdateState:state];
            }
        }
        
        
        
        [result close];
        
    }];
    
    return state;
}

-(void)saveUpdateState:(TGUpdateState *)state {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[NSString stringWithFormat:@"insert or replace into %@ (n_id, pts, qts, date, seq,pts_count) values (?,?,?,?,?,?)",tableUpdateState],@(1),@(state.pts),@(state.qts),@(state.date),@(state.seq),@(state.pts_count)];
    }];
}




- (void)findFileInfoByPathHash:(NSString *)pathHash completeHandler:(void (^)(BOOL result, id file))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {        
        FMResultSet *result = [db executeQuery:@"select serialized from files where hash = ?", pathHash];
        id file = nil;
        
        if([result next]) {
            file = [TLClassStore deserialize:[[result resultDictionary] objectForKey:@"serialized"]];
        }
        [result close];
        
        if(completeHandler) {
            [[ASQueue mainQueue] dispatchOnQueue:^{
                completeHandler(file != nil, file);
            }];
        }
    }];
}


- (id)fileInfoByPathHash:(NSString *)pathHash  {
    
    __block id file;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select serialized from files where hash = ?", pathHash];
        
        if([result next]) {
            file = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
        }
        [result close];
    }];
    
    return file;
}

- (void)setFileInfo:(id)file forPathHash:(NSString *)pathHash {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert or replace into files (hash, serialized) values (?,?)", pathHash, [TLClassStore serialize:file isCacheSerialize:NO]];
    }];
}

- (void)deleteFileHash:(NSString *)pathHash {
    [queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"delete from files WHERE hash = ?",pathHash];
    }];
}


TL_localMessage *parseMessage(FMResultSet *result) {
    @try {
        
        TL_localMessage *msg = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
        
        if([msg isChannelMessage]) {
            msg.flags = [result intForColumn:@"flags"];
            msg.invalidate = [result intForColumn:@"invalidate"];
            msg.pts = [result intForColumn:@"pts"];
            msg.views = [result intForColumn:@"views"];
            msg.viewed = [result intForColumn:@"is_viewed"];
        } else {
            
            msg.flags = [result intForColumn:@"flags"];
            msg.message = [result stringForColumn:@"message_text"];
            
                
        }
        
        if(![msg isKindOfClass:[TL_messageEmpty class]])
            return msg;

    }
    @catch (NSException *exception) {
        
    }
    
    
    return nil;
}


-(TGHistoryResponse *)loadMessages:(int)conversationId min_id:(int)min_id max_id:(int)max_id minDate:(int)minDate maxDate:(int)maxDate limit:(int)limit next:(BOOL)next  filterMask:(int)mask isChannel:(BOOL)isChannel {
    
    __block NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    __block TGMessageHole *hole;
    
    NSMutableArray *groupHoles = [[NSMutableArray alloc] init];
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        int localMaxDate = maxDate;
        int localMinDate = minDate;
        
        
        if(max_id != 0 && localMaxDate == 0) {
            localMaxDate = [db intForQuery:[NSString stringWithFormat:@"SELECT date FROM %@ WHERE n_id=?",tableMessages],@(max_id)];
        }
        
        if(min_id != 0 && localMinDate == 0) {
            localMinDate = [db intForQuery:[NSString stringWithFormat:@"SELECT date FROM %@ WHERE n_id=?",tableMessages],@(min_id)];
        }
        
        if(localMaxDate == 0)
            localMaxDate = INT32_MAX;
        
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE  peer_id = %d AND date >= %d AND date < %d %@  AND (filter_mask & %d > 0) ORDER BY date %@, n_id %@ LIMIT %d",isChannel ? tableChannelMessages : tableMessages,conversationId,localMinDate,localMaxDate,isChannel ? @"" : [NSString stringWithFormat: @"and destruct_time > %d",[[MTNetwork instance] getTime]],mask, next ? @"DESC" : @"ASC",next ? @"DESC" : @"ASC",limit];

        
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        
        
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        
        while ([result next]) {
            TL_localMessage *msg = parseMessage(result);
            if(msg) {
                [messages addObject:msg];
                [ids addObject:@(msg.n_id)];
            }
            
        }
        [result close];
        
        
        TL_localMessage *lastMessage = [messages lastObject];
        
        if(lastMessage) {
            
            NSArray *selectedCount = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.date == %d",lastMessage.date]];
           
            int localCount = [db intForQuery:[NSString stringWithFormat:@"SELECT count(*) from %@ where peer_id = ? and date = ?",isChannel ? tableChannelMessages : tableMessages],@(lastMessage.peer_id),@(lastMessage.date)];
            if(selectedCount.count < localCount) {
                
                NSString *sql = [NSString stringWithFormat:@"select * from %@ where date = %d and n_id NOT IN (%@) and peer_id = %d order by n_id desc",isChannel ? tableChannelMessages : tableMessages,lastMessage.date,[ids componentsJoinedByString:@","],lastMessage.peer_id];
                
                 FMResultSet *result = [db executeQueryWithFormat:sql,nil];
                
                 while ([result next]) {
                     TL_localMessage *msg = parseMessage(result);
                     if(msg)
                         [messages addObject:msg];
                 }
                 [result close];
                
            }
        }
        
        
        int max = max_id;
        int min = min_id;
        
        if(messages.count > 0)
        {
            TL_localMessage *first = next ? [messages firstObject] : [messages lastObject];
            TL_localMessage *last = !next ? [messages firstObject] : [messages lastObject];
            
            max = first.n_id;
            min = last.n_id;
        }
        
        NSMutableArray *holes = [NSMutableArray array];
        
        NSString *holeSql = [NSString stringWithFormat:@"select * from %@ where peer_id = %@ and max_id > %@ and min_id < %@ and (type & 2 = 2) order by date asc",tableMessageHoles,@(conversationId),@(next ? min : min_id),@(next ? max_id : max)];
        
        
        result = [db executeQuery:holeSql];
        
        while ([result next]) {
            TGMessageHole *hole = [[TGMessageHole alloc] initWithUniqueId:[result intForColumn:@"unique_id"] peer_id:[result intForColumn:@"peer_id"] min_id:[result intForColumn:@"min_id"] max_id:[result intForColumn:@"max_id"] date:[result intForColumn:@"date"] count:[result intForColumn:@"count"]];
            
            [holes addObject:hole];
        }
        
        [result close];
        
        
        
        if(!next)
            hole = [holes firstObject];
        else
            hole = [holes lastObject];
        
        
        
        
        if(mask & HistoryFilterImportantChannelMessage) {
            
            result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where peer_id = ? and ((min_id <= ?) and (max_id > ?)) and (type & 4 = 4) order by date asc",tableMessageHoles],@(conversationId),@(max),@(min)];
            
            while ([result next]) {
                TGMessageHole *gh = [[TGMessageGroupHole alloc] initWithUniqueId:[result intForColumn:@"unique_id"] peer_id:[result intForColumn:@"peer_id"] min_id:[result intForColumn:@"min_id"] max_id:[result intForColumn:@"max_id"] date:[result intForColumn:@"date"] count:[result intForColumn:@"count"]];
                
                if(hole && (hole.max_id <= gh.max_id && hole.min_id >= gh.min_id)) {
                    hole = nil;
                }
                [groupHoles addObject:gh];
                
                
            }
            
            [result close];
        }
        
        
        
        if(hole) {
            
            NSPredicate *predicate;
            
            if(next)
                predicate = [NSPredicate predicateWithFormat:@"self.n_id >= %d",hole.max_id];
            else
                predicate = [NSPredicate predicateWithFormat:@"self.n_id <= %d",hole.min_id];
            
            messages = [[messages filteredArrayUsingPredicate:predicate] mutableCopy];
            
        }
        
        
        [groupHoles enumerateObjectsUsingBlock:^(TGMessageGroupHole *hole, NSUInteger idx, BOOL *stop) {
            
            TL_localMessageService *msg = [TL_localMessageService createWithHole:hole];
            
            [messages addObject:msg];
        }];
        
        
    }];
    
    
    
    NSArray *supportList = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.reply_to_msg_id != 0"]];
    
    NSMutableArray *supportIds = [[NSMutableArray alloc] init];
    
    [supportList enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
        
        [supportIds addObject:@(isChannel ? channelMsgId([obj reply_to_msg_id], obj.peer_id) :obj.reply_to_msg_id)];
        
    }];
    
    
    NSArray *support = [self selectSupportMessages:supportIds];
    
    [MessagesManager addSupportMessages:support];
    
    return [[TGHistoryResponse alloc] initWithResult:[messages copy] hole:hole groupHoles:nil];

}



-(void)invalidateChannelMessagesWithPts:(int)pts {
    [queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[NSString stringWithFormat:@"update %@ set invalidate = 1 where pts <= ?",tableChannelMessages],@(pts)];
        
    }];
}


-(void)validateChannelMessages:(NSArray *)messages {
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set invalidate = 0 where n_id IN (%@)",tableChannelMessages,[messages componentsJoinedByString:@","]];
        
        [db executeUpdateWithFormat:sql,nil];
        
    }];
}

-(void)updateMessageViews:(int)views channelMsgId:(long)channelMsgId {
    [queue inDatabase:^(FMDatabase *db){
        [db executeUpdate:[NSString stringWithFormat:@"update %@ set views = ? where n_id = ?",tableChannelMessages],@(views),@(channelMsgId)];
    }];
}


-(void)markChannelMessagesAsRead:(int)channel_id max_id:(int)max_id callback:(void (^)(int unread_count))callback {
   
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    [queue inDatabase:^(FMDatabase *db) {
        
        int unread_count = [db intForQuery:[NSString stringWithFormat:@"select unread_count from %@ where peer_id = %d",tableModernDialogs,-channel_id]];
        
        int current_max_read = [db intForQuery:[NSString stringWithFormat:@"select read_inbox_max_id from %@ where peer_id = %d",tableModernDialogs,-channel_id]];
        
        unread_count = MAX(0, unread_count - (max_id - current_max_read));
        
        
        [db executeUpdate:[NSString stringWithFormat:@"update %@ set read_inbox_max_id = %d, unread_count = %d where peer_id = %d",tableModernDialogs,max_id,unread_count,-channel_id]];
        
        if(callback != nil) {
            dispatch_async(dqueue, ^{
                callback(unread_count);
            });
        }
        
    }];
}

-(TL_localMessage *)lastImportantMessageAroundMinId:(long)channelMsgId;
{
    return [self lastMessageAroundMinId:channelMsgId important:YES isTop:NO];
}

-(TL_localMessage *)lastMessageAroundMinId:(long)msgId important:(BOOL)important isTop:(BOOL)isTop {
   
    __block TL_localMessage *msg;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        int peer_id = 0;
        
        NSData *data = [[NSData alloc] initWithBytes:&msgId length:8];
        
        [data getBytes:&peer_id range:NSMakeRange(4, 4)];
        
        
        
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select flags,serialized,views,pts from %@ where n_id %@ ? and n_id < ? and peer_id = ? and  (filter_mask & ?) = ? order by n_id %@ limit 1",tableChannelMessages,!isTop ? @"<=" : @">=",isTop ? @"asc" : @"desc"],@(msgId),@(channelMsgId(TGMINFAKEID,peer_id)),@(peer_id),@(important ? HistoryFilterImportantChannelMessage : HistoryFilterChannelMessage),@(important ? HistoryFilterImportantChannelMessage : HistoryFilterChannelMessage)];
        
        if([result next]) {
            msg = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
            msg.flags = [result intForColumn:@"flags"];
            msg.views = [result intForColumn:@"views"];
            msg.pts = [result intForColumn:@"pts"];
        }
        
        [result close];
        
    }];
    
    return msg;
}


-(TL_localMessage *)messageById:(int)msgId {
    return [self messageById:msgId inChannel:0];
}

-(TL_localMessage *)messageById:(int)msgId inChannel:(int)channel_id {
    
    __block TL_localMessage *message;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where n_id = %d",tableMessages,msgId];
        
        if(channel_id != 0)
        {
            sql = [NSString stringWithFormat:@"select * from %@ where n_id = %ld",tableChannelMessages,channelMsgId(msgId, channel_id)];
        }
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        
        while ([result next]) {
            message = parseMessage(result);
        }
        [result close];
        
    }];
    
    return message;
    
}

-(void)messages:(void (^)(NSArray *))completeHandler forIds:(NSArray *)ids random:(BOOL)random queue:(ASQueue *)q  {
    
    [self messages:completeHandler forIds:ids random:random sync:NO queue:q];
}


-(void)messages:(void (^)(NSArray *))completeHandler forIds:(NSArray *)ids random:(BOOL)random sync:(BOOL)sync queue:(ASQueue *)q {
    
    void (^block)(FMDatabase *db) = ^(FMDatabase *db) {
        NSString *strIds = [ids componentsJoinedByString:@","];
        
        NSString *sql = [NSString stringWithFormat:@"select serialized,flags,message_text from %@ where %@ in (%@) order by date DESC",tableMessages,random ? @"random_id" : @"n_id",strIds];
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        __block NSMutableArray *messages = [[NSMutableArray alloc] init];
        while ([result next]) {
            TLMessage *msg = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
            msg.flags = -1;
            msg.flags = [result intForColumn:@"flags"];
            msg.message = [result stringForColumn:@"message_text"];
            [messages addObject:msg];
        }
        [result close];
        
        if(completeHandler)
        {
            if(sync)
                completeHandler(messages);
             else 
                [q dispatchOnQueue:^{
                    completeHandler(messages);
                }];
        }
    };
    
    if(!sync)
        [queue inDatabase:block];
    else
        [queue inDatabaseWithDealocing:block];
  
}

- (void)explainQuery:(NSString *)query
{
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"EXPLAIN QUERY PLAN %@", query]];
        while ([result next])
        {
            MTLog(@"%d %d %d :: %@", [result intForColumnIndex:0], [result intForColumnIndex:1], [result intForColumnIndex:2],
                  [result stringForColumnIndex:3]);
        }
        
        [result close];
    }];
    
    
}

-(NSArray *)issetMessages:(NSArray *)ids {
   
    NSMutableArray *isset = [[NSMutableArray alloc] init];
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select n_id from messages where n_id in (%@)",[ids componentsJoinedByString:@","]];
                
       FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        while ([result next]) {
            
            [isset addObject:[result objectForColumnName:@"n_id"]];
        }
        [result close];
        
    }];
    
    return isset;
}

-(void)lastMessageWithConversation:(TL_conversation *)conversation completeHandler:(void (^)(TL_localMessage *message, int importantMessage))completeHandler {
    
    [queue inDatabase:^(FMDatabase *db) {
        
        TL_localMessage *message;
        
        int importantMessage = 0;
        
        
        if([conversation.peer isKindOfClass:[TL_peerChannel class]]) {
            NSString *topMessage = [NSString stringWithFormat:@"select serialized,flags,pts,views,invalidate from %@ where peer_id = %d and (filter_mask & %d) > 0 ORDER BY date DESC, n_id desc LIMIT 1",tableChannelMessages,conversation.peer_id,conversation.chat.isMegagroup ? HistoryFilterChannelMessage : HistoryFilterImportantChannelMessage];
            
             FMResultSet *result;
            
            void (^fillMessage)(TL_localMessage *msg) = ^(TL_localMessage *msg) {
                
                msg.flags = [result intForColumn:@"flags"];
                msg.pts = [result intForColumn:@"pts"];
                msg.views = [result intForColumn:@"views"];
                msg.invalidate = [result intForColumn:@"invalidate"];
            };
            
            result = [db executeQueryWithFormat:topMessage,nil];
            
            if([result next]) {
                message = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
                fillMessage(message);
            }
            
            [result close];
            
            importantMessage = message.n_id;
            
            
        } else {
            
            NSString *sql = [NSString stringWithFormat:@"select serialized,flags,message_text from %@ where peer_id = %d ORDER BY n_id DESC LIMIT 1",tableMessages,conversation.peer_id];
            
            FMResultSet *result = [db executeQueryWithFormat:sql,nil];
            
            
            if([result next]) {
                message = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
                message.flags = [result intForColumn:@"flags"];
                message.message = [result stringForColumn:@"message_text"];
            }
            
            
            [result close];
        }
        
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler != nil) completeHandler(message,importantMessage);
        });
    }];

}




-(void)updateTopMessage:(TL_conversation *)dialog completeHandler:(void (^)(BOOL result))completeHandler {
    
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        [db executeUpdate:@"update dialogs set top_message = (?) where peer_id = ?",
            [NSNumber numberWithInt:dialog.top_message],
            [NSNumber numberWithInt:[[dialog peer] peer_id]]
         ];
        //[db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(YES);
        });
    }];
}





-(void)messagesWithWebpage:(TLMessageMedia *)mediaWebpage callback:(void (^)(NSDictionary *))callback {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSMutableDictionary *peers = [NSMutableDictionary dictionary];
        
        
        
        
        void (^proccessResult)(NSString *tableName, FMResultSet *result) = ^(NSString *tableName, FMResultSet *result){
            
            TL_localMessage *msg = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
            
            msg.media = mediaWebpage;
            
            long random_id = [result longForColumn:@"random_id"];
            
            [db executeUpdate:[NSString stringWithFormat:@"update %@ set serialized = ? where random_id = ?",tableName],[TLClassStore serialize:msg],@(random_id)];
            
            int peer_id = msg.peer_id;
            int n_id = msg.n_id;
            
            NSMutableArray *msgs = peers[@(peer_id)];
            
            if(!msgs) {
                msgs = peers[@(peer_id)] = [NSMutableArray array];
            }
            
            [msgs addObject:@(n_id)];
        };
        
        
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select serialized,random_id from %@ where webpage_id = ?",tableMessages],@(mediaWebpage.webpage.n_id)];
        
        while ([result next])
            proccessResult(tableMessages,result);
        
        [result close];
        
        result = [db executeQuery:[NSString stringWithFormat:@"select serialized,random_id from %@ where webpage_id = ?",tableChannelMessages],@(mediaWebpage.webpage.n_id)];
        
        while ([result next])
           proccessResult(tableChannelMessages,result);
            
        
        
        [result close];
        
        if(callback != nil)
        {
            dispatch_async(dqueue, ^{
                callback([peers copy]);
            });
        }
        
    }];
}



-(void)markMessagesAsRead:(NSArray *)messages useRandomIds:(NSArray *)randomIds {
    
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        
        NSString *mark,*sql;
        
        if(messages.count > 0) {
            mark = [messages componentsJoinedByString:@","];
            sql = [NSString stringWithFormat:@"update messages set flags = flags & ~1 WHERE n_id IN (%@)",mark];
            [db executeUpdateWithFormat:sql,nil];
        }
        
        if(randomIds.count > 0) {
            mark = [randomIds componentsJoinedByString:@","];
            sql = [NSString stringWithFormat:@"update messages set flags = flags & ~1 WHERE random_id IN (%@)",mark];
            [db executeUpdateWithFormat:sql,nil];
        }
    
    }];
}

-(void)markAllInConversation:(int)peer_id {
    [queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        [db executeUpdate:@"update messages set flags= flags & ~1 where peer_id = ?",@(peer_id)];
        [db executeUpdate:[NSString stringWithFormat:@"update %@ set read_inbox_max_id = (select top_message from %@ where peer_id = ?) where peer_id = ?",tableModernDialogs,tableModernDialogs],@(peer_id),@(peer_id)];
        [db commit];

    }];
}

-(void)markAllInConversation:(int)peer_id max_id:(int)max_id out:(BOOL)n_out completeHandler:(void (^)(NSArray * ids))completeHandler {
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    dispatch_queue_t q = dispatch_get_current_queue();
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db beginTransaction];
        
        int flags = n_out ? TGOUTMESSAGE | TGUNREADMESSAGE : TGUNREADMESSAGE;
        
        FMResultSet *result;
        
        if(!n_out) {
            int read_inbox_max_id = [db intForQuery:[NSString stringWithFormat:@"select read_inbox_max_id from %@ where peer_id = ?",tableModernDialogs],@(peer_id)];
            
            result = [db executeQuery:@"select n_id from messages where ((n_id <= ? and n_id >= ?) OR dstate=?) and peer_id = ? and (flags & ?) = ? and (flags & ?) = 0",@(max_id),@(read_inbox_max_id),@(DeliveryStatePending),@(peer_id),@(flags),@(flags),@(TGOUTMESSAGE)];
            
            
            [db executeUpdate:[NSString stringWithFormat:@"update %@ set read_inbox_max_id = ? where peer_id = ?",tableModernDialogs],@(max_id),@(peer_id)];
        } else {
            result = [db executeQuery:[NSString stringWithFormat:@"select n_id from %@ where (n_id <= ? OR dstate= ?) and peer_id = ? and (flags & ?) = ?",tableMessages],@(max_id),@(DeliveryStatePending),@(peer_id),@(flags),@(flags)];
        }
        
        
        
        
        while ([result next]) {
            
            [ids addObject:@([result intForColumn:@"n_id"])];
        }
        
        
        [result close];
        
        
        if(ids.count > 0)
        {
            NSString *sql = [NSString stringWithFormat:@"update messages set flags= flags & ~1 where n_id in (%@)",[ids componentsJoinedByString:@","]];
            
            [db executeUpdateWithFormat:sql,nil];
        }
        
        [db commit];
        
        dispatch_async(q,^{
            completeHandler(ids);
        });
        
    }];
}

-(void)readMessagesContent:(NSArray *)messages {
    [queue inDatabase:^(FMDatabase *db) {
        NSString *mark = [messages componentsJoinedByString:@","];
        NSString *sql = [NSString stringWithFormat:@"update messages set flags = flags & ~32 WHERE n_id IN (%@)",mark];
        [db executeUpdateWithFormat:sql,nil];
        
    }];
}


-(void)deleteMessagesWithRandomIds:(NSArray *)messages isChannelMessages:(BOOL)isChannelMessages completeHandler:(void (^)(NSArray *peer_update_data))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *mark = [messages componentsJoinedByString:@","];
        
        
        NSMutableArray *peer_update_data = [[NSMutableArray alloc] init];
        
        
        NSString *sql = [NSString stringWithFormat:@"select n_id,peer_id from %@ where random_id IN (%@)",isChannelMessages ? tableChannelMessages: tableMessages,mark];
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
       
       
        
        while ([result next]) {
            
            [peer_update_data addObject:@{KEY_PEER_ID:@([result intForColumn:@"peer_id"]),KEY_MESSAGE_ID:@([result intForColumn:@"n_id"])}];
        }
        
        [result close];


        sql = [NSString stringWithFormat:@"delete from %@ WHERE random_id IN (%@)",tableMessages,mark];
        [db executeUpdateWithFormat:sql,nil];
        
        
        sql = [NSString stringWithFormat:@"delete from %@ WHERE random_id IN (%@)",tableChannelMessages,mark];
        [db executeUpdateWithFormat:sql,nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(peer_update_data);
        });
        
    }];
}


-(void)deleteMessages:(NSArray *)messages completeHandler:(void (^)(NSArray *peer_updates))completeHandler {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        NSString *mark = [messages componentsJoinedByString:@","];
        
        NSMutableArray *peer_updates = [[NSMutableArray alloc] init];
        
        
        NSString *sql = [NSString stringWithFormat:@"SELECT n_id,peer_id FROM messages WHERE n_id IN (%@)",mark];
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        
        while ([result next]) {
            
            [peer_updates addObject:@{KEY_PEER_ID:@([result intForColumn:@"peer_id"]),KEY_MESSAGE_ID:@([result intForColumn:@"n_id"])}];
        }
        
        [result close];
        
        sql = [NSString stringWithFormat:@"delete from messages WHERE n_id IN (%@)",mark];
        [db executeUpdateWithFormat:sql,nil];
        
        
        
        //[db commit];
        dispatch_async(dqueue, ^{
            if(completeHandler) completeHandler(peer_updates);
        });
    }];
}

-(void)deleteChannelMessages:(NSArray *)messages completeHandler:(void (^)(NSArray *peer_updates, NSDictionary *readCount))completeHandler {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *mark = [messages componentsJoinedByString:@","];
        
        NSMutableArray *peer_updates = [[NSMutableArray alloc] init];
        
        if(messages.count > 0) {
            NSString *sql = [NSString stringWithFormat:@"SELECT n_id,random_id FROM %@ WHERE n_id IN (%@)",tableChannelMessages,mark];
            
            
            FMResultSet *result = [db executeQueryWithFormat:sql,nil];
            
            NSMutableDictionary *unreadCount = [NSMutableDictionary dictionary];
            
            NSMutableArray *randomIds = [NSMutableArray array];
            
            while ([result next]) {
                
                [randomIds addObject:@([result longForColumn:@"random_id"])];
                
                long n_id = [result longForColumn:@"n_id"];
                
                NSData *nData = [[NSData alloc] initWithBytes:&n_id length:8];
                
                int msgId;
                int peerId;

                
                [nData getBytes:&msgId range:NSMakeRange(0, 4)];
                [nData getBytes:&peerId range:NSMakeRange(4, 4)];
                
                int read_max_id = [db intForQuery:[NSString stringWithFormat:@"select read_inbox_max_id from %@ where peer_id = ?",tableModernDialogs],@(peerId)];
                
                if(msgId > read_max_id) {
                    unreadCount[@(peerId)] = @([unreadCount[@(peerId)] intValue] + 1);
                }
                
                
                [peer_updates addObject:@{KEY_MESSAGE_ID:@(msgId),KEY_PEER_ID:@(peerId)}];
            }
            
            
            [result close];
            
            
            [unreadCount enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                
                [db executeUpdate:[NSString stringWithFormat:@"update %@ set unread_count = unread_count - ? where peer_id = ?",tableModernDialogs],key,obj];
            }];
            
            
            sql = [NSString stringWithFormat:@"delete from %@ WHERE n_id IN (%@)",tableChannelMessages,mark];
            
            [db executeUpdateWithFormat:sql,nil];
            
            
            dispatch_async(dqueue, ^{
                if(completeHandler) completeHandler(peer_updates,unreadCount);
            });

        }
        
    }];
}

-(void)deleteMessagesInDialog:(TL_conversation *)dialog completeHandler:(dispatch_block_t)completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        
        NSString *sql = [NSString stringWithFormat:@"delete from %@ WHERE peer_id = %d",tableMessages,dialog.peer.peer_id];
        [db executeUpdateWithFormat:sql,nil];
        
        if(dialog.type == DialogTypeChannel) {
            sql = [NSString stringWithFormat:@"delete from %@ WHERE peer_id = %d",tableChannelMessages,dialog.peer.peer_id];
            [db executeUpdateWithFormat:sql,nil];
            
            [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where peer_id = ?",tableMessageHoles],@(dialog.peer_id)];
        }
        
        
        
        
        
        if(dialog.type == DialogTypeSecretChat)
            [db executeUpdate:@"delete from self_destruction where chat_id = ?",[NSNumber numberWithInt:dialog.peer.chat_id]];
        [db commit];
        
        if(completeHandler)
            dispatch_async(dispatch_get_main_queue(), ^{
                completeHandler();
            });
    }];
}

-(void)updateChannelMessageViews:(long)channelMsgId views:(int)views {
    [queue inDatabase:^(FMDatabase *db) {
       
        [db executeUpdate:[NSString stringWithFormat:@"update %@ set views = ? where n_id = ?",tableChannelMessages],@(views),@(channelMsgId)];
        
    }];
}


-(void)insertMessages:(NSArray *)messages completeHandler:(dispatch_block_t)completeHandler {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    
    
    [queue inDatabase:^(FMDatabase *db) {
        NSArray *msgs = [messages copy];
        
        test_start_group(@"insert_test");
        
        for (TL_localMessage *message in msgs) {
            
            TL_localMessage *m = [message copy];
            m.message = nil;
            
            int destruct_time = INT32_MAX;
            if([message isKindOfClass:[TL_destructMessage class]]) {
                if(((TL_destructMessage *)message).destruction_time != 0)
                    destruct_time = ((TL_destructMessage *)message).destruction_time;
            }
            int peer_id = [message peer_id];
            
            int mask = message.filterType;
            
            
            dispatch_block_t clearWithFakeId = ^{
                if(message.n_id < TGMINFAKEID) {
                    
                    NSString *sql = [NSString stringWithFormat:@"delete from %@ WHERE fake_id = %d",tableMessages,message.fakeId];
                    [db executeUpdateWithFormat:sql,nil];
                    
                    
                    sql = [NSString stringWithFormat:@"delete from %@ WHERE fake_id = %d",tableChannelMessages,message.fakeId];
                    [db executeUpdateWithFormat:sql,nil];
                    
                }
            };
            
            
            void (^insertBlock)(NSString *tableName) = ^(NSString *tableName) {
                
                
                [db executeUpdate:[NSString stringWithFormat:@"insert or replace into %@ (n_id,date,from_id,flags,peer_id,serialized, destruct_time, filter_mask,fake_id,dstate,random_id,webpage_id,message_text) values (?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName],
                 @(message.n_id),
                 @(message.date),
                 @(message.from_id),
                 @(message.flags),
                 @(peer_id),
                 [TLClassStore serialize:m],
                 @(destruct_time),
                 @(mask),
                 @(message.fakeId),
                 @(message.dstate),
                 @(message.randomId),
                 @(message.media.webpage.n_id),
                 message.message
                 ];
                
            };
            
            int globalPts = [db intForQuery:[NSString stringWithFormat:@"select pts from %@ where peer_id = ?",tableModernDialogs],@(message.peer_id)];
            
            
            dispatch_block_t insertChannelMessageBlock = ^ {
                
                int isset = [db intForQuery:[NSString stringWithFormat:@"select count(*) from %@ where n_id = ?",tableChannelMessages],@(message.channelMsgId)];
                
                int pts = MAX(message.n_id,globalPts);
                
                
                message.pts = pts;
                
                if(isset == 0) {
                    [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (n_id,date,from_id,flags,peer_id,serialized, filter_mask,fake_id,dstate,random_id,pts,views,webpage_id) values (?,?,?,?,?,?,?,?,?,?,?,?,?)",tableChannelMessages],
                     @(message.channelMsgId),
                     @(message.date),
                     @(message.from_id),
                     @(message.flags),
                     @(peer_id),
                     [TLClassStore serialize:message],
                     @(mask),
                     @(message.fakeId),
                     @(message.dstate),
                     @(message.randomId),
                     @(pts),
                     @(message.views),
                     @(message.media.webpage.n_id)
                     ];
                    
                    
                } else {
                    [db executeUpdate:[NSString stringWithFormat:@"update %@ set flags = ?, from_id = ?,  peer_id = ?, date = ?, serialized = ?, random_id = ?, filter_mask = ?, fake_id = ?, dstate = ?, pts = ?, views = ?, webpage_id = ? WHERE n_id = ?",tableChannelMessages],@(message.flags),@(message.from_id),@(message.peer_id),@(message.date),[TLClassStore serialize:message],@(message.randomId), @(message.filterType),@(message.fakeId),@(message.dstate),@(pts),
                     @(message.views),@(message.media.webpage.n_id),@(message.channelMsgId),nil];
                    
                }
                
                
                
            };
            
            clearWithFakeId();
            
            if(![message isKindOfClass:[TL_messageEmpty class]]) {
                if(![message.to_id isKindOfClass:[TL_peerChannel class]])
                    insertBlock(@"messages");
                else
                    insertChannelMessageBlock();
            }
            
        }
        
        test_step_group(@"insert_test");
        test_release_group(@"insert_test");
        
        if(completeHandler != nil) {
            dispatch_async(dqueue, completeHandler);
        }
    }];

}

-(void)insertMessages:(NSArray *)messages {
    [self insertMessages:messages completeHandler:nil];
}




-(void)loadChats:(void (^)(NSArray *chats))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
         NSMutableArray *chats = [[NSMutableArray alloc] init];
        FMResultSet *secretResult = [db executeQuery:@"select * from encrypted_chats"];
        while ([secretResult next]) {
            
            id chat = [TLClassStore deserialize:[secretResult dataForColumn:@"serialized"]];
            if(chat)
                [chats addObject:chat];
        }
        [secretResult close];
        
        
        FMResultSet *chatResult = [db executeQuery:@"select * from chats"];
        while ([chatResult next]) {
            id obj = [TLClassStore deserialize:[chatResult dataForColumn:@"serialized"]];
            if(obj)
            [chats addObject:obj];
        }
        
        [chatResult close];
        
         if(completeHandler)
                completeHandler(chats);
    }];
}

-(TLPeer *)peerWithType:(DialogType)type peer_id:(int)peer_id {
    
    TLPeer *peer;
    
    if(type == DialogTypeSecretChat) {
        peer = [TL_peerSecret createWithChat_id:peer_id];
    } else if(type == DialogTypeUser) {
        peer = [TL_peerUser createWithUser_id:peer_id];
    } else if(type == DialogTypeChat) {
        peer = [TL_peerChat createWithChat_id:-peer_id];
    } else if(type == DialogTypeBroadcast) {
        peer = [TL_peerBroadcast createWithChat_id:peer_id];
    } else if(type == DialogTypeChannel) {
        peer = [TL_peerChannel createWithChannel_id:-peer_id];
    }
    
    return peer;
}


- (NSArray *)parseDialogs:(FMResultSet *)result {
    
    NSMutableArray *dialogs = [NSMutableArray array];
    
    while ([result next]) {
        
        TLPeer *peer = [self peerWithType:[result intForColumn:@"type"] peer_id:[result intForColumn:@"peer_id"]];
        
        TL_conversation *dialog = [TL_conversation createWithPeer:peer top_message:[result intForColumn:@"top_message"] unread_count:[result intForColumn:@"unread_count"] last_message_date:[result intForColumn:@"last_message_date"] notify_settings:[TL_peerNotifySettings createWithMute_until:[result intForColumn:@"mute_until"] sound:@"" show_previews:YES events_mask:0] last_marked_message:[result intForColumn:@"last_marked_message"] top_message_fake:0 last_marked_date:[result intForColumn:@"last_marked_date"] sync_message_id:0 read_inbox_max_id:[result intForColumn:@"read_inbox_max_id"] unread_important_count:[result intForColumn:@"unread_important_count"] lastMessage:nil pts:[result intForColumn:@"pts"] isInvisibleChannel:[result boolForColumn:@"is_invisible"] top_important_message:[result intForColumn:@"top_important_message"]];
        
        [dialogs addObject:dialog];

    }
    
    return dialogs;
}

-(void)updateTopMessagesWithMessages:(NSDictionary *)topMessages topImportantMessages:(NSDictionary *)topImportantMessages {
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db beginTransaction];
        
        [topMessages enumerateKeysAndObjectsUsingBlock:^(id key, TL_localMessage *obj, BOOL *stop) {
            
            [db executeUpdate:[NSString stringWithFormat:@"update %@ set top_message = ? where peer_id = ?",tableModernDialogs],@(obj.channelMsgId)];
            
        }];
        
        [topImportantMessages enumerateKeysAndObjectsUsingBlock:^(id key, TL_localMessage *obj, BOOL *stop) {
            
            [db executeUpdate:[NSString stringWithFormat:@"update %@ set top_important_message = ? where peer_id = ?",tableModernDialogs],@(obj.channelMsgId)];
            
        }];
        
        [db commit];
        
        
    }];
    
}



- (void)searchDialogsByPeers:(NSArray *)peers needMessages:(BOOL)needMessages searchString:(NSString *)searchString completeHandler:(void (^)(NSArray *dialogs))completeHandler {
    
    __block NSArray *conversations;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        if(peers.count) {
            FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where peer_id IN(%@) order by last_message_date DESC",tableModernDialogs, [peers componentsJoinedByString:@","]]];
            
            conversations = [self parseDialogs:result];
            [self fillLastMessagesWithConversations:conversations];
            [result close];
        }
        
    }];
    
    if(completeHandler) {
        completeHandler(conversations);
    }
    
}

-(void)fillLastMessagesWithConversations:(NSArray *)list {
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [list enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *sql = [NSString stringWithFormat:@"select * from %@ where peer_id = ? ORDER BY date DESC, n_id DESC LIMIT 1",obj.type == DialogTypeChannel ? tableChannelMessages : tableMessages];
            
            FMResultSet *result = [db executeQuery:sql, @(obj.peer_id)];
            
            if([result next]) {
                obj.lastMessage = parseMessage(result);
                obj.last_message_date = obj.lastMessage.date;
            }
            
            
            
            [result close];
            
        }];
        
    }];
    
    
}

-(void)dialogsWithOffset:(int)offset limit:(int)limit completeHandler:(void (^)(NSArray *d))completeHandler {
    
    dispatch_queue_t dq = dispatch_get_current_queue();
    
    [queue inDatabase:^(FMDatabase *db) {
        
         FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ ORDER BY last_real_message_date DESC LIMIT ? OFFSET ?",tableModernDialogs],@(limit),@(offset)];
        
        NSArray *dialogs = [self parseDialogs:result];
        
        [self fillLastMessagesWithConversations:dialogs];
        
        [result close];
        
        if(completeHandler){
            dispatch_async(dq, ^{
                completeHandler(dialogs);
            });
        }
    }];
}




-(void)insertDialogs:(NSArray *)dialogs {
        
    [queue inDatabase:^(FMDatabase *db) {
        
        [dialogs enumerateObjectsUsingBlock:^(TL_conversation *dialog, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(dialog.fake)
                return;
            
            
            [db executeUpdate:[NSString stringWithFormat:@"insert or replace into %@ (peer_id,top_message,type,last_message_date,unread_count,last_marked_message,last_marked_date,last_real_message_date,read_inbox_max_id, unread_important_count, pts,is_invisible,top_important_message,mute_until) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableModernDialogs],
             @(dialog.peer_id),
             @(dialog.channel_top_message_id),
             @(dialog.type),
             @(dialog.last_message_date),
             @(dialog.unread_count),
             @(dialog.last_marked_message),
             @(dialog.last_marked_date),
             @(dialog.last_real_message_date),
             @(dialog.read_inbox_max_id),
             @(dialog.unread_important_count),
             @(dialog.pts),
             @(dialog.isInvisibleChannel),
             @(dialog.channel_top_important_message_id),
             @(dialog.notify_settings.mute_until)
             ];

        }];
        
        
    }];
}


-(void)insertChat:(TLChat *)chat completeHandler:(void (^)(BOOL))completeHandler {
    
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        BOOL result = [db executeUpdate:@"insert or replace into chats (n_id,serialized) values (?,?)",[NSNumber numberWithInt:chat.n_id], [TLClassStore serialize:chat]];
        //[db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(result);
        });
    }];
}



-(void)deleteDialog:(TL_conversation *)dialog completeHandler:(void (^)(void))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where peer_id = ?",tableModernDialogs],@(dialog.peer_id)];
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where peer_id = ?",tableMessages],@(dialog.peer_id)];
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where peer_id = ?",tableChannelMessages],@(dialog.peer_id)];
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where peer_id = ?",tableMessageHoles],@(dialog.peer_id)];
     
        TLChat *chat = dialog.chat;
        
        if([dialog.peer isKindOfClass:[TL_peerSecret class]])
            chat = (TLChat *) dialog.encryptedChat;
        
        if(chat) {
            [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where chat_id = ?",tableEncryptedChats],@(chat.n_id)];
            [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where n_id = ?",tableChats],@(chat.n_id)];
            [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where n_id = ?",tableChatsFull], @(chat.n_id)];
            [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where chat_id = ?",tableSelfDestruction],@(dialog.peer.chat_id)];
           
        }
        
        
        [db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler();
        });
        
    }];
}


-(void)insertChats:(NSArray *)chats completeHandler:(void (^)(BOOL))completeHandler {
    
    [queue inDatabase:^(FMDatabase *db) {
        __block BOOL result;
        //[db beginTransaction];
        for (TLChat *chat in chats) {
            result = [db executeUpdate:@"insert or replace into chats (n_id,serialized) values (?,?)",[NSNumber numberWithInt:chat.n_id], [TLClassStore serialize:chat]];
        }
        //[db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(result);
        });
        
    }];
}


-(void)chats:(void (^)(NSArray *))completeHandler {
    
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableArray *chats = [[NSMutableArray alloc] init];
        //[db beginTransaction];
      FMResultSet *result = [db executeQuery:@"select * from chats"];
        while ([result next]) {
            TLChat *chat = [TLClassStore deserialize:[[result resultDictionary] objectForKey:@"serialized"]];
            [chats addObject:chat];
        }
        [result close];
        //[db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(chats);
        });
    }];
}

-(void)users:(void (^)(NSArray *))completeHandler {
    
    
    [queue inDatabase:^(FMDatabase *db) {

        NSMutableArray *users = [[NSMutableArray alloc] init];
        
        
        FMResultSet *result = [db executeQuery:@"select * from users"];
        
        
        while ([result next]) {
            TLUser *user = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
            if([user isKindOfClass:[TLUser class]]) {
                user.lastSeenUpdate = [result intForColumn:@"lastseen_update"];
                
                int last_seen = [result intForColumn:@"last_seen"];
                
                if(last_seen != 0) {
                    user.status = last_seen < [[MTNetwork instance] getTime] ? [TL_userStatusOffline createWithWas_online:last_seen] : [TL_userStatusOnline createWithExpires:last_seen];
                }
                
                [users addObject:user];

            }
        }
        
        [result close];
        
        
        if(completeHandler) {
            completeHandler(users);
        }
    }];
}

-(void)updateUsersStatus:(NSArray *)users {
    [queue inDatabase:^(FMDatabase *db) {
        
        [users enumerateObjectsUsingBlock:^(TLUser *user, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [db executeUpdate:[NSString stringWithFormat:@"update %@ set last_seen = ? where n_id = ?",tableUsers],@(user.lastSeenTime),@(user.n_id)];
            
        }];
        
    }];
}


- (void)insertUser:(TLUser *)user completeHandler:(void (^)(BOOL result))completeHandler {
    [self insertUsers:@[user] completeHandler:completeHandler];
}

- (void)insertUsers:(NSArray *)users completeHandler:(void (^)(BOOL result))completeHandler {
    
    [queue inDatabase:^(FMDatabase *db) {
        for (TLUser *user in users) {
            
            if([user isKindOfClass:[TLUser class]]) {
                if(user.type == TLUserTypeSelf) {
                    [[Telegram standartUserDefaults] setObject:[TLClassStore serialize:user] forKey:@"selfUser"];
                    [[MTNetwork instance] setUserId:user.n_id];
                }
                
                [db executeUpdate:@"insert or replace into users (n_id, serialized,lastseen_update,last_seen) values (?,?,?,?)", @(user.n_id), [TLClassStore serialize:user],@(user.lastSeenUpdate),@(user.status.lastSeenTime)];

            }
            
        }
        
        if(completeHandler) {
            [[ASQueue mainQueue] dispatchOnQueue:^{
                completeHandler(YES);
            }];
        }
    }];
}




- (void) insertContact:(TLContact *) contact completeHandler:(void (^)(void))completeHandler {
    
    
    [queue inDatabase:^(FMDatabase *db) {
        if(![db executeUpdate:@"insert or replace into contacts (user_id, mutual) values (?,?)", [NSNumber numberWithInt:contact.user_id],[NSNumber numberWithBool:contact.mutual]]) {
            ELog(@"DB insert contact error: %d", contact.user_id);
        }
        [LoopingUtils runOnMainQueueAsync:^{
            if(completeHandler)
                completeHandler();
        }];
    }];
}

- (void) removeContact:(TLContact *) contact {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from contacts where user_id = ?", [NSNumber numberWithInt:contact.user_id]];
        
    }];
}


- (void) insertContact:(TLContact *) contact {
    [self insertContacst:@[contact]];
}

-(void)insertContacst:(NSArray *)contacts  {
    
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        for (TLContact *contact in contacts) {
            [db executeUpdate:@"insert or replace into contacts (user_id,mutual) values (?,?)",[NSNumber numberWithInt:contact.user_id],[NSNumber numberWithBool:contact.mutual]];
        }
        //[db commit];
    }];
}


-(void)dropContacts {
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        [db executeUpdate:@"delete from contacts where 1 = 1"];
        //[db commit];
        
    }];
}


-(void)contacts:(void (^)(NSArray *))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        FMResultSet *result = [db executeQuery:@"select * from contacts"];
        while ([result next]) {
            TLContact *contact = [[TLContact alloc] init];
            contact.user_id = [[[result resultDictionary] objectForKey:@"user_id"] intValue];
            contact.mutual = [[[result resultDictionary] objectForKey:@"mutual"] boolValue];
            [contacts addObject:contact];
        }
        [result close];
            if(completeHandler)
                completeHandler(contacts);
    }];
}

-(void)insertSession:(NSData *)session completeHandler:(void (^)(void))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        [db executeUpdate:@"insert or replace into sessions (session) values (?)",session];
        //[db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler();
        });
    }];
}


-(void)fullChats:(void (^)(NSArray *chats))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableArray *chats = [[NSMutableArray alloc] init];
        FMResultSet *result = [db executeQuery:@"select * from chats_full_new"];
        while ([result next]) {
            TLChatFull *fullChat = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
            
            if(fullChat) {
                fullChat.lastUpdateTime = [result intForColumn:@"last_update_time"];
                
                [chats addObject:fullChat];
            }
            
        }
        [result close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(chats);
        });
    }];

}

-(void)insertFullChat:(TLChatFull *)fullChat completeHandler:(void (^)(void))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert or replace into chats_full_new (n_id, last_update_time, serialized) values (?,?,?)",@(fullChat.n_id), @(fullChat.lastUpdateTime), [TLClassStore serialize:fullChat]];
        //[db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler();
        });
    }];
}

-(void)chatFull:(int)n_id completeHandler:(void (^)(TLChatFull *chat))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        FMResultSet *result = [db executeQuery:@"select * from chats_full where n_id = ?",[NSNumber numberWithInt:n_id]];
        [result next];
        if([result resultDictionary]) {
             TLChatFull *fullChat = [TLClassStore deserialize:[[result resultDictionary] objectForKey:@"serialized"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completeHandler) completeHandler(fullChat);
            });
        }
        [result close];
        //[db commit];
        
    }];
}

-(void)insertImportedContacts:(NSSet *)result {
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
       [result enumerateObjectsUsingBlock:^(TGHashContact *contact, BOOL *stop) {
           [db executeUpdate:@"insert or replace into imported_contacts (hash,hashObject,user_id) values (?,?,?)",@(contact.hash),contact.hashObject,@(contact.user_id)];
       }];
        
    }];
}

-(void)deleteImportedContacts:(NSSet *)result {
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        [result enumerateObjectsUsingBlock:^(TGHashContact *contact, BOOL *stop) {
            [db executeUpdate:@"delete from imported_contacts where hash = ?",@(contact.hash)];
        }];
        
        //[db commit];
    }];
}

-(void)importedContacts:(void (^)(NSSet *imported))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableSet *contacts = [[NSMutableSet alloc] init];
        //[db beginTransaction];
        FMResultSet *result = [db executeQuery:@"select * from imported_contacts"];
        while ([result next]) {
            
           
            TGHashContact *contact = [[TGHashContact alloc] initWithHash:[result stringForColumn:@"hashObject"] user_id:[result intForColumn:@"user_id"]];
            
            [contacts addObject:contact];
            
            
        }
        [result close];
        //[db commit];
        if(completeHandler) completeHandler(contacts);
    }];

}

-(void)unreadCount:(void (^)(int count))completeHandler includeMuted:(BOOL)includeMuted {
    
    [queue inDatabase:^(FMDatabase *db) {
        
        int unread_count = 0;
        
        if(includeMuted) {
            unread_count =[db intForQuery:[NSString stringWithFormat:@"select sum(unread_count) from %@ where is_invisible = 0 and unread_count > 0 and unread_count < 100000",tableModernDialogs]];
        } else {
            unread_count = [db intForQuery:[NSString stringWithFormat:@"select sum(unread_count) from %@ where is_invisible = 0 and unread_count > 0 and unread_count < 100000 and (mute_until == 0 OR mute_until < ?)",tableModernDialogs],@([[MTNetwork instance] getTime])];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(unread_count);
        });
    }];

}


-(void)insertEncryptedChat:(TL_encryptedChat *)chat {
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        [db executeUpdate:@"insert or replace into encrypted_chats (chat_id,serialized) values (?,?)",[NSNumber numberWithInt:chat.n_id],[TLClassStore serialize:chat]];
        //[db commit];
    }];
}




-(void)countOfUserPhotos:(int)user_id {
    __block int count = 0;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        count = [db intForQuery:@"select count(*) from user_photos where user_id = ?",@(user_id)];
        
    }];
}

-(void)addUserPhoto:(int)user_id media:(TLUserProfilePhoto *)photo {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert or replace into user_photos (id,user_id,serialized,date) values (?,?,?,?)",@(photo.photo_id),@(user_id),[TLClassStore serialize:photo],@([[MTNetwork instance] getTime])];
    }];
}

-(void)deleteUserPhoto:(int)n_id {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from user_photos where id = ? ",@(n_id)];
    }];
}


-(void)media:(void (^)(NSArray *))completeHandler max_id:(int)max_id filterMask:(int)filterMask peer:(TLPeer *)peer next:(BOOL)next limit:(int)limit {
     [queue inDatabase:^(FMDatabase *db) {
         
         FMResultSet *result;
         NSString *sql = [NSString stringWithFormat:@"select serialized from %@ where peer_id = %d and n_id %@ %@ and (filter_mask & %d) > 0 order by date DESC, n_id DESC LIMIT %d",[peer isKindOfClass:[TL_peerChannel class]] ? tableChannelMessages : tableMessages,peer.peer_id,next ? @"<" : @">",@([peer isKindOfClass:[TL_peerChannel class]] ? channelMsgId(max_id, peer.peer_id) : max_id),filterMask,limit];
         
         
        result = [db executeQueryWithFormat:sql,nil];
         
         
         __block NSMutableArray *list = [[NSMutableArray alloc] init];
         while ([result next]) {
             TL_localMessage *message = [TLClassStore deserialize:[[result resultDictionary] objectForKey:@"serialized"]];
            
             if(![message isKindOfClass:[TL_messageEmpty class]]) {
                  [list addObject:[[PreviewObject alloc] initWithMsdId:message.n_id media:message peer_id:peer.peer_id]];
             }
         }
         
         [LoopingUtils  runOnMainQueueAsync:^{
            if(completeHandler)
                completeHandler(list);
        }];
     }];
}

-(int)countOfMedia:(int)peer_id {
    
    __block int count = 0;
    
    
    
    return count;
}

-(void)pictures:(void (^)(NSArray *))completeHandler forUserId:(int)user_id {
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select serialized,id from user_photos where user_id = %d order by id DESC",user_id];
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        __block NSMutableArray *list = [[NSMutableArray alloc] init];
        while ([result next]) {
            TLUserProfilePhoto *photo = [TLClassStore deserialize:[[result resultDictionary] objectForKey:@"serialized"]];
            
             [list addObject:[[PreviewObject alloc] initWithMsdId:[result intForColumn:@"id"] media:photo peer_id:user_id]];
        }
        
        [LoopingUtils  runOnMainQueueAsync:^{
            if(completeHandler)
                completeHandler(list);
        }];
    }];
}


-(void)insertDestructor:(Destructor *)destructor {
    [queue inDatabase:^(FMDatabase *db) {
        //[db beginTransaction];
        [db executeUpdate:@"insert or replace into self_destruction (chat_id, max_id, ttl) values (?,?,?)",@(destructor.chat_id),@(destructor.max_id),@(destructor.ttl)];
        //[db commit];
    }];
}



-(void)selfDestructorFor:(int)chat_id max_id:(int)max_id completeHandler:(void (^)(Destructor *destructor))completeHandler {
    
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select * from self_destruction where chat_id = ? and max_id <= ? order by max_id desc limit 1",@(chat_id),@(max_id)];
        Destructor *destructor;
        while ([result next]) {
            destructor = [[Destructor alloc] initWithTLL:[result intForColumn:@"ttl"] max_id:[result intForColumn:@"max_id"] chat_id:[result intForColumn:@"chat_id"]];
        }
        [result close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(destructor);
        });
    }];
}

-(void)selfDestructors:(int)chat_id completeHandler:(void (^)(NSArray *destructors))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableArray *destructors = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [db executeQuery:@"select * from self_destruction where chat_id = ? order by max_id desc",@(chat_id)];
        
        while ([result next]) {
            Destructor * destructor = [[Destructor alloc] initWithTLL:[result intForColumn:@"ttl"] max_id:[result intForColumn:@"max_id"] chat_id:[result intForColumn:@"chat_id"]];
            [destructors addObject:destructor];
        }
        [result close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(destructors);
        });
    }];
}

-(void)selfDestructors:(void (^)(NSArray *destructors))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableArray *destructors = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [db executeQuery:@"select * from self_destruction order by max_id desc"];
        
        while ([result next]) {
            Destructor * destructor = [[Destructor alloc] initWithTLL:[result intForColumn:@"ttl"] max_id:[result intForColumn:@"max_id"] chat_id:[result intForColumn:@"chat_id"]];
            [destructors addObject:destructor];
        }
        [result close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(destructors);
        });
    }];
}

-(void)updateDestructTime:(int)time forMessages:(NSArray *)msgIds {
    [queue inDatabase:^(FMDatabase *db) {
        
        //[db beginTransaction];
        NSString *mark = [msgIds componentsJoinedByString:@","];
        NSString *sql = [NSString stringWithFormat:@"update messages set destruction_time = %d WHERE n_id IN (%@)",time,mark];
        [db executeUpdateWithFormat:sql,nil];

        //[db commit];
    }];
}


-(void)insertBlockedUsers:(NSArray *)users {
    [queue inDatabase:^(FMDatabase *db) {
        
        for (TL_contactBlocked *user in users) {
            [db executeUpdate:@"insert or replace into blocked_users (user_id, date) values (?,?)", @(user.user_id),@(user.date)];
        }
        
    }];
}

-(void)deleteBlockedUsers:(NSArray *)users {
    [queue inDatabase:^(FMDatabase *db) {
        
        NSMutableString *whereIn = [[NSMutableString alloc] init];
        
        for (TL_contactBlocked *user in users) {
            [whereIn appendFormat:@"%d,",user.user_id];
        }
         
       NSString *sql = [NSString stringWithFormat:@"delete from blocked_users WHERE user_id IN (%@)",[whereIn substringWithRange:NSMakeRange(0, whereIn.length-1)]];
        [db executeUpdateWithFormat:sql,nil];
        
    }];
}

-(void)blockedList:(void (^)(NSArray *users))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableArray *contacs = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [db executeQuery:@"select * from blocked_users"];
        
        while ([result next]) {
            TL_contactBlocked * contact = [TL_contactBlocked createWithUser_id:[result intForColumn:@"user_id"] date:[result intForColumn:@"date"]];
            [contacs addObject:contact];
        }
        [result close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler(contacs);
        });
    }];

}



-(void)insertTask:(id<ITaskRequest>)task {
    [queue inDatabase:^(FMDatabase *db) {
        NSDictionary *params = [[task params] mutableCopy];
        
        NSMutableDictionary *accepted = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in params.allKeys) {
            id tl = [params objectForKey:key];
            
            id serialized = [TLClassStore serialize:tl];
            
            if(serialized) {
                accepted[key] = serialized;
            }
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accepted];
        
        [db executeUpdate:@"insert or replace into tasks (task_id, params,extender) values (?,?,?)",@([task taskId]),data,NSStringFromClass([task class])];
    }];
}

-(void)removeTask:(id<ITaskRequest>)task {
    [queue inDatabase:^(FMDatabase *db) {
         [db executeUpdate:@"delete from tasks where task_id = ?",@([task taskId])];
    }];
}

-(void)selectTasks:(void (^)(NSArray *tasks))completeHandler {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableArray *tasks = [[NSMutableArray alloc] init];
        FMResultSet *result = [db executeQuery:@"select * from tasks"];
        
        while ([result next]) {
            
            Class class = NSClassFromString([result stringForColumn:@"extender"]);
            
            NSDictionary *params = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"params"]];
            NSMutableDictionary *accepted = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in params.allKeys) {
                id tl = [TLClassStore deserialize:params[key]];
                
                if(tl)
                    accepted[key] = tl;
                
                
            }
            
            NSUInteger taskId = [result intForColumn:@"task_id"];
            
            id <ITaskRequest> task = [[class alloc] initWithParams:accepted taskId:taskId];
            
            [tasks addObject:task];
        }
        [result close];
        dispatch_async(dqueue, ^{
            if(completeHandler) completeHandler(tasks);
        });


    }];
}

-(TL_conversation *)selectConversation:(TLPeer *)peer {
    __block TL_conversation *conversation;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where peer_id = %d", tableModernDialogs,peer.peer_id];
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        
        conversation = [[self parseDialogs:result] firstObject];
        
        if(conversation != nil)
            [self fillLastMessagesWithConversations:@[conversation]];
        
        [result close];
        
    }];
    
    
    return conversation;

}


-(void)conversationsWithPeerIds:(NSArray *)peer_ids completeHandler:(void (^)(NSArray * result))completeHandler {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    
    if(peer_ids.count == 0) {
        completeHandler(@[]);
        return;
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where peer_id IN (%@)",tableModernDialogs,[peer_ids componentsJoinedByString:@","]];
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        
        NSArray *list = [self parseDialogs:result];
        
        [result close];
        
        dispatch_async(dqueue, ^{
            completeHandler(list);
        });
        
    }];
    
}



-(void)insertBroadcast:(TL_broadcast *)broadcast {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert or replace into broadcasts (n_id, serialized, title,date) values (?,?,?,?)",@(broadcast.n_id),[TLClassStore serialize:broadcast],broadcast.title,@(broadcast.date)];
    }];
}

-(void)deleteBroadcast:(TL_broadcast *)broadcast {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from broadcasts where n_id = ?",@(broadcast.n_id)];
    }];
}

-(void)broadcastList:(void (^)(NSArray *list))completeHandler  {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:@"select * from broadcasts where 1=1 order by date"];
        while ([result next]) {
            TL_broadcast *broadcast = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
            if(broadcast) {
                [list addObject:broadcast];
            }
        }
        
         [result close];
        
        if(completeHandler)
            completeHandler(list);
        
    }];
    
    
}

-(void)insertSecretAction:(TGSecretAction *)action {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert or replace into out_secret_actions (action_id, message_data, chat_id, senderClass, layer) values (?,?,?,?,?)",@(action.actionId),action.decryptedData,@(action.chat_id),action.senderClass,@(action.layer)];
    }];
}


-(void)removeSecretAction:(TGSecretAction *)action {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from out_secret_actions where action_id = ?",@(action.actionId)];
    }];
}

-(void)selectAllActions:(void (^)(NSArray *list))completeHandler {
    
    
    [queue inDatabase:^(FMDatabase *db) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        FMResultSet *result = [db executeQuery:@"select * from out_secret_actions where 1=1 order by action_id"];
        while ([result next]) {
            TGSecretAction *action = [[TGSecretAction alloc] initWithActionId:[result intForColumn:@"action_id"] chat_id:[result intForColumn:@"chat_id"] decryptedData:[result dataForColumn:@"message_data"] senderClass:NSClassFromString([result stringForColumn:@"senderClass"]) layer:[result intForColumn:@"layer"]];
            
            [list addObject:action];
        }
        
        [result close];
        
        if(completeHandler) completeHandler(list);
        
    }];

}


-(void)insertSecretInAction:(TGSecretInAction *)action {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert or replace into in_secret_actions (action_id, message_data, file_data, chat_id, date, in_seq_no, layer) values (?,?,?,?,?,?,?)",@(action.actionId),action.messageData, action.fileData,@(action.chat_id),@(action.date),@(action.in_seq_no),@(action.layer)];
    }];
}
-(void)removeSecretInAction:(TGSecretInAction *)action {
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from in_secret_actions where action_id = ?",@(action.actionId)];
    }];
}

-(void)selectSecretInActions:(int)chat_id completeHandler:(void (^)(NSArray *list))completeHandler {
    [queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [db executeQuery:@"select * from in_secret_actions where chat_id=? order by in_seq_no",@(chat_id)];
        while ([result next]) {
            TGSecretInAction *action = [[TGSecretInAction alloc] initWithActionId:[result intForColumn:@"action_id"] chat_id:[result intForColumn:@"chat_id"] messageData:[result dataForColumn:@"message_data"] fileData:[result dataForColumn:@"file_data"] date:[result intForColumn:@"date"] in_seq_no:[result intForColumn:@"in_seq_no"] layer:[result intForColumn:@"layer"]];
            
            [list addObject:action];
        }
        
        [result close];
        
        if(completeHandler) completeHandler(list);
        
    }];
}


-(NSArray *)selectSupportMessages:(NSArray *)ids {
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        NSString *join = [ids componentsJoinedByString:@","];
        
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where n_id IN (%@)",tableSupportMessages,join];
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        
        
        while ([result next]) {
            id msg = [TLClassStore deserialize:[result dataForColumn:@"serialized"]];
            [messages addObject:msg];
            
        }
        
        [result close];
        
    }];
    
    return messages;
    
}


-(void)addSupportMessages:(NSArray *)messages {
    [queue inDatabase:^(FMDatabase *db) {
        [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            BOOL isset = [db boolForQuery:[NSString stringWithFormat:@"select count(*) from %@ where n_id = ?",tableSupportMessages],@(obj.channelMsgId)];
            
            if(isset) {
                [db executeUpdate:[NSString stringWithFormat:@"update %@ set serialized = ? where n_id = ?",tableSupportMessages],@(obj.channelMsgId),[TLClassStore serialize:obj],@(obj.channelMsgId)];
            } else {
                [db executeUpdate:[NSString stringWithFormat:@"insert or replace into %@ (n_id,serialized) values (?,?)",tableSupportMessages],@(obj.channelMsgId),[TLClassStore serialize:obj]];
            }
            
        }];
    }];
}



-(void)updateMessageId:(long)random_id msg_id:(int)n_id {
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"update messages set n_id = (?), dstate = (?) where random_id = ?",@(n_id),@(DeliveryStateNormal),@(random_id)];
        
        int  peer_id = [db intForQuery:[NSString stringWithFormat:@"select peer_id from %@ where random_id = ?",tableChannelMessages],@(random_id)];
      
        [db executeUpdate:[NSString stringWithFormat:@"update %@ set n_id = (?), dstate = (?) where random_id = ?",tableChannelMessages],@(channelMsgId(n_id,peer_id)),@(DeliveryStateNormal),@(random_id)];
        
        
    }];
}

+(void)addWebpage:(TLWebPage *)webpage forLink:(NSString *)link {
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        [transaction setObject:[TLClassStore serialize:webpage] forKey:link inCollection:@"webpage"];
        
    }];
      
    
}

-(NSArray *)conversationsWithIds:(NSArray *)ids {
    
    __block NSArray *dialogs;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where peer_id IN (%@)",tableModernDialogs,[ids componentsJoinedByString:@","]];
        
        FMResultSet *result = [db executeQueryWithFormat:sql,nil];
        
         dialogs = [self parseDialogs:result];
        
        [result close];
        
    }];
    
    return dialogs;
}

+(TLWebPage *)findWebpage:(NSString *)link {
    
    __block TLWebPage *webpage;
    
    if(link.length == 0)
        return webpage;
    
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        NSData *wp = [transaction objectForKey:link inCollection:@"webpage"];
        if(wp)
            webpage = [TLClassStore deserialize:wp];
        
    }];
    
    return webpage;
    
}


/*
 
 channel storage procedures
 
 */
 



-(void)insertMessagesHole:(TGMessageHole *)hole {
    
    [queue inDatabase:^(FMDatabase *db) {
        
        
        int unique_id = [db intForQuery:[NSString stringWithFormat:@"SELECT unique_id FROM %@ where peer_id = ? and (type & ?) = ?  and ((min_id = 0 OR min_id < ?) and max_id = ?) order by date asc limit 1",tableMessageHoles],@(hole.type),@(hole.type),@(hole.peer_id),@(hole.min_id), @(hole.max_id)];
        
        
         [db executeUpdate:[NSString stringWithFormat:@"insert or replace into %@ (unique_id, peer_id, min_id, max_id, date, type, count, imploded) values (?,?,?,?,?,?,?,?)",tableMessageHoles],@(unique_id < 0 ? unique_id : hole.uniqueId),@(hole.peer_id),@(hole.min_id),@(hole.max_id),@(hole.date),@(hole.type),@(hole.messagesCount),@(hole.isImploded)];
 
        
    }];
    
}

-(void)removeHole:(TGMessageHole *)hole {
    [queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where unique_id = ?",tableMessageHoles],@(hole.uniqueId)];
        
    }];
}

-(NSArray *)groupHoles:(int)peer_id min:(int)min max:(int)max {
    

    NSMutableArray *holes = [[NSMutableArray alloc] init];
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        FMResultSet *result;

        result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where peer_id = ? and (type & 4 = 4) and NOT(? >= max_id OR ? <= min_id) order by date asc",tableMessageHoles],@(peer_id),@(min),@(max)];
        
        while ([result next]) {
            [holes addObject:[[TGMessageGroupHole alloc] initWithUniqueId:[result intForColumn:@"unique_id"] peer_id:[result intForColumn:@"peer_id"] min_id:[result intForColumn:@"min_id"] max_id:[result intForColumn:@"max_id"] date:[result intForColumn:@"date"] count:[result intForColumn:@"count"] isImploded:[result boolForColumn:@"imploded"]]];
        }
        
    
        
        [result close];
        
    }];
    
    
    return [holes copy];
}

-(void)addHolesAroundMessage:(TL_localMessage *)message {
    [queue inDatabase:^(FMDatabase *db) {
        
        
        BOOL messageIsset = [db boolForQuery:[NSString stringWithFormat:@"select count(*) from %@ where n_id = ?",message.isChannelMessage ? tableChannelMessages : tableMessages],@(message.channelMsgId)];
        
        if(!messageIsset)
        {
            int minSynchedId = [self syncedMessageIdWithPeerId:message.peer_id important:message.isImportantMessage latest:NO isChannel:message.isChannelMessage];
            
            if(minSynchedId == 0) {
                minSynchedId = INT32_MAX;
            }
            
            if(minSynchedId > message.n_id) {
                TGMessageHole *hole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:message.peer_id min_id:message.n_id+1 max_id:minSynchedId-1 date:message.date count:0];
                
                [self insertMessagesHole:hole];
            }
        }
        
    }];
}

-(int)syncedMessageIdWithPeerId:(int)peer_id important:(BOOL)important latest:(BOOL)latest isChannel:(BOOL)isChannel {
    
    __block int max_id = 0;
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        int maxMsgId = [db intForQuery:[NSString stringWithFormat:@"select n_id from %@ where  peer_id = ? and n_id < ? and (filter_mask & ?) > 0 and dstate = ? order by date %@, n_id %@ limit 1",isChannel ? tableChannelMessages : tableMessages,latest ? @"desc" : @"asc",latest ? @"desc" : @"asc"],@(peer_id),@(isChannel ? channelMsgId(TGMINFAKEID, peer_id) : TGMINFAKEID),@(isChannel ? (important ?HistoryFilterImportantChannelMessage : HistoryFilterChannelMessage) : HistoryFilterNone),@(DeliveryStateNormal)];
        
        
        int holeMaxId = [db intForQuery:[NSString stringWithFormat:@"select max_id from %@ where peer_id = ? and (type & ?) = ? and max_id > ? and min_id <= ?",tableMessageHoles],@(important ? 4 : 2),@(important ? 4 : 2),@(peer_id),@(maxMsgId),@(maxMsgId)];
        
        
        if(holeMaxId != 0)
            max_id = holeMaxId;
        else
            max_id = maxMsgId;
        
    }];
    
    
    return max_id;
}

@end
