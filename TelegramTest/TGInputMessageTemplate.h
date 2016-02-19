//
//  TGInputMessageTemplate.h
//  Telegram
//
//  Created by keepcoder on 18/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGInputMessageTemplate : NSObject <NSCoding>


typedef enum {
    TGInputMessageTemplateTypeSimpleText,
    TGInputMessageTemplateTypeEditMessage
} TGInputMessageTemplateType;


@property (nonatomic,assign,readonly) TGInputMessageTemplateType type;
@property (nonatomic,strong,readonly) NSString *text;
@property (nonatomic,assign,readonly) int postId;
@property (nonatomic,assign,readonly) int peer_id;

@property (nonatomic,assign) BOOL autoSave;

-(void)updateTextAndSave:(NSString *)newText;

-(void)saveForce;

-(id)initWithType:(TGInputMessageTemplateType)type text:(NSString *)text peer_id:(int)peer_id;
-(id)initWithType:(TGInputMessageTemplateType)type text:(NSString *)text peer_id:(int)peer_id postId:(int)postId;


+(TGInputMessageTemplate *)templateWithType:(TGInputMessageTemplateType)type ofPeerId:(int)peer_id;

@end
