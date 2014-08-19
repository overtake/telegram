//
//  BTRControlAction.h
//  Butter
//
//  Created by Jonathan Willing on 7/19/13.
//  Copyright (c) 2013 ButterKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTRControl.h"

@interface BTRControlAction : NSObject

@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, copy) void(^block)(BTRControlEvents events);
@property (nonatomic, assign) BTRControlEvents events;

@end
