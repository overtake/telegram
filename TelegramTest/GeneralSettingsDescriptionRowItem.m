//
//  GeneralSettingsDescriptionRowItem.m
//  Telegram
//
//  Created by keepcoder on 27.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "GeneralSettingsDescriptionRowItem.h"

@implementation GeneralSettingsDescriptionRowItem

-(id)initWithObject:(id)object
{
    if(self = [super initWithObject:object]) {
        self.attributedString = object;
        
        self.height = 80;
    }
    
    return self;
}

-(NSUInteger)hash {
    return [self.attributedString hash];
}

@end
