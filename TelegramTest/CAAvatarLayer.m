//
//  CAAvatarLayer.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/16/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "CAAvatarLayer.h"

#import "TLFileLocation+Extensions.h"
#import "DownloadQueue.h"

#import "DownloadPhotoItem.h"
#define INIT_HASH_CHEKER() __block NSUInteger hash = self.currentHash;
#define HASH_CHECK() if(self.currentHash != hash) return;
#define HASH_STRONG_CHECK() if(strongSelf.currentHash != hash) return;

typedef enum {
    CAAvatarLayerUser,
    CAAvatarLayerChat,
    CAAvatarLayerText
} CAAvatarLayerType;

@interface CAAvatarLayer()

@property (nonatomic) CAAvatarLayerType type;
@property (nonatomic, strong) TLFileLocation *fileLocation;
@property (nonatomic, strong) NSImage *drawImage;

@property (nonatomic, strong) DownloadPhotoItem *downloadItem;
@property (nonatomic,strong) DownloadEventListener *downloadListener;
@property (nonatomic) NSUInteger currentHash;

@end

@implementation CAAvatarLayer

- (id) initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if(self) {
        self.actions =  [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                         [NSNull null], @"onOrderOut",
                         [NSNull null], @"sublayers",
                         [NSNull null], @"contents",
                         [NSNull null], @"bounds",
                         nil];
        
        self.backgroundColor = [NSColor grayColor].CGColor;
        self.delegate = self;
    }
    return self;
}

+ (id) defaultValueForKey:(NSString *)key {
    return [super defaultValueForKey:key];
}

- (void) setUser:(TLUser *)user {
    self->_user = user;
    self.type = CAAvatarLayerUser;
    self.fileLocation = user.photo.photo_small;
    [self rebuild];
}

- (void) setChat:(TLChat *)chat {
    [self redraw];
    self->_chat = chat;
    self.type = CAAvatarLayerChat;
    self.fileLocation = chat.photo.photo_small;
    [self rebuild];
}

- (void) setText:(NSString *)text {
    if([self.text isEqualToString:text])
        return;
    
    self->_text = text;
    self.type = CAAvatarLayerText;
    self.fileLocation = nil;
    [self rebuild];
}

- (void) rebuild {
    if(self.fileLocation) {
        self.currentHash = [self.fileLocation hashCacheKey];
    
        __block NSNumber *key = [NSNumber numberWithUnsignedInteger:self.currentHash];
        
        if(self.cacheDictionary) {
            NSImage *image = [self.cacheDictionary objectForKey:key];
            if(image) {
                self.drawImage = image;
                [self redraw];
                return;
            }
        }
        
        INIT_HASH_CHEKER();
        
        __block CAAvatarLayer *weakSelf = self;
        
        self.contents = nil;
        
        [self.downloadItem cancel];
        
        self.downloadItem = [[DownloadPhotoItem alloc] initWithObject:self.fileLocation size:0];
        
        self.downloadListener = [[DownloadEventListener alloc] init];
        
        [self.downloadItem addEvent:self.downloadListener];
        
        [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                if(weakSelf.currentHash != hash) return;
                
                if(!item.result) {
                    [weakSelf generateTextImage];
                    return;
                }
                
                NSImage *image = [[NSImage alloc] initWithData:item.result];
                if(!image) {
                    [weakSelf generateTextImage];
                    return;
                }
                
                if(weakSelf.cacheDictionary)
                    [weakSelf.cacheDictionary setObject:image forKey:key];
                
                weakSelf.drawImage = image;
                [weakSelf redraw];
                
                weakSelf.downloadItem = nil;
                weakSelf = nil;
            }];  

        }];
        
        [self.downloadItem start];
        
        
    } else {
        self.currentHash = [[NSString randStringWithLength:8] hash];
        [self generateTextImage];
    }
}

- (void) generateTextImage {
    self.drawImage = nil;
    [self redraw];
}

- (void) redraw {
    self.contents = self.drawImage;
}


- (void) drawInContext:(CGContextRef)ctx {
    
    
    MTLog(@"drow");
}

- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    MTLog(@"draw");
}

@end
