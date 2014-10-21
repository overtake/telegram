#import <Foundation/Foundation.h>

#import "YapDatabase.h"
#import "YapDatabaseDefaults.h"
#import "YapDatabaseConnection.h"
#import "YapDatabaseTransaction.h"
#import "YapDatabaseExtension.h"

#import "YapCache.h"
#import "YapMemoryTable.h"

#import "sqlite3.h"

/**
 * Helper method to conditionally invoke sqlite3_finalize on a statement, and then set the ivar to NULL.
**/
NS_INLINE void sqlite_finalize_null(sqlite3_stmt **stmtPtr)
{
	if (*stmtPtr) {
		sqlite3_finalize(*stmtPtr);
		*stmtPtr = NULL;
	}
}

extern NSString *const YapDatabaseRegisteredExtensionsKey;
extern NSString *const YapDatabaseRegisteredTablesKey;
extern NSString *const YapDatabaseExtensionsOrderKey;
extern NSString *const YapDatabaseNotificationKey;

@interface YapDatabase () {
@private
	
	NSMutableArray *changesets;
	uint64_t snapshot;
	
	dispatch_queue_t internalQueue;
	dispatch_queue_t checkpointQueue;
	
	YapDatabaseDefaults *defaults;
	
	NSDictionary *registeredExtensions;
	NSDictionary *registeredTables;
	
	NSDictionary *extensionDependencies;
	NSArray *extensionsOrder;
	
	YapDatabaseConnection *registrationConnection;
	
	NSUInteger maxConnectionPoolCount;
	NSTimeInterval connectionPoolLifetime;
	dispatch_source_t connectionPoolTimer;
	NSMutableArray *connectionPoolValues;
	NSMutableArray *connectionPoolDates;
	
	sqlite3 *db; // Used for setup & checkpoints
	
@public
	
	void *IsOnSnapshotQueueKey;       // Only to be used by YapDatabaseConnection
	void *IsOnWriteQueueKey;          // Only to be used by YapDatabaseConnection
	
	dispatch_queue_t snapshotQueue;   // Only to be used by YapDatabaseConnection
	dispatch_queue_t writeQueue;      // Only to be used by YapDatabaseConnection
	
	NSMutableArray *connectionStates; // Only to be used by YapDatabaseConnection
	
	NSArray *previouslyRegisteredExtensionNames; // Only to be used by YapDatabaseConnection
	
	YapDatabaseSerializer objectSerializer;       // Read-only by transactions
	YapDatabaseDeserializer objectDeserializer;   // Read-only by transactions
	
	YapDatabaseSerializer metadataSerializer;     // Read-only by transactions
	YapDatabaseDeserializer metadataDeserializer; // Read-only by transactions
	
	YapDatabaseSanitizer objectSanitizer;         // Read-only by transactions
	YapDatabaseSanitizer metadataSanitizer;       // Read-only by transactions
}

/**
 * General utility methods.
**/
- (BOOL)tableExists:(NSString *)tableName using:(sqlite3 *)aDb;
- (NSArray *)columnNamesForTable:(NSString *)tableName using:(sqlite3 *)aDb;

/**
 * New connections inherit their default values from this structure.
**/
- (YapDatabaseDefaults *)defaults;

/**
 * Called from YapDatabaseConnection's dealloc method to remove connection's state from connectionStates array.
**/
- (void)removeConnection:(YapDatabaseConnection *)connection;

/**
 * YapDatabaseConnection uses these methods to recycle sqlite3 instances using the connection pool.
**/
- (BOOL)connectionPoolEnqueue:(sqlite3 *)aDb;
- (sqlite3 *)connectionPoolDequeue;

/**
 * These methods are only accessible from within the snapshotQueue.
 * Used by [YapDatabaseConnection prepare].
**/
- (NSDictionary *)registeredTables;
- (NSArray *)extensionsOrder;

/**
 * This method is only accessible from within the snapshotQueue.
 * 
 * Prior to starting the sqlite commit, the connection must report its changeset to the database.
 * The database will store the changeset, and provide it to other connections if needed (due to a race condition).
 * 
 * The following MUST be in the dictionary:
 *
 * - snapshot : NSNumber with the changeset's snapshot
**/
- (void)notePendingChanges:(NSDictionary *)changeset fromConnection:(YapDatabaseConnection *)connection;

/**
 * This method is only accessible from within the snapshotQueue.
 * 
 * This method is used if a transaction finds itself in a race condition.
 * That is, the transaction started before it was able to process changesets from sibling connections.
 * 
 * It should fetch the changesets needed and then process them via [connection noteCommittedChanges:].
**/
- (NSArray *)pendingAndCommittedChangesSince:(uint64_t)connectionSnapshot until:(uint64_t)maxSnapshot;

/**
 * This method is only accessible from within the snapshotQueue.
 * 
 * Upon completion of a readwrite transaction, the connection must report its changeset to the database.
 * The database will then forward the changeset to all other connections.
 * 
 * The following MUST be in the dictionary:
 * 
 * - snapshot : NSNumber with the changeset's snapshot
**/
- (void)noteCommittedChanges:(NSDictionary *)changeset fromConnection:(YapDatabaseConnection *)connection;

/**
 * This method should be called whenever the maximum checkpointable snapshot is incremented.
 * That is, the state of every connection is known to the system.
 * And a snaphot cannot be checkpointed until every connection is at or past that snapshot.
 * Thus, we can know the point at which a snapshot becomes checkpointable,
 * and we can thus optimize the checkpoint invocations such that
 * each invocation is able to checkpoint one or more commits.
**/
- (void)asyncCheckpoint:(uint64_t)maxCheckpointableSnapshot;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface YapDatabaseConnection () {
@private
	uint64_t snapshot;
	
	id sharedKeySetForInternalChangeset;
	id sharedKeySetForExternalChangeset;
	
	YapDatabaseReadTransaction *longLivedReadTransaction;
	BOOL throwExceptionsForImplicitlyEndingLongLivedReadTransaction;
	NSMutableArray *pendingChangesets;
	NSMutableArray *processedChangesets;
	
	NSDictionary *registeredExtensions;
	BOOL registeredExtensionsChanged;
	
	NSDictionary *registeredTables;
	BOOL registeredTablesChanged;
	
	NSMutableDictionary *extensions;
	BOOL extensionsReady;
	id sharedKeySetForExtensions;
	
@public
	__strong YapDatabase *database;
	
	sqlite3 *db;
	
	dispatch_queue_t connectionQueue;     // Only for YapDatabaseExtensionConnection subclasses
	void *IsOnConnectionQueueKey;         // Only for YapDatabaseExtensionConnection subclasses
	
	NSArray *extensionsOrder;             // Read-only by YapDatabaseTransaction
	
	BOOL hasDiskChanges;
	
	YapCache *objectCache;
	YapCache *metadataCache;
	
	NSUInteger objectCacheLimit;          // Read-only by transaction. Use as consideration of whether to add to cache.
	NSUInteger metadataCacheLimit;        // Read-only by transaction. Use as consideration of whether to add to cache.
	
	YapDatabasePolicy objectPolicy;       // Read-only by transaction. Use to determine what goes in objectChanges.
	YapDatabasePolicy metadataPolicy;     // Read-only by transaction. Use to determine what goes in metadataChanges.
	
	BOOL needsMarkSqlLevelSharedReadLock; // Read-only by transaction. Use as consideration of whether to invoke method.
	
	NSMutableDictionary *objectChanges;
	NSMutableDictionary *metadataChanges;
	NSMutableSet *removedKeys;
	NSMutableSet *removedCollections;
	BOOL allKeysRemoved;
}

- (id)initWithDatabase:(YapDatabase *)database;

- (sqlite3_stmt *)beginTransactionStatement;
- (sqlite3_stmt *)commitTransactionStatement;
- (sqlite3_stmt *)rollbackTransactionStatement;

- (sqlite3_stmt *)yapGetDataForKeyStatement;   // Against "yap" database, for internal use
- (sqlite3_stmt *)yapSetDataForKeyStatement;   // Against "yap" database, for internal use
- (sqlite3_stmt *)yapRemoveExtensionStatement; // Against "yap" database, for internal use

- (sqlite3_stmt *)getCollectionCountStatement;
- (sqlite3_stmt *)getKeyCountForCollectionStatement;
- (sqlite3_stmt *)getKeyCountForAllStatement;
- (sqlite3_stmt *)getCountForRowidStatement;
- (sqlite3_stmt *)getRowidForKeyStatement;
- (sqlite3_stmt *)getKeyForRowidStatement;
- (sqlite3_stmt *)getKeyDataForRowidStatement;
- (sqlite3_stmt *)getKeyMetadataForRowidStatement;
- (sqlite3_stmt *)getDataForRowidStatement;
- (sqlite3_stmt *)getAllForRowidStatement;
- (sqlite3_stmt *)getDataForKeyStatement;
- (sqlite3_stmt *)getMetadataForKeyStatement;
- (sqlite3_stmt *)getAllForKeyStatement;
- (sqlite3_stmt *)insertForRowidStatement;
- (sqlite3_stmt *)updateAllForRowidStatement;
- (sqlite3_stmt *)updateMetadataForRowidStatement;
- (sqlite3_stmt *)removeForRowidStatement;
- (sqlite3_stmt *)removeCollectionStatement;
- (sqlite3_stmt *)removeAllStatement;
- (sqlite3_stmt *)enumerateCollectionsStatement;
- (sqlite3_stmt *)enumerateCollectionsForKeyStatement;
- (sqlite3_stmt *)enumerateKeysInCollectionStatement;
- (sqlite3_stmt *)enumerateKeysInAllCollectionsStatement;
- (sqlite3_stmt *)enumerateKeysAndMetadataInCollectionStatement;
- (sqlite3_stmt *)enumerateKeysAndMetadataInAllCollectionsStatement;
- (sqlite3_stmt *)enumerateKeysAndObjectsInCollectionStatement;
- (sqlite3_stmt *)enumerateKeysAndObjectsInAllCollectionsStatement;
- (sqlite3_stmt *)enumerateRowsInCollectionStatement;
- (sqlite3_stmt *)enumerateRowsInAllCollectionsStatement;

- (void)prepare;

- (NSDictionary *)extensions;

- (BOOL)registerExtension:(YapDatabaseExtension *)extension withName:(NSString *)extensionName;
- (void)unregisterExtension:(NSString *)extensionName;

- (NSDictionary *)registeredTables;

- (BOOL)registerTable:(YapMemoryTable *)table withName:(NSString *)name;
- (void)unregisterTableWithName:(NSString *)name;

- (YapDatabaseReadTransaction *)newReadTransaction;
- (YapDatabaseReadWriteTransaction *)newReadWriteTransaction;

- (void)markSqlLevelSharedReadLockAcquired;

- (void)postRollbackCleanup;

- (NSArray *)internalChangesetKeys;
- (NSArray *)externalChangesetKeys;
- (void)getInternalChangeset:(NSMutableDictionary **)internalPtr externalChangeset:(NSMutableDictionary **)externalPtr;
- (void)processChangeset:(NSDictionary *)changeset;

- (void)noteCommittedChanges:(NSDictionary *)changeset;

- (void)maybeResetLongLivedReadTransaction;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface YapDatabaseReadTransaction () {
@private
	
	NSMutableDictionary *extensions;
	NSMutableArray *orderedExtensions;
	BOOL extensionsReady;

@protected
	BOOL isMutated; // Used for "mutation during enumeration" protection
	
@public
	__unsafe_unretained YapDatabaseConnection *connection;
	
	BOOL isReadWriteTransaction;
	BOOL rollback;
	id customObjectForNotification;
}

- (id)initWithConnection:(YapDatabaseConnection *)connection isReadWriteTransaction:(BOOL)flag;

- (void)beginTransaction;
- (void)preCommitReadWriteTransaction;
- (void)commitTransaction;
- (void)rollbackTransaction;

- (NSDictionary *)extensions;
- (NSArray *)orderedExtensions;

- (YapMemoryTableTransaction *)memoryTableTransaction:(NSString *)tableName;

- (void)addRegisteredExtensionTransaction:(YapDatabaseExtensionTransaction *)extTransaction;
- (void)removeRegisteredExtensionTransaction:(NSString *)extName;


- (BOOL)getBoolValue:(BOOL *)valuePtr forKey:(NSString *)key extension:(NSString *)extensionName;
- (void)setBoolValue:(BOOL)value forKey:(NSString *)key extension:(NSString *)extensionName;

- (BOOL)getIntValue:(int *)valuePtr forKey:(NSString *)key extension:(NSString *)extensionName;
- (void)setIntValue:(int)value forKey:(NSString *)key extension:(NSString *)extensionName;

- (BOOL)getDoubleValue:(double *)valuePtr forKey:(NSString *)key extension:(NSString *)extensionName;
- (void)setDoubleValue:(double)value forKey:(NSString *)key extension:(NSString *)extensionName;

- (NSString *)stringValueForKey:(NSString *)key extension:(NSString *)extensionName;
- (void)setStringValue:(NSString *)value forKey:(NSString *)key extension:(NSString *)extensionName;

- (NSData *)dataValueForKey:(NSString *)key extension:(NSString *)extensionName;
- (void)setDataValue:(NSData *)value forKey:(NSString *)key extension:(NSString *)extensionName;

- (void)removeAllValuesForExtension:(NSString *)extensionName;

- (NSException *)mutationDuringEnumerationException;

- (BOOL)getRowid:(int64_t *)rowidPtr forKey:(NSString *)key inCollection:(NSString *)collection;

- (BOOL)getKey:(NSString **)keyPtr collection:(NSString **)collectionPtr forRowid:(int64_t)rowid;

- (BOOL)getKey:(NSString **)keyPtr
    collection:(NSString **)collectionPtr
        object:(id *)objectPtr
      forRowid:(int64_t)rowid;

- (BOOL)getKey:(NSString **)keyPtr
    collection:(NSString **)collectionPtr
      metadata:(id *)metadataPtr
      forRowid:(int64_t)rowid;

- (BOOL)getKey:(NSString **)keyPtr
    collection:(NSString **)collectionPtr
        object:(id *)objectPtr
      metadata:(id *)metadataPtr
      forRowid:(int64_t)rowid;

- (BOOL)hasRowForRowid:(int64_t)rowid;

- (id)objectForKey:(NSString *)key inCollection:(NSString *)collection withRowid:(int64_t)rowid;

- (void)_enumerateKeysInCollection:(NSString *)collection
                        usingBlock:(void (^)(int64_t rowid, NSString *key, BOOL *stop))block;

- (void)_enumerateKeysInCollections:(NSArray *)collections
                         usingBlock:(void (^)(int64_t rowid, NSString *collection, NSString *key, BOOL *stop))block;

- (void)_enumerateKeysInAllCollectionsUsingBlock:
                            (void (^)(int64_t rowid, NSString *collection, NSString *key, BOOL *stop))block;

- (void)_enumerateKeysAndMetadataInCollection:(NSString *)collection
                                   usingBlock:(void (^)(int64_t rowid, NSString *key, id metadata, BOOL *stop))block;
- (void)_enumerateKeysAndMetadataInCollection:(NSString *)collection
                                   usingBlock:(void (^)(int64_t rowid, NSString *key, id metadata, BOOL *stop))block
                                   withFilter:(BOOL (^)(int64_t rowid, NSString *key))filter;

- (void)_enumerateKeysAndMetadataInCollections:(NSArray *)collections
                usingBlock:(void (^)(int64_t rowid, NSString *collection, NSString *key, id metadata, BOOL *stop))block;
- (void)_enumerateKeysAndMetadataInCollections:(NSArray *)collections
                usingBlock:(void (^)(int64_t rowid, NSString *collection, NSString *key, id metadata, BOOL *stop))block
                withFilter:(BOOL (^)(int64_t rowid, NSString *collection, NSString *key))filter;

- (void)_enumerateKeysAndMetadataInAllCollectionsUsingBlock:
                        (void (^)(int64_t rowid, NSString *collection, NSString *key, id metadata, BOOL *stop))block;
- (void)_enumerateKeysAndMetadataInAllCollectionsUsingBlock:
                        (void (^)(int64_t rowid, NSString *collection, NSString *key, id metadata, BOOL *stop))block
             withFilter:(BOOL (^)(int64_t rowid, NSString *collection, NSString *key))filter;

- (void)_enumerateKeysAndObjectsInCollection:(NSString *)collection
                                  usingBlock:(void (^)(int64_t rowid, NSString *key, id object, BOOL *stop))block;
- (void)_enumerateKeysAndObjectsInCollection:(NSString *)collection
                                  usingBlock:(void (^)(int64_t rowid, NSString *key, id object, BOOL *stop))block
                                  withFilter:(BOOL (^)(int64_t rowid, NSString *key))filter;

- (void)_enumerateKeysAndObjectsInCollections:(NSArray *)collections
                 usingBlock:(void (^)(int64_t rowid, NSString *collection, NSString *key, id object, BOOL *stop))block;
- (void)_enumerateKeysAndObjectsInCollections:(NSArray *)collections
                 usingBlock:(void (^)(int64_t rowid, NSString *collection, NSString *key, id object, BOOL *stop))block
                 withFilter:(BOOL (^)(int64_t rowid, NSString *collection, NSString *key))filter;

- (void)_enumerateKeysAndObjectsInAllCollectionsUsingBlock:
                            (void (^)(int64_t rowid, NSString *collection, NSString *key, id object, BOOL *stop))block;
- (void)_enumerateKeysAndObjectsInAllCollectionsUsingBlock:
                            (void (^)(int64_t rowid, NSString *collection, NSString *key, id object, BOOL *stop))block
                 withFilter:(BOOL (^)(int64_t rowid, NSString *collection, NSString *key))filter;

- (void)_enumerateRowsInCollection:(NSString *)collection
                        usingBlock:(void (^)(int64_t rowid, NSString *key, id object, id metadata, BOOL *stop))block;
- (void)_enumerateRowsInCollection:(NSString *)collection
                        usingBlock:(void (^)(int64_t rowid, NSString *key, id object, id metadata, BOOL *stop))block
                        withFilter:(BOOL (^)(int64_t rowid, NSString *key))filter;

- (void)_enumerateRowsInCollections:(NSArray *)collections
     usingBlock:(void (^)(int64_t rowid, NSString *collection, NSString *key, id object, id metadata, BOOL *stop))block;
- (void)_enumerateRowsInCollections:(NSArray *)collections
     usingBlock:(void (^)(int64_t rowid, NSString *collection, NSString *key, id object, id metadata, BOOL *stop))block
     withFilter:(BOOL (^)(int64_t rowid, NSString *collection, NSString *key))filter;

- (void)_enumerateRowsInAllCollectionsUsingBlock:
                (void (^)(int64_t rowid, NSString *collection, NSString *key, id object, id metadata, BOOL *stop))block;
- (void)_enumerateRowsInAllCollectionsUsingBlock:
                (void (^)(int64_t rowid, NSString *collection, NSString *key, id object, id metadata, BOOL *stop))block
     withFilter:(BOOL (^)(int64_t rowid, NSString *collection, NSString *key))filter;

@end
