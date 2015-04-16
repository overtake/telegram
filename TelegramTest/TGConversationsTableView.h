//
//  TGConversationsTableView.h
//  Telegram
//
//  Created by keepcoder on 14.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMTableView.h"

@interface TGConversationsTableView : TMTableView
@property (nonatomic) BOOL isSwipeContainerOpen;
@property (nonatomic, strong) id swipeView;
@end
