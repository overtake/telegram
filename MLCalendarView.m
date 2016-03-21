//
//  MLCalendarPopup.m
//  ModernLookOSX
//
//  Created by András Gyetván on 2015. 03. 08..
//  Copyright (c) 2015. DroidZONE. All rights reserved.
//

#import "MLCalendarView.h"
#import "MLCalendarCell.h"
#import "MLCalendarBackground.h"

@interface MLCalendarView ()

@property (weak) IBOutlet NSTextField *calendarTitle;
- (IBAction)nextMonth:(id)sender;
- (IBAction)prevMonth:(id)sender;

@property (strong) NSMutableArray* dayLabels;
@property (strong) NSMutableArray* dayCells;
//@property (nonatomic, strong) NSDate* date;

- (id) viewByID:(NSString*)_id;
- (void) layoutCalendar;
- (void) stepMonth:(NSInteger)dm;
@end

@implementation MLCalendarView

+ (BOOL) isSameDate:(NSDate*)d1 date:(NSDate*)d2 {
	if(d1 && d2) {
		NSCalendar *cal = [NSCalendar currentCalendar];
		cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
		unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth;
		NSDateComponents *components = [cal components:unitFlags fromDate:d1];
		NSInteger ry = components.year;
		NSInteger rm = components.month;
		NSInteger rd = components.day;
		components = [cal components:unitFlags fromDate:d2];
		NSInteger ty = components.year;
		NSInteger tm = components.month;
		NSInteger td = components.day;
		return (ry == ty && rm == tm && rd == td);
	} else {
		return NO;
	}
}


- (instancetype) init {
	self = [super initWithNibName:@"MLCalendarView" bundle:[NSBundle bundleForClass:[self class]]];
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
    self.textColor = TEXT_COLOR;
	self.selectionColor = [NSColor redColor];
	self.todayMarkerColor = GRAY_TEXT_COLOR;
	self.dayMarkerColor = DIALOG_BORDER_COLOR;
	self.dayCells = [NSMutableArray array];
	for(int i = 0; i < 6; i++) {
		[self.dayCells addObject:[NSMutableArray array]];
	}
	_date = [NSDate date];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
	self.dayLabels = [NSMutableArray array];
	for(int i = 1; i < 8; i++) {
		NSString* _id = [NSString stringWithFormat:@"day%d",i];
		NSTextField* d = [self viewByID:_id];
		[self.dayLabels addObject:d];
	}
	for(int row = 0; row < 6;row++) {
		for(int col = 0; col < 7; col++) {
			int i = (row*7)+col+1;
			NSString* _id = [NSString stringWithFormat:@"c%d",i];
			MLCalendarCell* cell = [self viewByID:_id];
            [cell setTarget:self selector:@selector(cellClicked:)];
			[self.dayCells[row] addObject:cell];
			cell.owner = self;
		}
	}
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	NSArray *days = [df shortStandaloneWeekdaySymbols];
	for(NSInteger i = 0; i < days.count;i++) {
		NSString* day = [days[i] uppercaseString];
		NSInteger col = [self colForDay:i+1];
		NSTextField* tf = self.dayLabels[col];
		tf.stringValue = day;
	}
	MLCalendarBackground* bv = (MLCalendarBackground*)self.view;
	bv.backgroundColor = self.backgroundColor;
	[self layoutCalendar];
}

- (id) viewByID:(NSString*)_id {
	for (NSView *subview in self.view.subviews) {
		if([subview.identifier isEqualToString:_id]) {
			return subview;
		}
	}
	return nil;
}

- (void) setDate:(NSDate *)date {
	_date = [self toUTC:date];
	[self layoutCalendar];
	NSCalendar *cal = [NSCalendar currentCalendar];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	unsigned unitFlags = NSCalendarUnitDay| NSCalendarUnitYear | NSCalendarUnitMonth;
	NSDateComponents *components = [cal components:unitFlags fromDate:self.date];
	NSInteger month = components.month;
	NSInteger year = components.year;
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	NSString *monthName = [df standaloneMonthSymbols][month-1];
	NSString* mnFirstLetter = [[monthName substringToIndex:1] uppercaseString];
	NSString* mnLastPart = [monthName substringFromIndex:1];
	monthName = [NSString stringWithFormat:@"%@%@",mnFirstLetter,mnLastPart];
	NSString* budgetDateSummary = [NSString stringWithFormat:@"%@, %ld",monthName,year];
	self.calendarTitle.stringValue = budgetDateSummary;
}

- (NSDate*) toUTC:(NSDate*)d {
	NSCalendar *cal = [NSCalendar currentCalendar];
	unsigned unitFlags = NSCalendarUnitDay| NSCalendarUnitYear | NSCalendarUnitMonth;
	NSDateComponents *components = [cal components:unitFlags fromDate:d];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	return [cal dateFromComponents:components];
}
- (void) setSelectedDate:(NSDate *)selectedDate {
	_selectedDate = [self toUTC:selectedDate];
	for(int row = 0; row < 6;row++) {
		for(int col = 0; col < 7; col++) {
			MLCalendarCell*cell = self.dayCells[row][col];
			BOOL selected = [MLCalendarView isSameDate:cell.representedDate date:_selectedDate];
			cell.selected = selected;
		}
	}
	
}

- (void)cellClicked:(id)sender {
    
    MLCalendarCell* cell = sender;
    
    if(cell.representedDate.timeIntervalSince1970 > [[MTNetwork instance] getTime])
        return;
    
	for(int row = 0; row < 6;row++) {
		for(int col = 0; col < 7; col++) {
			MLCalendarCell*cell = self.dayCells[row][col];
			cell.selected = NO;
		}
	}
    
	
	cell.selected = YES;
	_selectedDate = cell.representedDate;
	if(self.delegate) {
		if([self.delegate respondsToSelector:@selector(didSelectDate:)]) {
			[self.delegate didSelectDate:self.selectedDate];
		}
	}
}

- (NSDate*) monthDay:(NSInteger)day {
	NSCalendar *cal = [NSCalendar currentCalendar];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	unsigned unitFlags = NSCalendarUnitDay| NSCalendarUnitYear | NSCalendarUnitMonth;
	NSDateComponents *components = [cal components:unitFlags fromDate:_date];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps.day = day;
	comps.year = components.year;
	comps.month = components.month;
	return [cal dateFromComponents:comps];
}

- (NSInteger) lastDayOfTheMonth {
	NSCalendar *cal = [NSCalendar currentCalendar];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	NSRange daysRange = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.date];
	return daysRange.length;
}

- (NSInteger) colForDay:(NSInteger)day {
	NSCalendar *cal = [NSCalendar currentCalendar];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	
	NSInteger idx = day - cal.firstWeekday;
	if(idx < 0) idx = 7 + idx;
	return idx;
}

+ (NSString*) dd:(NSDate*)d {
	NSCalendar *cal = [NSCalendar currentCalendar];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth;
	NSDateComponents *cpt = [cal components:unitFlags fromDate:d];
	return [NSString stringWithFormat:@"%ld-%ld-%ld",cpt.year, cpt.month, cpt.day];
}

- (void) layoutCalendar {
	if(!self.view) return;
	for(int row = 0; row < 6;row++) {
		for(int col = 0; col < 7; col++) {
			MLCalendarCell*cell = self.dayCells[row][col];
			cell.representedDate = nil;
			cell.selected = NO;
		}
	}
	NSCalendar *cal = [NSCalendar currentCalendar];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	unsigned unitFlags = NSCalendarUnitWeekday;
	NSDateComponents *components = [cal components:unitFlags fromDate:[self monthDay:1]];
	NSInteger firstDay = components.weekday;
	NSInteger lastDay = [self lastDayOfTheMonth];
	NSInteger col = [self colForDay:firstDay];
	NSInteger day = 1;
	for(int row = 0; row < 6;row++) {
		for(; col < 7; col++) {
			if(day <= lastDay) {
				MLCalendarCell*cell = self.dayCells[row][col];
				NSDate* d = [self monthDay:day];
				cell.representedDate = d;
				BOOL selected = [MLCalendarView isSameDate:d date:_selectedDate];
				cell.selected = selected;
				day++;
			}
		}
		col = 0;
	}
}

- (void) stepMonth:(NSInteger)dm {
	NSCalendar *cal = [NSCalendar currentCalendar];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	unsigned unitFlags = NSCalendarUnitDay| NSCalendarUnitYear | NSCalendarUnitMonth;
	NSDateComponents *components = [cal components:unitFlags fromDate:self.date];
	NSInteger month = components.month + dm;
	NSInteger year = components.year;
	if(month > 12) {
		month = 1;
		year++;
	};
	if(month < 1) {
		month = 12;
		year--;
	}
	components.year = year;
	components.month = month;
	self.date = [cal dateFromComponents:components];
}

- (IBAction)nextMonth:(id)sender {
	[self stepMonth:1];
}

- (IBAction)prevMonth:(id)sender {
	[self stepMonth:-1];
}

@end
