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
        [title appendString:self.url withColor:[NSColor whiteColor]];
        [title setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:title.range];
        _title = title;
        _titleSize = [title size];
        _titleSize.width = ceil(_titleSize.width + 14);
        _titleSize.height = ceil(_titleSize.height + 7);
        
        
        
         NSMutableAttributedString *serviceName = [[NSMutableAttributedString alloc] init];
        [serviceName appendString:@"YouTube" withColor:[NSColor whiteColor]];
        [serviceName setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:serviceName.range];
        _serviceName = serviceName;
        _serviceNameSize = [serviceName size];
        _serviceNameSize.width = ceil(_serviceNameSize.width + 14);
        _serviceNameSize.height = ceil(_serviceNameSize.height + 7);

        
    }
    
    return self;
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
    [NSRegularExpression regularExpressionWithPattern:@"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)"
                                              options:NSRegularExpressionCaseInsensitive
                                                    error:&error];
    return regex;
}

@end
