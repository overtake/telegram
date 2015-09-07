//
//  ITSwitch.h
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef void(^changeHandler)(BOOL isOn);


/**
 *  ITSwitch is a replica of UISwitch for Mac OS X
 */
@interface ITSwitch : NSControl

/**
 *  @property isOn - Gets or sets the switches state
 */
@property (nonatomic, setter = setOn:) BOOL isOn;

/**
 *  @property tintColor - Gets or sets the switches tint
 */
@property (nonatomic, strong) NSColor *tintColor;
@property(nonatomic, copy) changeHandler didChangeHandler;


- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
