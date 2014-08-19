//
//  RBLTableCellView.m
//  Rebel
//
//  Created by Jonathan Willing on 10/23/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLTableCellView.h"

@implementation RBLTableCellView

- (void)viewDidMoveToSuperview {
	if (self.superview == nil) {
		[self rbl_prepareForReuse];
	}
	
	[super viewDidMoveToSuperview];
}

- (void)rbl_prepareForReuse {
	
}

@end
