//
//  SocialServiceDescription.m
//  Telegram
//
//  Created by keepcoder on 03.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SocialServiceDescription.h"

@implementation SocialServiceDescription

- (id)initWithSocialURL:(NSString *)url item:(MessageTableItem *)tableItem {
    if(self = [super init]) {
        
    }
    
    return self;
}

+(NSString *)idWithURL:(NSString *)url {
    return nil;
}

+(NSRegularExpression *)regularExpression {
    return nil;
}

-(NSImage *)centerImage {
    return nil;
}

@end