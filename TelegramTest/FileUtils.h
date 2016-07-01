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
#import "TGAudioWaveform.h"
@interface OpenWithObject : NSObject
@property (nonatomic, strong,readonly) NSString *fullname;
@property (nonatomic, strong,readonly) NSURL *app;
@property (nonatomic, strong,readonly) NSImage *icon;


-(id)initWithFullname:(NSString *)fullname app:(NSURL *)app icon:(NSImage *)icon;

@end

@interface FileUtils : NSObject


typedef enum {
    PasteBoardItemTypeVideo,
    PasteBoardItemTypeDocument,
    PasteBoardItemTypeImage,
    PasteBoardItemTypeGif,
    PasteBoardTypeLink
} PasteBoardItemType;

extern NSString *const TGImagePType;

extern NSString *const TGImportCardPrefix;
extern NSString *const TLUserNamePrefix;
extern NSString *const TLHashTagPrefix;
extern NSString *const TLBotCommandPrefix;
extern NSString *const TGJoinGroupPrefix;
extern NSString *const TGStickerPackPrefix;
extern NSString *const TGImportShareLinkPrefix;


extern NSString *const kBotInlineTypeAudio;
extern NSString *const kBotInlineTypeVideo;
extern NSString *const kBotInlineTypeSticker;
extern NSString *const kBotInlineTypeGif;
extern NSString *const kBotInlineTypePhoto;
extern NSString *const kBotInlineTypeContact;
extern NSString *const kBotInlineTypeVenue;
extern NSString *const kBotInlineTypeGeo;
extern NSString *const kBotInlineTypeFile;
extern NSString *const kBotInlineTypeVoice;

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
NSString *mediaFilePath(TL_localMessage *message);
void removeMessageMedia(TL_localMessage *message);
NSString *documentPath(TLDocument *document);
NSDictionary *non_documents_mime_types();
NSString* dp();
+(BOOL)checkNormalizedSize:(NSString *)path checksize:(int)checksize;
+(NSString *)documentName:(TLDocument *)document;
+ (NSString *)dataMD5:(NSData *)data;

TelegramWindow *appWindow();

NSArray * soundsList();
void playSentMessage(BOOL play);
void open_link(NSString *link);
void open_link_with_controller(NSString *link, TMNavigationController *controller);
void open_card(NSString *link);
void share_link(NSString *url, NSString *text);
NSString *exportPath(long randomId,NSString *extension);


void determinateURLLink(NSString *link);
NSString *tg_domain_from_link(NSString *link);

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

NSString *first_domain_character(NSString *url);

NSString *path_for_external_link(NSString *link);
NSString *display_url(NSString *url);

NSArray *document_preview_mime_types();

NSString *priorityString(NSString *, ...);


+ (TGAudioWaveform *)waveformForPath:(NSString *)path;
+ (int)convertBinaryStringToDecimalNumber:(NSString *)binaryString;

BOOL isEnterAccess(NSEvent *theEvent);
BOOL isEnterEvent(NSEvent *theEvent);

@end
