
//  MapPanel.m
//  Telegram

//  Created by Mikhail Filimonov on 6/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MapPanel.h"
#import <MapKit/MapKit.h>
#import "Reachability.h"
@interface TMAnnotation ()
@property (nonatomic,assign) CLLocationCoordinate2D mainCoordinates;
@end

@implementation TMAnnotation



-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.mainCoordinates = newCoordinate;
}

-(CLLocationCoordinate2D)coordinate {
    return self.mainCoordinates;
}

-(NSString *)title {
    return NSLocalizedString(@"Annotation", nil);
}

@end


@interface TMMapView ()
@property (nonatomic,strong) TMAnnotation *currentAnnotation;

@end

@implementation TMMapView 

-(void)mouseUp:(NSEvent *)theEvent {
    
    if(theEvent.clickCount == 2) {
        CGPoint touchPoint = [theEvent locationInWindow];
        
        [self removeAnnotation:self.currentAnnotation];
        
        
        
        CLLocationCoordinate2D touchMapCoordinate = [self convertPoint:touchPoint toCoordinateFromView:nil];
        
        id <MKAnnotation> annotation = [[TMAnnotation alloc] init];
        
        annotation.coordinate = touchMapCoordinate;
        
        
        self.currentAnnotation = annotation;
        
        [self addAnnotation:annotation];
        
        
        
        
        return;

    }
    
    [super mouseUp:theEvent];
}

@end


@interface MapPanel()<MKMapViewDelegate>
@property (nonatomic, strong) TMView *view;
@property (nonatomic,strong) TMMapView *mapView;
@property (nonatomic,strong) TMView *backgroundView;
@property (nonatomic,strong) NSProgressIndicator *progressView;

@property (nonatomic,strong) TMView *controlView;
@property (nonatomic,assign) BOOL isFindUser;
@property (nonatomic,strong) TMTextField *textField;
@end

@implementation MapPanel

+ (MapPanel *)sharedPanel {
    static MapPanel *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MapPanel alloc] init];
        [instance setReleasedWhenClosed:NO];
    });
    return instance;
}

- (void)orderOut:(id)sender {
    [super orderOut:sender];
    
    self.mapView.showsUserLocation = NO;
    
    [((AppDelegate *)[NSApp delegate]).window endSheet:self];
}

- (id)init {
    self = [super init];
    if(self) {
        [self setFrame:NSMakeRect(0, 0, 400, 400) display:NO];
        self.view = [[TMView alloc] initWithFrame:self.frame];
        self.contentView = self.view;
        
        _textField = [TMTextField defaultTextField];
        
        int controlHeight = 40;
        
        
        NSRect mainRect = NSMakeRect(0, controlHeight, NSWidth(self.frame), NSHeight(self.frame)-controlHeight);
        
        self.mapView = [[TMMapView alloc] initWithFrame:mainRect];
        [self.mapView setMapType:MKMapTypeStandard];
        [self.mapView setZoomEnabled:YES];
        [self.mapView setScrollEnabled:YES];
        
        [self.mapView setMapType:MKMapTypeStandard];
        self.mapView.showsZoomControls = YES;
        
        
        self.controlView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), controlHeight)];
        
        self.controlView.backgroundColor = NSColorFromRGB(0xffffff);
        [self.view addSubview:self.controlView];
        
        
        weak();
        [self.controlView setDrawBlock:^ {
           [GRAY_BORDER_COLOR set];
            NSRectFill(NSMakeRect(0, NSHeight(weakSelf.controlView.frame)-1, NSWidth(weakSelf.controlView.frame), 1));
        }];
        
        
        BTRButton *sendButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(self.controlView.frame) - 70, (controlHeight - 17) / 2, 50, 20)];
        
        [sendButton setTitle:NSLocalizedString(@"Message.Send", nil) forControlState:BTRControlStateNormal];
      
        
        [sendButton addBlock:^(BTRControlEvents events) {
            
            [self sendCoordinates];
            
        } forControlEvents:BTRControlEventClick];
        
        
        BTRButton *cancelButton = [[BTRButton alloc] initWithFrame:NSMakeRect(20, (controlHeight - 17) / 2, 60, 20)];
        
        [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
        
        [cancelButton addBlock:^(BTRControlEvents events) {
            
            [self close];
            
        } forControlEvents:BTRControlEventClick];
        
        [cancelButton setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateHover];
        [sendButton setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateHover];
        
        [sendButton setTitleFont:TGSystemFont(13) forControlState:BTRControlStateNormal];
        [cancelButton setTitleFont:TGSystemFont(13) forControlState:BTRControlStateNormal];
        
        
        [cancelButton setTitleColor:BLUE_UI_COLOR forControlState:BTRControlStateNormal];
        [cancelButton setTitleColor:NSColorFromRGB(0x467fb0) forControlState:BTRControlStateHover];
        
        [sendButton setTitleColor:BLUE_UI_COLOR forControlState:BTRControlStateNormal];
        [sendButton setTitleColor:NSColorFromRGB(0x467fb0) forControlState:BTRControlStateHover];
       
        [self.controlView addSubview:cancelButton];
        [self.controlView addSubview:sendButton];
        
        [self.controlView setBackgroundColor:NSColorFromRGB(0xfdfdfd)];
        
        [self.view addSubview:self.mapView];
        
        
        self.backgroundView = [[TMView alloc] initWithFrame:mainRect];
        
        self.backgroundView.backgroundColor = [NSColor whiteColor];
        
        [self.view addSubview:self.backgroundView];
        
        self.progressView = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        
        [self.progressView setStyle:NSProgressIndicatorSpinningStyle];
        
        [self.progressView setCenterByView:self.backgroundView];
        
        [self.backgroundView addSubview:self.progressView];
        
        [self loadUserLocation];
        
       
       
    }
    return self;
}

- (void)sendCoordinates {
    CLLocationCoordinate2D coordinates;
    if(self.mapView.currentAnnotation) {
        coordinates = self.mapView.currentAnnotation.coordinate;
    } else {
        coordinates = self.mapView.userLocation.coordinate;
    }
    
    if(coordinates.latitude == 0 && coordinates.longitude == 0)
        return;
    
    [[Telegram rightViewController].messagesViewController sendLocation:coordinates forConversation:[Telegram rightViewController].messagesViewController.conversation];
    
    [self close];
    
}


-(void)update {
    
    
    self.mapView.delegate = self;
    
    [self loadUserLocation];
}

-(void)loadUserLocation {
    
    [self.backgroundView setHidden:YES];
    [self.mapView setHidden:NO];
 //   [self.progressView startAnimation:self];
    
    self.mapView.showsUserLocation = YES;
    
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {

}


- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    
}


- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView  {
    
}



- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    
    
    if(_isFindUser)
        return;
    
    _isFindUser = YES;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:NO];
    
    [self.mapView setHidden:NO];
    
    [self.backgroundView setHidden:YES];
    [self.progressView stopAnimation:self];
    
}


@end
