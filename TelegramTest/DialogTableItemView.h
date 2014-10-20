//
//  DialogTableItemView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMElements.h"
#import "DialogTableItem.h"
#import "DialogSwipeTableControll.h"


#define DIALOG_CELL_HEIGHT 66

typedef enum {
    DialogTableItemViewFullStyle,
    DialogTableItemViewShortStyle
} DialogTableItemViewStyle;

@class DialogTableView;

@interface DialogTableItemView : TMRowView

@property (nonatomic, strong) DialogTableView *tableView;
@property (nonatomic) BOOL swipePanelActive;

@property (nonatomic) DialogTableItemViewStyle style;

- (BOOL)isSwipePanelActive;

@end
