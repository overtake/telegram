//
//  TGCAActions.m
//  Telegram
//
//  Created by keepcoder on 18/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGCAActions.h"

@implementation TGCAActions

-(void)runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict {
   
}



static TGCAActions *actions;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = [[TGCAActions alloc] init];
    });
}

+(NSDictionary *)defaultActions {
    return  @{
              @"onOrderIn": actions,
              @"onOrderOut": actions,
              @"sublayers": actions,
              @"contents": actions,
              @"bounds": actions,
              @"position": actions,
              @"color": actions,
              @"foregroundColor": actions,
              };
}

@end
