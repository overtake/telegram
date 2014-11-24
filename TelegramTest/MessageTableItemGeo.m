//
//  MessageTableItemGeo.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemGeo.h"

@implementation MessageTableItemGeo

- (id) initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        
        TLGeoPoint *geoPoint = object.media.geo;
        self.geoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true", geoPoint.lat,  geoPoint.n_long, [NSScreen mainScreen].backingScaleFactor == 2 ? @"500x260" : @"250x130"]];
        
        self.blockSize = NSMakeSize(250, 130);
    }
    return self;
}

@end
