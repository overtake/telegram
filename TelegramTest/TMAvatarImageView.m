//
//  TMAvatarImageView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/17/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMAvatarImageView.h"
#import "TMImageUtils.h"

#import "TLFileLocation+Extensions.h"
#import "DownloadQueue.h"
#import "DialogTableItemView.h"
#import "DownloadPhotoItem.h"
#define INIT_HASH_CHEKER() __block NSUInteger hash = self.currentHash;
#define HASH_CHECK() if(self.currentHash != hash) return;
#import <CommonCrypto/CommonDigest.h>
#import <openssl/md5.h>
#import "ImageUtils.h"
#import "TGCache.h"
#import "TMAvaImageObject.h"



typedef struct
{
    int top;
    int bottom;
} TGTwoColors;


static const TGTwoColors colors[] = {
    { .top = 0xec6a5e, .bottom = 0xec6a5e },
    { .top = 0xf4d447, .bottom = 0xf4d447 },
    { .top = 0x7ccd52, .bottom = 0x7ccd52 },
    { .top = 0x66aee4, .bottom = 0x66aee4 },
    { .top = 0xc789e1, .bottom = 0xc789e1 },
    { .top = 0xffaf51, .bottom = 0xffaf51 },
};

@interface TMAvatarImageView()<TGImageObjectDelegate>
@property (nonatomic, strong) DownloadPhotoItem *downloadItem;
@property (nonatomic, strong) DownloadEventListener *downloadListener;
@property (nonatomic) NSUInteger currentHash;
@property (nonatomic) TMAvatarType type;
@property (nonatomic) BOOL isNeedPlaceholder;
@property (nonatomic,strong) NSImage *placeholder;
@property (nonatomic,strong) TMAvaImageObject *imageObject;

@end

@implementation TMAvatarImageView

+ (NSImage *) placeholderImageBySize:(NSSize)size andColor:(NSColor *)color {
    
    static NSMutableDictionary *placeHolderCache;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeHolderCache = [[NSMutableDictionary alloc] init];
    });
    
    NSImage *image = placeHolderCache[NSStringFromSize(size)];
    
    if(!image) {
        image = [[NSImage alloc] initWithSize:size];
        [image lockFocus];
        [color set];
        NSRectFill(NSMakeRect(0, 0, size.width, size.height));
        [image unlockFocus];
        
        image = [TMImageUtils roundedImage:image size:size];
        
        [placeHolderCache setObject:image forKey:NSStringFromSize(size)];
    }
    
    return image;
}

+ (instancetype)standartTableAvatar {
    TMAvatarImageView *avatarImageView = [[self alloc] initWithFrame:NSMakeRect(10, roundf((DIALOG_CELL_HEIGHT - 50) / 2.0), 50, 50)];
    avatarImageView.placeholder = [TMAvatarImageView placeholderImageBySize:avatarImageView.frame.size andColor:NSColorFromRGB(0xfafafa)];
    [avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:18]];
    return avatarImageView;
}

+ (instancetype)standartNewConversationTableAvatar {
    TMAvatarImageView *avatarImageView = [[self alloc] initWithFrame:NSMakeRect(10, roundf((60 - 44) / 2.0), 44, 44)];
    avatarImageView.placeholder = [TMAvatarImageView placeholderImageBySize:avatarImageView.frame.size andColor:NSColorFromRGB(0xfafafa)];
    [avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:18]];
    return avatarImageView;
}

+ (instancetype)standartMessageTableAvatar {
    TMAvatarImageView *avatarImageView = [[self alloc] initWithFrame:NSMakeRect(0, 0, 36, 36)];
    avatarImageView.placeholder = [TMAvatarImageView placeholderImageBySize:avatarImageView.frame.size andColor:NSColorFromRGB(0xfafafa)];
    [avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [avatarImageView setOffsetTextY:2];
    return avatarImageView;
}

+ (instancetype) standartUserInfoAvatar {
    TMAvatarImageView *avatarImageView = [[self alloc] initWithFrame:NSMakeRect(0, 0, 130, 130)];
    avatarImageView.placeholder = [TMAvatarImageView placeholderImageBySize:avatarImageView.frame.size andColor:NSColorFromRGB(0xfafafa)];
    [avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:30]];
    return avatarImageView;
}

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id) init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(NSRect)frame layerHosted:(BOOL)hostsLayer {
    self = [super initWithFrame:frame layerHosted:hostsLayer];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id) initWithImage:(NSImage *)image {
    self = [super initWithImage:image];
    if(self) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    [Notification addObserver:self selector:@selector(notificationUserChange:) name:USER_UPDATE_PHOTO];
    [Notification addObserver:self selector:@selector(notificationUserChange:) name:USER_UPDATE_NAME];

    [Notification addObserver:self selector:@selector(notificationChatChange:) name:CHAT_UPDATE_PHOTO];
    [Notification addObserver:self selector:@selector(notificationChatChange:) name:CHAT_UPDATE_TITLE];

    self.font = [NSFont fontWithName:@"HelveticaNeue" size:12];
    self.isNeedPlaceholder = YES;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [TGCache setMemoryLimit:5*1024*1024 group:AVACACHE];
    });
}

-(void)didDownloadImage:(NSImage *)image object:(TMAvaImageObject *)object {
    
    if([self.imageObject.location isEqualTo:object.location]) {
        self.image = image;
    }
    
}

- (void) dealloc {
    [Notification removeObserver:self];
}

- (void) notificationUserChange:(NSNotification *)notification {
    if(self.type == TMAvatarTypeUser) {
        TLUser *user = [notification.userInfo objectForKey:KEY_USER];
        
        if(self.user.n_id == user.n_id) {
            
            BOOL rebuild = NO;
            
            if([user.photo isKindOfClass:[TL_userProfilePhotoEmpty class]]) {
                rebuild = ![self.text isEqualToString:[NSString stringWithFormat:@"%C", (unichar)(user.fullName.length > 0 ? [user.fullName characterAtIndex:0] : 0)]];
            } else {
                rebuild = self.fileLocation.hashCacheKey != user.photo.photo_small.hashCacheKey;
            }
            
            if(rebuild) {
                self->_user = nil;
                self.isNeedPlaceholder = NO;
                [self setUser:user animated:YES];
                self.isNeedPlaceholder = YES;
            }
        }
    }
}

- (void) notificationChatChange:(NSNotification *)notification {
    if(self.type == TMAvatarTypeChat) {
        TLChat *chat = [notification.userInfo objectForKey:KEY_CHAT];
        if(self.chat.n_id == chat.n_id) {
            BOOL rebuild = NO;
            
            if([chat.photo isKindOfClass:[TL_chatPhotoEmpty class]]) {
                rebuild = ![self.text isEqualToString:[NSString stringWithFormat:@"%C", (unichar)(chat.title.length > 0 ? [chat.title characterAtIndex:0] : 0)]];
            } else {
                rebuild = self.fileLocation.hashCacheKey != chat.photo.photo_small.hashCacheKey;
            }
            
            if(rebuild) {
                DLog(@"rebuild chat photo true");
                self->_chat = nil;
                self.isNeedPlaceholder = NO;
                [self setChat:chat animated:YES];
                self.isNeedPlaceholder = YES;
            } else {
                DLog(@"rebuild chat photo false");
            }
        }
    }
}


- (void) setUser:(TLUser *)user {
    [self setUser:user animated:NO];
}

- (void) setUser:(TLUser *)user animated:(BOOL)animated {
    if(self.user.n_id == user.n_id)
        return;
    
    self->_chat = nil;
    self->_user = user;
    self->_text = nil;
    self->_broadcast = nil;
    self.type = TMAvatarTypeUser;
    self.fileLocation = user.photo.photo_small;
    self.imageObject = [[TMAvaImageObject alloc] initWithLocation:self.fileLocation placeHolder:self.placeholder sourceId:user.n_id];
    self.imageObject.delegate = self;
    self.imageObject.imageSize = self.frame.size;
    [self rebuild:animated];
}

- (void) setChat:(TLChat *)chat {
    [self setChat:chat animated:NO];
}


- (void) setChat:(TLChat *)chat animated:(BOOL)animated {
    if(self.chat.n_id == chat.n_id)
        return;
    
    self->_user = nil;
    self->_chat = chat;
    self->_text = nil;
    self->_broadcast = nil;
    self.type = TMAvatarTypeChat;
    self.fileLocation = chat.photo.photo_small;
    self.imageObject = [[TMAvaImageObject alloc] initWithLocation:self.fileLocation placeHolder:self.placeholder sourceId:chat.n_id];
    self.imageObject.delegate = self;
    self.imageObject.imageSize = self.frame.size;
    [self rebuild:animated];
}

- (void)setBroadcast:(TL_broadcast *)broadcast {
    if(self.broadcast.n_id == broadcast.n_id)
        return;
    
    self->_user = nil;
    self->_chat = nil;
    self->_text = nil;
    
    self->_broadcast = broadcast;
    
    self.type = TMAvatarTypeBroadcast;
    _fileLocation = nil;
    
    [self rebuild:NO];
}

- (void) setText:(NSString *)text {
    if([self.text isEqualToString:text])
        return;
    
    self->_text = text;
    self->_user = nil;
    self->_chat = nil;
    self->_broadcast = nil;
    self.type = TMAvatarTypeText;
    _fileLocation = nil;
    [self rebuild:NO];
}

static CAAnimation *ani() {
    static CAAnimation *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.duration = .2;
    });
    return animation;
}
static CAAnimation *ani2() {
    static CAAnimation *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.duration = .0;
    });
    return animation;
}


- (void) rebuild:(BOOL)animated {
    
    [self removeAnimationForKey:@"contents"];
    
    
    if(self.type == TMAvatarTypeUser && self.user.n_id == 777000 && self.bounds.size.width == 50.0f) {
        self.image = image_TelegramNotifications();
        self.image.size = NSMakeSize(50.0f, 50.0f);
        return;
    }
    
    if(self.fileLocation) {
        self.currentHash = [self.fileLocation hashCacheKey];
    } else {
        _text = [TMAvatarImageView text:self.chat ? self.chat : (self.broadcast ? self.broadcast : self.user)];
        self.currentHash = [self.text hash];
    }
    
    __block NSString *key = [NSString stringWithFormat:@"%lu:%@",self.currentHash,NSStringFromSize(self.bounds.size)];
    
    

    NSImage *image = [TGCache cachedImage:key group:@[AVACACHE]];
    if(image) {
        if(animated)
            [self addAnimation:ani() forKey:@"contents"];
    
        self.image = image;
        return;
    }


    self.image = self.placeholder;
    
    if(self.fileLocation) {
        
        [self.imageObject initDownloadItem];
        
    } else {
        
        
        int colorMask = [TMAvatarImageView colorMask:self.type == TMAvatarTypeChat ? self.chat : (self.type == TMAvatarTypeBroadcast ? self.broadcast : self.user)];

        
         __block NSString *text = self->_text;
        
        [ASQueue dispatchOnStageQueue:^{
            
            __block NSImage *image = [TMAvatarImageView generateTextAvatar:colorMask size:self.bounds.size text:text type:self.type font:self.font offsetY:self.offsetTextY];
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                    
                [TGCache cacheImage:image forKey:key groups:@[AVACACHE]];
                    
                if(animated)
                    [self addAnimation:ani() forKey:@"contents"];
                    
                self.image = (BTRImage *) image;
            }];
            
        }];
    }
}

+(NSString *)text:(NSObject *)object {
    
    NSString *text;
    
    
    if([object isKindOfClass:[TLUser class]]) {
        if([[object valueForKey:@"first_name"] length] == 0 && [[object valueForKey:@"last_name"] length] == 0) {
            text = [NSString stringWithFormat:@"A"];
        } else {
            text = [NSString stringWithFormat:@"%C%C", (unichar)([[object valueForKey:@"first_name"] length] ? [[object valueForKey:@"first_name"] characterAtIndex:0] : 0), (unichar)([[object valueForKey:@"last_name"] length] ? [[object valueForKey:@"last_name"] characterAtIndex:0] : 0)];
        }
        
    } else if([object isKindOfClass:[TLChat class]]) {
        text = [NSString stringWithFormat:@"%C", (unichar)([[object valueForKey:@"title"] length] > 0 ? [[object valueForKey:@"title"] characterAtIndex:0] : [[object valueForKey:@"n_id"] intValue])];
                                                           
    } else if([object isKindOfClass:[TL_broadcast class]]) {
        if([[object valueForKey:@"title"] length] > 0 ) {
            text = [NSString stringWithFormat:@"%C", (unichar)([[object valueForKey:@"title"] characterAtIndex:0])];
        } else {
            text = [NSString stringWithFormat:@"%d",[[object valueForKey:@"n_id"] intValue]];
        }
    }
    
    return text;
}

+(int)colorMask:(NSObject *)object {
    
    
    int uid = [[object valueForKey:@"n_id"] intValue];
    
    __block int colorMask = 0;
    
    
    static NSMutableDictionary *cacheColorIds;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheColorIds = [[NSMutableDictionary alloc] init];
    });
    
    
    if(cacheColorIds[@(uid)]) {
        colorMask = [cacheColorIds[@(uid)] intValue];
    } else {
        const int numColors = 8;
        
        if(uid != -1) {
            char buf[16];
            snprintf(buf, 16, "%d%d", uid, [UsersManager currentUserId]);
            unsigned char digest[CC_MD5_DIGEST_LENGTH];
            CC_MD5(buf, (unsigned) strlen(buf), digest);
            colorMask = ABS(digest[ABS(uid % 16)]) % numColors;
        } else {
            colorMask = -1;
        }
        
        cacheColorIds[@(uid)] = @(colorMask);
    }
    
    return colorMask;
    

}

+ (NSImage *)generateTextAvatar:(int)colorMask size:(NSSize)size text:(NSString *)text type:(TMAvatarType)type font:(NSFont *)font offsetY:(int)offset {
    
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    
    
    TGTwoColors twoColors;
    
    
    twoColors = colors[colorMask % (sizeof(colors) / sizeof(colors[0]))];
    
    
    if(colorMask != -1) {
        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        
        
        
        CGColorRef colors[2] = {
            CGColorRetain(NSColorFromRGB(twoColors.bottom).CGColor),
            CGColorRetain(NSColorFromRGB(twoColors.top).CGColor)
        };
        
        CFArrayRef colorsArray = CFArrayCreate(kCFAllocatorDefault, (const void **)&colors, 2, NULL);
        CGFloat locations[2] = {0.0f, 1.0f};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, (CGFloat const *)&locations);
        
        CFRelease(colorsArray);
        CFRelease(colors[0]);
        CFRelease(colors[1]);
        
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, size.height), 0);
        
        CFRelease(gradient);
    }

    if(type != TMAvatarTypeBroadcast) {
        NSColor *color = [NSColor whiteColor];
        text = [text uppercaseString];
        
        if(colorMask == -1) {
            NSBezierPath *path = [NSBezierPath bezierPath];
            
            [path appendBezierPathWithArcWithCenter: NSMakePoint(image.size.width/2, image.size.height/2)
                                             radius: roundf(image.size.width/2)
                                         startAngle: 0
                                           endAngle: 360 clockwise:NO];
            [path setLineWidth:2];
            [NSColorFromRGB(0x999999) set];
            [path stroke];
            
            
            color = NSColorFromRGB(0x999999);
        }
        
        NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color};
        NSSize textSize = [text sizeWithAttributes:attributes];
        [text drawAtPoint: NSMakePoint(roundf( (size.width- textSize.width) * 0.5 ),roundf( (size.height - textSize.height) * 0.5 + offset) )withAttributes: attributes];

    } else {
        static NSImage *smallAvatar;
        
        static NSImage *largeAvatar;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            smallAvatar = [NSImage imageNamed:@"BroadcastAvatarIcon"];
            largeAvatar = [NSImage imageNamed:@"BroadcastLargeAvatarIcon"];
        });
        
        NSImage *img = size.width > 50.0 ? largeAvatar : smallAvatar;
        
        
        [img drawInRect:NSMakeRect(roundf( (size.width - img.size.width) * 0.5 ),roundf( (size.height - img.size.height) * 0.5 ), img.size.width, img.size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
    }
    
    
    [image unlockFocus];
    
    image = [TMImageUtils roundedImageNew:image size:size];
    return image;
}

-(void)setImage:(NSImage *)image {
    [super setImage:image];
}

- (void) mouseDown:(NSEvent *)theEvent {
    if(self.tapBlock)
        self.tapBlock();
    else
        [super mouseDown:theEvent];
}

@end
