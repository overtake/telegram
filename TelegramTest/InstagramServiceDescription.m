//
//  InstagramServiceDescription.m
//  Telegram
//
//  Created by keepcoder on 06.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "InstagramServiceDescription.h"

@implementation InstagramServiceDescription


@synthesize url = _url;
@synthesize title = _title;
@synthesize serviceName = _serviceName;
@synthesize titleSize = _titleSize;
@synthesize serviceNameSize = _serviceNameSize;
@synthesize imageURL = _imageURL;
@synthesize tableItem = _tableItem;

-(id)initWithSocialURL:(NSString *)url item:(MessageTableItem *)tableItem {
    if(self = [super init]) {
        _url = url;
        _tableItem = tableItem;
        
        _imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://instagram.com/p/%@/media/?size=l",[InstagramServiceDescription idWithURL:url]]];
        
        
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
        
        NSString *urlString = url.length > 25 ? [[url substringToIndex:25] stringByAppendingString:@"..."] : url;
        
        [title appendString:urlString withColor:[NSColor whiteColor]];
        [title setFont:TGSystemFont(13) forRange:title.range];
        _title = title;
        _titleSize = [title size];
        _titleSize.width = ceil(_titleSize.width + 14);
        _titleSize.height = ceil(_titleSize.height + 3);
        
        
        
        NSMutableAttributedString *serviceName = [[NSMutableAttributedString alloc] init];
        [serviceName appendString:@"Instagram" withColor:[NSColor whiteColor]];
        [serviceName setFont:TGSystemFont(13) forRange:serviceName.range];
        _serviceName = serviceName;
        _serviceNameSize = [serviceName size];
        _serviceNameSize.width = ceil(_serviceNameSize.width + 14);
        _serviceNameSize.height = ceil(_serviceNameSize.height + 3);
        
        
    }
    
    return self;
}



+(NSString *)idWithURL:(NSString *)url {
    NSTextCheckingResult *match = [[InstagramServiceDescription regularExpression] firstMatchInString:url
                                                                                            options:0
                                                                                              range:NSMakeRange(0, [url length])];
    if (match) {
        NSRange videoIDRange = [match rangeAtIndex:2];
        return [url substringWithRange:videoIDRange];
    }
    
    return nil;
}

+(NSRegularExpression *)regularExpression {
    NSError *error = NULL;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:@"(instagram.com/p/([-a-zA-Z0-9_]+))"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    return regex;
}



@end
