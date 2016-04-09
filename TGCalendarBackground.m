
#import "TGCalendarBackground.h"

@implementation TGCalendarBackground

- (instancetype)initWithFrame: (NSRect)frameRect
{
	self = [super initWithFrame: frameRect];
	if (self != nil) {
		[self commonInit];
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if(self) {
		[self commonInit];
	}
	return self;
}

- (void) commonInit {
	self.backgroundColor = [NSColor whiteColor];
}

- (void)drawRect:(NSRect)dirtyRect {
	[self.backgroundColor set];
	NSRectFill(self.bounds);
}

@end
