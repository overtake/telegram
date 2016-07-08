//
//  TGSearchSignalKit.m
//  Telegram
//
//  Created by keepcoder on 06/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGSearchSignalKit.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation TGSearchKitItem

-(id)initWithAddedArray:(NSArray *)added URI:(NSString *)URI indexSelector:(SEL)indexSelector uniqueKeySelector:(SEL)uniqueKeySelector {
    if(self = [super init]) {
        _added = added;
        _URI = URI;
        _indexSelector = indexSelector;
        _uniqueKeySelector = uniqueKeySelector;
    }
    
    return self;
}

@end


@interface TGSearchSignalKit ()
{
    SKIndexRef _indexRef;
}
@property (nonatomic,strong) NSMutableData *indexData;
@end

@implementation TGSearchSignalKit

-(instancetype)init {
    if(self = [super init]) {
        
        _indexData = [NSMutableData data];
        

        _indexRef = SKIndexCreateWithMutableData((__bridge CFMutableDataRef)_indexData, NULL, kSKIndexInverted, nil);
        
        assert(_indexRef != nil);

        
    }
    
    return self;
}

-(void)reIndexSearchWithItem:(TGSearchKitItem *)changeItem {
    

    [changeItem.added enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj respondsToSelector:changeItem.indexSelector] && [obj respondsToSelector:changeItem.uniqueKeySelector]) {
            
            NSString * (*indexf)(id,SEL) = (NSString * (*)(id,SEL))[obj methodForSelector: changeItem.indexSelector];
            int (*uniquef)(id,SEL) = (int (*)(id,SEL))[obj methodForSelector: changeItem.uniqueKeySelector];

            NSString *text = (indexf)(obj, changeItem.indexSelector);
            NSString *uniqueKey = [NSString stringWithFormat:@"%d",(uniquef)(obj, changeItem.uniqueKeySelector)];
            
            SKDocumentRef document = SKDocumentCreate((__bridge CFStringRef)changeItem.URI, NULL, (__bridge CFStringRef)uniqueKey );
            
            
            SKIndexAddDocumentWithText(_indexRef, document, (__bridge CFStringRef)text, true);
            
            CFRelease(document);
        }
 
    }];
    
    //SKIndexCompact(_indexRef);
    
    
    NSLog(@"%ld",SKIndexGetDocumentCount(_indexRef));
    
    int bp = 0;
}

static const int kDefaultSearchLimit = 1000;

-(SSignal *)search:(NSString *)query parser:(id (^)(id object))parser {
    
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
         NSArray *components = [query componentsSeparatedByString:@" "];
        
        __block NSString *q = @"";
        
        [components enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(obj.length > 0)
                q = [q stringByAppendingString:[obj stringByAppendingString:@"*"]];
            
            if(idx != components.count - 1)
                q = [q stringByAppendingString:@" AND "];
            
        }];
        
        
        SKIndexFlush(_indexRef);
        
        SKSearchOptions options = kSKSearchOptionSpaceMeansOR;
        SKSearchRef search = SKSearchCreate(_indexRef, (__bridge CFStringRef)q, options);
        
        
        NSMutableArray *sresult = [NSMutableArray array];
        
        SKDocumentID documentIDs[kDefaultSearchLimit];
        CFURLRef urls[kDefaultSearchLimit];
        float scores[kDefaultSearchLimit];
        CFIndex foundCount;
        
        SKSearchFindMatches(search, kDefaultSearchLimit, documentIDs, scores, 0.5, &foundCount);
        
        
        SKIndexCopyDocumentURLsForDocumentIDs(_indexRef, foundCount, documentIDs, urls);
        
        for (CFIndex i = 0; i < foundCount; i++) {
            CFURLRef url = urls[i];
            
            if (!url) {
                CFRelease(url);
                continue;
            }
            
            NSString * uriKey = ((__bridge NSURL *)url).absoluteString;
            
            [sresult addObject:parser ? parser(uriKey)  : uriKey];
            
            CFRelease(url);
        }
        CFRelease(search);
        search = nil;
        

        [subscriber putNext:sresult];
        
        [subscriber putCompletion];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            if(search) {
                SKSearchCancel(search);
                CFRelease(search);
            }
            
        }];
            
    }];
    
}

-(void)dealloc {
    [self closeIndex];
}

- (void) closeIndex {
    if (_indexRef) {
        SKIndexClose (_indexRef);
        _indexRef = nil;
    }
}



@end


/*
 //
 //  TGSearchSignalKit.m
 //  Telegram
 //
 //  Created by keepcoder on 06/07/16.
 //  Copyright © 2016 keepcoder. All rights reserved.
 //
 
 #import "TGSearchSignalKit.h"
 #import <CoreFoundation/CoreFoundation.h>
 #import "SPSearchStore.h"
 
 @implementation TGSearchKitItem
 
 -(id)initWithChangedArray:(NSArray *)changed URI:(NSString *)URI indexSelector:(SEL)indexSelector uniqueKeySelector:(SEL)uniqueKeySelector {
 if(self = [super init]) {
 _changed = changed;
 _URI = URI;
 _indexSelector = indexSelector;
 _uniqueKeySelector = uniqueKeySelector;
 }
 
 return self;
 }
 
 @end
 
 
 @interface TGSearchSignalKit ()
 {
 //  SKIndexRef _indexRef;
 SPSearchStore *_core;
 }
 @end
 
 @implementation TGSearchSignalKit
 
 -(instancetype)init {
 if(self = [super init]) {
 
 
 
 //        _indexRef = SKIndexCreateWithMutableData((__bridge CFMutableDataRef)_indexData, NULL, kSKIndexInverted, nil);
 //
 //        assert(_indexRef != nil);
 
 //        [SPSearchStore setDefaultTextAnalysisOption:[SPSearchStore stopWordsForLanguage:@"en"]
 //                                             forKey:(NSString *)kSKStopWords];
 //
 //        [SPSearchStore setDefaultTextAnalysisOption:[NSNumber numberWithBool:YES]
 //                                             forKey:(NSString *)kSKProximityIndexing];
 //
 //        [SPSearchStore setDefaultTextAnalysisOption:[NSNumber numberWithInteger:1]
 //                                             forKey:(NSString *)kSKMinTermLength];
 
 
 _core = [[SPSearchStore alloc] initStoreWithMemory:nil type:kSKIndexInverted];
 _core.usesSpotlightImporters = YES;
 _core.usesConcurrentIndexing = YES;
 _core.ignoresNumericTerms = YES;
 
 
 
 }
 
 return self;
 }
 
 -(void)reIndexSearchWithItem:(TGSearchKitItem *)changeItem {
 
 
 [changeItem.changed enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
 
 if([obj respondsToSelector:changeItem.indexSelector] && [obj respondsToSelector:changeItem.uniqueKeySelector]) {
 
 NSString * (*indexf)(id,SEL) = (NSString * (*)(id,SEL))[obj methodForSelector: changeItem.indexSelector];
 int (*uniquef)(id,SEL) = (int (*)(id,SEL))[obj methodForSelector: changeItem.uniqueKeySelector];
 
 NSString *text = (indexf)(obj, changeItem.indexSelector);
 NSString *uniqueKey = [NSString stringWithFormat:@"%d",(uniquef)(obj, changeItem.uniqueKeySelector)];
 
 //  SKDocumentRef document = SKDocumentCreate((__bridge CFStringRef)changeItem.URI, NULL, (__bridge CFStringRef)uniqueKey );
 
 
 [_core addDocument:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@",changeItem.URI,uniqueKey]] withText:text];
 
 // SKIndexAddDocumentWithText(_indexRef, document, (__bridge CFStringRef)text, true);
 
 // CFRelease(document);
 }
 
 }];
 
 //SKIndexCompact(_indexRef);
 
 
 //  NSLog(@"%ld",SKIndexGetDocumentCount(_indexRef));
 
 int bp = 0;
 }
 
 static const int kDefaultSearchLimit = 1000;
 
 -(SSignal *)search:(NSString *)query parser:(id (^)(id object))parser {
 
 
 return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
 
 NSArray *components = [query componentsSeparatedByString:@" "];
 
 __block NSString *q = @"";
 
 [components enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
 
 if(obj.length > 0)
 q = [q stringByAppendingString:[obj stringByAppendingString:@"*"]];
 
 if(idx != components.count - 1)
 q = [q stringByAppendingString:@" AND "];
 
 }];
 
 [_core cancelSearch];
 
 SKSearchOptions options = kSKSearchOptionSpaceMeansOR;
 
 [_core prepareSearch:q options:kSKSearchOptionSpaceMeansOR];
 
 NSArray *documents = [[NSArray alloc] init];
 
 float *ranks;
 
 [_core fetchResults:&documents ranks:&ranks untilFinished:YES];
 
 
 //        SKIndexFlush(_indexRef);
 //
 //        SKSearchOptions options = kSKSearchOptionSpaceMeansOR;
 //        SKSearchRef search = SKSearchCreate(_indexRef, (__bridge CFStringRef)q, options);
 //
 //
 //        NSMutableArray *sresult = [NSMutableArray array];
 //
 //        SKDocumentID documentIDs[kDefaultSearchLimit];
 //        CFURLRef urls[kDefaultSearchLimit];
 //        float scores[kDefaultSearchLimit];
 //        CFIndex foundCount;
 //
 //        SKSearchFindMatches(search, kDefaultSearchLimit, documentIDs, scores, 0.5, &foundCount);
 //
 //
 //        SKIndexCopyDocumentURLsForDocumentIDs(_indexRef, foundCount, documentIDs, urls);
 //
 //        for (CFIndex i = 0; i < foundCount; i++) {
 //            CFURLRef url = urls[i];
 //
 //            if (!url) {
 //                CFRelease(url);
 //                continue;
 //            }
 //
 //            NSString * uriKey = ((__bridge NSURL *)url).absoluteString;
 //
 //            [sresult addObject:parser ? parser(uriKey)  : uriKey];
 //
 //            CFRelease(url);
 //        }
 //        CFRelease(search);
 //
 //
 //
 //
 NSMutableArray *sresult = [NSMutableArray array];
 
 [documents enumerateObjectsUsingBlock:^(NSURL *obj, NSUInteger idx, BOOL * _Nonnull stop) {
 [sresult addObject:parser ? parser(obj.absoluteString)  : obj.absoluteString];
 }];
 
 [subscriber putNext:documents];
 
 return [[SBlockDisposable alloc] initWithBlock:^{
 
 [_core cancelSearch];
 
 
 // SKSearchCancel(search);
 // CFRelease(search);
 }];
 
 }];
 
 }
 
 -(void)dealloc {
 [self closeIndex];
 }
 
 - (void) closeIndex {
 
 [_core closeStore];
 _core = nil;
 
 
 // if (_indexRef) {
 //  SKIndexClose (_indexRef);
 //   _indexRef = nil;
 // }
 }
 
 
 
 @end

 */
