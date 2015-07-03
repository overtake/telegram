//
//  TGSplitViewController.m
//  TelegramModern
//
//  Created by keepcoder on 25.06.15.
//  Copyright (c) 2015 telegram. All rights reserved.
//

#import "TGSplitViewController.h"

@implementation TGSplitViewController


-(void)splitViewDidNeedResizeController:(NSRect)rect {
    
   // NSLog(@"%@",NSStringFromRect(rect));
    
    [self.view setFrame:rect];
    
}

@end
