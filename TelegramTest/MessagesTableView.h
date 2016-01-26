//
//  MessagesTableView.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/30/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMElements.h"

@class MessagesViewController;

@interface MessagesTableView : TMTableView
@property (nonatomic, weak) MessagesViewController *viewController;

- (NSSize)containerSize;

- (void)clearSelection;
-(void)checkAndScroll:(NSPoint)point;

@end
