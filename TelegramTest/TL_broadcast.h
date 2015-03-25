//
//  TL_broadcast.h
//  Telegram
//
//  Created by keepcoder on 06.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"
@class TL_conversation;
@interface TL_broadcast : TLObject

@property (nonatomic,assign) int n_id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSMutableArray *participants;
@property (nonatomic,assign) int date;

+(TL_broadcast *)createWithN_id:(int)n_id participants:(NSArray *)participants title:(NSString *)title date:(int)date;

-(void)addParticipants:(NSArray *)ids;
-(void)removeParticipant:(int)n_id;

- (NSMutableArray *)inputContacts;
- (NSMutableArray *)generateRandomIds;

-(TL_conversation *)conversation;

- (NSAttributedString *)dialogTitle;
- (NSAttributedString *)titleForMessage;
- (NSAttributedString *)titleForChatInfo;

-(NSString *)partString;

- (NSAttributedString *)statusForMessagesHeaderView;

@end
