//
//  SelectUserRowView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowView.h"

@interface SelectUserRowView : TMRowView

@property (nonatomic, strong,readonly) TMNameTextField *titleTextField;
@property (nonatomic,strong,readonly) TMStatusTextField *lastSeenTextField;
- (void)needUpdateSelectType;

@end
