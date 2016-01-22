//
//  SecretSenterItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"
#import "Crypto.h"
#import "NSMutableData+Extension.h"
#import "UpgradeLayerSenderItem.h"
#import "MessageTableItem.h"
@interface SecretSenderItem ()<SenderListener>
@property (nonatomic,strong,readonly) NSData *decryptedData;
@end

@implementation SecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation {
    if(self = [self init]) {
        self.conversation = conversation;
        _params = [EncryptedParams findAndCreate:conversation.peer_id];
    }
    
    return self;
}

-(id)init {
    if(self = [super init]) {
        _random_id = rand_long();
        _random_bytes = [[NSMutableData alloc] initWithRandomBytes:16];
    }
    
    return self;
}

-(void)setConversation:(TL_conversation *)conversation {
    [super setConversation:conversation];
    
    
}

-(void)setAction:(TGSecretAction *)action {
    _action = action;
    [self addEventListener:_action];
}

-(id)initWithSecretAction:(TGSecretAction *)action {
    if(self = [self init]) {
        self.action = action;
        _decryptedData = self.action.decryptedData;
    }
    
    return self;
}

-(void)setMessage:(TL_localMessage *)message {
    [super setMessage:message];
   
    if(!_params)
        _params = [EncryptedParams findAndCreate:message.peer_id];
}


-(id)initWithDecryptedData:(NSData *)decryptedData conversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        _decryptedData = decryptedData;
        self.conversation = conversation;
    }
    
    return self;
    
}

-(NSData *)decryptedMessageLayer0 {
    return nil;
}

-(NSData *)deleteRandomMessageData0 {
    return nil;
}


-(NSData *)deleteRandomMessageData1 {
    return [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) random_bytes:self.random_bytes action:[Secret1_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]];
}

-(NSData *)deleteRandomMessageData17 {
    return [Secret17__Environment serializeObject:[Secret17_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(17) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*self.params.out_seq_no + [self.params out_x]) message:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret17_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]]];
}

-(NSData *)deleteRandomMessageData20 {
    return [Secret20__Environment serializeObject:[Secret20_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(20) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*self.params.out_seq_no + [self.params out_x]) message:[Secret20_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret20_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]]];
}

-(NSData *)deleteRandomMessageData23 {
    return [Secret23__Environment serializeObject:[Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(23) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*self.params.out_seq_no + [self.params out_x]) message:[Secret23_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret23_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]]];
}

-(NSData *)deleteRandomMessageData45 {
    return [Secret45__Environment serializeObject:[Secret45_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(45) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*self.params.out_seq_no + [self.params out_x]) message:[Secret45_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret45_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]]];
}

-(NSData *)deleteRandomMessageData {
    return  [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"deleteRandomMessageData%d",_params.layer])];;
}

-(id)decryptedMessageLayer {
    
    if(!_decryptedData) {
        
        _decryptedData = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"decryptedMessageLayer%d",_params.layer])];

    }
    
    
    
    return _decryptedData;
}

-(BOOL)increaseSeq {
    return YES;
}


/*
 NSMutableArray *entities = [[NSMutableArray alloc] init];
 
 
 [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
 
 Class messageEntityUnknown = convertClass(@"Secret%d_MessageEntity_messageEntityUnknown", layer);
 Class messageEntityMention = convertClass(@"Secret%d_MessageEntity_messageEntityMention", layer);
 Class messageEntityHashtag = convertClass(@"Secret%d_MessageEntity_messageEntityHashtag", layer);
 Class messageEntityBotCommand = convertClass(@"Secret%d_MessageEntity_messageEntityBotCommand", layer);
 Class messageEntityEmail = convertClass(@"Secret%d_MessageEntity_messageEntityEmail", layer);
 Class messageEntityBold = convertClass(@"Secret%d_MessageEntity_messageEntityBold", layer);
 Class messageEntityItalic = convertClass(@"Secret%d_MessageEntity_messageEntityItalic", layer);
 Class messageEntityCode = convertClass(@"Secret%d_MessageEntity_messageEntityCode", layer);
 Class messageEntityPre = convertClass(@"Secret%d_MessageEntity_messageEntityPre", layer);
 Class messageEntityTextUrl = convertClass(@"Secret%d_MessageEntity_messageEntityTextUrl", layer);
 
 
 if([obj isKindOfClass:messageEntityUnknown]) {
 [entities addObject:[TL_messageEntityUnknown createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue]]];
 } else if([obj isKindOfClass:messageEntityMention]) {
 [entities addObject:[TL_messageEntityMention createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue]]];
 } else if([obj isKindOfClass:messageEntityHashtag]) {
 [entities addObject:[TL_messageEntityHashtag createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue]]];
 } else if([obj isKindOfClass:messageEntityBotCommand]) {
 [entities addObject:[TL_messageEntityBotCommand createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue]]];
 } else if([obj isKindOfClass:messageEntityEmail]) {
 [entities addObject:[TL_messageEntityEmail createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue]]];
 } else if([obj isKindOfClass:messageEntityBold]) {
 [entities addObject:[TL_messageEntityBold createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue]]];
 } else if([obj isKindOfClass:messageEntityItalic]) {
 [entities addObject:[TL_messageEntityItalic createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue]]];
 } else if([obj isKindOfClass:messageEntityCode]) {
 [entities addObject:[TL_messageEntityCode createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue]]];
 } else if([obj isKindOfClass:messageEntityPre]) {
 [entities addObject:[TL_messageEntityPre createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue] language:[obj valueForKey:@"language"]]];
 } else if([obj isKindOfClass:messageEntityTextUrl]) {
 [entities addObject:[TL_messageEntityTextUrl createWithOffset:[[obj valueForKey:@"offset"] intValue] length:[[obj valueForKey:@"length"] intValue] url:[obj valueForKey:@"url"]]];
 }
 
 }];
 
 return entities;
 */

-(NSArray *)convertLEntities:(NSArray *)entities layer:(int)layer {
    NSMutableArray *convertedEntities = [[NSMutableArray alloc] init];
    
    
    [entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL *stop) {
        
        Class baseClass = NSClassFromString([NSString stringWithFormat:@"Secret%d_MessageEntity", layer]);
        
        if([obj isKindOfClass:[TL_messageEntityUnknown class]]) {
            [convertedEntities addObject:[baseClass messageEntityUnknownWithOffset:@(obj.offset) length:@(obj.length)]];
        } else if([obj isKindOfClass:[TL_messageEntityMention class]]) {
            [convertedEntities addObject:[baseClass messageEntityMentionWithOffset:@(obj.offset) length:@(obj.length)]];
        } else if([obj isKindOfClass:[TL_messageEntityHashtag class]]) {
            [convertedEntities addObject:[baseClass messageEntityHashtagWithOffset:@(obj.offset) length:@(obj.length)]];
        } else if([obj isKindOfClass:[TL_messageEntityBotCommand class]]) {
            [convertedEntities addObject:[baseClass messageEntityBotCommandWithOffset:@(obj.offset) length:@(obj.length)]];
        } else if([obj isKindOfClass:[TL_messageEntityEmail class]]) {
            [convertedEntities addObject:[baseClass messageEntityEmailWithOffset:@(obj.offset) length:@(obj.length)]];
        } else if([obj isKindOfClass:[TL_messageEntityBold class]]) {
            [convertedEntities addObject:[baseClass messageEntityBoldWithOffset:@(obj.offset) length:@(obj.length)]];
        }  else if([obj isKindOfClass:[TL_messageEntityItalic class]]) {
            [convertedEntities addObject:[baseClass messageEntityItalicWithOffset:@(obj.offset) length:@(obj.length)]];
        } else if([obj isKindOfClass:[TL_messageEntityCode class]]) {
            [convertedEntities addObject:[baseClass messageEntityCodeWithOffset:@(obj.offset) length:@(obj.length)]];
        } else if([obj isKindOfClass:[TL_messageEntityPre class]]) {
            [convertedEntities addObject:[baseClass messageEntityPreWithOffset:@(obj.offset) length:@(obj.length) language:obj.language]];
        } else if([obj isKindOfClass:[TL_messageEntityTextUrl class]]) {
            [convertedEntities addObject:[baseClass messageEntityTextUrlWithOffset:@(obj.offset) length:@(obj.length) url:obj.url]];
        }
        
    }];
    
    return convertedEntities;
}

-(NSArray *)convertLAttributes:(NSArray *)attributes layer:(int)layer {
    
    NSMutableArray *attrs = [[NSMutableArray alloc] init];
    
    
    [attributes enumerateObjectsUsingBlock:^(TLDocumentAttribute *obj, NSUInteger idx, BOOL *stop) {
        
        @try {
            Class baseClass = NSClassFromString([NSString stringWithFormat:@"Secret%d_DocumentAttribute", layer]);
            
            if([obj isKindOfClass:[TL_documentAttributeImageSize class]]) {
                
                [attrs addObject:[baseClass documentAttributeImageSizeWithW:[obj valueForKey:@"w"] h:[obj valueForKey:@"h"]]];
                
            } else if([obj isKindOfClass:[TL_documentAttributeSticker class]]) {
                
                if(layer >= 45) {
                    [attrs addObject:[baseClass documentAttributeStickerWithAlt:obj.alt stickerset:[Secret45_InputStickerSet inputStickerSetShortNameWithShort_name:obj.stickerset.short_name]]];
                } else {
                    [attrs addObject:[baseClass documentAttributeSticker]];
                }
                
            } else if([obj isKindOfClass:[TL_documentAttributeFilename class]]) {
                
                [attrs addObject:[baseClass documentAttributeFilenameWithFile_name:[obj valueForKey:@"file_name"]]];
                
            } else if([obj isKindOfClass:[TL_documentAttributeVideo class]]) {
                
                [attrs addObject:[baseClass documentAttributeVideoWithDuration:[obj valueForKey:@"duration"] w:[obj valueForKey:@"w"] h:[obj valueForKey:@"h"]]];
                
            } else if([obj isKindOfClass:[TL_documentAttributeAudio class]]) {
                
                [attrs addObject:[baseClass documentAttributeAudioWithDuration:[obj valueForKey:@"duration"]]];
                
            } else if([obj isKindOfClass:[TL_documentAttributeAnimated class]]) {
                
                [attrs addObject:[baseClass documentAttributeAnimated]];
            }
        }
        @catch (NSException *exception) {
            
        }
        
    }];
    
    return attrs;
    
}


-(void)takeAndFillReplyMessage {
    __block TL_localMessage *replyMessage;
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        replyMessage = [transaction objectForKey:self.conversation.cacheKey inCollection:REPLAY_COLLECTION];
        
        [transaction removeObjectForKey:self.conversation.cacheKey inCollection:REPLAY_COLLECTION];
    }];
    
    TL_destructMessage45 *msg = (TL_destructMessage45 *) self.message;
    
    if(replyMessage) {
        [[Storage manager] addSupportMessages:@[replyMessage]];
        msg.replyMessage = replyMessage;
        msg.reply_to_random_id = replyMessage.randomId;
    }
    
    [ASQueue dispatchOnMainQueue:^{
        
        if(replyMessage) {
            [appWindow().navigationController.messagesViewController removeReplayMessage:YES animated:YES];
        }
        
    }];
}

@end
