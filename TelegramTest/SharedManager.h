//
//  SharedManager.h
//  TelegramTest
//
//  Created by keepcoder on 21.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TL.h"
#import "ASQueue.h"
@interface SharedManager : NSObject {
    NSMutableArray *list;
    NSMutableDictionary *keys;
}

@property (nonatomic,strong,readonly) ASQueue *queue;

-(id)initWithQueue:(ASQueue *)queue;

-(void)drop;
+(void)drop;
-(void)save:(id)object;
+(instancetype)sharedManager;
-(id)find:(NSInteger)_id;
-(id)find:(NSInteger)_id withCustomKey:(NSString*)key;
-(void)add:(NSArray *)all;
-(void)add:(NSArray *)all withCustomKey:(NSString*)key;
-(NSArray*)all;
-(void)remove:(NSArray *)all;
-(void)remove:(NSArray*)all withCustomKey:(NSString*)key;
-(void)removeObjectWithKey:(id)key;
-(id)lastItem;

+(void)proccessGlobalResponse:(id)response;


-(NSArray *)searchWithString:(NSString *)search selector:(NSString *)selector;

@end
