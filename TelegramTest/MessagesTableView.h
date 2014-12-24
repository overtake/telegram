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
@property (nonatomic, strong) MessagesViewController *viewController;

- (NSSize)containerSize;

@property (nonatomic,assign) float fakeHeight;

- (void)clearSelection;
-(void)checkAndScroll:(NSPoint)point;

@end
