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
@interface MessageSender : NSObject

+(RPCRequest *)sendStatedMessage:(id)request successHandler:(RPCSuccessHandler)successHandler errorHandler:(RPCErrorHandler)errorHandler;

+(TL_localMessage *)createOutMessage:(NSString *)message media:(TGMessageMedia *)media dialog:(TL_conversation *)dialog;
+(int)getFutureMessageId;
+(int)getFakeMessageId;
+(void)drop;
+(void)insertEncryptedServiceMessage:(NSString *)title chat:(TGEncryptedChat *)chat;
+(void)startEncryptedChat:(TGUser *)user callback:(dispatch_block_t)callback;
+(RPCRequest *)setTTL:(int)ttl toConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback;
+(BOOL)sendDraggedFiles:(id <NSDraggingInfo>)sender dialog:(TL_conversation *)dialog asDocument:(BOOL)asDocument;
+(void)sendFilesByPath:(NSArray *)files dialog:(TL_conversation *)dialog asDocument:(BOOL)asDocument;

+ (NSDictionary *)videoParams:(NSString *)path;
+(void)compressVideo:(NSString *)path randomId:(long)randomId completeHandler:(void (^)(BOOL success,NSString *compressedPath))completeHandler progressHandler:(void (^)(float progress))progressHandler;

+(id)requestForDeleteEncryptedMessages:(NSMutableArray *)ids dialog:(TL_conversation *)dialog;
+(id)requestForFlushEncryptedHistory:(TL_conversation *)dialog;


+(NSData *)getEncrypted:(EncryptedParams *)params messageData:(NSData *)messageData;
@end
