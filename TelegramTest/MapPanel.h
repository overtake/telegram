//
//  MapPanel.h
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>

@interface TMMapView : MKMapView

@end

@interface TMAnnotation : NSObject<MKAnnotation>

@end

@interface MapPanel : NSPanel

+ (MapPanel *)sharedPanel;

-(void)update;

@end
