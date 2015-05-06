//
//  ImageStorage.m
//  FindPeople
//
//  Created by keepcoder on 21.06.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ImageStorage.h"
#import "ImageUtils.h"
#import "ImageCache.h"
#import "FileUtils.h"
@implementation ImageStorage


static dispatch_queue_t image_queue() {
    static dispatch_queue_t af_image_request_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_image_request_operation_processing_queue = dispatch_queue_create("ImageStorage", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(af_image_request_operation_processing_queue, ^{
            [[NSThread currentThread] setName:@"ImageStorage"];
        });
    });
    
    return af_image_request_operation_processing_queue;
}

+ (void) clearCache {
//    MTLog(@"clear path %@", path());
   /// CFAbsoluteTime time = getF
    
    [[NSFileManager defaultManager] removeItemAtPath:path() error:nil];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path()
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
    
    [[ImageCache sharedManager] clear];
    
    
}

+(void)saveImageWithName:(id)name image:(NSImage *)image completionHandler:(void (^)(void))completionHandler {
    dispatch_async(image_queue(), ^{
       [compressImage([image TIFFRepresentation], 0.83) writeToFile:[NSString stringWithFormat:@"%@/%@.jpg", path(), name] atomically:YES];
        if(completionHandler != nil) completionHandler();
    });

}

+(void)saveImageWithPath:(id)file_path image:(NSImage *)image completionHandler:(void (^)(void))completionHandler {
    dispatch_async(image_queue(), ^{
        [compressImage([image TIFFRepresentation], 0.83) writeToFile:file_path atomically:YES];
        if(completionHandler != nil) completionHandler();
    });
    
}

+(void)loadFileWithPath:(NSString *)p completeHandler:(void (^)(NSData *data))completeHandler {
    dispatch_async(image_queue(), ^{
        NSData *data = [[NSFileManager defaultManager] fileExistsAtPath:p] ? [NSData dataWithContentsOfFile:p] : nil;
        completeHandler(data);
    });
}

+(void)loadFile:(id)name completeHandler:(void (^)(NSData *data))completeHandler {
    dispatch_async(image_queue(), ^{
        NSString *p = [NSString stringWithFormat:@"%@/%@.jpg", path(), name];
        NSData *data = [[NSFileManager defaultManager] fileExistsAtPath:p] ? [NSData dataWithContentsOfFile:p] : nil;
        completeHandler(data);
    });
}



@end
