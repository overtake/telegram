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
    UploadNoneState = 0,
    UploadReady = 1,
    UploadExecuting = 2,
    UploadFinished = 3,
    UploadError = 4,
    UploadCancelled = 5
} UploadState;


@property (nonatomic, assign,readonly) UploadType uploadType;

@property (nonatomic, assign) int total_size;
@property (nonatomic, assign) NSUInteger readedBytes;
@property (atomic, assign) UploadState uploadState;

@property (nonatomic,strong) NSData *aes_key;
@property (nonatomic,strong) NSMutableData *aes_iv;
@property (nonatomic,assign) long identify;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) void (^uploadProgress)(UploadOperation *uploader, NSUInteger current, NSUInteger total);
@property (nonatomic, strong) void (^uploadStarted)(UploadOperation *uploader, NSData *fileData);
@property (nonatomic, strong) void (^uploadComplete)(UploadOperation *uploader, id inputPhoto);
@property (nonatomic, strong) void (^uploadCancelled)(UploadOperation *uploader);
@property (nonatomic, strong) void (^uploadTypingNeed)(UploadOperation *uploader);


@property (nonatomic, strong) id (^uploaderRequestFileHash)(UploadOperation *uploader);
@property (nonatomic, strong) void (^uploaderNeedSaveFileHash)(UploadOperation *uploader, id file);

- (void)cancel;
- (void)ready:(UploadType)type;
- (void)encryptedready:(UploadType)type key:(NSData *)key iv:(NSData *)iv;

-(Class)rpcClass;

@end
