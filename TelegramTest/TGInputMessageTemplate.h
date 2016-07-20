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

@property (nonatomic,strong) TL_localMessage *editMessage;

@property (nonatomic,strong,readonly) TL_localMessage *replyMessage;

@property (nonatomic,strong,readonly) NSString *originalText;

@property (nonatomic,assign) BOOL autoSave;
@property (nonatomic,strong) NSString *disabledWebpage;

@property (nonatomic,assign) BOOL applyNextNotification;

@property (nonatomic,strong) NSArray *forwardMessages;

-(BOOL)noWebpage;

-(void)setReplyMessage:(TL_localMessage *)replyMessage save:(BOOL)save;
-(void)updateTextAndSave:(NSString *)newText;
-(SSignal *)updateSignalText:(NSString *)newText;
-(void)saveForce;
-(NSString *)textWithEntities:(NSMutableArray *)entities;
-(void)updateTemplateWithDraft:(TLDraftMessage *)draft;

-(id)initWithType:(TGInputMessageTemplateType)type text:(NSString *)text peer_id:(int)peer_id;
-(id)initWithType:(TGInputMessageTemplateType)type text:(NSString *)text peer_id:(int)peer_id postId:(int)postId;


-(void)saveTemplateInCloudIfNeeded;

+(TGInputMessageTemplate *)templateWithType:(TGInputMessageTemplateType)type ofPeerId:(int)peer_id;
-(void)performNotification;
-(void)performNotification:(BOOL)swap;
-(NSString *)webpage;

@end
