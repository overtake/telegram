//
//  BTRButton.h
//  Butter
//
//  Created by Jonathan Willing on 12/21/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRControl.h"
#import "BTRImageView.h"
#import "BTRLabel.h"

@interface BTRButton : BTRControl

@property (nonatomic, strong, readonly) BTRLabel *titleLabel;
@property (nonatomic, strong, readonly) BTRImageView *backgroundImageView;
@property (nonatomic, strong, readonly) BTRImageView *imageView;

// Sets the content mode on the underlying image view.
@property (nonatomic, assign) BTRViewContentMode backgroundContentMode;
@property (nonatomic, assign) BTRViewContentMode imageContentMode;

@property (nonatomic) float heightBugFix;

@property (nonatomic) BOOL opacityHover;

// Subclassing hooks
- (CGRect)backgroundImageFrame;
- (CGRect)imageFrame;
- (CGRect)labelFrame;

@end
