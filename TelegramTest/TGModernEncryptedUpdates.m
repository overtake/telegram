//
//  TGModernEncryptedUpdates.m
//  Telegram
//
//  Created by keepcoder on 27.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGModernEncryptedUpdates.h"
#import "SecretLayer1.h"
#import "SecretLayer17.h"
#import "SecretLayer20.h"
#import "SecretLayer23.h"
#import <MtProtoKit/MTEncryption.h>
#import "Crypto.h"
#import "SenderHeader.h"
#import "MessagesUtils.h"
#import "SelfDestructionController.h"
#import "AcceptKeySecretSenderItem.h"
#import "CommitKeySecretSenderItem.h"
#import "AbortKeySecretSenderItem.h"
#import "ResendSecretSenderItem.h"
#import "Crypto.h"
@implementation TGModernEncryptedUpdates


-(void)proccessUpdate:(TL_encryptedMessage *)update {
    
    TL_encryptedChat *chat = [[ChatsManager sharedManager] find:[update chat_id]];
    
    EncryptedParams *params = [EncryptedParams findAndCreate:[update chat_id]];
    
    
    if(chat) {
        
        
        long keyId = 0;
        [update .bytes getBytes:&keyId range:NSMakeRange(0, 8)];
      
        
        NSData *key = [params ekey:keyId];
        
        if(!key) {
            return;
        }
        
        
        NSData *msg_key = [update.bytes subdataWithRange:NSMakeRange(8, 16)];
        NSData *decrypted = [Crypto encrypt:0 data:[update.bytes subdataWithRange:NSMakeRange(24, update.bytes.length - 24)] auth_key:key msg_key:msg_key encrypt:NO];
        
        int messageLength = 0;
        
        [decrypted getBytes:&messageLength range:NSMakeRange(0, 4)];
        
        
        
        if (messageLength < 0 || messageLength > (int32_t)decrypted.length - 4)
            return;
        else {
            NSData *localMessageKeyFull = computeSHA1ForSubdata(decrypted, 0, messageLength + 4);
            
            NSData *localMessageKey = [[NSData alloc] initWithBytes:(((int8_t *)localMessageKeyFull.bytes) + localMessageKeyFull.length - 16) length:16];
            if (![localMessageKey isEqualToData:msg_key])
                return;

        }
        
        
        
        decrypted = [decrypted subdataWithRange:NSMakeRange(4, decrypted.length-4)];
        
        
        int layer = MIN_ENCRYPTED_LAYER;
        if (decrypted.length >= 4)
        {
            
            int32_t possibleLayerSignature = 0;
            [decrypted getBytes:&possibleLayerSignature length:4];
            if (possibleLayerSignature == (int32_t)0x1be31789)
            {
                if (decrypted.length >= 4 + 1)
                {
                    uint8_t randomBytesLength = 0;
                    [decrypted getBytes:&randomBytesLength range:NSMakeRange(4, 1)];
                    while ((randomBytesLength + 1) % 4 != 0)
                    {
                        randomBytesLength++;
                    }
                    
                    if (decrypted.length >= 4 + 1 + randomBytesLength + 4 + 4 + 4)
                    {
                        int32_t value = 0;
                        [decrypted getBytes:&value range:NSMakeRange(4 + 1 + randomBytesLength, 4)];
                        layer = value;
                        
                    }
                }
            }
        }
        
        
        layer = MAX(1, layer);
        
        Class DeserializeClass = NSClassFromString([NSString stringWithFormat:@"Secret%d__Environment",layer]);
        
        SEL proccessMethod = NSSelectorFromString([NSString stringWithFormat:@"proccess%dLayer:params:conversation:encryptedMessage:",layer]);
        
        IMP imp = [self methodForSelector:proccessMethod];
        
        id des;
        
        @try {
            des = [DeserializeClass parseObject:decrypted];
        }
        @catch (NSException *exception) {
            [params discard];
        }
        
        void (*func)(id, SEL, id, EncryptedParams *, TL_conversation *, TL_encryptedMessage *) = (void *)imp;
        func(self, proccessMethod,des,params,chat.dialog, update);
         
    }
    
}



-(BOOL)proccessServiceMessage:(id)message withLayer:(int)layer params:(EncryptedParams *)params conversation:(TL_conversation *)conversation {
    
    if([message isKindOfClass:convertClass(@"Secret%d_DecryptedMessage_decryptedMessageService", layer)]) {
        
        id action = [message valueForKey:@"action"];
        long random_id = [[message valueForKey:@"random_id"] longValue];
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionNotifyLayer", layer)]) {
            
            int layer = [[action valueForKey:@"layer"] intValue];
            
            if(params.layer != MAX_ENCRYPTED_LAYER && params.layer != layer) {
                [self upgradeLayer:params conversation:conversation];
            }
            
            return YES;
            
        }
        
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionSetMessageTTL", layer)]) {
            
            int ttl_seconds = [[action valueForKey:@"ttl_seconds"] intValue];
            
            
            TL_secretServiceMessage *msg = [TL_secretServiceMessage createWithN_id:[MessageSender getFutureMessageId] flags:TGNOFLAGSMESSAGE from_id:[conversation.encryptedChat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:params.n_id] date:[[MTNetwork instance] getTime] action:[TL_messageActionSetMessageTTL createWithTtl:ttl_seconds] fakeId:[MessageSender getFakeMessageId] randomId:random_id out_seq_no:-1 dstate:DeliveryStateNormal];
            
            
            [MessagesManager addAndUpdateMessage:msg];
            
            params.ttl = ttl_seconds;
            
            
           // Destructor *destructor = [[Destructor alloc] initWithTLL:ttl_seconds max_id:msg.n_id chat_id:params.n_id];
          //  [SelfDestructionController addDestructor:destructor];
            
            return YES;
        }
        
        
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionDeleteMessages", layer)]) {
            
            
            NSArray *random_ids = [action valueForKey:@"random_ids"];
            
            [[DialogsManager sharedManager] deleteMessagesWithRandomMessageIds:random_ids isChannelMessages:NO];
            
            return YES;
        }
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionFlushHistory", layer)]) {
            
            [[Storage manager] deleteMessagesInDialog:conversation completeHandler:^{
                
                [Notification perform:MESSAGE_FLUSH_HISTORY data:@{KEY_DIALOG:conversation}];
                
                [[DialogsManager sharedManager] updateLastMessageForDialog:conversation];
                
            }];
            
            return YES;
        }
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionReadMessages", layer)]) {
            
            NSArray *items = [action valueForKey:@"random_ids"];
            
            
            [[Storage manager] messages:^(NSArray *result) {
                
                [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [SelfDestructionController addMessage:obj force:YES];
                }];
                
            } forIds:items random:YES sync:NO queue:_queue ? _queue : [ASQueue globalQueue]];
            
            return YES;
        }
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionScreenshotMessages", layer)]) {
            
            TL_secretServiceMessage *msg = [TL_secretServiceMessage createWithN_id:[MessageSender getFutureMessageId] flags:TGNOFLAGSMESSAGE from_id:[conversation.encryptedChat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:params.n_id] date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:NSLocalizedString(@"MessageAction.Secret.TookScreenshot", nil)] fakeId:[MessageSender getFakeMessageId] randomId:random_id out_seq_no:-1 dstate:DeliveryStateNormal];
            
            [MessagesManager addAndUpdateMessage:msg];
            
            return YES;
        
        }
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionRequestKey", layer)]) {
            
            long exchange_id = [[action valueForKey:@"exchange_id"] longValue];
            
            NSData *g_a = [action valueForKey:@"g_a"];
            
            
            
            uint8_t rawABytes[256];
            SecRandomCopyBytes(kSecRandomDefault, 256, rawABytes);
            
            for (int i = 0; i < 256 && i < (int)params.random.length; i++)
            {
                uint8_t currentByte = ((uint8_t *)params.random.bytes)[i];
                rawABytes[i] ^= currentByte;
            }
            
            NSData * aBytes = [[NSData alloc] initWithBytes:rawABytes length:256];
            
            int32_t tmpG = params.g;
            tmpG = NSSwapInt(tmpG);
            NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
            
            NSData *g_b = MTExp(g, aBytes, params.p);
            
            NSData *key =  MTExp(g_a, aBytes, params.p);
            
            long keyId;
            [[[Crypto sha1:key] subdataWithRange:NSMakeRange(12, 8)] getBytes:&keyId];
            
            
            if (!MTCheckIsSafeGAOrB(g_b, params.p))
            {
                MTLog(@"Surprisingly, we generated an unsafe g_a");
                
            } else {
                
                AcceptKeySecretSenderItem *acceptKey = [[AcceptKeySecretSenderItem alloc] initWithConversation:conversation exchange_id:exchange_id g_b:g_b key_fingerprint:keyId];
                
                [acceptKey send];
                
                [params setKey:key forFingerprint:keyId];
                
                [params setKey_fingerprint:keyId];
                
                [params save];
                
            }

            
            return YES;

        }
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionCommitKey", layer)]) {
            
            
            return YES;
        }
        
        if([action isKindOfClass:convertClass(@"Secret%d_DecryptedMessageAction_decryptedMessageActionAcceptKey", layer)]) {
            
            
            long exchange_id = [[action valueForKey:@"exchange_id"] longValue];
            
            NSData *g_b = [action valueForKey:@"g_b"];
            
            long key_fingerprint = [[action valueForKey:@"key_fingerprint"] longValue];
            
            
            NSData *key =  MTExp(g_b, params.a, params.p);
            
            long keyId;
            [[MTSha1(key) subdataWithRange:NSMakeRange(12, 8)] getBytes:&keyId];
            
            
            if (!MTCheckIsSafeGAOrB(g_b, params.p))
            {
                AbortKeySecretSenderItem *abort = [[AbortKeySecretSenderItem alloc] initWithConversation:conversation exchange_id:exchange_id];
                
                [abort send];
                
            } else {
                
                if(keyId == key_fingerprint) {
                    
                    CommitKeySecretSenderItem *commit = [[CommitKeySecretSenderItem alloc] initWithConversation:conversation exchange_id:exchange_id key_fingerprint:key_fingerprint];
                    
                    [commit send];
                    
                    [params setKey:key forFingerprint:keyId];
                    
                    [params setKey_fingerprint:keyId];
                    
                    [params save];
                    
                } else {
                    // abort key
                    AbortKeySecretSenderItem *abort = [[AbortKeySecretSenderItem alloc] initWithConversation:conversation exchange_id:exchange_id];
                    
                    [abort send];
                }
                
               
                
            }

            
            return YES;
        }
        
    }
    
    
    return NO;
}


Class convertClass(NSString *c, int layer) {
    return NSClassFromString([NSString stringWithFormat:c,layer]);
}


-(void)upgradeLayer:(EncryptedParams *)params conversation:(TL_conversation *)conversation {
    params.layer = MAX_ENCRYPTED_LAYER;
    
    [params save];
    
    UpgradeLayerSenderItem *upgradeLayer = [[UpgradeLayerSenderItem alloc] initWithConversation:conversation];
    
    [upgradeLayer send];
}




-(void)proccess1Layer:(Secret1_DecryptedMessage *)message params:(EncryptedParams *)params conversation:(TL_conversation *)conversation  encryptedMessage:(TL_encryptedMessage *)encryptedMessage  {
    
    BOOL isProccessed = [self proccessServiceMessage:message withLayer:1 params:params conversation:conversation];
    
    if(isProccessed)
        return;
    
    if([message isKindOfClass:[Secret1_DecryptedMessage_decryptedMessage class]]) {
        
        Secret1_DecryptedMessage_decryptedMessage *msg = (Secret1_DecryptedMessage_decryptedMessage *) message;
        
        TLMessageMedia *media = [self media:msg.media layer:1 file:encryptedMessage.file];
        
        int ttl = params.ttl;
        
        TL_localMessage *localMessage = [TL_destructMessage createWithN_id:[MessageSender getFutureMessageId] flags:TGUNREADMESSAGE from_id:[conversation.encryptedChat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:params.n_id] date:encryptedMessage.date message:msg.message media:media destruction_time:0 randomId:[msg.random_id intValue] fakeId:[MessageSender getFakeMessageId] ttl_seconds:ttl out_seq_no:-1 dstate:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:localMessage];
        
    }
      
}

-(void)proccess17Layer:(Secret17_DecryptedMessage *)message params:(EncryptedParams *)params conversation:(TL_conversation *)conversation  encryptedMessage:(TL_encryptedMessage *)encryptedMessage  {
    
    Secret17_DecryptedMessageLayer *layerMessage = (Secret17_DecryptedMessageLayer *)message;
    
    
    MTLog(@"local = %d, remote = %d",params.in_seq_no * 2 + [params in_x],[layerMessage.out_seq_no intValue]);
    
    if([layerMessage.out_seq_no intValue] != 0 && [layerMessage.out_seq_no intValue] < params.in_seq_no * 2 + [params in_x] )
        return;
    
    
    id media = [TL_messageMediaEmpty create];
    
    
    if([layerMessage.message isKindOfClass:[Secret17_DecryptedMessage_decryptedMessage class]]) {
         media = [self media:[layerMessage.message valueForKey:@"media"] layer:17 file:encryptedMessage.file];
    }
    
    TGSecretInAction *action = [[TGSecretInAction alloc] initWithActionId:arc4random() chat_id:params.n_id messageData:[Secret17__Environment serializeObject:layerMessage.message]  fileData:[TLClassStore serialize:media] date:encryptedMessage.date in_seq_no:[layerMessage.out_seq_no intValue] layer:17];
    
    
    [[Storage manager] insertSecretInAction:action];
    
    [self dequeueInActions:params conversation:conversation];
    
}

-(void)proccess20Layer:(Secret20_DecryptedMessage *)message params:(EncryptedParams *)params conversation:(TL_conversation *)conversation  encryptedMessage:(TL_encryptedMessage *)encryptedMessage  {
    
    Secret20_DecryptedMessageLayer *layerMessage = (Secret20_DecryptedMessageLayer *)message;
    
    MTLog(@"local = %d, remote = %d",params.in_seq_no * 2 + [params in_x],[layerMessage.out_seq_no intValue]);
    
    if([layerMessage.out_seq_no intValue] != 0 && [layerMessage.out_seq_no intValue] < params.in_seq_no * 2 + [params in_x] )
        return;
    
    
    id media = [TL_messageMediaEmpty create];
    
    
    
    if([layerMessage.message isKindOfClass:[Secret20_DecryptedMessage_decryptedMessage class]]) {
        media = [self media:[layerMessage.message valueForKey:@"media"] layer:20 file:encryptedMessage.file];
    }
    
    TGSecretInAction *action = [[TGSecretInAction alloc] initWithActionId:arc4random() chat_id:params.n_id messageData:[Secret20__Environment serializeObject:layerMessage.message]  fileData:[TLClassStore serialize:media] date:encryptedMessage.date in_seq_no:[layerMessage.out_seq_no intValue] layer:20];
    
    
    [[Storage manager] insertSecretInAction:action];
    
    [self dequeueInActions:params conversation:conversation];
    
}

-(void)proccess23Layer:(Secret23_DecryptedMessage *)message params:(EncryptedParams *)params conversation:(TL_conversation *)conversation  encryptedMessage:(TL_encryptedMessage *)encryptedMessage  {
    
    Secret23_DecryptedMessageLayer *layerMessage = (Secret23_DecryptedMessageLayer *)message;
    
    MTLog(@"local = %d, remote = %d",params.in_seq_no * 2 + [params in_x],[layerMessage.out_seq_no intValue]);
    
    if([layerMessage.out_seq_no intValue] != 0 && [layerMessage.out_seq_no intValue] < params.in_seq_no * 2 + [params in_x] )
        return;
    
    
    id media = [TL_messageMediaEmpty create];
    
    
    
    if([layerMessage.message isKindOfClass:[Secret23_DecryptedMessage_decryptedMessage class]]) {
        media = [self media:[layerMessage.message valueForKey:@"media"] layer:23 file:encryptedMessage.file];
    }
    
    TGSecretInAction *action = [[TGSecretInAction alloc] initWithActionId:arc4random() chat_id:params.n_id messageData:[Secret23__Environment serializeObject:layerMessage.message]  fileData:[TLClassStore serialize:media] date:encryptedMessage.date in_seq_no:[layerMessage.out_seq_no intValue] layer:23];
    
    
    [[Storage manager] insertSecretInAction:action];
    
    [self dequeueInActions:params conversation:conversation];
    
}


-(void)dequeueInActions:(EncryptedParams *)params conversation:(TL_conversation *)conversation {
    
    [[Storage manager] selectSecretInActions:params.n_id completeHandler:^(NSArray *list) {
        
        [ASQueue dispatchOnStageQueue:^{
            
            __block int startResendSeqNo = 0;
            __block int endResendSeqNo = 0;
            
            
            [list enumerateObjectsUsingBlock:^(TGSecretInAction *action, NSUInteger idx, BOOL *stop) {
                
                if(action.in_seq_no == params.in_seq_no * 2 + [params in_x]) {
                    
                    
                    id messageObject = [NSClassFromString([NSString stringWithFormat:@"Secret%d__Environment",action.layer]) parseObject:action.messageData];
                    
                    id media = [TLClassStore deserialize:action.fileData];
                    
                    BOOL isProccessed = [self proccessServiceMessage:messageObject withLayer:action.layer params:params conversation:conversation];
                    
                    
                    if(!isProccessed && [messageObject isKindOfClass:NSClassFromString([NSString stringWithFormat:@"Secret%d_DecryptedMessage_decryptedMessage",action.layer])]) {
                        
                        
                        TL_destructMessage *localMessage = [TL_destructMessage createWithN_id:[MessageSender getFutureMessageId] flags:TGUNREADMESSAGE from_id:[conversation.encryptedChat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:params.n_id] date:action.date message:[messageObject valueForKey:@"message"] media:media destruction_time:0 randomId:[[messageObject valueForKey:@"random_id"] longValue] fakeId:[MessageSender getFakeMessageId] ttl_seconds:[[messageObject valueForKey:@"ttl"] intValue] out_seq_no:-1 dstate:DeliveryStateNormal];
                        
                        [MessagesManager addAndUpdateMessage:localMessage];
                        
                    }
                    
                    params.in_seq_no++;
                    
                    [[Storage manager] removeSecretInAction:action];
                    
                    
                } else {
                    startResendSeqNo = params.in_seq_no * 2 + [params in_x];
                    endResendSeqNo = action.in_seq_no;
                }
                
                
            }];
            
            if(startResendSeqNo != 0 && endResendSeqNo != 0 && params.layer > 1) {
                ResendSecretSenderItem *resend = [[ResendSecretSenderItem alloc] initWithConversation:conversation start_seq:startResendSeqNo end_seq:endResendSeqNo];
                
                [resend send];
            }
            
        }];
        
        
    }];
    
}


-(NSMutableArray *)convertDocumentAttributes:(NSArray *)lAttrs layer:(int)layer {
    NSMutableArray *attrs = [[NSMutableArray alloc] init];
    
    
    [lAttrs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        Class imageSizeAttr = convertClass(@"Secret%d_DocumentAttribute_documentAttributeImageSize", layer);
        Class stickerAttr = convertClass(@"Secret%d_DocumentAttribute_documentAttributeSticker", layer);
        Class filenameAttr = convertClass(@"Secret%d_DocumentAttribute_documentAttributeFilename", layer);
        Class videoAttr = convertClass(@"Secret%d_DocumentAttribute_documentAttributeVideo", layer);
        Class audioAttr = convertClass(@"Secret%d_DocumentAttribute_documentAttributeAudio", layer);
        Class animatedAttr = convertClass(@"Secret%d_DocumentAttribute_documentAttributeAnimated", layer);
        
        
        
        if([obj isKindOfClass:imageSizeAttr]) {
            [attrs addObject:[TL_documentAttributeImageSize createWithW:[[obj valueForKey:@"w"] intValue] h:[[obj valueForKey:@"h"] intValue]]];
        } else if([obj isKindOfClass:stickerAttr]) {
            [attrs addObject:[TL_documentAttributeSticker createWithAlt:@"" stickerset:[TL_inputStickerSetEmpty create]]];
        } else if([obj isKindOfClass:filenameAttr]) {
            [attrs addObject:[TL_documentAttributeFilename createWithFile_name:[obj valueForKey:@"file_name"]]];
        } else if([obj isKindOfClass:videoAttr]) {
            [attrs addObject:[TL_documentAttributeVideo createWithDuration:[[obj valueForKey:@"duration"] intValue] w:[[obj valueForKey:@"w"] intValue] h:[[obj valueForKey:@"h"] intValue]]];
        } else if([obj isKindOfClass:audioAttr]) {
            [attrs addObject:[TL_documentAttributeAudio_old31 createWithDuration:[[obj valueForKey:@"duration"] intValue]]];
        } else if([obj isKindOfClass:animatedAttr]) {
            [attrs addObject:[TL_documentAttributeAnimated create]];
        }
        
    }];
    
    return attrs;
}

-(TLMessageMedia *)media:(id)media layer:(int)layer file:(TLEncryptedFile *)file {
    
    
    if([media isKindOfClass:convertClass(@"Secret%d_DecryptedMessageMedia_decryptedMessageMediaEmpty", layer)])
        return [TL_messageMediaEmpty create];
    
    
    if([media isKindOfClass:convertClass(@"Secret%d_DecryptedMessageMedia_decryptedMessageMediaGeoPoint", layer)]) {
        return [TL_messageMediaGeo createWithGeo:[TL_geoPoint createWithN_long:[[media valueForKey:@"plong"] doubleValue] lat:[[media valueForKey:@"lat"] doubleValue]]];
    }
    
    if([media isKindOfClass:convertClass(@"Secret%d_DecryptedMessageMedia_decryptedMessageMediaContact", layer)]) {
        
        return [TL_messageMediaContact createWithPhone_number:[media valueForKey:@"phone_number"] first_name:[media valueForKey:@"first_name"] last_name:[media valueForKey:@"last_name"] user_id:[[media valueForKey:@"user_id"] intValue]];
    }
    
    
    if([media isKindOfClass:convertClass(@"Secret%d_DecryptedMessageMedia_decryptedMessageMediaExternalDocument", layer)]) {
        
        
        TLPhotoSize *pthumb = [TL_photoSizeEmpty createWithType:@"x"];
        
        
        if( [[media valueForKey:@"thumb"] isKindOfClass:convertClass(@"Secret%d_PhotoSize_photoCachedSize", layer)]) {
            
            id thumb = [media valueForKey:@"thumb"];
            
            id location = [thumb valueForKey:@"location"];
            
            pthumb = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:[[location valueForKey:@"dc_id"] intValue] volume_id:[[location valueForKey:@"volume_id"] longValue] local_id:[[location valueForKey:@"local_id"] intValue] secret:[[location valueForKey:@"secret"] longValue]] w:[[thumb valueForKey:@"w"] intValue] h:[[thumb valueForKey:@"h"] intValue] bytes:[thumb valueForKey:@"bytes"]];
        }
        
        NSMutableArray *attrs = [self convertDocumentAttributes:[media valueForKey:@"attributes"] layer:layer];
        
        return [TL_messageMediaDocument createWithDocument:[TL_document createWithN_id:[[media valueForKey:@"pid"] longValue] access_hash:[[media valueForKey:@"access_hash"] longValue] date:[[media valueForKey:@"date"] intValue] mime_type:[media valueForKey:@"mime_type"] size:[[media valueForKey:@"size"] intValue] thumb:pthumb dc_id:[[media valueForKey:@"dc_id"] intValue] attributes:attrs]];
        
    }
    
    
    // ------------------ start save file key -----------------
    
    
    TL_fileLocation *location = [TL_fileLocation createWithDc_id:[file dc_id] volume_id:[file n_id] local_id:-1 secret:[file access_hash]];
    
    if(![media respondsToSelector:@selector(key)] || ![media respondsToSelector:@selector(iv)]) {
        MTLog(@"drop encrypted media class ====== %@ ======",NSStringFromClass([media class]));
        return [TL_messageMediaEmpty create];
    }
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:@{@"key": [media valueForKey:@"key"], @"iv":[media valueForKey:@"iv"]} forKey:[NSString stringWithFormat:@"%lu",file.n_id] inCollection:ENCRYPTED_IMAGE_COLLECTION];
    }];
    
    // ------------------ end save file key -----------------
    
    
    
    if([media isKindOfClass:convertClass(@"Secret%d_DecryptedMessageMedia_decryptedMessageMediaPhoto", layer)]) {
        
        TL_photoCachedSize *s0 = [TL_photoCachedSize createWithType:@"jpeg" location:location w:[[media valueForKey:@"thumb_w"] intValue] h:[[media valueForKey:@"thumb_h"] intValue] bytes:[media valueForKey:@"thumb"]];
        TL_photoSize *s1 = [TL_photoSize createWithType:@"jpeg" location:location w:[[media valueForKey:@"w"] intValue] h:[[media valueForKey:@"h"] intValue] size:[[media valueForKey:@"size"] intValue]];
        
        NSMutableArray *size =  [NSMutableArray arrayWithObjects:s0,s1,nil];
        
        return [TL_messageMediaPhoto createWithPhoto:[TL_photo createWithN_id:[file n_id] access_hash:[file access_hash] date:[[MTNetwork instance] getTime] sizes:size] caption:@""];
        
    } else if([media isKindOfClass:convertClass(@"Secret%d_DecryptedMessageMedia_decryptedMessageMediaDocument", layer)]) {
        
        TLPhotoSize *size = [TL_photoSizeEmpty createWithType:@"jpeg"];
        
         if( ((NSData *)[media valueForKey:@"thumb"]).length > 0) {
            size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:0 local_id:0 secret:0] w:[[media valueForKey:@"thumb_w"] intValue] h:[[media valueForKey:@"thumb_h"] intValue] bytes:[media valueForKey:@"thumb"]];
         }
            
        return [TL_messageMediaDocument createWithDocument:[TL_document createWithN_id:file.n_id access_hash:file.access_hash date:[[MTNetwork instance] getTime] mime_type:[media valueForKey:@"mime_type"] size:file.size thumb:size dc_id:[file dc_id] attributes:[@[[TL_documentAttributeFilename createWithFile_name:[media valueForKey:@"file_name"]]] mutableCopy]]];
       
           
    } else if([media isKindOfClass:convertClass(@"Secret%d_DecryptedMessageMedia_decryptedMessageMediaVideo", layer)]) {
        
        NSString *mime_type = [media respondsToSelector:@selector(mime_type)] ? [media valueForKey:@"mime_type"] : @"mp4";
        
        return [TL_messageMediaVideo createWithVideo:[TL_video createWithN_id:file.n_id access_hash:file.access_hash date:[[MTNetwork instance] getTime] duration:[[media valueForKey:@"duration"] intValue] mime_type:mime_type size:file.size thumb:[TL_photoCachedSize createWithType:@"jpeg" location:location w:[[media valueForKey:@"thumb_w"] intValue] h:[[media valueForKey:@"thumb_h"] intValue] bytes:[media valueForKey:@"thumb"]] dc_id:[file dc_id] w:[[media valueForKey:@"w"] intValue] h:[[media valueForKey:@"h"] intValue]] caption:@""];
        
    } else if([media isKindOfClass:convertClass(@"Secret%d_DecryptedMessageMedia_decryptedMessageMediaAudio", layer)]) {
        
        NSString *mime_type = [media respondsToSelector:@selector(mime_type)] ? [media valueForKey:@"mime_type"] : @"ogg";
        
        return [TL_messageMediaAudio createWithAudio:[TL_audio createWithN_id:file.n_id access_hash:file.access_hash date:[[MTNetwork instance] getTime] duration:[[media valueForKey:@"duration"] intValue] mime_type:mime_type size:file.size dc_id:file.dc_id]];
        
    } else {
        alert(@"Unknown secret media", @"");
    }
    
    return [TL_messageMediaEmpty create];
}


@end
