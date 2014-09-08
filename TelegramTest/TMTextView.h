//
//  TMTextView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMTextView : NSTextView
@property (nonatomic,strong) NSColor *placeholderColor;
@property (nonatomic, strong) NSString *placeholderStr;
@property (nonatomic) NSPoint placeholderPoint;
@property (nonatomic,assign) BOOL singleLineMode;
@end
