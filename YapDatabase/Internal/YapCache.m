#import "YapCache.h"
#import "YapDatabaseLogging.h"


/**
 * Define log level for this file: OFF, ERROR, WARN, INFO, VERBOSE
 * See YapDatabaseLogging.h for more information.
**/
#if DEBUG
  static const int ydbLogLevel = YDB_LOG_LEVEL_OFF;
#else
  static const int ydbLogLevel = YDB_LOG_LEVEL_OFF;
#endif

/**
 * Default countLimit, as specified in header file.
**/
#define YAP_CACHE_DEFAULT_COUNT_LIMIT 40


@interface YapCacheItem : NSObject {
@public
	__unsafe_unretained YapCacheItem *prev; // retained by cfdict
	__unsafe_unretained YapCacheItem *next; // retained by cfdict

	__unsafe_unretained id key; // retained by cfdict as key
	__strong id value;          // retained only by us
}

- (id)initWithKey:(id)key value:(id)value;

@end

@implementation YapCacheItem

- (id)initWithKey:(id <NSCopying>)aKey value:(id)aValue
{
	if ((self = [super init]))
	{
		key = aKey;
		value = aValue;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<YapCacheItem[%p] key(%@)>", self, key];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation YapCache
{
	Class keyClass;
	CFMutableDictionaryRef cfdict;
	
	NSUInteger countLimit;
	
	__unsafe_unretained YapCacheItem *mostRecentCacheItem;
	__unsafe_unretained YapCacheItem *leastRecentCacheItem;
	
	__strong YapCacheItem *evictedCacheItem;
	
#if YAP_CACHE_STATISTICS
	NSUInteger hitCount;
	NSUInteger missCount;
	NSUInteger evictionCount;
#endif
}

#if YAP_CACHE_STATISTICS
@synthesize hitCount = hitCount;
@synthesize missCount = missCount;
@synthesize evictionCount = evictionCount;
#endif

- (id)init
{
	return [self initWithKeyClass:NULL countLimit:0];
}

- (id)initWithKeyClass:(Class)inKeyClass
{
	return [self initWithKeyClass:inKeyClass countLimit:0];
}

- (id)initWithKeyClass:(Class)inKeyClass countLimit:(NSUInteger)inCountLimit
{
	if ((self = [super init]))
	{
		if (inKeyClass == NULL)
			keyClass = [NSString class];
		else
			keyClass = inKeyClass;
		
		if (inCountLimit == 0)
			countLimit = YAP_CACHE_DEFAULT_COUNT_LIMIT;
		else
			countLimit = inCountLimit;
		
		// We actually use countLimit plus one.
		// This is because we evict items after the count surpasses the countLimit.
		// In other words, we evict items when the count reaches countLimit plus one.
		
		cfdict = CFDictionaryCreateMutable(kCFAllocatorDefault,
		                                   0,
		                                   &kCFTypeDictionaryKeyCallBacks,
		                                   &kCFTypeDictionaryValueCallBacks);
	}
	return self;
}

- (void)dealloc
{
	if (cfdict) CFRelease(cfdict);
}

- (NSUInteger)countLimit
{
	return countLimit;
}

- (void)setCountLimit:(NSUInteger)newCountLimit
{
	if (countLimit != newCountLimit)
	{
		countLimit = newCountLimit;
		
		if (countLimit != 0) {
			while (CFDictionaryGetCount(cfdict) > countLimit)
			{
				leastRecentCacheItem->prev->next = nil;
				
				evictedCacheItem = leastRecentCacheItem;
				leastRecentCacheItem = leastRecentCacheItem->prev;
				
				CFDictionaryRemoveValue(cfdict, (const void *)(evictedCacheItem->key));
				
				evictedCacheItem->prev = nil;
				evictedCacheItem->next = nil;
				evictedCacheItem->key = nil;
				evictedCacheItem->value = nil;
				
				#if YAP_CACHE_STATISTICS
				evictionCount++;
				#endif
			}
		}
	}
}

- (id)objectForKey:(id)key
{
	NSAssert([key isKindOfClass:keyClass], @"Unexpected key class. Expected %@, passed %@", keyClass, [key class]);
	
	YapCacheItem *item = CFDictionaryGetValue(cfdict, (const void *)key);
	if (item)
	{
		if (item != mostRecentCacheItem)
		{
			// Remove item from current position in linked-list.
			//
			// Notes:
			// We fetched the item from the list,
			// so we know there's a valid mostRecentCacheItem & leastRecentCacheItem.
			// Furthermore, we know the item isn't the mostRecentCacheItem.
			
			item->prev->next = item->next;
			
			if (item == leastRecentCacheItem)
				leastRecentCacheItem = item->prev;
			else
				item->next->prev = item->prev;
			
			// Move item to beginning of linked-list
			
			item->prev = nil;
			item->next = mostRecentCacheItem;
			
			mostRecentCacheItem->prev = item;
			mostRecentCacheItem = item;
		}
		
		#if YAP_CACHE_STATISTICS
		hitCount++;
		#endif
		return item->value;
	}
	else
	{
		#if YAP_CACHE_STATISTICS
		missCount++;
		#endif
		return nil;
	}
}

- (BOOL)containsKey:(id)key
{
	NSAssert([key isKindOfClass:keyClass], @"Unexpected key class. Expected %@, passed %@", keyClass, [key class]);
	
	return CFDictionaryContainsKey(cfdict, (const void *)key);
}

- (void)setObject:(id)object forKey:(id)key
{
	NSAssert([key isKindOfClass:keyClass], @"Unexpected key class. Expected %@, passed %@", keyClass, [key class]);
	
	YapCacheItem *item = CFDictionaryGetValue(cfdict, (const void *)key);
	if (item)
	{
		// Update item value
		item->value = object;
		
		if (item != mostRecentCacheItem)
		{
			// Remove item from current position in linked-list
			//
			// Notes:
			// We fetched the item from the list,
			// so we know there's a valid mostRecentCacheItem & leastRecentCacheItem.
			// Furthermore, we know the item isn't the mostRecentCacheItem.
			
			item->prev->next = item->next;
			
			if (item == leastRecentCacheItem)
				leastRecentCacheItem = item->prev;
			else
				item->next->prev = item->prev;
			
			// Move item to beginning of linked-list
			
			item->prev = nil;
			item->next = mostRecentCacheItem;
			
			mostRecentCacheItem->prev = item;
			mostRecentCacheItem = item;
			
			YDBLogVerbose(@"key(%@) <- existing, new mostRecent", key);
		}
		else
		{
			YDBLogVerbose(@"key(%@) <- existing, already mostRecent", key);
		}
	}
	else
	{
		// Create new item (or recycle old evicted item)
		
		if (evictedCacheItem)
		{
			item = evictedCacheItem;
			item->key = key;
			item->value = object;
			
			evictedCacheItem = nil;
		}
		else
		{
			item = [[YapCacheItem alloc] initWithKey:key value:object];
		}
		
		// Add item to set
		CFDictionarySetValue(cfdict, (const void *)key, (const void *)item);
		
		// Add item to beginning of linked-list
		
		item->next = mostRecentCacheItem;
		
		if (mostRecentCacheItem)
			mostRecentCacheItem->prev = item;
		
		mostRecentCacheItem = item;
		
		// Evict leastRecentCacheItem if needed
		
		if ((countLimit != 0) && (CFDictionaryGetCount(cfdict) > countLimit))
		{
			YDBLogVerbose(@"key(%@), out(%@)", key, leastRecentCacheItem->key);
			
			leastRecentCacheItem->prev->next = nil;
			
			evictedCacheItem = leastRecentCacheItem;
			leastRecentCacheItem = leastRecentCacheItem->prev;

			CFDictionaryRemoveValue(cfdict, (const void *)(evictedCacheItem->key));
			
			evictedCacheItem->prev = nil;
			evictedCacheItem->next = nil;
			evictedCacheItem->key = nil;
			evictedCacheItem->value = nil;
			
			#if YAP_CACHE_STATISTICS
			evictionCount++;
			#endif
		}
		else
		{
			if (leastRecentCacheItem == nil)
				leastRecentCacheItem = item;
			
			YDBLogVerbose(@"key(%@) <- new, new mostRecent [%ld of %lu]",
			              key, CFDictionaryGetCount(cfdict), (unsigned long)countLimit);
		}
	}
	
	if (ydbLogLevel & YDB_LOG_FLAG_VERBOSE)
	{
		YDBLogVerbose(@"cfdict: %@", cfdict);
		
		YapCacheItem *loopItem = mostRecentCacheItem;
		NSUInteger i = 0;
		
		while (loopItem != nil)
		{
			YDBLogVerbose(@"%lu: %@", (unsigned long)i, loopItem);
			
			loopItem = loopItem->next;
			i++;
		}
	}
}

- (NSUInteger)count
{
	return CFDictionaryGetCount(cfdict);
}

- (void)removeAllObjects
{
	mostRecentCacheItem = nil;
	leastRecentCacheItem = nil;
	evictedCacheItem = nil;
	
	CFDictionaryRemoveAllValues(cfdict);
}

- (void)removeObjectForKey:(id)key
{
	NSAssert([key isKindOfClass:keyClass], @"Unexpected key class. Expected %@, passed %@", keyClass, [key class]);
	
	YapCacheItem *item = CFDictionaryGetValue(cfdict, (const void *)key);
	if (item)
	{
		if (item->prev)
			item->prev->next = item->next;
		
		if (item->next)
			item->next->prev = item->prev;
		
		if (mostRecentCacheItem == item)
			mostRecentCacheItem = item->next;
		
		if (leastRecentCacheItem == item)
			leastRecentCacheItem = item->prev;
		
		CFDictionaryRemoveValue(cfdict, (const void *)key);
	}
}

- (void)removeObjectsForKeys:(NSArray *)keys
{
	for (id key in keys)
	{
		NSAssert([key isKindOfClass:keyClass], @"Unexpected key class. Expected %@, passed %@", keyClass, [key class]);
		
		YapCacheItem *item = CFDictionaryGetValue(cfdict, (const void *)key);
		if (item)
		{
			if (item->prev)
				item->prev->next = item->next;
			
			if (item->next)
				item->next->prev = item->prev;
			
			if (mostRecentCacheItem == item)
				mostRecentCacheItem = item->next;
			
			if (leastRecentCacheItem == item)
				leastRecentCacheItem = item->prev;
			
			CFDictionaryRemoveValue(cfdict, (const void *)key);
		}
	}
}

- (void)enumerateKeysWithBlock:(void (^)(id key, BOOL *stop))block
{
	NSDictionary *nsdict = (__bridge NSDictionary *)cfdict;
	BOOL stop = NO;
	
	for (id key in [nsdict keyEnumerator])
	{
		block(key, &stop);
		
		if (stop) break;
	}
}

- (NSString *)description
{
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"%@, count=%ld, keys=\n", NSStringFromClass([self class]), CFDictionaryGetCount(cfdict)];
	
	YapCacheItem *item = mostRecentCacheItem;
	NSUInteger itemIndex = 0;
	
	while (item != nil)
	{
		[description appendFormat:@"  %lu: %@\n", (unsigned long)itemIndex, item->key];
		
		item = item->next;
		itemIndex++;
	}
	
	return description;
}

/*
- (void)debug
{
	CFIndex count = CFDictionaryGetCount(cfdict);
	NSAssert(count <= countLimit, @"Invalid count");
	
	NSMutableArray *forwardsKeys = [NSMutableArray arrayWithCapacity:count];
	NSMutableArray *backwardsKeys = [NSMutableArray arrayWithCapacity:count];
	
	__unsafe_unretained YapCacheItem *loopItem;
	
	loopItem = mostRecentCacheItem;
	while (loopItem != nil)
	{
		[forwardsKeys addObject:loopItem->key];
		loopItem = loopItem->next;
	}
	
	loopItem = leastRecentCacheItem;
	while (loopItem != nil)
	{
		[backwardsKeys insertObject:loopItem->key atIndex:0];
		loopItem = loopItem->prev;
	}
	
	NSAssert([forwardsKeys isEqual:backwardsKeys], @"Invalid order");
}
*/

@end
