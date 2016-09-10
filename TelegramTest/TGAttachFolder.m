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
        
        
        _task = zipDirectory(file, _generatedPath);
        
        [_task launch];
        [_task waitUntilExit];
        
        if(_task.terminationStatus == 0 && _task) {
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
        _generatedPath = exportPath(_unique_id, @"zip");
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
        _generatedPath = exportPath(_unique_id, @"zip");
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
        [path appendBezierPathWithRect:rect];
        [path fill];
        
        [image_Folder() drawInRect:NSMakeRect(roundf((NSWidth(rect) - image_Folder().size.width)/2.0), roundf((NSHeight(rect) - image_Folder().size.height)/2.0), image_Folder().size.width, image_Folder().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return isPathExists(_generatedPath) ? image : nil;
}

-(void)dealloc {
    [self cancel];
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
    [[NSFileManager defaultManager] removeItemAtPath:_generatedPath error:nil];
    [_task interrupt];
}

-(void)changeCaption:(NSString *)caption needSave:(BOOL)needSave {
    _caption = caption;
    if(needSave)
        [self save];
}

@end
