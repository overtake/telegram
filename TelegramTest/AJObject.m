//
//  BRSObject.m
//  Brain
//
//  Created by keepcoder on 24.05.15.
//
//

#import "AJObject.h"

@implementation AJObject

-(id)initWithJson:(NSDictionary *)json {
    if(self = [super init]) {
        
        NSArray *allProperty = [self allPropertyNames];
        
        __block BOOL fillObject = YES;
        
        [allProperty enumerateObjectsUsingBlock:^(NSString *propertyName, NSUInteger idx, BOOL *stop) {
            
            SEL selector = NSSelectorFromString(propertyName);
            
            if([self respondsToSelector:selector])
                [self setValue:[json objectForKey:propertyName] forKey:propertyName];
            else {
                *stop = YES;
                fillObject = NO;
            }
            
        }];
        
        if(!fillObject)
            return nil;
        
    }
    
    return self;
}





@end
