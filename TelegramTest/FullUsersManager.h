//
//  FullUsersManager.h
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SharedManager.h"

@interface FullUsersManager : SharedManager


-(void)loadUserFull:(TLUser *)user callback:(void (^)(TL_userFull *userFull))callback;

@end
