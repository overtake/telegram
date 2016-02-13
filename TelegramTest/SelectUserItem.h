//
//  SelectUserItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectUserItem : TMRowItem



@property (nonatomic, strong,readonly) TLUser *user;

@property (nonatomic, strong, readonly) TLChat *chat;

@property (nonatomic,assign) BOOL isSearchUser;

@property (nonatomic) BOOL isSelected;

-(id)object;


-(BOOL)acceptSearchWithString:(NSString *)searchString;

@end
