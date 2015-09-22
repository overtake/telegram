//
//  TGCache.m
//  Telegram
//
//  Created by keepcoder on 17.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGCache.h"
#import "ASQueue.h"
@interface TGCacheRecord : NSObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, strong) id object;
@property (nonatomic) NSUInteger size;

- (id)initWithObject:(id)object size:(NSUInteger)size;

@end

@implementation TGCacheRecord

- (id)initWithObject:(id)object size:(NSUInteger)size
{
    self = [super init];
    if (self != nil)
    {
        _object = object;
        _date = CFAbsoluteTimeGetCurrent();
        _size = size;
    }
    return self;
}

@end



@interface TGCache ()

@property (nonatomic,strong) NSMutableDictionary *groups;
@property (nonatomic,strong) NSMutableDictionary *groupMemoryTaken;
@property (nonatomic,strong) NSMutableDictionary *groupMemoryLimit;
@property (nonatomic,strong) NSMutableDictionary *groupCountLimit;




@property (nonatomic,strong) ASQueue *queue;


@end


static const int defaultMemoryLimit = 16*1024*1024;

@implementation TGCache

NSString *const IMGCACHE = @"IMGCACHE";
NSString *const THUMBCACHE = @"THUMBCACHE";
NSString *const PVCACHE = @"PVCACHE";
NSString *const PCCACHE = @"PCCACHE";
NSString *const AVACACHE = @"AVACACHE";

-(id)init {
    if(self = [super init]) {
        
        _queue = [[ASQueue alloc] initWithName:"tgcachequeue"];
        
        _groups = [[NSMutableDictionary alloc] init];
        _groupMemoryTaken = [[NSMutableDictionary alloc] init];
        _groupMemoryLimit = [[NSMutableDictionary alloc] init];
        _groupCountLimit = [[NSMutableDictionary alloc] init];
        NSArray *keys = @[IMGCACHE,THUMBCACHE,PVCACHE,PCCACHE,AVACACHE];
        
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            _groupMemoryLimit[obj] = @(defaultMemoryLimit);
            _groupMemoryTaken[obj] = @(0);
            _groups[obj] = [[NSMutableDictionary alloc] init];
            _groupCountLimit[obj] = @(0);
            
        }];
        

    }
    return self;
}

+(TGCache *)cache {
    static TGCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[TGCache alloc] init];
    });
    
    return cache;
}


// global methods

+(void)cacheImage:(NSImage *)image forKey:(NSString *)key groups:(NSArray *)groups {
    
    if(!image)
        return;
    
    [[self cache].queue dispatchOnQueue:^{
        [[self cache] cacheImage:image forKey:key groups:groups];
    }];
}

+(NSImage *)cachedImage:(NSString *)key {
    __block NSImage *image;
    
    [[self cache].queue dispatchOnQueue:^{
        
        image = [[self cache] cachedImage:key];
        
    } synchronous:YES];
    
    return image;
}

+(NSImage *)cachedImage:(NSString *)key group:(NSArray *)groups {
    __block NSImage *image;
    
    [[self cache].queue dispatchOnQueue:^{
        
        image = [[self cache] cachedImage:key group:groups];
        
    } synchronous:YES];
    
    return image;
}

+(void)removeCachedImage:(NSString *)key {
    [[self cache].queue dispatchOnQueue:^{
        
        [[self cache] removeCachedImage:key];
        
    }];
}

+(void)removeCachedImage:(NSString *)key groups:(NSArray *)groups {
    [[self cache].queue dispatchOnQueue:^{
        
        [[self cache] removeCachedImage:key groups:groups];
        
    }];
}


+(void)removeAllCachedImages:(NSArray *)groups {
    [[self cache].queue dispatchOnQueue:^{
        
        [[self cache] removeAllCachedImages:groups];
        
    }];
}

+(void)setMemoryLimit:(NSUInteger)limit group:(NSString *)group {
    [[self cache].queue dispatchOnQueue:^{
        
        [[self cache] setMemoryLimit:limit group:group];
        
    }];
}

+(void)setCountLimit:(NSUInteger)limit group:(NSString *)group {
    [[self cache].queue dispatchOnQueue:^{
        
        [[self cache] setCountLimit:limit group:group];
        
    }];
}

+(void)changeKey:(NSString *)key withKey:(NSString *)nkey {
    
    [[self cache].queue dispatchOnQueue:^{
        
        [[self cache] changeKey:key withKey:nkey];
        
    }];
    
}


// local methods its

-(void)cacheImage:(NSImage *)image forKey:(NSString *)key groups:(NSArray *)groups {
    
    if(!image || !key || !groups)
        return;
    
    
    
    
    NSUInteger size = image.size.width * image.size.height * 4;
    
    [groups enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        NSMutableDictionary *group = _groups[obj];
        TGCacheRecord *record = group[key];
        
        if(record) {
            _groupMemoryTaken[obj] = @([_groupMemoryTaken[obj] integerValue] - record.size);
            record.date = CFAbsoluteTimeGetCurrent();
            record.size = size;
            record.object = image;
        } else {
            group[key] = [[TGCacheRecord alloc] initWithObject:image size:size];
        }
        
        
        
         _groupMemoryTaken[obj] = @([_groupMemoryTaken[obj] integerValue] + size);
        
    }];
    
    
   
    
    [self checkMemory];

}

-(NSImage *)cachedImage:(NSString *)key {
    return [self cachedImage:key group:[_groups allKeys]];
}

-(NSImage *)cachedImage:(NSString *)key group:(NSArray *)groups {
    __block NSImage *image;
    
     [groups enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
       TGCacheRecord *record = _groups[obj][key];
        
        if(record)
        {
            record.date = CFAbsoluteTimeGetCurrent();
            image = record.object;
            *stop = YES;
        } else  {
          //  image = [_emCache imageForKey:[NSString stringWithFormat:@"%@_%@",key,obj]];
            
          //  if(image) {
          //      *stop = YES;
          //  }
        }
        
    }];
    
    return image;
}

-(void)removeCachedImage:(NSString *)key {
    [self removeCachedImage:key groups:[_groups allKeys]];
}

-(void)removeCachedImage:(NSString *)key groups:(NSArray *)groups {
    
    [groups enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        TGCacheRecord *record = _groups[obj][key];
        
        if(record)
        {
            [_groups[obj] removeObjectForKey:key];
            
             _groupMemoryTaken[obj] = @([_groupMemoryTaken[obj] integerValue] - record.size);
            
        }
        
    }];
    
    [self checkMemory];
    
}

-(void)removeAllCachedImages:(NSArray *)groups {
    [groups enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        [_groups[obj] removeAllObjects];
            
        _groupMemoryTaken[obj] = @(0);
        
    }];
}


-(void)checkMemory {
    
    NSMutableDictionary *update = [[NSMutableDictionary alloc] init];
    
    [_groupMemoryTaken enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
        
        
        NSUInteger size = [obj integerValue];
        NSUInteger limit = [_groupMemoryLimit[key] integerValue];
        
        NSUInteger maxCount = [_groupCountLimit[key] integerValue];
        
         NSMutableDictionary *group = _groups[key];
        
        
        if(size > limit && (maxCount == 0 || maxCount < [group count])) {
            
            __unused NSUInteger sizeAfter = size;
            
            NSArray *sortedKeys = [group keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return (((TGCacheRecord *)obj1).date < ((TGCacheRecord *)obj2).date) ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            for (int i = 0; i < sortedKeys.count && sizeAfter > limit; i++)
            {
                NSString *key = [sortedKeys objectAtIndex:i];
                
                TGCacheRecord *record = [group objectForKey:key];
                sizeAfter -= record.size;
                [group removeObjectForKey:key];
            }
            
            __block NSUInteger currentCacheSize = 0;
            
            [group enumerateKeysAndObjectsUsingBlock:^(__unused NSString *key, TGCacheRecord *record, __unused BOOL *stop) {
                currentCacheSize += record.size;
            }];
            
            update[key] = @(currentCacheSize);

        }
        
    }];
    
    [_groupMemoryTaken addEntriesFromDictionary:update];
    

}

-(void)setMemoryLimit:(NSUInteger)limit group:(NSString *)group {
    _groupMemoryLimit[group] = @(limit);
}

-(void)setCountLimit:(NSUInteger)limit group:(NSString *)group {
     _groupCountLimit[group] = @(limit);
}


-(void)changeKey:(NSString *)key withKey:(NSString *)nKey {
    
    [_groups enumerateKeysAndObjectsUsingBlock:^(NSString *groupKey, NSMutableDictionary *obj, BOOL *stop) {
        
        TGCacheRecord *record = obj[key];
        
        if(record)
        {
            obj[nKey] = record;
           // [obj removeObjectForKey:key];
        }
        
    }];
}

+(void)clear {
    [[self cache].queue dispatchOnQueue:^{
        
        [[self cache] clear];
        
    }];
}


-(void)clear {
    [_groups enumerateKeysAndObjectsUsingBlock:^(NSString *groupKey, NSMutableDictionary *obj, BOOL *stop) {
        
        [obj removeAllObjects];
        
    }];
}

@end
