
#import <Cocoa/Cocoa.h>
@class TGCalendarView;
@interface TGCalendarCell : NSButton


@property (weak) TGCalendarView* owner;
@property (nonatomic, strong) NSDate* representedDate;
@property (nonatomic) BOOL selected;

-(void)setTarget:(id)target selector:(SEL)selector;

//@property (nonatomic,strong) NSString *title;

@end
