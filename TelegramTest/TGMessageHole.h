//
//  TGMessageHole.h
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGMessageHole : NSObject

@property (nonatomic,assign,readonly) int uniqueId;
@property (nonatomic,assign,readonly) int peer_id;
@property (nonatomic,assign) int min_id;
@property (nonatomic,assign) int max_id;
@property (nonatomic,assign) int date;
@property (nonatomic,assign) int messagesCount;


@property (nonatomic,assign) BOOL isImploded;

-(id)initWithUniqueId:(int)uniqueId peer_id:(int)peer_id min_id:(int)min_id max_id:(int)max_id date:(int)date count:(int)count isImploded:(BOOL)isImploded;
-(id)initWithUniqueId:(int)uniqueId peer_id:(int)peer_id min_id:(int)min_id max_id:(int)max_id date:(int)date count:(int)count;
-(void)save;
-(void)remove;
-(int)type;

@end
