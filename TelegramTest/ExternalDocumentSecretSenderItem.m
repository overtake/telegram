//
//  ExternalDocumentSecretSenderItem.m
//  Telegram
//
//  Created by keepcoder on 09.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ExternalDocumentSecretSenderItem.h"

@implementation ExternalDocumentSecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation document:(TLDocument *)document {
    
    if(self = [super initWithConversation:conversation]) {
        
        int ttl = self.params.ttl;
        
        self.message = [TL_destructMessage createWithN_id:[MessageSender getFutureMessageId] flags:TGOUTUNREADMESSAGE from_id:UsersManager.currentUserId to_id:conversation.peer date:[[MTNetwork instance] getTime] message:@"" media:[TL_messageMediaDocument createWithDocument:document] destruction_time:0 randomId:rand_long() fakeId:[MessageSender getFakeMessageId] ttl_seconds:ttl == -1 ? 0 : ttl out_seq_no:-1 dstate:DeliveryStatePending];
        
        [self.message save:YES];
    }
    
    return self;
    
}



-(NSArray *)convertLAttributes:(NSArray *)attributes layer:(int)layer {
    
    NSMutableArray *attrs = [[NSMutableArray alloc] init];
    
    
    [attributes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        Class baseClass = NSClassFromString([NSString stringWithFormat:@"Secret%d_DocumentAttribute", layer]);

        if([obj isKindOfClass:[TL_documentAttributeImageSize class]]) {
            
            [attrs addObject:[baseClass documentAttributeImageSizeWithW:[obj valueForKey:@"w"] h:[obj valueForKey:@"h"]]];
        
        } else if([obj isKindOfClass:[TL_documentAttributeSticker class]]) {
            
            [attrs addObject:[baseClass documentAttributeSticker]];
            
        } else if([obj isKindOfClass:[TL_documentAttributeFilename class]]) {
            
            [attrs addObject:[baseClass documentAttributeFilenameWithFile_name:[obj valueForKey:@"file_name"]]];
            
        } else if([obj isKindOfClass:[TL_documentAttributeVideo class]]) {
            
            [attrs addObject:[baseClass documentAttributeVideoWithDuration:[obj valueForKey:@"duration"] w:[obj valueForKey:@"w"] h:[obj valueForKey:@"h"]]];
            
        } else if([obj isKindOfClass:[TL_documentAttributeAudio class]]) {
            
            [attrs addObject:[baseClass documentAttributeAudioWithDuration:[obj valueForKey:@"duration"]]];
            
        } else if([obj isKindOfClass:[TL_documentAttributeAnimated class]]) {
            
            [attrs addObject:[baseClass documentAttributeAnimated]];
        }
        
    }];
    
    return attrs;
    
}


-(NSData *)decryptedMessageLayer23 {
    
    
    Secret23_PhotoSize *photoSize = [Secret23_PhotoSize photoSizeEmptyWithType:self.message.media.document.thumb.type];
    
    
    if(![self.message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
        
        Secret23_FileLocation *location = [Secret23_FileLocation fileLocationWithDc_id:@(self.message.media.document.thumb.location.dc_id) volume_id:@(self.message.media.document.thumb.location.volume_id) local_id:@(self.message.media.document.thumb.location.local_id) secret:@(self.message.media.document.thumb.location.secret)];
        
        if([self.message.media.document.thumb isKindOfClass:[TL_photoCachedSize class]]) {
            photoSize = [Secret23_PhotoSize photoCachedSizeWithType:self.message.media.document.thumb.type location:location w:@(self.message.media.document.thumb.w) h:@(self.message.media.document.thumb.h) bytes:self.message.media.document.thumb.bytes];
        } else if([self.message.media.document.thumb isKindOfClass:[TL_photoSize class]]) {
            photoSize = [Secret23_PhotoSize photoSizeWithType:self.message.media.document.thumb.type location:location w:@(self.message.media.document.thumb.w) h:@(self.message.media.document.thumb.h) size:@(self.message.media.document.thumb.size)];
        }
    }
    
    return [Secret23__Environment serializeObject:[Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(23) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret23_DecryptedMessage decryptedMessageWithRandom_id:@(self.message.randomId) ttl:@(((TL_destructMessage *)self.message).ttl_seconds) message:self.message.message media:[Secret23_DecryptedMessageMedia decryptedMessageMediaExternalDocumentWithPid:@(self.message.media.document.n_id) access_hash:@(self.message.media.document.access_hash) date:@(self.message.media.document.date) mime_type:self.message.media.document.mime_type size:@(self.message.media.document.size) thumb:photoSize dc_id:@(self.message.media.document.dc_id) attributes:[self convertLAttributes:self.message.media.document.attributes layer:23]]]]];
}


-(void)performRequest {
    
    TLAPI_messages_sendEncrypted *request = [TLAPI_messages_sendEncrypted createWithPeer:[TL_inputEncryptedChat createWithChat_id:self.action.chat_id access_hash:self.params.access_hash] random_id:self.random_id data:[MessageSender getEncrypted:self.params messageData:[self decryptedMessageLayer]]];
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentEncryptedMessage *response) {
        
        ((TL_destructMessage *)self.message).date = [response date];
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        self.state = MessageSendingStateSent;
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    }];
    
    
}

@end
