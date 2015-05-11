//
//  MessageTableCellGeoView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellGeoView.h"
#import "UIImageView+AFNetworking.h"


@interface MessageTableCellGeoView()
@property (nonatomic, strong) NSImageView *geoImageView;
@property (nonatomic,strong) BTRButton *pinButton;
@property (nonatomic,strong) TMTextField *venueField;

@end

@implementation MessageTableCellGeoView

- (NSString *)urlEncoded:(NSString *)stringOld {
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)stringOld,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                    kCFStringEncodingUTF8 );
    
    NSString *string = [NSString stringWithString:(__bridge NSString *)urlString];
    CFRelease(urlString);

    return string;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        self.geoImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 250, 130)];
        __block dispatch_block_t block = ^{
            MessageTableItemGeo *geoItem = (MessageTableItemGeo *)weakSelf.item;
            
            TLUser *user = [[UsersManager sharedManager] find:geoItem.message.from_id];
            
            NSString *fullName = user.fullName ? [weakSelf urlEncoded:user.fullName] : @"";
            
            NSString *path = [NSString stringWithFormat:@"https://maps.google.com/maps?q=Location+(%@)+@%f,%f", fullName,  geoItem.message.media.geo.lat, geoItem.message.media.geo.n_long];
             
            
            open_link(path);
        };
        [self.geoImageView setWantsLayer:YES];
        [self.geoImageView.layer setCornerRadius:3];
        [self.geoImageView.layer setBorderWidth:0.5];
        [self.geoImageView.layer setBorderColor:NSColorFromRGB(0xcecece).CGColor];
        [self.geoImageView setCallback:block];
        [self.containerView addSubview:self.geoImageView];
        
        _pinButton = [[BTRButton alloc] initWithFrame:CGRectZero];
        [_pinButton setFrameSize:image_MessageMapPin().size];
        [_pinButton setCenterByView:self.geoImageView];
        [_pinButton setBackgroundImage:image_MessageMapPin() forControlState:BTRControlStateNormal];
        //[button setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
        [_pinButton addBlock:^(BTRControlEvents events) {
            block();
        } forControlEvents:BTRControlEventClick];
        [self.containerView addSubview:_pinButton];
        
        
        _venueField = [TMTextField defaultTextField];
    
        
        [self.containerView addSubview:_venueField];
    
        [_venueField setFrameOrigin:NSMakePoint(70, 3)];
        
        [[_venueField cell] setTruncatesLastVisibleLine:YES];
    }
    return self;
}

- (void) setItem:(MessageTableItemGeo *)item {
    [super setItem:item];
    
    [_geoImageView setFrameSize:item.imageSize];
    
    [_pinButton setCenterByView:_geoImageView];
    
    [_geoImageView setImageWithURL:item.geoUrl];
    
    [_pinButton setHidden:[item.message.media isKindOfClass:[TL_messageMediaVenue class]]];
    
    [_venueField setHidden:![item.message.media isKindOfClass:[TL_messageMediaVenue class]]];
    
    [_venueField setAttributedStringValue:item.venue];
    
    [_venueField setFrameSize:item.blockSize];
}


@end
