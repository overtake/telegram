//
//  MessageTableCellTextView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellContainerView.h"
#import "MessageTableItemText.h"
#import "TGMultipleSelectTextView.h"
@interface MessageTableCellTextView : MessageTableCellContainerView


@property (nonatomic, strong,readonly) TGMultipleSelectTextView *textView;

-(void)selectSearchTextInRange:(NSRange)range;


-(void)_mouseDragged:(NSEvent *)theEvent;
-(void)_setStartSelectPosition:(NSPoint)position;
-(void)_setCurrentSelectPosition:(NSPoint)position;
@end
