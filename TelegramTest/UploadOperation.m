//
//  ImageUploader.m
//  TelegramTest
//
//  Created by keepcoder on 02.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "UploadOperation.h"
#import "CMath.h"
#import "NSData+Extensions.h"
#import "QueueManager.h"
#import "NSMutableData+Extension.h"
#import "TGTimer.h"
#import <MTProtoKit/MTProtoKit.h>
#import <openssl/md5.h>
#import <CommonCrypto/CommonCrypto.h>
#define CONCURENT 3
#define MD5(data, len, md)      CC_MD5(data, len, md)

@interface UploadOperation () {
    int fingerprint;
    NSData *originKeyIv;
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic,strong) TGTimer *typingTimer;

@property (nonatomic, strong) NSInputStream *buffer;
@property (nonatomic, assign) int part_size;
@property (nonatomic, assign) int total_parts;
@property (nonatomic) BOOL isEncrypted;


@property (nonatomic, strong) id request;


@property (nonatomic, strong) NSMutableDictionary *encryptedParts;
@property (nonatomic, strong) NSMutableArray *blocksRequests;

@property (nonatomic) int maxEncryptedPart;

@property (nonatomic, strong) NSString *fileMD5Hash;
@end

@implementation UploadOperation

- (id)init {
    if(self = [super init]) {
        self.identify = rand_long();
        _uploadState = UploadNoneState;
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isFinished {
    return self.uploadState == UploadFinished || self.uploadState == UploadError || self.uploadState == UploadCancelled;
}

-(void)setUploadCancelled:(void (^)(UploadOperation *))uploadCancelled {
    
    [ASQueue dispatchOnMainQueue:^{
        _uploadCancelled = uploadCancelled;
    }];
}

-(void)setUploadComplete:(void (^)(UploadOperation *, id))uploadComplete {
    [ASQueue dispatchOnMainQueue:^{
        _uploadComplete = uploadComplete;
    }];
}

-(void)setUploadProgress:(void (^)(UploadOperation *, NSUInteger, NSUInteger))uploadProgress {
    [ASQueue dispatchOnMainQueue:^{
        _uploadProgress = uploadProgress;
    }];
}

-(void)setUploadStarted:(void (^)(UploadOperation *, NSData *))uploadStarted {
    [ASQueue dispatchOnMainQueue:^{
        _uploadStarted = uploadStarted;
    }];
}


- (BOOL)isExecuting {
    return self.uploadState == UploadExecuting;
}

- (BOOL)isCancelled {
    return self.uploadState == UploadCancelled;
}


-(void)setFilePath:(NSString *)filePath {
    
    self->_filePath = filePath;
    
    self.fileName = [filePath lastPathComponent];
}

-(void)setFileName:(NSString *)fileName {
    self->_fileName = fileName;
}

- (void)cancel {
    [super cancel];
    
    if(self.uploadState == UploadExecuting) {
        [self setState:UploadCancelled];
        [ASQueue dispatchOnStageQueue:^{
            [self removeAllObjects];
        }];
    } else {
        self.uploadState = UploadCancelled;
    }
    
    [ASQueue dispatchOnMainQueue:^{
        if(self.uploadCancelled)
            self.uploadCancelled(self);
    }];
    
}

- (void)push {
    if(self.uploadState == UploadReady) {
        [[QueueManager sharedManager] add:self];
    }
}

- (void)setState:(UploadState)uploadState {
    @synchronized(self) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isCancelled"];
        self.uploadState = uploadState;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isCancelled"];
    }
}

- (void)ready:(UploadType)type {
    _uploadType = type;
    
    
    self.uploadState = UploadReady;
    
    if(!self.fileName)
        self.fileName = [self.filePath lastPathComponent];
    
    self.total_size = (int) (self.fileData ? self.fileData.length : fileSize(self.filePath));
    
    
    if(self.filePath) {
        self.fileMD5Hash = fileMD5(self.filePath);
    }
    
    
    [self push];
   
}

- (void)encryptedready:(UploadType)type key:(NSData *)key iv:(NSData *)iv {
    self.aes_key = key;
    self.aes_iv = [iv mutableCopy];
    
    
    NSData *k = [self.aes_key dataWithData:self.aes_iv];
    
    unsigned char d[MD5_DIGEST_LENGTH];
    
    MD5([k bytes], (int)[k length], d);
    
    NSData *digest = [NSData dataWithBytes:&d length:MD5_DIGEST_LENGTH];
    
  
    
    NSMutableData *fingerdata = [[digest subdataWithRange:NSMakeRange(0, 4)] mutableCopy];
    
    NSData *b = [digest subdataWithRange:NSMakeRange(4, 4)];
    
    for (int i = 0; i < (int)fingerdata.length && i < (int)b.length; i++)
    {
        ((uint8_t *)fingerdata.mutableBytes)[i] ^= ((uint8_t *)b.bytes)[i];
    }
    
    [fingerdata getBytes:&self->fingerprint];
    
    self.isEncrypted = YES;
    
    [self ready:type];
}

- (void)start {
    
    if(!self.isEncrypted) {
        
        id manager = [NSClassFromString(@"Storage") performSelector:@selector(manager)];
        
        id file = [manager performSelector:@selector(fileInfoByPathHash:) withObject:self.fileMD5Hash];
        
        if(!file && _uploaderRequestFileHash) {
            file = _uploaderRequestFileHash(self);
        }
        
        if(file) {
            self.uploadState = UploadFinished;
            [ASQueue dispatchOnMainQueue:^{
                if(self.uploadComplete)
                    self.uploadComplete(self, file);
            }];
            
            return;
        }
    }
    
    if(self.uploadState == UploadCancelled)
        return;
    
    if(!self.fileName) {
        if(self.uploadType == UploadImageType) {
            self.fileName = @"photo.jpg";
        } else {
            self.fileName = @"unnamed";
        }
    }
    
    self.part_size = 128 * 1024;
    self.total_parts = ceil(self.total_size / 1.0 / self.part_size);

    while(self.total_parts > 2999 || 1048576 % self.part_size != 0) {
        self.part_size += 32 * 1024;
        self.total_parts = ceil(self.total_size / 1.0 / self.part_size);
    }
    
    [[ASQueue mainQueue] dispatchOnQueue:^{
        if(self.uploadStarted)
            self.uploadStarted(self, self.fileData);
        
        self.typingTimer = [[TGTimer alloc] initWithTimeout:4 repeat:YES completion:^{
            
            if(self.uploadTypingNeed && self.uploadState == UploadExecuting)
                self.uploadTypingNeed(self);
            
        } queue:[ASQueue globalQueue].nativeQueue];
        
        [self.typingTimer start];
    }];
    
    
   
    
    [self setState:UploadExecuting];
    
    [ASQueue dispatchOnStageQueue:^{
        if(!self.fileData) {
            self.buffer = [[NSInputStream alloc] initWithFileAtPath:self.filePath];
        }

        [self.buffer open];
        
        self.maxEncryptedPart = -1;
        self.encryptedParts = [[NSMutableDictionary alloc] init];
        self.blocksRequests = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < CONCURENT; i++) {
            [self startUploadPart:i];
        }
    }];
    
    _semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    MTLog(@"end");
    dispatch_semaphore_signal(_semaphore);
}

- (NSData *)readDataFromPosition:(NSUInteger)position length:(NSUInteger)length {
    
    assert(![NSThread isMainThread]);
    
    if(self.fileData) {
        return [self.fileData subdataWithRange:NSMakeRange(position, length)];
    }
    
    uint8_t *buf = malloc(sizeof(uint8_t) * length);
    [self.buffer setProperty:@(position) forKey:NSStreamFileCurrentOffsetKey];
    NSInteger lengthR = [self.buffer read:buf maxLength:length];
    if(lengthR == -1) {
        [self setState:UploadError];
        free(buf);
        return nil;
    }

    return [NSData dataWithBytesNoCopy:buf length:length freeWhenDone:YES];
}

- (int)lengthOfReadBytesForPart:(int)partNumber {
    return partNumber + 1 == self.total_parts ? (int)(self.total_size - (self.total_parts - 1) * self.part_size) : self.part_size;
}

- (void)removeAllObjects {
    if(self.buffer) {
        [self.buffer close];
    }
    
    [self.encryptedParts removeAllObjects];
    for(id request in self.blocksRequests) {
        [request cancelRequest];
    }
    [self.blocksRequests removeAllObjects];
    
    if(_semaphore)
        dispatch_semaphore_signal(_semaphore);
}

- (void)startUploadPart:(int)partNumber {
    if(partNumber >= self.total_parts)
        return;
    
    __block int readFromBufferSize = [self lengthOfReadBytesForPart:partNumber];

    NSData *data = nil;
    if(self.isEncrypted) {
        if(partNumber <= self.maxEncryptedPart) {
            data = [self.encryptedParts objectForKey:@(partNumber)];
        } else {
            
            for(int i = self.maxEncryptedPart + 1; i <= partNumber; i++) {
                readFromBufferSize = [self lengthOfReadBytesForPart:i];
                
                data = [self readDataFromPosition:i * self.part_size length:readFromBufferSize];
                data = [[data mutableCopy] addPadding:16];
                
                NSMutableData *copy = [data mutableCopy];
                
                
                MTAesEncryptInplaceAndModifyIv(copy, self.aes_key, self.aes_iv);
                [self.encryptedParts setObject:copy forKey:@(i)];
                
                data = copy;
            }
            
            self.maxEncryptedPart = partNumber;
        }
        
    } else {
        //Not encrypted
        data = [self readDataFromPosition:partNumber * self.part_size length:readFromBufferSize];
    }
    
    BOOL isBigFile = self.total_size > 10 * 1024 * 1024;
    
    id partRequest = isBigFile ? [TLAPI_upload_saveBigFilePart createWithFile_id:self.identify file_part:partNumber file_total_parts:self.total_parts bytes:data] : [TLAPI_upload_saveFilePart createWithFile_id:self.identify file_part:partNumber bytes:data];
    
   id request = [[self rpcClass] sendPollRequest:partRequest successHandler:^(id request, id response) {
        [self.blocksRequests removeObject:request];
        
        if(self.uploadState == UploadCancelled) {
            [self removeAllObjects];
            return; // this operation any cancelled
        }
        
        self.readedBytes += readFromBufferSize;
        
        if(self.isEncrypted) {
            [self.encryptedParts removeObjectForKey:@(partNumber)];
        }
        
        [ASQueue dispatchOnMainQueue:^{
            if(self.uploadProgress)
                self.uploadProgress(self,self.readedBytes,self.total_size);
        }];
        
        BOOL isLastPart = self.readedBytes == self.total_size;
        
        if(!isLastPart) {
            MTLog(@"upload progress[%d]: %lu/%d", partNumber, self.readedBytes / 1024, self.total_size / 1024);
            [self startUploadPart:partNumber + CONCURENT];
            
        } else {
            MTLog(@"upload complete: %lu/%d",self.readedBytes / 1024, self.total_size / 1024);
            
            id inputFile;
            if(self.aes_iv && self.aes_key) {
                if(isBigFile)
                    inputFile = [TL_inputEncryptedFileBigUploaded createWithN_id:self.identify parts:self.total_parts key_fingerprint:self->fingerprint];
                else
                    inputFile = [TL_inputEncryptedFileUploaded createWithN_id:self.identify parts:self.total_parts md5_checksum:@"" key_fingerprint:self->fingerprint];
            } else {
                if(isBigFile)
                    inputFile = [TL_inputFileBig createWithN_id:self.identify parts:self.total_parts name:@""];
                else
                    inputFile = [TL_inputFile createWithN_id:self.identify parts:self.total_parts name:self.fileName md5_checksum:@""];
            }
            
            if(_uploaderNeedSaveFileHash) {
                _uploaderNeedSaveFileHash(self,inputFile);
            }
            
            [self setState:UploadFinished];
            
            [self saveFileInfo:inputFile];
            
            [ASQueue dispatchOnMainQueue:^{
                if(self.uploadComplete)
                    self.uploadComplete(self, inputFile);
                [self.typingTimer invalidate];
                self.typingTimer = nil;
            }];
            
            [self removeAllObjects];
        }
    } errorHandler:^(id request, RpcError *error) {
        [self.blocksRequests removeObject:request];
        [self startUploadPart:partNumber];
    } queue:dispatch_get_current_queue()];
    
    [self.blocksRequests addObject:request];
}

- (void)saveFileInfo:(id)fileInfo {
    if(!self.isEncrypted && _fileMD5Hash.length > 0) {
        if(self.uploadType == UploadImageType ||
           self.uploadType == UploadDocumentType ||
           self.uploadType == UploadVideoType ) {
            
            id manager = [NSClassFromString(@"Storage") performSelector:@selector(manager)];
            
            [manager performSelector:@selector(setFileInfo:forPathHash:) withObject:fileInfo withObject:self.fileMD5Hash];
            
        }
        
    }
}

- (BOOL)checkChunkSize:(int)chunkSize {
    return chunkSize % 1024 == 0 && chunkSize < 524288 && 1048576 % chunkSize == 0;
}

-(Class)rpcClass {
    return NSClassFromString(@"RPCRequest") ? : NSClassFromString(@"TGS_RPCRequest");
}

@end