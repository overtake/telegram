//
//  TGCTextMark.m
//  Telegram
//
//  Created by keepcoder on 07.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGCTextMark.h"

@implementation TGCTextMark

-(id)initWithRange:(NSRange)range color:(NSColor *)color isReal:(BOOL)isReal; {
    if(self = [super init]) {
        _range = range;
        _color = color;
        _isReal = isReal;
    }
    return self;
}
@end
