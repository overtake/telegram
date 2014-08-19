//
//  DialogTableView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTableView.h"

@interface DialogTableView : TMTableView

@property (nonatomic) BOOL isSwipeContainerOpen;
@property (nonatomic, strong) id swipeView;

@end
