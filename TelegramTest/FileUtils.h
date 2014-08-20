//
//  FileUtils.h
//  Telegram P-Edition
//
//  Created by keepcoder on 04.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

#define MIN_IMG_SIZE NSMakeSize(250,40)
extern NSString *const TGImagePType; //удаление всей истории


+(NSString*)mimetypefromExtension:(NSString *)extension;
unsigned long fileSize(NSString *path);
+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSString * result))handler;

+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSString * result))handler forWindow:(NSWindow *)window;
+ (void)showChooseFolderPanel:(void (^)(NSString * result))handler forWindow:(NSWindow *)window;
NSString* path();
+(NSString *)path;
BOOL checkFileSize(NSString *path, int size);
BOOL fileExists(TGFileLocation *location);
NSString *locationFilePath(TGFileLocation *location,NSString *extension);
NSString *mediaFilePath(TGMessageMedia *media);
NSString *documentPath(TGDocument *document);
BOOL isPathExists(NSString *path);
NSString* dp();
+(BOOL)checkNormalizedSize:(NSString *)path checksize:(int)checksize;
+(NSString *)documentName:(TGDocument *)document;
+ (NSString *)dataMD5:(NSData *)data;
+ (NSString *)fileMD5:(NSString*)path;
BOOL check_file_size(NSString *path);
void alert(NSString *text, NSString *info);
void alert_bad_files(NSArray *bad_files);
void confirm(NSString *text, NSString *info, void (^block)(void));
NSArray *mediaTypes();
NSArray *videoTypes();
NSArray *imageTypes();

NSArray * soundsList();
void playSentMessage(BOOL play);
void open_link(NSString *link);
BOOL NSSizeNotZero(NSSize size);
BOOL NSContainsSize(NSSize size1, NSSize size2);
NSString *exportPath(long randomId,NSString *extension);
NSImage *cropImage(NSImage *image,NSSize backSize, NSPoint difference);


@end
