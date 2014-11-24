//
//  TGFullChatCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/28/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLChatFull (Category)

- (int)lastUpdateTime;
- (void)setLastUpdateTime:(int)lastUpdateTime;
-(TL_conversation *)conversation;
@end
