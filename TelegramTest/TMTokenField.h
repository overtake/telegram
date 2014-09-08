//
//  TMTextField.h
//  Telegram
//
//  Created by keepcoder on 8/29/24.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TokenItem.h"
@protocol TMTokenFieldDelegate <NSObject>
@optional

- (void)textView:(id)testView removeElements:(NSArray *)tokens;
- (void)textView:(id)textView changeElementCount:(int)count;
- (void)textStringDidChange:(NSString*)text;
@end

@interface TMTokenField : NSTextView<NSTextViewDelegate>
@property id tokenDelegate;
@property NSMutableArray *elements;



- (void)addToken:(TokenItem *)token;
- (void)removeToken:(TokenItem *)token;
- (void)removeAllTokens;

- (TokenItem *)token:(NSUInteger)identifier object:(id)object title:(NSString *)title;

@end
