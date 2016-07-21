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
#import "TGInputTextTag.h"

@implementation TGInputMessageTemplate
{
    SMDelayedBlockHandle _futureblock;
    NSMutableAttributedString *_textContainer;
}

static NSString *kYapTemplateCollection = @"kYapTemplateCollection";
static ASQueue *queue;
static NSMutableDictionary *list;
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _postId = [aDecoder decodeInt32ForKey:@"postId"];
        _type = [aDecoder  decodeInt32ForKey:@"type"];
        _peer_id = [aDecoder decodeInt32ForKey:@"peerId"];
        _editMessage = [aDecoder decodeObjectForKey:@"editMessage"];
        _replyMessage = [aDecoder decodeObjectForKey:@"replyMessage"];
        _disabledWebpage = [aDecoder decodeObjectForKey:@"disabledWebpage"];
        _textContainer = [aDecoder decodeObjectForKey:@"attributedString"];
        
        _autoSave = YES;
    }
    return self;
}

-(NSAttributedString *)attributedString {
    return _textContainer ? _textContainer : [[NSAttributedString alloc] init];
}

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[ASQueue alloc] initWithName:"inputSaveQueue"];
        list = [NSMutableDictionary dictionary];
    });
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.attributedString forKey:@"attributedString"];
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


-(void)setAttributedString:(NSAttributedString *)attributedString {
    _textContainer = [attributedString mutableCopy];
    if(_textContainer.length == 0)
        _disabledWebpage = nil;
}

-(id)initWithType:(TGInputMessageTemplateType)type text:(NSAttributedString *)attributedString peer_id:(int)peer_id {
    if(self = [super init]) {
        _textContainer = [attributedString mutableCopy];
        _type = type;
        _peer_id = peer_id;
        _autoSave = YES;
        
       
    }
    
    return self;
}

-(id)initWithType:(TGInputMessageTemplateType)type text:(NSAttributedString *)attributedString peer_id:(int)peer_id postId:(int)postId {
    if(self = [self initWithType:type text:attributedString peer_id:peer_id]) {
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
    __block int startOffset = (int)_textContainer.length;
    
    _textContainer = [[NSMutableAttributedString alloc] initWithString:_textContainer.string];
    
    __block int uniqueId = 0;
    
    [entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRange range = NSMakeRange(obj.offset > startOffset ? obj.offset + rightOffset : obj.offset, obj.length);
        
        if([obj isKindOfClass:[TL_messageEntityMentionName class]]) {
            
            [_textContainer addAttribute:TGMentionUidAttributeName value:[[TGInputTextTag alloc] initWithUniqueId:uniqueId left:true attachment:@(obj.user_id)] range:range];
            
        } else if([obj isKindOfClass:[TL_messageEntityPre class]]) {
            NSString *value = [_textContainer.string substringWithRange:range];
            [_textContainer replaceCharactersInRange:range withString:[NSString stringWithFormat:@"```%@```",value]];
            rightOffset+=6;
            startOffset = MIN(startOffset,obj.offset);
        } else if([obj isKindOfClass:[TL_messageEntityCode class]]) {
            NSString *value = [_textContainer.string substringWithRange:range];
            [_textContainer replaceCharactersInRange:range withString:[NSString stringWithFormat:@"`%@`",value]];
            rightOffset+=2;
            startOffset = MIN(startOffset,obj.offset);
        }
    }];
}

-(NSString *)textWithEntities:(NSMutableArray *)entities {
    
    NSString *message = [_textContainer.string copy];
    
    [_textContainer enumerateAttribute:TGMentionUidAttributeName inRange:NSMakeRange(0, _textContainer.length) options:0 usingBlock:^(__unused id value, NSRange range, __unused BOOL *stop) {
        if ([value isKindOfClass:[TGInputTextTag class]]) {
            TLUser *user = [[UsersManager sharedManager] find:[((TGInputTextTag *)value).attachment intValue]];
            if(user) {
                [entities addObject:[TL_inputMessageEntityMentionName createWithOffset:(int)range.location length:(int)range.length input_user_id:user.inputUser]];
            }
        }
    }];

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
    
    if(convesation.type == DialogTypeSecretChat || _type == TGInputMessageTemplateTypeEditMessage)
        return;
    
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
    [self performNotification:NO];
}

-(void)performNotification:(BOOL)swap {
    _applyNextNotification = YES;
    [Notification perform:UPDATE_MESSAGE_TEMPLATE data:@{KEY_TEMPLATE:self,KEY_PEER_ID:@(_peer_id),KEY_DATA:@(swap)}];
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
    
    _textContainer = [[NSMutableAttributedString alloc] initWithString:draft.message];
    [self fillEntities:draft.entities];
    
    if(draft.isNo_webpage) {
        _disabledWebpage = [_textContainer.string webpageLink];
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
                        
                        
                    } timeout:0 queue:[ASQueue globalQueue]._dispatch_queue];
                }
                
            } forIds:@[@(draft.reply_to_msg_id)] random:NO sync:NO  queue:[ASQueue globalQueue] isChannel:conversation.isChannel];
        }
        
    } else {
        _replyMessage = nil;
        pblock();
        
    }
}

-(void)updateTextAndSave:(NSAttributedString *)newText {
    
    BOOL save = ![_textContainer isEqualToAttributedString:newText];
    


    _textContainer = [newText mutableCopy];
    
    if(_autoSave && save) {
        cancel_delayed_block(_futureblock);
        
       // _futureblock = perform_block_after_delay(0.5, ^{
            [self saveForce];
       // });
    }
    
}


-(SSignal *)updateSignalText:(NSAttributedString *)newText {
    
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        BOOL save = ![_textContainer isEqualToAttributedString:newText];
        BOOL changedWebpage = self.webpage != newText.string.webpageLink && ![self.webpage isEqualToString:[newText.string webpageLink]];
        
        _textContainer = [newText mutableCopy];
        
        if(changedWebpage && _disabledWebpage) {
            _disabledWebpage = nil;
        }
        
        if(_autoSave && save) {
            [self saveForce];
        }
        
        [subscriber putNext:@[@(save),@(changedWebpage)]];
        [subscriber putCompletion];
        
        return nil;
        
    }];
    
    
}

-(BOOL)noWebpage {
    return [_disabledWebpage isEqualToString:[self.attributedString.string webpageLink]];
}

-(NSString *)webpage {
    return self.attributedString.string.webpageLink;
}

-(void)setReplyMessage:(TL_localMessage *)replyMessage save:(BOOL)save {
    _replyMessage = replyMessage;
    if(save) {
        [self saveForce];
    }
}


-(void)saveForce {
    
    
     NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
     [def setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:self.key];
    
     [def synchronize];
    
}

+(TGInputMessageTemplate *)templateWithType:(TGInputMessageTemplateType)type ofPeerId:(int)peer_id {
    __block TGInputMessageTemplate *template;
    
    __block BOOL n = NO;
    
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [NSString stringWithFormat:@"%d_%d",peer_id,type];
    
    
    
    template = list[key];
    
    if(!template)
    {
        template = [NSKeyedUnarchiver unarchiveObjectWithData:[def objectForKey:key]];
        
        if(template)
            list[key] = template;
    }
    
    if(!template) {
        template = [[TGInputMessageTemplate alloc] initWithType:TGInputMessageTemplateTypeSimpleText text:[[NSAttributedString alloc] init] peer_id:peer_id];
        n = YES;
        
        list[key] = template;
        
        [def setObject:[NSKeyedArchiver archivedDataWithRootObject:template] forKey:template.key];
        
        [def synchronize];
    }

    
    if(n) {
        
        TL_conversation *conversation = [[DialogsManager sharedManager] find:peer_id];
        
        if([conversation.draft isKindOfClass:[TL_draftMessage class]] && ![conversation.draft.message isEqualToString:template.attributedString.string]) {
            [template fillDraft:conversation.draft conversation:conversation save:NO];
        }
    }
    
    
    return template;
}



-(NSString *)key {
    return [NSString stringWithFormat:@"%d_%d",_peer_id,_type];
}

-(id)copy {
    
    TGInputMessageTemplate *template = [[[self class] alloc] initWithType:self.type text:self.attributedString peer_id:self.peer_id postId:self.postId];;
    [template setReplyMessage:_replyMessage save:NO];
    [template setEditMessage:_editMessage];
    [template setDisabledWebpage:_disabledWebpage];
    return template;
}


@end
