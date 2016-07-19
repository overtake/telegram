//
//  TGBottomAudioRecordView.h
//  Telegram
//
//  Created by keepcoder on 19/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "BTRControl.h"

@interface TGBottomAudioRecordView : BTRControl
-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController;

-(void)startRecord;
-(void)stopRecord:(BOOL)send;

-(void)updateDesc:(BOOL)inView;

@end
