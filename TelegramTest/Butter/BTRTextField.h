//
//  BTRTextField.h
//  Butter
//
//  Created by Jonathan Willing on 12/21/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BTRControl.h"
#import "BTRImageView.h"

// BTRTextField is a powerful subclass of NSTextField that adds support
// for image-based customization and modifications of default drawing,
// plus control event additions.
//
// BTRTextField should _not_ be layer backed in Interface Builder.
// There is an Interface Builder bug that leads to an issue which causes
// an additional shadow to be shown underneath the textfield.


@interface BTRTextField : NSTextField

- (NSImage *)backgroundImageForControlState:(BTRControlState)state;
- (void)setBackgroundImage:(NSImage *)image forControlState:(BTRControlState)state;

@property (nonatomic,strong) NSColor *activeFieldColor;
@property (nonatomic,strong) NSColor *inactiveFieldColor;
@property (nonatomic,assign) float fieldXInset;
@property (nonatomic, assign) BOOL drawsFocusRing;
// Modifies the contentMode on the underlying image view.
@property (nonatomic, assign) BTRViewContentMode contentMode;
@property (nonatomic, assign) BOOL animatesContents;
@property (nonatomic, strong) NSTextFieldCell *textFieldCell;

// Text attribute accessors
@property (nonatomic, strong) NSString *placeholderTitle;
@property (nonatomic, strong) NSColor *placeholderTextColor;
@property (nonatomic, strong) NSFont *placeholderFont;
@property (nonatomic, assign) NSTextAlignment placeholderAligment;
@property (nonatomic, strong) NSShadow *placeholderShadow;

@property (nonatomic, strong) NSShadow *textShadow;

// State
@property (nonatomic, readonly) BTRControlState state;
@property (nonatomic, getter = isHighlighted) BOOL btrHighlighted;
@property (nonatomic, readonly) NSInteger clickCount;

- (void)addBlock:(void (^)(BTRControlEvents events))block forControlEvents:(BTRControlEvents)events;

// Subclassing hooks
- (void)drawBackgroundInRect:(NSRect)rect;
- (NSRect)drawingRectForProposedDrawingRect:(NSRect)rect;
- (NSRect)editingRectForProposedEditingRect:(NSRect)rect;
- (void)setFieldEditorAttributes:(NSTextView *)fieldEditor;

@end
