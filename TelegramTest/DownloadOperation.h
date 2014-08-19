//
//  ImageSender.h
//  TelegramTest
//
//  Created by keepcoder on 21.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DownloadItem.h"
@interface DownloadOperation : NSObject

@property (nonatomic,strong,readonly) DownloadItem * item;

-(id)initWithItem:(DownloadItem *)item;

-(void)start:(id)target selector:(SEL)selector;

-(void)cancel;
@end
