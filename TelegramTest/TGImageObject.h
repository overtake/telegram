//
//  TGImageObject.h
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"

@class TGImageView;




@protocol TGImageObjectDelegate <NSObject>

@required
-(void)didDownloadImage:(NSImage *)image object:(id)object;

@end

@interface TGImageObject : NSObject
@property (nonatomic,strong,readonly) TGFileLocation *location;
@property (nonatomic,assign,readonly) int size;
@property (nonatomic,strong,readonly) NSImage *placeholder;
@property (nonatomic,assign,readonly) int sourceId;

@property (nonatomic,assign) NSSize imageSize;
@property (nonatomic,assign) NSSize realSize;

@property (nonatomic,strong) DownloadItem *downloadItem;
@property (nonatomic,strong,readonly) DownloadEventListener *downloadListener;

@property (nonatomic,strong) TGImageView *imageView;

@property (nonatomic,strong) id <TGImageObjectDelegate> delegate;


@property (nonatomic,assign) BOOL isLoaded;

-(id)initWithLocation:(TGFileLocation *)location;
-(id)initWithLocation:(TGFileLocation *)location placeHolder:(NSImage *)placeHolder;
-(id)initWithLocation:(TGFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId;
-(id)initWithLocation:(TGFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId size:(int)size;


-(void)initDownloadItem;



@end
