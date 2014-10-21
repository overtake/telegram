#import "YapDatabaseSecondaryIndexConnection.h"
#import "YapDatabaseSecondaryIndexPrivate.h"

#import "YapDatabasePrivate.h"
#import "YapDatabaseExtensionPrivate.h"
#import "YapDataBaseDictionary.h"
#import "YapDatabaseLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

/**
 * Define log level for this file: OFF, ERROR, WARN, INFO, VERBOSE
 * See YapDatabaseLogging.h for more information.
 **/
#if DEBUG
static const int ydbLogLevel = YDB_LOG_LEVEL_WARN;
#else
static const int ydbLogLevel = YDB_LOG_LEVEL_WARN;
#endif

@implementation YapDatabaseSecondaryIndexConnection
{
	sqlite3_stmt *insertStatement;
	sqlite3_stmt *updateStatement;
	sqlite3_stmt *removeStatement;
	sqlite3_stmt *removeAllStatement;
}

@synthesize secondaryIndex = secondaryIndex;

- (id)initWithSecondaryIndex:(YapDatabaseSecondaryIndex *)inSecondaryIndex
          databaseConnection:(YapDatabaseConnection *)inDatabaseConnection
{
	if ((self = [super init]))
	{
		secondaryIndex = inSecondaryIndex;
		databaseConnection = inDatabaseConnection;
		
		queryCacheLimit = 10;
		queryCache = [[YapCache alloc] initWithKeyClass:[NSString class] countLimit:queryCacheLimit];
	}
	return self;
}

- (void)dealloc
{
	[queryCache removeAllObjects];
	
	sqlite_finalize_null(&insertStatement);
	sqlite_finalize_null(&updateStatement);
	sqlite_finalize_null(&removeStatement);
	sqlite_finalize_null(&removeAllStatement);
}

/**
 * Required override method from YapDatabaseExtensionConnection
**/
- (void)_flushMemoryWithLevel:(int)level
{
	if (level >= YapDatabaseConnectionFlushMemoryLevelMild)
	{
		[queryCache removeAllObjects];
	}
	
	if (level >= YapDatabaseConnectionFlushMemoryLevelModerate)
	{
		sqlite_finalize_null(&insertStatement);
		sqlite_finalize_null(&updateStatement);
		sqlite_finalize_null(&removeStatement);
		sqlite_finalize_null(&removeAllStatement);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Required override method from YapDatabaseExtensionConnection.
**/
- (YapDatabaseExtension *)extension
{
	return secondaryIndex;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)queryCacheEnabled
{
	__block BOOL result = NO;
	
	dispatch_block_t block = ^{
		
		result = (queryCache == nil) ? NO : YES;
	};
	
	if (dispatch_get_specific(databaseConnection->IsOnConnectionQueueKey))
		block();
	else
		dispatch_sync(databaseConnection->connectionQueue, block);
	
	return result;
}

- (void)setQueryCacheEnabled:(BOOL)queryCacheEnabled
{
	dispatch_block_t block = ^{
		
		if (queryCacheEnabled)
		{
			if (queryCache == nil)
				queryCache = [[YapCache alloc] initWithKeyClass:[NSString class] countLimit:queryCacheLimit];
		}
		else
		{
			queryCache = nil;
		}
	};
	
	if (dispatch_get_specific(databaseConnection->IsOnConnectionQueueKey))
		block();
	else
		dispatch_async(databaseConnection->connectionQueue, block);
}

- (NSUInteger)queryCacheLimit
{
	__block NSUInteger result = 0;
	
	dispatch_block_t block = ^{
		
		result = queryCacheLimit;
	};
	
	if (dispatch_get_specific(databaseConnection->IsOnConnectionQueueKey))
		block();
	else
		dispatch_sync(databaseConnection->connectionQueue, block);
	
	return result;
}

- (void)setQueryCacheLimit:(NSUInteger)newQueryCacheLimit
{
	dispatch_block_t block = ^{
		
		queryCacheLimit = newQueryCacheLimit;
		queryCache.countLimit = queryCacheLimit;
	};
	
	if (dispatch_get_specific(databaseConnection->IsOnConnectionQueueKey))
		block();
	else
		dispatch_async(databaseConnection->connectionQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Transactions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Required override method from YapDatabaseExtensionConnection.
**/
- (id)newReadTransaction:(YapDatabaseReadTransaction *)databaseTransaction
{
	YapDatabaseSecondaryIndexTransaction *transaction =
	    [[YapDatabaseSecondaryIndexTransaction alloc]
	        initWithSecondaryIndexConnection:self
	                     databaseTransaction:databaseTransaction];
	
	return transaction;
}

/**
 * Required override method from YapDatabaseExtensionConnection.
**/
- (id)newReadWriteTransaction:(YapDatabaseReadWriteTransaction *)databaseTransaction
{
	YapDatabaseSecondaryIndexTransaction *transaction =
	    [[YapDatabaseSecondaryIndexTransaction alloc]
	        initWithSecondaryIndexConnection:self
	                     databaseTransaction:databaseTransaction];
	
	if (blockDict == nil)
		blockDict = [NSMutableDictionary dictionaryWithSharedKeySetNew:secondaryIndex->columnNamesSharedKeySet];
	
	return transaction;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Changeset
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Required override method from YapDatabaseExtension
**/
- (void)getInternalChangeset:(NSMutableDictionary **)internalChangesetPtr
           externalChangeset:(NSMutableDictionary **)externalChangesetPtr
              hasDiskChanges:(BOOL *)hasDiskChangesPtr
{
	// Nothing to do for this particular extension.
	//
	// YapDatabaseExtension throws a "not implemented" exception
	// to ensure extensions have implementations of all required methods.
}

/**
 * Required override method from YapDatabaseExtension
**/
- (void)processChangeset:(NSDictionary *)changeset
{
	// Nothing to do for this particular extension.
	//
	// YapDatabaseExtension throws a "not implemented" exception
	// to ensure extensions have implementations of all required methods.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Statements
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (sqlite3_stmt *)insertStatement
{
	if (insertStatement == NULL)
	{
		NSMutableString *string = [NSMutableString stringWithCapacity:100];
		[string appendFormat:@"INSERT INTO \"%@\" (\"rowid\"", [secondaryIndex tableName]];
		
		for (YapDatabaseSecondaryIndexColumn *column in secondaryIndex->setup)
		{
			[string appendFormat:@", \"%@\"", column.name];
		}
		
		[string appendString:@") VALUES (?"];
		
		NSUInteger count = [secondaryIndex->setup count];
		NSUInteger i;
		for (i = 0; i < count; i++)
		{
			[string appendString:@", ?"];
		}
		
		[string appendString:@");"];
		
		sqlite3 *db = databaseConnection->db;
		
		int status = sqlite3_prepare_v2(db, [string UTF8String], -1, &insertStatement, NULL);
		if (status != SQLITE_OK)
		{
			YDBLogError(@"%@: Error creating prepared statement: %d %s", THIS_METHOD, status, sqlite3_errmsg(db));
		}
	}
	
	return insertStatement;
}

- (sqlite3_stmt *)updateStatement
{
	if (updateStatement == NULL)
	{
		NSMutableString *string = [NSMutableString stringWithCapacity:100];
		[string appendFormat:@"UPDATE \"%@\" SET ", [secondaryIndex tableName]];
		
		NSUInteger i = 0;
		for (YapDatabaseSecondaryIndexColumn *column in secondaryIndex->setup)
		{
			if (i == 0)
				[string appendFormat:@"\"%@\" = ?", column.name];
			else
				[string appendFormat:@", \"%@\" = ?", column.name];
			
			i++;
		}
		
		[string appendString:@" WHERE rowid = ?;"];
		
		sqlite3 *db = databaseConnection->db;
		
		int status = sqlite3_prepare_v2(db, [string UTF8String], -1, &updateStatement, NULL);
		if (status != SQLITE_OK)
		{
			YDBLogError(@"%@: Error creating prepared statement: %d %s", THIS_METHOD, status, sqlite3_errmsg(db));
		}
	}
	
	return updateStatement;
}

- (sqlite3_stmt *)removeStatement
{
	if (removeStatement == NULL)
	{
		NSString *string =
		    [NSString stringWithFormat:@"DELETE FROM \"%@\" WHERE \"rowid\" = ?;", [secondaryIndex tableName]];
		
		sqlite3 *db = databaseConnection->db;
		
		int status = sqlite3_prepare_v2(db, [string UTF8String], -1, &removeStatement, NULL);
		if (status != SQLITE_OK)
		{
			YDBLogError(@"%@: Error creating prepared statement: %d %s", THIS_METHOD, status, sqlite3_errmsg(db));
		}
	}
	
	return removeStatement;
}

- (sqlite3_stmt *)removeAllStatement
{
	if (removeAllStatement == NULL)
	{
		NSString *string = [NSString stringWithFormat:@"DELETE FROM \"%@\";", [secondaryIndex tableName]];
		
		sqlite3 *db = databaseConnection->db;
		
		int status = sqlite3_prepare_v2(db, [string UTF8String], -1, &removeAllStatement, NULL);
		if (status != SQLITE_OK)
		{
			YDBLogError(@"%@: Error creating prepared statement: %d %s", THIS_METHOD, status, sqlite3_errmsg(db));
		}
	}
	
	return removeAllStatement;
}

@end
