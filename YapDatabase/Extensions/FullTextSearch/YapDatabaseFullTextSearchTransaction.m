#import "YapDatabaseFullTextSearchTransaction.h"
#import "YapDatabaseFullTextSearchPrivate.h"
#import "YapDatabaseExtensionPrivate.h"
#import "YapDatabasePrivate.h"
#import "YapDatabaseString.h"
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

/**
 * This version number is stored in the yap2 table.
 * If there is a major re-write to this class, then the version number will be incremented,
 * and the class can automatically rebuild the tables as needed.
**/
#define YAP_DATABASE_FTS_CLASS_VERSION 1


@implementation YapDatabaseFullTextSearchTransaction

- (id)initWithFTSConnection:(YapDatabaseFullTextSearchConnection *)inFTSConnection
        databaseTransaction:(YapDatabaseReadTransaction *)inDatabaseTransaction
{
	if ((self = [super init]))
	{
		ftsConnection = inFTSConnection;
		databaseTransaction = inDatabaseTransaction;
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Extension Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Required override method from YapDatabaseExtensionTransaction.
 *
 * This method is called to create any necessary tables (if needed),
 * as well as populate the view (if needed) by enumerating over the existing rows in the database.
**/
- (BOOL)createIfNeeded
{
	int oldClassVersion = [self intValueForExtensionKey:@"classVersion"];
	int classVersion = YAP_DATABASE_FTS_CLASS_VERSION;
	
	if (oldClassVersion != classVersion)
	{
		// First time registration
		
		[self upgradeFromForOldClassVersion:oldClassVersion];
		
		if (![self createTable]) return NO;
		if (![self populate]) return NO;
		
		[self setIntValue:classVersion forExtensionKey:@"classVersion"];
		
		int userSuppliedConfigVersion = ftsConnection->fts->version;
		[self setIntValue:userSuppliedConfigVersion forExtensionKey:@"version"];
	}
	else
	{
		// Check user-supplied config version.
		// We may need to re-populate the database if the groupingBlock or sortingBlock changed.
		
		int oldVersion = [self intValueForExtensionKey:@"version"];
		int newVersion = ftsConnection->fts->version;
		
		if (oldVersion != newVersion)
		{
			if (![self dropTable]) return NO;
			if (![self createTable]) return NO;
			if (![self populate]) return NO;
			
			[self setIntValue:newVersion forExtensionKey:@"version"];
		}
	}
	
	return YES;
}

/**
 * Required override method from YapDatabaseExtensionTransaction.
 *
 * This method is called to prepare the transaction for use.
 *
 * Remember, an extension transaction is a very short lived object.
 * Thus it stores the majority of its state within the extension connection (the parent).
 *
 * Return YES if completed successfully, or if already prepared.
 * Return NO if some kind of error occured.
**/
- (BOOL)prepareIfNeeded
{
	return YES;
}

/**
 * Internal method.
 *
 * This method is used to handle the upgrade process from earlier architectures of this class.
**/
- (void)upgradeFromForOldClassVersion:(int)oldClassVersion
{
	// Reserved for future use...
}

/**
 * Internal method.
 *
 * This method is called, if needed, to drop the old table.
**/
- (BOOL)dropTable
{
	sqlite3 *db = databaseTransaction->connection->db;
	
	NSString *tableName = [self tableName];
	NSString *dropTable = [NSString stringWithFormat:@"DROP TABLE IF EXISTS \"%@\";", tableName];
	
	int status = sqlite3_exec(db, [dropTable UTF8String], NULL, NULL, NULL);
	if (status != SQLITE_OK)
	{
		YDBLogError(@"%@ - Failed dropping FTS table (%@): %d %s",
		            THIS_METHOD, dropTable, status, sqlite3_errmsg(db));
		return NO;
	}
	
	return YES;
}

/**
 * Internal method.
 * 
 * This method is called, if needed, to create the tables for the view.
**/
- (BOOL)createTable
{
	sqlite3 *db = databaseTransaction->connection->db;
	
	NSString *tableName = [self tableName];
	
	YDBLogVerbose(@"Creating FTS table for registeredName(%@): %@", [self registeredName], tableName);
	
	// CREATE VIRTUAL TABLE pages USING fts4(column1, column2, column3);
	
	NSMutableString *createTable = [NSMutableString stringWithCapacity:100];
	[createTable appendFormat:@"CREATE VIRTUAL TABLE IF NOT EXISTS \"%@\" USING fts4(", tableName];
	
	__block NSUInteger i = 0;
	
	NSOrderedSet *columnNames = ftsConnection->fts->columnNames;
	for (NSString *columnName in columnNames)
	{
		if (i == 0)
			[createTable appendFormat:@"\"%@\"", columnName];
		else
			[createTable appendFormat:@", \"%@\"", columnName];
		
		i++;
	}
	
	NSDictionary *options = ftsConnection->fts->options;
	[options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		NSString *option = (NSString *)key;
		NSString *value = (NSString *)obj;
		
		if (i == 0)
			[createTable appendFormat:@"%@=%@", option, value];
		else
			[createTable appendFormat:@", %@=%@", option, value];
		
		i++;
	}];
	
	[createTable appendString:@");"];
	
	int status = sqlite3_exec(db, [createTable UTF8String], NULL, NULL, NULL);
	if (status != SQLITE_OK)
	{
		YDBLogError(@"%@ - Failed creating FTS table (%@): %d %s",
		            THIS_METHOD, tableName, status, sqlite3_errmsg(db));
		return NO;
	}
	
	return YES;
}

/**
 * Internal method.
 *
 * This method is called, if needed, to populate the FTS indexes.
 * It does so by enumerating the rows in the database, and invoking the usual blocks and insertion methods.
**/
- (BOOL)populate
{
	// Remove everything from the database
	
	[self removeAllRowids];
	
	// Enumerate the existing rows in the database and populate the indexes
	
	__unsafe_unretained YapDatabaseFullTextSearch *fts = ftsConnection->fts;
	
	BOOL needsObject = fts->blockType == YapDatabaseFullTextSearchBlockTypeWithObject ||
	                   fts->blockType == YapDatabaseFullTextSearchBlockTypeWithRow;
	
	BOOL needsMetadata = fts->blockType == YapDatabaseFullTextSearchBlockTypeWithMetadata ||
	                     fts->blockType == YapDatabaseFullTextSearchBlockTypeWithRow;
	
	if (needsObject && needsMetadata)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithRowBlock block =
		    (YapDatabaseFullTextSearchWithRowBlock)fts->block;
		
		[databaseTransaction _enumerateRowsInAllCollectionsUsingBlock:
		    ^(int64_t rowid, NSString *collection, NSString *key, id object, id metadata, BOOL *stop) {
			
			block(ftsConnection->blockDict, collection, key, object, metadata);
			
			if ([ftsConnection->blockDict count] > 0)
			{
				[self addRowid:rowid isNew:YES];
				[ftsConnection->blockDict removeAllObjects];
			}
		}];
	}
	else if (needsObject && !needsMetadata)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithObjectBlock block =
		    (YapDatabaseFullTextSearchWithObjectBlock)fts->block;
		
		[databaseTransaction _enumerateKeysAndObjectsInAllCollectionsUsingBlock:
		    ^(int64_t rowid, NSString *collection, NSString *key, id object, BOOL *stop) {
			
			block(ftsConnection->blockDict, collection, key, object);
			
			if ([ftsConnection->blockDict count] > 0)
			{
				[self addRowid:rowid isNew:YES];
				[ftsConnection->blockDict removeAllObjects];
			}
		}];
	}
	else if (!needsObject && needsMetadata)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithMetadataBlock block =
		    (YapDatabaseFullTextSearchWithMetadataBlock)fts->block;
		
		[databaseTransaction _enumerateKeysAndMetadataInAllCollectionsUsingBlock:
		    ^(int64_t rowid, NSString *collection, NSString *key, id metadata, BOOL *stop) {
			
			block(ftsConnection->blockDict, collection, key, metadata);
			
			if ([ftsConnection->blockDict count] > 0)
			{
				[self addRowid:rowid isNew:YES];
				[ftsConnection->blockDict removeAllObjects];
			}
		}];
	}
	else // if (!needsObject && !needsMetadata)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithKeyBlock block =
		    (YapDatabaseFullTextSearchWithKeyBlock)fts->block;
		
		[databaseTransaction _enumerateKeysInAllCollectionsUsingBlock:
		    ^(int64_t rowid, NSString *collection, NSString *key, BOOL *stop) {
			
			block(ftsConnection->blockDict, collection, key);
			
			if ([ftsConnection->blockDict count] > 0)
			{
				[self addRowid:rowid isNew:YES];
				[ftsConnection->blockDict removeAllObjects];
			}
		}];
	}
	
	return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Required override method from YapDatabaseExtensionTransaction.
**/
- (YapDatabaseReadTransaction *)databaseTransaction
{
	return databaseTransaction;
}

/**
 * Required override method from YapDatabaseExtensionTransaction.
**/
- (YapDatabaseExtensionConnection *)extensionConnection
{
	return ftsConnection;
}

- (NSString *)registeredName
{
	return [ftsConnection->fts registeredName];
}

- (NSString *)tableName
{
	return [ftsConnection->fts tableName];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logic
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addRowid:(int64_t)rowid isNew:(BOOL)isNew
{
	YDBLogAutoTrace();
	
	sqlite3_stmt *statement = NULL;
	if (isNew)
		statement = [ftsConnection insertRowidStatement];
	else
		statement = [ftsConnection setRowidStatement];
	
	if (statement == NULL)
		return;
	
	//  isNew : INSERT INTO "tableName" ("rowid", "column1", "column2", ...) VALUES (?, ?, ? ...)
	// !isNew : INSERT OR REPLACE INTO "tableName" ("rowid", "column1", "column2", ...) VALUES (?, ?, ? ...)
	
	sqlite3_bind_int64(statement, 1, rowid);
	
	int i = 2;
	for (NSString *columnName in ftsConnection->fts->columnNames)
	{
		NSString *columnValue = [ftsConnection->blockDict objectForKey:columnName];
		if (columnValue)
		{
			sqlite3_bind_text(statement, i, [columnValue UTF8String], -1, SQLITE_TRANSIENT);
		}
		
		i++;
	}
	
	int status = sqlite3_step(statement);
	if (status != SQLITE_DONE)
	{
		YDBLogError(@"Error executing '%s': %d %s",
		            isNew ? "insertRowidStatement" : "setRowidStatement",
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	
	isMutated = YES;
}

- (void)removeRowid:(int64_t)rowid
{
	YDBLogAutoTrace();
	
	sqlite3_stmt *statement = [ftsConnection removeRowidStatement];
	if (statement == NULL) return;
	
	// DELETE FROM "tableName" WHERE "rowid" = ?;
	
	sqlite3_bind_int64(statement, 1, rowid);
	
	int status = sqlite3_step(statement);
	if (status != SQLITE_DONE)
	{
		YDBLogError(@"Error executing 'removeRowidStatement': %d %s",
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	
	isMutated = YES;
}

- (void)removeRowids:(NSArray *)rowids
{
	YDBLogAutoTrace();
	
	NSUInteger count = [rowids count];
	
	if (count == 0) return;
	if (count == 1)
	{
		int64_t rowid = [[rowids objectAtIndex:0] longLongValue];
		
		[self removeRowid:rowid];
		return;
	}
	
	// DELETE FROM "tableName" WHERE "rowid" in (?, ?, ...);
	//
	// Note: We don't have to worry sqlite's max number of host parameters.
	// YapDatabase gives us the rowids in batches where each batch is already capped at this number.
	
	NSUInteger capacity = 50 + (count * 3);
	NSMutableString *query = [NSMutableString stringWithCapacity:capacity];
	
	[query appendFormat:@"DELETE FROM \"%@\" WHERE \"rowid\" IN (", [self tableName]];
	
	NSUInteger i;
	for (i = 0; i < count; i++)
	{
		if (i == 0)
			[query appendFormat:@"?"];
		else
			[query appendFormat:@", ?"];
	}
	
	[query appendString:@");"];
	
	sqlite3_stmt *statement;
	
	int status = sqlite3_prepare_v2(databaseTransaction->connection->db, [query UTF8String], -1, &statement, NULL);
	if (status != SQLITE_OK)
	{
		YDBLogError(@"Error creating 'removeRowids' statement: %d %s",
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
		return;
	}
	
	for (i = 0; i < count; i++)
	{
		int64_t rowid = [[rowids objectAtIndex:i] longLongValue];
		
		sqlite3_bind_int64(statement, (int)(i + 1), rowid);
	}
	
	status = sqlite3_step(statement);
	if (status != SQLITE_DONE)
	{
		YDBLogError(@"Error executing 'removeRowids' statement: %d %s",
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_finalize(statement);
	
	isMutated = YES;
}

- (void)removeAllRowids
{
	YDBLogAutoTrace();
	
	sqlite3_stmt *statement = [ftsConnection removeAllStatement];
	if (statement == NULL)
		return;
	
	int status;
	
	// DELETE FROM "tableName";
	
	YDBLogVerbose(@"DELETE FROM '%@';", [self tableName]);
	
	status = sqlite3_step(statement);
	if (status != SQLITE_DONE)
	{
		YDBLogError(@"%@ (%@): Error in removeAllStatement: %d %s",
		            THIS_METHOD, [self registeredName],
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_reset(statement);
	
	isMutated = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Cleanup & Commit
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Required override method from YapDatabaseExtension
**/
- (void)commitTransaction
{
	// An extensionTransaction is only valid within the scope of its encompassing databaseTransaction.
	// I imagine this may occasionally be misunderstood, and developers may attempt to store the extension in an ivar,
	// and then use it outside the context of the database transaction block.
	// Thus, this code is here as a safety net to ensure that such accidental misuse doesn't do any damage.
	
	ftsConnection = nil;       // Do not remove !
	databaseTransaction = nil; // Do not remove !
}

/**
 * Required override method from YapDatabaseExtension
**/
- (void)rollbackTransaction
{
	// An extensionTransaction is only valid within the scope of its encompassing databaseTransaction.
	// I imagine this may occasionally be misunderstood, and developers may attempt to store the extension in an ivar,
	// and then use it outside the context of the database transaction block.
	// Thus, this code is here as a safety net to ensure that such accidental misuse doesn't do any damage.
	
	ftsConnection = nil;       // Do not remove !
	databaseTransaction = nil; // Do not remove !
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark YapDatabaseExtensionTransaction_Hooks
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * YapDatabase extension hook.
 * This method is invoked by a YapDatabaseReadWriteTransaction as a post-operation-hook.
**/
- (void)handleInsertObject:(id)object
                    forKey:(NSString *)key
              inCollection:(NSString *)collection
              withMetadata:(id)metadata
                     rowid:(int64_t)rowid
{
	YDBLogAutoTrace();
	
	__unsafe_unretained YapDatabaseFullTextSearch *fts = ftsConnection->fts;
	
	// Invoke the block to find out if the object should be included in the index.
	
	if (fts->blockType == YapDatabaseFullTextSearchBlockTypeWithKey)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithKeyBlock block =
		    (YapDatabaseFullTextSearchWithKeyBlock)fts->block;
		
		block(ftsConnection->blockDict, collection, key);
	}
	else if (fts->blockType == YapDatabaseFullTextSearchBlockTypeWithObject)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithObjectBlock block =
		    (YapDatabaseFullTextSearchWithObjectBlock)fts->block;
		
		block(ftsConnection->blockDict, collection, key, object);
	}
	else if (fts->blockType == YapDatabaseFullTextSearchBlockTypeWithMetadata)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithMetadataBlock block =
		    (YapDatabaseFullTextSearchWithMetadataBlock)fts->block;
		
		block(ftsConnection->blockDict, collection, key, metadata);
	}
	else
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithRowBlock block =
		    (YapDatabaseFullTextSearchWithRowBlock)fts->block;
		
		block(ftsConnection->blockDict, collection, key, object, metadata);
	}
	
	if ([ftsConnection->blockDict count] == 0)
	{
		// This was an insert operation, so we don't have to worry about removing anything.
	}
	else
	{
		// Add values to index.
		// This was an insert operation, so we know we can insert rather than update.
		
		[self addRowid:rowid isNew:YES];
		[ftsConnection->blockDict removeAllObjects];
	}
}

/**
 * YapDatabase extension hook.
 * This method is invoked by a YapDatabaseReadWriteTransaction as a post-operation-hook.
**/
- (void)handleUpdateObject:(id)object
                    forKey:(NSString *)key
              inCollection:(NSString *)collection
              withMetadata:(id)metadata
                     rowid:(int64_t)rowid
{
	YDBLogAutoTrace();
	
	__unsafe_unretained YapDatabaseFullTextSearch *fts = ftsConnection->fts;
	
	// Invoke the block to find out if the object should be included in the index.
	
	if (fts->blockType == YapDatabaseFullTextSearchBlockTypeWithKey)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithKeyBlock block =
		    (YapDatabaseFullTextSearchWithKeyBlock)fts->block;
		
		block(ftsConnection->blockDict, collection, key);
	}
	else if (fts->blockType == YapDatabaseFullTextSearchBlockTypeWithObject)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithObjectBlock block =
		    (YapDatabaseFullTextSearchWithObjectBlock)fts->block;
		
		block(ftsConnection->blockDict, collection, key, object);
	}
	else if (fts->blockType == YapDatabaseFullTextSearchBlockTypeWithMetadata)
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithMetadataBlock block =
		    (YapDatabaseFullTextSearchWithMetadataBlock)fts->block;
		
		block(ftsConnection->blockDict, collection, key, metadata);
	}
	else
	{
		__unsafe_unretained YapDatabaseFullTextSearchWithRowBlock block =
		    (YapDatabaseFullTextSearchWithRowBlock)fts->block;
		
		block(ftsConnection->blockDict, collection, key, object, metadata);
	}
	
	if ([ftsConnection->blockDict count] == 0)
	{
		// Remove associated values from index (if needed).
		// This was an update operation, so the rowid may have previously had values in the index.
		
		[self removeRowid:rowid];
	}
	else
	{
		// Add values to index (or update them).
		// This was an update operation, so we need to insert or update.
		
		[self addRowid:rowid isNew:NO];
		[ftsConnection->blockDict removeAllObjects];
	}
}

/**
 * YapDatabase extension hook.
 * This method is invoked by a YapDatabaseReadWriteTransaction as a post-operation-hook.
**/
- (void)handleUpdateMetadata:(id)metadata
                      forKey:(NSString *)key
                inCollection:(NSString *)collection
                   withRowid:(int64_t)rowid
{
	YDBLogAutoTrace();
	
	__unsafe_unretained YapDatabaseFullTextSearch *fts = ftsConnection->fts;
	
	// Invoke the block to find out if the object should be included in the index.
	
	id object = nil;
	
	if (fts->blockType == YapDatabaseFullTextSearchBlockTypeWithKey ||
	    fts->blockType == YapDatabaseFullTextSearchBlockTypeWithObject)
	{
		// Index values are based on the key or object.
		// Neither have changed, and thus the values haven't changed.
		
		return;
	}
	else
	{
		// Index values are based on metadata or objectAndMetadata.
		// Invoke block to see what the new values are.
		
		if (fts->blockType == YapDatabaseFullTextSearchBlockTypeWithMetadata)
		{
			__unsafe_unretained YapDatabaseFullTextSearchWithMetadataBlock block =
		        (YapDatabaseFullTextSearchWithMetadataBlock)fts->block;
			
			block(ftsConnection->blockDict, collection, key, metadata);
		}
		else
		{
			__unsafe_unretained YapDatabaseFullTextSearchWithRowBlock block =
		        (YapDatabaseFullTextSearchWithRowBlock)fts->block;
			
			object = [databaseTransaction objectForKey:key inCollection:collection];
			block(ftsConnection->blockDict, collection, key, object, metadata);
		}
		
		if ([ftsConnection->blockDict count] == 0)
		{
			// Remove associated values from index (if needed).
			// This was an update operation, so the rowid may have previously had values in the index.
			
			[self removeRowid:rowid];
		}
		else
		{
			// Add values to index (or update them).
			// This was an update operation, so we need to insert or update.
			
			[self addRowid:rowid isNew:NO];
			[ftsConnection->blockDict removeAllObjects];
		}
	}
}

/**
 * YapDatabase extension hook.
 * This method is invoked by a YapDatabaseReadWriteTransaction as a post-operation-hook.
**/
- (void)handleTouchObjectForKey:(NSString *)key inCollection:(NSString *)collection withRowid:(int64_t)rowid
{
	// Nothing to do for this extension
}

/**
 * YapDatabase extension hook.
 * This method is invoked by a YapDatabaseReadWriteTransaction as a post-operation-hook.
**/
- (void)handleTouchMetadataForKey:(NSString *)key inCollection:(NSString *)collection withRowid:(int64_t)rowid
{
	// Nothing to do for this extension
}

/**
 * YapDatabase extension hook.
 * This method is invoked by a YapDatabaseReadWriteTransaction as a post-operation-hook.
**/
- (void)handleRemoveObjectForKey:(NSString *)key inCollection:(NSString *)collection withRowid:(int64_t)rowid
{
	YDBLogAutoTrace();
	
	[self removeRowid:rowid];
}

/**
 * YapDatabase extension hook.
 * This method is invoked by a YapDatabaseReadWriteTransaction as a post-operation-hook.
**/
- (void)handleRemoveObjectsForKeys:(NSArray *)keys inCollection:(NSString *)collection withRowids:(NSArray *)rowids
{
	YDBLogAutoTrace();
	
	[self removeRowids:rowids];
}

/**
 * YapDatabase extension hook.
 * This method is invoked by a YapDatabaseReadWriteTransaction as a post-operation-hook.
**/
- (void)handleRemoveAllObjectsInAllCollections
{
	YDBLogAutoTrace();
	
	[self removeAllRowids];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Queries
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)enumerateKeysMatching:(NSString *)query
                   usingBlock:(void (^)(NSString *collection, NSString *key, BOOL *stop))block
{
	if (block == nil) return;
	if ([query length] == 0) return;
	
	sqlite3_stmt *statement = [ftsConnection queryStatement];
	if (statement == NULL) return;

	BOOL stop = NO;
	isMutated = NO; // mutation during enumeration protection
	
	// SELECT "rowid" FROM "tableName" WHERE "tableName" MATCH ?;
	
	YapDatabaseString _query; MakeYapDatabaseString(&_query, query);
	sqlite3_bind_text(statement, 1, _query.str, _query.length, SQLITE_STATIC);
	
	int status = sqlite3_step(statement);
	if (status == SQLITE_ROW)
	{
		do
		{
			int64_t rowid = sqlite3_column_int64(statement, 0);
			
			NSString *key = nil;
			NSString *collection = nil;
			[databaseTransaction getKey:&key collection:&collection forRowid:rowid];
			
			block(collection, key, &stop);
			
			if (stop || isMutated) break;
			
		} while ((status = sqlite3_step(statement)) == SQLITE_ROW);
	}
	
	if ((status != SQLITE_DONE) && !stop && !isMutated)
	{
		YDBLogError(@"%@ - sqlite_step error: %d %s", THIS_METHOD,
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	FreeYapDatabaseString(&_query);
	
	if (isMutated && !stop)
	{
		@throw [databaseTransaction mutationDuringEnumerationException];
	}
}

- (void)enumerateKeysAndMetadataMatching:(NSString *)query
                              usingBlock:(void (^)(NSString *collection, NSString *key, id metadata, BOOL *stop))block
{
	if (block == nil) return;
	if ([query length] == 0) return;
	
	sqlite3_stmt *statement = [ftsConnection queryStatement];
	if (statement == NULL) return;

	BOOL stop = NO;
	isMutated = NO; // mutation during enumeration protection
	
	// SELECT "rowid" FROM "tableName" WHERE "tableName" MATCH ?;
	
	YapDatabaseString _query; MakeYapDatabaseString(&_query, query);
	sqlite3_bind_text(statement, 1, _query.str, _query.length, SQLITE_STATIC);
	
	int status = sqlite3_step(statement);
	if (status == SQLITE_ROW)
	{
		do
		{
			int64_t rowid = sqlite3_column_int64(statement, 0);
			
			NSString *key = nil;
			NSString *collection = nil;
			id metadata = nil;
			[databaseTransaction getKey:&key collection:&collection metadata:&metadata forRowid:rowid];
			
			block(collection, key, metadata, &stop);
			
			if (stop || isMutated) break;
			
		} while ((status = sqlite3_step(statement)) == SQLITE_ROW);
	}
	
	if ((status != SQLITE_DONE) && !stop && !isMutated)
	{
		YDBLogError(@"%@ - sqlite_step error: %d %s", THIS_METHOD,
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	FreeYapDatabaseString(&_query);
	
	if (isMutated && !stop)
	{
		@throw [databaseTransaction mutationDuringEnumerationException];
	}
}

- (void)enumerateKeysAndObjectsMatching:(NSString *)query
                             usingBlock:(void (^)(NSString *collection, NSString *key, id object, BOOL *stop))block
{
	if (block == nil) return;
	if ([query length] == 0) return;
	
	sqlite3_stmt *statement = [ftsConnection queryStatement];
	if (statement == NULL) return;

	BOOL stop = NO;
	isMutated = NO; // mutation during enumeration protection
	
	// SELECT "rowid" FROM "tableName" WHERE "tableName" MATCH ?;
	
	YapDatabaseString _query; MakeYapDatabaseString(&_query, query);
	sqlite3_bind_text(statement, 1, _query.str, _query.length, SQLITE_STATIC);
	
	int status = sqlite3_step(statement);
	if (status == SQLITE_ROW)
	{
		do
		{
			int64_t rowid = sqlite3_column_int64(statement, 0);
			
			NSString *key = nil;
			NSString *collection = nil;
			id object = nil;
			[databaseTransaction getKey:&key collection:&collection object:&object forRowid:rowid];
			
			block(collection, key, object, &stop);
			
			if (stop || isMutated) break;
			
		} while ((status = sqlite3_step(statement)) == SQLITE_ROW);
	}
	
	if ((status != SQLITE_DONE) && !stop && !isMutated)
	{
		YDBLogError(@"%@ - sqlite_step error: %d %s", THIS_METHOD,
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	FreeYapDatabaseString(&_query);
	
	if (isMutated && !stop)
	{
		@throw [databaseTransaction mutationDuringEnumerationException];
	}
}

- (void)enumerateRowsMatching:(NSString *)query
                   usingBlock:(void (^)(NSString *collection, NSString *key, id object, id metadata, BOOL *stop))block
{
	if (block == nil) return;
	if ([query length] == 0) return;
	
	sqlite3_stmt *statement = [ftsConnection queryStatement];
	if (statement == NULL) return;

	BOOL stop = NO;
	isMutated = NO; // mutation during enumeration protection
	
	// SELECT "rowid" FROM "tableName" WHERE "tableName" MATCH ?;
	
	YapDatabaseString _query; MakeYapDatabaseString(&_query, query);
	sqlite3_bind_text(statement, 1, _query.str, _query.length, SQLITE_STATIC);
	
	int status = sqlite3_step(statement);
	if (status == SQLITE_ROW)
	{
		do
		{
			int64_t rowid = sqlite3_column_int64(statement, 0);
			
			NSString *key = nil;
			NSString *collection = nil;
			id object = nil;
			id metadata = nil;
			[databaseTransaction getKey:&key collection:&collection object:&object metadata:&metadata forRowid:rowid];
			
			block(collection, key, object, metadata, &stop);
			
			if (stop || isMutated) break;
			
		} while ((status = sqlite3_step(statement)) == SQLITE_ROW);
	}
	
	if ((status != SQLITE_DONE) && !stop && !isMutated)
	{
		YDBLogError(@"%@ - sqlite_step error: %d %s", THIS_METHOD,
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	FreeYapDatabaseString(&_query);
	
	if (isMutated && !stop)
	{
		@throw [databaseTransaction mutationDuringEnumerationException];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Queries with Snippets
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)enumerateKeysMatching:(NSString *)query
           withSnippetOptions:(YapDatabaseFullTextSearchSnippetOptions *)inOptions
                   usingBlock:
            (void (^)(NSString *snippet, NSString *collection, NSString *key, BOOL *stop))block
{
	if (block == nil) return;
	if ([query length] == 0) return;
	
	sqlite3_stmt *statement = [ftsConnection querySnippetStatement];
	if (statement == NULL) return;
	
	YapDatabaseFullTextSearchSnippetOptions *options;
	if (inOptions)
		options = [inOptions copy];
	else
		options = [[YapDatabaseFullTextSearchSnippetOptions alloc] init]; // default snippet options
	
	BOOL stop = NO;
	isMutated = NO; // mutation during enumeration protection
	
	// SELECT "rowid", snippet("tableName", ?, ?, ?, ?, ?) FROM "tableName" WHERE "tableName" MATCH ?;
	
	YapDatabaseString _startMatchText; MakeYapDatabaseString(&_startMatchText, options.startMatchText);
	sqlite3_bind_text(statement, 1, _startMatchText.str, _startMatchText.length, SQLITE_STATIC);
	
	YapDatabaseString _endMatchText; MakeYapDatabaseString(&_endMatchText, options.endMatchText);
	sqlite3_bind_text(statement, 2, _endMatchText.str, _endMatchText.length, SQLITE_STATIC);
	
	YapDatabaseString _ellipsesText; MakeYapDatabaseString(&_ellipsesText, options.ellipsesText);
	sqlite3_bind_text(statement, 3, _ellipsesText.str, _ellipsesText.length, SQLITE_STATIC);

	int columnIndex = -1;
	if (options.columnName)
	{
		NSUInteger index = [ftsConnection->fts->columnNames indexOfObject:options.columnName];
		if (index == NSNotFound)
		{
			YDBLogWarn(@"Invalid snippet option: columnName(%@) not found", options.columnName);
		}
		else
		{
			columnIndex = (int)index;
		}
	}
	sqlite3_bind_int(statement, 4, columnIndex);
	sqlite3_bind_int(statement, 5, options.numberOfTokens);
	
	YapDatabaseString _query; MakeYapDatabaseString(&_query, query);
	sqlite3_bind_text(statement, 6, _query.str, _query.length, SQLITE_STATIC);
	
	int status = sqlite3_step(statement);
	if (status == SQLITE_ROW)
	{
		do
		{
			int64_t rowid = sqlite3_column_int64(statement, 0);
			
			const unsigned char *text = sqlite3_column_text(statement, 1);
			int textSize = sqlite3_column_bytes(statement, 1);
			
			NSString *snippet = [[NSString alloc] initWithBytes:text length:textSize encoding:NSUTF8StringEncoding];
			
			NSString *key = nil;
			NSString *collection = nil;
			[databaseTransaction getKey:&key collection:&collection forRowid:rowid];
			
			block(snippet, collection, key, &stop);
			
			if (stop || isMutated) break;
			
		} while ((status = sqlite3_step(statement)) == SQLITE_ROW);
	}
	
	if ((status != SQLITE_DONE) && !stop && !isMutated)
	{
		YDBLogError(@"%@ - sqlite_step error: %d %s", THIS_METHOD,
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	
	FreeYapDatabaseString(&_startMatchText);
	FreeYapDatabaseString(&_endMatchText);
	FreeYapDatabaseString(&_ellipsesText);
	FreeYapDatabaseString(&_query);
	
	if (isMutated && !stop)
	{
		@throw [databaseTransaction mutationDuringEnumerationException];
	}
}

- (void)enumerateKeysAndMetadataMatching:(NSString *)query
                      withSnippetOptions:(YapDatabaseFullTextSearchSnippetOptions *)inOptions
                              usingBlock:
            (void (^)(NSString *snippet, NSString *collection, NSString *key, id metadata, BOOL *stop))block
{
	if (block == nil) return;
	if ([query length] == 0) return;
	
	sqlite3_stmt *statement = [ftsConnection querySnippetStatement];
	if (statement == NULL) return;
	
	YapDatabaseFullTextSearchSnippetOptions *options;
	if (inOptions)
		options = [inOptions copy];
	else
		options = [[YapDatabaseFullTextSearchSnippetOptions alloc] init]; // default snippet options
	
	BOOL stop = NO;
	isMutated = NO; // mutation during enumeration protection
	
	// SELECT "rowid", snippet("tableName", ?, ?, ?, ?, ?) FROM "tableName" WHERE "tableName" MATCH ?;
	
	YapDatabaseString _startMatchText; MakeYapDatabaseString(&_startMatchText, options.startMatchText);
	sqlite3_bind_text(statement, 1, _startMatchText.str, _startMatchText.length, SQLITE_STATIC);
	
	YapDatabaseString _endMatchText; MakeYapDatabaseString(&_endMatchText, options.endMatchText);
	sqlite3_bind_text(statement, 2, _endMatchText.str, _endMatchText.length, SQLITE_STATIC);
	
	YapDatabaseString _ellipsesText; MakeYapDatabaseString(&_ellipsesText, options.ellipsesText);
	sqlite3_bind_text(statement, 3, _ellipsesText.str, _ellipsesText.length, SQLITE_STATIC);

	int columnIndex = -1;
	if (options.columnName)
	{
		NSUInteger index = [ftsConnection->fts->columnNames indexOfObject:options.columnName];
		if (index == NSNotFound)
		{
			YDBLogWarn(@"Invalid snippet option: columnName(%@) not found", options.columnName);
		}
		else
		{
			columnIndex = (int)index;
		}
	}
	sqlite3_bind_int(statement, 4, columnIndex);
	sqlite3_bind_int(statement, 5, options.numberOfTokens);
	
	YapDatabaseString _query; MakeYapDatabaseString(&_query, query);
	sqlite3_bind_text(statement, 6, _query.str, _query.length, SQLITE_STATIC);
	
	int status = sqlite3_step(statement);
	if (status == SQLITE_ROW)
	{
		do
		{
			int64_t rowid = sqlite3_column_int64(statement, 0);
			
			const unsigned char *text = sqlite3_column_text(statement, 1);
			int textSize = sqlite3_column_bytes(statement, 1);
			
			NSString *snippet = [[NSString alloc] initWithBytes:text length:textSize encoding:NSUTF8StringEncoding];
			
			NSString *key = nil;
			NSString *collection = nil;
			id metadata = nil;
			[databaseTransaction getKey:&key collection:&collection metadata:&metadata forRowid:rowid];
			
			block(snippet, collection, key, metadata, &stop);
			
			if (stop || isMutated) break;
			
		} while ((status = sqlite3_step(statement)) == SQLITE_ROW);
	}
	
	if ((status != SQLITE_DONE) && !stop && !isMutated)
	{
		YDBLogError(@"%@ - sqlite_step error: %d %s", THIS_METHOD,
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	
	FreeYapDatabaseString(&_startMatchText);
	FreeYapDatabaseString(&_endMatchText);
	FreeYapDatabaseString(&_ellipsesText);
	FreeYapDatabaseString(&_query);
	
	if (isMutated && !stop)
	{
		@throw [databaseTransaction mutationDuringEnumerationException];
	}
}

- (void)enumerateKeysAndObjectsMatching:(NSString *)query
                     withSnippetOptions:(YapDatabaseFullTextSearchSnippetOptions *)inOptions
                             usingBlock:
            (void (^)(NSString *snippet, NSString *collection, NSString *key, id object, BOOL *stop))block
{
	if (block == nil) return;
	if ([query length] == 0) return;
	
	sqlite3_stmt *statement = [ftsConnection querySnippetStatement];
	if (statement == NULL) return;
	
	YapDatabaseFullTextSearchSnippetOptions *options;
	if (inOptions)
		options = [inOptions copy];
	else
		options = [[YapDatabaseFullTextSearchSnippetOptions alloc] init]; // default snippet options
	
	BOOL stop = NO;
	isMutated = NO; // mutation during enumeration protection
	
	// SELECT "rowid", snippet("tableName", ?, ?, ?, ?, ?) FROM "tableName" WHERE "tableName" MATCH ?;
	
	YapDatabaseString _startMatchText; MakeYapDatabaseString(&_startMatchText, options.startMatchText);
	sqlite3_bind_text(statement, 1, _startMatchText.str, _startMatchText.length, SQLITE_STATIC);
	
	YapDatabaseString _endMatchText; MakeYapDatabaseString(&_endMatchText, options.endMatchText);
	sqlite3_bind_text(statement, 2, _endMatchText.str, _endMatchText.length, SQLITE_STATIC);
	
	YapDatabaseString _ellipsesText; MakeYapDatabaseString(&_ellipsesText, options.ellipsesText);
	sqlite3_bind_text(statement, 3, _ellipsesText.str, _ellipsesText.length, SQLITE_STATIC);

	int columnIndex = -1;
	if (options.columnName)
	{
		NSUInteger index = [ftsConnection->fts->columnNames indexOfObject:options.columnName];
		if (index == NSNotFound)
		{
			YDBLogWarn(@"Invalid snippet option: columnName(%@) not found", options.columnName);
		}
		else
		{
			columnIndex = (int)index;
		}
	}
	sqlite3_bind_int(statement, 4, columnIndex);
	sqlite3_bind_int(statement, 5, options.numberOfTokens);
	
	YapDatabaseString _query; MakeYapDatabaseString(&_query, query);
	sqlite3_bind_text(statement, 6, _query.str, _query.length, SQLITE_STATIC);
	
	int status = sqlite3_step(statement);
	if (status == SQLITE_ROW)
	{
		do
		{
			int64_t rowid = sqlite3_column_int64(statement, 0);
			
			const unsigned char *text = sqlite3_column_text(statement, 1);
			int textSize = sqlite3_column_bytes(statement, 1);
			
			NSString *snippet = [[NSString alloc] initWithBytes:text length:textSize encoding:NSUTF8StringEncoding];
			
			NSString *key = nil;
			NSString *collection = nil;
			id object = nil;
			[databaseTransaction getKey:&key collection:&collection object:&object forRowid:rowid];
			
			block(snippet, collection, key, object, &stop);
			
			if (stop || isMutated) break;
			
		} while ((status = sqlite3_step(statement)) == SQLITE_ROW);
	}
	
	if ((status != SQLITE_DONE) && !stop && !isMutated)
	{
		YDBLogError(@"%@ - sqlite_step error: %d %s", THIS_METHOD,
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	
	FreeYapDatabaseString(&_startMatchText);
	FreeYapDatabaseString(&_endMatchText);
	FreeYapDatabaseString(&_ellipsesText);
	FreeYapDatabaseString(&_query);
	
	if (isMutated && !stop)
	{
		@throw [databaseTransaction mutationDuringEnumerationException];
	}
}

- (void)enumerateRowsMatching:(NSString *)query
           withSnippetOptions:(YapDatabaseFullTextSearchSnippetOptions *)inOptions
                   usingBlock:
            (void (^)(NSString *snippet, NSString *collection, NSString *key, id object, id metadata, BOOL *stop))block
{
	if (block == nil) return;
	if ([query length] == 0) return;
	
	sqlite3_stmt *statement = [ftsConnection querySnippetStatement];
	if (statement == NULL) return;
	
	YapDatabaseFullTextSearchSnippetOptions *options;
	if (inOptions)
		options = [inOptions copy];
	else
		options = [[YapDatabaseFullTextSearchSnippetOptions alloc] init]; // default snippet options
	
	BOOL stop = NO;
	isMutated = NO; // mutation during enumeration protection
	
	// SELECT "rowid", snippet("tableName", ?, ?, ?, ?, ?) FROM "tableName" WHERE "tableName" MATCH ?;
	
	YapDatabaseString _startMatchText; MakeYapDatabaseString(&_startMatchText, options.startMatchText);
	sqlite3_bind_text(statement, 1, _startMatchText.str, _startMatchText.length, SQLITE_STATIC);
	
	YapDatabaseString _endMatchText; MakeYapDatabaseString(&_endMatchText, options.endMatchText);
	sqlite3_bind_text(statement, 2, _endMatchText.str, _endMatchText.length, SQLITE_STATIC);
	
	YapDatabaseString _ellipsesText; MakeYapDatabaseString(&_ellipsesText, options.ellipsesText);
	sqlite3_bind_text(statement, 3, _ellipsesText.str, _ellipsesText.length, SQLITE_STATIC);

	int columnIndex = -1;
	if (options.columnName)
	{
		NSUInteger index = [ftsConnection->fts->columnNames indexOfObject:options.columnName];
		if (index == NSNotFound)
		{
			YDBLogWarn(@"Invalid snippet option: columnName(%@) not found", options.columnName);
		}
		else
		{
			columnIndex = (int)index;
		}
	}
	sqlite3_bind_int(statement, 4, columnIndex);
	sqlite3_bind_int(statement, 5, options.numberOfTokens);
	
	YapDatabaseString _query; MakeYapDatabaseString(&_query, query);
	sqlite3_bind_text(statement, 6, _query.str, _query.length, SQLITE_STATIC);
	
	int status = sqlite3_step(statement);
	if (status == SQLITE_ROW)
	{
		do
		{
			int64_t rowid = sqlite3_column_int64(statement, 0);
			
			const unsigned char *text = sqlite3_column_text(statement, 1);
			int textSize = sqlite3_column_bytes(statement, 1);
			
			NSString *snippet = [[NSString alloc] initWithBytes:text length:textSize encoding:NSUTF8StringEncoding];
			
			NSString *key = nil;
			NSString *collection = nil;
			id object = nil;
			id metadata = nil;
			[databaseTransaction getKey:&key collection:&collection object:&object metadata:&metadata forRowid:rowid];
			
			block(snippet, collection, key, object, metadata, &stop);
			
			if (stop || isMutated) break;
			
		} while ((status = sqlite3_step(statement)) == SQLITE_ROW);
	}
	
	if ((status != SQLITE_DONE) && !stop && !isMutated)
	{
		YDBLogError(@"%@ - sqlite_step error: %d %s", THIS_METHOD,
		            status, sqlite3_errmsg(databaseTransaction->connection->db));
	}
	
	sqlite3_clear_bindings(statement);
	sqlite3_reset(statement);
	
	FreeYapDatabaseString(&_startMatchText);
	FreeYapDatabaseString(&_endMatchText);
	FreeYapDatabaseString(&_ellipsesText);
	FreeYapDatabaseString(&_query);
	
	if (isMutated && !stop)
	{
		@throw [databaseTransaction mutationDuringEnumerationException];
	}
}

@end
