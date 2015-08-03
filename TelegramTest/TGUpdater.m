//
//  TGUpdater.m
//  Telegram
//
//  Created by keepcoder on 08.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGUpdater.h"
#import "AFImageRequestOperation.h"
#import "AJUpdateObject.h"
@interface TGUpdater ()
@property (nonatomic,assign) int version;
@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSString *url;


@property (nonatomic,strong) AJUpdateObject *updateObject;
@property (nonatomic,strong) NSString *v_path;
@end

@implementation TGUpdater

-(id)initWithVersion:(int)version token:(NSString *)token url:(NSString *)url {
    if(self = [super init])
    {
        _version = version;
        _token = token;
        _url = url;
    }
    
    return self;
}

-(void)itsHaveNewVersion:(void(^)(bool nVersion))callback {
    

    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if(data[@"response"] && data[@"response"][@"download_url"] && data[@"response"][@"ver"])
        {
            _updateObject = [[AJUpdateObject alloc] initWithJson:data[@"response"]];
            _v_path = [path() stringByAppendingPathComponent:[NSString stringWithFormat:@"tg%d.dmg",_updateObject.ver]];
            
            callback([data[@"response"][@"ver"] intValue] > _version);
        } else
        {
            callback(false);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_after_seconds(5, ^{
            [self itsHaveNewVersion:callback];
        });
        
    }];
    
    [operation start];
    
}

-(void)startDownload:(void (^)(NSString *fpath))callback progress:(void (^)(NSUInteger progress))progressHandler {
    
    assert(_updateObject != nil);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_updateObject.download_url]];
    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:_v_path append:NO];
    
    [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        
        [ASQueue dispatchOnMainQueue:^{
            if(progressHandler != nil)
                progressHandler((float)totalBytesRead / (float)totalBytesExpectedToRead * 100.0);
        }];
        
    }];
    
    [operation setCompletionBlock:^{
        
#ifdef TGDEBUG
        assert([_updateObject.md5sum isEqualToString:md5sum(_v_path)]);
#endif
        
        if([_updateObject.md5sum isEqualToString:md5sum(_v_path)])
        {
            [ASQueue dispatchOnMainQueue:^{
                callback(_v_path);
            }];
        }
        
    }];
    [operation start];
    

    
}


@end
