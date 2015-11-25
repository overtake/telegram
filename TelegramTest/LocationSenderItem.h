//
//  LocationSenderItem.h
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"
#import <CoreLocation/CoreLocation.h>
@interface LocationSenderItem : SenderItem

-(id)initWithCoordinates:(CLLocationCoordinate2D)coordinates conversation:(TL_conversation *)conversation additionFlags:(int)additionFlags;

@end
