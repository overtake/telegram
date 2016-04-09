//
//  TGLocationRequest.m
//  Telegram
//
//  Created by keepcoder on 25/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGLocationRequest.h"
#import "Reachability.h"
@interface TGLocationRequest ()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,copy) void (^successCallback)(CLLocation *location);
@property (nonatomic,copy) void (^errorCallback)(NSString *error);

@property (nonatomic,strong) Reachability *reachability;



@end

@implementation TGLocationRequest


-(instancetype)init {
    if(self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    
    return self;
}

//static ASQueue *locationQueue;
//
//+(void)initialize {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        locationQueue = [[ASQueue alloc] initWithName:"LocationRequestQueue"];
//    });
//}


-(void)startRequestLocation:(void (^)(CLLocation *location))successCallback failback:(void (^)(NSString *error))errorCallback {
    [self startRequestLocation:successCallback failback:errorCallback timeout:0];
}

-(void)startRequestLocation:(void (^)(CLLocation *location))successCallback failback:(void (^)(NSString *error))errorCallback timeout:(int)timeout {
    
    _successCallback = [successCallback copy];
    _errorCallback = [errorCallback copy];
    
    if([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
            [_locationManager startUpdatingLocation];
            break;
            
        case kCLAuthorizationStatusDenied:
            if(_errorCallback)
                _errorCallback(NSLocalizedString(@"LocationService.LocationAreDenied", nil));
             [self clear];
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            [_locationManager startUpdatingLocation];
            break;
            
        case kCLAuthorizationStatusRestricted:
            if(_errorCallback)
                _errorCallback(NSLocalizedString(@"LocationService.LocationAreRestricted", nil));
             [self clear];
            break;
            
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(_errorCallback) {
        
        _reachability = [Reachability reachabilityForLocalWiFi];
        [_reachability startNotifier];
            
        
            _errorCallback(NSLocalizedString(error.code == 0 ? NSLocalizedString(@"LocationService.WifiDisabledError", nil) : @"LocationService.UndefinedError", nil));
        [self clear]; 
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.lastObject;
    
    if(location) {
        
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        
        if (self.successCallback != nil)
            self.successCallback(location);
    }
    
}

-(void)clear {
    _successCallback = nil;
    _errorCallback = nil;
    
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _locationManager = nil;
}

-(void)dealloc {
    
}


@end
