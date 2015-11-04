//
//  TGModernUserViewController.h
//  Telegram
//
//  Created by keepcoder on 28.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeViewController.h"

@interface TGModernUserViewController : ComposeViewController


-(void)setUser:(TLUser *)user conversation:(TL_conversation *)conversation;

@end
