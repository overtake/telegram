//
//  ImageUploader.h
//  TelegramTest
//
//  Created by keepcoder on 02.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface UploadOperation : NSOperation


typedef enum {
    UploadImageType = 0,
    UploadDocumentType = 1,
    UploadVideoType = 2,
    UploadAudioType = 3
} UploadType;

typedef enum {
    UploadReady = 0,
    UploadExecuting = 1,
    UploadFinished = 2,
    UploadError = 3,
    UploadCancelled = 4
} UploadState;


@property (nonatomic, assign) int total_size;
@property (nonatomic, assign) NSUInteger readedBytes;
@property (nonatomic, copy) void (^uploadProgress)(UploadOperation *uploader, NSUInteger current, NSUInteger total);
@property (atomic, assign) UploadState uploadState;

@property (nonatomic,strong) NSData *aes_key;
@property (nonatomic,strong) NSMutableData *aes_iv;
@property (nonatomic,assign) long identify;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, copy) void (^uploadStarted)(UploadOperation *uploader, NSData *fileData);
@property (nonatomic, copy) void (^uploadComplete)(UploadOperation *uploader, id inputPhoto);
@property (nonatomic, copy) void (^uploadCancelled)(UploadOperation *uploader);
@property (nonatomic, copy) void (^uploadTypingNeed)(UploadOperation *uploader);

- (void)cancel;
- (void)ready:(UploadType)type;
- (void)encryptedready:(UploadType)type key:(NSData *)key iv:(NSData *)iv;
- (void)saveFileInfo:(id)fileInfo;

@end
