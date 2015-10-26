//
//  MessageTableCell.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableItem.h"
#import "TMElements.h"
#import "MessagesViewController.h"

@interface MessageTableCell : NSView

@property (nonatomic, weak) MessageTableItem *item;
@property (nonatomic, weak) MessagesViewController *messagesViewController;

- (void)setHover:(BOOL)isHover redraw:(BOOL)redraw;
- (void)setItem:(MessageTableItem *)item;
- (void)resizeAndRedraw;

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color;

-(void)clearSelection;
-(BOOL)mouseInText:(NSEvent *)theEvent;

@end
