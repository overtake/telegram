//
//  TMSearchImage.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/18/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMSearchImage : NSObject
@property (nonatomic, strong) NSString *mediaUrl;
@property (nonatomic, strong) NSString *displayUrl;
@property (nonatomic, strong) NSString *sourceUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *n_id;
@property (nonatomic, strong) NSString *thumbUrl;
@property (nonatomic) NSSize size;
@property (nonatomic) NSUInteger fileSize;
@property (nonatomic) NSSize thumbSize;
@property (nonatomic) NSUInteger thumbFileSize;
@end
