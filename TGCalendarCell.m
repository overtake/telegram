
#import "TGCalendarCell.h"
#import "TGCalendarView.h"
@interface TGCalendarCell ()
- (void) commonInit;
- (BOOL) isToday;
@end

@implementation TGCalendarCell

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
	self.representedDate = nil;
    if(NSAppKitVersionNumber > NSAppKitVersionNumber10_9)
        self.appearance = [NSAppearance currentAppearance];
    [(NSButtonCell*)[self cell] setHighlightsBy:NSNoCellMask];
}

-(void)setTarget:(id)target selector:(SEL)selector {
    self.target = target;
    self.action = selector;
}

-(NSFont *)font {
    return TGSystemFont(14);
}

- (BOOL) isToday {
	if(self.representedDate) {
		return 	[TGCalendarView isSameDate:self.representedDate date:[NSDate date]];
	} else {
		return NO;
	}
}

- (void) setSelected:(BOOL)selected {
	_selected = selected;
	self.needsDisplay = YES;
}

- (void) setRepresentedDate:(NSDate *)representedDate {
	_representedDate = representedDate;
	if(_representedDate) {
		NSCalendar *cal = [NSCalendar currentCalendar];
		cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
		unsigned unitFlags = NSCalendarUnitDay;// | NSCalendarUnitYear | NSCalendarUnitMonth;
		NSDateComponents *components = [cal components:unitFlags fromDate:_representedDate];
		NSInteger day = components.day;
		self.title = [NSString stringWithFormat:@"%ld",day];
	} else {
		self.title = @"";
	}
}

- (void)drawRect:(NSRect)dirtyRect {
	if(self.owner) {
	//	[NSGraphicsContext saveGraphicsState];
		
		NSRect bounds = [self bounds];
        
        
        

		[NSColorFromRGB(0xffffff) setFill];
		NSRectFill(dirtyRect);
		
		
		if(self.representedDate) {

			NSMutableParagraphStyle * aParagraphStyle = [[NSMutableParagraphStyle alloc] init];
			[aParagraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
			[aParagraphStyle setAlignment:NSCenterTextAlignment];
			
			
			//title
            NSDictionary *attrs = @{NSParagraphStyleAttributeName: aParagraphStyle,NSFontAttributeName: self.font,NSForegroundColorAttributeName:self.representedDate.timeIntervalSince1970 < [[MTNetwork instance] getTime] ? self.owner.textColor : GRAY_TEXT_COLOR};
			
			NSSize size = [self.title sizeWithAttributes:attrs];
			
			NSRect r = NSMakeRect(bounds.origin.x,
								  bounds.origin.y + ((bounds.size.height - size.height)/2.0) - 1,
								  bounds.size.width,
								  size.height);
			
			[self.title drawInRect:r withAttributes:attrs];
			
			
			//line
			NSBezierPath* topLine = [NSBezierPath bezierPath];
			[topLine moveToPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
			[topLine lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
			[self.owner.dayMarkerColor set];
			topLine.lineWidth = 0.3f;
			[topLine stroke];
			if([self selected]) {
				[self.owner.todayMarkerColor set];
				NSBezierPath* bottomLine = [NSBezierPath bezierPath];
				[bottomLine moveToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
				[bottomLine lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
				bottomLine.lineWidth = 4.0f;
				[bottomLine stroke];
			}
		}
	//	[NSGraphicsContext restoreGraphicsState];
    } else {
        [super drawRect:dirtyRect];
    }
}

@end
