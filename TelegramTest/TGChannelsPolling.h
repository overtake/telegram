//
//  TGChannelsPolling.h
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TGChannelPollingDelegate <NSObject>

-(void)pollingDidSaidTooLong:(int)channel_id;
-(void)pollingReceivedUpdates:(id)updates endPts:(int)pts;

@end

@interface TGChannelsPolling : NSObject

@property (nonatomic,weak) id <TGChannelPollingDelegate> deleagte;

-(id)initWithDelegate:(id <TGChannelPollingDelegate>)delegate withUpdatesLimit:(int)limit;

-(void)setCurrentConversation:(TL_conversation *)conversation;

@end
