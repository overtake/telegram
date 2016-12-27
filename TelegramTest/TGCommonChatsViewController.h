//
//  TGCommonChatsViewController.h
//  Telegram
//
//  Created by keepcoder on 04/11/2016.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface TGCommonChatsViewController : TMViewController
-(void)updateWithChats:(NSArray *)chats users:(NSArray *)users;
@end
