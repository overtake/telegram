//
//  TGDatabase.h
//  Telegram
//
//  Created by keepcoder on 05.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
@interface TGDatabase : NSObject
{
    FMDatabaseQueue *queue;
}

-(void)open:(void (^)())completeHandler;
-(void)drop:(void (^)())completeHandler;


+(NSString *)path;

+(TGDatabase *)manager;

+(void)setManager:(id)manager;

+(void)dbSetKey:(NSString *)key;
+(void)dbRekey:(NSString *)rekey;


+(void)setMasterdatacenter:(int)dc_id;
+(int)masterdatacenter;

@end
