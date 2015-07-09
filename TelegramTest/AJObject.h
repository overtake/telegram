//
//  BRSObject.h
//  Brain
//
//  Created by keepcoder on 24.05.15.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+BObject.h"
// remote static object

@interface AJObject : NSObject

-(id)initWithJson:(NSDictionary *)json;



- (instancetype)init __attribute__((unavailable("init not available, call initialize: or instance instead")));

+ (instancetype)new __attribute__((unavailable("new not available, call initialize: or instance instead")));

@end
