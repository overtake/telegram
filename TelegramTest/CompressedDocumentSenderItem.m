//
//  CompressedDocumentSenderItem.m
//  Telegram
//
//  Created by keepcoder on 16/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "CompressedDocumentSenderItem.h"

@interface DocumentSenderItem ()
-(void)performRequest;
@end

@interface CompressedDocumentSenderItem ()<TGCompressDelegate>
@property (nonatomic,strong) TGCompressItem *item;
@end

@implementation CompressedDocumentSenderItem

-(id)initWithItem:(TGCompressItem *)compressItem {
    if(self = [super initWithConversation:compressItem.conversation]) {
        self.item = compressItem;
        
        TL_compressDocument *document = [TL_compressDocument createWithN_id:0 access_hash:0 date:[[MTNetwork instance] getTime] mime_type:compressItem.mime_type size:0 thumb:[TL_photoSizeEmpty createWithType:@"x"] dc_id:0 attributes:[compressItem.attributes mutableCopy] compressor:[NSKeyedArchiver archivedDataWithRootObject:_item]];

        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[[NSData alloc] initWithContentsOfFile:compressItem.path], NULL);

        if(source != NULL) {
            NSDictionary* options = @{(NSString*)kCGImageSourceTypeIdentifierHint : (id)kUTTypeGIF};
            
            
            CGImageRef imgRef = CGImageSourceCreateImageAtIndex(source, 0, (__bridge CFDictionaryRef)options);
            
            NSImage *image = [[NSImage alloc] initWithCGImage:imgRef size:compressItem.size];
            
            NSData *jpeg = jpegNormalizedData(image);
            
            document.thumb = [TL_photoSize createWithType:@"" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:image.size.width h:image.size.height size:(int)jpeg.length];
            
            [TGCache cacheImage:image forKey:[NSString stringWithFormat:@"%@:blurred",[document.thumb.location cacheKey]] groups:@[IMGCACHE]];
            
            [jpeg writeToFile:[document.thumb.location path] atomically:YES];
            
        }
        
        
        super.message = [MessageSender createOutMessage:nil media:[TL_messageMediaDocument createWithDocument:document] conversation:compressItem.conversation];
        
        [self.message save:YES];
        

    }
    
    return self;
}

-(void)didStartCompressing:(id)item {
    
}

-(void)performRequest {
    if([[NSFileManager defaultManager] fileExistsAtPath:self.item.path isDirectory:nil])
        [self.item readyAndStart];
     else
        [self cancel];
}

-(void)setProgress:(float)progress {
    [ASQueue dispatchOnStageQueue:^{
        [super setProgress:(self.item.progress/2.0) + (progress/2.0)];
    }];
}


-(void)didEndCompressing:(TGCompressItem *)item success:(BOOL)success {
    if(item == _item) {
        
        [ASQueue dispatchOnStageQueue:^{
            
            if(success) {
                [[NSFileManager defaultManager] moveItemAtPath:item.outputPath toPath:exportPath(self.message.randomId, extensionForMimetype(self.message.media.document.mime_type)) error:nil];
                
                [super performRequest];
            } else {
                self.state = MessageSendingStateError;
            }
            
        }];

    }
}


-(void)didProgressUpdate:(id)item progress:(int)progress {
    [self setProgress:0];
}
-(void)didCancelCompressing:(id)item {
    
}

-(void)setItem:(TGCompressItem *)item {
    _item = item;
    _item.delegate = self;
}

-(void)setMessage:(TL_localMessage *)message {
    [super setMessage:message];
    
    self.item = [NSKeyedUnarchiver unarchiveObjectWithData:message.media.document.compressor];
}

-(void)cancel {
    [_item cancel];
    [super cancel];
}

@end
