//
//  TGProfileHeaderRowItem.m
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGProfileHeaderRowItem.h"

@implementation TGProfileHeaderRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _conversation = object;
    }
    
    return self;
}


-(Class)viewClass {
    return NSClassFromString(@"TGProfileHeaderRowView");
}


@end
