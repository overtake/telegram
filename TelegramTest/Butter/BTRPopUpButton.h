//
//  BTRPopUpButton.h
//  Butter
//
//  Created by Indragie Karunaratne on 2012-12-30.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRControl.h"

@interface BTRPopUpButton : BTRControl

// The pop up button's menu.
@property (nonatomic, copy) IBOutlet NSMenu *btrMenu;

// The selected item whose title is being currently displayed in
// the pop up button.
@property (nonatomic, strong) NSMenuItem *selectedItem;

// Whether the pop up button automatically calls -setEnabled: on all
// menu items before displaying the menu.
@property (nonatomic, assign) BOOL autoenablesItems;

// Alignment of the text in the pop up button label.
@property (nonatomic, assign) NSTextAlignment textAlignment;

- (void)selectItemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfSelectedItem;

// Adjust the width of the view to fit the content
- (void)sizeToFit;

- (NSImage *)arrowImageForControlState:(BTRControlState)state;
- (void)setArrowImage:(NSImage *)image forControlState:(BTRControlState)state;

// Can be overriden by subclasses to customize layout
// The frame of the image view 
- (NSRect)imageFrame;

// The frame of the text label
- (NSRect)labelFrame;

// The frame of the arrow image view
- (NSRect)arrowFrame;

// The padding between each element (between image and label, and label and arrow)
- (CGFloat)interElementSpacing;

// The distance between the pop up button content and the view edges
- (CGFloat)edgeInset;

// The width to fit all the content in the view (used by -sizeToFit)
- (CGFloat)widthToFit;

// Returns the arrow image for the current `BTRControlState`
@property (nonatomic, strong, readonly) NSImage *currentArrowImage;

@end
