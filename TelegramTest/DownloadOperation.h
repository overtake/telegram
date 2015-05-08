//
//  DownloadOperation.h
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"
@interface DownloadOperation : NSObject
@property (nonatomic,strong,readonly) DownloadItem * item;

-(id)initWithItem:(DownloadItem *)item;

-(void)start:(id)target selector:(SEL)selector;

-(void)cancel;
@end
