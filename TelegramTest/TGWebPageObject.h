//
//  TGWebPageObject.h
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGWebpageObject : NSObject

@property (nonatomic,strong,readonly) NSAttributedString *title;
@property (nonatomic,assign,readonly) NSSize titleSize;

@property (nonatomic,strong,readonly) TGImageObject *imageObject;
@property (nonatomic,strong,readonly) TGImageObject *roundObject;

@property (nonatomic,strong,readonly) NSAttributedString *desc;
@property (nonatomic,assign,readonly) NSSize descSize;


@property (nonatomic,strong,readonly) NSString *toolTip;
@property (nonatomic,strong,readonly) NSString *date;
@property (nonatomic,strong,readonly) NSAttributedString *author;

@property (nonatomic,strong,readonly) TLWebPage *webpage;

@property (nonatomic,assign,readonly) NSSize size;
@property (nonatomic,assign,readonly) NSSize imageSize;


@property (nonatomic,strong) NSAttributedString *siteName;


-(id)initWithWebPage:(TLWebPage *)webpage;


-(void)makeSize:(int)width;
-(int)blockHeight;
-(Class)webpageContainer;

+(id)objectForWebpage:(TLWebPage *)webpage;

-(NSImage *)siteIcon;

@end
