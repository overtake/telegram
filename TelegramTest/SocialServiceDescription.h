//
//  SocialServiceDescription.h
//  Telegram
//
//  Created by keepcoder on 03.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialServiceDescription : NSObject


@property (nonatomic,strong,readonly) NSURL *imageURL;
@property (nonatomic,strong,readonly) NSString *url;

@property (nonatomic,strong,readonly) NSAttributedString *title;
@property (nonatomic,strong,readonly) NSAttributedString *serviceName;

@property (nonatomic,assign,readonly) NSSize titleSize;
@property (nonatomic,assign,readonly) NSSize serviceNameSize;
@property (nonatomic,strong,readonly) MessageTableItem *tableItem;


- (id)initWithSocialURL:(NSString *)url item:(MessageTableItem *)tableItem;

-(NSImage *)centerImage;


+(NSString *)idWithURL:(NSString *)url;
+(NSRegularExpression *)regularExpression;

@end 
