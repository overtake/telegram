//
//  NSObject+BObject.h
//  Brain
//
//  Created by keepcoder on 24.05.15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (BObject)

- (NSArray *)allPropertyNames;
- (void *)pointerOfIvarForPropertyNamed:(NSString *)name;

@end
