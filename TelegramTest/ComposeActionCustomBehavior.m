//
//  ComposeActionSelectBehavior.m
//  Telegram
//
//  Created by keepcoder on 20.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionCustomBehavior.h"

@implementation ComposeActionCustomBehavior


-(NSUInteger)limit {
    return NSIntegerMax;
}

-(NSAttributedString *)centerTitle {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:self.customCenterTitle withColor:NSColorFromRGB(0x333333)];
    
    [attr setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attr.length-1)];
    
    return attr;
}

-(NSString *)doneTitle {
    return self.customDoneTitle;
}

-(void)composeDidChangeSelected {
    
    if(self.composeChangeSelected)
        self.composeChangeSelected();
    
}

-(void)composeDidDone {
    if(self.composeDone)
        self.composeDone();
}


-(void)composeDidCancel {
    if(self.composeCancel)
        self.composeCancel();
}

@end
