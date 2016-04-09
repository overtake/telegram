
#import <Cocoa/Cocoa.h>

@protocol MLCalendarViewDelegate <NSObject>
- (void) didSelectDate:(NSDate*)selectedDate;
@end

@interface TGCalendarView : NSViewController
@property (nonatomic, copy) NSColor* backgroundColor;
@property (nonatomic, copy) NSColor* textColor;
@property (nonatomic, copy) NSColor* selectionColor;
@property (nonatomic, copy) NSColor* todayMarkerColor;
@property (nonatomic, copy) NSColor* dayMarkerColor;

@property (nonatomic,weak) id<MLCalendarViewDelegate> delegate;

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSDate* selectedDate;

+ (BOOL) isSameDate:(NSDate*)d1 date:(NSDate*)d2;


@end
