//
//  PXListViewCell.h
//  PXListView
//
//  Created by Alex Rozanski on 29/05/2010.
//  Copyright 2010 Alex Rozanski. http://perspx.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListViewDropHighlight.h"


@class PXListView;

@interface PXListViewCell : TMView
{
	NSString *_reusableIdentifier;
	
	NSUInteger _row;
	PXListViewDropHighlight	_dropHighlight;
}

@property (nonatomic, weak) PXListView *listView;

@property (readonly, copy) NSString *reusableIdentifier;
@property (readonly) NSUInteger row;

@property (readonly,getter=isSelected) BOOL selected;
@property (assign) PXListViewDropHighlight dropHighlight;


- (void)prepareForReuse;

-(void)layoutSubviews;

@end
