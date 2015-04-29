//
//  TGAttachObject.h
//  Telegram
//
//  Created by keepcoder on 20.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TGAttachDelegate <NSObject>

-(void)didSuccessGenerateAttach;
-(void)didFailGenerateAttach;
-(void)didSuccessGeneratedThumb:(NSImage *)thumb;

-(void)didStartUploading:(UploadOperation *)uploader;
-(void)didEndUploading:(UploadOperation *)uploader;
@end

@interface TGAttachObject : NSObject<NSCoding>


@property (nonatomic,strong,readonly) NSString *caption;

@property (nonatomic,strong) UploadOperation *uploader;

@property (nonatomic,assign,readonly) NSUInteger unique_id;

@property (nonatomic,assign,readonly) int peer_id;

@property (nonatomic,strong) id<TGAttachDelegate> delegate;

@property (nonatomic,strong,readonly) NSImage *thumb;
@property (nonatomic,strong,readonly) NSImage *image;
@property (nonatomic,strong,readonly) NSData *previewData;
@property (nonatomic,assign,readonly) NSSize imageSize;


-(NSString *)generatedPath;




-(id)initWithOriginFile:(NSString *)file orData:(NSData *)data peer_id:(int)peer_id;

-(void)prepare;

-(Class)senderClass;

-(void)save;

-(void)changeCaption:(NSString *)caption needSave:(BOOL)needSave;

@end
