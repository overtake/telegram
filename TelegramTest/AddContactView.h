//
//  AddContactView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 22.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface AddContactView : TMView<NSTextFieldDelegate>
@property (nonatomic,strong) NewConversationViewController *controller;
@end
