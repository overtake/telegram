//
//  YoutubeServiceDescription.m
//  Telegram
//
//  Created by keepcoder on 03.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "YoutubeServiceDescription.h"

@implementation YoutubeServiceDescription
@synthesize url = _url;
@synthesize title = _title;
@synthesize serviceName = _serviceName;
@synthesize titleSize = _titleSize;
@synthesize serviceNameSize = _serviceNameSize;
@synthesize imageURL = _imageURL;

-(id)initWithSocialURL:(NSString *)url {
    if(self = [super init]) {
        _url = url;
        
        _imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",[YoutubeServiceDescription idWithURL:url]]];
        
        
        
         NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
        
        NSString *urlString = url.length > 25 ? [[url substringToIndex:25] stringByAppendingString:@"..."] : url;
        
        [title appendString:urlString withColor:[NSColor whiteColor]];
        [title setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:title.range];
        _title = title;
        _titleSize = [title size];
        _titleSize.width = ceil(_titleSize.width + 14);
        _titleSize.height = ceil(_titleSize.height + 3);
        
        
        
         NSMutableAttributedString *serviceName = [[NSMutableAttributedString alloc] init];
        [serviceName appendString:@"YouTube" withColor:[NSColor whiteColor]];
        [serviceName setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:serviceName.range];
        _serviceName = serviceName;
        _serviceNameSize = [serviceName size];
        _serviceNameSize.width = ceil(_serviceNameSize.width + 14);
        _serviceNameSize.height = ceil(_serviceNameSize.height + 3);

        
    }
    
    return self;
}

-(NSImage *)centerImage {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 48, 48);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGBWithAlpha(0x000000, 0.5) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        [image_PlayIconWhite() drawInRect:NSMakeRect(roundf((48 - image_PlayIconWhite().size.width)/2) + 2, roundf((48 - image_PlayIconWhite().size.height)/2) , image_PlayIconWhite().size.width, image_PlayIconWhite().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return image;
    
}

+(NSString *)idWithURL:(NSString *)url {
    NSTextCheckingResult *match = [[YoutubeServiceDescription regularExpression] firstMatchInString:url
                                                                                            options:0
                                                                                              range:NSMakeRange(0, [url length])];
    if (match) {
        NSRange videoIDRange = [match rangeAtIndex:0];
        return [url substringWithRange:videoIDRange];
    }
    
    return nil;
}

+(NSRegularExpression *)regularExpression {
    NSError *error = NULL;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:@"(?<=youtube.com/watch\\?v=)([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)"
                                              options:NSRegularExpressionCaseInsensitive
                                                    error:&error];
    return regex;
}

@end
