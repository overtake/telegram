//
//  DownloadExternalOperation.m
//  Telegram
//
//  Created by keepcoder on 24/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "DownloadExternalOperation.h"
#import "AFNetworking.h"
#import "DownloadExternalItem.h"
#import "DownloadQueue.h"
#import "NSData+Extensions.h"
@interface DownloadExternalOperation ()<NSURLConnectionDelegate>
@property (nonatomic,assign) NSUInteger dataLength;

@property (nonatomic,strong)id target;
@property (nonatomic,assign) SEL selector;



@property (nonatomic,strong) NSURLConnection *connection;

@end

@implementation DownloadExternalOperation

@synthesize item = _item;

-(id)initWithItem:(DownloadItem *)item {
    if(self = [super initWithItem:item]) {
        _item = item;
        _dataLength = 0;
        _item.result = [[NSData alloc] init];
    }
    
    return self;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{

    _item.result = [_item.result dataWithData:data];
    _item.progress = ((float)_item.result.length/(float)_dataLength) * 100;
    [DownloadQueue setProgress:_item.progress toOperation:self];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse: (NSHTTPURLResponse*) response {
    if([response statusCode] == 200)
        _dataLength = [response expectedContentLength];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    _item.errorType = DownloadErrorCantLoad;
    [self.target performSelectorInBackground:self.selector withObject:self];
    
    _connection = nil;
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
   
    [_item.result writeToFile:_item.path atomically:YES];
    _item.result = nil;
    
    _item.downloadState = DownloadStateCompleted;
    [self.target performSelectorInBackground:self.selector withObject:self];
    
    _connection = nil;
}

-(NSOperationQueue *)queue {
    static NSMutableArray *queues;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queues = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 5; i++) {
            [queues addObject:[[NSOperationQueue alloc] init]];
        }
    });
    
    [queues sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self.operationCount" ascending:YES]]];
    
    return queues[0];
}

-(void)start:(id)target selector:(SEL)selector {
    
    _target = target;
    _selector = selector;
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:((DownloadExternalItem *)_item).downloadUrl]];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [_connection setDelegateQueue:self.queue];
    
    
    
    [_connection start];
   
}

@end
