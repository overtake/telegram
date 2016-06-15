//
//  TGInputMessageTemplate.m
//  Telegram
//
//  Created by keepcoder on 18/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGInputMessageTemplate.h"
#import "SpacemanBlocks.h"
#import "NSString+FindURLs.h"

@implementation TGInputMessageTemplate
{
    SMDelayedBlockHandle _futureblock;
}

static NSString *kYapTemplateCollection = @"kYapTemplateCollection";

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _text = [aDecoder decodeObjectForKey:@"text"];
        _originalText = [aDecoder decodeObjectForKey:@"originalText"];
        _postId = [aDecoder decodeInt32ForKey:@"postId"];
        _type = [aDecoder  decodeInt32ForKey:@"type"];
        _peer_id = [aDecoder decodeInt32ForKey:@"peerId"];
        _autoSave = [aDecoder decodeBoolForKey:@"autoSave"];
        _editMessage = [aDecoder decodeObjectForKey:@"editMessage"];
        _replyMessage = [aDecoder decodeObjectForKey:@"replyMessage"];
        _disabledWebpage = [aDecoder decodeObjectForKey:@"disabledWebpage"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:@"text"];
    [aCoder encodeObject:_originalText forKey:@"originalText"];
    [aCoder encodeInt32:_type forKey:@"type"];
    [aCoder encodeInt32:_postId forKey:@"postId"];
    [aCoder encodeInt32:_peer_id forKey:@"peerId"];
    [aCoder encodeBool:_autoSave forKey:@"autoSave"];
    if(_editMessage)
        [aCoder encodeObject:_editMessage forKey:@"editMessage"];
    if(_replyMessage)
        [aCoder encodeObject:_replyMessage forKey:@"replyMessage"];
    if(_disabledWebpage)
        [aCoder encodeObject:_disabledWebpage forKey:@"disabledWebpage"];
    
}

-(void)setDisabledWebpage:(NSString *)disabledWebpage {
    _disabledWebpage = disabledWebpage;
    
}

-(void)setText:(NSString *)text {
    _text = text;
    if(_text.length == 0)
        _disabledWebpage = nil;
}

-(id)initWithType:(TGInputMessageTemplateType)type text:(NSString *)text peer_id:(int)peer_id {
    if(self = [super init]) {
        _text = text;
        _type = type;
        _peer_id = peer_id;
        _autoSave = YES;
        _originalText = text;
        
       
    }
    
    return self;
}

-(id)initWithType:(TGInputMessageTemplateType)type text:(NSString *)text peer_id:(int)peer_id postId:(int)postId {
    if(self = [self initWithType:type text:text peer_id:peer_id]) {
        _postId = postId;
    }
    
    return self;
}

-(void)setEditMessage:(TL_localMessage *)editMessage {
    _editMessage = editMessage;
    
    [self fillEntities:_editMessage.entities];
}

-(void)fillEntities:(NSArray *)entities {
    __block int rightOffset = 0;
    __block int startOffset = (int)_text.length;
    
    [entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRange range = NSMakeRange(obj.offset > startOffset ? obj.offset + rightOffset : obj.offset, obj.length);
        
        if([obj isKindOfClass:[TL_messageEntityMentionName class]]) {
            
            NSString *value = [_text substringWithRange:range];
            NSString *userId = [NSString stringWithFormat:@"%d",obj.user_id];
            
            _text = [_text stringByReplacingOccurrencesOfString:value withString:[NSString stringWithFormat:@"@[%@|%@]",value,userId] options:0 range:range];
            
            rightOffset+=4+userId.length;
            startOffset = MIN(startOffset,obj.offset);
            
        } else if([obj isKindOfClass:[TL_messageEntityPre class]]) {
            NSString *value = [_text substringWithRange:range];
            _text = [_text stringByReplacingOccurrencesOfString:value withString:[NSString stringWithFormat:@"```%@```",value] options:0 range:range];
            rightOffset+=6;
            startOffset = MIN(startOffset,obj.offset);
        } else if([obj isKindOfClass:[TL_messageEntityCode class]]) {
            NSString *value = [_text substringWithRange:range];
            _text = [_text stringByReplacingOccurrencesOfString:value withString:[NSString stringWithFormat:@"`%@`",value] options:0 range:range];
            rightOffset+=2;
            startOffset = MIN(startOffset,obj.offset);
        }
    }];
}

-(NSString *)textWithEntities:(NSMutableArray *)entities {
    
    NSString *message = [self.text copy];
    
    message = [MessageSender parseCustomMentions:message entities:entities];
    
    message = [MessageSender parseEntities:message entities:entities backstrips:@"```" startIndex:0];
    
    message = [MessageSender parseEntities:message entities:entities backstrips:@"`" startIndex:0];
    
    return message;
}

-(void)saveTemplateInCloudIfNeeded {
    NSMutableArray *entities = [NSMutableArray array];
    
    NSString *text = [self textWithEntities:entities];
    
    int flags = 0;
    
    if(_replyMessage)
        flags|= (1 << 0);
    if(entities.count > 0)
        flags|= (1 << 3);
    if(self.noWebpage)
        flags|= (1 << 1);
    
    // need support no webpage
    
    
    TL_conversation *convesation = [[DialogsManager sharedManager] find:_peer_id];
    
    TLDraftMessage *draftMessage = text.length == 0 && flags == 0 ? [TL_draftMessageEmpty create] : [TL_draftMessage createWithFlags:0 reply_to_msg_id:_replyMessage.n_id message:text entities:entities date:[[MTNetwork instance] getTime]];
    
    if((![convesation.draft isKindOfClass:draftMessage.class] && !([draftMessage isKindOfClass:[TL_draftMessageEmpty class]] && convesation.draft == nil)) || ((draftMessage.message && ![draftMessage.message isEqualToString:convesation.draft.message]) || draftMessage.flags != draftMessage.flags)) {
        
        
        convesation.draft = draftMessage;
        
        if([convesation.draft isKindOfClass:[TL_draftMessageEmpty class]])
            convesation.last_message_date = convesation.lastMessage ? convesation.lastMessage.date : convesation.last_message_date;
        else
            convesation.last_message_date = MAX(draftMessage.date,convesation.last_message_date);
        
       
        [RPCRequest sendRequest:[TLAPI_messages_saveDraft createWithFlags:flags reply_to_msg_id:_replyMessage.n_id peer:convesation.inputPeer message:text entities:entities] successHandler:^(id request, id response) {
            
            
            
            [convesation save];
            
            dispatch_block_t block = ^{
                [[DialogsManager sharedManager] notifyAfterUpdateConversation:convesation];
            };
            
            if([convesation.draft isKindOfClass:[TL_draftMessageEmpty class]] || convesation.draft == nil)
                block();
            else
                dispatch_after_seconds(1.5,block);

            
        } errorHandler:^(id request, RpcError *error) {
            
            
        }];
        
    }
    
    
    
   

}

-(void)performNotification {
    _applyNextNotification = YES;
    [Notification perform:UPDATE_MESSAGE_TEMPLATE data:@{KEY_TEMPLATE:self,KEY_PEER_ID:@(_peer_id)}];
}

-(void)updateTemplateWithDraft:(TLDraftMessage *)draft {
    
    __block TL_conversation *conversation = [[DialogsManager sharedManager] find:_peer_id];
    
    NSArray *unloaded = @[];
    
    if(!conversation)
        unloaded = @[@(conversation.peer_id)];
    
    [[Storage manager] conversationsWithPeerIds:unloaded completeHandler:^(NSArray *result) {
        
        [[DialogsManager sharedManager] add:result];
        if(!conversation) {
             conversation = [[DialogsManager sharedManager] find:_peer_id];
        }
        
        if(conversation) {
            
            conversation.draft = draft;
            
            conversation.last_message_date = MAX(draft.date,conversation.last_message_date);
            
            [conversation save];
            [[DialogsManager sharedManager] notifyAfterUpdateConversation:conversation];
            
            [self fillDraft:draft conversation:conversation save:YES];
            

        }
        
       
    }];
    
}

-(void)fillDraft:(TLDraftMessage *)draft conversation:(TL_conversation *)conversation save:(BOOL)save {
    
    
    dispatch_block_t pblock = ^{
        if(save) {
            [self saveForce];
            [self performNotification];
        }
    };
    
    _text = draft.message;
    [self fillEntities:draft.entities];
    
    if(draft.isNo_webpage) {
        _disabledWebpage = [_text webpageLink];
    }
    
    
    
    if(draft.reply_to_msg_id != 0) {
        
        if(draft.reply_to_msg_id != _replyMessage.n_id) {
            [[Storage manager] messages:^(NSArray *messages) {
                
                if(messages.count == 1) {
                    _replyMessage = messages[0];
                    
                    pblock();
                } else {
                    
                    id request = [TLAPI_messages_getMessages createWithN_id:[@[@(draft.reply_to_msg_id)] mutableCopy]];
                    
                    if(conversation.isChannel) {
                        request = [TLAPI_channels_getMessages createWithChannel:[TL_inputChannel createWithChannel_id:conversation.chat.n_id access_hash:conversation.chat.access_hash] n_id:[@[@(draft.reply_to_msg_id)] mutableCopy]];
                    }
                    
                    [RPCRequest sendRequest:request successHandler:^(id request, TL_messages_messages *response) {
                        
                        
                        if(response.messages.count == 1 ) {
                            
                            NSMutableArray *messages = [response.messages mutableCopy];
                            [[response messages] removeAllObjects];
                            
                            
                            [TL_localMessage convertReceivedMessages:messages];
                            
                            if([messages[0] isKindOfClass:[TL_messageEmpty class]]) {
                                messages[0] = [TL_localEmptyMessage createWithN_Id:[(TL_messageEmpty *)messages[0] n_id] to_id:conversation.peer];
                            }
                            
                            [SharedManager proccessGlobalResponse:response];
                            
                            [[Storage manager] addSupportMessages:messages];
                            
                            
                            _replyMessage = messages[0];
                            
                            pblock();
                        }
                        
                        
                    } errorHandler:^(id request, RpcError *error) {
                        
                        
                    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
                }
                
            } forIds:@[@(draft.reply_to_msg_id)] random:NO sync:NO  queue:[ASQueue globalQueue] isChannel:conversation.isChannel];
        }
        
    } else {
        _replyMessage = nil;
        pblock();
        
    }
}

-(void)updateTextAndSave:(NSString *)newText {
    
    BOOL save = ![_text isEqualToString:newText];
    

    _text = [newText trim];
    
    if(_autoSave && save) {
        cancel_delayed_block(_futureblock);
        
        _futureblock = perform_block_after_delay(0.5, ^{
            [self saveForce];
        });
    }
    
}

-(BOOL)noWebpage {
    return [_disabledWebpage isEqualToString:[self.text webpageLink]];
}

-(void)setReplyMessage:(TL_localMessage *)replyMessage save:(BOOL)save {
    _replyMessage = replyMessage;
    if(save) {
        [self saveForce];
    }
}

-(void)saveForce {
    
     cancel_delayed_block(_futureblock);
    
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        
        [transaction setObject:self forKey:self.key inCollection:kYapTemplateCollection];
        
    }];
}

+(TGInputMessageTemplate *)templateWithType:(TGInputMessageTemplateType)type ofPeerId:(int)peer_id {
    __block TGInputMessageTemplate *template;
    
    __block BOOL n = NO;
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        
        template = [transaction objectForKey:[NSString stringWithFormat:@"%d_%d",peer_id,type] inCollection:kYapTemplateCollection];
        
        
        if(!template) {
            template = [[TGInputMessageTemplate alloc] initWithType:TGInputMessageTemplateTypeSimpleText text:@"" peer_id:peer_id];
            n = YES;
            
            [transaction setObject:template forKey:template.key inCollection:kYapTemplateCollection];
        }
        
    }];
    
    
    if(n) {
        
        TL_conversation *conversation = [[DialogsManager sharedManager] find:peer_id];
        
        if([conversation.draft isKindOfClass:[TL_draftMessage class]] && ![conversation.draft.message isEqualToString:template.text]) {
            [template fillDraft:conversation.draft conversation:conversation save:NO];
        }
    }
    
    
    return template;
}



-(NSString *)key {
    return [NSString stringWithFormat:@"%d_%d",_peer_id,_type];
}

-(id)copy {
    
    TGInputMessageTemplate *template = [[[self class] alloc] initWithType:self.type text:self.text peer_id:self.peer_id postId:self.postId];;
    [template setReplyMessage:_replyMessage save:NO];
    [template setEditMessage:_editMessage];
    [template setDisabledWebpage:_disabledWebpage];
    return template;
}


@end
