//
//  BroadcastInfoViewController.h
//  Telegram
//
//  Created by keepcoder on 11.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatInfoViewController.h"

@interface BroadcastInfoViewController : ChatInfoViewController


@property (nonatomic,strong) TL_broadcast *broadcast;

-(void)reloadParticipants;
@end
