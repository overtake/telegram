//
//  FullUsersManager.h
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SharedManager.h"

@interface FullUsersManager : SharedManager



-(void)requestUserFull:(TLUser *)user withCallback:(void (^) (TLUserFull *userFull))callback;



@end
