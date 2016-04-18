//
//  TGCTextView.h
//  Telegram
//
//  Created by keepcoder on 01.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TGCTextMark.h"


@interface TGCTextView : NSView  {
    CTFrameRef CTFrame;
    
    
    @public
    NSPoint startSelectPosition;
    NSPoint currentSelectPosition;
    
}

@property (nonatomic,copy) NSAttributedString *attributedString;
//@property (nonatomic,assign) NSRange selectionRange;
@property (nonatomic,assign,setter=setEditable:) BOOL isEditable;

@property (nonatomic,assign,readonly) NSRange selectRange;
@property (nonatomic,assign) BOOL disableLinks;

@property (nonatomic,strong) NSColor *selectColor;
@property (nonatomic,strong) NSColor *backgroundColor;

@property (nonatomic,weak) id <SelectTextDelegate> owner;


@property (nonatomic,strong) NSArray *drawRects;


-(void)setSelectionRange:(NSRange)selectionRange;

-(void)addMark:(TGCTextMark *)mark;
-(void)addMarks:(NSArray *)marks;

-(int)currentIndexInLocation:(NSPoint)location;
-(BOOL)indexIsSelected:(int)index;


-(void)open_link:(NSString *)link itsReal:(BOOL)itsReal;

@property (nonatomic,copy) void (^linkCallback)(NSString *link);

@property (nonatomic,copy) void (^linkOver)(NSString *link, BOOL over,NSRect rect,TGCTextView *textView);


// its private not for use
-(BOOL)_checkClickCount:(NSEvent *)theEvent;

-(BOOL)mouseInText:(NSEvent *)theEvent;

-(void)_mouseDown:(NSEvent *)theEvent;

@end
