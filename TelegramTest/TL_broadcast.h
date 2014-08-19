//
//  TL_broadcast.h
//  Telegram
//
//  Created by keepcoder on 06.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLRPC.h"
@class TL_conversation;
@interface TL_broadcast : TGObject

@property (nonatomic,assign) int n_id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSMutableArray *participants;

+(TL_broadcast *)createWithN_id:(int)n_id participants:(NSArray *)participants title:(NSString *)title;

-(void)addParticipants:(NSArray *)ids;
-(void)removeParticipant:(int)n_id;

- (NSMutableArray *)inputContacts;

-(TL_conversation *)conversation;

- (NSAttributedString *)dialogTitle;
- (NSAttributedString *)titleForMessage;
- (NSAttributedString *)titleForChatInfo;

- (NSAttributedString *)statusForMessagesHeaderView;

@end
