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
        [serviceName appendString:url withColor:[NSColor whiteColor]];
        [serviceName setFont:TGSystemFont(12) forRange:serviceName.range];
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
    
    [t setFont:TGSystemFont(13) forRange:t.range];
    
    _title = t;
    _titleSize = [t size];
    _titleSize.width = ceil(_titleSize.width + 14);
    _titleSize.height = ceil(_titleSize.height + 3);
}

-(NSImage *)centerImage {
    return image_ModernMessageYoutubeButton();
    
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
