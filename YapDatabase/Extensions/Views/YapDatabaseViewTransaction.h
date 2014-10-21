#import <Foundation/Foundation.h>
#import "YapDatabaseExtensionTransaction.h"
#import "YapDatabaseViewMappings.h"

/**
 * Welcome to YapDatabase!
 *
 * The project page has a wealth of documentation if you have any questions.
 * https://github.com/yaptv/YapDatabase
 *
 * If you're new to the project you may want to check out the wiki
 * https://github.com/yaptv/YapDatabase/wiki
 *
 * YapDatabaseView is an extension designed to work with YapDatabase.
 * It gives you a persistent sorted "view" of a configurable subset of your data.
 *
 * For more information, please see the wiki article about Views:
 * https://github.com/yaptv/YapDatabase/wiki/Views
 *
 * You may also wish to consult the documentation in YapDatabaseView.h for information on setting up a view.
 *
 * You access this class within a regular transaction.
 * For example:
 *
 * [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
 *
 *     topUsaSale = [[transaction ext:@"myView"] objectAtIndex:0 inGroup:@"usa"]
 * }];
 *
 * Keep in mind that the YapDatabaseViewTransaction object is linked to the YapDatabaseReadTransaction object.
 * So don't try to use it outside the transaction block (cause it won't work).
**/
@interface YapDatabaseViewTransaction : YapDatabaseExtensionTransaction

#pragma mark Groups

/**
 * Returns the number of groups the view manages.
 * Each group has one or more keys in it.
**/
- (NSUInteger)numberOfGroups;

/**
 * Returns the names of all groups in an unsorted array.
 * Each group has one or more keys in it.
 *
 * @see YapDatabaseView - groupingBlock
**/
- (NSArray *)allGroups;

/**
 * Returns YES if there are any keys in the given group.
 * This is equivalent to ([viewTransaction numberOfKeysInGroup:group] > 0)
**/
- (BOOL)hasGroup:(NSString *)group;

/**
 * Returns the total number of keys in the given group.
 * If the group doesn't exist, returns zero.
**/
- (NSUInteger)numberOfKeysInGroup:(NSString *)group;

/**
 * Returns the total number of keys in every single group.
**/
- (NSUInteger)numberOfKeysInAllGroups;

#pragma mark Fetching

/**
 * Returns the key & collection at the given index within the given group.
 * Returns nil if the group doesn't exist, or if the index is out of bounds.
**/
- (BOOL)getKey:(NSString **)keyPtr
    collection:(NSString **)collectionPtr
       atIndex:(NSUInteger)index
       inGroup:(NSString *)group;

/**
 * Shortcut for: [view getKey:&key collection:&collection atIndex:0 inGroup:group]
**/
- (BOOL)getFirstKey:(NSString **)keyPtr collection:(NSString **)collectionPtr inGroup:(NSString *)group;

/**
 * Shortcut for: [view getKey:&key collection:&collection atIndex:(numberOfKeysInGroup-1) inGroup:group]
**/
- (BOOL)getLastKey:(NSString **)keyPtr collection:(NSString **)collectionPtr inGroup:(NSString *)group;

/**
 * Shortcut for fetching just the collection at the given index.
**/
- (NSString *)collectionAtIndex:(NSUInteger)index inGroup:(NSString *)group;

/**
 * Shortcut for fetching just the key at the given index.
 * Convenient if you already know what collection the key is in.
**/
- (NSString *)keyAtIndex:(NSUInteger)index inGroup:(NSString *)group;

/**
 * If the given {collection, key} are included in the view, then returns the associated group.
 * If the {collection, key} isn't in the view, then returns nil.
**/
- (NSString *)groupForKey:(NSString *)key inCollection:(NSString *)collection;

/**
 * Fetches both the group and the index within the group for the given {collection, key}.
 *
 * Returns YES if the {collection, key} is included in the view.
 * Otherwise returns NO, and sets the parameters to nil & zero.
**/
- (BOOL)getGroup:(NSString **)groupPtr
           index:(NSUInteger *)indexPtr
          forKey:(NSString *)key
    inCollection:(NSString *)collection;

#pragma mark Finding

typedef id YapDatabaseViewFindBlock; // One of the YapDatabaseViewFindX types below.

typedef NSComparisonResult (^YapDatabaseViewFindWithKeyBlock)      \
                                                        (NSString *collection, NSString *key);
typedef NSComparisonResult (^YapDatabaseViewFindWithObjectBlock)   \
                                                        (NSString *collection, NSString *key, id object);
typedef NSComparisonResult (^YapDatabaseViewFindWithMetadataBlock) \
                                                        (NSString *collection, NSString *key, id metadata);
typedef NSComparisonResult (^YapDatabaseViewFindWithRowBlock)      \
                                                        (NSString *collection, NSString *key, id object, id metadata);

#ifndef YapDatabaseViewBlockTypeDefined
#define YapDatabaseViewBlockTypeDefined 1

typedef enum {
	YapDatabaseViewBlockTypeWithKey       = 201,
	YapDatabaseViewBlockTypeWithObject    = 202,
	YapDatabaseViewBlockTypeWithMetadata  = 203,
	YapDatabaseViewBlockTypeWithRow       = 204
} YapDatabaseViewBlockType;

#endif

/**
 * This method uses a binary search algorithm to find a range of items within the view that match the given criteria.
 * For example:
 * 
 * You have a view which sorts items by timestamp (oldest to newest)
 * You could then use this method to quickly find all items whose timestamp falls on a certain day.
 * Or, more generally, within a certain timespan.
 * 
 * NSDate *beginningOfMonday = ...   // Monday at 12:00 AM
 * NSDate *beginningOfTuesday =  ... // Tuesday at 12:00 AM
 *
 * YapDatabaseViewBlockType blockType = YapDatabaseViewBlockTypeWithObject;
 * YapDatabaseViewFindWithObjectBlock block = ^(NSString *key, id object){
 *
 *     Purchase *purchase = (Purchase *)object;
 *
 *     if ([purchase.timestamp compare:beginningOfMonday] == NSOrderedAscending) // earlier than start range
 *         return NSOrderedAscending;
 * 
 *     if ([purchase.timestamp compare:beginningOfTuesday] == NSOrderedAscending) // earlier than end range
 *         return NSOrderedSame;
 * 
 *     return NSOrderedDescending; // greater than end range (or exactly midnight on tuesday)
 * };
 * 
 * The return values from the YapDatabaseViewFindBlock have the following meaning:
 * 
 * - NSOrderedAscending : The given row (block parameters) is less than the range I'm looking for.
 *                        That is, the row would have a smaller index within the view than would the range I seek.
 * 
 * - NSOrderedDecending : The given row (block parameters) is greater than the range I'm looking for.
 *                        That is, the row would have a greater index within the view than would the range I seek.
 * 
 * - NSOrderedSame : The given row (block parameters) is within the range I'm looking for.
 * 
 * Keep in mind 2 things:
 * 
 * #1 : This method can only be used if you need to find items according to their sort order.
 *      That is, according to how the items are sorted via the view's sortingBlock.
 *      Attempting to use this method in any other manner makes no sense.
 *
 * #2 : The findBlock that you pass needs to be setup in the same manner as the view's sortingBlock.
 *      That is, the following rules must be followed, or the results will be incorrect:
 *      
 *      For example, say you have a view like this, looking for the following range of 3 items:
 *      myView = @[ A, B, C, D, E, F, G ]
 *                     ^^^^^^^
 *      sortingBlock(A, B) => NSOrderedAscending
 *      findBlock(A)       => NSOrderedAscending
 *      
 *      sortingBlock(E, D) => NSOrderedDescending
 *      findBlock(E)       => NSOrderedDescending
 * 
 *      findBlock(B) => NSOrderedSame
 *      findBlock(C) => NSOrderedSame
 *      findBlock(D) => NSOrderedSame
 * 
 * In other words, you can't sort one way in the sortingBlock, and "sort" another way in the findBlock.
 * Another way to think about it is in terms of how the Apple docs define the NSOrdered enums:
 * 
 * NSOrderedAscending  : The left operand is smaller than the right operand.
 * NSOrderedDescending : The left operand is greater than the right operand.
 * 
 * For the findBlock, the "left operand" is the row that is passed,
 * and the "right operand" is the desired range.
 * 
 * And NSOrderedSame means: "the passed row is within the range I'm looking for".
 * 
 * Implementation Note:
 * This method uses a binary search to find an item for which the block returns NSOrderedSame.
 * It then uses information from the first binary search (known min/max) to perform two subsequent binary searches.
 * One to find the start of the range, and another to find the end of the range.
 * Thus:
 * - the implementation is efficient
 * - the block won't be invoked for every item within the range
 *
 * @param group
 *     The group within the view to search.
 * 
 * @param block
 *     One of the YapDatabaseViewFindWithXBlock types.
 * 
 * @param blockType
 *     The proper YapDatabaseViewBlockTypeWithX type that matches the given block.
 * 
 * @return
 *     If found, the range that matches the items within the desired range.
 *     That is, is these items were passed to the given block, the block would return NSOrderedSame.
 *     If not found, returns NSMakeRange(NSNotFound, 0).
**/
- (NSRange)findRangeInGroup:(NSString *)group
                 usingBlock:(YapDatabaseViewFindBlock)block
                  blockType:(YapDatabaseViewBlockType)blockType;

#pragma mark Enumerating

/**
 * Enumerates the keys in the given group.
**/
- (void)enumerateKeysInGroup:(NSString *)group
                  usingBlock:(void (^)(NSString *collection, NSString *key, NSUInteger index, BOOL *stop))block;

/**
 * Enumerates the keys in the given group.
 * Reverse enumeration is supported by passing NSEnumerationReverse. (No other enumeration options are supported.)
**/
- (void)enumerateKeysInGroup:(NSString *)group
                 withOptions:(NSEnumerationOptions)options
                  usingBlock:(void (^)(NSString *collection, NSString *key, NSUInteger index, BOOL *stop))block;

/**
 * Enumerates the keys in the range of the given group.
 * Reverse enumeration is supported by passing NSEnumerationReverse. (No other enumeration options are supported.)
**/
- (void)enumerateKeysInGroup:(NSString *)group
                 withOptions:(NSEnumerationOptions)options
                       range:(NSRange)range
                  usingBlock:(void (^)(NSString *collection, NSString *key, NSUInteger index, BOOL *stop))block;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface YapDatabaseViewTransaction (ReadWrite)

/**
 * "Touching" a object allows you to mark an item in the view as "updated",
 * even if the object itself wasn't directly updated.
 *
 * This is most often useful when a view is being used by a tableView,
 * but the tableView cells are also dependent upon another object in the database.
 *
 * For example:
 *
 *   You have a view which includes the departments in the company, sorted by name.
 *   But as part of the cell that's displayed for the department,
 *   you also display the number of employees in the department.
 *   The employee count comes from elsewhere.
 *   That is, the employee count isn't a property of the department object itself.
 *   Perhaps you get the count from another view,
 *   or perhaps the count is simply the number of keys in a particular collection.
 *   Either way, when you add or remove an employee, you want to ensure that the view marks the
 *   affected department as updated so that the corresponding cell will properly redraw itself.
 *
 * So the idea is to mark certain items as "updated" (in terms of this view) so that
 * the changeset for the view will properly reflect a change to the corresponding index.
 * But you don't actually need to update the item on disk.
 * This is exactly what "touch" does.
 *
 * Touching an item has very minimal overhead.
 * It doesn't cause the groupingBlock or sortingBlock to be invoked,
 * and it doesn't cause any writes to the database.
 *
 * You can touch
 * - just the object
 * - just the metadata
 * - or both object and metadata (the row)
 * 
 * If you mark just the object as changed,
 * and neither the groupingBlock nor sortingBlock depend upon the object,
 * then the view doesn't reflect any change.
 * 
 * If you mark just the metadata as changed,
 * and neither the groupingBlock nor sortingBlock depend upon the metadata,
 * then the view doesn't relect any change.
 * 
 * In all other cases, the view will properly reflect a corresponding change in the notification that's posted.
**/

- (void)touchRowForKey:(NSString *)key inCollection:(NSString *)collection;
- (void)touchObjectForKey:(NSString *)key inCollection:(NSString *)collection;
- (void)touchMetadataForKey:(NSString *)key inCollection:(NSString *)collection;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * YapDatabaseView deals with ordered arrays of collection/key tuples.
 * So, strictly speaking, it only knows about collection/key tuples, groups, and indexes.
 * 
 * But it's really convenient to have methods that put it all together to fetch an object in a single method.
**/
@interface YapDatabaseViewTransaction (Convenience)

/**
 * Equivalent to invoking:
 *
 * NSString *collection = nil;
 * NSString *key = nil;
 * [[transaction ext:@"myView"] getKey:&key collection:&collection atIndex:index inGroup:group];
 * [transaction objectForKey:key inCollection:collection];
**/
- (id)objectAtIndex:(NSUInteger)keyIndex inGroup:(NSString *)group;

/**
 * Equivalent to invoking:
 *
 * NSString *collection = nil;
 * NSString *key = nil;
 * [[transaction ext:@"myView"] getFirstKey:&key collection:&collection inGroup:group];
 * [transaction objectForKey:key inCollection:collection];
**/
- (id)firstObjectInGroup:(NSString *)group;

/**
 * Equivalent to invoking:
 *
 * NSString *collection = nil;
 * NSString *key = nil;
 * [[transaction ext:@"myView"] getLastKey:&key collection:&collection inGroup:group];
 * [transaction objectForKey:key inCollection:collection];
**/
- (id)lastObjectInGroup:(NSString *)group;

/**
 * The following methods are equivalent to invoking the enumerateKeysInGroup:... methods,
 * and then fetching the metadata within your own block.
**/

- (void)enumerateKeysAndMetadataInGroup:(NSString *)group
                             usingBlock:
                    (void (^)(NSString *collection, NSString *key, id metadata, NSUInteger index, BOOL *stop))block;

- (void)enumerateKeysAndMetadataInGroup:(NSString *)group
                            withOptions:(NSEnumerationOptions)options
                             usingBlock:
                    (void (^)(NSString *collection, NSString *key, id metadata, NSUInteger index, BOOL *stop))block;

- (void)enumerateKeysAndMetadataInGroup:(NSString *)group
                            withOptions:(NSEnumerationOptions)options
                                  range:(NSRange)range
                             usingBlock:
                    (void (^)(NSString *collection, NSString *key, id metadata, NSUInteger index, BOOL *stop))block;

/**
 * The following methods are equivalent to invoking the enumerateKeysInGroup:... methods,
 * and then fetching the object within your own block.
**/

- (void)enumerateKeysAndObjectsInGroup:(NSString *)group
                            usingBlock:
            (void (^)(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop))block;

- (void)enumerateKeysAndObjectsInGroup:(NSString *)group
                           withOptions:(NSEnumerationOptions)options
                            usingBlock:
            (void (^)(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop))block;

- (void)enumerateKeysAndObjectsInGroup:(NSString *)group
                           withOptions:(NSEnumerationOptions)options
                                 range:(NSRange)range
                            usingBlock:
            (void (^)(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop))block;

/**
 * The following methods are equivalent to invoking the enumerateKeysInGroup:... methods,
 * and then fetching the object and metadata within your own block.
**/

- (void)enumerateRowsInGroup:(NSString *)group
                  usingBlock:
            (void (^)(NSString *collection, NSString *key, id object, id metadata, NSUInteger index, BOOL *stop))block;

- (void)enumerateRowsInGroup:(NSString *)group
                 withOptions:(NSEnumerationOptions)options
                  usingBlock:
            (void (^)(NSString *collection, NSString *key, id object, id metadata, NSUInteger index, BOOL *stop))block;

- (void)enumerateRowsInGroup:(NSString *)group
                 withOptions:(NSEnumerationOptions)options
                       range:(NSRange)range
                  usingBlock:
            (void (^)(NSString *collection, NSString *key, id object, id metadata, NSUInteger index, BOOL *stop))block;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface YapDatabaseViewTransaction (Mappings)

/**
 * Gets the key & collection at the given indexPath, assuming the given mappings are being used.
 * Returns NO if the indexPath is invalid, or the mappings aren't initialized.
 * Otherwise returns YES, and sets the key & collection ptr (both optional).
**/
- (BOOL)getKey:(NSString **)keyPtr
    collection:(NSString **)collectionPtr
   atIndexPath:(NSIndexPath *)indexPath
  withMappings:(YapDatabaseViewMappings *)mappings;

/**
 * Fetches the indexPath for the given {collection, key} tuple, assuming the given mappings are being used.
 * Returns nil if the {collection, key} tuple isn't included in the view + mappings.
**/
- (NSIndexPath *)indexPathForKey:(NSString *)key
                    inCollection:(NSString *)collection
                    withMappings:(YapDatabaseViewMappings *)mappings;

@end
