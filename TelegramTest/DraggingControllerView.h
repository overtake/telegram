//
//  DraggingControllerView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 05.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"



@interface DraggingControllerView : TMView

typedef enum {
    DraggingTypeMultiChoose,
    DraggingTypeSingleChoose
} DraggingViewType;

+ (DraggingControllerView *)view;

+(void)setType:(DraggingViewType)type;

@end
