#import "NSView+GreenArrows.h"
#import "NS(Attributed)String+Geometrics.h"

@implementation NSView (ShowDimensions)

const float calloutFontSize = 24.0 ;
const float calloutLineWidth = 3.0 ;
const float arrowWidth = 16.0 ;
const float arrowLength = 24.0 ;

- (void)showGreenArrowsWithHeightNumber:(NSNumber*)overallHeightNumber {
	// Lock graphics context focus so we can draw
	if ([self canDraw]) {

		[self lockFocus] ;
		float overallHeight = [overallHeightNumber floatValue] ;
		NSRect rect = [self bounds] ;
		
		// Erase previous ShowDimensions by redrawing the whole underlying view
		// Not very efficient, but, oh well, it's only a demo
		[self drawRect:rect] ;
		
		float x1 = NSMinX(rect) + 0.5 ;
		float x2 = NSMaxX(rect) - 0.5 ;
		float xMid = (x1+x2)/2 ;
		[[NSColor greenColor] set] ;
		// Draw the edge line
		NSRect line = NSMakeRect(x1, overallHeight, x2-x1, 1.0) ;
		NSRectFill(line) ;

		float y1 = NSMinY(rect) + 0.5 ;
		//float y2 = y1 + overallHeight ;
		//float yMid = (y1+y2)/2 ;

		// Create callout string and its attributes
		NSString* callout = [NSString stringWithFormat:@"%0.1f", overallHeight] ;
		NSFont* calloutFont = [NSFont systemFontOfSize:calloutFontSize] ;
		NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
				 calloutFont, NSFontAttributeName,
				 [NSColor greenColor], NSForegroundColorAttributeName,
				 nil];

		// In order to align the callout and white-out its
		// background, we eat a bit of our own dog food...
		NSSize calloutTextSize = [callout sizeForWidth:FLT_MAX
												height:FLT_MAX
											attributes:attrs] ;
//		float calloutMinX = xMid-calloutTextSize.width/2 ;
		//float calloutMinY = yMid-calloutTextSize.height/2 ;
		if (overallHeight < 2*arrowLength + calloutTextSize.height) {
			// Not enough vertical space to fit the callout text in between the
			// callout arrows, so offset the callout text to the right.
//			calloutMinX += (arrowWidth + calloutTextSize.width)/2 ;
		}
		

		// Get ready to draw callout line and arrows
		NSBezierPath* bp ;
		NSColor* lightGreen = [NSColor colorWithDeviceRed:0.0 green:1.0 blue:0.0 alpha:0.25] ;
		[lightGreen set]  ;
		
		// Draw top arrow ;
		bp = [NSBezierPath bezierPath] ;
		[bp moveToPoint:NSMakePoint(xMid, y1)] ;
		[bp relativeLineToPoint:NSMakePoint(-arrowWidth/2, arrowLength)] ;
		[bp relativeLineToPoint:NSMakePoint(+arrowWidth, 0.0)] ;
		[bp closePath] ;
		[bp fill] ;

		// Draw the callout line
		bp = [NSBezierPath bezierPath] ;
		[bp setLineWidth:calloutLineWidth] ;
		[bp moveToPoint:NSMakePoint(xMid, y1)] ;
		[bp lineToPoint:NSMakePoint(xMid, overallHeight)] ;
		[bp stroke] ;
		
		// Draw bottom arrow ;
		bp = [NSBezierPath bezierPath] ;
		[bp moveToPoint:NSMakePoint(xMid, overallHeight)] ;
		[bp relativeLineToPoint:NSMakePoint(-arrowWidth/2, -arrowLength)] ;
		[bp relativeLineToPoint:NSMakePoint(+arrowWidth, 0.0)] ;
		[bp closePath] ;
		[bp fill] ;
		
		/*
		 // White-out existing text behind the callout text
		 NSRect calloutRect = NSMakeRect(calloutMinX, calloutMinY, calloutTextSize.width, calloutTextSize.height) ;
		 [[NSColor whiteColor] set] ;
		 NSRectFill(calloutRect) ;
		 
		 // Draw the callout text
		 NSPoint calloutLocation = NSMakePoint(calloutMinX, calloutMinY) ;
		 [callout drawAtPoint:calloutLocation
		 withAttributes:attrs] ;
		 */
		[self unlockFocus] ;
	}
}

- (void)showGreenArrowsWithHeight:(float)overallHeight {
	// Delay drawing this until after the runloop has completed.
	// Otherwise, whatever we do will likely be obliterated by 
	// an invocation of drawRect:
	[self performSelector:@selector(showGreenArrowsWithHeightNumber:)
				   withObject:[NSNumber numberWithFloat:overallHeight]
				   afterDelay:.05] ;
	
	// This method is invoked many times as window is resized.
	// It would e much more efficient to somehow cancel all except the last one 
	// just before the mouse is released.  But I can't figure out easily how
	// to do that without having to add an ivar and make this a subclass
	// instead of a category that I can apply to both NSTextView and NSTextFields.
}

@end
