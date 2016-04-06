//
//  MessageSender.h
//  TelegramTest
//
//  Created by keepcoder on 20.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadOperation.h"
#import "EncryptedParams.h"
#import "MessagesViewController.h"
@interface MessageSender : NSObject


+(TL_localMessage *)createOutMessage:(NSString *)msg media:(TLMessageMedia *)media conversation:(TL_conversation *)conversation  additionFlags:(int)additionFlags;
+(int)getFutureMessageId;
+(int)getFakeMessageId;
+(void)drop;
+(void)insertEncryptedServiceMessage:(NSString *)title chat:(TLEncryptedChat *)chat;
+(void)startEncryptedChat:(TLUser *)user callback:(dispatch_block_t)callback;
+(RPCRequest *)setTTL:(int)ttl toConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback;
+(BOOL)sendDraggedFiles:(id <NSDraggingInfo>)sender dialog:(TL_conversation *)dialog asDocument:(BOOL)asDocument messagesViewController:(MessagesViewController *)messagesViewController;
+(void)sendFilesByPath:(NSArray *)files dialog:(TL_conversation *)dialog isMultiple:(BOOL)isMultiple asDocument:(BOOL)asDocument messagesViewController:(MessagesViewController *)messagesViewController;

+ (NSDictionary *)videoParams:(NSString *)path thumbSize:(NSSize)thumbSize;
+(NSString *)parseEntities:(NSString *)message entities:(NSMutableArray *)entities backstrips:(NSString *)backstrips startIndex:(NSUInteger)startIndex;

+(void)compressVideo:(NSString *)path randomId:(long)randomId completeHandler:(void (^)(BOOL success,NSString *compressedPath))completeHandler progressHandler:(void (^)(float progress))progressHandler;

+(id)requestForDeleteEncryptedMessages:(NSMutableArray *)ids dialog:(TL_conversation *)dialog;
+(id)requestForFlushEncryptedHistory:(TL_conversation *)dialog;


+(NSData *)getEncrypted:(EncryptedParams *)params messageData:(NSData *)messageData;
@end
