//
//  DatacenterArchiver.h
//  Messenger for Telegram
//
//  Created by keepcoder on 06.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatacenterArchiver : NSObject<NSCoding>

@property (nonatomic,strong) NSArray *options;

-(id)initWithOptions:(NSArray *)options;
@end
