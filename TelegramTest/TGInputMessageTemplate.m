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
        _postId = [aDecoder decodeInt32ForKey:@"postId"];
        _type = [aDecoder  decodeInt32ForKey:@"type"];
        _peer_id = [aDecoder decodeInt32ForKey:@"peerId"];
        _autoSave = [aDecoder decodeBoolForKey:@"autoSave"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:@"text"];
    [aCoder encodeInt32:_type forKey:@"type"];
    [aCoder encodeInt32:_postId forKey:@"postId"];
    [aCoder encodeInt32:_peer_id forKey:@"peerId"];
    [aCoder encodeBool:_autoSave forKey:@"autoSave"];
    
}

-(id)initWithType:(TGInputMessageTemplateType)type text:(NSString *)text peer_id:(int)peer_id {
    if(self = [super init]) {
        _text = text;
        _type = type;
        _peer_id = peer_id;
        _autoSave = YES;
    }
    
    return self;
}

-(id)initWithType:(TGInputMessageTemplateType)type text:(NSString *)text peer_id:(int)peer_id postId:(int)postId {
    if(self = [self initWithType:type text:text peer_id:peer_id]) {
        _postId = postId;
    }
    
    return self;
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
