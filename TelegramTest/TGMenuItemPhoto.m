//
//  TGMenuItemPhoto.m
//  Telegram
//
//  Created by keepcoder on 12.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGMenuItemPhoto.h"
#import "TMAvatarImageView.h"
#import "TMAvaImageObject.h"

@interface TGMenuItemPhoto ()<TGImageObjectDelegate>

@end

@implementation TGMenuItemPhoto

-(id)initWithUser:(TLUser *)user menuItem:(NSMenuItem *)menuItem {
    if(self = [super init]) {
        _user = user;
        _menuItem = menuItem;
        
        [self generatePhoto];
        
    }
    
    return self;
}

static NSImage *mentionCap() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 30, 30);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0xffffff) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        
        [image unlockFocus];
    });
    return image;//image_VideoPlay();
}

-(void)generatePhoto {
    
    
    
    self.imageObject = [[TMAvaImageObject alloc] initWithLocation:_user.photo.photo_small];
    
    self.imageObject.delegate = self;
    
    self.imageObject.imageSize = NSMakeSize(30, 30);
    
    NSImage *image = [TGCache cachedImage:self.imageObject.cacheKey];
    
    
    if(!image) {
        
        if([_user.photo isKindOfClass:[TL_userProfilePhoto class]]) {
            self.menuItem.image = mentionCap();
            [self.imageObject initDownloadItem];
        } else {
            
            int colorMask = [TMAvatarImageView colorMask:_user];
            
            NSString *text = [TMAvatarImageView text:_user];
            
            image = [TMAvatarImageView generateTextAvatar:colorMask size:NSMakeSize(30, 30) text:text type: TMAvatarTypeUser font:TGSystemFont(12) offsetY:2];
            
            self.menuItem.image = image;
        }
        
    } else
        self.menuItem.image = image;
    
    
    
}

-(void)didDownloadImage:(NSImage *)image object:(id)object {
    
    
    _menuItem.highlightedImage = image;
    _menuItem.image = image;
    
    
}



@end
