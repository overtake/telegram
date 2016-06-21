//
//  TGSingleMediaSenderModalView.h
//  Telegram
//
//  Created by keepcoder on 20/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModalView.h"

@interface TGSingleMediaSenderModalView : TGModalView


-(void)show:(NSWindow *)window animated:(BOOL)animated file:(NSString *)filepath ptype:(PasteBoardItemType)ptype conversation:(TL_conversation *)conversation messagesViewController:(MessagesViewController *)messagesViewController;

@end
