//
//  TGBottomMessageActionsView.h
//  Telegram
//
//  Created by keepcoder on 19/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGBottomMessageActionsView : BTRControl
-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController;
- (void)setSectedMessagesCount:(NSUInteger)count deleteEnable:(BOOL)deleteEnable forwardEnable:(BOOL)forwardEnable;
@end
