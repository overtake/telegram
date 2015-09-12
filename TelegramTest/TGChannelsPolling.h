//
//  TGChannelsPolling.h
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TGChannelPollingDelegate <NSObject>

-(void)pollingDidSaidTooLongWithHole:(TGMessageHole *)hole;

-(void)pollingReceivedUpdates:(id)updates endPts:(int)pts;

@end

@interface TGChannelsPolling : NSObject

@property (nonatomic,weak) id <TGChannelPollingDelegate> delegate;

@property (nonatomic,assign,readonly) BOOL isActive;

-(id)initWithDelegate:(id <TGChannelPollingDelegate>)delegate withUpdatesLimit:(int)limit;

-(void)setCurrentConversation:(TL_conversation *)conversation;

-(void)start;
-(void)stop;

-(void)checkInvalidatedMessages:(NSArray *)result important:(BOOL)important;

@end
