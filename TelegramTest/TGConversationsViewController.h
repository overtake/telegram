//
//  TGConversationsViewController.h
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "StandartViewController.h"
#import "TGConversationTableItem.h"
@interface TGConversationsViewController : StandartViewController
@property (nonatomic, strong,readonly) TGConversationTableItem *selectedItem;

+ (void)showPopupMenuForDialog:(TL_conversation *)dialog withEvent:(NSEvent *)theEvent forView:(NSView *)view;
-(void)initialize;

@end
