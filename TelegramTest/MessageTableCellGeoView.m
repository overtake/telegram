//
//  MessageTableCellGeoView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellGeoView.h"
#import "TGImageView.h"
#import "TGCTextView.h"
@interface MessageTableCellGeoView()
@property (nonatomic, strong) TGImageView *imageView;
@property (nonatomic,strong) NSImageView *pinView;
@property (nonatomic,strong) TGCTextView *venueField;

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
        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 250, 130)];
        [_imageView setContentMode:BTRViewContentModeScaleAspectFill];
        
        __block dispatch_block_t block = ^{
            MessageTableItemGeo *geoItem = (MessageTableItemGeo *)weakSelf.item;
            
            TLUser *user = [[UsersManager sharedManager] find:geoItem.message.from_id];
            
            NSString *fullName = user.fullName ? [weakSelf urlEncoded:user.fullName] : @"";
            
            NSString *path = [NSString stringWithFormat:@"https://maps.google.com/maps?q=Location+(%@)+@%f,%f", fullName,  geoItem.message.media.geo.lat, geoItem.message.media.geo.n_long];
             
            
            open_link(path);
        };
        
        [_imageView setTapBlock:block];
        
        [_imageView setCornerRadius:4];

        [self.containerView addSubview:_imageView];
        
        _pinView = imageViewWithImage(image_MessageMapPin());
        [_pinView setCenterByView:_imageView];
        
        [_imageView addSubview:_pinView];
        
        _venueField = [[TGCTextView alloc] initWithFrame:NSMakeRect(70, 0, 0, 0)];
        
        
        [self.containerView addSubview:_venueField];
        
    }
    return self;
}

- (void) setItem:(MessageTableItemGeo *)item {
    [super setItem:item];
    
    [_imageView setFrameSize:item.contentSize];
    
    [_pinView setCenterByView:_pinView.superview];
    
    [_imageView setObject:item.imageObject];
    
    [_venueField setHidden:!item.isVenue];
    
    [_venueField setAttributedString:item.venue];
    
    [_venueField setFrameSize:item.venueSize];
    [_venueField setFrameOrigin:NSMakePoint(item.contentSize.width + item.defaultOffset, 0)];
    [_venueField setCenteredYByView:_venueField.superview];
    
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!anim) {
        _venueField.backgroundColor = color;
    } else {
        [_venueField pop_addAnimation:anim forKey:@"background"];
    }
    
    
}


@end
