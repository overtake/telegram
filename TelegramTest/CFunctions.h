//
//  CFunctions.h
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFunctions : NSObject

BOOL checkFileSize(NSString *path, int size);
unsigned long fileSize(NSString *path);
BOOL fileExists(TLFileLocation *location);
NSString *locationFilePath(TLFileLocation *location,NSString *extension);
NSString* locationFilePathWithPrefix(TLFileLocation *location, NSString *prefix, NSString *extension);
BOOL isPathExists(NSString *path);
BOOL check_file_size(NSString *path);
NSString* path();

BOOL NSSizeNotZero(NSSize size);
BOOL NSContainsSize(NSSize size1, NSSize size2);
BOOL NSStringIsValidEmail(NSString *checkString);

NSArray *mediaTypes();
NSArray *videoTypes();
NSArray *imageTypes();

NSString *fileMD5(NSString * path);


NSString *mimetypefromExtension(NSString *extension);

NSString* extensionForMimetype(NSString *mimetype);

@end
