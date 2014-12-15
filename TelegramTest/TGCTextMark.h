//
//  TGCTextMark.h
//  Telegram
//
//  Created by keepcoder on 07.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGCTextMark : NSObject
@property (nonatomic,assign,readonly) NSRange range;
@property (nonatomic,strong) NSColor *color;

@property (nonatomic,assign,readonly) BOOL isReal;


-(id)initWithRange:(NSRange)range color:(NSColor *)color isReal:(BOOL)isReal;
@end
