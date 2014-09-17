//
//  UserCardViewController.h
//  Telegram
//
//  Created by keepcoder on 16.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface UserCardViewController : TMViewController

typedef enum {
    UserCardViewTypeImport,
    UserCardViewTypeExport
} UserCardViewType;


-(void)showWithType:(UserCardViewType)type relativeRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(CGRectEdge)edge;

@end
