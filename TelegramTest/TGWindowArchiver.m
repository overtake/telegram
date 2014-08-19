
//
//  TGWindowArchiver.m
//  Telegram
//
//  Created by keepcoder on 05.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGWindowArchiver.h"

@implementation TGWindowArchiver


- (id)initWithName:(NSString *)name {
    if(self = [super init]) {
        _requiredName = name;
    }
    
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.size = [[aDecoder decodeObjectForKey:@"size"] sizeValue];
        self.origin = [[aDecoder decodeObjectForKey:@"origin"] pointValue];
        _requiredName = [aDecoder decodeObjectForKey:@"name"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithSize:self.size] forKey:@"size"];
    [aCoder encodeObject:[NSValue valueWithPoint:self.origin] forKey:@"origin"];
    [aCoder encodeObject:self.requiredName forKey:@"name"];
}

+(TGWindowArchiver *)find:(NSString *)name {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSData *data = [user objectForKey:[@"window_saver_" stringByAppendingString:name]];
    
    TGWindowArchiver *archiver;
    
    if(data) {
        archiver = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return archiver;
}

- (void)save {
    
    if(self.requiredName.length == 0)
        [NSException exceptionWithName:@"TGWindiwArchiver error" reason:@"expect {requiredName}" userInfo:nil];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    [user setObject:data forKey:[@"window_saver_" stringByAppendingString:self.requiredName]];
    [user synchronize];
}


@end
