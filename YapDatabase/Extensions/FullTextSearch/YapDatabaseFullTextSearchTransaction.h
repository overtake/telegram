#import <Foundation/Foundation.h>

#import "YapDatabaseExtensionTransaction.h"
#import "YapDatabaseFullTextSearchSnippetOptions.h"


/**
 * Welcome to YapDatabase!
 *
 * The project page has a wealth of documentation if you have any questions.
 * https://github.com/yaptv/YapDatabase
 *
 * If you're new to the project you may want to check out the wiki
 * https://github.com/yaptv/YapDatabase/wiki
 *
 * YapDatabaseFullTextSearch is an extension for performing text based search.
 * Internally it uses sqlite's FTS module which was contributed by Google.
 *
 * After registering the extension, you can access this class within a regular transaction.
 * For example:
 *
 * [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
 *
 *     [[transaction ext:@"mySearch"] enumerateKeysMatching:@"birthday party"
 *                                               usingBlock:^(NSString *collection, NSString *key, BOOL *stop){
 *         // matching row...
 *     }]
 * }];
**/
@interface YapDatabaseFullTextSearchTransaction : YapDatabaseExtensionTransaction

// Regular query matching

- (void)enumerateKeysMatching:(NSString *)query
                   usingBlock:(void (^)(NSString *collection, NSString *key, BOOL *stop))block;

- (void)enumerateKeysAndMetadataMatching:(NSString *)query
                              usingBlock:(void (^)(NSString *collection, NSString *key, id metadata, BOOL *stop))block;

- (void)enumerateKeysAndObjectsMatching:(NSString *)query
                             usingBlock:(void (^)(NSString *collection, NSString *key, id object, BOOL *stop))block;

- (void)enumerateRowsMatching:(NSString *)query
                   usingBlock:(void (^)(NSString *collection, NSString *key, id object, id metadata, BOOL *stop))block;

// Query matching + Snippets

- (void)enumerateKeysMatching:(NSString *)query
           withSnippetOptions:(YapDatabaseFullTextSearchSnippetOptions *)options
                   usingBlock:
            (void (^)(NSString *snippet, NSString *collection, NSString *key, BOOL *stop))block;

- (void)enumerateKeysAndMetadataMatching:(NSString *)query
                      withSnippetOptions:(YapDatabaseFullTextSearchSnippetOptions *)options
                              usingBlock:
            (void (^)(NSString *snippet, NSString *collection, NSString *key, id metadata, BOOL *stop))block;

- (void)enumerateKeysAndObjectsMatching:(NSString *)query
                     withSnippetOptions:(YapDatabaseFullTextSearchSnippetOptions *)options
                             usingBlock:
            (void (^)(NSString *snippet, NSString *collection, NSString *key, id object, BOOL *stop))block;

- (void)enumerateRowsMatching:(NSString *)query
           withSnippetOptions:(YapDatabaseFullTextSearchSnippetOptions *)options
                   usingBlock:
            (void (^)(NSString *snippet, NSString *collection, NSString *key, id object, id metadata, BOOL *stop))block;

@end
