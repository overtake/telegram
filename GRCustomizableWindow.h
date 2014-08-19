//
//  GRCustomizableWindow.h
//  GRCustomizableWindow
//
//  Created by Guilherme Rambo on 26/02/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GRCustomizableWindow : NSWindow

/*!
 @property titlebarHeight
 @abstract Defines the height of the window's titlebar
 */
@property (nonatomic, copy) NSNumber *titlebarHeight;

/*!
 @property titlebarColor
 @abstract Defines the background color of the window's titlebar
 @discussion
 Set the window's titlebar background color, It will be overlaid by a subtle gradient
 */
@property (nonatomic, copy) NSColor *titlebarColor;

/*!
 @property titleColor
 @abstract Defines the color used to draw the window's title
 @discussion
 If left nil, will use a darker version of titlebarColor
 */
@property (nonatomic, copy) NSColor *titleColor;

/*!
 @property titleFont
 @abstract Defines the font used to draw the window's title
 */
@property (nonatomic, copy) NSFont *titleFont;

/*!
 @property centerControls
 @abstract Defines if the window's buttons and title should be centered vertically
 */
@property (nonatomic, assign) BOOL centerControls;

/*!
 @property enableGradients
 @abstract Defines whether the window's title bar and content border should have a gradient added to them
 */
@property (nonatomic, assign) BOOL enableGradients;

@end