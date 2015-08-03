//
//  NSObject+BObject.m
//  Brain
//
//  Created by keepcoder on 24.05.15.
//
//

#import "NSObject+BObject.h"
#import <objc/runtime.h>


@implementation NSObject (BObject)


- (NSArray *)allPropertyNames
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

- (void *)pointerOfIvarForPropertyNamed:(NSString *)name
{
    objc_property_t property = class_getProperty([self class], [name UTF8String]);
    
    const char *attr = property_getAttributes(property);
    const char *ivarName = strchr(attr, 'V') + 1;
    
    Ivar ivar = object_getInstanceVariable(self, ivarName, NULL);
    
    return (char *)self + ivar_getOffset(ivar);
}


@end
