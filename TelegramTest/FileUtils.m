
//
//  FileUtils.m
//  Telegram P-Edition
//
//  Created by keepcoder on 04.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "FileUtils.h"
#import "TLFileLocation+Extensions.h"
#import "Crypto.h"
#import "TMMediaController.h"
#include <IOKit/IOKitLib.h>

#import <CoreFoundation/CoreFoundation.h>


@implementation OpenWithObject

-(id)initWithFullname:(NSString *)fullname app:(NSURL *)app icon:(NSImage *)icon {
    if(self = [super init]) {
        _fullname = fullname;
        _app = app;
        _icon = icon;
    }
    
    return self;
}


@end


@interface FileUtils ()
@property (nonatomic,strong) NSDictionary *mimeTypes;
@property (nonatomic,strong) NSDictionary *extensions;
@end

@implementation FileUtils


NSString *const TGImagePType = @"TGImagePasteType";
NSString *const TGImportCardPrefix = @"tg://resolve?domain=";
NSString *const TLUserNamePrefix = @"@";

-(id)init {
    if(self = [super init]) {
        NSMutableDictionary *types = [[NSMutableDictionary alloc] init];
        
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"mime-types.txt"]];
        
        NSString *mimefile = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        NSArray* mimes = [mimefile componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        
        NSMutableDictionary *ex = [[NSMutableDictionary alloc] init];
        
        for (NSString *line in mimes) {
            NSArray* single = [line componentsSeparatedByCharactersInSet:
                                   [NSCharacterSet characterSetWithCharactersInString:@":"]];
            
            [types setObject:[single objectAtIndex:1] forKey:[single objectAtIndex:0]];
            [ex setObject:[single objectAtIndex:0] forKey:[single objectAtIndex:1]];
        }
        
       
        self.extensions = ex;
        
        self.mimeTypes = types;
    }
    return self;
}

BOOL fileExists(TLFileLocation *location) {
    return [[NSFileManager defaultManager] fileExistsAtPath:locationFilePath(location, @"tiff")];
}

BOOL isPathExists(NSString *path) {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


+(FileUtils *)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] init];
    });
    return instance;
}

unsigned long fileSize(NSString *path) {
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath:path error: NULL];
    return [attrs fileSize];
}

+(BOOL)checkNormalizedSize:(NSString *)path checksize:(int)checksize {
    int pathsize = (int)fileSize(path);
    int dif = abs(pathsize-checksize);
    return pathsize != 0 && dif <= 16; //for encrypted files
}

BOOL checkFileSize(NSString *path, int size) {
    long fs = fileSize(path);
    return fs > 0 && fs >= size;
}

+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSString * result))handler forWindow:(NSWindow *)window {
    
    [[TMMediaController controller] close];
    
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setCanCreateDirectories:YES];
    if(types.count > 0)
        [openDlg setAllowedFileTypes:types];
    
    [openDlg setAllowsMultipleSelection:YES];
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [openDlg URLs];
            for(int i = 0; i < [urls count]; i++ ) {
                NSString *path = [[urls objectAtIndex:i] path];
                NSString *pathExtension = [[path pathExtension] lowercaseString];
                
                if(types) {
                    if([types containsObject:pathExtension])
                        handler(path);
                } else {
                    handler(path);
                }
            }
        }
    }];
}


+ (void)showChooseFolderPanel:(void (^)(NSString * result))handler forWindow:(NSWindow *)window {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];
    
    [openDlg beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = [openDlg URL];
            handler([url path]);
        } else {
            handler(nil);
        }
    }];
}


+ (void)showPanelWithTypes:(NSArray *)types completionHandler:(void (^)(NSString * result))handler {
    [self showPanelWithTypes:types completionHandler:handler forWindow:[NSApp mainWindow]];
}

NSString* locationFilePath(TLFileLocation *location, NSString *extension) {
    return [NSString stringWithFormat:@"%@/%@.%@",path(),location.cacheKey,extension];
}

NSString* locationFilePathWithPrefix(TLFileLocation *location, NSString *prefix, NSString *extension) {
    return [NSString stringWithFormat:@"%@/%@_%@.%@",path(),location.cacheKey,prefix,extension];
}

NSString* mediaFilePath(TLMessageMedia *media) {
    if([media isKindOfClass:[TL_messageMediaAudio class]]) {
        return [NSString stringWithFormat:@"%@/%lu_%lu.ogg",path(),media.audio.n_id,media.audio.access_hash];
    }
    if([media isKindOfClass:[TL_messageMediaVideo class]]) {
        return [NSString stringWithFormat:@"%@/%lu_%lu.mp4",path(),media.video.n_id,media.video.access_hash];
    }
    
    if([media isKindOfClass:[TL_messageMediaDocument class]]) {
        return [media.document isSticker] ? [NSString stringWithFormat:@"%@/%ld.webp",path(),media.document.n_id] : [FileUtils documentName:media.document];
    }
    
    if([media isKindOfClass:[TL_messageMediaPhoto class]]) {
        TL_photoSize *size = [media.photo.sizes lastObject];
        return locationFilePath(size.location, @"tiff");
    }
    
    return nil;
}

NSString* documentPath(TLDocument *document) {
    NSString *fileName = document.file_name;
    
    if([document isKindOfClass:[TL_outDocument class]]) {
        NSString *path_for_file = ((TL_outDocument *)document).file_path;
        if(isPathExists(path_for_file)) {
            return path_for_file;
        }
    }
    
    
    
    NSArray *item = [fileName componentsSeparatedByCharactersInSet:
                     [NSCharacterSet characterSetWithCharactersInString:@"."]];
    NSString *extenstion = [FileUtils extensionformime:document.mime_type];
    
    if(item.count >= 2) {
        return [NSString stringWithFormat:@"%@/%@",[SettingsArchiver documentsFolder],document.file_name];
    }
    
    return [NSString stringWithFormat:@"%@/%@.%@",[SettingsArchiver documentsFolder],item[0],extenstion];
    

    
}

NSString* dp() {
  //  NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES)[0];
   // NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
   // NSString *path = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"documents"];
    
   // if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
        
   // }
    return applicationSupportPath;
}

NSString* path() {
    static NSString* path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        path = @"";
        if ([paths count]) {
            NSString *bundleName =
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            
            path = [[paths objectAtIndex:0] stringByAppendingString:@"/"];
            path = [path stringByAppendingString:bundleName];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
            
            path = [path stringByAppendingString:@"/cache"];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    });
    return path;
}

+(NSString *)path {
    return path();
}

+(NSString *)extensionformime:(NSString *)mimetype {
    NSString *ex = [[[self sharedManager] mimeTypes] objectForKey:mimetype];
    if(!ex)
        ex = [[[self sharedManager] extensions] objectForKey:@"*"];
    return ex;
}


+(NSString *)documentName:(TLDocument *)document {
    return [self documentName:document number:0];
}

+(NSString *)documentName:(TLDocument *)document number:(int)number {
    NSString *doc = documentPath(document);
    NSString *pathExtension = [doc pathExtension];
    NSString *name = [doc stringByDeletingPathExtension];
    
    NSString *path = number > 0 ? [NSString stringWithFormat:@"%@ (%d).%@",name,number,pathExtension] : documentPath(document);
    
    if([self checkNormalizedSize:path checksize:document.size])
        return path;
    
    
    
    if(isPathExists(path))
        return [self documentName:document number:++number];
    return path;
}

BOOL check_file_size(NSString *path) {
    return fileSize(path) < MAX_FILE_SIZE;
}


void alert_bad_files(NSArray *bad_files) {
    NSString *bad_string = [bad_files componentsJoinedByString:@", "];
    NSString *localize = NSLocalizedString(@"Conversation.Send.FilesSizeError", nil);
    
    alert(NSLocalizedString(@"App.MaxFileSize", nil),[NSString stringWithFormat:localize, bad_string]);
}

void confirm(NSString *text, NSString *info, void (^block)(void), void (^cancelBlock)(void)) {
    
    NSAlert *alert = [NSAlert alertWithMessageText:text ? text : @"" informativeText:info ? info : @"" block:^(id result) {
        if([result intValue] == 1000)
            block();
         else if(cancelBlock)
            cancelBlock();
    }];
    [alert addButtonWithTitle:NSLocalizedString(@"Yes", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No", nil)];
    [alert show];
}

void alert(NSString *text, NSString *info) {
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setMessageText:text];
    [alert setInformativeText:info];
    [alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

+ (NSString *)dataMD5:(NSData *)data {
    NSUInteger size = [data length];
    
    NSString *md5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] md5];
    return [[NSString stringWithFormat:@"MD5_%@_%lu", md5, (unsigned long)size] md5];
    
}

+ (NSString *)fileMD5:(NSString *)path {
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
	if( handle == nil)
        return [@"ERROR GETTING FILE MD5" md5]; // file didnt exist
	
    NSUInteger size = fileSize(path);
    
	NSData *fileData = [[NSData alloc] initWithData:[handle readDataOfLength:MIN(size, 4096)]];
    NSString *md5 = [[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] md5];
    return [[NSString stringWithFormat:@"MD5_%@_%lu", md5, (unsigned long)size] md5];
}


+(NSString *)mimetypefromExtension:(NSString *)extension {
    NSString *mimeType = [[[self sharedManager] mimeTypes] objectForKey:extension];
    if(!mimeType)
        mimeType = [[[self sharedManager] mimeTypes] objectForKey:@"*"];
    return mimeType;
}

+(NSString*)extensionForMimetype:(NSString *)mimetype {
    return [[self sharedManager] extensions][mimetype];
}

/*
 ~/Library/Sounds
 /Library/Sounds
 /Network/Library/Sounds
 /System/Library/Sounds
 */

NSArray * soundsList() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.aiff'"];
    
    [list addObject:@"DefaultSoundName"];
    
    [list addObject:@"None"];

    NSArray *dirContents = [fm contentsOfDirectoryAtPath:@"~/Library/Sounds" error:nil];
    [list addObjectsFromArray:[dirContents filteredArrayUsingPredicate:fltr]];
    
    dirContents = [fm contentsOfDirectoryAtPath:@"/Library/Sounds" error:nil];
    [list addObjectsFromArray:[dirContents filteredArrayUsingPredicate:fltr]];
    
    dirContents = [fm contentsOfDirectoryAtPath:@"/Network/Library/Sounds" error:nil];
    [list addObjectsFromArray:[dirContents filteredArrayUsingPredicate:fltr]];
    
    dirContents = [fm contentsOfDirectoryAtPath:@"/System/Library/Sounds" error:nil];
    [list addObjectsFromArray:[dirContents filteredArrayUsingPredicate:fltr]];
    
    
    
    for (int i = 0; i < list.count; i++) {
        list[i] = [list[i] stringByDeletingPathExtension];
    }
    
    return [list sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        if([obj2 isEqualToString:[SettingsArchiver soundNotification]]) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
        
    }];

}
void playSentMessage(BOOL play) {
    [ASQueue dispatchOnStageQueue:^{
        static NSSound *sound ;
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            sound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sent" ofType:@"caf"] byReference:YES];
            [sound setVolume:1.0f];
        });
        if(play && [SettingsArchiver checkMaskedSetting:SoundEffects])
            [sound play];
    }];

}

NSArray *mediaTypes() {
    return @[@"png", @"tiff", @"jpeg", @"jpg", @"mp4",@"mov",@"avi"];
}

NSArray *videoTypes() {
    return @[@"mp4",@"mov",@"avi"];
}

NSArray *imageTypes() {
    return @[@"png", @"tiff", @"jpeg", @"jpg"];
}




void open_card(NSString *link) {
    
    
    NSArray *card = encodeCard(link);
    
    if(card) {
        
        [TMViewController showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_contacts_importCard createWithExport_card:[card mutableCopy]] successHandler:^(RPCRequest *request, id response) {
            
            [TMViewController hideModalProgress];
            
            dispatch_after_seconds(0.2,^ {
                if(![response isKindOfClass:[TL_userEmpty class]]) {
                    [[UsersManager sharedManager] add:@[response]];
                    
                    [[Telegram rightViewController] showUserInfoPage:[[UsersManager sharedManager] find:[(TLUser *)response n_id]]];
                } else {
                    alert(NSLocalizedString(@"CardImport.ErrorTextUserNotExist", nil), NSLocalizedString(@"CardImport.ErrorDescUserNotExist", nil));
                }
            });
            
          
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
             [TMViewController hideModalProgress];
            
            dispatch_after_seconds(0.2, ^{
                if(error.error_code == 400) {
                    alert(NSLocalizedString(@"CardImport.ErrorTextUserNotExist", nil), NSLocalizedString(@"CardImport.ErrorDescUserNotExist", nil));
                }
            });
            
          
            
        } timeout:4];
    }
    

}

void open_user_by_name(NSString * userName) {
    
    NSArray *users = [UsersManager findUsersByName:userName];
    
    if(users.count == 1) {
        [[Telegram rightViewController] showUserInfoPage:users[0]];
    } else {
        [TMViewController showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_contacts_resolveUsername createWithUsername:userName] successHandler:^(RPCRequest *request, TLUser *response) {
            
            [TMViewController hideModalProgress];
            
            dispatch_after_seconds(0.2,^ {
                
                if(![response isKindOfClass:[TL_userEmpty class]]) {
                    
                    [[UsersManager sharedManager] add:@[response] withCustomKey:@"n_id" update:YES];
                    
                    [[Telegram rightViewController] showUserInfoPage:[[UsersManager sharedManager] find:response.n_id]];
                } else {
                    alert(NSLocalizedString(@"UserNameExport.UserNameNotFound", nil), NSLocalizedString(@"UserNameExport.UserNameNotFoundDescription", nil));
                }
                
            });
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            [TMViewController hideModalProgress];
            
            dispatch_after_seconds(0.2, ^{
                if(error.error_code == 400) {
                    alert(NSLocalizedString(@"UserNameExport.UserNameNotFound", nil), NSLocalizedString(@"UserNameExport.UserNameNotFoundDescription", nil));
                }
            });
           
            
        } timeout:4];
    }
    
    
}


BOOL NSStringIsValidEmail(NSString *checkString) {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

void open_link(NSString *link) {
    
    
    if([link hasPrefix:TGImportCardPrefix]) {
        
        open_card([link substringFromIndex:TGImportCardPrefix.length]);
        
        return;
    }
    
    
    if([link hasPrefix:TLUserNamePrefix]) {
        open_user_by_name([link substringFromIndex:TLUserNamePrefix.length]);
        return;
    }
    
    
    NSRange checkRange = [link rangeOfString:@"telegram.me/"];
    
    if(checkRange.location != NSNotFound) {
        
        NSString *name = [link substringFromIndex:checkRange.location + checkRange.length ];
        
        if(name.length > 0) {
            open_user_by_name(name);
            
            return;
        } 
    }
    
    
    if(![link hasPrefix:@"http"] && ![link hasPrefix:@"ftp"]) {
        
        if(!NSStringIsValidEmail(link)) {
            link = [@"http://" stringByAppendingString:link];
        } else if(![link hasPrefix:@"mailto:"]) {
            link = [@"mailto:" stringByAppendingString:link];
        }
    }

    
    
    
    
    NSURL *url = [NSURL URLWithString:link];
    if([SettingsArchiver checkMaskedSetting:OpenLinksInBackground]) {
        [[NSWorkspace sharedWorkspace] openURLs:@[url] withAppBundleIdentifier:nil options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:nil];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}


BOOL zipDirectory(NSURL *directoryURL, NSString * archivePath)
{
    //Delete existing zip
    if ( [[NSFileManager defaultManager] fileExistsAtPath:archivePath] ) {
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:nil];
    }
    
    //Specify action
    NSString *toolPath = @"/usr/bin/zip";
    
    //Get directory contents
    NSArray *pathsArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[directoryURL path] error:nil];
    
    //Add arguments
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments insertObject:@"-r" atIndex:0];
    [arguments insertObject:archivePath atIndex:0];
    for ( NSString *filePath in pathsArray ) {
        [arguments addObject:filePath]; //Maybe this would even work by specifying relative paths with ./ or however that works, since we set the working directory before executing the command
        //[arguments insertObject:@"-j" atIndex:0];
    }
    
    //Switch to a relative directory for working.
    NSString *currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[directoryURL path]];
    //NSLog(@"dir %@", [[NSFileManager defaultManager] currentDirectoryPath]);
    
    //Create
    NSTask *task = [[NSTask alloc] init] ;
    [task setLaunchPath:toolPath];
    [task setArguments:arguments];
    
    //Run
    [task launch];
    [task waitUntilExit];
    
    //Restore normal path
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:currentDirectory];
    
    //Update filesystem
    [[NSWorkspace sharedWorkspace] noteFileSystemChanged:archivePath];
    
    return ([task terminationStatus] == 0);
}

BOOL NSSizeNotZero(NSSize size) {
    return size.width > 0 || size.height > 0;
}

BOOL NSContainsSize(NSSize size1, NSSize size2) {
    return size1.width == size2.width && size1.height == size2.height;
}


NSImage *cropImage(NSImage *image,NSSize backSize, NSPoint difference) {
    NSImage *source = image;
    NSImage *target = [[NSImage alloc]initWithSize:backSize];
    
    [target lockFocus];
    [source drawInRect:NSMakeRect(0,0,backSize.width,backSize.height)
              fromRect:NSMakeRect(difference.x,difference.y,backSize.width,backSize.height)
             operation:NSCompositeCopy
              fraction:1.0];
    [target unlockFocus];
    
    return target;
}

NSString *exportPath(long randomId, NSString *extension) {
    NSString *applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString *applicationName = appName();
    NSString *exportDirectory = [[applicationSupportPath stringByAppendingPathComponent:applicationName] stringByAppendingPathComponent:@"exports"];
   
    [[NSFileManager defaultManager] createDirectoryAtPath:exportDirectory
       withIntermediateDirectories:YES
                        attributes:nil
                             error:nil];
    
    
    return [NSString stringWithFormat:@"%@/%lu.%@",exportDirectory,randomId,extension];
}


NSString *decodeCard(NSArray *card) {
    
    __block NSString *c = @"";
    
    NSMutableArray *hex = [[NSMutableArray alloc] init];
    
    [card enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [hex insertObject:[NSString stringWithFormat:@"%x",[obj intValue]] atIndex:idx];
    }];
    
    c = [hex componentsJoinedByString:@":"];
    
    return c;
}


NSArray *encodeCard(NSString *card) {
    NSArray *hex = [card componentsSeparatedByString:@":"];
    
    if(hex.count >= 3 && hex.count <= 10) {
        NSMutableArray *digit = [[NSMutableArray alloc] init];
        [hex enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            
            NSScanner *scanner = [NSScanner scannerWithString:obj];
            
            int result = 0;

            [scanner scanHexInt:&result];
            
            
            [digit insertObject:@(result) atIndex:idx];
        }];
        
        return digit;
    }
    
    return nil;
}



+ (void) fillAppByUrl:(NSURL*)url bundle:(NSString**)bundle name:(NSString**)name version:(NSString**)version icon:(NSImage**)icon {
    NSBundle *b = [NSBundle bundleWithURL:url];
    if (b) {
        NSString *path = [url path];
        *name = [[NSFileManager defaultManager] displayNameAtPath: path];
        if (!*name) *name = (NSString*)[b objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if (!*name) *name = (NSString*)[b objectForInfoDictionaryKey:@"CFBundleName"];
        if (*name) {
            *bundle = [b bundleIdentifier];
            if (bundle) {
                *version = (NSString*)[b objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
                *icon = [[NSWorkspace sharedWorkspace] iconForFile: path];
                if (*icon && [*icon isValid]) [*icon setSize: CGSizeMake(16., 16.)];
                return;
            }
        }
    }
    *bundle = *name = *version = nil;
    *icon = nil;
}

+(NSArray *)appsForFileUrl:(NSString *)fileUrl {
    
    NSArray *appsList = (__bridge NSArray*)LSCopyApplicationURLsForURL((__bridge CFURLRef)[NSURL fileURLWithPath:fileUrl], kLSRolesAll);
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:16];
    int fullcount = 0;
    for (id app in appsList) {
        if (fullcount > 15) break;
        
        NSString *bundle = nil, *name = nil, *version = nil;
        NSImage *icon = nil;
        [FileUtils fillAppByUrl:(NSURL*)app bundle:&bundle name:&name version:&version icon:&icon];
        if (bundle && name) {
            NSString *key = [[NSArray arrayWithObjects:bundle, name, nil] componentsJoinedByString:@"|"];
            if (!version) version = @"";
            
            NSMutableDictionary *versions = (NSMutableDictionary*)[data objectForKey:key];
            if (!versions) {
                versions = [NSMutableDictionary dictionaryWithCapacity:2];
                [data setValue:versions forKey:key];
            }
            if (![versions objectForKey:version]) {
                [versions setValue:[NSArray arrayWithObjects:name, icon, app, nil] forKey:version];
                ++fullcount;
            }
        }
    }
    
    
    NSMutableArray *apps = [NSMutableArray arrayWithCapacity:fullcount];
    for (id key in data) {
        NSMutableDictionary *val = (NSMutableDictionary*)[data objectForKey:key];
        for (id ver in val) {
            NSArray *app = (NSArray*)[val objectForKey:ver];
            
            NSString *fullname = (NSString*)[app objectAtIndex:0], *version = (NSString*)ver;
            BOOL showVersion = ([val count] > 1);
            if (!showVersion) {
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+\\.\\d+\\.\\d+(\\.\\d+)?$" options:NSRegularExpressionCaseInsensitive error:&error];
                showVersion = ![regex numberOfMatchesInString:version options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0,[version length])];
            }
            if (showVersion) fullname = [[NSArray arrayWithObjects:fullname, @" (", version, @")", nil] componentsJoinedByString:@""];
            OpenWithObject *a = [[OpenWithObject alloc] initWithFullname:fullname app:app[2] icon:app[1]];
            
            [apps addObject:a];
        }
    }
    
    
    return apps;
}

int64_t SystemIdleTime(void) {
    int64_t idlesecs = -1;
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iter) == KERN_SUCCESS) {
        io_registry_entry_t entry = IOIteratorNext(iter);
        if (entry) {
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
                CFNumberRef obj = CFDictionaryGetValue(dict, CFSTR("HIDIdleTime"));
                if (obj) {
                    int64_t nanoseconds = 0;
                    if (CFNumberGetValue(obj, kCFNumberSInt64Type, &nanoseconds)) {
                        idlesecs = (nanoseconds >> 30); // Divide by 10^9 to convert from nanoseconds to seconds.
                    }
                }
                CFRelease(dict);
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
    }
    
    return idlesecs;
}


@end
