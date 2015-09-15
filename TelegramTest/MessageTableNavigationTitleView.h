//
//  MessageTableNavigationTitleView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface MessageTableNavigationTitleView : TMView<TMStatusTextFieldProtocol, TMNameTextFieldProtocol>

@property (nonatomic, strong) TL_conversation *dialog;
@property (nonatomic, strong) dispatch_block_t tapBlock;

-(void)enableDiscussion;

@end
