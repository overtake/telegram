//
//  TGSImageObject.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSImageObject.h"
#import "TGSDownloadPhotoItem.h"
#import <CommonCrypto/CommonDigest.h>
#include "NSString+Extended.h"
#import "TGS_MTNetwork.h"

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

@implementation TGSImageObject



@synthesize supportDownloadListener = _supportDownloadListener;

-(void)initDownloadItem {
    
    
    if(!self.location)
    {
        [ASQueue dispatchOnStageQueue:^{
            [self _didDownloadImage:nil];
        }];
    }

    
    if((self.downloadItem && (self.downloadItem.downloadState != DownloadStateCompleted && self.downloadItem.downloadState != DownloadStateCanceled && self.downloadItem.downloadState != DownloadStateWaitingStart)) || !self.location)
        return;//[_downloadItem cancel];
    
    
    self.downloadItem = [[TGSDownloadPhotoItem alloc] initWithObject:self.location size:self.size];
    
    self.downloadListener = [[DownloadEventListener alloc] init];
    
    _supportDownloadListener = [[DownloadEventListener alloc] init];
    
    
    [self.downloadItem addEvent:self.supportDownloadListener];
    [self.downloadItem addEvent:self.downloadListener];
    
    
    weak();
    
    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        weakSelf.isLoaded = YES;
        
        [weakSelf _didDownloadImage:item];
        weakSelf.downloadItem = nil;
        weakSelf.downloadListener = nil;
    }];
    
    
    [self.downloadListener setProgressHandler:^(DownloadItem * item) {
        if([weakSelf.delegate respondsToSelector:@selector(didUpdatedProgress:)]) {
            [weakSelf.delegate didUpdatedProgress:item.progress];
        }
    }];
    
    
    [self.downloadItem start];
}


-(void)_didDownloadImage:(DownloadItem *)item {
    
    
    NSImage *image;
    
    if(!item.result) {
        image = [self generateTextAvatar:[self colorMask:_object] size:self.imageSize text:[self text:_object] font:TGSystemLightFont(14) offsetY:2];
    } else {
        __block NSImage *imageOrigin = [[NSImage alloc] initWithData:item.result];
        
        image = renderedImage(imageOrigin, imageOrigin.size);
        
        image = [TMImageUtils roundedImageNew:image size:self.imageSize];
    }
    
    
    
    [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}


-(NSString *)text:(NSObject *)object {
    
    NSString *text;
    
    
    if([object isKindOfClass:[TLUser class]]) {
        if([[object valueForKey:@"first_name"] length] == 0 && [[object valueForKey:@"last_name"] length] == 0) {
            text = [NSString stringWithFormat:@"A"];
        } else {
            
            
            NSArray *emoji = [[object valueForKey:@"first_name"] getEmojiFromString:NO];
            
            __block NSString *firstName = [object valueForKey:@"first_name"];
            
            [emoji enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                firstName = [firstName stringByReplacingOccurrencesOfString:obj withString:@""];
            }];
            
            emoji = [[object valueForKey:@"last_name"] getEmojiFromString:NO];
            
            __block NSString *lastName = [object valueForKey:@"last_name"];
            
            [emoji enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                lastName = [lastName stringByReplacingOccurrencesOfString:obj withString:@""];
            }];
            
            text = [NSString stringWithFormat:@"%C%C", (unichar)([firstName length] ? [firstName characterAtIndex:0] : 0), (unichar)([lastName length] ? [lastName characterAtIndex:0] : 0)];
        }
        
    } else if([object isKindOfClass:[TLChat class]]) {
        
        NSArray *emoji = [[object valueForKey:@"title"] getEmojiFromString:NO];
        
        __block NSString *textResult = [object valueForKey:@"title"];
        
        [emoji enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            textResult = [textResult stringByReplacingOccurrencesOfString:obj withString:@""];
        }];
        
        text = textResult.length > 0 ? [textResult substringWithRange:NSMakeRange(0, 1)] : @"A";
        
    }
    return text;
}

-(int)colorMask:(NSObject *)object {
    
    
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
        const int numColors = [object isKindOfClass:[TLUser class]] ? 8 : 4;
        
        if(uid != -1) {
            char buf[16];
            
            if(![object isKindOfClass:[TLUser class]])
                snprintf(buf, 16, "%d", -uid);
            else
                snprintf(buf, 16, "%d%d", uid, [[TGS_MTNetwork instance] getUserId]);
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

- (NSImage *)generateTextAvatar:(int)colorMask size:(NSSize)size text:(NSString *)text font:(NSFont *)font offsetY:(int)offset {
    
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
    
    NSColor *color = [NSColor whiteColor];
    
    __block NSString *textResult = [text uppercaseString];
    
    NSArray *emoji = [textResult getEmojiFromString:NO];
    
    [emoji enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        textResult = [textResult stringByReplacingOccurrencesOfString:obj withString:@""];
    }];
    
    if(colorMask == -1) {
        NSBezierPath *path = [NSBezierPath bezierPath];
        
        [path appendBezierPathWithArcWithCenter: NSMakePoint(image.size.width/2, image.size.height/2)
                                         radius: roundf(image.size.width/2)
                                     startAngle: 0
                                       endAngle: 360 clockwise:NO];
        [path setLineWidth:2];
        [GRAY_TEXT_COLOR set];
        [path stroke];
        
        
        color = GRAY_TEXT_COLOR;
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color};
    NSSize textSize = [textResult sizeWithAttributes:attributes];
    [textResult drawAtPoint: NSMakePoint(roundf( (size.width- textSize.width) * 0.5 ),roundf( (size.height - textSize.height) * 0.5 + offset) )withAttributes: attributes];

    
    
    [image unlockFocus];
    
    image = [TMImageUtils roundedImageNew:image size:size];
    return image;
}


-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"%lu:%@",!self.location ? [[self.object valueForKey:@"n_id"] intValue] : self.location.hashCacheKey,NSStringFromSize(self.imageSize)];
}

@end
