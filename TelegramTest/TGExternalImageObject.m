//
//  TGExternalImageObject.m
//  Telegram
//
//  Created by keepcoder on 23/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGExternalImageObject.h"
#import "AFImageRequestOperation.h"
#import "DownloadQueue.h"
@interface TGExternalImageObject ()
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) AFImageRequestOperation *af_imageRequestOperation;
@end

@implementation TGExternalImageObject


-(id)initWithURL:(NSString *)url {
    if(self = [super init]) {
        _url = [NSURL URLWithString:url];
    }
    
    return self;
}

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_imageRequestOperationQueue setMaxConcurrentOperationCount:5];
    });
    
    return _af_imageRequestOperationQueue;
}

-(void)initDownloadItem {
    
    if(!_af_imageRequestOperation) {
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
        [request setHTTPShouldHandleCookies:NO];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:request];
        [requestOperation setFailureCallbackQueue:[DownloadQueue nativeQueue]];
        [requestOperation setSuccessCallbackQueue:[DownloadQueue nativeQueue]];

        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([request isEqual:[self.af_imageRequestOperation request]]) {
                
                NSImage *image;
                
                if(responseObject) {
                    
                    if(self.imageProcessor) {
                        image = self.imageProcessor(responseObject,self.imageSize);
                    } else {
                        image = renderedImage(responseObject, self.imageSize);
                    }
                    
                    [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
                    
                    [ASQueue dispatchOnMainQueue:^{
                        [self.delegate didDownloadImage:image object:self];
                    }];
                    
                    self.af_imageRequestOperation = nil;
                }
    
            }
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([request isEqual:[self.af_imageRequestOperation request]]) {
               
                if (self.af_imageRequestOperation == operation) {
                    self.af_imageRequestOperation = nil;
                }
            }
        }];
        
        self.af_imageRequestOperation = requestOperation;
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
    
}


-(NSString *)cacheKey {
    return _url.absoluteString;
}

@end
