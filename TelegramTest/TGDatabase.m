//
//  TGDatabase.m
//  Telegram
//
//  Created by keepcoder on 04.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGDatabase.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
@implementation TGDatabase


NSString *dbfolder() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = appName();
    NSString *path = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"database"];
    
    if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
        
    }
    return path;
}

static FMDatabase *db;
static SQueue *queue;
static NSString *key = @"712yfihqwehg";
static NSString *baseKey = @"712yfihqwehg"; // public encryption key
static NSString *unencryptedpath;
static NSString *dbpath;


+(void)dbRekey:(NSString *)key {
    
}

+(void)dbSetKey:(NSString *)key {
    
}

+(SSignal *)initialize {
    
    queue = [[SQueue alloc] init];
    
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        
        unencryptedpath = [dbfolder() stringByAppendingPathComponent:@"t143.sqlite"];
        dbpath = [dbfolder() stringByAppendingPathComponent:@"encrypted.sqlite"];
        
        SSignal *createSignal = [self createAndCheckDatabase];
        
        
        [createSignal startWithNext:^(id next) {
            
            [self initializeDatabase];
            
            [subscriber putNext:nil];
        }];
    
        
        return nil;
    }] startOn:queue];
}


+(void)initializeDatabase {
    
    db = [[FMDatabase alloc] initWithPath:dbpath];
    
    [db open];
    
    [db setKey:key];
    
    [db executeUpdate:@"create table if not exists messages (n_id INTEGER PRIMARY KEY,message_text TEXT, flags integer, from_id integer, peer_id integer, date integer, serialized blob, random_id, destruct_time, filter_mask integer, fake_id integer, dstate integer)"];
    
    //messages indexes
    {
        [db executeUpdate:@"CREATE INDEX if not exists select_messages_idx ON messages(peer_id,date)"];
        [db executeUpdate:@"CREATE INDEX if not exists peer_idx ON messages(peer_id)"];
        [db executeUpdate:@"CREATE INDEX if not exists date_idx ON messages(date)"];
        [db executeUpdate:@"CREATE INDEX if not exists random_idx ON messages(random_id)"];
        [db executeUpdate:@"CREATE INDEX if not exists peer_flags_idx ON messages(peer_id,flags)"];
    }
    
    
    [db executeUpdate:@"create table if not exists dialogs (peer_id INTEGER PRIMARY KEY, top_message integer, unread_count unsigned integer,last_message_date integer, type integer, notify_settings blob, last_marked_message integer, top_message_fake integer, dstate integer,sync_message_id integer,last_marked_date integer,last_real_message_date integer)"];
    
    
    //dialogs indexes
    {
        [db executeUpdate:@"CREATE INDEX if not exists select_conv_idx ON dialogs(top_message,last_real_message_date)"];
        
    }
    
    
    [db executeUpdate:@"create table if not exists chats (n_id INTEGER PRIMARY KEY, serialized blob)"];
    
    
    
    [db executeUpdate:@"create table if not exists update_state (seq integer, pts integer, date integer, qts integer, pts_count integer)"];
    
    
    
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS users (n_id INTEGER PRIMARY KEY, serialized blob, lastseen_update integer)"];
    
    [db executeUpdate:@"create table if not exists contacts (user_id INTEGER PRIMARY KEY,mutual integer)"];
    
    
    [db executeUpdate:@"CREATE INDEX if not exists user_id_index ON contacts(user_id)"];
    
    [db executeUpdate:@"create table if not exists chats_full_new (n_id INTEGER PRIMARY KEY, last_update_time integer, serialized blob)"];
    
    [db executeUpdate:@"create table if not exists imported_contacts (hash blob primary key, hashObject string, user_id integer)"];
    
    
    [db executeUpdate:@"create table if not exists encrypted_chats (chat_id integer primary key,serialized blob)"];
    
    [db executeUpdate:@"create table if not exists sharedmedia (message_id integer primary key, peer_id integer, serialized blob,date integer, filter_mask integer)"];
    
    
    [db executeUpdate:@"CREATE INDEX if not exists sm_peer_idx ON sharedmedia(peer_id)"];
    
    
    
    [db executeUpdate:@"create table if not exists self_destruction (id integer primary key autoincrement, chat_id integer, max_id integer, ttl integer)"];
    
    
    [db executeUpdate:@"create table if not exists user_photos (id blob primary key, user_id integer, serialized blob,date integer)"];
    
    
    
    [db executeUpdate:@"create table if not exists blocked_users (user_id integer primary key, date integer)"];
    
    [db executeUpdate:@"create table if not exists tasks (task_id integer primary key, params blob, extender blob)"];
    
    [db executeUpdate:@"create table if not exists files (hash string PRIMARY KEY, serialized blob)"];
    
    
    [db executeUpdate:@"create table if not exists broadcasts (n_id integer PRIMARY KEY, serialized blob, title string, date integer)"];
    
    
    [db executeUpdate:@"create table if not exists out_secret_actions (action_id integer primary key, message_data blob, chat_id integer, senderClass string, out_seq_no integer, layer integer)"];
    
    [db executeUpdate:@"create table if not exists in_secret_actions (action_id integer primary key, message_data blob, file_data blob, chat_id integer, date integer, in_seq_no integer, layer integer)"];
    
    
    [db executeUpdate:@"create table if not exists support_messages (n_id INTEGER PRIMARY KEY, serialized blob)"];
    
    
    if([db hadError]) {
        [self drop];
    }

}



+(SSignal *)drop {
    
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [[NSFileManager defaultManager] removeItemAtPath:dbpath error:nil];
        
        
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
            [transaction removeAllObjectsInAllCollections];
        }];
        
        key = baseKey;
        
        
        [SSignal single:[self initialize]];
        
        
        return nil;

        
        
    }] deliverOn:queue];
    
    
}

+(SSignal *) createAndCheckDatabase
{
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        BOOL success;
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *copyDbPath = [NSString stringWithFormat:@"%@/%@",dbfolder(),@"cp_old_db"];
        
        
        success = [fileManager fileExistsAtPath:dbpath] && fileSize(dbpath) > 0 && ![fileManager fileExistsAtPath:unencryptedpath];
        
        if (success)
        {
            [subscriber putNext:nil];
            return nil;
        }
        
        
        [fileManager copyItemAtPath:unencryptedpath toPath:copyDbPath error:nil];
        
        
        const char* sqlQ = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", dbpath, key] UTF8String];
        
        sqlite3 *unencrypted_DB;
        if (sqlite3_open([copyDbPath UTF8String], &unencrypted_DB) == SQLITE_OK) {
            
            
            
            // Attach empty encrypted database to unencrypted database
            sqlite3_exec(unencrypted_DB, sqlQ, NULL, NULL, NULL);
            
            // export database
            sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
            
            // Detach encrypted database
            sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
            
            sqlite3_close(unencrypted_DB);
            
            
            
        }
        else {
            sqlite3_close(unencrypted_DB);
            NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
        }

        
        [fileManager removeItemAtPath:copyDbPath error:nil];
        [fileManager removeItemAtPath:unencryptedpath error:nil];
        
        [subscriber putNext:nil];
        
        [subscriber putCompletion];
        
        return nil;
        
    }];
    
    
}


+(SSignal *)conversationsWithOffset:(NSUInteger)offset {
    
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        
        FMResultSet *result = [db executeQuery:@"select messages.message_text,messages.from_id, dialogs.peer_id, dialogs.type,dialogs.last_message_date, messages.serialized serialized_message, dialogs.top_message,dialogs.sync_message_id,dialogs.last_marked_date,dialogs.unread_count unread_count, dialogs.notify_settings notify_settings, dialogs.last_marked_message last_marked_message,dialogs.last_real_message_date last_real_message_date, messages.flags from dialogs left join messages on dialogs.top_message = messages.n_id ORDER BY dialogs.last_real_message_date DESC LIMIT ? OFFSET ?",@(20),@(offset)];
        
        
        NSMutableArray *conversations = [[NSMutableArray alloc] init];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        
        
        [self parseConversations:result conversations:conversations messages:messages];
        
        [subscriber putNext:@{@"conversations":conversations,@"messages":messages}];
        
        
        
        
        [result close];

        
        return nil;
        
    }] startOn:queue];
    
}



+ (void)parseConversations:(FMResultSet *)result conversations:(NSMutableArray *)conversations messages:(NSMutableArray *)messages {
    while ([result next]) {
        
        TL_conversation *dialog = [[TL_conversation alloc] init];
        int type = [result intForColumn:@"type"];
        
        if(type == DialogTypeSecretChat) {
            dialog.peer = [TL_peerSecret createWithChat_id:[result intForColumn:@"peer_id"]];
        } else if(type == DialogTypeUser) {
            dialog.peer = [TL_peerUser createWithUser_id:[result intForColumn:@"peer_id"]];
        } else if(type == DialogTypeChat) {
            dialog.peer = [TL_peerChat createWithChat_id:-[result intForColumn:@"peer_id"]];
        } else if(type == DialogTypeBroadcast) {
            dialog.peer = [TL_peerBroadcast createWithChat_id:[result intForColumn:@"peer_id"]];
        }
        
        
        id notifyObject = [result dataForColumn:@"notify_settings"];
        
        if(notifyObject != nil && ![notifyObject isKindOfClass:[NSNull class]]) {
            dialog.notify_settings = [TLClassStore deserialize:notifyObject];
        }
        
        dialog.unread_count = [result intForColumn:@"unread_count"];
        dialog.top_message = [result intForColumn:@"top_message"];
        dialog.last_message_date = [result intForColumn:@"last_message_date"];
        dialog.last_marked_message = [result intForColumn:@"last_marked_message"];
        dialog.last_marked_date = [result intForColumn:@"last_marked_date"];
        dialog.sync_message_id = [result intForColumn:@"sync_message_id"];
        dialog.last_real_message_date = [result intForColumn:@"last_real_message_date"];
        
        id serializedMessage =[[result resultDictionary] objectForKey:@"serialized_message"];
        TL_localMessage *message;
        if(![serializedMessage isKindOfClass:[NSNull class]]) {
            
            @try {
                message = [TLClassStore deserialize:serializedMessage];
                message.flags = -1;
                message.message = [result stringForColumn:@"message_text"];
                message.flags = [result intForColumn:@"flags"];
            }
            @catch (NSException *exception) {
                
            }
            
            if(message)
                [messages addObject:message];
        }
        
        dialog.lastMessage = message;
        
        [conversations addObject:dialog];
    }
}



@end
