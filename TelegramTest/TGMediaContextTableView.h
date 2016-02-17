//
//  TGMediaContextTableView.h
//  Telegram
//
//  Created by keepcoder on 25/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TMTableView.h"

@interface TGMediaContextTableView : TMTableView


@property (nonatomic,weak) MessagesViewController *messagesViewController;

@property (nonatomic,copy) void (^choiceHandler)(TLBotInlineResult *document);
@property (nonatomic,copy) void (^needLoadNext)(BOOL next);

-(void)drawResponse:(NSArray *)items;
-(void)clear;

@property (nonatomic,assign) BOOL needCheckKeyWindow;

@end
