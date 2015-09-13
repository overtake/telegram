//
//  TGSettingsTableView.m
//  Telegram
//
//  Created by keepcoder on 13.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSettingsTableView.h"


@interface TGSettingsTableView () <TMTableViewDelegate>

@end

@implementation TGSettingsTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.tm_delegate = self;
    }
    
    return self;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TGGeneralRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TGGeneralRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TGGeneralRowItem *) item {
   return [self cacheViewForClass:[item viewClass] identifier:NSStringFromClass([item viewClass]) withSize:NSMakeSize(NSWidth(self.frame), [item height])];
}

- (void)selectionDidChange:(NSInteger)row item:(TGGeneralRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TGGeneralRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(TGGeneralRowItem *) item {
    return NO;
}

@end
