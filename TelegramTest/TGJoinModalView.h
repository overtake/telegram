//
//  TGJoinModalView.h
//  Telegram
//
//  Created by keepcoder on 08/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModalView.h"

@interface TGJoinModalView : TGModalView

-(void)showWithChatInvite:(TLChatInvite *)chatInvite hash:(NSString *)hash;

@end
