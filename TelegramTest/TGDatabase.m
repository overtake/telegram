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



NSString *db_path() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = appName();
    NSString *path = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"database"];
    
    if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
        
    }
    return path;
}

static FMDatabaseQueue *queue;

+(void)initialize {

    NSString *dbName = @"tgmodern.sqlite";
    
    queue = [FMDatabaseQueue databaseQueueWithPath:[NSString stringWithFormat:@"%@/%@",db_path(),dbName]];
    
    
    /*
     @property int n_id;
     @property int flags;
     @property int from_id;
     @property (nonatomic, strong) TLPeer* to_id;
     @property int fwd_from_id;
     @property int fwd_date;
     @property int reply_to_msg_id;
     @property int date;
     @property (nonatomic, strong) NSString* message;
     @property (nonatomic, strong) TLMessageMedia* media;
     @property (nonatomic, strong) TLReplyMarkup* reply_markup;
     @property (nonatomic, strong) TLMessageAction* action;
     */
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"create table if not exists messages (n_id INTEGER PRIMARY KEY,flags integer, from_id integer, peer_id integer, fwd_from_id integer, fwd_date integer, reply_to_msg_id intger, date integer, message string, reply_markup blob, action serialized)"];
        
        
    }];
    
}


+(SSignal *)requestMessagesWith:(int)date limit:(int)limit {
    
    SSignal *signal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        [queue inDatabase:^(FMDatabase *db) {
            
            
            FMResultSet *result = [db executeQuery:@"SELECT * FROM messages where date >= ?",date];
            
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            
        }];
        
        return nil;
    }];
    
    
    return signal;
    
}


@end
