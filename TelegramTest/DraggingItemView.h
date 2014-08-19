//
//  DraggingItemView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 05.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface DraggingItemView : TMView

typedef enum {
    DraggingTypeMedia = 1,
    DraggingTypeDocument = 2
} DraggingType;

@property (nonatomic,assign) BOOL dragEntered;
@property (nonatomic,assign) DraggingType type;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *subtitle;

@end
