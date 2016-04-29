//
//  TGInputMessageTemplate.m
//  Telegram
//
//  Created by keepcoder on 18/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGInputMessageTemplate.h"
#import "SpacemanBlocks.h"


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
    
    __block int rightOffset = 0;
    __block int startOffset = (int)_text.length;
    
    [_editMessage.entities enumerateObjectsUsingBlock:^(TLMessageEntity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRange range = NSMakeRange(obj.offset > startOffset ? obj.offset + rightOffset : obj.offset, obj.length);
        
        if([obj isKindOfClass:[TL_messageEntityMentionName class]]) {
            
            NSString *value = [_text substringWithRange:range];
            NSString *userId = [NSString stringWithFormat:@"%d",obj.user_id];
            
            _text = [_text stringByReplacingOccurrencesOfString:value withString:[NSString stringWithFormat:@"@[%@|%@]",value,userId] options:0 range:range];
            
            rightOffset+=4+userId.length;
            startOffset = MIN(startOffset,obj.offset);
            
        } else if([obj isKindOfClass:[TL_messageEntityCode class]]) {
            NSString *value = [_text substringWithRange:range];
            _text = [_text stringByReplacingOccurrencesOfString:value withString:[NSString stringWithFormat:@"```%@```",value] options:0 range:range];
            rightOffset+=6;
            startOffset = MIN(startOffset,obj.offset);
        } else if([obj isKindOfClass:[TL_messageEntityPre class]]) {
            NSString *value = [_text substringWithRange:range];
            _text = [_text stringByReplacingOccurrencesOfString:value withString:[NSString stringWithFormat:@"`%@`",value] options:0 range:range];
            rightOffset+=2;
            startOffset = MIN(startOffset,obj.offset);
        }
    }];
}


-(void)updateTextAndSave:(NSString *)newText {
    _text = newText;
    
    if(_autoSave) {
        cancel_delayed_block(_futureblock);
        
        _futureblock = perform_block_after_delay(0.5, ^{
            [self saveForce];
        });
    }
    
}

-(void)saveForce {
    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        
        [transaction setObject:self forKey:self.key inCollection:kYapTemplateCollection];
        
    }];
}

+(TGInputMessageTemplate *)templateWithType:(TGInputMessageTemplateType)type ofPeerId:(int)peer_id {
    __block TGInputMessageTemplate *template;
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        
        template = [transaction objectForKey:[NSString stringWithFormat:@"%d_%d",peer_id,type] inCollection:kYapTemplateCollection];
        
    }];
    
    return template;
}

-(NSString *)key {
    return [NSString stringWithFormat:@"%d_%d",_peer_id,_type];
}


@end
