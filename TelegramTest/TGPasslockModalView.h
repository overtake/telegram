//
//  TGPasslockModalView.h
//  Telegram
//
//  Created by keepcoder on 23.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGPasslockModalView : TMView


typedef enum {
 
    TGPassLockViewConfirmType,
    TGPassLockViewCreateType,
    TGPassLockViewChangeType
} TGPassLockViewType;

@property (nonatomic,assign) TGPassLockViewType type;
@property (nonatomic,copy) passlockCallback passlockResult;
@property (nonatomic,assign,getter=isClosable) BOOL closable;

@end
