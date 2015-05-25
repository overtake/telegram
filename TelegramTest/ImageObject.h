//
//  TGImageObject.h
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"
#import "TGCache.h"
#import "TLFileLocation+Extensions.h"


@protocol TGImageObjectDelegate <NSObject>

@required
-(void)didDownloadImage:(NSImage *)image object:(id)object;


@optional
-(void)didUpdatedProgress:(float)progress;
@end

@interface ImageObject : NSObject
@property (nonatomic,strong) TLFileLocation *location;
@property (nonatomic,assign,readonly) int size;
@property (nonatomic,strong,readonly) NSImage *placeholder;
@property (nonatomic,assign,readonly) int sourceId;

@property (nonatomic,assign) NSSize imageSize;
@property (nonatomic,assign) NSSize realSize;

@property (nonatomic,strong) DownloadItem *downloadItem;
@property (nonatomic,strong) DownloadEventListener *downloadListener;
@property (nonatomic,strong,readonly) DownloadEventListener *supportDownloadListener;

@property (nonatomic,weak) id <TGImageObjectDelegate> delegate;



@property (nonatomic,assign) BOOL isLoaded;

-(id)initWithLocation:(TLFileLocation *)location;
-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder;
-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId;
-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId size:(int)size;


-(void)initDownloadItem;

-(NSString *)cacheKey;


@end
