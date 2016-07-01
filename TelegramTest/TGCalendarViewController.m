//
//  TGCalendarViewController.m
//  Telegram
//
//  Created by keepcoder on 29/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGCalendarViewController.h"
#import "TGCalendarUtils.h"
#import "TGSettingsTableView.h"
#import "TGCalendarRowItem.h"
#import "TGModernStickRowItem.h"
#import "TGCalendarStickRowItem.h"
#import "MessageTableItem.h"
@interface TGCalendarViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) TGCalendarRowItem *selectedItem;
@property (nonatomic,assign) BOOL inProgress;
@end

@implementation TGCalendarViewController

-(void)loadView {
    [super loadView];
    
    self.view.wantsLayer = YES;
    self.view.layer.cornerRadius = 4;
    self.view.autoresizesSubviews = YES;
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutCalendar];
}


-(void)layoutCalendar {
    
    
    [_tableView removeAllItems:NO];
    [_tableView reloadData];
    
    NSDate *currentDate = [NSDate date];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    weak();
    
    NSDate *startDate = [dateFormat dateFromString:@"20130801"];
    
    while (currentDate.timeIntervalSince1970 > startDate.timeIntervalSince1970) {
        
        TGCalendarRowItem *item = [[TGCalendarRowItem alloc] initWithObject:currentDate];
        
        
        [item setDayClickHandler:^(NSDate *month, NSInteger day) {
            [weakSelf didSelectDate:[TGCalendarUtils monthDay:day date:month]];
        }];
        
        [_tableView insert:[[TGCalendarStickRowItem alloc] initWithObject:currentDate] atIndex:0 tableRedraw:NO];
        [_tableView insert:[[TGGeneralRowItem alloc] initWithHeight:20] atIndex:1 tableRedraw:NO];
        [_tableView insert:item atIndex:2 tableRedraw:NO];
        
        
        currentDate = [TGCalendarUtils stepMonth:-1 date:currentDate];
        
    }
    [_tableView reloadData];
    
    
    [self scrollToCurrentDate:YES animated:NO];
    
    [_tableView setStickClass:[TGCalendarStickRowItem class]];
    

}




- (void) didSelectDate:(NSDate *)selectedDate {
    
    assert(_messagesViewController != nil);
    
    [self.messagesViewController showModalProgress];
    
    
    selectedDate = [NSDate dateWithTimeIntervalSince1970:selectedDate.timeIntervalSince1970];
    id request;
    
    int time = selectedDate.timeIntervalSince1970 - [[MTNetwork instance] globalTimeOffsetFromUTC];
    
    
    request = [TLAPI_messages_getHistory createWithPeer:_messagesViewController.conversation.inputPeer offset_id:0 offset_date:time add_offset:-100 limit:100 max_id:INT32_MAX min_id:0];
    
    _inProgress = YES;
    
    [self scrollToCurrentDate:NO animated:NO];
    
    [RPCRequest sendRequest:request successHandler:^(id request, TL_messages_messages *response) {
        
        _inProgress = NO;
        
        [TL_localMessage convertReceivedMessages:response.messages];
        
        if(response.messages.count > 0) {
            [[Storage manager] addHolesAroundMessage:[response.messages firstObject]];
            [[Storage manager] addHolesAroundMessage:[response.messages lastObject]];
            
            [SharedManager proccessGlobalResponse:response];
            
            __block TL_localMessage *jumpMessage = [response.messages lastObject];
            
            
            [self.messagesViewController showMessage:jumpMessage fromMsg:nil flags:ShowMessageTypeDateJump];
            [self.messagesViewController hideModalProgressWithSuccess];
            
        } else {
            [self.messagesViewController hideModalProgress];
        }
        
        
        
    } errorHandler:^(id request, RpcError *error) {
        [self.messagesViewController hideModalProgress];
        _inProgress = NO;
    } timeout:10];
    
}

-(void)setMessagesViewController:(MessagesViewController *)messagesViewController {
    _messagesViewController = messagesViewController;
    [self addScrollEvent];
}

-(void)addScrollEvent {
    id clipView = [[self.messagesViewController.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
    
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    
    if(_rblpopover.isShown) {
        [self scrollToCurrentDate:YES animated:YES];
    }
}

-(void)scrollToCurrentDate:(BOOL)scroll animated:(BOOL)animated {
    NSRange range = [_messagesViewController.table rowsInRect:[_messagesViewController.table visibleRect]];
    
    __block MessageTableItem *item;
    //NSEnumerationReverse
    [_messagesViewController.messageList enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(obj.message != nil) {
            item = obj;
            *stop = YES;
        }
        
    }];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:item.message.date];
    
    
    [self.tableView.list enumerateObjectsUsingBlock:^(TGCalendarRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[TGCalendarRowItem class]]) {
            if([TGCalendarUtils isSameDate:date date:obj.month checkDay:NO] && !_inProgress) {
               
                NSCalendar *cal = [NSCalendar currentCalendar];
                cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
                NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:date];
                
                BOOL otherDay = _selectedItem.selectedDay != components.day;
                
                obj.selectedDay = components.day;
                
               if(_selectedItem != obj || otherDay) {
                    
                    if(scroll) {
                     //   if(idx == _tableView.count - 1)
                      //      [_tableView scrollToItem:[_tableView itemAtPosition:idx] animated:animated yOffset:10];
                      //  else
                        [_tableView scrollToItem:[_tableView itemAtPosition:idx - 2] animated:animated yOffset:10];
                    }
                    
                    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:idx] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                }

                _selectedItem = obj;
                
               
            } else {
                if(obj.selectedDay != -1) {
                    obj.selectedDay = -1;
                    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:idx] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                }
               
            }
 
        }
        
    }];
    
    
   
}


@end
