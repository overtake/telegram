//
//  DatacenterArchiver.m
//  Messenger for Telegram
//
//  Created by keepcoder on 06.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DatacenterArchiver.h"

@implementation DatacenterArchiver

-(id)initWithOptions:(NSArray *)options {
    if(self = [super init]) {
        self.options = options;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.options = [aDecoder decodeObjectForKey:@"options"];
    }
    return self;
}

-(BOOL)isEqualTo:(DatacenterArchiver *)object {
    for (NSDictionary *option in object.options) {
        BOOL current = NO;
        for (NSDictionary *archivedOption in self.options) {
            if([option[@"dc_id"] intValue] == [archivedOption[@"dc_id"] intValue]) {
                current = [option[@"port"] intValue] == [archivedOption[@"port"] intValue] && [option[@"ip_address"] isEqualToString:archivedOption[@"ip_address"]];
            }
        }
        if(!current)
            return NO;
    }
    
    return YES;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.options forKey:@"options"];
}

@end
