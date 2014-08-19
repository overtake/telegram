//
//  ImageStorage.h
//  FindPeople
//
//  Created by keepcoder on 21.06.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageStorage : NSObject
+ (void) loadFile:(id)name completeHandler:(void (^)(NSData *image))completeHandler;
+ (void) saveImageWithName:(id)name image:(NSImage *)image completionHandler:(void (^)(void))completionHandler;
+ (void) clearCache;
+(void)loadFileWithPath:(NSString *)p completeHandler:(void (^)(NSData *data))completeHandler;
+(void)saveImageWithPath:(id)file_path image:(NSImage *)image completionHandler:(void (^)(void))completionHandler;
@end
