/*
 Created by Jonathan Willing on 8/28/13.
 Copyright (c) 2013, ButterKit. All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

#import "BTRScrollView.h"
#import "BTRClipView.h"

@implementation BTRScrollView

#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	
	[self swapClipView];
	
	return self;
}

- (BTRClipView *)clipView {
	if ([self.contentView isKindOfClass:BTRClipView.class]) {
		return (BTRClipView *)self.contentView;
	}
	
	return nil;
}



#pragma mark Clip view swapping

- (void)swapClipView {
    self.layer = [CAScrollLayer layer];
	self.wantsLayer = YES;
//    [self.layer setDrawsAsynchronously:NO];
    self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    [self.layer setOpaque:YES];
    
	id documentView = self.documentView;
	BTRClipView *clipView = [[BTRClipView alloc] initWithFrame:self.contentView.frame];
    clipView.wantsLayer = YES;
//    [clipView.layer setDrawsAsynchronously:NO];
//    clipView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawDuringViewResize;
    [clipView.layer setOpaque:YES];
    
	self.contentView = clipView;
	self.documentView = documentView;
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self setNeedsDisplay:YES];
}

//- (void)viewWillStartLiveResize {
//    self.wantsLayer = NO;
//}
//
//- (void)viewDidEndLiveResize {
//    self.wantsLayer = YES;
//}

@end
