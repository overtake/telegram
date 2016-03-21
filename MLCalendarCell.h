//
//  NSCalendarCell.h
//  ModernLookOSX
//
//  Created by András Gyetván on 2015. 03. 08..
//  Copyright (c) 2015. DroidZONE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MLCalendarView;
@interface MLCalendarCell : NSButton
//@property (nonatomic, copy) NSColor* backgroundColor;
//@property (nonatomic, copy) NSColor* textColor;
//@property (nonatomic, copy) NSColor* selectionColor;
//@property (nonatomic, copy) NSColor* todayMarkerColor;
//@property (nonatomic, copy) NSColor* dayMarkerColor;

@property (weak) MLCalendarView* owner;
@property (nonatomic, strong) NSDate* representedDate;
@property (nonatomic) BOOL selected;

-(void)setTarget:(id)target selector:(SEL)selector;

//@property (nonatomic,strong) NSString *title;

@end
