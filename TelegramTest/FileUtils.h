//
//  FileUtils.h
//  Telegram P-Edition
//
//  Created by keepcoder on 04.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TelegramWindow.h"
@interface OpenWithObject : NSObject
@property (nonatomic, strong,readonly) NSString *fullname;
@property (nonatomic, strong,readonly) NSURL *app;
@property (nonatomic, strong,readonly) NSImage *icon;


-(id)initWithFullname:(NSString *)fullname app:(NSURL *)app icon:(NSImage *)icon;

@end

@interface FileUtils : NSObject


extern NSString *const TGImagePType;

extern NSString *const TGImportCardPrefix;
extern NSString *const TLUserNamePrefix;
extern NSString *const TLHashTagPrefix;
extern NSString *const TLBotCommandPrefix;
extern NSString *const TGJoinGroupPrefix;
extern NSString *const TGStickerPackPrefix;
extern NSString *const TGImportShareLinkPrefix;
unsigned long fileSize(NSString *path);
+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSArray * result))handler;

+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSArray * result))handler forWindow:(NSWindow *)window;
+ (void)showChooseFolderPanel:(void (^)(NSString * result))handler forWindow:(NSWindow *)window;

+(NSString *)path;

void alert(NSString *text, NSString *info);
void alert_bad_files(NSArray *bad_files);
void confirm(NSString *text, NSString *info, void (^block)(void), void (^cancelBlock)(void));

NSString* md5sum(NSString *fp);

NSDictionary *getUrlVars(NSString *url);
NSString *mediaFilePath(TLMessageMedia *media);
NSString *documentPath(TLDocument *document);
NSString* dp();
+(BOOL)checkNormalizedSize:(NSString *)path checksize:(int)checksize;
+(NSString *)documentName:(TLDocument *)document;
+ (NSString *)dataMD5:(NSData *)data;

TelegramWindow *appWindow();

NSArray * soundsList();
void playSentMessage(BOOL play);
void open_link(NSString *link);
void open_card(NSString *link);
void share_link(NSString *url, NSString *text);
NSString *exportPath(long randomId,NSString *extension);


void determinateURLLink(NSString *link);


BOOL zipDirectory(NSURL *directoryURL, NSString * archivePath);
NSString *decodeCard(NSArray *card);
NSArray *encodeCard(NSString *card);
void open_user_by_name(NSDictionary * userName);

void join_group_by_hash(NSString * hash);

void add_sticker_pack_by_name(TLInputStickerSet *set);

int64_t SystemIdleTime(void);
NSData *passwordHash(NSString *password, NSData *salt);

+ (void) fillAppByUrl:(NSURL*)url bundle:(NSString**)bundle name:(NSString**)name version:(NSString**)version icon:(NSImage**)icon;

+(NSArray *)appsForFileUrl:(NSString *)file;

NSDictionary *audioTags(AVURLAsset *asset);

@end
