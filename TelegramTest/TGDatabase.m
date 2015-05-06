//
//  TGDatabase.m
//  Telegram
//
//  Created by keepcoder on 05.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGDatabase.h"

@implementation TGDatabase

static NSString *encryptionKey = @"";

-(instancetype)init {
    if(self = [super init]) {
        [self open:nil];
    }
    
    return self;
}

+(void)dbSetKey:(NSString *)key {
    
    [TGDatabase manager];
    
    encryptionKey = key;
}

+(void)dbRekey:(NSString *)rekey {
    
    [[TGDatabase manager] dbRekey:encryptionKey];
    
}

static id dm;

+(TGDatabase *)manager {
    
    if(!dm) {
        static TGDatabase *instance;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[[self class] alloc] init];
            
            [self setManager:instance];
        });

    }
    
    return dm;
}

+(void)setManager:(id)manager {
    if([manager isKindOfClass:[TGDatabase class]])
        dm = manager;
}

static const int dckey = 1;


+(void)setMasterdatacenter:(int)dc_id {
    
    [TGDatabase manager];
    
    [[self manager]->queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert or replace into masterdatacenter (key,dc_id) values (?,?)",@(dckey),@(dc_id)];
    }];
    
}
+(int)masterdatacenter {
    
    [TGDatabase manager];
    
    __block int dc_id = 1;
    
    [[self manager]->queue inDatabaseWithDealocing:^(FMDatabase *db) {
        dc_id = [db intForQuery:@"select dc_id from masterdatacenter where key=?",@(dckey)];
    }];
    
    return dc_id;
}

-(void)dbRekey:(NSString *)rekey {
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db rekey:rekey];
        
    }];
}

-(void)open:(void (^)())completeHandler {
    
    NSString *dbName = @"t140.sqlite"; // 61
    
    self->queue = [FMDatabaseQueue databaseQueueWithPath:[NSString stringWithFormat:@"%@/%@",[TGDatabase path],dbName]];
    
    __block BOOL res = NO;
    
    
    
    [queue inDatabaseWithDealocing:^(FMDatabase *db) {
        
        res = [db setKey:encryptionKey];
        
    }];
    
    
    NSString *oldName = [[NSUserDefaults standardUserDefaults] objectForKey:@"db_name"];
    
    if(![oldName isEqualToString:dbName]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:dbName forKey:@"db_name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"create table if not exists messages (n_id INTEGER PRIMARY KEY,message_text TEXT, flags integer, from_id integer, peer_id integer, date integer, serialized blob, random_id, destruct_time, filter_mask integer, fake_id integer, dstate integer)"];
        
        
        [db executeUpdate:@"CREATE INDEX if not exists peer_id_index ON messages(peer_id)"];
        [db executeUpdate:@"CREATE INDEX if not exists date_id_index ON messages(date)"];
        [db executeUpdate:@"CREATE INDEX if not exists filter_mask_index ON messages(filter_mask)"];
        [db executeUpdate:@"CREATE INDEX if not exists n_id_index ON messages(n_id)"];
        
        [db executeUpdate:@"CREATE INDEX if not exists message_text_index ON messages(message_text COLLATE NOCASE)"];
        
        
        [db executeUpdate:@"create table if not exists dialogs (peer_id INTEGER PRIMARY KEY, top_message integer, unread_count unsigned integer,last_message_date integer, type integer, notify_settings blob, last_marked_message integer, top_message_fake integer, dstate integer,sync_message_id integer,last_marked_date integer,last_real_message_date integer)"];
        
        [db executeUpdate:@"create table if not exists chats (n_id INTEGER PRIMARY KEY, serialized blob)"];
        
        
        
        [db executeUpdate:@"create table if not exists update_state (seq integer, pts integer, date integer, qts integer, pts_count integer)"];
        
        
        
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS users (n_id INTEGER PRIMARY KEY, serialized blob, lastseen_update integer)"];
        
        [db executeUpdate:@"create table if not exists contacts (user_id INTEGER PRIMARY KEY,mutual integer)"];
        
        
        [db executeUpdate:@"CREATE INDEX if not exists user_id_index ON contacts(user_id)"];
        
        [db executeUpdate:@"create table if not exists sessions (session blob)"];
        
        [db executeUpdate:@"create table if not exists chats_full_new (n_id INTEGER PRIMARY KEY, last_update_time integer, serialized blob)"];
        
        [db executeUpdate:@"create table if not exists imported_contacts (hash blob primary key, hashObject string, user_id integer)"];
        
        
        [db executeUpdate:@"create table if not exists dc_options (dc_id integer primary key, ip_address string, port integer)"];
        
        [db executeUpdate:@"create table if not exists encrypted_chats (chat_id integer primary key,serialized blob)"];
        
        [db executeUpdate:@"create table if not exists sharedmedia (message_id integer primary key, peer_id integer, serialized blob,date integer, filter_mask integer)"];
        
        
        [db executeUpdate:@"CREATE INDEX if not exists mid_id_index ON sharedmedia(message_id)"];
        
        
        [db executeUpdate:@"create table if not exists self_destruction (id integer primary key autoincrement, chat_id integer, max_id integer, ttl integer)"];
        
        
        
        [db executeUpdate:@"create table if not exists user_photos (id blob primary key, user_id integer, serialized blob,date integer)"];
        
        
        
        [db executeUpdate:@"create table if not exists blocked_users (user_id integer primary key, date integer)"];
        
        [db executeUpdate:@"create table if not exists tasks (task_id integer primary key, params blob, extender blob)"];
        
        [db executeUpdate:@"create table if not exists files (hash string PRIMARY KEY, serialized blob)"];
        
        
        [db executeUpdate:@"create table if not exists broadcasts (n_id integer PRIMARY KEY, serialized blob, title string, date integer)"];
        
        
        [db executeUpdate:@"create table if not exists out_secret_actions (action_id integer primary key, message_data blob, chat_id integer, senderClass string, out_seq_no integer, layer integer)"];
        
        [db executeUpdate:@"create table if not exists in_secret_actions (action_id integer primary key, message_data blob, file_data blob, chat_id integer, date integer, in_seq_no integer, layer integer)"];
        
        
        [db executeUpdate:@"create table if not exists support_messages (n_id INTEGER PRIMARY KEY, serialized blob)"];
        
        [db executeUpdate:@"create table if not exists masterdatacenter (key integer primary key, dc_id integer)"];
        
        
        [db makeFunctionNamed:@"searchText" maximumArguments:2 withBlock:^(sqlite3_context *context, int argc, sqlite3_value **aargv) {
            
            if (sqlite3_value_type(aargv[0]) == SQLITE_TEXT) {
                
                @autoreleasepool {
                    
                    const char *c = (const char *)sqlite3_value_text(aargv[0]);
                    
                    NSString *s = [NSString stringWithUTF8String:c];
                    
                    
                    const char *cSearch = (const char *)sqlite3_value_text(aargv[1]);
                    
                    NSString *search = [NSString stringWithUTF8String:cSearch];
                    
                    BOOL result = [s rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound;
                    
                    
                    sqlite3_result_int(context, result);
                }
            } else {
                sqlite3_result_null(context);
            }
        }];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completeHandler) completeHandler();
        });
        
        
    }];
    
    
    
}


-(void)drop:(void (^)())completeHandler {
    [self->queue inDatabase:^(FMDatabase *db) {
        [[NSFileManager defaultManager] removeItemAtPath:self->queue.path error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[TGDatabase path] error:nil];
        encryptionKey = @"";
        [self open:completeHandler];
    }];
}


+(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = @"Telegram";
    NSString *path = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"database"];
    
    if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
        
    }
    return path;
}


@end
