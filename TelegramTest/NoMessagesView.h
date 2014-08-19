//
//  NoMessagesView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 15.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface NoMessagesView : TMView

-(void)setConversation:(TL_conversation *)conversation;
- (void)setLoading:(BOOL)isLoading;

@end
