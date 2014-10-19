//
//  _TMSearchTextField.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/24/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMClockProgressView : BTRView

@property (nonatomic, strong) NSImageView *frameView;
@property (nonatomic, strong) NSImageView *minView;
@property (nonatomic, strong) NSImageView *hourView;

@property (nonatomic) bool isAnimating;

- (void)startAnimating;
- (void)stopAnimating;


@end
