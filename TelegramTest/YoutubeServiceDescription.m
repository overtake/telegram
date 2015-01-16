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
@synthesize tableItem = _tableItem;

-(id)initWithSocialURL:(NSString *)url item:(MessageTableItem *)tableItem {
    if(self = [super initWithSocialURL:url item:tableItem]) {
        _url = url;
        _tableItem = tableItem;
        
        NSString *yid = [YoutubeServiceDescription idWithURL:url];
        
        _imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",yid]];
        
        
        NSMutableAttributedString *serviceName = [[NSMutableAttributedString alloc] init];
        [serviceName appendString:@"YouTube" withColor:[NSColor whiteColor]];
        [serviceName setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:serviceName.range];
        _serviceName = serviceName;
        _serviceNameSize = [serviceName size];
        _serviceNameSize.width = ceil(_serviceNameSize.width + 14);
        _serviceNameSize.height = ceil(_serviceNameSize.height + 3);
        
        
        __block NSDictionary *description = nil;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            description = [transaction objectForKey:yid inCollection:SOCIAL_DESC_COLLECTION];
        }];
       
        
        if(description) {
           
             NSString *desc = description[@"title"];
            
             [self setTitle:desc];
        
        } else {
            [self loadInfo:yid];
        }

        
    }
    
    return self;
}


-(void)loadInfo:(NSString *)yid {
    
   
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=jsonc",yid]]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if(json) {
                
                NSString *title = json[@"data"][@"title"];
                NSString *duration = [NSString durationTransformedValue:[json[@"data"][@"duration"] intValue]];
                
                if(title && duration && self.tableItem) {
                    [self setTitle:title];
                    
                    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                        [transaction setObject:@{@"title":title, @"duration":duration} forKey:yid inCollection:SOCIAL_DESC_COLLECTION];
                    }];
                    
                    [Notification perform:UPDATE_MESSAGE_ITEM data:@{@"item":self.tableItem}];
                }
                
                
            }
        }
        
    }];
    
}

-(void)setTitle:(NSString *)title {
    NSMutableAttributedString *t = [[NSMutableAttributedString alloc] init];
    
    
    
    [t appendString:title.length > 25 ? [[title substringToIndex:25] stringByAppendingString:@"..."] : title withColor:[NSColor whiteColor]];
    
    [t setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:t.range];
    
    _title = t;
    _titleSize = [t size];
    _titleSize.width = ceil(_titleSize.width + 14);
    _titleSize.height = ceil(_titleSize.height + 3);
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
