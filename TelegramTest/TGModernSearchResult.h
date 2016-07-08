//
//  TGModernSearchResult.h
//  Telegram
//
//  Created by keepcoder on 07/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGModernSearchResult : NSObject
@property (nonatomic,strong) NSArray *usersAndChats;
@property (nonatomic,strong) NSArray *globalUsers;
@property (nonatomic,strong) NSArray *messages;
@property (nonatomic,strong) NSArray *hashtags;
@end
