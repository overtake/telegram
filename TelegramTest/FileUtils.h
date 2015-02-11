//
//  FileUtils.h
//  Telegram P-Edition
//
//  Created by keepcoder on 04.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OpenWithObject : NSObject
@property (nonatomic, strong,readonly) NSString *fullname;
@property (nonatomic, strong,readonly) NSURL *app;
@property (nonatomic, strong,readonly) NSImage *icon;


-(id)initWithFullname:(NSString *)fullname app:(NSURL *)app icon:(NSImage *)icon;

@end

@interface FileUtils : NSObject

#define MIN_IMG_SIZE NSMakeSize(250,40)
extern NSString *const TGImagePType;

extern NSString *const TGImportCardPrefix;
extern NSString *const TLUserNamePrefix;

+(NSString*)mimetypefromExtension:(NSString *)extension;
+(NSString*)extensionForMimetype:(NSString *)mimetype;

unsigned long fileSize(NSString *path);
+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSString * result))handler;

+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSString * result))handler forWindow:(NSWindow *)window;
+ (void)showChooseFolderPanel:(void (^)(NSString * result))handler forWindow:(NSWindow *)window;
NSString* path();
+(NSString *)path;
BOOL checkFileSize(NSString *path, int size);
BOOL fileExists(TLFileLocation *location);
NSString *locationFilePath(TLFileLocation *location,NSString *extension);
NSString* locationFilePathWithPrefix(TLFileLocation *location, NSString *prefix, NSString *extension);
NSString *mediaFilePath(TLMessageMedia *media);
NSString *documentPath(TLDocument *document);
BOOL isPathExists(NSString *path);
NSString* dp();
+(BOOL)checkNormalizedSize:(NSString *)path checksize:(int)checksize;
+(NSString *)documentName:(TLDocument *)document;
+ (NSString *)dataMD5:(NSData *)data;
+ (NSString *)fileMD5:(NSString*)path;
BOOL check_file_size(NSString *path);
void alert(NSString *text, NSString *info);
void alert_bad_files(NSArray *bad_files);
void confirm(NSString *text, NSString *info, void (^block)(void), void (^cancelBlock)(void));

NSArray *mediaTypes();
NSArray *videoTypes();
NSArray *imageTypes();

NSArray * soundsList();
void playSentMessage(BOOL play);
void open_link(NSString *link);
void open_card(NSString *link);
BOOL NSSizeNotZero(NSSize size);
BOOL NSContainsSize(NSSize size1, NSSize size2);
NSString *exportPath(long randomId,NSString *extension);
NSImage *cropImage(NSImage *image,NSSize backSize, NSPoint difference);
BOOL NSStringIsValidEmail(NSString *checkString);
BOOL zipDirectory(NSURL *directoryURL, NSString * archivePath);
NSString *decodeCard(NSArray *card);
NSArray *encodeCard(NSString *card);
void open_user_by_name(NSString * userName);
int64_t SystemIdleTime(void);


+ (void) fillAppByUrl:(NSURL*)url bundle:(NSString**)bundle name:(NSString**)name version:(NSString**)version icon:(NSImage**)icon;

+(NSArray *)appsForFileUrl:(NSString *)file;
@end
