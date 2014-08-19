//
//  NewConversationRow.h
//  Telegram P-Edition
//
//  Created by keepcoder on 20.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"
#import "NewConversationViewController.h"
@interface NewConversationRowItem : TMRowItem

@property (nonatomic,strong) NSMutableAttributedString *title;
@property (nonatomic,assign) NSSize titleSize;
@property (nonatomic,assign) BOOL isChecked;
@property (nonatomic,strong) NSMutableAttributedString *lastSeen;
@property (nonatomic,assign) NSSize lastSeenSize;
@property (nonatomic,assign) NSPoint lastSeenPoint;
@property (nonatomic,assign) NSPoint titlePoint;
@property (nonatomic,assign) NSPoint avatarPoint;
@property (nonatomic,assign) NewConversationAction action;
@property (nonatomic,assign) BOOL animated;
@property (nonatomic,strong) TGFileLocation *location;
@property (nonatomic,strong) TGUser *user;
@property (nonatomic,strong) NewConversationViewController *controller;
-(BOOL)canSelect;

@end
