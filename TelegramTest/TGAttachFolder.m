//
//  TGAttachFolder.m
//  Telegram
//
//  Created by keepcoder on 01/09/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGAttachFolder.h"


#import "TGAttachFolder.h"
#import "ASQueue.h"
#import "ImageAttachSenderItem.h"
#import "FolderAttachSender.h"
@interface TGAttachFolder ()
@property (nonatomic,strong) NSString *generatedPath;

@property (nonatomic,strong) NSTask *task;

@end

@implementation TGAttachFolder


@synthesize uploader = _uploader;
@synthesize peer_id = _peer_id;
@synthesize caption = _caption;
@synthesize unique_id = _unique_id;

-(NSString *)generatedPath {
    
    __block NSString *p;
    
    [self.queue dispatchOnQueue:^{
        
        if(isPathExists(_generatedPath)) {
            p = _generatedPath;
        }
        
    } synchronous:YES];
    
    
    return p;
}





-(void)prepareFolder:(NSString *)file {
    
    [self.queue dispatchOnQueue:^{
        
        NSString *ep = exportPath(rand_long(),@"zip");
        
        _task = zipDirectory(file, ep);
        
        [_task launch];
        [_task waitUntilExit];
        
        if(_task.terminationStatus == 0 && _task) {
            _generatedPath = ep;
            _task = nil;
            
            [ASQueue dispatchOnMainQueue:^{
                
                [self startUploader];
                
                [self.delegate didSuccessGeneratedThumb:self.thumb];
                
                [self.delegate didSuccessGenerateAttach];
            }];
            
            
            
        } else {
            [ASQueue dispatchOnMainQueue:^{
                
                [self.delegate didFailGenerateAttach];
            }];

        }
       
        
    }];
    
}

-(void)startUploader {
    
    if(!_uploader) {
        
        id uploadedFile = [[Storage manager] fileInfoByPathHash:fileMD5(_generatedPath)];
        
        if(!uploadedFile) {
            _uploader = [[UploadOperation alloc] init];
            
            [_uploader setFilePath:_generatedPath];
            [_uploader setFileName:[_file lastPathComponent]];
            [_uploader ready:UploadDocumentType];
            
            weak();
            
            [_uploader setUploadComplete:^(UploadOperation *uploader, id input) {
                
                weakSelf.uploader = nil;
                
                [weakSelf.delegate didEndUploading:uploader];
                
            }];
            
            [_uploader setUploadProgress:^(UploadOperation *upload, NSUInteger current, NSUInteger total) {
                
                [weakSelf.delegate didUpdateProgress:((float)current/(float)total) * 100.0f];
                
            }];
            
            [ASQueue dispatchOnMainQueue:^{
                [self.delegate didStartUploading:_uploader];
            }];
        }
        
    }
    
}




-(void)prepare {
    if(_file) {
        if(!isPathExists(_generatedPath))
            [self prepareFolder:_file];
        else  {
            [self.delegate didSuccessGeneratedThumb:self.thumb];
                
            [self.delegate didSuccessGenerateAttach];

        }
    } else {
        [self.delegate didFailGenerateAttach];
    }
    
    
}

-(id)initWithOriginFile:(NSString *)file orData:(NSData *)data peer_id:(int)peer_id {
    if(self = [super init]) {
        _file = file;
        _unique_id = rand_long();
        _peer_id = peer_id;
        _caption = @"";
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_file forKey:@"file"];
    [aCoder encodeInt64:_unique_id forKey:@"unique_id"];
    [aCoder encodeInt:_peer_id forKey:@"peer_id"];
    [aCoder encodeObject:_caption forKey:@"caption"];
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _file = [aDecoder decodeObjectForKey:@"file"];
        _unique_id = [aDecoder decodeInt64ForKey:@"unique_id"];
        _generatedPath = exportPath(_unique_id, @"jpg");
        _peer_id = [aDecoder decodeIntForKey:@"peer_id"];
        _caption = [aDecoder decodeObjectForKey:@"caption"];
    }
    
    return self;
}

-(NSImage *)thumb {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 68, 68);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [BLUE_COLOR set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:0 yRadius:0];
        [path fill];
        
        [image_DocumentThumbIcon() drawInRect:NSMakeRect(roundf((NSWidth(rect) - image_DocumentThumbIcon().size.width)/2), roundf((NSHeight(rect) - image_DocumentThumbIcon().size.height)/2), image_DocumentThumbIcon().size.width, image_DocumentThumbIcon().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return isPathExists(_generatedPath) ? image : nil;
}

-(void)dealloc {
    [_uploader cancel];
    _uploader = nil;
    [_task terminate];
}

-(BOOL)isEqualTo:(TGAttachFolder *)object {
    return object.unique_id == _unique_id;
}

-(Class)senderClass {
    return [FolderAttachSender class];
}

-(void)cancel {
    [_uploader cancel];
    _uploader = nil;
    [_task terminate];
    _task = nil;
}

-(void)changeCaption:(NSString *)caption needSave:(BOOL)needSave {
    _caption = caption;
    if(needSave)
        [self save];
}

@end
