//
//  TGSearchRowItem.m
//  Telegram
//
//  Created by keepcoder on 30.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSearchRowItem.h"

@implementation TGSearchRowItem

-(NSUInteger)hash {
    return -1;
}

-(Class)viewClass {
    return NSClassFromString(@"TGGeneralSearchRowView");
}

@end
