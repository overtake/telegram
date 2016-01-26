//
//  TGGeneralInputRowItem.m
//  Telegram
//
//  Created by keepcoder on 05/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGeneralInputRowItem.h"

@implementation TGGeneralInputRowItem


-(Class)viewClass {
    return NSClassFromString(@"TGGeneralInputTextRowView");
}

-(BOOL)updateItemHeightWithWidth:(int)width {
    
    NSSize size = [_result sizeForTextFieldForWidth:width - (self.xOffset * 2)];
    
    self.height = MAX(25, size.height + 5);
    
    return YES;
}

@end
