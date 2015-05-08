//
//  TGSDownloadOperation
//  Telegram
//
//  Created by keepcoder on 07.05.14.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGSDownloadOperation.h"
#import "NSMutableData+Extension.h"
#import "DownloadPart.h"
#import "DownloadQueue.h"
#import "TGS_RPCRequest.h"
@interface TGSDownloadOperation ()
@property (nonatomic,strong)id target;
@property (nonatomic,assign) SEL selector;
@property (nonatomic,assign) BOOL isCancelled;
@property (nonatomic,strong) NSOutputStream *stream;
@property (nonatomic,assign) NSUInteger downloaded;
@property (nonatomic,strong) NSMutableData *resultData;


@property (nonatomic,strong) NSMutableArray *poll;
@property (nonatomic,strong) NSMutableArray *completePoll;
@property (nonatomic,assign) int partSize;

@property (nonatomic,assign) int partEnumerator;
@property (nonatomic,assign) int currentPartId;
@property (nonatomic,assign) int max_poll_size;

@property (nonatomic,assign) int startOffset;
@end



@implementation TGSDownloadOperation

@synthesize item = _item;


-(id)initWithItem:(DownloadItem *)item {
    if(self = [super init]) {
        _item = item;
        self.poll = [[NSMutableArray alloc] init];
        self.completePoll = [[NSMutableArray alloc] init];
        self.resultData = [[NSMutableData alloc] init];
        self.partSize = [item partSize];
        
        self.max_poll_size = self.partSize == 0 ? 1 : 5;
        
        
        
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:_item.path error: NULL];
        
        
        
        BOOL append = YES;
        
        self.item.isRemoteLoaded = YES;
        if(item.size != 0  && self.item.fileType != DownloadFileImage) {
            self.downloaded = self.startOffset = (int)[attrs fileSize];
            append = self.downloaded < item.size && self.downloaded > 0;
            [DownloadQueue setProgress:(float)self.downloaded/(float)_item.size * 100.0f toOperation:self];
        }
        
        self.stream = [[NSOutputStream alloc] initToFileAtPath:_item.path append:append];
        
    }
    return self;
}





-(void)start:(id)target selector:(SEL)selector {
    self.selector = selector;
    self.target = target;
    
    _item.errorType = DownloadErrorNone;
    
    [DownloadQueue dispatchOnDownloadQueue:^{
        
        [DownloadQueue setProgress:(float)self.downloaded/(float)_item.size * 100.0f toOperation:self];
        
        if(self.partSize == 0) {
            [DownloadQueue setProgress:70 toOperation:self];
        }
        
        if(self.item.size != 0 && self.downloaded == self.item.size && self.item.fileType != DownloadFileImage) {
            _item.downloadState = DownloadStateCompleted;
            [self.target performSelectorInBackground:self.selector withObject:self];
            return;
        }
        
        
        if(_item.fileType == DownloadFileImage) {
            
            
            NSData *imageData = [NSData dataWithContentsOfFile:self.item.path];
            
            if(imageData == nil || (imageData.length == 0 || (self.item.size > 0 && self.item.size > imageData.length))) {
                [self load];
            } else {
                _item.isRemoteLoaded = NO;
                _item.result = imageData;
                _item.downloadState = DownloadStateCompleted;
                [self.target performSelectorInBackground:self.selector withObject:self];
            }
        } else
            [self load];
    }];
    
}


- (void)flush {
    [DownloadQueue dispatchOnDownloadQueue:^{
        while (self.poll.count > 0) {
            DownloadPart *part = self.poll[0];
            [part.request cancelRequest];
            
            [self.poll removeObjectAtIndex:0];
            
            part = nil;
        }
        
        
        while (self.completePoll.count > 0) {
            DownloadPart *part = self.completePoll[0];
            [part.request cancelRequest];
            
            [self.completePoll removeObjectAtIndex:0];
            
            part = nil;
        }
    }];
}

-(void)cancel {
    
    [DownloadQueue dispatchOnDownloadQueue:^{
        self.resultData = nil;
        
        [self flush];
        
        _item.errorType = DownloadErrorCantLoad;
        if(self.item.isRemoteLoaded) {
            [self.stream close];
            
            if(self.item.size == 0)
                [[NSFileManager defaultManager] removeItemAtPath:_item.path error:nil];
            
            [self.target performSelectorInBackground:self.selector withObject:self];
        }
    }];
    
}

-(void)load:(DownloadPart *)part {
    
    TLAPI_upload_getFile *upload = [TLAPI_upload_getFile createWithLocation:part.item.input offset:part.offset limit:self.partSize];
    
    part.request = [TGS_RPCRequest sendRequest:upload forDc:part.dcId successHandler:^(TGS_RPCRequest *request, id response) {
        
        [DownloadQueue dispatchOnDownloadQueue:^{
            
            TLupload_File *obj = response;
            
            part.resultData = obj.bytes;
            
            obj.bytes = nil;
            
            [self.poll removeObject:part];
            
            [self.completePoll addObject:part];
            
            
            
            [self.completePoll sortUsingComparator:^NSComparisonResult(DownloadPart *part1, DownloadPart *part2) {
                return part1.partId > part2.partId ? NSOrderedDescending : NSOrderedAscending;
            }];
            
            
            while (_completePoll.count > 0 && [_completePoll[0] partId] == _currentPartId) {
                
                ++_currentPartId;
                
                DownloadPart *p = _completePoll[0];
                
                [self proccessPartData:p.resultData];
                
                
                [_completePoll removeObject:p];
                
                p.resultData = nil;
                p.request = nil;
                p = nil;
                
            }
            
            [self fill];
            
            
        }];
        
        
    } errorHandler:^(TGS_RPCRequest *request, RpcError *error) {
        
        [DownloadQueue dispatchOnDownloadQueue:^{
            
            
            int n_dc = error.resultId;
            n_dc = n_dc == 0 ? part.dcId : n_dc;
            
            if(part.dcId != n_dc) {
                
                [self flush];
                
                self.partEnumerator = 0;
                self.item.dc_id = n_dc;
                self.currentPartId = 0;
                
                [self.stream close];
                
                self.stream = [[NSOutputStream alloc] initToFileAtPath:_item.path append:NO];
                
                [self load];
                
            }  else {
                _item.downloadState = DownloadStateCompleted;
                [self cancel];
            }
        }];
        
    }];
}

-(void)proccessPartData:(NSData *)partData {
    
    
  
    self.downloaded+=partData.length;
    
    const uint8_t *bytes = (const uint8_t*)[partData bytes];
    [self.stream write:bytes maxLength:partData.length];
    
    
    
    if(_item.fileType == DownloadFileImage)
        [self.resultData appendData:partData];
    
    
    if( _item.size == 0 || _item.size <= self.downloaded || bytes == NULL) {
        [self.stream close];
        _item.progress = 100.0f;
        _item.result = self.resultData;
        if(_item.downloadState == DownloadStateCanceled) {
            [self cancel];
        } else {
            _item.downloadState = DownloadStateCompleted;
            [self.target performSelectorInBackground:self.selector withObject:self];
        }
        
    } else {
        [DownloadQueue setProgress:(float)self.downloaded/(float)_item.size * 100.0f toOperation:self];
    }
    
}

- (void)fill {
    while (_item.downloadState == DownloadStateDownloading && _poll.count < _max_poll_size) {
        
        if(self.item.size == 0 || (self.startOffset + self.partEnumerator*self.partSize <= self.item.size)) {
            DownloadPart *newPart = [[DownloadPart alloc] initWithId:self.partEnumerator offset:self.startOffset + self.partEnumerator*self.partSize dcId:_item.dc_id downloadItem:_item];
            
            self.partEnumerator++;
            
            [_poll addObject:newPart];
            [self load:[_poll lastObject]];
            
        } else {
            break;
        }
        
        
    }
    
}



-(void)load {
    
    if(self.item.dc_id == 0) {
        _item.downloadState = DownloadStateCompleted;
        [self.target performSelectorInBackground:self.selector withObject:self];
        return;
    }
    
    [self.stream open];
    
    [self fill];
    
}



@end
