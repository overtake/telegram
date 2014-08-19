//
//  TMSearchTextField.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/22/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "_TMSearchTextField.h"

@protocol TMSearchTextFieldDelegate <NSTextFieldDelegate>
- (void) searchFieldFocus;
- (void) searchFieldBlur;
- (void) searchFieldTextChange:(NSString*)searchString;
@end

@interface TMSearchTextField : TMView<TMSearchTextFieldDelegate>

@property (nonatomic, strong) TMView *containerView;
@property (nonatomic, strong) id<TMSearchTextFieldDelegate> delegate;

- (void)setStringValue:(NSString *)value;

@end
