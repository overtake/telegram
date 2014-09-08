//
//  TMAvatarImageView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/17/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMAvatarImageView.h"
#import "TMImageUtils.h"

#import "TGFileLocation+Extensions.h"
#import "DownloadQueue.h"
#import "DialogTableItemView.h"
#import "DownloadPhotoItem.h"
#define INIT_HASH_CHEKER() __block NSUInteger hash = self.currentHash;
#define HASH_CHECK() if(self.currentHash != hash) return;
#import <CommonCrypto/CommonDigest.h>
#import <openssl/md5.h>
#import "ImageUtils.h"
typedef enum {
    TMAvatarTypeUser,
    TMAvatarTypeChat,
    TMAvatarTypeText,
    TMAvatarTypeBroadcast
} TMAvatarType;


typedef struct
{
    int top;
    int bottom;
} TGTwoColors;


static const TGTwoColors colors[] = {
    { .top = 0xff516a, .bottom = 0xff885e },
    { .top = 0xffa85c, .bottom = 0xffcd6a },
    { .top = 0x54cb68, .bottom = 0xa0de7e },
    { .top = 0x2a9ef1, .bottom = 0x72d5fd },
    { .top = 0x6c65f9, .bottom = 0x84b2fd },
    { .top = 0xd575ea, .bottom = 0xe0a8f1 },
};

@interface TMAvatarImageView()
@property (nonatomic, strong) DownloadPhotoItem *downloadItem;
@property (nonatomic, strong,readonly) DownloadEventListener *downloadListener;
@property (nonatomic) NSUInteger currentHash;
@property (nonatomic, strong) NSImage *drawImage;
@property (nonatomic) TMAvatarType type;

@property (nonatomic) BOOL takeBigPhoto;
@property (nonatomic) BOOL isNeedPlaceholder;

@end

@implementation TMAvatarImageView

static NSCache *tableViewCache(NSSize size) {
    static NSCache *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[NSCache alloc] init];
        [instance setObject:[TMAvatarImageView placeholderImageBySize:size andColor:NSColorFromRGB(0xfafafa)] forKey:@(-1)];
    });
    return instance;
}

static NSCache *newConverstaionTableViewCache(NSSize size) {
    static NSCache *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[NSCache alloc] init];
        [instance setObject:[TMAvatarImageView placeholderImageBySize:size andColor:NSColorFromRGB(0xfafafa)] forKey:@(-1)];
    });
    return instance;
}

static NSCache *userProfileCache(NSSize size) {
    static NSCache *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[NSCache alloc] init];
        [instance setObject:[TMAvatarImageView placeholderImageBySize:size andColor:NSColorFromRGB(0xfafafa)] forKey:@(-1)];
    });
    return instance;
}

static NSCache *messageTableViewCache(NSSize size) {
    static NSCache *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[NSCache alloc] init];
        [instance setObject:[TMAvatarImageView placeholderImageBySize:size andColor:NSColorFromRGB(0xfafafa)] forKey:@(-1)];
    });
    return instance;
}

static NSCache *photosSmallCache() {
    static NSCache *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[NSCache alloc] init];
    });
    return instance;
}

static NSCache *photosBigCache() {
    static NSCache *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[NSCache alloc] init];
    });
    return instance;
}

+ (NSImage *) placeholderImageBySize:(NSSize)size andColor:(NSColor *)color {
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [color set];
    NSRectFill(NSMakeRect(0, 0, size.width, size.height));
    [image unlockFocus];
    
    
    image = [TMImageUtils roundedImage:image size:size];
    
    return image;
}

+ (instancetype)standartTableAvatar {
    TMAvatarImageView *avatarImageView = [[self alloc] initWithFrame:NSMakeRect(10, roundf((DIALOG_CELL_HEIGHT - 50) / 2.0), 50, 50)];
    [avatarImageView setCacheDictionary:tableViewCache(avatarImageView.bounds.size)];
    [avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:18]];
    return avatarImageView;
}

+ (instancetype)standartNewConversationTableAvatar {
    TMAvatarImageView *avatarImageView = [[self alloc] initWithFrame:NSMakeRect(10, roundf((60 - 44) / 2.0), 44, 44)];
    [avatarImageView setCacheDictionary:newConverstaionTableViewCache(avatarImageView.bounds.size)];
    [avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:18]];
    return avatarImageView;
}

+ (instancetype)standartMessageTableAvatar {
    TMAvatarImageView *avatarImageView = [[self alloc] initWithFrame:NSMakeRect(0, 0, 36, 36)];
    [avatarImageView setCacheDictionary:messageTableViewCache(avatarImageView.bounds.size)];
    [avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [avatarImageView setOffsetTextY:2];
    return avatarImageView;
}

+ (instancetype) standartUserInfoAvatar {
    TMAvatarImageView *avatarImageView = [[self alloc] initWithFrame:NSMakeRect(0, 0, 130, 130)];
    [avatarImageView setCacheDictionary:userProfileCache(avatarImageView.bounds.size)];
    [avatarImageView setSmallCacheDictionary:tableViewCache(avatarImageView.bounds.size)];
    [avatarImageView setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:48]];
    [avatarImageView setTakeBigPhoto:YES];
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

    
}

- (void) dealloc {
    [Notification removeObserver:self];
}

- (void) notificationUserChange:(NSNotification *)notification {
    if(self.type == TMAvatarTypeUser) {
        TGUser *user = [notification.userInfo objectForKey:KEY_USER];
        
        if(self.user.n_id == user.n_id) {
            
            BOOL rebuild = NO;
            
            if([user.photo isKindOfClass:[TL_userProfilePhotoEmpty class]]) {
                rebuild = ![self.text isEqualToString:[NSString stringWithFormat:@"%C", (unichar)(user.fullName.length > 0 ? [user.fullName characterAtIndex:0] : 0)]];
            } else {
                rebuild = self.fileLocationSmall.hashCacheKey != user.photo.photo_small.hashCacheKey;
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
        TGChat *chat = [notification.userInfo objectForKey:KEY_CHAT];
        if(self.chat.n_id == chat.n_id) {
            BOOL rebuild = NO;
            
            if([chat.photo isKindOfClass:[TL_chatPhotoEmpty class]]) {
                rebuild = ![self.text isEqualToString:[NSString stringWithFormat:@"%C", (unichar)(chat.title.length > 0 ? [chat.title characterAtIndex:0] : 0)]];
            } else {
                rebuild = self.fileLocationSmall.hashCacheKey != chat.photo.photo_small.hashCacheKey;
            }
            
            if(rebuild) {
                NSLog(@"rebuild chat photo true");
                self->_chat = nil;
                self.isNeedPlaceholder = NO;
                [self setChat:chat animated:YES];
                self.isNeedPlaceholder = YES;
            } else {
                NSLog(@"rebuild chat photo false");
            }
        }
    }
}

- (void) setCacheDictionary:(NSCache *)cacheDictionary {
    self->_cacheDictionary = cacheDictionary;
}

- (void) setUser:(TGUser *)user {
    [self setUser:user animated:NO];
}

- (void) setUser:(TGUser *)user animated:(BOOL)animated {
    if(self.user.n_id == user.n_id)
        return;
    
    self->_chat = nil;
    self->_user = user;
    self->_text = nil;
    self->_broadcast = nil;
    self.type = TMAvatarTypeUser;
    self.fileLocationBig = user.photo.photo_big;
    self.fileLocationSmall = user.photo.photo_small;
    [self rebuild:animated];
}

- (void) setChat:(TGChat *)chat {
    [self setChat:chat animated:NO];
}


- (void) setChat:(TGChat *)chat animated:(BOOL)animated {
    if(self.chat.n_id == chat.n_id)
        return;
    
    self->_user = nil;
    self->_chat = chat;
    self->_text = nil;
    self->_broadcast = nil;
    self.type = TMAvatarTypeChat;
    self.fileLocationBig = chat.photo.photo_big;
    self.fileLocationSmall = chat.photo.photo_small;
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
    self.fileLocationBig = nil;
    self.fileLocationSmall = nil;
    
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
    self.fileLocationBig = nil;
    self.fileLocationSmall = nil;
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

- (TGFileLocation *)fileLocation {
    return self.takeBigPhoto ? self.fileLocationBig : self.fileLocationSmall;
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
        if(self.type == TMAvatarTypeUser) {
            if(self.user.first_name.length == 0 && self.user.last_name.length == 0) {
                self->_text = [NSString stringWithFormat:@"A"];
            } else {
                self->_text = [NSString stringWithFormat:@"%C%C", (unichar)(self.user.first_name.length ? [self.user.first_name characterAtIndex:0] : 0), (unichar)(self.user.last_name.length ? [self.user.last_name characterAtIndex:0] : 0)];
            }
            
        } else if(self.type == TMAvatarTypeChat) {
            self->_text = [NSString stringWithFormat:@"%C", (unichar)(self.chat.title.length > 0 ? [self.chat.title characterAtIndex:0] : self.chat.n_id)];
        } else if(self.type == TMAvatarTypeBroadcast) {
            if(self.broadcast.title.length > 0 ) {
                self->_text = [NSString stringWithFormat:@"%C", (unichar)([self.broadcast.title characterAtIndex:0])];
            } else {
                self->_text = [NSString stringWithFormat:@"%d",self.broadcast.n_id];
            }
            
        }
        self.currentHash = [self.text hash];
    }
    
    __block NSNumber *key = [NSNumber numberWithUnsignedInteger:self.currentHash];
    
    
    //Пытаемся выбрать из кеша таблицы
    if(self.cacheDictionary) {
        NSImage *image = [self.cacheDictionary objectForKey:key];
        if(image) {
            if(animated)
                [self addAnimation:ani() forKey:@"contents"];
    
            self.image = image;
            return;
        }
    }
    
    //Пытаемся получить изображение с кеша с большими размерами
    NSCache *cache = self.takeBigPhoto ? photosBigCache() : photosSmallCache();
    NSImage *image = [cache objectForKey:key];
    if(image) {
        //Уменьшаем до нужного нам размера
        image = [TMImageUtils roundedImageNew:image size:self.bounds.size];
        if(animated)
            [self addAnimation:ani() forKey:@"contents"];
        self.image = image;
        //Записываем в кеш
        [self.cacheDictionary setObject:image forKey:key];
        //Профит
        return;
    }
    
    
    BOOL isNeedPlaceholder = self.isNeedPlaceholder;
    
    //Попробуем еще глянуть меньшую копию, но грузить уже точно нужно
    if(self.takeBigPhoto) {
        NSImage *image = [photosSmallCache() objectForKey:[NSNumber numberWithUnsignedInteger:[self.fileLocationSmall hashCacheKey]]];
        if(image) {
            image = [TMImageUtils roundedImageNew:image size:self.bounds.size];
            if(animated)
                [self addAnimation:ani() forKey:@"contents"];
            
            self.image = (BTRImage *) image;
            isNeedPlaceholder = NO;
        }
    }
    
    //Если что Placeholder
    if(isNeedPlaceholder) {
        NSImage *image = [self.cacheDictionary objectForKey:[NSNumber numberWithInt:-1]];
        self.image = (BTRImage *) image;
    }
    
    //Ну, типа останавливаем старые загрузки
    if(self.fileLocation && self.downloadItem.downloadState != DownloadStateDownloading) {
        [self.downloadItem cancel];
        self.downloadItem = nil;
        _downloadListener = nil;
    }
    
    
    if(self.fileLocation) {
        __block TMAvatarImageView *weakSelf = self;
        
        INIT_HASH_CHEKER();
        
        
       
        self.downloadItem = [[DownloadPhotoItem alloc] initWithObject:self.fileLocation size:0];
        
        _downloadListener = [[DownloadEventListener alloc] initWithItem:self.downloadItem];
        
        
        [self.downloadItem addEvent:self.downloadListener];
        
        [self.downloadListener setCompleteHandler:^(DownloadItem * item) {

            
            
            weakSelf.downloadItem = nil;
            
            if(!item.result) {
                [weakSelf setFileLocationBig:nil];
                [weakSelf setFileLocationSmall:nil];
                [weakSelf rebuild:animated];
                return;
            }
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
                __block NSImage *imageOrigin = [[NSImage alloc] initWithData:item.result];
                
                if(!imageOrigin) {
                    [LoopingUtils runOnMainQueueAsync:^{
                        [weakSelf setFileLocationBig:nil];
                        [weakSelf setFileLocationSmall:nil];
                        [weakSelf rebuild:animated];
                    }];
                    return;
                }
                
                __block NSImage *image = [TMImageUtils roundedImageNew:imageOrigin size:weakSelf.bounds.size];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if(weakSelf.cacheDictionary)
                        [weakSelf.cacheDictionary setObject:image forKey:key];
                    
                    if(!weakSelf.takeBigPhoto) {
                        [photosSmallCache() setObject:imageOrigin forKey:key];
                    } else {
                        [photosBigCache() setObject:imageOrigin forKey:key];
                    }
                    
                    if(weakSelf.currentHash != hash) return;
                    
                    if(animated)
                        [weakSelf addAnimation:ani() forKey:@"contents"];
                    else {
                       // [weakSelf addAnimation:ani2() forKey:@"contents"];
                    }
                    
                    
                    
                    
                    if(weakSelf.isNeedPlaceholder)
                        weakSelf.image =  (BTRImage *)image;
                });
            });

        }];
        
        [self.downloadItem start];
        
    } else {
        
        
        
        int uid = self.type == TMAvatarTypeChat ? self.chat.n_id : (self.type == TMAvatarTypeBroadcast ? self.broadcast.n_id : self.user.n_id);
        
        __block int colorMask = 0;// = colorId != -1 ? (colorId) % 6 : -1;
        
        
       
        
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
        
        
        
         __block NSString *text = self->_text;
        
        weakify();
            INIT_HASH_CHEKER();
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
                __block NSImage *image = [strongSelf generateTextAvatar:colorMask text:text type:self.type];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if(strongSelf.cacheDictionary)
                        [strongSelf.cacheDictionary setObject:image forKey:key];
                    
                    HASH_CHECK();
                    if(animated)
                        [strongSelf addAnimation:ani() forKey:@"contents"];
                    
                    strongSelf.image = (BTRImage *) image;
                });
            });
    }
}

- (NSImage *)generateTextAvatar:(int)colorMask text:(NSString *)text type:(TMAvatarType)type {
    
    NSSize size = self.bounds.size;
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
            
            [NSColorFromRGB(0xdedede) set];
            [path stroke];
            
            color = NSColorFromRGB(0xc8c8c8);
        }
        
        NSDictionary *attributes = @{NSFontAttributeName: self.font, NSForegroundColorAttributeName: color};
        NSSize textSize = [text sizeWithAttributes:attributes];
        [text drawAtPoint: NSMakePoint(roundf( (self.bounds.size.width - textSize.width) * 0.5 ),roundf( (self.bounds.size.height - textSize.height) * 0.5 + self.offsetTextY) )withAttributes: attributes];

    } else {
        static NSImage *smallAvatar;
        
        static NSImage *largeAvatar;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            smallAvatar = [NSImage imageNamed:@"BroadcastAvatarIcon"];
            largeAvatar = [NSImage imageNamed:@"BroadcastLargeAvatarIcon"];
        });
        
        NSImage *img = self.bounds.size.width > 50.0 ? largeAvatar : smallAvatar;
        
        
        [img drawInRect:NSMakeRect(roundf( (self.bounds.size.width - img.size.width) * 0.5 ),roundf( (self.bounds.size.height - img.size.height) * 0.5 ), img.size.width, img.size.height)];
    }
    
    
    [image unlockFocus];
    
    
    
    
    image = [TMImageUtils roundedImageNew:image size:self.bounds.size];
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
