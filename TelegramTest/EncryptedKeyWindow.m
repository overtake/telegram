//
//  EncryptedKeyWindow.m
//  Messenger for Telegram
//
//  Created by keepcoder on 08.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "EncryptedKeyWindow.h"
#import "ImageUtils.h"
#import "Crypto.h"
#import "NS(Attributed)String+Geometrics.h"
@interface EncryptedKeyWindow ()
@property (nonatomic,strong) NSImageView *imageView;
@property (nonatomic,strong) TMHyperlinkTextField *textField;
@end

@implementation EncryptedKeyWindow

-(id)init {
    if(self = [super initWithContentRect:NSMakeRect(400, 400, 700, 330)
                               styleMask:NSClosableWindowMask|NSTitledWindowMask
                                 backing:NSBackingStoreBuffered
                                   defer:YES]) {
        
        TMView *bg = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
        [bg setBackgroundColor:NSColorFromRGB(0xffffff)];
        [self.contentView addSubview:bg];
        
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(roundf((self.frame.size.height-264)/2), roundf((self.frame.size.height-264)/2), 264, 264)];
        [self.contentView addSubview:self.imageView];
        
        self.textField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(self.imageView.frame.size.width+self.imageView.frame.origin.x + 40, self.imageView.frame.origin.y, 300, 264)];
        
       [self.textField setAlignment:NSCenterTextAlignment];
        
        self.textField.url_delegate = self;
        
        [self.textField setFont:TGSystemFont(14)];
        
        [self.textField setEditable:NO];
        [self.textField setSelectable:NO];
        [self.textField setBordered:NO];
        self.textField.hardYOffset = 25.0f;
        [self.contentView addSubview:self.textField];
        
       
        self.title = NSLocalizedString(@"EncryptionKey.EncryptionKey", nil);
    }
    
    return self;
}



+(EncryptedKeyWindow *)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end
