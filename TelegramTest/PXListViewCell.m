//
//  PXListViewCell.m
//  PXListView
//
//  Created by Alex Rozanski on 29/05/2010.
//  Copyright 2010 Alex Rozanski. http://perspx.com. All rights reserved.
//

#import "PXListViewCell.h"
#import "PXListViewCell+Private.h"

#import <iso646.h>

#import "PXListView.h"
#import "PXListView+Private.h"
#import "PXListView+UserInteraction.h"
#pragma mark -

@implementation PXListViewCell

@synthesize reusableIdentifier = _reusableIdentifier;
@synthesize listView = _listView;
@synthesize row = _row;


#pragma mark -
#pragma mark Init/Dealloc




- (id)initWithFrame:(NSRect)frameRect
{
	if((self = [super initWithFrame:frameRect]))
	{
		_reusableIdentifier = NSStringFromClass([self class]);
	}
	
	return self;
}




#pragma mark -
#pragma mark Handling Selection

- (void)mouseDown:(NSEvent*)theEvent
{
	[[self listView] handleMouseDown:theEvent inCell:self];
}

- (BOOL)isSelected
{
	return [[[self listView] selectedRows] containsIndex:[self row]];
}

#pragma mark -
#pragma mark Drag & Drop

- (void)setDropHighlight:(PXListViewDropHighlight)inState
{
	[[self listView] setShowsDropHighlight: inState != PXListViewDropNowhere];
	
	_dropHighlight = inState;
	[self setNeedsDisplay:YES];
}

-(PXListViewDropHighlight)dropHighlight
{
	return _dropHighlight;
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    [super drawRect:dirtyRect];
    
//	if(_dropHighlight == PXListViewDropAbove)
//	{
//		[[NSColor alternateSelectedControlColor] set];
//		NSRect		theBox = [self bounds];
//		theBox.origin.y += theBox.size.height -1.0f;
//		theBox.size.height = 2.0f;
//		[NSBezierPath setDefaultLineWidth: 2.0f];
//		[NSBezierPath strokeRect: theBox];
//	}
//	else if(_dropHighlight == PXListViewDropBelow)
//	{
//		[[NSColor alternateSelectedControlColor] set];
//		NSRect		theBox = [self bounds];
//		theBox.origin.y += 1.0f;
//		theBox.size.height = 2.0f;
//		[NSBezierPath setDefaultLineWidth: 2.0f];
//		[NSBezierPath strokeRect: theBox];
//	}
//	else if(_dropHighlight == PXListViewDropOn)
//	{
//		[[NSColor alternateSelectedControlColor] set];
//		NSRect		theBox = [self bounds];
//		[NSBezierPath setDefaultLineWidth: 2.0f];
//		[NSBezierPath strokeRect: NSInsetRect(theBox,1.0f,1.0f)];
//	}
}


#pragma mark -
#pragma mark Reusing Cells

- (void)prepareForReuse
{
	_dropHighlight = PXListViewDropNowhere;
}


#pragma mark layout

-(void)layoutSubviews;
{
    
}

@end
