//
//  LoginButtonAndErrorView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface LoginButtonAndErrorView : TMView
@property (nonatomic, strong) TMTextButton *textButton;
@property (nonatomic, strong) TMTextField *errorTextField;

- (void)showErrorWithText:(NSString *)text;
- (void)setButtonText:(NSString *)string;

- (void)prepareForLoading;
- (void)loadingSuccess;
- (void)setHasImage:(BOOL)hasImage;
- (void)performTextToBottomWithDuration:(float)positionDuration;
@end
