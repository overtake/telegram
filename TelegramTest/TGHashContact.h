//
//  TGContact.h
//  Telegram
//
//  Created by keepcoder on 28.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGHashContact : NSObject

@property (nonatomic,assign) int user_id;

@property (nonatomic,strong,readonly) NSString *hashObject;

-(id)initWithHash:(NSString *)hash;
-(id)initWithHash:(NSString *)hash user_id:(int)user_id;

-(TLUser *)user;

@end
