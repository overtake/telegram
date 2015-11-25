//
//  FMDatabaseQueue.m
//  fmdb
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//

#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#include <execinfo.h>


/*
 
 Note: we call [self retain]; before using dispatch_sync, just incase
 FMDatabaseQueue is released on another thread and we're in the middle of doing
 something in dispatch_sync
 
 */

@implementation FMDatabaseQueue

@synthesize path = _path;
@synthesize openFlags = _openFlags;

+ (instancetype)databaseQueueWithPath:(NSString*)aPath {
    
    FMDatabaseQueue *q = [[self alloc] initWithPath:aPath];
    FMDBAutorelease(q);
    
    return q;
}

+ (instancetype)databaseQueueWithPath:(NSString*)aPath flags:(int)openFlags {
    
    FMDatabaseQueue *q = [[self alloc] initWithPath:aPath flags:openFlags];
    
    FMDBAutorelease(q);
    
    return q;
}

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags {
    
    self = [super init];
    
    if (self != nil) {
        
        _db = [FMDatabase databaseWithPath:aPath];
        FMDBRetain(_db);
        
#if SQLITE_VERSION_NUMBER >= 3005000
        if (![_db openWithFlags:openFlags]) {
#else
            if (![_db open]) {
#endif
                MTLog(@"Could not create database queue for path %@", aPath);
                FMDBRelease(self);
                return 0x00;
            }
            
            _path = FMDBReturnRetained(aPath);
            
            _queue = dispatch_queue_create([[NSString stringWithFormat:@"fmdb.%@", self] UTF8String], NULL);
            dispatch_async(_queue, ^{
                [[NSThread currentThread] setName:@"sqllite _queue"];
            });
            _openFlags = openFlags;
        }
        
        return self;
    }
    
    - (instancetype)initWithPath:(NSString*)aPath {
        
        // default flags for sqlite3_open
        return [self initWithPath:aPath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
    }
    
    - (void)dealloc {
        
        FMDBRelease(_db);
        FMDBRelease(_path);
        
        if (_queue) {
            FMDBDispatchQueueRelease(_queue);
            _queue = 0x00;
        }
#if ! __has_feature(objc_arc)
        [super dealloc];
#endif
    }
    
    - (void)close {
        FMDBRetain(self);
        dispatch_sync(_queue, ^() {
            [_db close];
            FMDBRelease(_db);
            _db = 0x00;
        });
        FMDBRelease(self);
    }
    
    - (FMDatabase*)database {
        if (!_db) {
            _db = FMDBReturnRetained([FMDatabase databaseWithPath:_path]);
            
#if SQLITE_VERSION_NUMBER >= 3005000
            if (![_db openWithFlags:_openFlags]) {
#else
                if (![db open])
#endif
                    MTLog(@"FMDatabaseQueue could not reopen database for path %@", _path);
                FMDBRelease(_db);
                _db  = 0x00;
                return 0x00;
            }
        }
        
        return _db;
    }
    
    - (void)inDatabase:(void (^)(FMDatabase *db))block  {
        
//        NSUInteger hash = [[NSString randStringWithLength:10] hash];
//        NSString *string = nil;
//        void *addr[2];
//        int nframes = backtrace(addr, sizeof(addr)/sizeof(*addr));
//        if (nframes > 1) {
//            char **syms = backtrace_symbols(addr, nframes);
//            
////            [[NSString alloc] initWi]
//            
//            string = [NSString stringWithFormat:@"%s", syms[1]];
//            string = [string stringByReplacingOccurrencesOfString:@"1   Messenger for Telegram              " withString:@""];
//            
//            free(syms);
//        }

        FMDBRetain(self);
        
        dispatch_block_t b = ^{
            FMDatabase *db = [self database];
            block(db);
            
            if ([db hasOpenResultSets]) {
                MTLog(@"Warning: there is at least one open result set around after performing [FMDatabaseQueue inDatabase:]");
            }
        };
        
        
        
        if(dispatch_get_current_queue() != _queue)
            dispatch_async(_queue, b);
        else
            b();
        
    
        FMDBRelease(self);
    }
    
    - (void)inDatabaseWithDealocing:(void (^)(FMDatabase *db))block {
        FMDBRetain(self);
        
        dispatch_block_t eblock = ^{
            FMDatabase *db = [self database];
            block(db);
            
            if ([db hasOpenResultSets]) {
                MTLog(@"Warning: there is at least one open result set around after performing [FMDatabaseQueue inDatabase:]");
            }
        };
        
        if(dispatch_get_current_queue() == _queue) {
            eblock();
        } else {
            dispatch_sync(_queue, eblock);
        }
        
        FMDBRelease(self);
    }
    
    
    - (void)beginTransaction:(BOOL)useDeferred withBlock:(void (^)(FMDatabase *db, BOOL *rollback))block {
        FMDBRetain(self);
        dispatch_sync(_queue, ^() {
            
            BOOL shouldRollback = NO;
            
            if (useDeferred) {
                [[self database] beginDeferredTransaction];
            }
            else {
                [[self database] beginTransaction];
            }
            
            block([self database], &shouldRollback);
            
            if (shouldRollback) {
                [[self database] rollback];
            }
            else {
                [[self database] commit];
            }
        });
        
        FMDBRelease(self);
    }
    
    - (void)inDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
        [self beginTransaction:YES withBlock:block];
    }
    
    - (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
        [self beginTransaction:NO withBlock:block];
    }
    
#if SQLITE_VERSION_NUMBER >= 3007000
    - (NSError*)inSavePoint:(void (^)(FMDatabase *db, BOOL *rollback))block {
        
        static unsigned long savePointIdx = 0;
        __block NSError *err = 0x00;
        FMDBRetain(self);
        dispatch_sync(_queue, ^() {
            
            NSString *name = [NSString stringWithFormat:@"savePoint%ld", savePointIdx++];
            
            BOOL shouldRollback = NO;
            
            if ([[self database] startSavePointWithName:name error:&err]) {
                
                block([self database], &shouldRollback);
                
                if (shouldRollback) {
                    // We need to rollback and release this savepoint to remove it
                    [[self database] rollbackToSavePointWithName:name error:&err];
                }
                [[self database] releaseSavePointWithName:name error:&err];
                
            }
        });
        FMDBRelease(self);
        return err;
    }
#endif
    
    @end
