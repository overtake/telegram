//
//  BTRLabel.m
//  Butter
//
//  Created by Jonathan Willing on 12/21/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRLabel.h"

@implementation BTRLabel

static void BTRLabelCommonInit(BTRLabel *self) {
	self.bezeled = NO;
	self.editable = NO;
	self.drawsFocusRing = NO;
	self.drawsBackground = NO;
	self.selectable = NO;
}

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;
	BTRLabelCommonInit(self);
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	BTRLabelCommonInit(self);
	return self;
}

@end
